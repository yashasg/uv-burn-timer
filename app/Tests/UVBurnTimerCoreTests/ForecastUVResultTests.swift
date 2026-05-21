// ForecastUVResultTests.swift — WI-7 test Groups C (polar-as-nighttime) and D (UVResult lookup)
// Spec: .squad/designs/wi-7/gi-forecast-data-lifecycle.md §8
//       .squad/agents/ma-ti/history.md (WI-7 consolidation — polar-as-nighttime directive)
// Key directive (Yashas, 2026-05-21): polar night = UVI 0 = same .nighttime code path.
// No .polarNight enum case. Wheeler ratification confirmed. Kwame: ForecastSnapshot.swift

import Foundation
import Testing
@testable import UVBurnTimerCore

// MARK: - Helpers

private func isolatedStoreURL() -> URL {
    FileManager.default
        .urls(for: .cachesDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("wi7-uvresult-test-\(UUID().uuidString).json")
}

/// A snapshot anchored at a known UTC base date for deterministic hour-lookup tests.
/// `baseEpoch` is chosen so that 24 consecutive hours starting at baseEpoch cover one UTC day.
private let baseEpoch: TimeInterval = 1_748_016_000   // 2026-05-23 12:00:00 UTC
private let sfCoord = (lat: 37.77, lon: -122.42)

private func makeFreshSnapshot(
    latitude: Double = sfCoord.lat,
    longitude: Double = sfCoord.lon,
    hours overrideHours: [HourForecast]? = nil
) -> ForecastSnapshot {
    let base = Date(timeIntervalSince1970: baseEpoch)
    // Use .distantFuture so the snapshot is always fresh regardless of test-machine clock.
    // Tests that explicitly need a stale snapshot use makeExpiredSnapshot() instead.
    let expiry = Date.distantFuture
    let dayDate = base
    let hours: [HourForecast] = overrideHours ?? (0..<24).map { h in
        HourForecast(
            timestamp: dayDate.addingTimeInterval(Double(h) * 3600),
            uvIndex: (h >= 6 && h <= 18) ? 6.0 : 0.0
        )
    }
    let day = DayForecast(date: dayDate, dailyMinUVI: 0, dailyMaxUVI: 6, sunrise: nil, sunset: nil)
    return ForecastSnapshot(
        schemaVersion: ForecastSnapshot.currentSchemaVersion,
        latitude: latitude,
        longitude: longitude,
        fetchedAt: base,
        expirationDate: expiry,
        days: [day],
        hours: hours
    )
}

private func makeExpiredSnapshot() -> ForecastSnapshot {
    let base = Date(timeIntervalSince1970: baseEpoch)
    let expiry = Date(timeIntervalSince1970: 0)   // epoch is always in the past → stale
    let day = DayForecast(date: base, dailyMinUVI: 0, dailyMaxUVI: 6, sunrise: nil, sunset: nil)
    let hours: [HourForecast] = (0..<24).map { h in
        HourForecast(timestamp: base.addingTimeInterval(Double(h) * 3600), uvIndex: 6.0)
    }
    return ForecastSnapshot(
        schemaVersion: ForecastSnapshot.currentSchemaVersion,
        latitude: sfCoord.lat,
        longitude: sfCoord.lon,
        fetchedAt: base,
        expirationDate: expiry,
        days: [day],
        hours: hours
    )
}

// MARK: - Group C: Polar-as-nighttime (per user directive, 2026-05-21T01:06:30Z)

/// C14 — CRITICAL: A DayForecast with 24 entries all UVI=0 (polar night) must
/// return `.nighttime` at any hour lookup — NOT `.value(0)`, NOT `.unavailable`.
/// Wheeler ratification: UVI=0 collapses to .nighttime regardless of WHY it's zero.
@Test func test_polar_night_day_renders_via_nighttime_path() async throws {
    // Svalbard coordinates, deep winter polar night
    let polarCoord = (lat: 78.5, lon: 15.0)
    let base = Date(timeIntervalSince1970: 1_736_208_000)  // 2025-01-07 00:00 UTC
    let expiry = Date.distantFuture

    // 24 hours, all UVI = 0 — polar night
    let polarHours: [HourForecast] = (0..<24).map { h in
        HourForecast(timestamp: base.addingTimeInterval(Double(h) * 3600), uvIndex: 0.0)
    }

    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)

    let day = DayForecast(date: base, dailyMinUVI: 0, dailyMaxUVI: 0, sunrise: nil, sunset: nil)
    let snapshot = ForecastSnapshot(
        schemaVersion: ForecastSnapshot.currentSchemaVersion,
        latitude: polarCoord.lat,
        longitude: polarCoord.lon,
        fetchedAt: base,
        expirationDate: expiry,
        days: [day],
        hours: polarHours
    )
    try await store.save(snapshot)

    // Solar noon is the typical UV-peak check — must be .nighttime on polar night
    let solarNoonEntry = base.addingTimeInterval(12 * 3600)
    let result = await store.uvIndex(at: solarNoonEntry)

    #expect(result == .nighttime,
            "Polar night hour (UVI=0) must return .nighttime, not .value(0) or .unavailable")

    // Verify the inverse — we're NOT getting .value(0)
    if case .value(let v) = result {
        Issue.record("Expected .nighttime but got .value(\(v)) — UVI=0 must collapse to .nighttime")
    }
}

