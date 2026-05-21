# Forecast Data Lifecycle — Schema, Retention, Eviction, Multi-Location

**Author:** Gi (Data Specialist)  
**Date:** 2026-05-20T18:06:16-07:00  
**Work item:** WI-7 (10-day UVI forecast feature — fully locked as of 2026-05-21T01:06:30Z)  
**Addressee:** Kwame (mechanism owner), Iris (cold-start UX contract), team for visibility  
**Status:** Proposed — open questions for Kwame flagged in §9

---

## 1. Data Shape — Minimum Useful Set

### Normalized structure: `ForecastSnapshot`

One wrapper, two arrays. No denormalization.

```swift
struct ForecastSnapshot: Codable {
    let schemaVersion: Int          // current: 1
    let latitude: Double            // 2dp per LAUNCH-PLAN coords policy
    let longitude: Double           // 2dp
    let fetchedAt: Date             // UTC

    let days: [DayForecast]         // 10 items
    let hours: [HourForecast]       // 168 items (7d × 24h)
}
```

### `DayForecast` — 10 rows

| Field | Type | Rationale |
|---|---|---|
| `date` | `Date` | Start-of-day in device locale |
| `peakUVI` | `Double` | **All 10 days** — display gated to days 1–5, but days 6–7 still needed for picker burn-window computation |
| `peakUVIHour` | `Int` | 0–23; hourly card can auto-scroll to peak; picker can default to peak hour for a given day |
| `whoCategory` | `WHOTier` | Derived from `peakUVI` at fetch time, stored as enum; avoids re-derivation on render |
| `sunrise` | `Date` | UTC absolute; used for "nighttime" guard in picker |
| `sunset` | `Date` | UTC absolute; paired with sunrise |

**What is NOT stored in `DayForecast`:**
- Personalized burn window — derived at render time from `skin type × SPF × peakUVI`. Skin type and SPF are `@State`-only per LAUNCH-PLAN §9 (Donatello M7). Cannot cache them; must not cache their product either.
- Day-level condition / cloud cover — not needed for any display surface in WI-7 spec.

### `HourForecast` — 168 rows (7 × 24)

| Field | Type | Rationale |
|---|---|---|
| `timestamp` | `Date` | UTC absolute |
| `uvIndex` | `Double` | Raw WeatherKit value |
| `condition` | `String?` | Optional; if Kwame wants an accurate SF symbol beyond UVI-tier derivation |

