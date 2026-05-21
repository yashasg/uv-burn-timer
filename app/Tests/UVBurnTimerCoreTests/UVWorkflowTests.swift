import Foundation
import Testing

@testable import UVBurnTimerCore

@Test func workflowRequiresSkinTypeBeforeFetchingUV() async {
    let workflow = UVBurnTimerWorkflow(uvProvider: StaticUVDataProvider(uvIndex: 8))

    await #expect(throws: UVBurnTimerWorkflowError.missingSkinType) {
        try await workflow.fetchEstimate(
            for: UVBurnTimerSession(),
            at: UVCoordinate(latitude: 37.7749, longitude: -122.4194)
        )
    }
}

@Test func workflowRequiresDisclaimerAcknowledgementBeforeFetchingUV() async {
    let workflow = UVBurnTimerWorkflow(uvProvider: StaticUVDataProvider(uvIndex: 8))
    let session = UVBurnTimerSession(
        selectedSkinType: .typeI,
        selectedSPF: .spf30,
        acknowledgedDisclaimer: false
    )

    await #expect(throws: UVBurnTimerWorkflowError.disclaimerNotAcknowledged) {
        try await workflow.fetchEstimate(
            for: session,
            at: UVCoordinate(latitude: 37.7749, longitude: -122.4194)
        )
    }
}

@Test func workflowRoundsCoordinatesBeforeWeatherRequest() async throws {
    let workflow = UVBurnTimerWorkflow(uvProvider: StaticUVDataProvider(uvIndex: 8))
    let session = UVBurnTimerSession(
        selectedSkinType: .typeI,
        selectedSPF: .spf30,
        acknowledgedDisclaimer: true
    )

    let result = try await workflow.fetchEstimate(
        for: session,
        at: UVCoordinate(latitude: 37.7749, longitude: -122.4194)
    )

    #expect(result.snapshot.roundedCoordinate == UVCoordinate(latitude: 37.77, longitude: -122.42))
    #expect(result.estimate.roundedDisplayMinutes == 120)
    #expect(result.estimate.isCappedForSunscreenReapplication)
}

@Test func cachedRoundedCoordinateStorageNeverPersistsPreciseCoordinates() throws {
    let cached = CachedRoundedCoordinate(
        roundedCoordinate: UVCoordinate(latitude: 37.7749, longitude: -122.4194)
    )
    let storageValue = try CachedRoundedCoordinateStorage.storageValue(for: cached)
    let restoredCoordinate = try CachedRoundedCoordinateStorage.roundedCoordinate(from: storageValue)

    #expect(cached.roundedCoordinate == UVCoordinate(latitude: 37.77, longitude: -122.42))
    #expect(restoredCoordinate == UVCoordinate(latitude: 37.77, longitude: -122.42))
    #expect(!storageValue.contains("37.7749"))
    #expect(!storageValue.contains("-122.4194"))
}

@Test func workflowSurfacesProviderFailures() async {
    let workflow = UVBurnTimerWorkflow(uvProvider: ThrowingUVDataProvider(error: ProviderFailure.offline))
    let session = UVBurnTimerSession(
        selectedSkinType: .typeIII,
        selectedSPF: .spf30,
        acknowledgedDisclaimer: true
    )

    await #expect(throws: ProviderFailure.offline) {
        try await workflow.fetchEstimate(
            for: session,
            at: UVCoordinate(latitude: 37.7749, longitude: -122.4194)
        )
    }
}

@Test func estimateWindowExpiresAtEarlierOfBurnTimeOrTwoHourRefreshInterval() throws {
    let fetchedAt = Date(timeIntervalSince1970: 1_000)
    let shortEstimate = try BurnTimeCalculator.estimate(
        skinType: .typeI,
        spf: .spf15,
        uvIndex: 150
    )

    #expect(!shortEstimate.isElapsed(fetchedAt: fetchedAt, now: fetchedAt.addingTimeInterval(12 * 60)))
    #expect(shortEstimate.isElapsed(fetchedAt: fetchedAt, now: fetchedAt.addingTimeInterval(14 * 60)))

    let longEstimate = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .spf30,
        uvIndex: 8
    )

    #expect(!longEstimate.isElapsed(fetchedAt: fetchedAt, now: fetchedAt.addingTimeInterval(7_199)))
    #expect(longEstimate.isElapsed(fetchedAt: fetchedAt, now: fetchedAt.addingTimeInterval(7_200)))
}

