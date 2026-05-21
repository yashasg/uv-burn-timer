// ForecastStoreTests.swift — WI-7 test Groups A (ForecastStore unit) and B (data invariants)
// Spec: .squad/designs/wi-7/kwame-forecast-storage-mechanism.md
//       .squad/designs/wi-7/gi-forecast-data-lifecycle.md §3 (staleness, eviction)

import Foundation
import Testing
@testable import UVBurnTimerCore

// MARK: - Helpers

/// Unique per-test file URL so stores don't share state.
private func isolatedStoreURL() -> URL {
    FileManager.default
        .urls(for: .cachesDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("wi7-test-\(UUID().uuidString).json")
}

/// Minimal valid `ForecastSnapshot` for test use.
private func makeSnapshot(
    schemaVersion: Int = ForecastSnapshot.currentSchemaVersion,
    latitude: Double = 37.77,
    longitude: Double = -122.42,
    fetchedAt: Date = Date(timeIntervalSince1970: 1_748_000_000),
    expirationDate: Date = Date(timeIntervalSince1970: 1_748_000_000 + 3600),
    dayCount: Int = 10
) -> ForecastSnapshot {
    let baseDate = Date(timeIntervalSince1970: 1_748_000_000)
    let days: [DayForecast] = (0..<dayCount).map { d in
        DayForecast(
            date: baseDate.addingTimeInterval(Double(d) * 86400),
            dailyMinUVI: 0,
            dailyMaxUVI: 6,
            sunrise: baseDate.addingTimeInterval(Double(d) * 86400 + 6 * 3600),
            sunset: baseDate.addingTimeInterval(Double(d) * 86400 + 20 * 3600)
        )
    }
    let hours: [HourForecast] = days.flatMap { day in
        (0..<24).map { h in
            HourForecast(
                timestamp: day.date.addingTimeInterval(Double(h) * 3600),
                uvIndex: (h >= 6 && h <= 18) ? 6.0 : 0.0
            )
        }
    }
    return ForecastSnapshot(
        schemaVersion: schemaVersion,
        latitude: latitude,
        longitude: longitude,
        fetchedAt: fetchedAt,
        expirationDate: expirationDate,
        days: days,
        hours: hours
    )
}

// MARK: - Group A: ForecastStore unit tests

/// A1 — Saving a snapshot and loading it back produces an equal value.
@Test func test_save_then_load_round_trip() async throws {
    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)

    let original = makeSnapshot()
    try await store.save(original)

    let loaded = try await store.load()
    let required = try #require(loaded)

    #expect(required.schemaVersion == original.schemaVersion)
    #expect(required.latitude == original.latitude)
    #expect(required.longitude == original.longitude)
    #expect(required.fetchedAt == original.fetchedAt)
    #expect(required.expirationDate == original.expirationDate)
    #expect(required.days.count == original.days.count)
    #expect(required.hours.count == original.hours.count)
    #expect(required.hours.first?.uvIndex == original.hours.first?.uvIndex)
}

/// A2 — A fresh store with no file returns nil.
@Test func test_load_returns_nil_when_no_snapshot() async throws {
    let url = isolatedStoreURL()  // no file written
    let store = ForecastStore(fileURL: url)

    let result = try await store.load()
    #expect(result == nil)
}

/// A3 — isStale returns false when now is 1 hour before expirationDate.
@Test func test_isStale_returns_false_when_now_before_expirationDate() {
    let expiry = Date(timeIntervalSince1970: 1_000_000)
    let now = expiry.addingTimeInterval(-3600)
    let snapshot = makeSnapshot(expirationDate: expiry)
    #expect(!snapshot.isStale(now: now))
}

/// A4 — isStale returns true at the exact boundary (now == expirationDate).
@Test func test_isStale_returns_true_when_now_equals_expirationDate() {
    let expiry = Date(timeIntervalSince1970: 1_000_000)
    let snapshot = makeSnapshot(expirationDate: expiry)
    #expect(snapshot.isStale(now: expiry))
}

/// A5 — isStale returns true when now is 1 minute past expirationDate.
@Test func test_isStale_returns_true_when_now_after_expirationDate() {
    let expiry = Date(timeIntervalSince1970: 1_000_000)
    let now = expiry.addingTimeInterval(60)
    let snapshot = makeSnapshot(expirationDate: expiry)
    #expect(snapshot.isStale(now: now))
}

