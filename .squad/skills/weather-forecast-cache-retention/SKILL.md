# SKILL: Weather Forecast Cache Retention Policy

**Category:** Data / Caching  
**Applies to:** Any mobile app that caches re-fetchable weather/environmental forecast data  
**First extracted:** 2026-05-20T18:06:16-07:00 (UV Burn Timer, WI-7)

---

## Problem

A mobile app fetches time-series forecast data (e.g., UV index, temperature, AQI) from a third-party API (e.g., WeatherKit, OpenWeatherMap) that:
- Has a natural forward window (e.g., 10 days)
- Decays in forecast skill over time (past ~72 h for UV, ~5 days for precipitation)
- Contains no user-personal data (re-fetchable freely)
- Is consumed by both a display surface (cards) and a computation surface (a picker or calculator)

The app must decide: what to store, how long, when to evict, and how to behave offline.

---

## Pattern

### 1. Single-snapshot architecture

Keep ONE snapshot per logical location. No historical archive unless the app has an explicit "forecast accuracy" or "trend" JTBD. Weather data is forward-facing; past forecasts have no user value in a planning-only app.

### 2. Two-array normalized schema

```
ForecastSnapshot {
    schemaVersion: Int
    latitude: Double        // rounded to 2dp
    longitude: Double       // rounded to 2dp
    fetchedAt: Date

    days: [DayForecast]     // N rows (e.g., 10)
    hours: [HourForecast]   // M rows = display_window_days × 24
}
```

**Key normalization rule:** If the forecast skill horizon is shorter than the display horizon (e.g., display 10 days, picker only uses 7 days), trim the hourly array to the shorter window. Do not store hours that no consumer will ever read.

**Never store derived/computed personalized values** (e.g., burn windows, risk scores that incorporate user profile). These must be computed at render time. If the user profile is ephemeral (@State-only), storing its product defeats the purpose.

### 3. Eviction trigger hierarchy (ordered)

Run in this order on foreground:

1. **Schema version mismatch** → throw snapshot, re-fetch. No migration for re-fetchable data.
2. **Coordinate delta > threshold** (e.g., 50 km) → discard + re-fetch immediately.
3. **Time-based stale** (e.g., > 1 h) → refresh in background, show stale data with disclosure.
4. **Manual user refresh** → immediate re-fetch.
5. **OS storage pressure** (if stored in `Caches/`) → OS evicts; app handles as cold-start.

### 4. Offline: show stale with disclosure, never refuse to render

If the user has no network and has stale data:
- Show the data
- Show a non-dismissable banner: "Forecast last updated [human time]. Connect to internet for latest."
- Keep computation surfaces (pickers, calculators) functional with stale data
- Label computed results with "(cached forecast from [time])"

Exception: `snapshot == nil AND network unavailable` → show error state with retry. Do not show a skeleton loader (nothing is loading).

### 5. Schema versioning: integer field, throw-and-re-fetch

```swift
struct ForecastSnapshot: Codable {
    static let currentSchemaVersion = 1
    let schemaVersion: Int
}

// On decode:
guard snapshot.schemaVersion == ForecastSnapshot.currentSchemaVersion else {
    try? FileManager.default.removeItem(at: cacheURL)
    return nil
}
```

Bump `schemaVersion` only when adding a field with no safe default or changing a field type. Adding optional fields with nil defaults is backwards-compatible — no bump needed.

### 6. Multi-location: one snapshot, overwrite on coord change

A ring buffer of recent locations adds complexity (geocoding, location picker UI, 2–3× storage) with no payoff unless the app has a multi-location comparison JTBD. Planning apps for travelers don't: the user wants the forecast for where they ARE, not a comparison.

### 7. Computation surface data contract (picker/calculator API)

```swift
enum ForecastResult {
    case value(Double)
    case nighttime
    case unavailable(ForecastUnavailableReason)
}
enum ForecastUnavailableReason {
    case outsideWindow
    case cacheStale(fetchedAt: Date)
    case noCache
}
```

**Rules:**
- No silent `nil` return. Every state is named.
- For any date in the advertised window with a fresh cache: return `.value` or `.nighttime`, never `.unavailable`.
- For stale-cache + network-failed: return `.unavailable(.cacheStale)` and let the presentation layer decide whether to show the stale value with disclosure (usually: yes, show it).
- Expose `var pickerUpperBound: Date` so UI can clamp DatePicker range to actual data availability.

### 8. Cold-start loading state machine

```
.idle → .loading → .loaded(snapshot) | .failed(error)
```

- Skeleton loaders in `.loading`, not empty cards
- Gate computation surface (picker/calculator) entry point until `.loaded`
- Transition to `.loading` is synchronous — no flash of `.idle`

---

## Trade-off notes

| Choice | Alternative | When to switch |
|---|---|---|
| `Caches/` directory | `Application Support/` | If OS eviction causes UX-jarring cold starts in offline-heavy use cases |
| Foreground-only refresh | `BGAppRefreshTask` | If pre-populated cache on foreground is a core UX requirement (power users, outdoor athletes) |
| JSON file | SwiftData | If app already uses SwiftData and consistency > simplicity |
| 1-hour stale threshold | 30 min / 6 h | Adjust to API update cadence and user session length |
| 50 km coord eviction threshold | 25 km / 100 km | Adjust to data spatial resolution of the underlying model |

---

## Anti-patterns to avoid

- ❌ Migrating a re-fetchable cache on schema bump — re-fetch is always cheaper and safer
- ❌ Storing a ring buffer of locations without a user-facing multi-location JTBD
- ❌ Refusing to render stale data offline — especially harmful for outdoor/travel use cases
- ❌ Storing user-profile-derived computed values (burn windows, risk scores) that depend on ephemeral @State
- ❌ Returning silent `nil` from a computation-surface API — always name the failure reason
- ❌ Storing more hourly rows than the narrowest consumer needs (trim to picker/display window, whichever is shorter)
