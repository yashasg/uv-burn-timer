# UVBurnTimer Squad Decisions Archive

> Pre-Loop-25 entries archived: see .squad/decisions/archive/2026-05-pre-loop25.md

---

### 2026-05-22T04:55:00-07:00: Iris — Loop-26 Post-Merge HIG-Pass Review
**Author:** Iris (UI/UX Designer)  
**Scope:** PR #98 (`squad/swiftlint-hig-error-gate`) merge commit a8b1ac8, auditing commits 66cc6c9/a643523/174be71.

**Verdict:** **PASS-WITH-NOTES**

**Results:**
- SwiftLint gate: 0 violations on github/main HEAD
- ForecastPickerView: 15 @ScaledMetric identifiers faithful; all 13 violations resolved
- AppViews: 5 struct @ScaledMetric declarations; all 18 violations + navigation_stack_in_sheet fixed
- Group R guards: Extended to cover new @ScaledMetric tokens

**Deviations accepted:**
- Test R2 narrowed from file-wide to DisclaimerCover CTA (pragmatic — pre-existing out-of-scope sites at AppViews:298/318/342/2130 deferred as Loop-27 WI-1)
- 4 extra swiftlint:disable comments (AV-12/13/15/16) — all justified by 200-char regex lookahead limitation

**Loop-27 WIs generated:**
- WI-1: Migrate chip/footer minHeight:44 to @ScaledMetric (HIGH PRIORITY)
- WI-2: HIG catalog expansion — 14 additional rules pending
- WI-3: AST-level missing_min_touch_target (eliminate lookahead, remove 6 disables)
- WI-4: test_U2 7000-char window brittleness

### 2026-05-22T12:20:00Z: Iris — Loop-28+ Gap Analysis (Structural Rule-Coverage Holes)
**Author:** Iris (UI/UX Designer)  
**Scope:** Post-merge review surfacing 5 structural SwiftLint rule-coverage gaps — not regressions from PR #98, but pre-existing blind spots.

**Gaps surfaced:**
- **GAP-1 (High):** `hardcoded_frame_dimensions` rule does not catch `minHeight:`/`minWidth:` literals
- **GAP-2 (High):** `missing_min_touch_target` does not cover `Button { }` no-paren trailing-closure form
- **GAP-3 (Medium):** `missing_min_touch_target` does not cover `NavigationLink` or `Link` controls
- **GAP-4 (Medium):** `DisclaimerSeeAboutLink` button in DisclaimerCover has no explicit touch-target height
- **GAP-5 (Low):** ForecastPickerView day-row `Button { }` pattern requires systematic audit

**All five gaps are structural rule holes, not code regressions.** Recommended fixes documented for Loop-28+ owner.

---

## 2026-05-22 (Loop-28 WI decisions inbox merge)

### SwiftLint HIG gate install (Kwame decision)

**Date:** 2026-05-22T02:30:00Z
**Author:** Kwame (iOS Developer)

Install SwiftLint in two places:
1. Exact-pin `SimplyDanny/SwiftLintPlugins` `0.63.2` in `app/Package.swift`.
2. Install Homebrew `swiftlint` in CI and invoke it explicitly from both `.github/workflows/ci.yml` and `build.sh`, using `--strict`.

Seed the harness with four HIG rules plus two audit-backed layout rules (`hardcoded_frame_dimensions`, `literal_system_font_size`).

**Trade-offs:** `SwiftLintPlugins` vs `realm/SwiftLint` — chose `SimplyDanny` for plugin-only package advantages. SPM plugin keeps integration Apple-native; Homebrew gives deterministic CLI availability. `--strict` ensures a rule misconfigured as warning still fails CI.

**Consequences:** `build.sh` now runs SwiftLint before any `xcodebuild` work. CI installs SwiftLint via Homebrew and runs a dedicated strict lint step. Baseline is intentionally red: **16 HIG violations** (11 `hardcoded_frame_dimensions`, 4 `literal_system_font_size`, 1 `navigation_stack_in_sheet`).

---

### SwiftLint HIG gate tightening — hard-error day 1 (Kwame decision)

**Date:** 2026-05-22T03:32:09-07:00
**Author:** Kwame (iOS Developer)

Tighten the SwiftLint HIG gate so layout/touch/typography rules are hard errors from day 1. `missing_min_touch_target` no longer accepts literal `minHeight: 44` / `56` as compliant.

**Context:** User overruled Iris's softer rollout policy. Rationale: iPhone SE/mini widths combined with AX5 Dynamic Type make fixed 44pt touch targets feel cramped; `@ScaledMetric` lets the hit area grow.

**Trade-offs:** Regex heuristic vs real semantic validation — SwiftLint cannot prove `@ScaledMetric`. Broader touch-target failures; justified exceptions must use per-line disable comment. Hard-error rollout with no grace period.

**Consequences:** Layout/touch/typography rules stay at `severity: error`. `missing_min_touch_target` now flags literal touch-target floors. Strict lint baseline rises from 16 to **31 violations**.

---

### User directive — HIG layout rules are ERROR day 1, no literal exceptions

**Date:** 2026-05-22T03:32:09-07:00
**By:** yashasgujjar (via Copilot)

Override Iris's "Error after grace period" severity bucket and allowed exception for `minHeight: 44` / `minHeight: 56`. New policy:

1. **All HIG layout rules ship at `severity: error` on day 1.** No grace period.
2. **No literal numbers in layout.** `.frame(minHeight: 44)` must be backed by `@ScaledMetric`.
3. **The `missing_min_touch_target` rule regex must enforce `@ScaledMetric`** as backing, not literals.

