## WI-7 Test Suite Complete — 2026-05-21T02:38:00Z

97 unit tests implemented and passing (Groups A–G). Full coverage of ForecastStore actor, WeatherKitForecastProvider, persistence, DST coercion, polar night handling, and edge cases. C16 ambiguity resolved by Kwame's b183dc9 fix.

## 2026-05-21T03:10:00Z — WI-7 ForecastPickerLogic tests (Groups H–M)

**17 new tests written** (Groups H–M) for `ForecastPickerLogic` pure functions. Total test count: **114 passing** (2 intentional known issues: I2, L1).

### Key patterns learned

**Epoch arithmetic beats UTC calendar extraction.** Using `Calendar(identifier:).dateComponents(...)` to verify UTC hours fails on machines with non-UTC local timezone (observed +4h offset). All hour/day assertions now use `Date(timeIntervalSince1970: epoch + n*3600)` comparisons — timezone-independent and clearer.

**Epoch constants need careful verification.** The comment `// 2026-05-23 12:00:00 UTC` on `baseEpoch = 1_748_016_000` in existing tests is wrong (actual: 2025-05-23T16:00Z). Always verify epoch values with arithmetic from a known anchor (2026-01-01 = 1767225600) rather than trusting comments.

**`withKnownIssue` accepts only string literals, not concatenated strings.** Swift Testing's `Comment` type is `ExpressibleByStringLiteral` — string concatenation (`"a" + "b"`) fails to compile. Use a single long string literal.

**Top-level computed `var` properties are not safe for Calendar.** `private var utcCalendar: Calendar { ... }` at file scope compiles but the timezone setting is not reliably respected when extracting components. Inline the calendar creation inside each function that needs it, or avoid UTC component extraction altogether.

### Testability gaps flagged (see .squad/decisions/inbox/ma-ti-picker-logic-gaps.md)

1. **`shouldShowRevealRow` not extracted** — The `forecastDays.count > 7` condition is inline in `ForecastPickerView.dayListSection`. L1 (default collapsed state) requires a SwiftUI test host. Recommend `ForecastPickerViewModel` struct.

2. **`sameHourOnDay` does not validate hour availability** — The pure function returns a UTC date without checking it exists in the target day's `[HourForecast]` array. Consumer (`selectDay`) clamps post-call, but this makes I2 (missing-slot edge case) untestable as a pure function.

3. **`burnCardDatePrefix` same/different-day branching** — The implementation correctly branches on `utcCal.isDate(selectedDate, inSameDayAs: now)`: same day → `"Burn time at [hour]"`, other day → `"Burn time on [weekday] at [hour]"`. Iris spec §5 is now accurately matched.
- **2026-05-21 WI-7 Sprint Complete**: ForecastPickerLogic test suite delivered (17 tests, Groups H–M). All 114 tests pass (97 baseline + 17 new). Three testability gaps identified (shouldShowRevealRow exposure, burnCardDatePrefix future-today variant, sameHourOnDay hour-availability validation)—all deferred to future sprint as low-urgency.

---

## 2026-05-21T04:15:00Z — WI-7 Final Validation

Kwame's final 2 commits (c772df1, 7bee563) shipped all 10 Iris §8 items with clean test results:
- **114 tests pass** on existing test infrastructure (no test regressions)
- **Build clean** — no compiler warnings or errors
- **TODO markers removed** — both Iris §8 items 9 + 10 complete

No new test gaps surfaced. All existing WI-7 coverage (Groups A–M) remains valid. Feature branch ready for user GitLab MR.

## 2026-05-22T02:58:03-07:00 — SwiftLint HIG gate installed

SwiftLint now hard-gates CI before tests (Kwame's branch `squad/swiftlint-hig-error-gate`), so test-only changes may trigger lint failures if they touch view files. 16 baseline HIG violations are now visible; Iris will HIG-pass them before merge.
Model assignment updated 2026-05-22T04:01: claude-opus-4.7 (premium Opus, always-on — overrides prior auto selection).

## 2026-05-22T04:05:00-07:00 — Loop-26 test audit (HIG #95/#96 + PR #98 + manual QA gates)

Audit written to `.squad/decisions/inbox/ma-ti-loop-26-test-audit.md`.

### Inventory snapshot
- **309 tests total** (300 unit `@Test` + 9 XCUITest `func test*`). Largest file: `BurnTimeCalculatorTests.swift` (218). MainScreenCleanupContractTests = 18 (Groups N–Q).

### Key findings
1. **Both manual checklists FAIL by loop.md §6** — sign-off blocks blank, non-automatability explicitly documented (contrast checklist §123–148, launch checklist §129–157). Build cycle is BLOCKED on TestFlight/App Store gates, NOT on daily merge work. Asset-token contract is partially satisfied via existing `Color("Severity*")` lookups + source-text guards (O1, T1).
2. **PR #98 SwiftLint regex has a hole:** numeric `.padding(N)` is NOT covered by any rule. #95 has 23 padding sites, #96 has 12 — all would pass lint silently if frames+fonts are fixed.
3. **`missing_min_touch_target` is a regex heuristic, not an AST check** — cannot prove backing identifier is `@ScaledMetric` (acknowledged in `.swiftlint.yml` itself).

### TDD recommendation
Write **Group R (8 tests)** in `MainScreenCleanupContractTests.swift` BEFORE Kwame's cleanup work — mirrors the `test_O1_*` source-text-guard pattern (`String(contentsOf: appViewsSwiftURL())` + identifier-boundary regex). R1–R6 pin literal frame/padding/font absence in both files; R7/R8 close the `@ScaledMetric` adjacency gap that SwiftLint cannot prove. Cost ~80 lines / 30 min. Carve-outs: `.padding(0)`, `.frame(...:0)`, `.frame(maxHeight: .infinity)`.

### Learning
- **The source-text guard idiom from O1 is the right primitive for HIG-token enforcement.** Compile-independent, fast, and audits the actual file Kwame edits — not just a built artifact. Avoids the SwiftLint binary-availability trap on local devs.
- **Sign-off blocks deserve a hands-off policy.** The contrast checklist's own truthfulness-contract clause (line 130) is the binding rule — auto-filling would violate D-2026-05-19-honest-privacy-copy. Always treat blank = FAIL = surface to loop maintainer, never paper over.
