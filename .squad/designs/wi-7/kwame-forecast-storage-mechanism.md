# iOS Forecast Storage Mechanism — Kwame Proposal

**Date:** 2026-05-20T18:06:16-07:00
**Author:** Kwame (iOS Developer)
**Status:** Proposed — awaiting Gi lifecycle policy coordination
**Work item:** WI-7 (10-day UVI forecast + burn-time picker)

---

## Decision

**Recommended mechanism: Option B — single-file JSON cache in the app's Caches directory.**

File path:
```swift
FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("forecast-snapshot.json")
```

Root type written to disk:
```swift
struct ForecastSnapshot: Codable, Sendable {
    let schemaVersion: Int          // = 1; mismatch → discard
    let fetchedAt: Date
    let roundedCoordinate: UVCoordinate
    let dailyForecasts: [DailyForecastEntry]    // 10 entries
    let hourlyForecasts: [HourlyForecastEntry]  // ≤ 240 entries
}

struct DailyForecastEntry: Codable, Sendable {
    let date: Date
    let peakUVIndex: Double
    let conditionSymbol: String     // SF Symbol name from WeatherCondition
    let sunrise: Date?
    let sunset: Date?
}

struct HourlyForecastEntry: Codable, Sendable {
    let date: Date                  // truncated to the hour
    let uvIndex: Double
    let conditionSymbol: String
}
```

Actor:
```swift
actor ForecastStore: ForecastStoring {
    // Owns all disk I/O. No DispatchQueue. Strict Concurrency clean.
    func load() async throws -> ForecastSnapshot?
    func save(_ snapshot: ForecastSnapshot) async throws
    func clear() async throws
    // O(1) lookup for picker
    func hourlyUVIndex(at date: Date, in snapshot: ForecastSnapshot) -> Double?
}
```

---

## Rationale for Option B over alternatives

| Option | Verdict | Reason |
|--------|---------|--------|
| A — In-memory only | Rejected | Every cold launch re-fetches WeatherKit. Picker sheet opens to "unavailable" until network resolves. Unacceptable for the planning-mode JTBD (Devon, Vee, Priya). |
| B — Single-file JSON in Caches | **RECOMMENDED** | OS-evictable (free cleanup under disk pressure). No schema migration infrastructure. Atomic overwrite. iOS 16-compatible (no SwiftData). ~20 KB is negligible. Decode failure → treat as absent, re-fetch silently. |
| C — SwiftData | Rejected | iOS 17 minimum. WI-7 targets iOS 16+. Schema migration story for 1 file is over-engineered. |
| D — UserDefaults JSON blob | Rejected | UserDefaults is not intended for multi-KB structured data. No OS-managed eviction. Pollutes the existing scalar preference namespace. |

---

## Current state (what's already persisted)

Audited from `app/Sources/UVBurnTimer/AppViews.swift` lines 17–23 and `UVBurnTimerCore/UVWorkflow.swift`:

| Data | Mechanism | Notes |
|------|-----------|-------|
| Skin type | `@AppStorage("selectedSkinType")` → UserDefaults integer | Persisted since 2026-05-19 build; LAUNCH-PLAN @State-only rule superseded by shipped decision |
| SPF level | `@AppStorage("selectedSPF")` → UserDefaults integer | Same |
| Last rounded coordinate | `@AppStorage("lastRoundedCoordinate")` → UserDefaults JSON string (`CachedRoundedCoordinate`) | 2dp-rounded lat/lng only, no UVI |
| Location rationale acknowledged | `@AppStorage("locationRationaleAcknowledged")` → UserDefaults bool | |
| Current UV snapshot (UVI + fetchedAt) | `@State` — in-memory only | **NOT persisted to disk.** Lives only as long as the view tree. `legacyCachedUVSnapshotStorage` is a cleared tombstone, not active. |
| Forecast data (daily + hourly) | **NOTHING TODAY** | This is the gap WI-7 must fill. |

Data flow for current-day UVI:
1. `RootView.refreshUV()` (AppViews.swift:334) → `DeviceLocationProvider.currentCoordinate()` (WeatherLocationServices.swift:28) → rounds to 2dp
2. → `UVBurnTimerWorkflow.fetchEstimate()` (UVWorkflow.swift:132) → `WeatherKitUVDataProvider.currentUVIndex()` (WeatherLocationServices.swift:99–113)
3. → `WeatherService.shared.weather(for: location)` — fetches `.currentWeather.uvIndex.value` ONLY. **No daily/hourly forecast is fetched today.**
4. Returns `UVSnapshot(uvIndex:fetchedAt:roundedCoordinate:)` stored as `@State` in RootView.