**Rationale:** Small screens + AX5 Dynamic Type make 44pt tap targets cramped. `@ScaledMetric` lets the target grow, which is what HIG intends.

**Supersedes:** Iris's "Error after grace period" bucket and literal `44`/`56` exception.

**Action:** Applied via Kwame: all HIG layout rules now `severity: error`, 31 baseline violations identified.

---

### Kwame decision — Loop-28 WI-1: chip/footer `minTap` migration
### 2026-05-22T03:32:09-07:00: User directive — HIG layout rules are ERROR day 1, no literal exceptions
**By:** yashasg (via Copilot)
**What:** Override Iris's "Error after grace period" severity bucket and her "allowed exception" carve-out for `minHeight: 44` / `minHeight: 56` HIG-touch-target floors. The new policy is:

1. **All HIG layout rules ship at `severity: error` on day 1.** No grace period, no "warn now, error in 2 weeks" ramp. The CI gate is the gate from the moment the SwiftLint PR merges.
2. **No literal numbers in layout — including HIG touch-target floors.** `.frame(minHeight: 44)`, `.frame(minHeight: 56)`, etc. must be backed by `@ScaledMetric` (e.g., `@ScaledMetric private var minTap: CGFloat = 44`). The raw literal does not satisfy the lint rule even though Iris originally exempted it.
3. **The `missing_min_touch_target` rule regex must enforce `@ScaledMetric`** as the backing, not a literal `44`/`56`/`88` count. Literals fail.
4. **Rationale (user-supplied):** Small screens (iPhone SE / mini) combined with AX5 Dynamic Type make a fixed-pixel 44pt tap target visibly cramped. `@ScaledMetric` lets the tap target grow proportionally with the user's text-size preference, which is what HIG actually intends. The literal is the easy interpretation of HIG; `@ScaledMetric` is the right one.

**Supersedes:**
- Iris's "Severity bucket recommendations" section in `iris-hig-lint-rule-catalog.md` — specifically the "Error after grace period (warn for now, error in 2 weeks)" bucket for touch-target and padding rules.
- Iris's "Allowed exception: Fixed minimum sizes that directly serve Apple HIG touch-target rules stay allowed (`minHeight: 44` / `56`)" carve-out documented in the same catalog.

**Action items dropped to Kwame this turn:**
- Apply error severity to ALL HIG layout rules in `.swiftlint.yml` on branch `squad/swiftlint-hig-error-gate`. No `severity: warning` on layout/padding/frame/touch-target rules.
- Tighten the `missing_min_touch_target` regex to require `@ScaledMetric`-backed minHeight; literal numbers like `minHeight: 44` are violations.
- Update the comment header in `.swiftlint.yml` to call out this policy explicitly so future contributors don't re-soften it.
- The 16 baseline violations + the literal `minHeight: 44`/`56` sites the audit didn't previously count are now ALL CI-blockers. Issues #95/#96 (Kwame HIG cleanup) become more urgent — they must land before this branch merges, OR this branch's CI will be red the moment it hits main.

