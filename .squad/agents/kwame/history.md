# Kwame — History

**Latest Status (2026-05-21T04:15:00Z):** WI-7 COMPLETE. All 10 Iris §8 items shipped + verified. Final commits c772df1 (stale banner + error retry) + 7bee563 (Increase Contrast). 114 tests pass. Build clean. Branch feature/wi-7-uv-forecast ready for user GitLab MR.

**Full History Archive:** See `history-archive-2026-05-21T04-15-00Z.md`

---

## Final Round (2026-05-21T04:15:00Z) — Items 9 + 10

### Item 9: Stale-data banner + error retry

**ForecastRefreshState enum** (`.idle` / `.refreshing` / `.error(String)`):
- Wired in `performForecastRefresh()`: set `.refreshing` AFTER guard, `.idle` on success, `.error(msg)` on catch
- Reset to `.idle` in `clearSavedRoundedCoordinate()`
- Banner placed inside `else` branch (non-empty data) — structural placement = no nil checks needed

**Stale-data banner UI**:
- Yellow background: `systemYellow.opacity(0.12)`
- Rotating arrow: `.animation(.linear(1.5).repeatForever())` + `.animation(nil)` under Reduce Motion
- Static arrow icon under `accessibilityReduceMotion` (no rotation)

**Error row + Retry button**:
- Red error text: `.foregroundColor(.red)`
- 44pt Retry button: `.frame(minHeight: 44)` (HIG minimum tap target)
- Parent easeInOut animation on `forecastRefreshState` (not on banner itself)

### Item 10: Increase Contrast

**Private helpers pattern**:
```swift
@Environment(\.colorSchemeContrast) private var contrast

var pillBorderWidth: CGFloat { contrast == .increased ? 1 : 0 }
var bandBarHeight: CGFloat { contrast == .increased ? 6 : 4 }
var selectedRowOpacity: Double { contrast == .increased ? 0.25 : 0.12 }
```

**Application**:
- Badge pill / band chip borders: `.overlay(RoundedRectangle.stroke(..., lineWidth: pillBorderWidth))`
- Band bar height: `.frame(height: bandBarHeight)`
- Selected day background: `Color.accentColor.opacity(selectedRowOpacity)`

**Trade-off**: Zero layout cost at normal contrast (0pt borders = invisible). Growth at Increase Contrast is absorbed by Spacer compression (cell frame is fixed 60×88pt).

### Build + Test

- `xcodebuild build`: ✅ BUILD SUCCEEDED (no warnings)
- `swift test`: ✅ Test Suite passed (114 tests)
- Both TODO markers removed

---

## Summary: WI-7 Ship

**Commits on feature/wi-7-uv-forecast:**
- 4 initial (storage + picker shell + refresh wiring)
- 4 intermediate (ForecastPickerLogic tests + C16 fix)
- 4 polish rounds (items 1–8)
- 2 final (items 9–10)
- Total: ~32 commits

**Iris §8 Checklist:** ✅ All 10 items complete
**Test count:** ✅ 114 all passing
**Build status:** ✅ Clean

**Ready:** Branch ships to user for GitLab MR. No further squad work required.


**Built on branch `feature/wi-7-uv-forecast` (4 commits):**

### What was built

1. **`app/Sources/UVBurnTimerCore/ForecastSnapshot.swift`** — locked data model:
   - `ForecastSnapshot`: schemaVersion, latitude/longitude (2dp flat fields), fetchedAt, expirationDate (Apple signal), `days: [DayForecast]`, `hours: [HourForecast]`
   - `DayForecast`: date, dailyMinUVI (0.0), dailyMaxUVI (from DayWeather.uvIndex), sunrise?, sunset? — NO solarNoon, no polar-detection fields (zero special-case code)
   - `HourForecast`: timestamp (UTC), uvIndex
   - `isStale(now:)` predicate using `expirationDate` (no hardcoded threshold)
   - `UVResult` enum: `.value(Double)`, `.nighttime` (UVI==0 including polar night), `.unavailable(reason: UnavailableReason)`
   - `UnavailableReason: String, Codable`: noSnapshot, snapshotExpired, coordOutOfRange, schemaMismatch

