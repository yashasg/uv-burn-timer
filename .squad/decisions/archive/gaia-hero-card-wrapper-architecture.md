# Gaia — SwiftUI view-struct identity preserves toolbar hit-test (HeroTimerCard wrapper) ADR

- **Date:** 2026-05-21T11:30:00Z
- **Owner:** Gaia (Lead/Architect)
- **Status:** **RATIFIED** — captures the architectural lesson surfaced by the
  hero-card-wrapper-restore cycle (PR #19, commit `f74ce6f`, merged to
  `github/main` as `8f2f16d` on 2026-05-21T10:29:48Z). Closes WI-l from the
  end-of-loop review pass logged in
  `.squad/log/2026-05-21T10-30-00Z-hero-card-wrapper-restore-cycle.md`.
- **Reviewer:** Iris (UX impact), Ma-Ti (R-group guard coverage),
  Kwame (call-site implementation)

## Decision

Any SwiftUI view whose parent owns one or more presentation-affecting
modifiers — specifically `.toolbar { ... }` paired with `.sheet(isPresented:)`,
`.fullScreenCover(isPresented:)`, `.alert(isPresented:)`, or
`.popover(isPresented:)` — **must** keep its substantial child content in
dedicated `struct ...: View` types rather than inlining the bodies into the
parent as `private var ...View: some View` computed properties.

In concrete terms: `RootView`'s hero card content lives in
`struct HeroTimerCard: View` and is invoked from
`RootView.heroTimerCardView` as `HeroTimerCard(...)`. Inlining the body of
that struct into the `private var heroTimerCardView: some View` computed
property is **prohibited** even when the inlined version "looks equivalent"
from a layout/styling perspective.

This applies to all child views that exceed roughly one VStack of nested
content, not just `HeroTimerCard`. The same trade-off should be audited
for `uvIndexCardView` and `forecastPickerCardView` (tracked as WI-m).

## Why this is the right default

1. **Toolbar hit-test depends on view identity.** SwiftUI resolves which
   view a tap belongs to via a structural identity diff. The toolbar's
   `gearshape` Button is owned by `RootView` and its `.sheet` modifier is
   attached to `RootView`. When `HeroTimerCard`'s body was inlined as a
   `private var ...View: some View`, the structural identity boundary
   between the two collapsed: SwiftUI began treating the entire hero card
   tree as part of `RootView`'s body, which scrambled the hit-test envelope
   resolution for the toolbar Button and the presentation-slot resolution
   for `.sheet(isPresented: $showSettings)`. The tap arrived at the
   Button but the `isPresented` flip did not propagate to a `.sheet`
   activation. Result: `testSettingsSheetOpens` started failing in XCUI.
2. **The bug was invisible until tested by XCUI.** No unit test, no
   manual run, no SwiftUI preview surfaced the regression. It only
   appeared when `XCUIElement.tap()` on the gear icon failed to bring up
   the Settings sheet. This is exactly the class of regression that the
   shipped XCUI smoke suite exists to catch — but it is also a class of
   regression that we cannot expect a refactoring engineer to anticipate
   from reading the diff. The wrapper is therefore a load-bearing
   architectural invariant, not a stylistic preference.
3. **Identity-stable view boundaries are an explicit SwiftUI contract.**
   Apple's SwiftUI documentation (and the WWDC '21 talk *"Demystify SwiftUI"*)
   establishes that the structural identity of view types is the
   diff/update boundary the framework relies on for animation, transition,
   state preservation, and gesture/hit-test routing. The framework is
   under no obligation to treat an inlined `some View` computed property
   identically to a `struct ...: View` extraction even when the rendered
   tree looks identical at the pixel layer.
4. **Inlining provided no measurable benefit.** The original motivation
   for `9da54cf` was "the circular gauge stands alone as the main-screen
   primary." That UX intent is preserved by the restored wrapper: the
   wrapper now omits the card chrome (`.padding(24)`, `.regularMaterial`,
   `cornerRadius: 24`) and the `Burn-time estimate` title row. The
   architectural shape (struct) is decoupled from the visual shape
   (no chrome), so we keep the UX intent and the framework contract.

## Trade-offs

1. **Slight verbosity.** A 3- to 12-line view body must live in a typed
   struct rather than a computed property. The cost is at most one extra
   `struct ...: View {` line per extraction plus an `init` if any state
   is captured.
