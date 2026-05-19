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
        selectedSPF: .none,
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
        selectedSPF: .none,
        acknowledgedDisclaimer: true
    )

    let result = try await workflow.fetchEstimate(
        for: session,
        at: UVCoordinate(latitude: 37.7749, longitude: -122.4194)
    )

    #expect(result.snapshot.roundedCoordinate == UVCoordinate(latitude: 37.77, longitude: -122.42))
    #expect(result.estimate.roundedDisplayMinutes == 17)
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
        spf: .none,
        uvIndex: 10
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

@Test func zeroUVEstimateDoesNotExpire() throws {
    let fetchedAt = Date(timeIntervalSince1970: 1_000)
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeVI,
        spf: .spf70Plus,
        uvIndex: 0
    )

    #expect(!estimate.isElapsed(fetchedAt: fetchedAt, now: fetchedAt.addingTimeInterval(7_200)))
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
