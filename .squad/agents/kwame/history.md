# Kwame — History (Summarized)

**Summarized on 2026-05-22T15:05:00Z** — archived entries before 2026-05-22 Loop-28 closure to history-archive.md.

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

---

## Loop-28 WI-4 — `_substringOfAppViewsStruct` helper replaces fixed scan windows

**Closed** on `squad/wi-loop28-4-test-u2-scan-window` (base
`d028ea8` = github/main). Brittle hand-picked fixed-character-offset
scan windows in three source-text contract tests were replaced with
a brace-counted helper, freeing the AV-12 / AV-13
`swiftlint:disable:next missing_min_touch_target` justifications to
return to their canonical verbose "Reason:" form.

**Changes:**

- **`_substringOfAppViewsStruct(_:in:) -> String?`** — ~110 LOC,
  inserted after `_appViewsSourceForGroupR()` in
  `BurnTimeCalculatorTests.swift`. Lexer state machine
  (`normal | lineComment | blockComment | string | multilineString`)
  so `}` characters living inside comments or string literals don't
  prematurely close the scan. Pairs with
  `_findStructDeclStart(name:in:)` which matches `struct {name}`
  bounded by a non-identifier tail so `struct Foo` doesn't drift
  into `struct FooBar`.
- **`test_T1_photosensitizerLineLabelOnL1CoverUsesPrimaryTextColor`**
  — replaced 6000-char fixed window with helper call for
  `DisclaimerCover`.
- **`test_U2_settingsSheetRendersDisclaimerLineFromProductCopy`** —
  replaced 7000-char fixed window with helper call for
  `SettingsSheet`. This is the window that had forced AV-12 / AV-13
  to shrink in the first place.
- **`test_V4_heroTimerCardKeepsCuratedParentAccessibilityLabelAndContainElement`**
  — replaced 14000-char fixed window with helper call for
  `HeroTimerCard`.
- **Group SU (`test_SU1`…`test_SU5`)** — new helper guards:
  resolves a real struct bounded by braces, stays inside the body
  (no leak into `SkinTypeEditView` / `PersistentFooter`), returns
  nil for missing names, respects identifier-tail boundary, and
  respects comment / string / multiline-string lexer contexts on a
  synthetic `struct Trickster` fixture.
- **AV-12 / AV-13 verbose comment restoration** — both
  `clearStoredSkinType` and `clearStoredSPF` Button-attached
  `// swiftlint:disable:next missing_min_touch_target` justifications
  expanded back from 2-line shrunken stubs to ~11–13 line
  "Reason: Button has multi-line action body …" blocks matching
  their sibling sites (AppViews.swift lines 946-951 / 1548-1553).
- **ADR-0001 line-citation refresh** — `PersistentFooter`'s
  `AboutView(highlightEstimateApplicability: true)` push citation
  bumped from line **2144** → **2164** (body block 2143–2145 →
  2163–2165) in the References and Worked-example sections. A new
  audit-trail paragraph documents the Loop-28 WI-4 line drift +
  rationale.

**Build status:** `./build.sh` per-test results green; SwiftLint
strict gate at 0 violations; warnings-as-errors clean. Exit code
flake on IOHIDLib kext arch-mismatch runner restart was disregarded
per the established convention (see Loop-27 closure).

### Learnings

- **Fixed-character scan windows are a comment-prose tax.** Every
  time a struct body grows, the next-door justification comments
  must shrink to fit — and the shrink propagates to every cohort
  agent who later reads them. A brace-counted bound (with lexer
  state machine) is ~110 LOC and removes that pressure permanently.
- **Lex `}` carefully inside Swift strings.** Multiline
  `"""..."""` literals are the easy gotcha: triple-quote inside a
  triple-quoted test fixture has to be escaped as `\"\"\"` to keep
  the Swift compiler from terminating the literal early. Group
  SU5's synthetic fixture exists specifically to pin this.
- **Identifier-tail boundary matters more than the "struct"
  keyword.** A naive `range(of: "struct Foo")` would match
  `struct FooBar` — the failure is silent (you get *too much*
  text). Always check the character after the name and reject when
  it's `[A-Za-z0-9_]`.

---

## 2026-05-22: Loop-28 closure — 4 WIs shipped (PR #99–#102)

**Kwame execution:** Landed 4 work items on main (toolbar, chip/footer, hardcoded-frame-dimensions audit widening, matched-brace helper test refactor). Dynamic Type scaling verified on iPhone SE at AX5. SwiftLint strict: 0 violations post-merge. Discovered: UI cold-start flakiness on first CI run of PR #100 (3 tests flaked, all passed on re-run); documented as Loop-29 WI-2-flake candidate. Carry-forward: ~14 HIG catalog rules pending (WI-loop-28-A), label-closure regex blind spot (scheduled for swift-syntax AST replacement).