**Note on Iris:** Iris's catalog isn't being rewritten retroactively (it's part of append-only decisions.md). She'll see this directive on her next spawn and update her skill (`.squad/skills/swiftlint-hig-ruleset/SKILL.md`) to reflect the new policy. The original catalog stays as the historical artifact; this directive is the authoritative supersession.

---

# Iris — Loop-28 Closure HIG Sign-Off

**Date:** 2026-05-22T14:20:00Z | **Author:** Iris (UI/UX Designer) | **Commits:** `521bc82` (WI-0), `d028ea8` (WI-1)

---

## VERDICT: 🟢 HIG-PASS

Both WI-0 and WI-1 meet HIG compliance. All `@ScaledMetric` declarations verified, all frame applications correct, zero literal `minHeight: 44/56` regressions, `.swiftlint.yml` strict-error directive upheld, WI-21 automation-status explanations intact.

---

## A. WI-0 Verification (521bc82 — RootView toolbar AV-19/AV-20)

**A1. @ScaledMetric declaration (AV-19):** ✅ `AppViews.swift:54` contains `@ScaledMetric private var minTap: CGFloat = 44` inside RootView body (grep verified).

**A2. Gear Button .frame (AV-19):** ✅ Line 126 applies `.frame(minWidth: minTap, minHeight: minTap)` inside gear Button label.

**A3. EstimateInfoButton .frame (AV-20):** ✅ Line 135 applies `.frame(minWidth: minTap, minHeight: minTap)` inside NavigationLink label.

---

## B. WI-1 Verification (d028ea8 — chip/footer minTap migration)

**B1. locationChip (LU1):** ✅ Line 310 `.frame(maxWidth: .infinity, minHeight: minTap)` — literal `44` replaced.

**B2. spfChip (LU2):** ✅ Line 330 `.frame(maxWidth: .infinity, minHeight: minTap)` — literal `44` replaced.

**B3. skinTypeChip (LU3):** ✅ Line 354 `.frame(maxWidth: .infinity, minHeight: minTap)` — literal `44` replaced.

**B4. PersistentFooter (LU4):** ✅ Line 2166 `@ScaledMetric private var minTap` + line 2179 `.frame(minHeight: minTap)` — both verified.

---

## C. File-Wide LU5 Guard (Zero Literal minHeight: 44/56)

**C1. `minHeight:\s*44\b` grep:** ✅ ZERO executable hits (only one comment at line 2158).

**C2. `minHeight:\s*56\b` grep:** ✅ ZERO hits (exit code 1).

---

## D. SwiftLint Strict-Error Compliance

**D1. HIG rules severity:** ✅ All 6 HIG custom rules (`color_literal_rgb`, `navigation_stack_in_sheet`, `missing_min_touch_target`, `no_uppercased_in_code`, `hardcoded_frame_dimensions`, `literal_system_font_size`) remain at `severity: error` in `.swiftlint.yml` lines 50–88.

**D2. No literal-44 disable carve-outs:** ✅ Zero disable comments at the six migrated sites (AV-19/20 + four chips/footer). Fixes applied directly.

---

## E. WI-21 Automation-Status Checklist Verification

**E1. iris-contrast-qa-checklist.md:** ✅ Lines 123–140 contain WI-21 explanation (WCAG physical-device requirement). Sign-off block blank-with-reason (correct state).

**E2. iris-launch-readiness-checklist.md:** ✅ Lines 129–145 contain WI-21 explanation (OLED + polarization test requirement). Sign-off block blank-with-reason (correct state).

---

## F. Summary

| Item | Result |
|------|--------|
| WI-0 AV-19 `@ScaledMetric` declaration | ✅ Line 54 |
| WI-0 AV-19 gear Button frame | ✅ Line 126 |
| WI-0 AV-20 EstimateInfoButton frame | ✅ Line 135 |
| WI-1 LU1 locationChip | ✅ Line 310 |
| WI-1 LU2 spfChip | ✅ Line 330 |
| WI-1 LU3 skinTypeChip | ✅ Line 354 |
| WI-1 LU4 PersistentFooter | ✅ Lines 2166/2179 |
| LU5 file-wide literal-44 guard | ✅ 0 hits |
| SwiftLint strict-error (6 rules) | ✅ All `error` |
| WI-21 checklist explanations | ✅ Intact |

**Loop-29 note:** GAP-2 confirmed — gear Button at line 122 uses `Button { }` trailing-closure form (regex blind spot). Fix IS correct; SwiftLint did NOT enforce it. WI-29-2 must wire AST-aware rule or expand regex to catch `Button\s*\{`.

**No regressions introduced.** Both commits HIG-safe to ship.

---

**Iris** | 2026-05-22T14:20:00Z

---

# Decision Drop — Kwame, Loop-28 WI-1: chip/footer `minTap` migration

**Date:** 2026-05-22T13:00:00Z
**Author:** Kwame (iOS Developer)
**Branch:** `squad/wi-loop28-1-chip-footer-mintap`

Migrated four literal `minHeight: 44` call sites in `app/Sources/UVBurnTimer/AppViews.swift` to `@ScaledMetric`-backed `minTap`:
- `RootView.locationChip` Button (line 310)
- `RootView.spfChip` Menu (line 330)
- `RootView.skinTypeChip` Button (line 354)
- `PersistentFooter` Label (line 2153)

**Why:** PR #98's `missing_min_touch_target` regex anchors on `\bButton\s*(` and misses literals nested inside `} label: { ... }` closures. These four sites survived the baseline while still representing real Dynamic-Type-scaling debt.

**Test coverage:** Added Group LU (LU1–LU5); LU5 is file-wide regex guard for `minHeight:\s*44\b` → zero matches. Removed R2; updated EJ4. Refreshed ADR-0001 line citations.

**Verification:** `./build.sh` GREEN; all tests pass; SwiftLint strict 0 violations. UI tests 9/9 green on re-run (cold-start flakiness observed on first run; candidate for Loop-29 WI-2-flake).

**SwiftLint blind spot:** Label-closure gap confirmed; scheduled for swift-syntax AST replacement.
**Loop:** 28 / Work Item 1
**Status:** Local commit ready. Not yet pushed (Coordinator-gated).

## What

Migrated four pre-existing literal `minHeight: 44` call sites in
`app/Sources/UVBurnTimer/AppViews.swift` to the canonical
`@ScaledMetric`-backed `minTap` token, closing the residual HIG
Dynamic-Type-scaling debt Iris's Loop-26 post-merge audit identified.

Sites migrated:

| # | Symbol                              | Line | Before                                                  | After                                                          |
|---|-------------------------------------|------|---------------------------------------------------------|----------------------------------------------------------------|
| 1 | `RootView.locationChip` Button lbl  |  310 | `.frame(maxWidth: .infinity, minHeight: 44)`            | `.frame(maxWidth: .infinity, minHeight: minTap)`               |
| 2 | `RootView.spfChip` Menu label       |  330 | `.frame(maxWidth: .infinity, minHeight: 44)`            | `.frame(maxWidth: .infinity, minHeight: minTap)`               |
| 3 | `RootView.skinTypeChip` Button lbl  |  354 | `.frame(maxWidth: .infinity, minHeight: 44)`            | `.frame(maxWidth: .infinity, minHeight: minTap)`               |
| 4 | `PersistentFooter` Label            | 2153 | `.frame(minHeight: 44, alignment: .leading)`            | `.frame(minHeight: minTap, alignment: .leading)`               |

`RootView` already declared `@ScaledMetric private var minTap: CGFloat
= 44` (Loop-28 WI-0 / AV-19). `PersistentFooter` received a new
identical declaration with an explanatory `// MARK: - HIG
@ScaledMetric tokens` comment.

## Why

At default Dynamic Type these four sites render at the HIG 44-pt
floor. On iPhone SE at AX5 the literal `44` does NOT scale; the
`@ScaledMetric` form expands the floor proportionally to ~88 pt,
restoring reachability for users who depend on accessibility text
sizes. PR #98's `missing_min_touch_target` SwiftLint rule did not
flag these sites because its regex anchors on `\bButton\s*(` at the
call site and misses literals nested inside `} label: { ... }`
closures (Button / Menu / NavigationLink alike). The four sites
therefore passed the Loop-26 0-violations gate while still
representing real Dynamic-Type-scaling debt.

## Test-coverage change

### Added: Group LU (Loop-28 WI-1) in `MainScreenCleanupContractTests.swift`

- **LU1** — `RootView.locationChip` body uses `.frame(maxWidth: .infinity, minHeight: minTap)`.
- **LU2** — `RootView.spfChip` body uses `.frame(maxWidth: .infinity, minHeight: minTap)`.
- **LU3** — `RootView.skinTypeChip` body uses `.frame(maxWidth: .infinity, minHeight: minTap)`.
- **LU4** — `struct PersistentFooter` declares `@ScaledMetric private var minTap: CGFloat = 44` AND
  applies `.frame(minHeight: minTap, alignment: .leading)`.
- **LU5** — File-wide: `minHeight:\s*44\b` regex must find zero matches in `AppViews.swift`. This is
  the broad-scope safety net for any future regression at any literal site.

LU1–LU4 use struct-scoped substring slices (struct opener → next
`\nstruct `, or chip-name → next `private var `) to anchor each
contract to its declaring scope, mirroring the LT1 pattern from
Loop-28 WI-0 (Iris's recommended primitive for source-text guards).

### Removed: narrowed Loop-26 R2

`test_R2_appViewsDisclaimerCTAUsesMinTap` was a per-CTA guard that
only forbade the literal `minHeight: 44` on the DisclaimerCover "I
understand" CTA. LU5 (file-wide) subsumes R2's intent without leaving
a per-CTA guard whose name no longer describes its job. An inline
`// R2 — REMOVED in Loop-28 WI-1` comment block in the same file
preserves the audit trail.

### Updated: `test_EJ4_persistentFooterMeetsHIG44ptHitTarget`

Previously asserted `body.contains(".frame(minHeight: 44")`. Now
asserts both the struct-scoped `@ScaledMetric private var minTap:
CGFloat = 44` declaration and `.frame(minHeight: minTap`. EJ4
remains the dedicated Plunder C3-floor guard for the
`PersistentFooter` reach-back; LU4 is the new general struct-shape
guard.

### Updated: `ADR-0001` line citations

`PersistentFooter`'s `AboutView` push citation moved from line
**2133** → line **2144** (+11 lines from the new `@ScaledMetric`
block + MARK comment). Refreshed two citations in the ADR
(References § bullet at line 243, worked-example block at lines
296–298) and appended a `**Loop-28 WI-1 — line-number refresh
(chip/footer `minTap` migration):**` audit-trail paragraph to the
Loop-28 line-manifest section. Chip line numbers (301 / 320 / 339)
did not shift; only PersistentFooter and everything after it did.

## Verification

`./build.sh` GREEN end-to-end on Xcode 26.4 / iPhone 17 Pro / iOS
26.4:

- **Debug build:** clean (`SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`,
  `-warnings-as-errors`).
- **Core unit tests:** 307 passed, 0 failed, 2 pre-existing known
  issues in `ForecastPickerLogicTests` (orthogonal, predate Loop-28).
  Group LU all green (LU1/LU2/LU3/LU4/LU5).
- **UI tests:** 9 passed, 0 failed (115.0 s total). The three
  Loop-28 WI-0 hittability tests
  (`testEstimateInfoButtonOpensAboutWithHighlightedApplicabilityAnchor`,
  `testEstimateInfoNavigationRoundTripReturnsToMainScreen`,
  `testSettingsSheetOpens`) still pass after the chip/footer
  migration — the visual layout doesn't change at default Dynamic
  Type (`@ScaledMetric` initial value is `44`).
- **Release build:** clean, signed, validated.

**SwiftLint strict:** 0 violations. No rule delta — the four
migrated sites passed SwiftLint baseline before too (which is
exactly why they survived PR #98). Confirms the
`missing_min_touch_target` label-closure blind spot identified by
Iris is real and remains scheduled for a swift-syntax AST
replacement (Loop-28+ follow-up #4 in `kwame/history.md`).

## SwiftLint heuristic blind spot (escape-route analysis)

PR #98's `missing_min_touch_target` regex (`.swiftlint.yml`):

```
included: ".*\\.swift"
name: missing_min_touch_target
regex: '\\bButton\\s*\\(.{0,200}?(?<!minHeight:\\s)(?<!minWidth:\\s)44'
```

The pattern anchors on `\bButton\s*(` at the call site. The four
migrated sites all live inside `} label: { ... .frame(...minHeight:
44) }` closures attached to Button / Menu / NavigationLink
constructors — the `.frame(...minHeight: 44)` literal is well past
the 200-char regex lookahead window, AND in two cases the host
constructor is Menu or NavigationLink, which `\bButton\s*(` never
matches in the first place. Both gaps must close before this rule
can be relied on as the sole touch-target floor enforcer. Until
then, LU5's file-wide source-text guard is the strict-mode safety
net.

## Files touched

- `app/Sources/UVBurnTimer/AppViews.swift`
- `app/Tests/UVBurnTimerCoreTests/MainScreenCleanupContractTests.swift`
- `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift`
- `.squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md`
- `.squad/agents/kwame/history.md`
- `.squad/decisions/inbox/kwame-loop28-wi1-chip-footer-mintap.md` (this file)

## For Iris / Scribe

- Iris: confirms the Loop-26 post-merge audit "WI-1 chip/footer"
  item is now closed. The label-closure blind spot remains — please
  prioritise the swift-syntax AST replacement for
  `missing_min_touch_target` in Loop-29 or earlier.
- Scribe: merge this file into `.squad/decisions.md` under Loop-28
  closure. R2 deletion + LU1–LU5 addition + EJ4 update + ADR-0001
  line-citation refresh are the four discrete changes to record.

---

# Kwame — Loop-28 WI-4: brace-counted source-substring helper for AppViews source-text tests

**From:** Kwame (iOS dev agent)
**Branch:** `squad/wi-loop28-4-test-u2-scan-window`
**Base:** `d028ea8` (= github/main)
**For:** Scribe (history + index) / Iris (HIG-gate cross-check) / Coordinator

## What changed

Three source-text contract tests in `BurnTimeCalculatorTests.swift`
(`test_T1_photosensitizerLineLabelOnL1CoverUsesPrimaryTextColor`,
`test_U2_settingsSheetRendersDisclaimerLineFromProductCopy`,
`test_V4_heroTimerCardKeepsCuratedParentAccessibilityLabelAndContainElement`)
used hand-picked fixed-character-offset scan windows (6000 / 7000 /
14000 chars respectively) after locating the relevant struct
declaration. The windows were brittle: when a struct body grew, the
scan either truncated mid-assertion-target or — in the AV-12 / AV-13
case in `SettingsSheet` — forced surrounding justification comments to
shrink so the disclaimer line stayed inside the 7000-char window.

WI-4 introduces `_substringOfAppViewsStruct(_:in:) -> String?` (~110
LOC) which:

1. Locates `struct {name}` via `_findStructDeclStart(name:in:)` with
   non-identifier-tail boundary (so `struct Foo` won't match
   `struct FooBar`).
2. Walks forward with a lexer state machine
   (`normal | lineComment | blockComment | string | multilineString`)
   counting balanced `{`/`}` until depth returns to 0.
3. Returns the exact substring from the `struct` keyword to the
   matching closing brace — no fixed character budget.

All three tests now bound their scans by the real struct body. The
AV-12 (`clearStoredSkinType` Button) and AV-13 (`clearStoredSPF`
Button) `// swiftlint:disable:next missing_min_touch_target`
justifications were restored from 2-line shrunken stubs to the
canonical ~11–13 line "Reason: Button has multi-line action body …"
form matching sibling sites at AppViews.swift:946-951 and
1548-1553.

## New tests (Group SU)

- **SU1** — helper resolves `SettingsSheet`, returns non-empty
  substring ending in `}`.
- **SU2** — `SettingsSheet` region contains
  `ProductCopy.disclaimerLinkLabel` and does NOT leak into
  `SkinTypeEditView` or `PersistentFooter`.
- **SU3** — helper returns `nil` for a missing struct name.
- **SU4** — identifier-tail boundary on a synthetic `struct Foo`
  vs `struct FooBar`.
- **SU5** — lexer respects `}` inside line comments, block
  comments, single-quoted strings, and triple-quoted multiline
  strings (synthetic `struct Trickster` fixture).

## ADR-0001 refresh

`PersistentFooter`'s `AboutView(highlightEstimateApplicability:
true)` push citation moved **2144 → 2164** (body block
**2143–2145 → 2163–2165**) at References and Worked-example
sections. A new audit-trail paragraph documents the Loop-28 WI-4
line drift + rationale.

## Build status

`./build.sh` per-test results green; SwiftLint strict gate at 0
violations; warnings-as-errors clean. (The IOHIDLib kext arch
runner-restart exit-code flake was disregarded per Loop-27
convention — verify per-test results, not exit code.)

## Open coordination item — for Coordinator

During this WI another agent committed `a346d4d` on
`squad/wi-loop29-3-min-frame-regex` that calls
`_substringOfAppViewsStruct(_:in:)` from `test_T1` / `test_U2` /
`test_V4` **without** including the helper's definition (the calls
were copied from my work-in-progress snapshot but the helper hunk was
not). That commit will not compile if rebased onto github/main
without WI-loop28-4 landed first. Recommend landing WI-loop28-4
before WI-loop29-3 OR cherry-picking the helper hunk into the
Loop-29 WI-3 branch as a prerequisite.

## Files

- `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift` —
  helper + T1/U2/V4 rewrites + Group SU.
- `app/Sources/UVBurnTimer/AppViews.swift` — AV-12 / AV-13 verbose
  comment restoration (+20 lines net).
- `.squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md`
  — line-citation refresh + Loop-28 WI-4 audit paragraph.
- `.squad/agents/kwame/history.md` — Loop-28 WI-4 closure entry.

---

# Kwame decision inbox — SwiftLint HIG error gate install

- **Date:** 2026-05-22T02:30:00Z
- **Author:** Kwame (iOS Developer — Modern Swift & WeatherKit)

## Decision

Install SwiftLint in two places:

1. Exact-pin `SimplyDanny/SwiftLintPlugins` `0.63.2` in `app/Package.swift` so SwiftPM/Xcode can attach lint as a build-tool-only dependency with no runtime binary linkage.
2. Install Homebrew `swiftlint` in CI and invoke it explicitly from both `.github/workflows/ci.yml` and `build.sh`, using `--strict` so any HIG rule that is accidentally left at warning still blocks the pipeline.

Seed the harness with the four agreed HIG rules plus two audit-backed layout rules (`hardcoded_frame_dimensions`, `literal_system_font_size`) so the current tree already exercises the error gate while Iris prepares the broader catalog.

## Context

The repo currently hardens the Swift compiler via `SWIFT_TREAT_WARNINGS_AS_ERRORS`, but HIG regressions can still sneak through as ordinary review debt. Apple’s HIG treats minimum 44×44pt hit targets, semantic colors that adapt to appearance/contrast, semantic text sizing, and sheets as focused single-task presentations as shipped UX contracts rather than optional polish.

Iris is landing the larger HIG rule catalog separately at `.squad/decisions/inbox/iris-hig-lint-rule-catalog.md`. The harness here needs to make that next merge mechanical instead of architectural.

## Trade-offs

- **`SwiftLintPlugins` vs `realm/SwiftLint` as the package dependency:** chose `SimplyDanny/SwiftLintPlugins` because its README documents the plugin-only package advantages: no full SwiftLint source checkout, no extra SwiftSyntax dependency graph, and no accidental runtime product linkage. Cost: CI still needs a CLI install for explicit script/workflow steps.
- **SPM plugin vs Homebrew-only install:** the plugin keeps package/Xcode integration Apple-native and build-tool-only; Homebrew gives deterministic CLI availability for `build.sh` and GitHub Actions. Using both is intentional defense in depth.
- **`--strict` vs plain lint:** `--strict` ensures a rule misconfigured as warning still fails CI. Cost: unrelated legacy SwiftLint debt would also block. To keep the gate focused, `.swiftlint.yml` disables the repo’s existing non-HIG SwiftLint debt and leaves the hard block centered on HIG rules.
- **Error vs warning severity:** raw RGB colors, literal live-content frames, literal `.font(.system(size:))`, nested `NavigationStack` inside `.sheet`, and sub-44pt gestures have direct dark-mode, Dynamic Type, or task-flow consequences. They should be treated like build-breaking correctness issues, not advisory warnings.

## Consequences

- `build.sh` now runs SwiftLint before any `xcodebuild` work and exposes `./build.sh lint` with the emoji reporter for local feedback.
- `.github/workflows/ci.yml` now installs SwiftLint via Homebrew and runs a dedicated strict lint step before `./build.sh`.
- `app/Package.swift` carries the exact plugin pin so future SwiftPM/Xcode invocations can keep using the same rule file without shipping SwiftLint in the app.
- Current baseline is intentionally red: the new harness surfaces **16 HIG violations** on today’s tree — `11` `hardcoded_frame_dimensions`, `4` `literal_system_font_size`, and `1` `navigation_stack_in_sheet`. Those fixes stay with issues `#95` and `#96`, not this wiring branch.

## Validation

- `swift package resolve --package-path app` resolved `SwiftLintPlugins` at `0.63.2`.
- `./build.sh` now fails fast on SwiftLint errors with Xcode-style file/line output when `swiftlint` is present.
- `./build.sh lint` emits fast local feedback and exits non-zero on the current HIG violations.
- With `swiftlint` intentionally absent from `PATH`, `RUN_TESTS=false ./build.sh` still completes successful Debug + Release builds.
- The post-change `xcodebuild test` path still exits non-green because of the repo’s existing two Swift Testing known-issue records in `ForecastPickerLogicTests`; this branch does not change app/test logic.

---

# Kwame decision inbox — SwiftLint strict day-1 HIG tightening

- **Date:** 2026-05-22T03:32:09-07:00
- **Author:** Kwame (iOS Developer — Modern Swift & WeatherKit)

## Decision

Tighten the SwiftLint HIG gate so layout/touch/typography rules are hard errors from day 1 and `missing_min_touch_target` no longer accepts literal `minHeight: 44` / `56` as compliant. The rule now only treats nearby `.frame(...minWidth|minHeight: someIdentifier)` usage as a pass, which is the regex-level proxy for requiring `@ScaledMetric`-backed touch-target floors.

## Context

The user overruled Iris’s softer rollout policy and the literal `44` / `56` exception. The rationale is concrete: iPhone SE/mini widths combined with AX5 Dynamic Type make fixed 44pt touch targets feel cramped, while `@ScaledMetric` lets the hit area grow with the user’s preferred text size.

This branch is config-only. It should intentionally turn more existing UI debt red without attempting the cleanup itself; those fixes stay with issues `#95` and `#96`.

## Trade-offs

- **Regex heuristic vs real semantic validation:** SwiftLint custom regex rules cannot prove that an identifier is declared with `@ScaledMetric`. The chosen heuristic only distinguishes a bare identifier from a literal number near `Button` / `.onTapGesture`. Perfect enforcement would require AST-aware analysis.
- **Broader touch-target failures:** Buttons that rely on platform defaults or styling, rather than an explicit identifier-backed `minWidth` / `minHeight`, now fail this rule. That is intentional under the strict-day-1 policy; justified exceptions must use a per-line disable comment and PR rationale.
- **Hard-error rollout:** No grace period means CI will go red immediately on current debt. That is the point of this policy change, not an accidental side effect.

## Consequences

- `.swiftlint.yml` now states the hard-gate policy in its header and keeps the existing layout/touch/typography rules at `severity: error`.
- `missing_min_touch_target` now flags literal touch-target floors and bare `Button` / `.onTapGesture` sites without a nearby identifier-backed minimum frame.
- The strict lint baseline rises from `16` to **31 violations** on the current tree: `15` `missing_min_touch_target`, `11` `hardcoded_frame_dimensions`, `4` `literal_system_font_size`, and `1` `navigation_stack_in_sheet`.

## Validation

- `swiftlint --strict --config .swiftlint.yml` now fails with **31 violations** on the current tree.
- No app code was modified; this change is limited to lint policy + supporting squad documentation.

---

## 2026-05-22 — Loop-30 triage (PR #111 UI-runner flake, PR #113 dedup hotfix)

# Gaia — Loop-30 mid-iteration triage: PR #111 UI-runner flake + PR #113 hotfix snapshot + next-WI dispatch plan

**Date:** 2026-05-22T19:10:00Z
**Author:** Gaia (Lead/Architect)
**Loop:** 30, mid-iteration (post-WI-loop30-2 PR #112 merge)
**Branch under triage:** `squad/wi-loop29-6-adr0002-dedup-hotfix` (HEAD `0983b40`)
**main:** `5550612` ("Iris history: WI-loop29-6 rebase post-mortem")

### PR #111 — WI-loop29-5 toolbar XCUI flake stabilisation

**URL:** https://github.com/yashasg/uv-burn-timer/pull/111
**Head:** `squad/wi-loop29-5-toolbar-xcui-flake-stabilize`
**Pre-rerun CI:** 1× SUCCESS (run `26306378673`, completed 19:08:45Z), 1× FAILURE (run `26306380377`, completed 19:07:49Z).

#### Triage of the FAILURE run

Log excerpt (run `26306380377` job `77444122647`):

```
✘ Test run with 326 tests passed after 4.105 seconds with 2 known issues.
Testing failed:
  UVBurnTimerUITests-Runner (6246) encountered an error
  (The test runner failed to initialize for UI testing.
   (Underlying Error: Failed call to AXDisableAccessibilityOnTermination: kAXErrorCannotComplete))
** TEST FAILED **
##[error]Process completed with exit code 65.
```

**Diagnosis:** This is **not** a toolbar XCUI flake regression. The 326 core/unit tests (with the 2 expected `withKnownIssue` blocks) all **passed**. The failure is at the **XCTest runner-process layer** — the UI-test host failed to enable Accessibility on the simulator before any UI test could start. `kAXErrorCannotComplete` from `AXDisableAccessibilityOnTermination` is a known macOS/Xcode CI-runner symptom when the simulator boot or accessibility daemon (`accessibilityd`) is racy, and is wholly orthogonal to the toolbar-hit-target work in PR #111.

**Evidence this is infrastructure, not code:**
1. The **parallel** check (run `26306378673`) on the **same SHA** is SUCCESS. Code-driven failures do not pass on one runner and fail on a parallel runner with the identical commit.
2. The failure is pre-test-launch (no XCUITest user code executed) — `Failed call to AXDisableAccessibilityOnTermination` fires during runner termination/init handshake.
3. The 326-test unit/Swift Testing leg passed cleanly. If PR #111's toolbar stabilisation had regressed, we would expect failures *inside* the UI tests, not at runner-init.

#### Verdict for PR #111

**(a) Re-run the failed job** — done now via `gh run rerun 26306380377 --failed`. Expect green on the rerun based on the parallel run's success on the same SHA.

**Not (b) supersede:** WI-loop30-1 (UI-runner toolbar flake bisection, Kwame + Ma-Ti) **subsumes the *underlying infra flake category*** but does **not** invalidate PR #111's payload (the actual toolbar test-helper stabilisation). PR #111 should land on its own merits once CI is green; WI-loop30-1 will operate *across* PR #111 + future PRs to bisect the runner-init flake itself.

**Not (c) fix-commit:** there is no code in PR #111 that can fix `kAXErrorCannotComplete` — that lives in the CI workflow (simulator preheat, runner retry policy, or pinned Xcode/iOS-sim version), which is a separate WI.

**Action item harvested for WI-loop30-1:** Add this run's failure log (run `26306380377`) to the bisection corpus. Pattern signature: `kAXErrorCannotComplete` + `AXDisableAccessibilityOnTermination` + pre-test-launch + parallel-runner-success-on-same-SHA. This is now at least the second sighting in Loop-29 → Loop-30 (also recall the WI-2-flake carry-forward).

### PR #113 — WI-loop29-6 hotfix snapshot

**URL:** https://github.com/yashasg/uv-burn-timer/pull/113
**Head:** `squad/wi-loop29-6-adr0002-dedup-hotfix` (HEAD `0983b40`)
**CI at 19:10Z:** 2× build-test **IN_PROGRESS** (runs `26306584189` started 19:06:49Z, `26306592197` started 19:07:34Z). No FAILURE yet.

**Status:** poll-only this dispatch — do not block. Expected wall-clock to first-check completion ≈ 5–6 min from start (typical leg time on this repo). I'll re-check on the next dispatch tick. No action item until both legs are SUCCESS or one is FAILURE.

**Merge plan when green:** squash-merge (consistent with PR #112), then close-by-merge for the rebase post-mortem cycle. After merge, rebase `squad/wi-loop29-5-toolbar-xcui-flake-stabilize` (PR #111) on the new `main` so it carries the dedup hotfix before its own merge.

### Next 2–3 WIs to dispatch in parallel **after PR #113 lands**

Three are dispatchable in parallel; one (WI-loop30-4) stays gated.

#### Dispatch slot 1 — **WI-loop30-1: UI-runner toolbar flake bisection**
- **Owner:** Kwame (lead, iOS XCUITest surface) + Ma-Ti (test-infra/contract evidence)
- **Scope:** Bisect the UI-runner init flake category specifically. Inputs: PR #111 run `26306380377` failure log; WI-2-flake notes from Loop-28 carry-forward; current `.github/workflows/ci.yml` simulator preheat / runner version pinning.
- **Deliverable:** Either (a) a CI-workflow PR adding simulator preheat + accessibilityd warm-up + bounded runner retry, *or* (b) an ADR concluding the flake is unfixable at our layer and proposing an XCUITest-tier retry harness. **Not** a Swift code change to `app/`.
- **TDD note:** Validation criterion is statistical (≥20 consecutive UI-test legs green on `main`), not unit-testable.

#### Dispatch slot 2 — **WI-loop30-3: decisions.md compaction (460 KB → <150 KB)**
- **Owner:** Scribe (already spawning in parallel per coordinator)
- **Scope:** Preserve all binding decisions; compress per-loop chatter to one-line entries; lift any still-load-bearing rationale into ADRs (`docs/adrs/`). Loop-22-and-earlier "narrative" sections are the highest-yield compaction targets — they predate the ADR system.
- **Constraint:** Decisions referenced by hash/anchor elsewhere in `.squad/` must keep stable anchors. Run a grep audit before deletion.
- **Acceptance:** `wc -c .squad/decisions.md < 150000`; `git grep` for any pre-compaction decision-anchor still resolves.

#### Dispatch slot 3 — **WI-loop30-6: Privacy Policy hosting**
- **Owner:** Plunder (already spawning in parallel) + yashasg (final URL ownership + DNS/host)
- **Scope:** Plunder produces the policy text (already drafted in prior loops — confirm the current canonical copy in repo before regenerating) and a hosting recipe (GitHub Pages on a `gh-pages` branch is the lowest-cost option matching prior squad practice). yashasg supplies the final URL and toggles DNS if a custom domain is wanted.
- **Constraint:** This is the silent Goal-4 blocker per Loop-26 history note. Until the URL is live and wired into `ProductCopy.privacyPolicyURL` (or equivalent), "Expert approved" cannot go green.
- **Agent boundary:** Plunder must NOT fabricate the URL or commit a placeholder that pretends to be live — that would violate WI-21 automation-status posture by analogy. Either land a real URL or surface "blocked on owner action".

#### Gated — **WI-loop30-4: HIG-rule cluster (Iris → Kwame)**
- **Hold** until WI-loop30-2's AST spike (per ADR-0003, filed Loop-30 iter-1) closes with a verdict. Reason: per my history note "the right moment to make a regex-vs-AST decision is before the next batch of rules ships". If we dispatch loop30-4 now with regex rules and the spike subsequently passes, we will have locked in five more units of brittleness tax for one loop cycle's saved wall-clock — net negative.

### Goal-5 movement

**No movement. Still FAIL.** Both `iris-contrast-qa-checklist.md` and `iris-launch-readiness-checklist.md` sign-off blocks remain blank. WI-21 automation-status clause is in force: no agent (Iris, Plunder, Gaia, or otherwise) may fill them. Requires owner `yashasg` + physical OLED iPhone + WCAG measurement tool + linear polarizing filter. Surfaced in this dispatch; will continue to surface every loop until resolved. Do not allow drift to "PARTIAL".

### Carry-forward & open questions

- The `kAXErrorCannotComplete` flake pattern is now repeat-observed. After WI-loop30-1's bisection lands, file a follow-up ADR if the resolution is structural (e.g., we commit to runner-retry semantics in CI) — this is the kind of cross-cutting infra decision that deserves an ADR slot.
- After PR #113 lands and PR #111 reruns green, the next decision point is whether WI-loop30-4 dispatches **as regex rules with a sunset clause** or **waits flat for the AST spike**. My current lean is wait-flat; revisit at the next dispatch tick.

— Gaia

---

## 2026-05-22 (Loop-30 iter-2 closure — 4 PRs merged, merge-sweep)

### Gaia — Loop-30 iter-2 merge-gate sweep

- **Date:** 2026-05-22T20:10:00Z  
- **Scope:** Reviewer-discipline sweep across three Loop-30 iter-2 PRs (#114 / #115 / #116); all merged first-pass, no rejections

**Merge summary:**
| PR  | Author | Status    | Merge SHA   |
|-----|--------|-----------|-------------|
| 115 | Gaia   | merged    | `f616517`   |
| 114 | Kwame  | merged    | `5b899df`   |
| 116 | Ma-Ti  | merged    | `1a4eecb`   |

**Key outcomes:**
- ADR-0003 flipped to Accepted (markdown-only, spike-backed)
- Cross-agent reviewer discipline held (Gaia reviewed Kwame PR #114 and Ma-Ti PR #116)
- AST gate live on main (belt-and-braces with regex)
- Stash hygiene: `scribe-loop30-iter2-deferred` applied, `gaia-pre-mergesync-iris-mati-history` dropped
- Inbox merged (Scribe closure logging recorded)

**Loop-30 iter-2 goals:**
- ✅ Goal-1: UI flake stabilisation (PR #111 + #114)
- ✅ Goal-2: ADR-0003 spike verdict (PR #115)
- ✅ Goal-3: AST gate integration (PR #116)
- 🟡 Goal-4: Privacy policy hosting (blocked, Plunder WI-30-6 spawned)
- ❌ Goal-5: Contrast QA (hardware-blocked)

**Iter-3 dispatch ready:** WI-30-1 (Kwame+Ma-Ti flake bisection), WI-30-3 (Scribe decisions compaction), WI-30-6 (Plunder privacy policy)
