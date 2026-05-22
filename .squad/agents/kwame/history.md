# Kwame — History (Summarized)

**Latest Status (2026-05-22T03:32:09-07:00):** Loop-26 closure complete. PR #98 merged as a8b1ac8. SwiftLint HIG hard-gate live on main. Applied Iris playbook across 3 commits (66cc6c9 TDD, a643523 FPV, 174be71 AV). All 31 violations resolved (13 FPV + 18 AV). CI green. Post-merge audit PASS-WITH-NOTES.

**Previous Status (2026-05-21T04:40:00Z):** Main screen cleanup (K-1 through K-11) shipped. Removed photosensitization banner, added ⓘ toolbar button, flattened PersistentFooter, simplified status messages. Build: clean, 114 unit tests passing.

---

## Key Implementations

### Loop-26 HIG Cleanup (PR #98)

**Commits:**
- **66cc6c9** — TDD group R guards (MainScreenCleanupContractTests.swift) — 5 source-text contracts (R1–R5) pinning @ScaledMetric presence and literal absence
- **a643523** — ForecastPickerView.swift HIG cleanup (FPV-1 through FPV-13) — 15 @ScaledMetric identifiers, all 13 violations resolved
- **174be71** — AppViews.swift HIG cleanup (AV-1 through AV-18) — 5 struct @ScaledMetric declarations, all 18 violations + navigation_stack_in_sheet fixed

**Playbook fidelity:** All FPV/AV sections implemented faithfully. 4 additional swiftlint:disable comments added (AV-12, 13, 15, 16) — justified by 200-char regex lookahead constraint, not HIG softening. Pre-existing out-of-scope chip/footer literal minHeight:44 sites deferred as Loop-27 WI-1.

### Main Screen Cleanup (WI prior)

**K-1 through K-11 shipped:**
- K-1: Removed `photosensitizationBanner` (37-line computed property)
- K-2: Added ⓘ toolbar button with NavigationLink to AboutView
- K-6: Flattened `PersistentFooter` to pure NavigationLink
- K-7/K-8/K-9: Removed verdict caveats, simplified location rationale
- K-10/K-11: Added `aboutSunSafetyActions` constants to satisfy Plunder C2

**Test integration:** Groups N–Q (8 new tests) guard main screen cleanup contracts. Source-text guards (@filePath + grep) used for cross-target verification.

---

## Learnings

### SwiftLint Implementation (Loop-26)

- **User directive superseded Iris's softer policy:** hard-error day 1, no grace period, no literal exceptions. All HIG layout/touch/typography rules at `severity: error` from day 1.
- **@ScaledMetric backing required:** `missing_min_touch_target` no longer accepts literal minHeight:44/56. Regex heuristic checks for nearby `.frame(...minWidth|minHeight: someIdentifier)` — pragmatic proxy for @ScaledMetric, not proof.
- **200-char regex lookahead is a real constraint:** Multi-line Button bodies push `.frame()` past the window. Justified disable comments with prose explanation required.
- **Loop-28 follow-ups identified:** (1) Residual literal minHeight:44 at AppViews:295/315/337/2135 in Button/Menu/NavigationLink wrappers. (2) ForecastPickerView header minHeight:28. (3) Semantic-font vs. ScaledMetric choice needs annotation. (4) Schedule swift-syntax AST replacement for missing_min_touch_target. (5) Line-number-fragile tests need symbol anchors.

### Main Screen Cleanup (WI prior)

- **Avoid redeclaration errors:** grep for constant names before adding ProductCopy.swift entries.
- **Toolbar placement:** `.primaryAction` (far trailing) + `.topBarTrailing` coexist cleanly; ⓘ sits left of gear button.
- **LocationRationaleCard removal logic:** When app requests only approximate location (kCLLocationAccuracyReduced), OS dialog is self-explanatory. In-app rationale card adds UX friction with no privacy benefit.

---

## 2026-05-22: Loop-26 closure — PR #98 merged (a8b1ac8)

SwiftLint HIG hard-gate wired and live on main. All 31 violations resolved (FPV 13 + AV 18). Issues #95/#96 closed. Post-merge audit PASS-WITH-NOTES (5 structural rule-coverage gaps deferred to Loop-28+). Privacy Policy hosting and physical-device sign-offs remain user-owned blockers.