**Why 168 not 240 (10 × 24)?**  
The picker window is `Date.now ... Date.now + 7 days` (hard cap per 2026-05-21T01:06:16Z directive, Wheeler's skill horizon). Hours for days 8–10 are not reachable by the picker and the forecast card for those days shows `WHOTier` only (already in `DayForecast`). Storing 72 extra hours wastes space and increases cache write time with no consumer.

### Normalization rationale

Two flat arrays are sufficient. Do NOT denormalize hours into `DayForecast.hours`. A flat `[HourForecast]` is O(1) indexed by filtering `timestamp` in `[dayStart, dayStart+24h)` — trivial for 168 items. Denormalization would duplicate metadata (date, tier) and complicate the Codable schema for no lookup benefit.

---

## 2. Retention Horizon

**Single snapshot. No historical archive.**

| Data | Keep? | Why |
|---|---|---|
| Current 10-day forward forecast | ✅ Yes — one snapshot | This is the entire app value |
| Past-day forecast rows (rolled out of window) | ❌ Discard on next refresh | No persona JTBD for "was Tuesday's forecast accurate?" |
| Historical forecast snapshots (multi-day archive) | ❌ Never | Not a weather accuracy app; no trend analysis surface planned |

**Persona check:**
- Devon (PCT hiker): Wants "next 7 days at my current camp" — forward-only.
- Priya (parent): Wants "this weekend's forecast" — forward-only.
- Vee (albinism/vitiligo): Wants "next 10 days to avoid" — forward-only.
- None of Suchi's six personas have a "look back at old forecasts" JTBD.

**Retention horizon: 10 days forward (DayForecast) + 7 days hourly (HourForecast). Zero historical retention.**

---

## 3. Eviction Triggers

Ordered by priority (highest = most disruptive, runs first):

### Trigger 1 — Schema version bump (on open)
```
stored.schemaVersion != ForecastSnapshot.currentSchemaVersion
  → delete snapshot → fetch on open
```
No migration. Re-fetchable weather data does not warrant migration logic. One extra WeatherKit call on first post-upgrade open is the correct trade-off.

### Trigger 2 — Coordinate delta (on foreground, before staleness check)
```
CLLocation(cached).distance(from: CLLocation(current)) > 50_000  // 50 km
  → discard snapshot immediately → fetch new coords
```
50 km rationale: NWP model spatial resolution. Devon covering a 30 km day-hike section will NOT trigger eviction mid-day — good. Flying LAX→JFK (~3,800 km) WILL trigger it — correct.

Note: the 2dp rounding on stored coords adds ~1.1 km max error. At a 50 km threshold this is noise.

### Trigger 3 — Time-based stale (on foreground)
```
Date() - snapshot.fetchedAt > 3600  // 1 hour
  → mark stale → trigger background refresh
  → show existing snapshot with "Cached at [time]" disclosure until fresh data arrives
```
1 hour rationale: WeatherKit operational update cadence is 1–6 hours. The diurnal UVI curve changes meaningfully near solar noon. Users outdoors opening the app mid-day need current UV data, not a 3-hour-old reading.

**Stale data is NOT discarded — it is shown with disclosure (see §7).** Discard only on coord change or schema bump.

### Trigger 4 — Manual pull-to-refresh
Existing behavior (`RootView.refreshable { await refreshUV() }`, WI-47 XCUI-covered). Extends to forecast refresh. Triggers immediate re-fetch regardless of fetchedAt.

### Trigger 5 — OS Caches pressure
If stored in `Caches/` directory (recommended — see §9 open question), iOS can evict freely. App handles this as a cold-start / `snapshot == nil` path. No explicit trigger needed.

---

## 4. Multi-Location Strategy

**One active snapshot per install. Overwrite on coord change. No ring buffer.**

### Why not a ring buffer?

A ring buffer of 2–3 recent locations (e.g., LAX + JFK for Devon's flight) would require:
- Geocoding location names (new API dependency)
- A "current location" picker UI (complexity Iris hasn't specced)
- 2–3× storage cost
- Logic to determine which snapshot to serve to the picker

None of Suchi's personas need a comparison across locations simultaneously:
- **Devon (PCT):** At one camp at a time. When he moves >50 km, his new camp is all he cares about.
- **Priya (parent):** At the beach OR at home. Not comparing them.
- **Vee (albinism/vitiligo):** Single-location daily planner.

**Policy:** On coord delta > 50 km, discard old snapshot, fetch new location. Old location data is intentionally gone. This matches user mental model: "I'm at a new place, show me new data."

**Edge case — flight with app open:** If user opens app mid-flight (airplane mode, no network), old snapshot persists (coord change triggers eviction attempt, network unavailable). App shows cold-start error state: "Unable to fetch forecast for new location. No internet connection." Old location data is not shown — showing LAX forecast to a user in JFK airspace is misleading, not helpful.

---

## 5. Schema Versioning

**Integer `schemaVersion` field in `ForecastSnapshot`. Current: 1.**

```swift
struct ForecastSnapshot: Codable {
    static let currentSchemaVersion = 1
    let schemaVersion: Int
    // ...
}
```

**On decode:**
```swift
let cached = try JSONDecoder().decode(ForecastSnapshot.self, from: data)
guard cached.schemaVersion == ForecastSnapshot.currentSchemaVersion else {
    // Delete file, return nil, trigger fetch
    try? FileManager.default.removeItem(at: cacheURL)
    return nil
}
```

**Also handle decode failure** (malformed file, truncated write) the same way: delete and return nil.

**Why no migration?** The snapshot is always re-fetchable from WeatherKit. Writing a migration path introduces more risk (partial migration, wrong values) than the cost of one extra WeatherKit call. This is weather cache, not user documents.

**When to bump `schemaVersion`:**
- Adding a field with no safe default (e.g., a new required `Bool` that changes picker behavior)
- Changing the type of an existing field
- Removing a field that downstream code still expects

**When NOT to bump:**
- Adding an optional field with a nil default (backwards-compatible Codable)

---

## 6. Cold-Start UX Contract

**First-ever launch or post-eviction open: `snapshot == nil`.**

### `ForecastStore` state machine

```swift
enum ForecastLoadingState {
    case idle
    case loading
    case loaded(ForecastSnapshot)
    case failed(ForecastError)
}
```

### Contract for Iris and Kwame

| `ForecastLoadingState` | Hourly card | 10-day card | "View UV Forecast" chip | Picker |
|---|---|---|---|---|
| `.idle` | — | — | Hidden or disabled | Inaccessible |
| `.loading` | Skeleton loaders | Skeleton loaders (10 rows) | Disabled: "Forecast loading…" | Inaccessible |
| `.loaded(_)` | Renders | Renders | Enabled | Accessible |
| `.failed(_)` | Error state | Error state | Enabled (retry) | "Forecast unavailable" — Done disabled |

**Skeleton loaders, not empty cards.** Empty cards create an impression of "no data" (which may be correct, but is confusing without animation). Skeleton rows signal "data is coming." This is the Apple Weather / Apple Maps pattern.

**The "View UV Forecast" chip must not be tappable in `.idle` or `.loading`.** Opening the sheet and showing empty content before the first fetch would result in a jarring snap-in. Disable (gray, `accessibilityLabel: "Forecast loading"`) until `.loaded`.

**Transition timing:** `ForecastStore` emits `.loading` synchronously on `fetchForecast()` call. Iris can rely on this being immediate — no flash of `.idle` followed by `.loading`.

---

## 7. Offline / No-Network Behavior

**Show stale data with prominent disclosure. Do not refuse to render.**

### Rationale

Devon is on a ridge. He opened the app to check if tomorrow's planned exposed section is worth it. He has no cell signal. His 36-hour-old cached forecast is the only UV planning data he has anywhere. Refusing to display it does not protect him — it just makes the app useless at exactly the moment he needs it.

### Disclosure requirements

A non-dismissable banner at the top of the forecast sheet:
```
⚠️ Forecast last updated [time, local]. 
Connect to internet for latest data.
```

- `[time, local]` = `snapshot.fetchedAt` formatted as "2:30 PM yesterday" or "May 18 at 9 AM" — human-readable, not ISO-8601.
- Banner persists until a successful refresh completes.
- VoiceOver: announcement on sheet open ("Forecast data is from [time]. Connect to internet for latest.").

### Picker behavior with stale cache

Picker remains functional. Result label changes:
```
"Estimated burn time (forecast from [time])"
```

The picker result is not wrong — it's computed from the best available data. Disclosing the data age is the correct response, not blocking the computation.

### True no-cache + no-network

```
snapshot == nil AND network unavailable
```

→ Show forecast sheet error state: "Unable to load forecast. Check your internet connection." Retry button. No skeleton loaders (nothing is loading).

---

## 8. Picker Data Integrity Guarantee

**The contract `ForecastStore.uvIndex(at: Date)` must satisfy:**

```swift
enum UVResult {
    case value(Double)                          // UVI found for this (date, hour)
    case nighttime                              // UVI is 0; "No UV at this hour"
    case unavailable(reason: UVUnavailableReason)
}

enum UVUnavailableReason {
    case outsideWindow                          // date not in [now, now+7d]
    case cacheStale(fetchedAt: Date)            // stale cache, network failed
    case noCache                                // no snapshot at all
}
```

### Guarantees

1. For any `date` in `[now, now+7d]` with a fresh cache: returns `.value(uvi)` or `.nighttime`. Never `.unavailable`.
2. For any `date` in `[now, now+7d]` with stale cache and network failure: returns `.unavailable(.cacheStale(fetchedAt:))`. **Kwame's picker sheet should render the stale value with disclosure** (same as §7 policy) rather than showing "unavailable" — but the store's contract is correctly named so Kwame can make that call at the presentation layer.
3. For any `date` outside `[now, now+7d]`: returns `.unavailable(.outsideWindow)`. This should be unreachable if Iris's `DatePicker` range is enforced, but the store must be robust against clock drift and edge cases.
4. **No silent `nil` return.** Every state is named. Iris's "Forecast unavailable for this time" copy is driven by `.unavailable(.noCache)`. The stale-cache case gets its own disclosure path per §7.

### Boundary clamping (per WI-7 spec)

> "Picker boundary clamps to last WeatherKit `DayWeather` entry if WeatherKit returns < 7 days."

If WeatherKit returns only 6 days of `DayWeather`, the picker upper bound should be `min(Date.now + 7d, lastDayForecast.date + 24h)`. The store exposes `var pickerUpperBound: Date` so Iris's `DatePicker` range is always `Date.now ... store.pickerUpperBound`.

---

## 9. Recommendation + Open Questions for Kwame

### Recommended policy (summary)

| Dimension | Decision |
|---|---|
| **Storage format** | Single `ForecastSnapshot` JSON file |
| **Storage location** | `Caches/` directory (OS-evictable, no personal data) |
| **Schema** | `[DayForecast]` × 10 + `[HourForecast]` × 168, wrapped with coords + fetchedAt + schemaVersion |
| **Skin type / SPF** | NOT stored (LAUNCH-PLAN @State-only rule) |
| **Retention** | One snapshot, no historical archive |
| **Stale threshold** | 1 hour on foreground |
| **Coord eviction** | > 50 km delta → discard + re-fetch |
| **Schema bump** | Throw and re-fetch, no migration |
| **Offline** | Show stale data with fetchedAt disclosure |
| **Multi-location** | One snapshot, overwrite on coord change |
| **Schema version** | Integer field, current = 1 |

### Open questions for Kwame

**Q1 — Storage tier: `Caches/` vs `Application Support/`?**  
I recommend `Caches/` — weather data is re-fetchable, no personal data, OS eviction is acceptable. If Kwame determines the UX cost of OS eviction is too high (e.g., blank screen on foreground after storage pressure on a Devon-style always-outdoor session), `Application Support/` is the alternative with manual cleanup on coord-eviction and schema-version-bump paths.

**Q2 — Refresh trigger: foreground-only or BGAppRefreshTask?**  
Foreground-only is simpler and fits our zero-third-party-SDK posture. `BGAppRefreshTask` would pre-populate the cache so Devon always sees fresh data on open. Background refresh requires `UIBackgroundModes: fetch` entitlement and a BGTaskScheduler registration — not complex, but a deliberate scope call. My policy works either way; Kwame decides.

**Q3 — Actor model: `@MainActor` observable or `actor`?**  
`ForecastStore` should be one or the other — not a `class` with manual thread hops. Recommend `@Observable @MainActor ForecastStore` for simplicity given the small data set. If Kwame wants the decode/file IO off the main thread, an `actor` with `MainActor.run {}` for state publication is correct.

**Q4 — SwiftData vs JSON file?**  
178 rows (10 + 168) is simple enough for either. A JSON file with `JSONEncoder/JSONDecoder` is transparent, debuggable (cat the file in Simulator), and needs no schema migration tooling. SwiftData adds overhead and its migration story for throws-and-re-fetches is less obvious than "delete file." My recommendation: JSON file. But if Kwame already has SwiftData scaffolding from the main app, consistency may outweigh simplicity.

**Q5 — Coordinate delta: `CLLocation.distance(from:)` vs stored-coord comparison?**  
The stored coords are 2dp-rounded per LAUNCH-PLAN policy. `CLLocation` from 2dp coords has ~1.1 km max rounding error. At a 50 km threshold this is noise — safe to compare against. Kwame can use `CLLocation(latitude: snapshot.latitude, longitude: snapshot.longitude).distance(from: currentCLLocation) > 50_000`.

---

*This decision document covers data policy only. Mechanism (SwiftData/JSON, actor model, BGRefresh) is Kwame's domain.*
