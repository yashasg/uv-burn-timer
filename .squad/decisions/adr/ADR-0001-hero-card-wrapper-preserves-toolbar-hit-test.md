# ADR-0001: Hero card wrapper preserves toolbar hit-test

- **Status:** Accepted (2026-05-21)
- **Author:** Gaia (Lead / Architect)
- **Work item:** WI-l
- **Supersedes:** _none_
- **Superseded by:** _none_

## Context

`RootView` in `app/Sources/UVBurnTimer/AppViews.swift` is the main-screen
parent: it owns the `NavigationStack`, the `.toolbar { ... }` block that
hosts the `gearshape` button, and the `.sheet(isPresented: $showSettings)`
modifier that presents the Settings sheet. The hero card (UV verdict +
circular burn-time gauge + caveat link) is the most visually-prominent
child of that parent.

In the 8th-loop cycle (logged in
`.squad/log/2026-05-21T10-30-00Z-hero-card-wrapper-restore-cycle.md`),
commit `9da54cf` ("refactor(ui): remove HeroTimerCard wrapper — circular
gauge stands alone as main-screen primary") inlined the entire
`HeroTimerCard` body into `RootView` as a `private var heroTimerCardView:
some View` computed body. The user-visible intent of the refactor — drop
the card chrome (`.padding(24)`, `.regularMaterial`,
`cornerRadius: 24`) and the "Burn-time estimate" header label so the
gauge stands alone — was correct and approved.

The structural side-effect was not. After the inline, XCUI
`testSettingsSheetOpens` regressed deterministically: tapping the
toolbar's `gearshape` button no longer presented the Settings sheet.
Reproducer trace:

1. Commit `9da54cf` (inlined hero, no struct boundary) → XCUI
   `testSettingsSheetOpens` **fails**.
2. Commit `f74ce6f` (hero re-extracted into `struct HeroTimerCard:
   View` — chrome still removed, header still gone) → XCUI
   `testSettingsSheetOpens` **passes**.
3. Squash-merged to `main` as `8f2f16d` via PR #19.

### Why SwiftUI behaves this way

A `private var ...View: some View` computed property does **not**
introduce a new view-struct identity — it is body-flattened into the
parent's `body` at compile time. The `.toolbar { ... }` and
`.sheet(isPresented:)` modifiers attached to that parent are bound to
the parent's presentation-slot resolver, which is keyed on the parent's
identity-diff signature.

When the hero card was inlined, the parent's identity-diff signature
grew to include all of the hero's state-dependent subtree. The toolbar
hit-test envelope (computed against the parent's identity) and the
sheet's presentation slot (also keyed to that identity) both
re-resolved on every hero-state change, scrambling the dispatch route
from the toolbar Button's tap target to the `$showSettings` binding.
Re-introducing `struct HeroTimerCard: View` re-isolated the hero's
identity diff from RootView's, restoring deterministic toolbar
hit-testing and sheet presentation.

`NavigationStack` does not substitute for this boundary: `RootView`
already wraps its content in `NavigationStack` (see
`AppViews.swift:99`), and the bug still reproduced. The required
boundary is a **distinct `View` struct** for the heavy child, not a
container modifier.

## Decision

### Rule (positive form — MUST)

When a parent `View` owns both a `.toolbar { ... }` modifier and a
`.sheet(isPresented:)` (or any presentation modifier whose binding
lives on the parent), any **complex child content** rendered inside
that parent's `body` MUST be extracted into its own `View` struct
(e.g. `struct HeroTimerCard: View { ... }`) and invoked from the
parent via its constructor (`HeroTimerCard(...)`).

"Complex" here means: contains its own `@State`, owns gesture handlers,
re-renders independently of the parent on data updates, or runs to more
than a small handful of lines. The hero card meets every one of those.

### Anti-pattern (negative form — MUST NOT)

A parent that owns `.toolbar { ... }` + `.sheet(isPresented:)` MUST
NOT inline a 100+-line `private var fooBody: some View` computed
property containing complex child content. Doing so collapses the
child's identity diff into the parent's, scrambling the toolbar's
hit-test envelope and the sheet's presentation-slot resolution. The
fact that the code _compiles and runs_ is not evidence of correctness —
the regression manifests only at XCUI dispatch time.

### Permitted lightweight inlining

Small, presentation-only fragments (a `Label`, an `HStack` with two
text items, a divider, etc.) that do not own state or gestures MAY
remain as `private var ...View: some View` computed properties on the
parent. The identity-collapse problem only bites for subtrees heavy
enough to materially change the parent's diff signature.

## Consequences

### Pro

- **Deterministic XCUI hit-test.** Toolbar buttons and sheet bindings
  on the parent resolve against a stable identity that does not
  depend on the hero card's render cycle.
- **No presentation-slot scramble.** `.sheet(isPresented:)`,
  `.popover(...)`, `.alert(...)` on the parent stay attached to the
  parent's slot table; child re-renders do not invalidate them.
- **Easier diffing.** PR reviewers can isolate hero-card changes from
  RootView chrome changes. The struct boundary doubles as a review
  boundary.
- **Re-mountable.** The child can be reused (e.g. previews, alternate
  layouts) without dragging RootView's modifier chain along.

### Con

- **Extra struct boilerplate.** Every input the parent passes to the
  child must be declared as a `let` (or `@Binding`) property on the
  child struct and re-listed at the call site.
- **No direct `@State` sharing.** The child cannot reach into the
  parent's `@State` — state that must round-trip (e.g.
  `$showSettings`) has to be promoted to `@Binding` or hoisted to a
  shared `@StateObject` / `@Observable` model.
- **Marginal type-checker cost.** Each new `View` struct adds a small
  amount of generic-parameter inference work; in this codebase the
  effect is negligible.

### Operational

- Enforced in source by two contract tests in
  `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift`:
  - **R1** — `test_R1_heroTimerCardWrapperStructStillExists` asserts
    that the literal `struct HeroTimerCard: View` declaration survives
    in `AppViews.swift`.
  - **R2** — `test_R2_rootViewDelegatesToHeroTimerCardConstructor`
    asserts that `RootView.heroTimerCardView` instantiates
    `HeroTimerCard(...)` via its constructor (i.e. is not re-inlined as
    a raw `VStack { ... }` body).
- Both tests live in the only test file currently wired into
  `app.xcodeproj`, so they run on every CI invocation of
  `./build.sh`. After WI-g / WI-j land the membership guard, the
  guards remain valid in the same location.
- Supplemented by upcoming WI-h (causal-binding XCUI test) which will
  pin the behavior end-to-end at the toolbar dispatch level rather
  than at the source-shape level.

## Alternatives considered

1. **Inline + restructure the modifier chain.** Hypothesis: maybe the
   toolbar/sheet pair could be re-ordered or the inlined body
   simplified to keep the parent's diff stable.
   **Rejected:** The root cause is identity collapse, not modifier
   ordering or chain length. No achievable simplification of an
   inlined 100+-line body restores a stable identity signature for
   the parent.

2. **Move `.toolbar { ... }` onto a child view.** Hypothesis: relocate
   toolbar ownership down to the hero card itself, then the hit-test
   envelope tracks the child's identity.
   **Rejected:** Scatters chrome ownership across the tree. The
   toolbar conceptually belongs to the main screen (Settings, info
   buttons, future menu items), not to one card. Moving it would
   re-create the same problem the next time we add a sibling card
   (UV index card, forecast picker card) that also needs toolbar
   coordination.

3. **Use `NavigationStack` as the identity boundary.** Hypothesis:
   wrap the inlined hero in an extra `NavigationStack` (or `Group`,
   `VStack`, etc.) to introduce an identity break without a new struct.
   **Explored and rejected.** RootView already wraps its content in
   `NavigationStack` (`AppViews.swift:99`) and the bug still
   reproduced under `9da54cf`. The presentation-slot resolver keys on
   the **struct-type** identity of the modifier-owning view, not on
   intermediate container views. The only reliable boundary is a
   distinct `View` struct for the child.

4. **Status quo (revert `9da54cf` entirely).** Keep the chrome and
   header along with the wrapper struct.
   **Rejected:** The UX intent of the redesign (gauge as standalone
   primary) was approved by Iris. Reverting would re-introduce the
   competing card chrome the team explicitly removed. The accepted
   fix (`f74ce6f`) keeps the chrome removed and only restores the
   struct boundary.

## References

- `app/Sources/UVBurnTimer/AppViews.swift`
  - `RootView.heroTimerCardView` delegation site — lines **233–247**
    (the `private var heroTimerCardView: some View` that calls
    `HeroTimerCard(...)`)
  - `struct HeroTimerCard: View` declaration — lines **795–1070**
  - `RootView` `NavigationStack` wrapper — line **99** (referenced in
    Alternative 3)
- `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift`
  - `test_R1_heroTimerCardWrapperStructStillExists` — line **1500**
  - `test_R2_rootViewDelegatesToHeroTimerCardConstructor` — line **1512**
- `.squad/log/2026-05-21T10-30-00Z-hero-card-wrapper-restore-cycle.md`
  — 8th-loop closure log; "Ratified architectural decision" section is
  the informal source of this ADR.
- Commits:
  - `9da54cf` — regression introduction (HeroTimerCard inlined into
    RootView)
  - `f74ce6f` — fix (HeroTimerCard wrapper restored without chrome;
    R1–R6 contract tests added)
  - `8f2f16d` — squash-merge of PR #19 onto `main` (2026-05-21T10:29:48Z)

**WI-gaia-gg (Loop-11) — line-number refresh:** the citations above were
bumped from their original WI-l-era positions (211–231 / 737–969 / 1090 /
1102) to the current `a691734`-era positions after the 13 Loop-10 source-
text + unit guards (Y/Z/AA/BB/GD) added ~1027 lines to the test file.
The *rule* the ADR encodes is unchanged; only the pointer numerics moved.

**WI-bundleS / Gaia L13a/b/c (Loop-14) — line-number refresh:** the
References block + Addendum + worked-example citations were re-bumped
from their Loop-10/11-era positions to the current `690046f`-era
positions after Loop-12 + Loop-13 churn (Bundles G/I/J/L/M/P/Q/R/RR +
WI-loop14-high). Forward-pinning guard
`test_S5_adr0001CitationsMatchLiveSourceLineNumbers` reads each cited
symbol's live source line and fails CI if the ADR ever drifts again.

**Loop-28 WI-0 — line-number refresh:** the References block + Addendum
+ worked-example citations were bumped again after `RootView` gained an
`@ScaledMetric private var minTap` declaration plus its explanatory
comment (AV-19) to floor the two toolbar `Image`s at HIG 44 pt
(AV-20). The new symbols shifted every downstream line in
`AppViews.swift` by ~14 lines; `test_S5_…` flagged the drift and this
addendum closes it. The *rule* this ADR encodes is unchanged.

**Loop-28 WI-0 / AV-19/AV-20 — current line manifest** (pinned by
`test_S5_adr0001CitationsMatchLiveSourceLineNumbers`). The Settings
gear `Image(systemName: "gearshape")` and the EstimateInfoButton
`Image(systemName: "info.circle")` each gained a
`.frame(minWidth: minTap, minHeight: minTap)` + `.contentShape(Rectangle())`
pair (Group LT contract tests LT1/LT2/LT3), inserting two lines per
toolbar item. Resulting `AppViews.swift` positions on this commit:

- `struct HeroTimerCard: View` declaration — line **795**
- `RootView.heroTimerCardView` delegation site — line **233**
- EstimateInfoButton `NavigationLink(destination: AboutView(...))` —
  line **133** (was 132 pre-Loop-28-WI-0)
- `.accessibilityIdentifier("EstimateInfoButton")` — line **140**
  (was 138 pre-Loop-28-WI-0)
- `PersistentFooter`'s `AboutView(highlightEstimateApplicability: true)`
  push — line **2171**
- `skinTypeChip` — line **339**, `locationChip` — line **301**,
  `spfChip` — line **320**

**Loop-28 WI-1 — line-number refresh (chip/footer `minTap` migration):**
the `PersistentFooter` `AboutView` push citation was bumped from line
**2133** → line **2144** (and the surrounding `NavigationLink { ... }`
body block from lines 2132–2134 → 2143–2145) after `struct
PersistentFooter` gained its own `@ScaledMetric private var minTap:
CGFloat = 44` declaration plus an explanatory `// MARK: - HIG
@ScaledMetric tokens` comment (Loop-28 WI-1 / Iris audit). The
matching source-text contract guard is `test_LU4_persistentFooter
DeclaresAndUsesMinTap` in `MainScreenCleanupContractTests.swift`,
with `test_LU5_appViewsHasNoLiteralMinHeight44` enforcing the
file-wide "no literal `minHeight: 44`" rule that replaced the
narrowed Loop-26 R2. The chip computed properties (`locationChip` /
`spfChip` / `skinTypeChip`) at lines **301 / 320 / 339** did not
shift; only their `.frame(maxWidth: .infinity, minHeight: ...)`
arguments changed from the literal `44` to the existing RootView-
scoped `minTap` token. `test_S5_…` flagged the PersistentFooter
drift and this addendum closes it. The *rule* this ADR encodes is
unchanged.

**Loop-29 WI-3 — line-number refresh (SkinTypePickerRow `rowMinHeight`):**
the `PersistentFooter` `AboutView` push citation was bumped from
line **2144** → line **2150** (body block 2143–2145 → 2149–2151)
after `struct SkinTypePickerRow` (AppViews.swift:1618) gained a
`@ScaledMetric private var rowMinHeight: CGFloat = 56` declaration
plus a five-line explanatory comment. The literal outer
`.frame(minHeight: 56)` on SkinTypePickerRow's Button was migrated
to `.frame(minHeight: rowMinHeight)` so the row's taller-than-44pt
hit-target floor (two text lines) now scales with Dynamic Type
(Iris loop-29 GAP-1). The matching source-text guards are
`test_LV2_appViewsHasNoLiteralMinFrameAxis` (zero literal `min*:
<digit>` frame axes in AppViews.swift) and
`test_LV5_skinTypePickerRowDeclaresRowMinHeightScaledMetric`
(substring-bounded to the SkinTypePickerRow struct body). The
SwiftLint `hardcoded_frame_dimensions` regex was widened to
`(?:width|height|minWidth|minHeight|maxWidth|maxHeight)` so the
gate catches all six axes — the inline-frame-axis blind spot
Iris's Loop-29 gap analysis flagged. The *rule* this ADR encodes
is unchanged.

**Loop-28 WI-4 — line-number refresh (AV-12 / AV-13 verbose
justification restored):** the `PersistentFooter` `AboutView` push
citation was bumped from line **2150** → line **2171** (body block
2149–2151 → 2170–2172) after the `clearStoredSkinType` (AV-12) and
`clearStoredSPF` (AV-13) `// swiftlint:disable:next
missing_min_touch_target` justifications inside `struct SettingsSheet`
had their "Reason: Button has multi-line action body …" comments
restored to the canonical verbose form (two-line shrunken stubs
expanded back to 11–13 line "Reason:" blocks matching their sibling
sites). The expansion is purely a comment change — no code semantics
moved — and was driven by a contract-test refactor: the brittle fixed
character-offset scan windows in `test_T1`, `test_U2`, and `test_V4`
(6000 / 7000 / 14000 chars) were replaced by a brace-counted
`_substringOfAppViewsStruct(name:in:)` helper so the comment-prose
budget is no longer a function of how far the next `}` happens to
fall. The matching helper guards are Group SU
(`test_SU1`…`test_SU5`) in `BurnTimeCalculatorTests.swift`. The
*rule* this ADR encodes is unchanged.

## Audit

Periodic: when adding a new toolbar-owning parent view (or attaching a
new `.toolbar { ... }` or `.sheet(isPresented:)` to an existing
parent), verify that all complex children rendered inside that
parent's body live in their own `View` structs. The pattern that
triggered this ADR — a parent that owns presentation modifiers
flattening a heavy child into a computed-property body — should be
called out in code review.

**WI-m** (`wi-m-audit-other-inlined-views`) tracks the explicit audit
of the other two main-screen card slots — `uvIndexCardView` and
`forecastPickerCardView` — for the same trade-off. Findings should be
appended to this ADR as an addendum if either case requires
re-architecting; otherwise WI-m closes with a note that the inlining
is benign for those slots (no toolbar/sheet binding pressure).

## Addendum (2026-05-21, WI-gaia-hh) — Multi-sheet / multi-cover on a single parent

When this ADR was ratified (2026-05-21), `RootView` carried a single
`.sheet(isPresented: $showSettings)` modifier. By Loop-10 close the
surface area expanded to **four** presentation modifiers and **two**
`NavigationLink` push routes all resolving against `RootView`'s identity:

1. `.sheet(isPresented: $showSettings)` — `AppViews.swift:78`
   (Settings sheet, owned by `RootView`).
2. `.sheet(isPresented: $showSkinTypeEdit)` — `AppViews.swift:88`
   (Pattern-B skin-type edit sheet; added by WI-ff / Group GD).
3. `.fullScreenCover(isPresented: $showDisclaimer)` — attached **from the
   parent `App`** at `UVBurnTimerApp.swift:94` via the
   `disclaimerPresentation(...)` view extension. Even though the binding
   lives on `UVBurnTimerApp`, the cover anchors to `RootView`'s view tree.
4. `.fullScreenCover(isPresented: $showSkinTypeOnboarding)` — also
   attached from the parent at `UVBurnTimerApp.swift:106` via
   `skinTypePresentation(...)`. Note the deliberate 500 ms
   `Task { @MainActor in }` defer at `UVBurnTimerApp.swift:129–136` —
   iOS swallows a second `fullScreenCover` set while the first is still
   tearing down its transition. This is **not** an identity-collapse
   bug; it is a presentation-slot serialisation issue. We mention it
   here so anyone reading this ADR after a future multi-cover bug rules
   the slot-serialisation pattern in/out before hunting for an inlined
   child.

The two `NavigationLink` push routes that also key on `RootView`'s
identity:

- toolbar ⓘ `EstimateInfoButton` → `AboutView(highlightEstimateApplicability: true)`
  at `AppViews.swift:133` (accessibility identifier `EstimateInfoButton`
  at line 140).
- `PersistentFooter` reach-back link → `AboutView(...)` at
  `AppViews.swift:2171` (inside the `NavigationLink { AboutView(...) }`
  body at lines 2170–2172), rendered inside the
  `.safeAreaInset(edge: .bottom)` at line 143–151.

### Rule (extended)

The original rule still binds: **complex children inside `RootView`'s
body must be extracted into their own `View` struct.** This now matters
for **every** modifier in the list above, not just `$showSettings`. A
regression in any one of them is the same class of identity-collapse
bug — only the symptom changes (toolbar gear tap dead, chip tap dead,
L1 cover stuck open, About push unresponsive, ⓘ tap dead).

### Lightweight-inlining clarification (worked examples)

- ✅ `mainNavigationStack` / `navigationStackBase` (`AppViews.swift:66-156`)
  — these are `RootView`'s *own modifier chain*, decomposed into two
  computed properties purely for Swift's expression-complexity budget
  (see the comment at lines 63–65). They are not children. The
  decomposition does not introduce a new identity boundary and cannot
  trigger identity-collapse.
- ✅ `skinTypeChip` (`AppViews.swift:339-368`), `locationChip` (301-318),
  `spfChip` (320-337) — each is a small `Button` whose action mutates
  `RootView`'s `@State`. They are permitted as inline computed properties
  **as long as** they (a) carry no `@State`/`@StateObject`, (b) own no
  gestures beyond `Button` action, and (c) stay short. **WI-gaia-ii**
  (Loop-11) adds source-text guard `R8 — chip watchlist` (Group R8c
  in `BurnTimeCalculatorTests.swift`) that fires if any of these grow
  past those limits.
- ❌ `heroTimerCardView` (233-247) inlining the full `HeroTimerCard`
  body — explicitly forbidden, guarded by R1/R2.

### Operational

When attaching a *new* `.sheet` / `.fullScreenCover` / `.popover` /
`.alert` to `RootView` (or to the App at its `RootView` insertion
site), the author must:

1. Confirm every complex child rendered inside `RootView`'s body
   already lives in its own `View` struct.
2. Add (or extend) an R-series source-text guard in
   `BurnTimeCalculatorTests.swift` for the new binding so a future
   inliner sees a green guard and reads this ADR.

## Addendum (2026-05-22, Loop-13) — See ADR-0002 for toolbar *placement*

This ADR establishes the **identity-boundary** contract for the
toolbar (parent owns `.toolbar { ... }`; complex children live in
their own `View` structs so the parent's identity-diff signature
stays stable). It does **not** constrain which `ToolbarItem`
placement enum the items use.

On the Xcode 26 / iOS 26 toolchain, the choice of placement enum
turned out to matter independently: SwiftUI's Liquid Glass rendering
of `ToolbarItem(placement: .primaryAction)` produces a hit-test
geometry that `XCUIElement.isHittable` reports as `false`,
regressing `testSettingsSheetOpens` and
`testToolbarRendersBothSettingsAndEstimateInfoButtons` even though
the parent-identity contract above is satisfied.

The follow-on decision — both toolbar items use `.topBarTrailing`,
with declaration order determining horizontal position (first
declared = rightmost; gear in the corner, ⓘ to its left) — is
captured in
[ADR-0002](./ADR-0002-toolbar-topbartrailing-ios26.md) (PR #57,
branch `squad/wi-loop13-toolbar-ios26-hittability`). The R1/R2
identity guards in this ADR remain in force; ADR-0002 layers a
placement-enum guard (**S4**,
`test_S4_toolbarGearButtonUsesTopBarTrailingNotPrimaryAction`) on
top.