2. **`app/Sources/UVBurnTimerCore/ForecastStore.swift`** — actor:
   - Pure load/save/clear/isStale/isCoordOutOfRange/uvIndex(at:) API
   - `load()`: validates schema version + hours invariant; deletes corrupt file; throws `.schemaMismatch`
   - `save()`: atomic write (`options: .atomic`)
   - `isCoordOutOfRange()`: pure Haversine (no CoreLocation, keeps core lean)
   - `uvIndex(at:)`: picker API — UVI==0 → `.nighttime` (polar night handled by collapse, zero special-case code)
   - Registered in `app.xcodeproj` UVBurnTimerCore Sources build phase

3. **`app/Sources/UVBurnTimer/WeatherLocationServices.swift`** — added `WeatherKitForecastProvider`:
   - Single round-trip: `WeatherService.shared.weather(for:including: .daily, .hourly)`
   - `DayWeather.sun` is `SunEvents` (non-optional struct); `sunrise`/`sunset` are `Date?` inside
   - Hours coerced to `days.count × 24` UTC slots:
     - DST spring-forward (23 civil hours): missing slot → UVI = 0
     - DST fall-back (25 civil hours): truncated to first 24
     - Polar-night: all 24 slots carry UVI = 0 (physics; no special casing)
   - expirationDate from `Forecast<DayWeather>.metadata.expirationDate`