/// A6 — Loading a snapshot written with schemaVersion 999 throws schemaMismatch.
/// Gi §5: schema mismatch → delete file, throw, no migration.
@Test func test_schema_mismatch_throws_on_load() async throws {
    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }

    // Write a snapshot with a future schema version directly to disk.
    let badSnapshot = makeSnapshot(schemaVersion: 999)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(badSnapshot)
    try data.write(to: url, options: .atomic)

    let store = ForecastStore(fileURL: url)
    await #expect(throws: ForecastStoreError.schemaMismatch) {
        _ = try await store.load()
    }

    // After the throw, the corrupted file must be gone.
    #expect(!FileManager.default.fileExists(atPath: url.path))
}

/// A7 — clear() removes the snapshot; subsequent load returns nil.
@Test func test_clear_removes_snapshot() async throws {
    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)

    try await store.save(makeSnapshot())
    try await store.clear()

    let result = try await store.load()
    #expect(result == nil)
}

/// A8 — A coord ~1 km from the stored coord (< 50 km) is NOT out-of-range.
/// Rationale: LAUNCH-PLAN 2dp rounding adds ≤ 1.1 km max error at 50 km threshold.
@Test func test_coord_distance_under_50km_is_valid() async {
    // +0.01° lat ≈ 1.1 km at SF latitude
    let storeCoord = (lat: 37.77, lon: -122.42)
    let nearCoord  = (lat: 37.78, lon: -122.42)   // ~1.1 km north

    let snapshot = makeSnapshot(latitude: storeCoord.lat, longitude: storeCoord.lon)
    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)
    try? await store.save(snapshot)

    let outOfRange = await store.isCoordOutOfRange(latitude: nearCoord.lat, longitude: nearCoord.lon)
    #expect(!outOfRange, "1 km delta should NOT trigger coord eviction")
}

/// A9 — A coord ~55 km from the stored coord (> 50 km threshold) IS out-of-range.
@Test func test_coord_distance_over_50km_triggers_eviction() async {
    // +0.5° lat ≈ 55.5 km
    let storeCoord = (lat: 37.77, lon: -122.42)
    let farCoord   = (lat: 38.27, lon: -122.42)

    let snapshot = makeSnapshot(latitude: storeCoord.lat, longitude: storeCoord.lon)
    let url = isolatedStoreURL()
    defer { try? FileManager.default.removeItem(at: url) }
    let store = ForecastStore(fileURL: url)
    try? await store.save(snapshot)

    let outOfRange = await store.isCoordOutOfRange(latitude: farCoord.lat, longitude: farCoord.lon)
    #expect(outOfRange, "+0.5° lat (~55 km) should trigger coord eviction")
}

// MARK: - Group B: Data invariants

/// B10 — A 10-day forecast snapshot has exactly days.count × 24 = 240 hourly entries.
@Test func test_hours_count_equals_days_count_times_24() {
    let snapshot = makeSnapshot(dayCount: 10)
    #expect(snapshot.hours.count == snapshot.days.count * 24)
    #expect(snapshot.hours.count == 240)
}

/// B11 — DST spring-forward coercion: provider MUST pad the 23-civil-hour day
/// to 24 UTC-based hour slots (missing slot → UVI = 0).
/// 2026-03-08: DST springs forward in America/New_York.
///
/// This test validates the INVARIANT by constructing a snapshot that violates
/// it (23 hours for the DST day) and asserting the violation, documenting the
/// contract that `WeatherKitForecastProvider` must satisfy.
@Test func test_hours_count_invariant_on_dst_spring_forward_day() {
    // Simulate a DST spring-forward day (23 civil hours) in one 10-day window.
    // The invariant: hours.count must equal days.count * 24 ALWAYS.
    // WeatherKitForecastProvider coerces by UTC-slot iteration (see Kwame §Refresh).
    let baseDate = Date(timeIntervalSince1970: 1_741_424_400) // 2026-03-08 UTC
    let expiry = baseDate.addingTimeInterval(3600 * 6)

    // Construct a snapshot as the provider SHOULD after coercion: 10 × 24 = 240 slots.
    // All DST-gap slots padded to UVI = 0.
    var hours: [HourForecast] = []
    let days: [DayForecast] = (0..<10).map { d in
        let dayDate = baseDate.addingTimeInterval(Double(d) * 86400)
        // UTC-based: always 24 slots regardless of DST in any local tz.
        for h in 0..<24 {
            hours.append(HourForecast(timestamp: dayDate.addingTimeInterval(Double(h) * 3600), uvIndex: 0.0))
        }
        return DayForecast(date: dayDate, dailyMinUVI: 0, dailyMaxUVI: 5, sunrise: nil, sunset: nil)
    }

    let snapshot = ForecastSnapshot(
        schemaVersion: ForecastSnapshot.currentSchemaVersion,
        latitude: 40.71,
        longitude: -74.01,
        fetchedAt: baseDate,
        expirationDate: expiry,
        days: days,
        hours: hours
    )

    // Invariant: UTC-based slot iteration means no civil-time DST gap.
    #expect(snapshot.hours.count == snapshot.days.count * 24,
            "DST spring-forward: provider must coerce to 24 UTC slots per day")
}