**Commits:** 66cc6c9 (TDD), a643523 (FPV), 174be71 (AV) → merged as a8b1ac8

---

## 2026-05-22T12:35:00Z: Loop-28 WI-0 — RootView toolbar @ScaledMetric floor (AV-19/AV-20)

Fixed three regressed XCUITests on Xcode 26.4 / iPhone 17 Pro / iOS 26.4:
`testEstimateInfoButtonOpensAboutWithHighlightedApplicabilityAnchor`,
`testEstimateInfoNavigationRoundTripReturnsToMainScreen`,
`testSettingsSheetOpens`.

**Root cause.** PR #98 (AV-1..AV-18) gave virtually every Button in the
app a `@ScaledMetric private var minTap` + `.frame(minHeight: minTap)`
HIG floor — except the two RootView toolbar items (gear `Button` and
`EstimateInfoButton` `NavigationLink`), whose labels are just a single
SF Symbol `Image`. On iOS 26.4 Liquid Glass nav-bar treatment, a
toolbar item with only a ~22 pt Image label is composited with a
hit-test rectangle so tight that `XCUIElement.isHittable` returns
false. ADR-0002's prior fix (`.primaryAction` → `.topBarTrailing`) is
necessary but, on iOS 26.4, no longer sufficient. Iris's GAP-2/GAP-3
(Loop-28+) already noted that `missing_min_touch_target` doesn't cover
`NavigationLink` or trailing-closure `Button` forms — these two
toolbar items are exactly that blind spot.

**Fix.** Two minimum-diff edits to `AppViews.swift`:

- **AV-19** — added `@ScaledMetric private var minTap: CGFloat = 44`
  to `struct RootView` (with an explanatory comment + LT test
  reference).
- **AV-20** — applied `.frame(minWidth: minTap, minHeight: minTap)`
  to the gear `Image(systemName: "gearshape")` and the
  EstimateInfoButton `Image(systemName: "info.circle")`.

**TDD discipline.** Wrote Group LT (Loop-Twenty-eight) source-text
contract tests in `MainScreenCleanupContractTests.swift` first
(LT1/LT2/LT3), confirmed RED, then applied AV-19/AV-20. LT1 anchors
specifically to RootView's body via a substring-bounded slice
(struct-opener → next `\nstruct `) — the pre-existing R1 guard at
file-level was insufficient because it didn't scope to the
declaring struct.

**ADR-0001 drift.** `test_S5_adr0001CitationsMatchLiveSourceLineNumbers`
fired after the fix shifted every downstream line in `AppViews.swift`
by ~2 lines (AV-19 declaration + .frame additions). Refreshed all
References + Addendum + worked-example line citations and added a
Loop-28 WI-0 line-number-refresh paragraph at the bottom of the
References section to keep the audit trail intact.

**AV-9 red herring.** The original prompt hypothesised that PR #98's
`.sheet`→`.fullScreenCover` swap in `DisclaimerCover` was the cause.
It is not — that cover is internal to `DisclaimerCover`'s "see About"
link and never on the failing tests' path (they acknowledge the
disclaimer first). Kept `.fullScreenCover` as-is.

**Verification.** Core unit suite green (incl. LT1/LT2/LT3 + S5
refreshed citation gate). All originally-failing UI tests pass
individually and on re-run in the full UI suite. Suite-level
"TEST FAILED" exit remains attributable to the documented
IOHIDLib.kext arch-mismatch flake (`have x86_64,arm64e need arm64`)
that occasionally restarts the test runner mid-suite — orthogonal to
this fix.

**Files touched:**
- `app/Sources/UVBurnTimer/AppViews.swift` — AV-19/AV-20.
- `app/Tests/UVBurnTimerCoreTests/MainScreenCleanupContractTests.swift`
  — Group LT (LT1/LT2/LT3).
- `.squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md`
  — line-citation refresh + Loop-28 WI-0 audit-trail paragraph.
- `.squad/decisions/inbox/kwame-loop28-wi0-ui-test-fix.md` — decision
  drop for Iris.