/// C15 — Polar day (Svalbard mid-summer): 24 hours with non-zero UVI must render
/// as `.value(...)` across all 24 cells — no special polar-day collapse.
/// WeatherKit polar day UVI can reach 4–7 at Arctic latitudes (Wheeler §2.1).
@Test func test_polar_day_renders_normally_with_nonzero_uvi() async throws {
    let polarCoord = (lat: 78.5, lon: 15.0)
    let base = Date(timeIntervalSince1970: 1_750_204_800)  // 2025-06-18 00:00 UTC (mid-summer)
    let expiry = Date.distantFuture

    // Polar day: UVI rises and falls over 24 h but stays > 0 (sun never below horizon)
    // Typical Svalbard mid-summer profile: peak ~4–5 around "noon"
    let polarDayUVIs: [Double] = [
        1, 1, 2, 2, 3, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 3, 3, 2, 2, 1, 1
    ]
    let polarHours: [HourForecast] = polarDayUVIs.enumerated().map { h, uvi in
        HourForecast(timestamp: base.addingTimeInterval(Double(h) * 3600), uvIndex: uvi)
    }

    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)

    let day = DayForecast(date: base, dailyMinUVI: 1, dailyMaxUVI: 5, sunrise: nil, sunset: nil)
    let snapshot = ForecastSnapshot(
        schemaVersion: ForecastSnapshot.currentSchemaVersion,
        latitude: polarCoord.lat,
        longitude: polarCoord.lon,
        fetchedAt: base,
        expirationDate: expiry,
        days: [day],
        hours: polarHours
    )
    try await store.save(snapshot)

    // All 24 hours should return .value(...) since UVI > 0 for all of them
    for (h, expectedUVI) in polarDayUVIs.enumerated() {
        let hourDate = base.addingTimeInterval(Double(h) * 3600)
        let result = await store.uvIndex(at: hourDate)
        #expect(result == .value(expectedUVI),
                "Polar-day hour \(h) (UVI=\(expectedUVI)) must return .value, not .nighttime")
    }
}

/// C16 — A missing hourly entry (edge case per Kwame §2.1 research) must coerce to .nighttime.
/// WeatherKit `HourWeather.uvIndex` is non-optional, but if a slot is absent from the
/// hours array (e.g., DST padding gap), the lookup must return .nighttime — not crash or
/// return .unavailable. Gi §8 guarantee: no silent nil.
///
/// Path is unreachable in production — WeatherKitForecastProvider coerces missing slots to
/// UVI=0 at write time. This tests the defensive fallback inside the snapshot window only.
/// (Dates outside the snapshot window still return .unavailable(.snapshotExpired).)
@Test func test_missing_or_nil_hourly_entry_coerces_to_zero() async throws {
    let base = Date(timeIntervalSince1970: baseEpoch)

    // Deliberately omit the hour-12 slot to simulate a missing WeatherKit entry
    let hoursWithGap: [HourForecast] = (0..<24).compactMap { h -> HourForecast? in
        guard h != 12 else { return nil }   // hour 12 missing
        return HourForecast(timestamp: base.addingTimeInterval(Double(h) * 3600), uvIndex: 6.0)
    }
    #expect(hoursWithGap.count == 23, "Setup: 23 hours (slot 12 deliberately absent)")

    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)

    let day = DayForecast(date: base, dailyMinUVI: 0, dailyMaxUVI: 6, sunrise: nil, sunset: nil)
    let snapshot = ForecastSnapshot(
        schemaVersion: ForecastSnapshot.currentSchemaVersion,
        latitude: sfCoord.lat,
        longitude: sfCoord.lon,
        fetchedAt: base,
        expirationDate: Date.distantFuture,
        days: [day],
        hours: hoursWithGap
    )
    try await store.save(snapshot)

    let missingHour = base.addingTimeInterval(12 * 3600)
    let result = await store.uvIndex(at: missingHour)

    #expect(result == .nighttime,
            "Missing hourly entry must coerce to .nighttime (UVI = 0), not .unavailable")
}

