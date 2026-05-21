# ADR-0002: Use `.topBarTrailing` instead of `.primaryAction` for toolbar buttons on iOS 26+

- **Status:** Accepted (2026-05-22)
- **Author:** Squad (Loop-13)
- **Work item:** WI-loop13-toolbar-ios26-hittability
- **Supersedes:** _none_
- **Superseded by:** _none_
- **Related:** [ADR-0001](./ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md)
  (the parent identity contract for the same toolbar)

## Context

`RootView` in `app/Sources/UVBurnTimer/AppViews.swift` owns the main
screen's `.toolbar { ... }` block. The toolbar carries two items:

1. The Settings gear (`gearshape`) button that toggles `$showSettings`.
2. The `EstimateInfoButton` (ⓘ) that pushes `AboutView`.

Through Loop-12 both items were declared as
`ToolbarItem(placement: .primaryAction) { ... }`. That worked on the
Xcode 15 / iOS 17 toolchain the project was originally pinned to.

After the Xcode 26 toolchain bump (iOS 26 SDK) SwiftUI's navigation bar
adopted the **Liquid Glass** rendering treatment. Under that treatment,
items declared with `placement: .primaryAction` are composited into a
glass-effect region whose hit-test geometry is reported back to XCUI as
**not hittable**: `XCUIElement.isHittable` returns `false` even though
the button is visually present, animates on tap in manual testing, and
appears in the accessibility tree.

Two XCUI tests regressed deterministically against the iOS 26 simulator:

- `testSettingsSheetOpens` — tapping the gear no longer presented the
  Settings sheet (XCUI tap was dispatched to a hittable=false element).
- `testToolbarRendersBothSettingsAndEstimateInfoButtons` — the same
  hittability assertion failed for the gear, and intermittently for the
  ⓘ button depending on layout order.

The regression is **not** an identity-collapse bug of the ADR-0001
class — `HeroTimerCard` is still its own `View` struct, and the
toolbar/sheet modifiers are still attached at `RootView`'s identity.
The change is purely in how iOS 26 composites the `.primaryAction`
slot.

`.topBarTrailing` (and its companion `.topBarLeading`) declare the
items into the classic trailing region of the navigation bar, which
on iOS 26 is rendered with hit-test geometry that XCUI can target.
The visual result is indistinguishable from `.primaryAction` for our
two-button case; only the underlying placement-slot resolution
differs.

## Decision

### Rule (positive form — MUST)

Toolbar items on `RootView`'s `.toolbar { ... }` MUST use
`ToolbarItem(placement: .topBarTrailing) { ... }`, not
`.primaryAction`. The same applies to any future toolbar item added to
a navigation bar in this app while the deployment target includes
iOS 26+.

### Declaration order ↔ horizontal position

With multiple `.topBarTrailing` items, **declaration order determines
horizontal position: the item declared first is rendered rightmost.**
The current order is therefore:

1. **Settings gear** (`gearshape`) — declared first → rendered
   **rightmost** (the corner position users reach for first).
2. **`EstimateInfoButton`** (ⓘ) — declared second → rendered to the
   left of the gear.

This order matches the Iris-approved visual spec: gear in the corner,
info to its left.

### Anti-pattern (negative form — MUST NOT)

Toolbar items on `RootView` MUST NOT use
`ToolbarItem(placement: .primaryAction) { ... }`. The Liquid Glass
composition path on iOS 26 reports those items as
`isHittable == false` to XCUI even when they render and respond to
real-finger taps, which makes the toolbar untestable end-to-end.

## Consequences

### Pro

- **Deterministic XCUI hittability.** Both toolbar buttons report
  `isHittable == true` on the iOS 26 simulator, restoring
  `testSettingsSheetOpens` and
  `testToolbarRendersBothSettingsAndEstimateInfoButtons` to green.
- **Stable visual spec.** The user-visible layout is identical to the
  pre-iOS-26 `.primaryAction` rendering for our two-button case
  (gear in the corner, ⓘ to its left).
