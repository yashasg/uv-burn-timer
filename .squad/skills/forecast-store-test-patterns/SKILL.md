# Skill: Mocking WeatherKit Responses and Asserting on UVResult

**Author:** Ma-Ti (Test Engineer)  
**Date:** 2026-05-21T02:00:00Z  
**Context:** WI-7 — 10-day UV forecast  

---

## Problem

WeatherKit types (`Weather`, `DayWeather`, `HourWeather`, `WeatherMetadata`) are opaque framework types that cannot be instantiated in Swift Package Manager unit tests. Testing the forecast data pipeline requires a different approach.

## Pattern: Protocol abstraction + StaticForecastProvider

### 1. Define a protocol in UVBurnTimerCore (not the app target)

```swift
// ForecastProvider.swift
public protocol ForecastProviding: Sendable {
    func fetchForecast(at coordinate: UVCoordinate) async throws -> ForecastSnapshot
}
```

The production `WeatherKitForecastProvider` (app target) conforms to this. Tests supply a mock.

### 2. StaticForecastProvider for happy-path tests

```swift
private actor StaticForecastProvider: ForecastProviding {
    let snapshot: ForecastSnapshot
    private(set) var callCount = 0

    init(snapshot: ForecastSnapshot) { self.snapshot = snapshot }

    func fetchForecast(at coordinate: UVCoordinate) async throws -> ForecastSnapshot {
        callCount += 1
        return snapshot
    }
}
```

Note: must be an `actor` for Swift 6 strict-concurrency compliance.

### 3. FailingForecastProvider for error-path tests

```swift
private actor FailingForecastProvider: ForecastProviding {
    let error: Error
    init(error: Error = URLError(.notConnectedToInternet)) { self.error = error }
    func fetchForecast(at coordinate: UVCoordinate) async throws -> ForecastSnapshot {
        throw error
    }
}
```

### 4. ForecastStore testable init (inject file URL)

Add `internal init(fileURL:)` to `ForecastStore` alongside the public production `init()`:

```swift
internal init(fileURL: URL) {
    self.fileURL = fileURL
}
```

In tests, generate a UUID-named file in the Caches directory for isolation:

```swift
private func isolatedStoreURL() -> URL {
    FileManager.default
        .urls(for: .cachesDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("wi7-test-\(UUID().uuidString).json")
}

// In test:
let url = isolatedStoreURL()
defer { try? FileManager.default.removeItem(at: url) }
let store = ForecastStore(fileURL: url)
```

## Asserting on UVResult

`UVResult` must be `Equatable` for `#expect(result == .nighttime)` to work. Add conformance:

```swift
public enum UVResult: Equatable, Sendable { ... }
public enum UnavailableReason: String, Codable, Equatable, Sendable { ... }
```

Then:

```swift
// UVI > 0
#expect(result == .value(7.0))

// UVI == 0 (nighttime or polar night — same code path per Wheeler ratification)
#expect(result == .nighttime)

// Unavailable states
#expect(result == .unavailable(reason: .noSnapshot))
#expect(result == .unavailable(reason: .snapshotExpired))
#expect(result == .unavailable(reason: .coordOutOfRange))
```

Note: `UnavailableReason` has a `reason:` label in the associated value — always include it.

## Clock-independence for freshness tests

`ForecastStore.uvIndex(at:)` calls `snapshot.isStale()` using `Date()` (system clock). Use `Date.distantFuture` as `expirationDate` in fresh-snapshot helpers:

```swift
private func makeFreshSnapshot(...) -> ForecastSnapshot {
    // ...
    expirationDate: Date.distantFuture  // clock-independent freshness
}
```

For stale tests, use a past epoch:
```swift
expirationDate: Date(timeIntervalSince1970: 0)  // always stale
```

For staleness boundary tests (A3/A4/A5), test `snapshot.isStale(now:)` directly (it has an injectable `now:` parameter).

## Key gotcha: `inMemorySnapshot` lifecycle

`ForecastStore.uvIndex(at:)` uses `inMemorySnapshot`, which is populated by `save()` and `load()`. In tests:
- After `save()`: `inMemorySnapshot` is populated — `uvIndex(at:)` works
- Fresh store (no `save()`): `inMemorySnapshot` is nil — `uvIndex(at:)` returns `.unavailable(.noSnapshot)`
- After `load()`: `inMemorySnapshot` is populated only if file exists and passes invariants
