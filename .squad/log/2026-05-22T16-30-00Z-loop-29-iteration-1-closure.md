# Loop-29 Iteration 1 Closure

**Date:** 2026-05-22T16:30:00Z
**Agent:** Scribe (Session Logger) — via Copilot CLI loop driver
**Branch base:** main @ 36c3560

## Summary

First post-Loop-28 iteration of Loop-29 closed. Three PRs landed on `main`:

| PR | Title | Merged | Author trail |
|---|---|---|---|
| #102 | WI-loop28-4: matched-brace struct scan helper replaces fixed-offset windows | 15:02Z | Kwame (test-side TDD hardening for U2/T1/V4 scan windows + helper SU1–SU5) |
| #103 | Scribe: Loop-28→29 hygiene — merge 4 inbox files into decisions.md | 15:12Z | Scribe (inbox 4→0, decisions.md +433L) |
| #104 | WI-loop29-2: missing_min_touch_target regex covers Button { trailing-closure form | 16:27Z | Kwame (TDD Group LW1–LW3 + 9 site reconciliations) |

## What shipped

**Source-text contract test infrastructure (PR #102 / WI-loop28-4):**
- `_substringOfAppViewsStruct(_:in:)` helper with lexer state machine (~110 LOC) covering normal/line-comment/block-comment/string/multiline-string contexts.
- Group SU (SU1–SU5) guards the helper itself.
- T1, U2, V4 migrated from fixed-character windows to matched-brace bounded slices — removes the comment-prose pressure that previously forced AV-12/AV-13 swiftlint:disable justification blocks to shrink as struct bodies grew.
- ADR-0001 line citations refreshed (PersistentFooter push 2144→2164; test_R1/R2 1383→1500, 1395→1512).

**Squad hygiene (PR #103):**
- Inbox files merged into decisions.md and removed:
  - `copilot-directive-hig-strict-error-day1.md`
  - `kwame-loop28-wi1-chip-footer-mintap.md`
  - `kwame-swiftlint-hig-gate-install.md`
  - `kwame-swiftlint-strict-day1-tightening.md`
- Iris Loop-28 closure HIG sign-off block appended (verifies WI-0 + WI-1 + LU1–LU5 + WI-21 automation-status state).

**HIG SwiftLint rule expansion (PR #104 / WI-loop29-2):**
- `missing_min_touch_target` regex trigger alternation widened from `(?:\.onTapGesture\b|\bButton\s*\()` to `(?:\.onTapGesture\b|\bButton\s*\(|\bButton\s*\{)`. Closes Iris Loop-29 GAP-2 (the iOS 26.4 toolbar hittability regression blind spot — `Button { ... } label: { ... }` trailing-closure form on RootView's gear button).
- Lookahead unchanged: still requires `.frame(...minWidth: id, minHeight: id)` within 200 chars.
- 9 Button-`{` sites reconciled (5 in AppViews.swift, 4 in ForecastPickerView.swift). Mix of `.frame(minHeight: minTap)` additions, struct-scoped `@ScaledMetric` declarations, and `swiftlint:disable:this missing_min_touch_target` per-line directives where the existing `@ScaledMetric` floor sits past the 200-char lookahead.
- New Group LW (LW1–LW3) in `MainScreenCleanupContractTests.swift`:
  - LW1: `.swiftlint.yml` regex includes `Button\s*\{` pattern.
  - LW2: `AppViews.swift` Button `{` sites all have adjacent `.frame` guard or per-line disable.
  - LW3: `ForecastPickerView.swift` Button `{` sites all have adjacent `.frame` guard.

## CI / Build health

- `./build.sh` green on all three branches before merge.
- SwiftLint strict gate: 0 violations on each merged commit.
- Warnings-as-errors: clean on each merged commit.
- Test suite: 320 tests pass (2 pre-existing known issues in `ForecastPickerLogicTests`, unrelated to this iteration).

## Loop-29 backlog status after this iteration

Original backlog (filed by Iris 2026-05-22T13:30Z): WI-29-1 … WI-29-7.

| WI | Title | Status |
|---|---|---|
| WI-29-1 | Struct-scoped contract tests (matched-brace slicer) | ✅ Done — landed via PR #102 (Group SU + T1/U2/V4 migrations) |
| WI-29-2 | Regex catches `Button {` trailing-closure | ✅ Done — PR #104 |
| WI-29-3 | Regex catches `minHeight:`/`minWidth:` literals | ✅ Done — PR #101 (pre-iteration) |
| WI-29-4 | Toolbar-specific custom rule (`toolbar_image_needs_scaled_frame`) | 🟡 Open — not started |
| WI-29-5 | DisclaimerSeeAboutLink Button AX5 fix | 🟡 Open — partially addressed in PR #104 (DisclaimerSeeAboutLink got `minHeight: minTap` in its inner `.frame`) — verify separately whether AX5 vertical-stack rendering still needs a dedicated WI |
| WI-29-6 | ADR-0002 iOS 26.4 extension subsection | 🟡 Open — not started |
| WI-29-7 | Systematic `NavigationLink`/`Link` audit (regex widening) | 🟡 Open — deferred per WI-29-2 scope cap |

## Goals checklist (from loop.md §6)

- [x] **Working app:** `./build.sh` green; UVBurnTimer.app builds; previously-shipped behaviour preserved.
- [x] **UI/UX approved:** Iris Loop-28 closure HIG sign-off block in decisions.md (PR #103) validates WI-0 + WI-1 + LU1–LU5.
- [x] **User scenarios captured:** No new persona changes this iteration; canonical user-flow spec unchanged.
- [x] **Expert approved:** No new science / legal / privacy decisions this iteration.
- [ ] **Code tested and validated:** Automated tests + lint green ✅. WI-21 physical-device sign-off blocks on `iris-contrast-qa-checklist.md` + `iris-launch-readiness-checklist.md` REMAIN BLANK (deferred — owner lacks OLED iPhone + WCAG measurement tool). Goal 5 carries PENDING into the next iteration.

## Next-iteration kick-off pointers

1. **Highest-priority remaining HIG work item:** WI-29-7 (NavigationLink/Link regex audit). The Button-`{` widening exposes a remaining trigger-alternation gap on `NavigationLink {` and `Link(...)` — both forms appear in AppViews.swift and ForecastPickerView.swift and are currently SwiftLint blind spots.
2. **Documentation gap:** WI-29-6 (ADR-0002 needs one-paragraph iOS-26.4 extension subsection documenting the Image-frame requirement discovered in PR #99).
3. **Toolbar-specific rule:** WI-29-4 (`toolbar_image_needs_scaled_frame`) — the general `missing_min_touch_target` rule cannot see inside `.toolbar { ... }` Image label closures.
4. **Physical-device sign-offs (Goal 5):** Still blocked on owner access to OLED iPhone + WCAG measurement tool. Both checklists carry the WI-21 automation-status section explaining this is non-CI-completable.

## Files touched this iteration

- `app/Sources/UVBurnTimer/AppViews.swift` (WI-loop28-4, WI-loop29-2)
- `app/Sources/UVBurnTimer/ForecastPickerView.swift` (WI-loop29-2)
- `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift` (WI-loop28-4)
- `app/Tests/UVBurnTimerCoreTests/MainScreenCleanupContractTests.swift` (WI-loop29-2)
- `.swiftlint.yml` (WI-loop29-2)
- `.squad/decisions.md` (Scribe hygiene)
- `.squad/decisions/inbox/*.md` (4 deleted by Scribe hygiene)
- `.squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md` (WI-loop28-4 line-citation refresh)
- `.squad/agents/kwame/history.md` (WI-loop28-4 learnings)

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