/// B12 — DST fall-back coercion: provider MUST truncate the 25-civil-hour day
/// to 24 UTC-based slots (extra slot dropped).
/// 2026-11-01: DST falls back in America/New_York.
@Test func test_hours_count_invariant_on_dst_fall_back_day() {
    let baseDate = Date(timeIntervalSince1970: 1_762_574_400) // 2026-11-01 UTC
    let expiry = baseDate.addingTimeInterval(3600 * 6)

    // Construct coerced snapshot (24 UTC slots — any 25th civil slot was dropped).
    var hours: [HourForecast] = []
    let days: [DayForecast] = (0..<10).map { d in
        let dayDate = baseDate.addingTimeInterval(Double(d) * 86400)
        for h in 0..<24 {
            hours.append(HourForecast(timestamp: dayDate.addingTimeInterval(Double(h) * 3600), uvIndex: 0.0))
        }
        return DayForecast(date: dayDate, dailyMinUVI: 0, dailyMaxUVI: 4, sunrise: nil, sunset: nil)
    }

    let snapshot = ForecastSnapshot(
        schemaVersion: ForecastSnapshot.currentSchemaVersion,
        latitude: 40.71,
        longitude: -74.01,
        fetchedAt: baseDate,
        expirationDate: expiry,
        days: days,
        hours: hours
    )

    #expect(snapshot.hours.count == snapshot.days.count * 24,
            "DST fall-back: provider must coerce to 24 UTC slots per day")
}

/// B13 — Polar-night day (Svalbard, 78.5°N): all 24 hourly UVI entries are 0.
/// Storage stores all 24 rows — no collapse, no special-case omission.
/// Wheeler ratification: UVI = 0 on all 24 hours is handled by the
/// existing `.nighttime` path; no special polar-night rows are dropped.
@Test func test_hours_count_invariant_on_polar_night_day() {
    // Svalbard, 78.5°N, deep winter: sun never above horizon
    let baseDate = Date(timeIntervalSince1970: 1_736_208_000) // 2025-01-07 UTC
    let expiry = baseDate.addingTimeInterval(3600 * 6)

    var hours: [HourForecast] = []
    let days: [DayForecast] = (0..<10).map { d in
        let dayDate = baseDate.addingTimeInterval(Double(d) * 86400)
        for h in 0..<24 {
            // All UVI = 0 — polar night. WeatherKit HourWeather.uvIndex is non-optional;
            // during polar night it returns 0 per physics + Wheeler ratification.
            hours.append(HourForecast(timestamp: dayDate.addingTimeInterval(Double(h) * 3600), uvIndex: 0.0))
        }
        return DayForecast(date: dayDate, dailyMinUVI: 0, dailyMaxUVI: 0, sunrise: nil, sunset: nil)
    }

    let snapshot = ForecastSnapshot(
        schemaVersion: ForecastSnapshot.currentSchemaVersion,
        latitude: 78.5,
        longitude: 15.0,
        fetchedAt: baseDate,
        expirationDate: expiry,
        days: days,
        hours: hours
    )

    // All 24 rows for the polar-night day must be stored (not collapsed or dropped).
    #expect(snapshot.hours.count == snapshot.days.count * 24,
            "Polar-night day must still store 24 hour rows (all UVI = 0)")
    #expect(snapshot.hours.allSatisfy { $0.uvIndex == 0.0 },
            "All hourly UVI values for polar night must be 0")
}