---

## WeatherKit native caching behavior

WeatherKit (`WeatherService.shared.weather(for:)`) does perform internal HTTP-level caching via NSURLSession's URL cache (standard iOS URL caching semantics). In practice:

- **Deduplication:** Requests for the same location within a short window (minutes) will typically return a cached HTTP response. This is OS-managed and not controllable by the app.
- **Offline behavior:** WeatherKit does **not** serve a local offline store. If the network is unavailable and the HTTP cache has expired, the call throws. There is no "serve stale data" fallback baked into the framework. This is exactly why we need our own Caches-directory layer for the planning feature.
- **Rate/cost model:** WeatherKit REST API free tier is 500,000 calls/month per app. `WeatherService.shared` uses the on-device framework path (JWT signed by the OS, not the REST endpoint), which counts against the same App Store Connect quota. For our scale (indie app), 500K/month is essentially infinite — but we should not over-fetch. "Once per active foreground session, if cache >6h old" is the right discipline.
- **10-day availability:** `WeatherService.shared.weather(for:including: .daily)` returns up to 10 `DayWeather` entries. `.hourly` returns up to 240 `HourWeather` entries (10 days × 24). These are available in one round-trip call via the variadic `weather(for:including:)` API.

Source: Apple Developer Documentation — WeatherKit > WeatherService, WWDC23 "Explore enhancements to WeatherKit" (session 10149).

---

## Storage size estimate

| Component | Entries | Bytes/entry | Subtotal |
|-----------|---------|-------------|----------|
| `DailyForecastEntry` (date, UVI, symbol, sunrise, sunset) | 10 | ~150 B | ~1.5 KB |
| `HourlyForecastEntry` (date, UVI, symbol) | 240 | ~80 B | ~19 KB |
| `ForecastSnapshot` header (fetchedAt, coord, schema version) | 1 | ~80 B | ~80 B |
| **Total uncompressed JSON** | | | **~21 KB** |

APFS compression: JSON with repeated string keys compresses ~3:1 → **~7 KB on disk**.

The Caches directory eviction threshold on iOS starts around 1–2 GB of disk pressure. 21 KB is 0.001% of that threshold. No pagination, no chunking, no size concern.

---

## Refresh strategy

**Trigger:** `scenePhase == .active` observer — already wired in `AppViews.swift` lines 110–128. Extend this observer to call `refreshForecastIfNeeded()` alongside the existing reattestation check.

**Staleness threshold:** 6 hours. Rationale: "once per day" is the intent; 6h allows a midday refresh on heavy users without over-fetching. Formula: `Date().timeIntervalSince(snapshot.fetchedAt) > 6 * 3600`.

**Trigger sequence:**
1. `scenePhase → .active`
2. Check `ForecastStore.load()` — if nil OR `fetchedAt` older than 6h → trigger async `refreshForecast()`
3. `refreshForecast()` calls `WeatherService.shared.weather(for: location, including: .daily, .hourly)` in one network round-trip
4. On success: `ForecastStore.save(snapshot)` → overwrite file
5. On network failure: keep stale snapshot, surface "Last updated X hours ago" caption on forecast card

**Background refresh (BGAppRefreshTask):** NOT for v1. The forecast is a planning feature, not a safety feature. Background refresh adds entitlement complexity, battery budget scrutiny, and App Store review questions we don't need for v1. Revisit in v1.1 if daily-planner personas (Vee, Priya) show strong engagement.

**WeatherKit call batching:** Fetch `.daily` and `.hourly` in a single `weather(for:including:)` call — one round-trip for both the 10-day card and the hourly "today" card. Do not make two separate calls.

---

## Concurrency / thread safety

`ForecastStore` is a Swift actor. All disk I/O is isolated to the actor. No `DispatchQueue`. No `DispatchQueue.main.async`. Strict Concurrency compliant.

```swift
// In RootView (already @MainActor):
@State private var forecastStore = ForecastStore()

// In refreshForecast():
let snapshot = try await weatherService.fetchForecastSnapshot(at: roundedCoordinate)
try await forecastStore.save(snapshot)
```

`ForecastStore` never calls `WeatherService`. It is a pure storage actor. WeatherKit call stays in RootView (or a new `ForecastViewModel @MainActor`), passed in as a value after resolution. This keeps the actor testable with `StaticForecastStore` (equivalent of the existing `StaticUVDataProvider`).

---

## Picker data dependency