- **Forward-compatible.** `.topBarTrailing` is the explicit,
  documented placement for trailing nav-bar items and is not
  earmarked for any Liquid Glass-style re-composition.

### Con

- **Declaration-order coupling.** The "first declared is rightmost"
  rule is implicit in the modifier chain; a future contributor
  reordering the `ToolbarItem` blocks would silently swap the on-
  screen position of the gear and ⓘ. Contract test **S4** (below)
  guards the placement enum but not the order; the visual order is
  guarded by the existing `testToolbarRendersBothSettingsAndEstimateInfoButtons`
  XCUI test, which queries the gear first and then the ⓘ.

### Operational

- Enforced by a source-text contract test in
  `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift`:
  - **S4** —
    `test_S4_toolbarGearButtonUsesTopBarTrailingNotPrimaryAction`
    asserts that `AppViews.swift` contains no
    `ToolbarItem(placement: .primaryAction)` declaration and that
    the gear/ⓘ items both use `.topBarTrailing`.
- ADR-0001's identity contract (R1, R2) is **unchanged** — the
  `HeroTimerCard` struct boundary remains required, independently of
  this ADR. ADR-0002 layers on top of ADR-0001: the toolbar must
  *both* attach to a stable parent identity (ADR-0001) *and* use
  the iOS-26-hittable placement enum (this ADR).

## Alternatives considered

1. **Keep `.primaryAction` and add `isHittable == true` workarounds in
   the XCUI tests** (e.g. force-tap by coordinate, or wait/retry on
   hittability).
   **Rejected.** iOS 26's Liquid Glass rendering of `.primaryAction`
   is intentional Apple behavior, not a bug we should paper over with
   test-only workarounds. Hittability is the contract XCUI is meant
   to enforce; defeating it would also defeat manual accessibility-
   audit tooling that relies on the same hit-test geometry.

2. **Move toolbar items off the nav bar entirely** (e.g. into a
   `.safeAreaInset(edge: .top)` custom bar).
   **Rejected.** Re-implements the nav bar from scratch and loses
   `NavigationLink` integration for the ⓘ → `AboutView` push route.
   Disproportionate cost for what is essentially a one-line
   placement-enum change.

3. **`.navigationBarTrailing`** (the pre-iOS-14 spelling, still
   available as a deprecated alias).
   **Rejected.** Deprecated; emits a warning under the project's
   warnings-as-errors flag and would break `./build.sh`.
   `.topBarTrailing` is the modern equivalent.

## References

- `app/Sources/UVBurnTimer/AppViews.swift`
  - `RootView.toolbar { ... }` block — declares both
    `ToolbarItem(placement: .topBarTrailing)` items (gear first,
    ⓘ second).
- `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift`
  - `test_S4_toolbarGearButtonUsesTopBarTrailingNotPrimaryAction`
    — Group S4 source-text guard.
- XCUI tests restored to green by this change:
  - `testSettingsSheetOpens`
  - `testToolbarRendersBothSettingsAndEstimateInfoButtons`
- PR / branch:
  - PR **#57** — `WI-loop13: toolbar `.primaryAction` → `.topBarTrailing` for iOS 26 hittability`
  - Branch `squad/wi-loop13-toolbar-ios26-hittability`
- Related ADR:
  - [ADR-0001](./ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md)
    — the parent identity contract that this ADR layers on top of.
    ADR-0001 ensures the toolbar attaches to a stable parent identity
    (so taps dispatch to the right binding); ADR-0002 ensures the
    placement enum produces a hit-testable geometry (so taps reach
    the dispatcher at all). Both must hold for the toolbar to be
    reliable.

## Audit

When adding a new toolbar item to any navigation bar in the app
(`RootView` or a future screen), the author must:

1. Use `ToolbarItem(placement: .topBarTrailing)` (or `.topBarLeading`
   for leading items). Do not introduce `.primaryAction`.
2. If adding alongside existing items, place the new declaration in
   the order that matches the desired left-to-right visual layout —
   recall that first-declared = rightmost.
3. Confirm S4's guard still passes after the change; extend S4 to
   cover the new item if the new screen lives outside `RootView`.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