2. **Forgetting to extract is a real risk.** SwiftUI does not warn us
   when an inlined `some View` would have been safer as a struct, and
   neither does Xcode. We mitigate via the R-group guard tests in
   `BurnTimeCalculatorTests.swift` (R1, R2) which fail at the source-text
   level if `HeroTimerCard` is collapsed or its call-site is removed
   from `RootView`. The XCUI `testSettingsSheetOpens` smoke test
   provides a second, behavioral check.
3. **The same trade-off may exist elsewhere.** WI-m tracks the audit
   of `uvIndexCardView` and `forecastPickerCardView`. Until that audit
   completes, those two surfaces could harbor the same latent regression.

## Guardrails

The following invariants pin this decision in source. Any failure should
block the merge.

| ID | Location | Check |
|----|----------|-------|
| R1 | `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift` | `struct HeroTimerCard: View` literal appears in `app/Sources/UVBurnTimer/AppViews.swift` |
| R2 | same file | `HeroTimerCard(` constructor call appears in `app/Sources/UVBurnTimer/AppViews.swift` |
| XCUI | `app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift` (`testSettingsSheetOpens`) | tapping the toolbar `gearshape` Button opens the Settings sheet |

These three guards together close the loop: a future engineer who tries
to inline `HeroTimerCard` for either stylistic or "performance" reasons
will see two unit-test failures (R1/R2) at compile-time-of-tests, plus a
behavioral XCUI failure if the unit failures are somehow waived. The
failure messages cite this ADR by name in their `#expect` messages.

## Alternatives considered

1. **Inline `HeroTimerCard` into `RootView` and accept the XCUI
   regression.** Rejected: the regression is a real user-visible bug
   (toolbar gear icon visibly does nothing). No UX win compensates for
   it.
2. **Move the toolbar definition into `HeroTimerCard` instead of
   `RootView`.** Rejected: the Settings sheet is a `RootView`-level
   concern (it surfaces app-wide settings, not hero-card settings). The
   toolbar belongs to the screen, not to the card. Relocating it would
   bend the IA to fit a SwiftUI workaround.
3. **Replace `.sheet(isPresented:)` with a manual presentation manager
   (e.g., a state-machine + `.overlay`).** Rejected: solves the wrong
   problem. The presentation API works; it is the view identity boundary
   that was violated.
4. **Add a SwiftUI `.id(_:)` modifier or `EquatableView` wrapper to
   force re-identity.** Rejected: brittle, depends on framework
   undocumented behavior, and would have to be re-discovered for every
   future inlined view. The struct extraction is the documented contract.

## Audit scope (WI-m follow-up)

The following currently-shipped inlined views in `app/Sources/UVBurnTimer/AppViews.swift`
should be reviewed by the next cycle's owner against the same criteria:

- `RootView.uvIndexCardView` — currently inlined; renders the secondary
  UV index summary. Owns no presentation modifiers itself but lives
  alongside the toolbar Button, so any future addition of a chrome layer
  could trigger the same regression class.
- `RootView.forecastPickerCardView` — currently inlined; renders the
  10-day forecast picker. Same condition as above.

Both are LOW-risk right now because their content is simpler than the
hero card and they do not own a `.sheet`/`.fullScreenCover` of their own.
WI-m will determine whether to pre-emptively extract them.

## Files touched by this ADR

This ADR is documentation-only and does not modify any source.
The architectural invariant it captures is enforced by:

- `app/Sources/UVBurnTimer/AppViews.swift` — `HeroTimerCard` struct and
  its `RootView.heroTimerCardView` call-site (the load-bearing wrapper)
- `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift` —
  R-group guard tests (R1 through R6)
- `app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift` —
  `testSettingsSheetOpens` behavioral check

## References

- Cycle log: `.squad/log/2026-05-21T10-30-00Z-hero-card-wrapper-restore-cycle.md`
- Regressing commit: `9da54cf` (`refactor(ui): remove HeroTimerCard wrapper`)
- Fix commit: `f74ce6f` (`fix(ui): restore HeroTimerCard wrapper without chrome`)
- PR: #19 (squash-merged as `8f2f16d`)
- Apple guidance: *"Demystify SwiftUI"*, WWDC '21 (structural identity
  and view-tree diffing)
