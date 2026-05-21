// ForecastProviderTests.swift — WI-7 test Groups E (provider integration), F (scenePhase), G (persistence guards)
// Spec: .squad/designs/wi-7/kwame-forecast-storage-mechanism.md §Refresh strategy, §Cleanup
//       .squad/designs/wi-7/gi-forecast-data-lifecycle.md §8, §9
// Kwame's WeatherKitForecastProvider lives in the app target (uses WeatherKit); tested here
// via mock doubles through the ForecastProviding protocol.

import Foundation
import Testing
@testable import UVBurnTimerCore

// MARK: - Test doubles

/// A `ForecastProviding` implementation that always returns a preset snapshot.
private actor StaticForecastProvider: ForecastProviding {
    let snapshot: ForecastSnapshot
    private(set) var callCount = 0

    init(snapshot: ForecastSnapshot) {
        self.snapshot = snapshot
    }

    func fetchForecast(at coordinate: UVCoordinate) async throws -> ForecastSnapshot {
        callCount += 1
        return snapshot
    }
}

/// A `ForecastProviding` implementation that always throws a given error.
private actor FailingForecastProvider: ForecastProviding {
    let error: Error
    private(set) var callCount = 0

    init(error: Error = URLError(.notConnectedToInternet)) {
        self.error = error
    }

    func fetchForecast(at coordinate: UVCoordinate) async throws -> ForecastSnapshot {
        callCount += 1
        throw error
    }
}

// MARK: - Helpers

private func isolatedStoreURL() -> URL {
    FileManager.default
        .urls(for: .cachesDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("wi7-provider-test-\(UUID().uuidString).json")
}

private let sfCoordProvider = UVCoordinate(latitude: 37.77, longitude: -122.42)
private let baseEpochProvider: TimeInterval = 1_748_016_000   // 2026-05-23 12:00:00 UTC

private func makeFullSnapshot(
    latitude: Double = 37.77,
    longitude: Double = -122.42,
    expirationDate: Date = Date.distantFuture,
    dayCount: Int = 10
) -> ForecastSnapshot {
    let base = Date(timeIntervalSince1970: baseEpochProvider)
    var hours: [HourForecast] = []
    let days: [DayForecast] = (0..<dayCount).map { d in
        let dayDate = base.addingTimeInterval(Double(d) * 86400)
        for h in 0..<24 {
            hours.append(HourForecast(
                timestamp: dayDate.addingTimeInterval(Double(h) * 3600),
                uvIndex: (h >= 6 && h <= 18) ? 6.0 : 0.0
            ))
        }
        return DayForecast(date: dayDate, dailyMinUVI: 0, dailyMaxUVI: 6, sunrise: nil, sunset: nil)
    }
    return ForecastSnapshot(
        schemaVersion: ForecastSnapshot.currentSchemaVersion,
        latitude: latitude,
        longitude: longitude,
        fetchedAt: base,
        expirationDate: expirationDate,
        days: days,
        hours: hours
    )
}

// MARK: - Group E: WeatherKit provider integration (mock-based)

/// E22 — Provider must capture `expirationDate` from WeatherKit metadata and forward it
/// to the stored snapshot.
/// WeatherKit: `Forecast<DayWeather>.metadata.expirationDate` is the authoritative expiry.
/// No hardcoded N-hour threshold (per Kwame design decision and ForecastSnapshot.expirationDate
/// contract in ForecastSnapshot.swift).
///
/// This test verifies the contract via a mock provider (WeatherKit is not available in
/// Swift Package Manager unit tests). The production `WeatherKitForecastProvider` must
/// satisfy the same contract; empirical verification requires a device.
@Test func test_provider_captures_expirationDate_from_metadata() async throws {
    let specificExpiry = Date(timeIntervalSince1970: 1_748_100_000)  // a specific future date
    let snapshotWithExpiry = makeFullSnapshot(expirationDate: specificExpiry)

    let provider = StaticForecastProvider(snapshot: snapshotWithExpiry)
    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)

    // Simulate what the coordinator does on scenePhase active
    let fetched = try await provider.fetchForecast(at: sfCoordProvider)
    try await store.save(fetched)

    let loaded = try await store.load()
    let required = try #require(loaded)

    #expect(required.expirationDate == specificExpiry,
            "expirationDate must be preserved exactly from provider (sourced from WeatherKit metadata)")
}

/// E23 — A provider returning only 5 days (partial WeatherKit response) must produce
/// a snapshot with days.count == 5 and hours.count == 5 × 24 = 120.
/// Gi §8 boundary-clamping: `pickerUpperBound` clamps to last available day.
@Test func test_provider_handles_partial_response_gracefully() async throws {
    let partialSnapshot = makeFullSnapshot(dayCount: 5)
    #expect(partialSnapshot.days.count == 5)
    #expect(partialSnapshot.hours.count == 120,
            "5 days × 24 hours = 120 — invariant must hold even for partial responses")

    let provider = StaticForecastProvider(snapshot: partialSnapshot)
    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)

    let fetched = try await provider.fetchForecast(at: sfCoordProvider)
    try await store.save(fetched)

    let loaded = try await store.load()
    let required = try #require(loaded)
    #expect(required.days.count == 5)
    #expect(required.hours.count == required.days.count * 24)
}

// MARK: - Group F: scenePhase refresh logic

