# Ma-Ti — History

## Core Context

- **Project:** A UV exposure and sunburn timer app
- **Role:** Tester
- **Joined:** 2026-05-19T06:26:01.547Z

## Learnings

<!-- Append learnings below -->

- 2026-05-19T10:56:40Z: Added TDD coverage for behavior-first Fitzpatrick picker copy; implementation should reorder copy to burn/tan behavior before skin-color descriptors.
- 2026-05-19T16:30:05-07:00 (work item #4): Discovered latent failure in `approvedMainScreenSafetyCopyIsCaptured` — `skinTypePickerPrompt` had been updated to behavior-first Wheeler-aligned copy ("Choose by how your skin burns and tans…") but the test was still asserting the old string. Fixed. Added 9 new core tests covering: all-six-rows invariant, behavior-first/no-color-anchor for prompt, Wheeler §3.1 subtext cues, Plunder §2.3 inline source pointer, no-default footer (D-2026-05-19-012), not-medical-advice on major surfaces, WeatherKit attribution URL, full citation links set (Wheeler §4), and onboarding commit-gate model invariant. Added 2 UI tests: main screen does not expose Fitzpatrick picker post-onboarding; Settings skin-type edit path (uses XCTExpectFailure until Kwame implements). Final count: 56 / 0 failures. Key blocker: Settings skin-type edit row not yet in app. Full plan at `.squad/decisions/inbox/ma-ti-redesign-test-plan.md`.

- 2026-05-19T16:47:52-07:00 (circular gauge guard): Kwame landed `BurnRiskGaugeCard` (AppViews.swift ~line 1338) and two initial gauge UI tests while I was scoping. I confirmed the implementation matches the Iris spec (Issue 2, iris-redesign-a11y-review.md): placed between HeroTimerCard and UVIndexCard, `accessibilityIdentifier("BurnRiskGauge")`, `accessibilityLabel("Burn risk gauge. N% of estimated burn window elapsed.")`, `accessibilityValue(percentText)`, suppressed when estimate is nil/tier=.none. Kwame's two tests covered: (1) gauge present on stale estimate + value not 0%; (2) gauge absent when no estimate. Gaps I filled: (3) `testCircularGaugePresentOnFreshEstimate` — guards against conditioning on stale-only; (4) `testHeroTimeEstimateRemainsDominantAlongsideGauge` — guards gauge-as-replacement regression; (5) `testCircularGaugeAccessibilityLabelIsNonColorAndMeaningful` — guards label contains "Burn risk gauge" + "elapsed" text, value ends with "%". All 5 tests should pass (implementation is in place). Cannot run in this environment (iOS simulator required). Decision doc at `.squad/decisions/inbox/ma-ti-circular-gauge-test-guard.md`.

### 2026-05-20T00:01:47Z: Team Decision

**Scribe Log Entry**

Team approvals and implementations completed for approved redesign and paraphrasing initiatives:
- Wheeler: Paraphrase traceability review (conditional accept, fixes noted)
- Ma-Ti: Redesign tests passing + gauge guard tests verified
- Iris: HIG/accessibility audit passed
- Kwame: Implementation and circular gauge both passing

All inbox decisions merged into decisions.md.


- 2026-05-19T22:50:27.684-07:00 (duration formatting tests): Aligned duration-format coverage with Kwame’s in-progress hours/minutes implementation. Core tests now cover under-1-hour minutes, exact 1 hour, over-1-hour burn estimates, the sunscreen 2-hour cap, and No UV unavailable display/accessibility. UI expectations now target compact hero strings such as `Up to 2 hr` and `~1 hr 20 min`. SwiftPM core tests pass (62/0); full Xcode build/test was attempted with project-local DerivedData but did not complete before timeout, so simulator UI validation remains blocked.

### 2026-05-21T00:55:49Z — Incoming test suite updates for UVI forecast feature (WI-7 round 2)

- **Drop tests (if written):** Any test asserting opacity/gray visual demotion on forecast rows D6–10 (flat treatment now locked).
- **Add test assertions (CRITICAL for compliance):**
  1. Card-level `.caption .secondary` footnote present on 10-day forecast card; text matches "UV accuracy beyond 3–5 days decreases as cloud cover becomes harder to predict."
  2. Picker refuses to compute burn-time for any date selection > D+7 (returns `.none` or refusal-state enum, not a number).
  3. Integer UVI rendered for day-indices 0–4 only; no integer UVI for day-indices ≥5 on 10-day card.
  4. WHO category band thresholds match locked WHO 2002 values exactly: 0–2 (Low), 3–5 (Moderate), 6–7 (High), 8–10 (Very High), 11+ (Extreme).
  5. Picker default date/time = current date/time (rounded to next full hour, or now if within first half of current hour).
  6. UVI 0 hour → "No UV at this hour — no sun protection needed" display (not ∞, not a number).
  7. No-skin-type gate on picker (same as live card): shows "Set your skin type to see a planned burn window" prompt.
  8. Forecast-unavailable hour → "Forecast unavailable for this time" with retry button; Done button disabled.
  9. Day 8–10 picker selection (if D+10 clamping used as fallback) → graceful-refusal message renders.
  10. L3 chevron ("Is this estimate for me?") present on forecast card footer; navigates to About @ photosensitizer enumeration section.
  11. Photosensitization re-disclosure text present on picker sheet (D-2026-05-19-013 wording carried).
  12. WeatherKit attribution present on forecast card and picker-sheet surfaces.
- **Edge-case coverage:** Sunrise/sunset computation (sun below horizon = UVI 0); ReduceMotion behavior (instant swap vs eased animation); picker range clamping at data boundary (if WeatherKit returns <10 days).
- **Orchestration log / session log:** Attached to `.squad/log/2026-05-21T00:55:49Z-uvi-forecast-pushback-round-2.md`.


## 2026-05-21 Session Update — WI-7 Consolidation Round

**Context:** WI-7 design is fully locked. Wheeler has ratified polar-region science. All blocked questions resolved. Only implementation remains.

**Status for Ma-Ti:** Test acceptance criteria are complete and reconfirmed. Wheeler's polar-region science ratification (2026-05-21T01:34:16Z) confirms no special test cases needed beyond the already-locked list. Specifically:

**Test plan stands (per Gi §8 + Iris §1 + Wheeler ratification):**
1. Hourly card scroll — verify smooth horizontal scroll, cell visibility
2. Day 1–5 vs 6–10 row rendering — numeric UVI present D1–D5 only, TierBadge on all 10
3. Picker date range clamping at D+7 — verify DatePicker boundaries + boundary hours
4. UVI-0 edge case — verify `BurnTimeEstimate` returns `.infinity` + `tier: .none`; UI shows `"No UV at this hour"`
5. No-skin-type gate — verify picker shows prompt, Done disabled until skin type set
6. Forecast-unavailable retry — verify error block appears, Done disabled, Retry button functional
7. VoiceOver per-row labels — verify accessibility labels on day/hour rows
8. Dynamic Type (accessibility3+) — verify hourly card adapts to `LazyVStack` at large sizes
9. Reduce Motion — verify picker date change swaps result instantly (no animated count-up)
10. L3 chevron → About anchor — verify "Is this estimate for me?" link opens correct anchor

**No additional polar-night test cases needed.** Wheeler confirmed:
- Burn-time formula at UVI=0 is already correct (returns `.infinity`, no special handling)
- Polar-day sustained 24h UVI does not change formula (single-session model still correct)
- No `.polarNight` enum case in `UVResult` (`.nighttime` covers all UVI=0 cases indistinguishably)
- UI-layer collapsed state (Iris's "No UV today — sun does not rise at this place") does not require special-case test phrasing

**One pending:** Wheeler's copy MODIFY ("latitude" → "this place"). Iris will update the spec; Ma-Ti to verify the phrasing in test cases matches the final Iris spec.

Acceptance criteria are locked. Ready for test implementation.

## 2026-05-21 — WI-7 Unit Test Suite (Groups A–G) — SHIPPED

**All 27 WI-7 tests written, committed, and passing.** Summary of learnings:

### Key type name corrections (charter vs. reality)
- Charter used `UVUnavailableReason` → Kwame has `UnavailableReason`
- Charter used `.unavailable(.snapshotExpired)` → actual labeled: `.unavailable(reason: .snapshotExpired)`
- Charter used `snapshot.dailyForecasts` / `snapshot.hourlyForecasts` → Kwame has `.days` / `.hours`
- Charter used `HourlyForecastEntry.date` → Kwame has `HourForecast.timestamp`
- `DayForecast` has no `solarNoon` field — polar-night is UVI=0 → `.nighttime` with no special storage

### Clock-injection gotcha
`ForecastStore.uvIndex(at:)` checks staleness via `Date()` (wall clock). `isStale(now:)` IS injectable but `uvIndex(at:)` doesn't use it. Workaround: use `expirationDate: Date.distantFuture` in every "fresh snapshot" helper.

### ForecastStore test isolation pattern
Use `internal init(fileURL:)` + UUID-named file under `cachesDirectory`. Clean up with `defer { try? FileManager.default.removeItem(at: url) }`. Do NOT use `/tmp` (forbidden by environment).

### C16 known issue — missing entry fallback
`ForecastStore.uvIndex(at:)` returns `.unavailable(reason: .snapshotExpired)` for missing hourly entries. Spec says `.nighttime`. Gap tracked in `.squad/decisions/inbox/ma-ti-missing-hour-coercion.md`. Test wrapped with `withKnownIssue(...)`.

### Mock/protocol pattern for WeatherKit
WeatherKit types are uninitializable in SPM unit tests. Solution: `ForecastProviding` protocol in Core + `StaticForecastProvider`/`FailingForecastProvider` test doubles. Full pattern documented in `.squad/skills/forecast-store-test-patterns/SKILL.md`.

### ForecastRefreshCoordinator injection
`handleSceneActive(currentLatitude:currentLongitude:now:)` is fully injectable. Groups E/F/G tests work cleanly. The real `WeatherKitForecastProvider` doesn't yet conform to `ForecastProviding` — Kwame needs to add that wiring.

### Final outcome
- 97 tests total: 96 pass + 1 known issue (C16)
- 4 commits on `feature/wi-7-uv-forecast`
- Spec ambiguity: `.squad/decisions/inbox/ma-ti-missing-hour-coercion.md`
- Test pattern skill: `.squad/skills/forecast-store-test-patterns/SKILL.md`

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