@Test func unprotectedReferenceEstimateUsesBurnWindowInsteadOfSunscreenRefreshInterval() throws {
    let fetchedAt = Date(timeIntervalSince1970: 1_000)
    let longEstimate = try BurnTimeCalculator.estimate(
        skinType: .typeVI,
        spf: .unprotectedReference,
        uvIndex: 4
    )

    #expect(longEstimate.tier == .long)
    #expect(!longEstimate.isCappedForDisplay)
    #expect(longEstimate.rawMinutes > 120)
    #expect(!longEstimate.isElapsed(fetchedAt: fetchedAt, now: fetchedAt.addingTimeInterval(7_200)))
    #expect(
        longEstimate.isElapsed(
            fetchedAt: fetchedAt, now: fetchedAt.addingTimeInterval((longEstimate.rawMinutes * 60) + 1)))
}

@Test func zeroUVEstimateDoesNotExpire() throws {
    let fetchedAt = Date(timeIntervalSince1970: 1_000)
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeVI,
        spf: .spf70Plus,
        uvIndex: 0
    )

    #expect(!estimate.isElapsed(fetchedAt: fetchedAt, now: fetchedAt.addingTimeInterval(7_200)))
}

/// WI-12 storage contract: `Settings → Clear saved location` clears the cached
/// rounded coordinate (and the legacy UV snapshot key) but must NOT clear the
/// persisted skin type and SPF preferences. Uninstall (`clearStoredPreferences`)
/// is the universal escape hatch for clearing all persisted prefs.
///
/// This test pins the storage-layer contract that `RootView.clearSavedRoundedCoordinate`
/// relies on (it writes `CachedRoundedCoordinateStorage.clearedStorageValue`
/// to the two coordinate keys via `@AppStorage` and never touches skin-type/SPF keys).
@Test func clearingCachedCoordinateDoesNotClearSkinTypeAndSPF() throws {
    let suiteName = "WI12-clearCoord-\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }

    let cachedRoundedCoordinateKey = "lastRoundedCoordinate"
    let legacyCachedUVSnapshotKey = "lastUVSnapshot"

    let snapshot = UVSnapshot(
        uvIndex: 6,
        fetchedAt: Date(timeIntervalSince1970: 1_000),
        roundedCoordinate: UVCoordinate(latitude: 37.77, longitude: -122.42)
    )
    let storageValue = try CachedRoundedCoordinateStorage.storageValue(for: snapshot)
    defaults.set(storageValue, forKey: cachedRoundedCoordinateKey)
    defaults.set(storageValue, forKey: legacyCachedUVSnapshotKey)
    defaults.set(FitzpatrickSkinType.typeIII.rawValue, forKey: UserPreferenceStorage.selectedSkinTypeKey)
    defaults.set(SPFLevel.spf50.rawValue, forKey: UserPreferenceStorage.selectedSPFKey)

    // Simulate Settings → Clear saved location, which only touches the two
    // coordinate-keyed AppStorage values in RootView.clearSavedRoundedCoordinate.
    defaults.set(CachedRoundedCoordinateStorage.clearedStorageValue, forKey: cachedRoundedCoordinateKey)
    defaults.set(CachedRoundedCoordinateStorage.clearedStorageValue, forKey: legacyCachedUVSnapshotKey)

    // The cached coordinate is now cleared.
    #expect(defaults.string(forKey: cachedRoundedCoordinateKey) == "")
    #expect(defaults.string(forKey: legacyCachedUVSnapshotKey) == "")

    // Skin type and SPF must survive — they are orthogonal to the coordinate cache.
    let restored = UserPreferenceStorage.restoredSession(from: defaults)
    #expect(restored.selectedSkinType == .typeIII)
    #expect(restored.selectedSPF == .spf50)

    // The escape hatch — `UserPreferenceStorage.clearStoredPreferences`, which
    // is what app uninstall effectively does to the sandbox — clears all prefs.
    UserPreferenceStorage.clearStoredPreferences(from: defaults)
    #expect(UserPreferenceStorage.restoredSession(from: defaults).selectedSkinType == nil)
    #expect(UserPreferenceStorage.restoredSession(from: defaults).selectedSPF == .spf30)
}

private enum ProviderFailure: Error, Equatable {
    case offline
}

private struct ThrowingUVDataProvider: UVDataProviding {
    let error: ProviderFailure

    func currentUVIndex(at coordinate: UVCoordinate) async throws -> UVSnapshot {
        throw error
    }
}