### Learnings (added to ## Learnings)

- **iOS 26.4 Liquid Glass extends ADR-0002's hittability concern.**
  `.topBarTrailing` is necessary but not sufficient: any toolbar item
  whose label is just an `Image` needs a `@ScaledMetric` 44 pt frame
  on the inner `Image` to keep `XCUIElement.isHittable` true.
- **@ScaledMetric floor must cover every Button-shaped control,
  including `NavigationLink` and toolbar `Button { Image(...) }`
  forms.** Iris's GAP-2/GAP-3 was right; we paid the bill in Loop-28.
- **Source-text contract tests must anchor to the declaring struct,
  not file-level.** Non-greedy regex `[\s\S]*?` still matches into
  sibling structs and silently passes; a substring slice between the
  struct opener and the next `\nstruct ` is the correct primitive.
- **ADR line-citation drift is detected by `test_S5_*` — refresh it
  whenever AppViews.swift grows.** A two-line drift was enough to red
  the suite.


### 2026-05-22T13:30Z: Loop-28 WI-0 shipped via PR #99 (521bc82)

**Outcome:** AV-19/AV-20 + Group LT (LT1/LT2/LT3) all green on main. ADR-0001 line citations refreshed. RootView toolbar @ScaledMetric touch-target floor now load-bearing for iOS 26.4 Liquid Glass hittability (ADR-0002 extension).

**Verification:** Core unit suite (UVBurnTimerCoreTests) green, UI suite all three originally-failing tests pass. SwiftLint strict gate 0 violations. Warnings-as-errors clean.

**Learnings:**
- iOS 26.4 Liquid Glass hittability model extends beyond `.topBarTrailing` — inner `Image` label must carry `@ScaledMetric` frame.
- Two-line drift in AppViews.swift triggers S5 ADR-citation test — maintain discipline on line-number refresh.
- Group LT precedent established for toolbar/Image-label test pattern; candidate for ADR-0002 Audit section as recurring guard.

## 2026-05-22T13:00:00Z: Loop-28 WI-1 — chip/footer @ScaledMetric migration

Closed Iris's Loop-26 post-merge audit item: the four pre-existing
literal `minHeight: 44` sites in `AppViews.swift` that PR #98's
`missing_min_touch_target` SwiftLint rule did not flag because its
regex anchors on `\bButton\s*(` at the call site and never sees
literals nested inside Button / Menu / NavigationLink **label**
closures.

**Sites migrated to `@ScaledMetric`-backed `minTap`:**

- `RootView.locationChip`    (line 310) — Button label `.frame(maxWidth: .infinity, minHeight: minTap)`
- `RootView.spfChip`         (line 330) — Menu  label `.frame(maxWidth: .infinity, minHeight: minTap)`
- `RootView.skinTypeChip`    (line 354) — Button label `.frame(maxWidth: .infinity, minHeight: minTap)`
- `PersistentFooter` Label   (line 2153) — `.frame(minHeight: minTap, alignment: .leading)`

`RootView` already declared `@ScaledMetric private var minTap: CGFloat = 44`
(Loop-28 WI-0 / AV-19), so the three chip sites needed only a literal-
→-identifier swap. `PersistentFooter` is its own top-level struct and
received a new `@ScaledMetric private var minTap: CGFloat = 44` declaration
with an explanatory `// MARK: - HIG @ScaledMetric tokens` comment.

**TDD discipline.** Wrote Group LU (LU1/LU2/LU3/LU4/LU5) in
`MainScreenCleanupContractTests.swift` first, confirmed RED on
xcodebuild (5 failed assertions across 5 tests), then applied the
four source edits. LU1-LU3 slice each chip's computed-property body
and assert `.frame(maxWidth: .infinity, minHeight: minTap)` is
present. LU4 slices `struct PersistentFooter`'s body and asserts both
the declaration and the `.frame(minHeight: minTap, alignment:
.leading)` site. LU5 is the file-wide zero-literal-`minHeight: 44`
guard, replacing the narrowed Loop-26 R2 (which only forbade the
literal on the DisclaimerCover "I understand" CTA). R2 is deleted —
not broadened — for clarity; the inline `// R2 — REMOVED in Loop-28
WI-1` comment block preserves the audit trail and points readers to
LU5.