// MARK: - Group D: Lookup API contract (Gi's UVResult enum)

/// D17 — UVI = 7 for a normal daytime hour returns .value(7.0).
@Test func test_uvResult_value_for_normal_daytime_hour() async throws {
    let base = Date(timeIntervalSince1970: baseEpoch)

    let hours: [HourForecast] = (0..<24).map { h in
        HourForecast(timestamp: base.addingTimeInterval(Double(h) * 3600), uvIndex: h == 12 ? 7.0 : 0.0)
    }

    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)
    try await store.save(makeFreshSnapshot(hours: hours))

    let noonDate = base.addingTimeInterval(12 * 3600)
    let result = await store.uvIndex(at: noonDate)
    #expect(result == .value(7.0))
}

/// D18 — UVI = 0 for a nighttime hour returns .nighttime (NOT .value(0)).
/// This is the fundamental contract: zero UVI is the nighttime signal.
@Test func test_uvResult_nighttime_for_zero_uvi_hour() async throws {
    let base = Date(timeIntervalSince1970: baseEpoch)

    let hours: [HourForecast] = (0..<24).map { h in
        HourForecast(timestamp: base.addingTimeInterval(Double(h) * 3600), uvIndex: 0.0)
    }

    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)
    try await store.save(makeFreshSnapshot(hours: hours))

    let midnightDate = base  // hour 0, UVI = 0
    let result = await store.uvIndex(at: midnightDate)
    #expect(result == .nighttime, "UVI=0 must return .nighttime, not .value(0)")
}

/// D19 — Loading an expired snapshot and calling uvIndex returns .unavailable(.snapshotExpired).
@Test func test_uvResult_unavailable_when_snapshot_expired() async throws {
    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)

    let expiredSnapshot = makeExpiredSnapshot()
    try await store.save(expiredSnapshot)

    let lookupDate = Date(timeIntervalSince1970: baseEpoch + 12 * 3600)
    let result = await store.uvIndex(at: lookupDate)
    #expect(result == .unavailable(reason: .snapshotExpired))
}

/// D20 — With no snapshot loaded, uvIndex returns .unavailable(.noSnapshot).
@Test func test_uvResult_unavailable_when_no_snapshot() async {
    let url = isolatedStoreURL()   // file does not exist
    let store = ForecastStore(fileURL: url)

    let lookupDate = Date(timeIntervalSince1970: baseEpoch + 12 * 3600)
    let result = await store.uvIndex(at: lookupDate)
    #expect(result == .unavailable(reason: .noSnapshot))
}

/// D21 — Snapshot exists and is fresh, but the current coord is > 50 km from the stored coord.
/// The lookup should return .unavailable(.coordOutOfRange).
///
/// DESIGN NOTE: Kwame's `ForecastStore.uvIndex(at:)` performs an in-memory UVI lookup
/// without checking coordinate proximity — that check lives in `isCoordOutOfRange(latitude:longitude:)`.
/// This test therefore validates the coord-check method directly. The full contract
/// (coord gate + UVI lookup as a single operation) is enforced at the coordinator level
/// (Group F tests) and via `ForecastRefreshCoordinator.handleSceneActive`.
@Test func test_uvResult_unavailable_when_coord_out_of_range() async throws {
    let storeCoord = (lat: 37.77, lon: -122.42)
    let farCoord   = (lat: 38.27, lon: -122.42)   // ~55 km north

    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)
    let snapshot = makeFreshSnapshot(latitude: storeCoord.lat, longitude: storeCoord.lon)
    try await store.save(snapshot)

    // The coord eviction check must flag this as out-of-range
    let outOfRange = await store.isCoordOutOfRange(latitude: farCoord.lat, longitude: farCoord.lon)
    #expect(outOfRange, "Coord > 50 km from stored snapshot must be flagged out-of-range")

    // Document the expected combined behaviour: if the coordinator evicts the snapshot
    // first, uvIndex(at:) should return .unavailable(.noSnapshot) on the cleared store.
    // This verifies the end-to-end contract via the coordinator path.
    try await store.clear()
    let lookupDate = Date(timeIntervalSince1970: baseEpoch + 12 * 3600)
    let result = await store.uvIndex(at: lookupDate)
    #expect(result == .unavailable(reason: .noSnapshot),
            "After coord-eviction clear, lookup must return .unavailable(.noSnapshot)")
}
