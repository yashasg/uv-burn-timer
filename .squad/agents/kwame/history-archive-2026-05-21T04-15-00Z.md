# Kwame — History Archive (2026-05-21T04:15:00Z)

Archive of detailed learnings from WI-7 implementation rounds 1–5. See kwame/history.md for current status.

## Archived Sections

### Round 1–2: Storage Layer + WeatherKit Integration

- `ForecastSnapshot` data model (schemaVersion, lat/lon, fetchedAt, expirationDate, days/hours)
- `ForecastStore` actor API (load/save/clear/isStale/uvIndex)
- `WeatherKitForecastProvider` single round-trip integration
- DST coercion logic (spring-forward fill, fall-back truncate, polar-night all-zeros)
- `scenePhase .active` wiring in AppViews

**Outcome:** 97 tests passing, storage layer fully locked.

### Round 3–4: ForecastPickerView Structural Shell + Iris §8 Items 1–8

- Swift type-checker complexity budget (split modifier chains)
- Equatable conformance required for onChange(of:) two-arg form
- ForecastPickerLogic placement in UVBurnTimerCore
- Day row anatomy, badge pills, band chips, hourly cells with current-hour dot
- Scroll snap targeting with `.scrollTargetBehavior(.viewAligned)`
- Default selection and scenePhase reset
- Burn card copy branching (same day vs. future day)
- AX4 vertical layout breakpoint
- Items 1–8 shipped; items 9–10 deferred

**Outcome:** 97 tests pass, ForecastPickerView struct complete, ready for item 9–10 polish.

### Round 5: ForecastPickerLogic Tests + C16 Fix

- 17 new test cases (Groups H–M) for pure selection logic
- Epoch arithmetic beats UTC calendar extraction (timezone-independent)
- `withKnownIssue` accepts string literals only
- Top-level computed Calendar properties not timezone-safe; inline creation instead
- C16 resolution: missing-entry fallback changed to `.nighttime` per polar-as-nighttime directive
- 3 testability gaps identified (shouldShowRevealRow, sameHourOnDay, burnCardDatePrefix) — deferred

**Outcome:** 114 tests passing (97 baseline + 17 ForecastPickerLogic).

## Key Patterns

1. **Type-checker relief**: Split long modifier chains across separate computed properties
2. **Equatable synthesis**: All value-type snapshot models are trivially Equatable
3. **Pure logic isolation**: Core tests don't import SwiftUI or app target
4. **DST-immune hours**: UTC-based slot arithmetic (epoch + offset×3600s) avoids spring/fall traps
5. **Polar-night unified**: UVI=0 → `.nighttime` enum case (no special struct fields)
6. **Scroll snap alignment**: `.scrollTargetBehavior(.viewAligned)` + `.scrollTargetLayout()` + explicit `.id()`
7. **Reduce Motion pattern**: `.animation(reduceMotion ? nil : .easeInOut(...), value:)` on parent container

## Flags / Known Gaps

- `ForecastProviding` protocol not implemented (Ma-Ti can add for mocking)
- `forecastDays` exposed as internal (not private) for Iris's picker subview
- AX4 empirical test needed (xxxLarge Dynamic Type may require breakpoint adjustment)
- UTC calendar used in `burnCardDatePrefix` — device timezone offset may affect "today" phrasing at midnight