4. **`app/Sources/UVBurnTimer/AppViews.swift`** — scenePhase wiring:
   - Added `@State forecastStore`, `@State forecastSnapshot`, `@State isFetchingForecast`
   - `scenePhase .active`: fires `refreshForecastIfNeeded()` (augments, doesn't replace existing reattestation)
   - `refreshForecastIfNeeded()`: nil → fetch; stale → fetch; coord >50km → clear + fetch; valid → noop
   - `performForecastRefresh()`: guarded by `isFetchingForecast`, network errors swallowed (offline-safe)
   - `refreshUV()` success path also calls `performForecastRefresh()` (seeds forecast on first location fix)
   - `clearSavedRoundedCoordinate()` also clears forecast store + forecastSnapshot
   - `forecastDays: [DayForecast]` exposed for Iris's picker PR (stub — full picker UI deferred)

### Deviations from spec (noted)

- **`forecastDays` access modifier**: exposed as `var forecastDays: [DayForecast]` on RootView (internal, not private) so Iris's picker subview can read it. Marked as stub in comment.
- **Conflict resolution**: An earlier agent session had created `ForecastModels.swift` in `UVBurnTimerCore` with different type names (`DailyForecastEntry`, `HourlyForecastEntry`, `roundedCoordinate: UVCoordinate`). That file did not exist on disk at implementation time — no conflict at build time. The locked spec's type names (`DayForecast`, `HourForecast`, flat lat/lon) were used throughout.
- **`ForecastProviding` protocol**: not implemented. The spec doesn't require it; WeatherKitForecastProvider is a concrete struct. Ma-Ti can add protocol conformance if needed for mocking.

### Build verification

- `swift build` (SPM, UVBurnTimerCore): ✅ Build complete
- `xcodebuild -scheme UVBurnTimer -destination 'generic/platform=iOS Simulator'`: ✅ Build complete

---

## Learnings — Appended 2026-05-21T02:00:00Z

- **`ForecastModels.swift` conflict**: Prior sessions may leave stub files with conflicting type declarations. Always check `ls Sources/UVBurnTimerCore/` before creating new files.
- **`Forecast<DayWeather>.metadata.expirationDate`**: The variadic `weather(for:including:)` API returns typed `Forecast<T>` tuples, each with `.metadata.expirationDate`. This is the Apple-blessed staleness signal per the spec.
- **Haversine in UVBurnTimerCore**: Using pure-Swift Haversine keeps the Core module free of CoreLocation. The max error from 2dp coord rounding (~1.1 km) is noise at the 50 km eviction threshold.
- **Hours invariant coercion**: UTC-based slots (dayStart + offset×3600s) are DST-immune. Spring-forward gaps → pad 0; fall-back overlap → first 24 wins. Polar-night: all 24 slots naturally carry UVI=0 with no special code.
- **C16 closed (2026-05-21T02:35:00Z)**: `uvIndex(at:)` missing-entry fallback changed from `.unavailable(.snapshotExpired)` to `.nighttime`, per polar-as-nighttime directive (Yashas, 2026-05-21). Critical distinction: dates *outside* the snapshot window still return `.unavailable(.snapshotExpired)`; only dates inside the window with an absent slot return `.nighttime`. Required adding a date-range guard (`firstHour…lastHour`) before the coercion so a date a year in the future still gets `.unavailable`, not `.nighttime`. `withKnownIssue` wrapper removed from C16 test. All 97 tests pass.


## Learnings — Iris §8 items 9 + 10 — 2026-05-21T03:35:00Z

### Items shipped this round

**Item 9 — Stale-data banner + error retry:**
- **Refresh state machine**: `ForecastRefreshState: Equatable` enum (`.idle` / `.refreshing` / `.error(String)`) lives in `ForecastPickerView.swift`. Must be `public` because `ForecastPickerView` is `public` — the compiler will reject `public let forecastRefreshState: ForecastRefreshState` if the enum is `internal`.
- **State wiring**: Set `.refreshing` *after* the guard in `performForecastRefresh()`. Early returns (no coord, already fetching) must NOT change state. Set `.idle` on success, `.error(localizedDescription)` in `catch`. Reset to `.idle` in `clearSavedRoundedCoordinate()` to prevent stale error banner after location clear.
- **Banner guard**: Insert `staleBannerView` only inside the `else` branch (data non-empty). `forecastDays.isEmpty` = skeleton state = banner is invisible regardless of `forecastRefreshState`. No explicit nil check needed in the view — structural placement handles it.
- **Rotation animation**: `@State var isRotating: Bool = false` + `.animation(.linear(1.5).repeatForever(autoreverses: false), value: isRotating)` + `.onAppear { isRotating = true }` + `.onDisappear { isRotating = false }`. Static under `accessibilityReduceMotion` via `animation(nil, value:)`.
- **easeInOut on parent**: `.animation(reduceMotion ? nil : .easeInOut(0.2), value: forecastRefreshState)` on the card container, not on the banner itself. This animates the banner's appear/disappear without accidentally animating other card content.
- **Retry button 44pt**: `.frame(minHeight: 44)` on a `Button("Retry")` — meets HIG minimum tap target. VoiceOver reads "Retry, button"; the preceding Text has `.accessibilityLabel("Could not update forecast")` for full context.
- **Skill written**: `.squad/skills/ios-refresh-state-banner/SKILL.md` — reusable pattern for any stale-data-with-background-refresh surface.

**Item 10 — Increase Contrast:**
- **Private helpers pattern**: Three `var` helpers (`pillBorderWidth: CGFloat`, `bandBarHeight: CGFloat`, `selectedRowOpacity: Double`) driven by `@Environment(\.colorSchemeContrast) private var contrast`. Each helper has a ternary: `contrast == .increased ? highValue : normalValue`. Cleaner than inline conditionals scattered across multiple view functions.
- **Border via `.overlay`**: `.overlay(RoundedRectangle(cornerRadius: 11).stroke(Color(.label), lineWidth: pillBorderWidth))` — a `lineWidth: 0` stroke is invisible (no layout cost) so the overlay is always present; it just renders nothing at normal contrast.
- **Band bar height**: Replace `.frame(height: 4)` with `.frame(height: bandBarHeight)`. The surrounding `VStack(spacing: 0)` + `Spacer` layout means the cell grows slightly — acceptable; the cell outer frame is `frame(width: 60, height: 88)` which is fixed, so the bar growth compresses the Spacer only.
- **Selected background**: `Color.accentColor.opacity(selectedRowOpacity)` — 0.12 normal, 0.25 Increase Contrast. Applied only to the day row, not the hourly cell selected state (which uses 0.15 and is a separate spec value not listed in §7 Increase Contrast).

### Build + test result
- `xcodebuild build`: ✅ BUILD SUCCEEDED (clean, no warnings)
- All tests: ✅ `Test Suite 'All tests' passed` (114 tests)
- Both TODO markers removed from `ForecastPickerView.swift`


WI-7 implementation and C16 fix complete. 11 commits (6 implementation + 1 fix), 97 tests all passing. Storage layer fully locked and ready for UI.


## Learnings — ForecastPickerView Structural Shell — 2026-05-21T03:30:00Z

- **Swift type-checker complexity budget**: SwiftUI views with many `@State` properties + long modifier chains can hit the type-checker's expression complexity limit, triggering "unable to type-check this expression in reasonable time". The fix is NOT to just extract the VStack content — you must also split the *modifier chain itself* into two separate computed properties (`navigationStackBase` + `mainNavigationStack`). Each property is type-checked independently. ~16 modifiers was the tipping point here.

- **Equatable required for `onChange(of:)`**: The two-argument `onChange(of:) { _, new in }` form (iOS 17+) requires the observed value to conform to `Equatable`. `ForecastSnapshot?` didn't conform, so adding `.onChange(of: forecastSnapshot)` failed. Solution: add `Equatable` to `ForecastSnapshot`, `DayForecast`, `HourForecast` — all trivially synthesised since every stored property is `Equatable`.

- **Extract heavy closures into methods**: The `onChange(of: scenePhase)` closure contained a `switch` with multiple branches and state mutations. Extracting to `handleScenePhaseChange(_:)` both reduces inline type-checker burden and improves readability.

- **`@ViewBuilder` split pattern**: To keep `RootView.body` trivial, use `body → mainNavigationStack → navigationStackBase`. Each level is a separately-typed expression. `body` returns one property, `mainNavigationStack` applies event modifiers to `navigationStackBase`, and `navigationStackBase` owns the NavigationStack chrome (toolbar, safeAreaInset, title).

- **ForecastPickerLogic placement**: Pure logic (no SwiftUI, no actors) belongs in UVBurnTimerCore so Ma-Ti can test it without any app target linkage. The app target's `ForecastPickerView` imports it.


## Learnings — Iris §8 Checklist Implementation — 2026-05-21T03:10:00Z

### Items shipped this round (items 1–8)

1. **Day row anatomy (item 1)**: Two-line layout using `VStack { primaryLabel; secondaryLabel }` + `.fixedSize(horizontal: false, vertical: true)` grows at AX sizes without clipping. `Calendar.current.isDateInToday` for the "Today" label. WHO band color table implemented as a switch on UVI ranges using UIKit semantic colors (`Color(.systemGreen)` etc.) — no hex, adapts to light/dark/contrast automatically.
2. **Selected day state (item 2)**: Confirmed `Color.accentColor.opacity(0.12)` + `.isSelected` trait already present; wired `.headline` font for selected/Today rows via `isSelected || isToday` condition.
3. **Badge pill / band chip (item 1)**: 40×22pt pill = `frame(width: 40, height: 22)` + `RoundedRectangle(cornerRadius: 11)`. Text contrast: `uvi < 6 ? .black : .white` (Low/Moderate are light fills). Band chip is 56×22pt for D+7–D+9.
4. **Hourly cell band bar (item 3)**: `RoundedRectangle(cornerRadius: 2).fill(bandColor).frame(height: 4)` at bottom of a `VStack(spacing: 0)` outer container. `Color.clear` for nighttime avoids layout shift. The outer VStack is `frame(width: 60, height: 88)` — inner Spacers distribute vertical space.
5. **Current-hour dot (item 3)**: Placed outside cell frame by wrapping `hourCell` + `Circle()` in a `VStack(spacing: 4)` (`hourCellWrapped`). Used `Color.clear` instead of `.opacity(0)` or `.hidden()` to avoid layout shifts while keeping the dot slot in layout.
6. **Scroll snap (item 4)**: `.scrollTargetBehavior(.viewAligned)` on the `ScrollView`, `.scrollTargetLayout()` on the `LazyHStack`, explicit `.id(hour.timestamp)` on each cell for `ScrollViewReader`. `.onAppear` also fires the scroll so the picker opens on the current hour without user interaction.
7. **Default selection init (item 5)**: `ForecastPickerLogic.defaultSelectedDate(in:now:)` finds `snap.hours.first { roundedDownToHour($0.timestamp) >= roundedNow }` — first slot at-or-after now, not the exact rounded hour. This is more robust than clamping because it handles "between hour slots" edge cases.
8. **scenePhase .active reset (item 5)**: Reset both `selectedDate` and `selectedDateIsUserOverridden = false` at the top of the `.active` case, before the reattestation check. Order matters: if reattestation fires, the disclaimer sheet appears over a correctly-reset picker state.
9. **Burn card copy (item 6)**: `burnCardDatePrefix` now uses `utcCal.isDate(selectedDate, inSameDayAs: now)` to distinguish "today future hour" vs "future day". Using UTC calendar (not `.current`) matches the picker's day-selection logic, so "today" in the card header always agrees with "today" in the day list.
10. **HeroTimerCard UVI=0 copy (item 6)**: Replaced `moon.zzz` + verbose copy with a `Label { Text("No UV at this hour") } icon: { Image(systemName: "moon.fill") }`. Label auto-stacks icon+text and applies correct `.subheadline` + `Color(.secondaryLabel)`. Added explicit `.accessibilityLabel("No UV at this hour. No burn risk.")` for VoiceOver reassurance per Iris §5.
11. **Chevron rotation (item 7)**: Single `chevron.down.circle.fill` + `.rotationEffect(.degrees(showExtendedDays ? 180 : 0))` + `.animation(reduceMotion ? nil : .easeInOut(0.15), value: showExtendedDays)`. Cleaner than symbol-swap and respects Reduce Motion (animation(nil) = instant, no tween).
12. **AX4 vertical layout (item 8)**: `dynamicTypeSize >= .xxLarge` gate (AX3+). Iris empirical flag: if horizontal cells clip at AX4 (xxxLarge) on simulator, lower breakpoint to `.xLarge`. Vertical rows reuse `bandChip(uvi:)` helper — no new types needed. Each row uses `frame(minHeight: 44)` not fixed height so text wraps at very large sizes.

### Items deferred

- **Item 9 — Stale-data banner**: Not shipped. Requires new state in RootView (`isForecastRefreshing`, `forecastRefreshError`) to be passed down. The view layer is ready (TODO comment in ForecastPickerView.swift). Deferred to avoid RootView state explosion in this round — coordinate with Yashas/Ma-Ti.
- **Item 10 — Increase Contrast**: Not shipped. Requires `@Environment(\.colorSchemeContrast) == .increased` checks on badge pills, band chips, selected backgrounds (opacity 0.25), and band bars (6pt height). The TODO comment is in ForecastPickerView.swift. Low visual risk to defer — Increase Contrast mode is an overlay on already-working UI.

### Flags for Iris / Yashas

- **AX4 empirical test needed**: Test at xxxLarge Dynamic Type on iOS Simulator. If horizontal hourly cells clip, lower `dynamicTypeSize >= .xxLarge` breakpoint to `>= .xLarge` in `hourlyStripSection`.
- **WHO band text contrast on Moderate (yellow)**: Low UVI (0–5) uses `.black` text on systemGreen/systemYellow fills. These are light fills — contrast should pass WCAG AA. Worth a quick contrast check at AX5.
- **`burnCardDatePrefix` uses UTC calendar**: Both the day picker and `burnCardDatePrefix` use UTC day boundaries. If the user's device timezone is significantly offset from UTC (e.g., UTC-8), "today" in the card header may lag by one day at midnight local time. Accept for now — aligns with picker's UTC-based day selection. Known limitation, document if it surfaces.
- **2026-05-21 WI-7 Sprint Complete**: ForecastPickerView implementation shipped (6 commits). Pure logic in UVBurnTimerCore, synchronous snapshot read, Equatable models, NavigationStack split for type-checker, Date.FormatStyle for Swift 6 Sendable. All 97 baseline tests pass; ready for Ma-Ti testability sprint. Items 9–10 deferred.