/// F24 — Fresh snapshot + scenePhase → .active must NOT re-fetch.
/// Snapshot is fresh (expirationDate in the far future) and coord is the same.
@Test func test_scenePhase_active_with_fresh_snapshot_does_not_refetch() async throws {
    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)

    // Save a fresh snapshot (expires 24 h from base)
    let freshExpiry = Date(timeIntervalSince1970: baseEpochProvider + 3600 * 24)
    let freshSnapshot = makeFullSnapshot(expirationDate: freshExpiry)
    try await store.save(freshSnapshot)

    let provider = StaticForecastProvider(snapshot: freshSnapshot)
    let coordinator = ForecastRefreshCoordinator(store: store, provider: provider)

    // Simulate scenePhase → .active at a time well before expiry
    let nowBeforeExpiry = Date(timeIntervalSince1970: baseEpochProvider + 3600)  // 1 h after base
    await coordinator.handleSceneActive(
        currentLatitude: sfCoordProvider.latitude,
        currentLongitude: sfCoordProvider.longitude,
        now: nowBeforeExpiry
    )

    let providerCallCount = await provider.callCount
    let coordinatorFetchCount = await coordinator.fetchCallCount
    #expect(coordinatorFetchCount == 0, "Fresh snapshot → no re-fetch expected")
    #expect(providerCallCount == 0, "No WeatherKit call should be made for a fresh snapshot")
}

/// F25 — Expired snapshot + scenePhase → .active MUST trigger a re-fetch.
@Test func test_scenePhase_active_with_expired_snapshot_triggers_refetch() async throws {
    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)

    // Save a snapshot that is already stale
    let staleExpiry = Date(timeIntervalSince1970: 0)  // epoch = always stale
    let staleSnapshot = makeFullSnapshot(expirationDate: staleExpiry)
    try await store.save(staleSnapshot)

    // Provider returns a fresh snapshot to simulate a successful re-fetch
    let freshExpiry = Date(timeIntervalSince1970: baseEpochProvider + 3600 * 24)
    let freshSnapshot = makeFullSnapshot(expirationDate: freshExpiry)
    let provider = StaticForecastProvider(snapshot: freshSnapshot)
    let coordinator = ForecastRefreshCoordinator(store: store, provider: provider)

    let nowPastExpiry = Date()  // current time always > epoch
    await coordinator.handleSceneActive(
        currentLatitude: sfCoordProvider.latitude,
        currentLongitude: sfCoordProvider.longitude,
        now: nowPastExpiry
    )

    let coordinatorFetchCount = await coordinator.fetchCallCount
    let providerCallCount = await provider.callCount
    #expect(coordinatorFetchCount == 1, "Expired snapshot → re-fetch must occur")
    #expect(providerCallCount == 1, "WeatherKit fetch must be called once for expired snapshot")
}

/// F26 — Fresh snapshot but coord moved > 50 km → scenePhase .active MUST re-fetch.
/// Coord delta >50 km is an eviction trigger (Gi §3 Trigger 2, 50 km NWP spatial resolution).
@Test func test_scenePhase_active_with_far_coord_triggers_refetch() async throws {
    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)

    // Snapshot stored at SF coords, fresh expiry
    let freshExpiry = Date(timeIntervalSince1970: baseEpochProvider + 3600 * 24)
    let freshSnapshot = makeFullSnapshot(
        latitude: sfCoordProvider.latitude,
        longitude: sfCoordProvider.longitude,
        expirationDate: freshExpiry
    )
    try await store.save(freshSnapshot)

    // Current coord is ~55 km north of SF (outside the 50 km radius)
    let farLat = sfCoordProvider.latitude + 0.5   // +0.5° ≈ 55.5 km
    let provider = StaticForecastProvider(snapshot: freshSnapshot)
    let coordinator = ForecastRefreshCoordinator(store: store, provider: provider)

    let nowBeforeExpiry = Date(timeIntervalSince1970: baseEpochProvider + 3600)
    await coordinator.handleSceneActive(
        currentLatitude: farLat,
        currentLongitude: sfCoordProvider.longitude,
        now: nowBeforeExpiry
    )

    let coordinatorFetchCount = await coordinator.fetchCallCount
    #expect(coordinatorFetchCount == 1,
            "Coord moved >50 km → re-fetch must occur even when snapshot is fresh")
}

// MARK: - Group G: Persistence rule guards (LAUNCH-PLAN §9 compliance)

/// G27 — A ForecastSnapshot must never contain a field encoding skin type.
/// skin type and SPF must never be transmitted in `ForecastSnapshot` (server-visible payload).
/// This test is a regression guard against future contributors accidentally adding skinType to the snapshot.
@Test func test_skinType_is_never_in_snapshot() throws {
    let snapshot = makeFullSnapshot()
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(snapshot)
    let jsonString = String(decoding: data, as: UTF8.self).lowercased()

    // None of these identifiers should appear in the serialized snapshot
    let forbidden = ["skintype", "skin_type", "fitzpatrick", "typeI", "typeII",
                     "typei", "typeii", "typeiii", "typeiv", "typev", "typevi"]
    for key in forbidden {
        #expect(!jsonString.contains(key),
                "Forbidden skin-type key '\(key)' found in ForecastSnapshot JSON")
    }
}

/// G28 — A ForecastSnapshot must never contain a field encoding SPF level.
/// skin type and SPF must never be transmitted in `ForecastSnapshot` (server-visible payload).
@Test func test_spf_is_never_in_snapshot() throws {
    let snapshot = makeFullSnapshot()
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(snapshot)
    let jsonString = String(decoding: data, as: UTF8.self).lowercased()

    let forbidden = ["spf", "sunscreenfactor", "sunscreen_factor", "protectionfactor", "sunprotection"]
    for key in forbidden {
        #expect(!jsonString.contains(key),
                "Forbidden SPF key '\(key)' found in ForecastSnapshot JSON")
    }
}
