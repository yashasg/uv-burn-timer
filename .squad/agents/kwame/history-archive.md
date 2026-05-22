# Kwame — History Archive

Archived entries from earlier cycles:

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