The "Plan for another time" picker (`DatePicker`, range `Date.now...Date.now + 7*24*3600`) needs `uvIndex` for arbitrary (date, hour) within the window.

**Lookup API:**
```swift
extension ForecastStore {
    // O(1): truncate date to hour, binary search hourlyForecasts by date
    func hourlyEntry(at date: Date, in snapshot: ForecastSnapshot) -> HourlyForecastEntry?
}
```

**Picker behavior contract:**
1. On picker date change → `ForecastStore.hourlyEntry(at:in:)` — synchronous O(1) lookup in the in-memory snapshot (already loaded on scene activation)
2. **Never re-fetches synchronously on picker interaction.** If the cache is absent or stale, surface "Forecast unavailable for this time" + retry button (WI-7 edge case — locked in spec)
3. Background refresh happens concurrently; picker updates reactively via `@Observable` / `@StateObject` binding when new data arrives

The picker view-model holds a reference to the loaded `ForecastSnapshot` — it does not go actor-hop on every knob turn. Snapshot is loaded once on sheet open, held as `@State var loadedSnapshot: ForecastSnapshot?`.

---

## Cleanup / eviction

| Trigger | Action | Who decides |
|---------|--------|-------------|
| Disk pressure (iOS) | OS evicts Caches directory automatically | Free — we do nothing |
| Stale > 6h + scene active | Re-fetch and overwrite | Kwame (hardcoded staleness gate) |
| Coord moved > ~0.1° at 2dp | Discard stored snapshot, re-fetch | **Open question for Gi** — what's the distance threshold that triggers invalidation? |
| App version upgrade (schema mismatch) | `schemaVersion` field mismatch → discard + re-fetch | Kwame (version field in `ForecastSnapshot`) |
| User clears saved location (existing flow) | Forecast snapshot should also be cleared | **Open question for Gi** — is forecast data logically tied to the coord cache, or independent? |
| App uninstall | Caches directory deleted by OS | Free |
| Time horizon expires (entries become past) | No eviction needed — re-fetch on next scene activation serves fresh future data | N/A |

---

## Open questions for Gi (lifecycle policy)

1. **Retention horizon:** Should we discard forecast data for days that have already passed within the stored snapshot (e.g., 3 of the 10 days are now yesterday)? Or is a 6h-since-fetch staleness gate sufficient regardless of how many days are "past"?

2. **Coord invalidation distance:** When the user moves, what delta triggers "discard old snapshot and re-fetch"? My proposed rule: if stored `roundedCoordinate` differs from current by > 0.1° in lat OR lng (roughly 10 km), treat as new location. Does Gi's lifecycle policy want a tighter or looser bound?

3. **Explicit clear on location wipe:** The existing "Clear saved location" button in SettingsSheet (AppViews.swift:495–496) clears `cachedRoundedCoordinateStorage`. Should it also clear the forecast snapshot? I say yes — the forecast is keyed to a location; clearing location should clear forecast. Gi to confirm.

4. **Schema versioning approach:** My proposal: `schemaVersion: Int` field in `ForecastSnapshot`, default = 1. On decode failure OR version mismatch → silently delete file + re-fetch. Gi to confirm this is acceptable from an eviction-policy standpoint (i.e., "user opened app after upgrade and sees a blank forecast briefly while re-fetch completes").

5. **Multiple-location scenario (future):** WI-7 is single-location (current device location). If WI-9 (plan for elsewhere) ever lands, the Caches-directory approach would need a keyed file per coordinate pair. Does Gi want to pre-spec a keyed store now, or keep it single-file for v1 and migrate later?

---

## Files to create / modify

| File | Change |
|------|--------|
| `app/Sources/UVBurnTimerCore/ForecastModels.swift` | New: `ForecastSnapshot`, `DailyForecastEntry`, `HourlyForecastEntry`, `ForecastStoring` protocol |
| `app/Sources/UVBurnTimerCore/ForecastStore.swift` | New: `actor ForecastStore: ForecastStoring` |
| `app/Sources/UVBurnTimer/WeatherLocationServices.swift` | Add `WeatherKitForecastProvider` struct that calls `weather(for:including: .daily, .hourly)` |
| `app/Sources/UVBurnTimer/AppViews.swift` | Wire `ForecastStore` into `RootView`, extend `scenePhase .active` observer, add `refreshForecastIfNeeded()` |
| `app/Tests/UVBurnTimerTests/ForecastStoreTests.swift` | New: round-trip encode/decode, staleness gate, coord-moved invalidation, schema-version mismatch |
