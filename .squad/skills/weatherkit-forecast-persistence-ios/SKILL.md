# Skill: WeatherKit Forecast Persistence on iOS

**Domain:** iOS / Swift / WeatherKit  
**Applicable when:** You need to cache WeatherKit `DayWeather` + `HourWeather` arrays locally on iOS for offline access and planning features, without SwiftData (iOS 16 minimum).

---

## Pattern Summary

Store the entire forecast response as a single Codable JSON file in the app's Caches directory. Wrap all I/O in a Swift actor. Refresh on `scenePhase == .active` with a staleness gate (e.g., 6 hours). Invalidate on location change (coord delta), schema mismatch, or explicit user clear.

---

## Core Types

```swift
// ForecastModels.swift — in Core module (UVBurnTimerCore or equivalent)

struct ForecastSnapshot: Codable, Sendable {
    let schemaVersion: Int          // bump when struct shape changes
    let fetchedAt: Date
    let roundedCoordinate: UVCoordinate
    let dailyForecasts: [DailyForecastEntry]    // ≤ 10 entries
    let hourlyForecasts: [HourlyForecastEntry]  // ≤ 240 entries
}

struct DailyForecastEntry: Codable, Sendable {
    let date: Date
    let peakUVIndex: Double
    let conditionSymbol: String     // SF Symbol name
    let sunrise: Date?
    let sunset: Date?
}

struct HourlyForecastEntry: Codable, Sendable {
    let date: Date                  // truncated to hour
    let uvIndex: Double
    let conditionSymbol: String
}

protocol ForecastStoring: Sendable {
    func load() async throws -> ForecastSnapshot?
    func save(_ snapshot: ForecastSnapshot) async throws
    func clear() async throws
}
```

## Storage Actor

```swift
// ForecastStore.swift

actor ForecastStore: ForecastStoring {
    private let fileURL: URL = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("forecast-snapshot.json")
    }()
    private let currentSchemaVersion = 1

    func load() async throws -> ForecastSnapshot? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        let snapshot = try JSONDecoder().decode(ForecastSnapshot.self, from: data)
        guard snapshot.schemaVersion == currentSchemaVersion else {
            try? FileManager.default.removeItem(at: fileURL)
            return nil
        }
        return snapshot
    }

    func save(_ snapshot: ForecastSnapshot) async throws {
        let data = try JSONEncoder().encode(snapshot)
        try data.write(to: fileURL, options: .atomic)   // atomic = write-rename, no partial writes
    }

    func clear() async throws {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
```

## WeatherKit Fetch (one round-trip)

```swift
// WeatherLocationServices.swift — app target

struct WeatherKitForecastProvider: Sendable {
    func fetchSnapshot(at coordinate: UVCoordinate) async throws -> ForecastSnapshot {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let (daily, hourly) = try await WeatherService.shared.weather(
            for: location,
            including: .daily, .hourly
        )
        return ForecastSnapshot(
            schemaVersion: 1,
            fetchedAt: Date(),
            roundedCoordinate: coordinate,
            dailyForecasts: daily.forecast.map { DailyForecastEntry(from: $0) },
            hourlyForecasts: hourly.forecast.map { HourlyForecastEntry(from: $0) }
        )
    }
}
```

## Refresh Gate (in RootView or ViewModel)

```swift
// In the scenePhase .active observer — AppViews.swift or ForecastViewModel

private func refreshForecastIfNeeded() async {
    let staleness: TimeInterval = 6 * 3600
    guard let snapshot = try? await forecastStore.load() else {
        await performForecastRefresh(); return
    }
    // Invalidate on staleness
    if Date().timeIntervalSince(snapshot.fetchedAt) > staleness {
        await performForecastRefresh(); return
    }
    // Invalidate on coord move (>0.1° ≈ 10 km)
    if let current = currentRoundedCoordinate,
       abs(current.latitude - snapshot.roundedCoordinate.latitude) > 0.1
       || abs(current.longitude - snapshot.roundedCoordinate.longitude) > 0.1 {
        await performForecastRefresh(); return
    }
}
```

## Picker Lookup (O(1))

```swift
extension ForecastSnapshot {
    func hourlyEntry(at date: Date) -> HourlyForecastEntry? {
        let target = Calendar.current.startOfHour(for: date)
        return hourlyForecasts.first { Calendar.current.startOfHour(for: $0.date) == target }
    }
}
```

---

## Key Rules

1. **Never re-fetch synchronously on picker interaction.** Serve stale-but-present data; refresh async.
2. **`ForecastStore` never calls WeatherKit.** It is a pure storage actor. Caller fetches and deposits.
3. **Caches directory = no guarantee.** Always handle `load()` returning nil gracefully.
4. **Single round-trip:** `weather(for:including: .daily, .hourly)` fetches both in one call.
5. **Schema version:** Bump `currentSchemaVersion` whenever `ForecastSnapshot` shape changes. Mismatch → delete + re-fetch silently.
6. **`options: .atomic` on `Data.write`:** Prevents half-written file on crash/kill.
7. **No BGAppRefreshTask for v1** — planning feature, not safety feature. Add in v1.1 if engagement warrants.

---

## Size / Performance Reference

| Component | Entries | ~Size |
|-----------|---------|-------|
| DailyForecastEntry | 10 | ~1.5 KB |
| HourlyForecastEntry | 240 | ~19 KB |
| Header | 1 | ~80 B |
| **Total JSON** | | **~21 KB** |

~7 KB on-disk with APFS compression. Negligible vs. Caches eviction thresholds (~1–2 GB).

---

## Project context

First applied: UV Burn Timer app, WI-7 (10-day UVI forecast + burn-time picker), 2026-05-20.  
Reference decision doc: `.squad/decisions/inbox/kwame-forecast-storage-mechanism.md`