**Collateral test repairs (one file each):**

- `test_EJ4_persistentFooterMeetsHIG44ptHitTarget`
  (`BurnTimeCalculatorTests.swift`) — bumped the per-site contract
  from the literal `.frame(minHeight: 44` to the `@ScaledMetric`-
  backed `.frame(minHeight: minTap` and added a positive guard on
  the new struct-scoped `@ScaledMetric` declaration. The pre-Loop-28
  EJ4 was the only test that hard-coded the literal `44` at the
  footer site and would otherwise red after the migration.

- `test_S5_adr0001CitationsMatchLiveSourceLineNumbers` — addressed
  predictable ADR drift. The `PersistentFooter` `AboutView` push
  moved from line **2133** → line **2144** (+11 lines for the new
  `@ScaledMetric` block + MARK comment). Refreshed two ADR-0001
  citations (the References § bullet and the worked-example block at
  lines 296–298) and appended a `**Loop-28 WI-1 — line-number
  refresh (chip/footer `minTap` migration):**` paragraph to the
  Loop-28 audit-trail section so the next reader can reconstruct the
  drift. Chip line numbers (301 / 320 / 339) did not shift; only
  PersistentFooter and everything after it did.

**Verification.** `./build.sh` GREEN end-to-end on Xcode 26.4 /
iPhone 17 Pro / iOS 26.4: Debug build clean, 307 core unit tests
pass (2 pre-existing `forecast_picker_logic` known issues, both
predate Loop-28 and are orthogonal), 9 UI tests pass, Release build
clean, all with `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES` /
`-warnings-as-errors`. SwiftLint strict 0 violations (no rule
delta — the four sites passed SwiftLint baseline pre-migration too).

**Files touched:**

- `app/Sources/UVBurnTimer/AppViews.swift` — four `.frame(...minHeight: 44)`
  → `.frame(...minHeight: minTap)` swaps + `PersistentFooter` gained
  `@ScaledMetric private var minTap: CGFloat = 44` with MARK comment.
- `app/Tests/UVBurnTimerCoreTests/MainScreenCleanupContractTests.swift`
  — Group LU (LU1/LU2/LU3/LU4/LU5) added; R2 removed (replaced by an
  inline audit-trail comment).
- `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift` —
  `test_EJ4_persistentFooterMeetsHIG44ptHitTarget` updated to assert
  the `minTap`-shaped contract.
- `.squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md`
  — PersistentFooter line citations refreshed (2133 → 2144 in two
  places) + Loop-28 WI-1 audit-trail paragraph appended.
- `.squad/decisions/inbox/kwame-loop28-wi1-chip-footer-mintap.md` —
  decision drop for Iris/Scribe.

### Learnings (added to ## Learnings)

- **`@ScaledMetric` floor at every literal site is not a free
  micro-refactor — it shifts every downstream source line.**
  PersistentFooter gained 11 lines; `test_S5_…` red-fires unless the
  ADR is refreshed in the same commit. Treat ADR line-citation
  refresh as part of the migration, not a follow-up.
- **SwiftLint `missing_min_touch_target` has a known label-closure
  blind spot:** the regex `\bButton\s*(` matches the call site but
  not literals nested inside the `} label: { ... .frame(...minHeight:
  44) }` body — that's how four real Dynamic-Type-scaling debts
  survived PR #98's 0-violations gate. File-wide source-text guards
  (LU5-style `minHeight:\s*44\b` regex over the whole file) cover
  exactly this blind spot until a swift-syntax AST replacement for
  `missing_min_touch_target` lands.
- **Prefer deleting narrowed guards over broadening them when a
  file-wide guard subsumes them.** R2's narrowed scope (single CTA)
  made it tempting to keep around as a "specific" safety net, but
  the per-site positive guards LU1-LU4 + the file-wide LU5 fully
  cover R2's intent without leaving a guard whose name no longer
  describes its job. Inline `// X — REMOVED in Loop-Y` comment
  blocks preserve the audit trail without code clutter.
