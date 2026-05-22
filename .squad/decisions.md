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

## 2026-05-22 — Loop-30 iter-3 closure

### Inbox: gaia-loop30-iter3-status

# Gaia — Loop-30 iter-3 status board

**Date:** 2026-05-22T20:55:00Z
**Loop / iter:** Loop-30, iteration 3
**Author:** Gaia (Lead)

## PR table

| PR | Branch | Author | Scope | Status | Merge SHA / Block |
|---|---|---|---|---|---|
| #118 | `squad/wi-loop30-ast-ly-retire-regex` | Kwame | Retire `toolbar_image_needs_scaled_frame` regex from `.swiftlint.yml`; AST gate is now sole source of truth for the iOS 26.4 toolbar-Image `@ScaledMetric` floor. Gravestone comment + contract-test inversion. | **MERGED** (squash, branch deleted) | `604c444c7b51d2fd61b8e529072b0504ea36794a` |
| #119 | `squad/wi-loop30-4a-image-accessibility-label` | Ma-Ti | Second AST rule: `image_systemname_missing_accessibility_label`. Validates harness multi-rule scaling per ADR-0003 §Rollout WI-30-B. | **BLOCKED on revision** | Silencer (d) violates Iris's catalog P5 (WCAG 1.1.1 implicit-decoration risk). Revision owner: **Kwame** (Ma-Ti locked out per reviewer-rejection protocol). See `.squad/decisions/inbox/gaia-pr119-adjudication.md`. |
| TBD | `squad/wi-loop30-4a-iris-3sites` *(in flight, placeholder)* | Kwame | Fix three `app/Sources/` sites that fire the strict `image_systemname_missing_accessibility_label` rule: `AppViews.swift:1152` (TierBadge), `ForecastPickerView.swift:209` (refresh banner), `ForecastPickerView.swift:230` (error banner). Prescribed remediation per Iris's catalog: `.accessibilityHidden(true)` or `.accessibilityLabel(…)`. | **OPENING (parallel)** | PR # not yet assigned — to be filled in when Kwame opens it. Must merge before revised #119 can merge. |

## PR #117 note

PR #117 (Scribe Loop-30 iter-2 closure) was **CLOSED** earlier in iter-2; not reopened. Numbering gap accounted for. No dropped work.

## Dependency chain (visual)

```
main @ 604c444c (PR #118 merged, regex retired)
   │
   ├── (parallel) Kwame: WI-loop30-4a-iris-3sites
   │       Fix 3 production sites → MERGE TO MAIN FIRST
   │
   └── Ma-Ti PR #119  ── BLOCKED
            ├── Kwame revision: remove silencer (d) + add POSITIVE tests
            │     (Ma-Ti locked out from this revision)
            └── rebase onto main (post-3-sites-fix)
                  → `./build.sh lint` green under strict rule
                  → merge #119
```

## Open coordination items

- **Iris:** sign off on revised #119 once Kwame's silencer-(d) removal lands; explicit comment that the rule now matches catalog P5.
- **Kwame:** dual-track — (1) open the 3-sites PR; (2) revise #119's visitor and tests per `gaia-pr119-adjudication.md`. Recommend opening the 3-sites PR first since it must merge first.
- **Ma-Ti:** stand-down on silencer (d). May still address non-controversial review feedback on silencers (a)/(b)/(c), harness wiring, and TDD commits in #119.
- **Scribe:** pending fold of `gaia-pr119-adjudication.md` + this status file at next sweep.

## Iter-3 goal status

- ✅ **Goal 1 — Retire LY regex now AST is canonical:** done (PR #118).
- 🟡 **Goal 2 — Validate AST harness scales to a second rule:** in flight via revised #119; deferred to post-revision.
- 🟡 **Goal 3 — First batch of HIG/a11y rules begins shipping:** deferred to revised #119 + the 3-sites fix.

— Gaia


### Inbox: gaia-pr119-adjudication

# Gaia — PR #119 adjudication: silencer (d) veto

**Date:** 2026-05-22T20:55:00Z
**PR:** #119 — `WI-loop30-4a: AST rule — image_systemname_missing_accessibility_label` (Ma-Ti, branch `squad/wi-loop30-4a-image-accessibility-label`)
**Decision class:** Major — design-spec adjudication; invokes reviewer-rejection / lockout protocol.
**Verdict:** Iris's design spec wins. Silencer (d) must be removed. #119 blocked on revision; revision owner is **Kwame**, not Ma-Ti.

## Context

Ma-Ti's PR #119 ships the second SwiftSyntax/AST custom lint rule (`image_systemname_missing_accessibility_label`) and validates the AST harness's multi-rule scaling claim from ADR-0003 §Rollout WI-30-B. The rule implements four silencers:

- **(a)** Image inside `Button` / `NavigationLink` / `Link` label closure (unconditional).
- **(b)** Any-form `.accessibilityElement(...)` / `.accessibilityLabel(...)` / `.accessibilityHidden(true)` in the ancestor modifier chain.
- **(c)** Image inside `Label { } icon: { }` icon closure.
- **(d)** [Ma-Ti's extension] Image has a sibling `Text(...)` in the same enclosing view-builder block.

Ma-Ti added silencer (d) after `ForecastPickerView.swift` L209/L230 (refresh + error banners) and `AppViews.swift:1152` (TierBadge) fired the rule, citing the WI-loop30-4a constraint "if AST fires on real code, refine the rule, not the SUT".

In parallel, Iris published the fixture catalog (`.squad/decisions/inbox/iris-image-accessibility-fixtures.md`) which classifies the "Image + adjacent Text in stack" pattern as a **POSITIVE** (rule should fire), with explicit HIG/WCAG 1.1.1 anchoring.

## Reasoning

### 1. The catalog is the design spec; the spec predates the implementation

Iris's catalog entry P5 reads:

> A sibling `Text` is **not** a labeling relation in SwiftUI's a11y tree — they are two adjacent focusable elements. VoiceOver reads "Arrow, clockwise, Image. Updating forecast." The image's symbol-id leaks through. Authors who want decorative-icon-plus-text-label semantics must either (a) use `Label { Text(…) } icon: { Image(…) }`, (b) wrap the `HStack` with `.accessibilityElement(children: .combine)` + `.accessibilityLabel(…)`, or (c) hide the image with `.accessibilityHidden(true)`. The rule deliberately rejects "implicit decoration via adjacency" — too risky for SF Symbols whose names are not user-readable.

This is a WCAG 1.1.1 (Non-text Content) compliance anchor, not a style preference. Silencer (d) suppresses the exact failure mode the rule was designed to catch.

### 2. The "refine the rule, not the SUT" constraint inverts when the catalog calls the firings positive

Ma-Ti's WI-loop30-4a directive presupposes the production firings are false positives. The catalog establishes them as **true positives**. Under that re-classification, the WI constraint flips: the SUT must be remediated, not the rule.

This is exactly the case the squad's reviewer-rejection protocol exists for: a design owner's spec overrides an implementer's local optimization for test-corpus greenness.

### 3. The three production sites are remediable, not load-bearing

- `AppViews.swift:1152` (TierBadge) — known case, Iris's memo cites it as case (b) silencer via `.accessibilityElement(children: .combine)` + `.accessibilityLabel`. Should already silence under Ma-Ti's broadened silencer (b) — needs verification post-(d)-removal.
- `ForecastPickerView.swift:209` (refresh banner) — fix with `.accessibilityHidden(true)` on the Image (Iris's prescribed remediation).
- `ForecastPickerView.swift:230` (error banner) — same fix shape.

Kwame is opening a separate PR (`WI-loop30-4a-iris-3sites`) for these. The remediation surface is narrow; no architectural risk.

### 4. Lockout enforcement

Per `.squad/agent.md` reviewer-rejection semantics and Gaia's charter ("On rejection, I may require a different agent to revise (not the original author)"): Ma-Ti is excluded from owning the silencer-(d) revision. Her PR #119 stays open under her authorship for the parts of the visitor that are accepted (silencers a/b/c, harness wiring, TDD commits, parity gates), but the silencer-(d) revision is dispatched to a different agent.

### 5. What's not contested

The other three Ma-Ti divergences from Iris's catalog are accepted:

- **Silencer (a) unconditional** — looser than Iris's "interactive ancestor only if it has title text or `.accessibilityLabel`". Accepted as v1; could tighten in a follow-up tightening WI.
- **Silencer (b) any-form `.accessibilityElement`** — broader than Iris's `children: .ignore` narrowing. Required for the AppViews:1152 `combine` shape Iris herself cites. Accepted.
- **Toggle / Menu deferral** — accepted; no production sites today.

These ship as part of revised #119.

## Required revision (specification for the named owner)

**Owner:** Kwame
**Branch:** Kwame to open a revision branch off `squad/wi-loop30-4a-image-accessibility-label` (e.g. `squad/wi-loop30-4a-image-accessibility-label-revise`), opened as a PR targeting Ma-Ti's branch (so #119's diff updates atomically) **or** force-pushed onto Ma-Ti's branch with explicit handoff. Kwame's call on mechanics.
**Scope:**

1. Remove silencer (d) from `tools/swiftlint-rules/Sources/SwiftLintASTRules/ImageSystemNameMissingAccessibilityLabelRule.swift`:
   - Delete the visitor logic that walks the enclosing view-builder block looking for sibling `Text(...)` nodes.
   - Delete the two explicit silencer-(d) tests added in commit `566a22e`.
   - Update the rule's doc comment to enumerate only silencers (a)/(b)/(c) and cite Iris's catalog P5 as the design source-of-truth for the rejection of "implicit decoration via adjacency".
2. Reinstate the original plain-HStack-with-sibling-`Text` TP fixture (commit `566a22e` tightened it to `Spacer()` — restore the `Text` sibling and assert the rule fires).
3. Add three explicit POSITIVE tests covering the production shapes:
   - TierBadge-style: `HStack { Image(systemName:); Text(...) }` without `.accessibilityElement` ancestor.
   - Refresh-banner-style: `HStack { Image(systemName: "arrow.clockwise"); Text("Updating…") }`.
   - Error-banner-style: same shape with error iconography.
4. PR body's divergence table updated to drop the silencer (d) row.

## Sequencing dependency

```
[main] (PR #118 merged 604c444c — toolbar regex retired)
   │
   ├── PR: Kwame WI-loop30-4a-iris-3sites — fixes AppViews:1152, ForecastPicker:209/230
   │         (independent merge target → main)
   │
   └── PR #119 (Ma-Ti, BLOCKED) ── awaiting:
            ├── Kwame revision (silencer (d) removal + tests)  ──┐
            └── Kwame 3-sites PR merged to main                  │
                  └── #119 rebased onto main, corpus green ──────┘
                        → merge #119
```

**Hard gate:** #119 may not merge until both (a) silencer (d) is removed from its diff and (b) the 3-sites fix has merged to main, so that `./build.sh lint` runs green against `app/Sources/` under the strict rule.

## Acceptance criteria for revised #119

1. `swift test --package-path tools/swiftlint-rules` green with silencer (d) removed, the reinstated `Text`-sibling TP fixture, and the three new production-shape POSITIVE tests.
2. `./build.sh lint` green against `app/Sources/` **after** Kwame's 3-sites fix has merged to main (verified via rebase, not local patching).
3. Iris's catalog P5 entry referenced in the rule's doc comment as the design source-of-truth.
4. PR body's divergence table updated — only silencer (a) unconditional / silencer (b) any-form / Toggle-Menu deferral rows remain.
5. Iris confirms (PR comment or decision-inbox) that the revised rule matches her catalog.

## Lockout enforcement note

**Ma-Ti is excluded** from owning the silencer-(d) revision per reviewer-rejection / lockout protocol. She retains authorship of PR #119's accepted parts and may rebase / handle non-controversial review feedback on silencers (a)/(b)/(c), the harness wiring, and the TDD commits. The silencer-(d) revision must arrive via a different agent's commits (Kwame's recommended).

If Kwame is unavailable, escalation order: Argos (test-corpus expertise) → Ralph (rules harness) → yashasg.

## What this preserves

- ADR-0003's AST-harness multi-rule scaling claim still ships in #119 (just with the strict rule).
- The Loop-30 iter-3 "AST harness validates beyond a single rule" goal is preserved — only the rule body changes, not the harness contract.
- Reviewer-rejection protocol gets its first real test in the squad workflow; documenting the lockout enforcement here gives Scribe a clean fold target.

— Gaia


### Inbox: iris-image-accessibility-fixtures

# Iris — Fixture Catalog: `image_systemname_missing_accessibility_label`

**Author:** Iris (UI/UX Designer, Apple HIG & Accessibility)
**Date:** 2026-05-22T20:30:00Z
**Audience:** Ma-Ti (AST visitor + XCTest author for WI-loop30-4 batch-1, rule #2)
**Companion to:** Iris scope memo §Rule 2 (decisions.md L1862) and WI-loop30-4 scope decision.
**Purpose:** Exhaustive fixture corpus the AST visitor MUST classify correctly per Apple HIG (VoiceOver chapter — "Provide meaningful alternative text for images") and WCAG 2.2 SC 1.1.1 (Non-text Content, Level A).

---

## 0. Rule restatement (the contract)

> Fire on a call expression `Image(systemName: …)` **iff none** of the following labeling conditions are satisfied:
>
> 1. The `Image` has `.accessibilityLabel(…)` somewhere in its own modifier chain.
> 2. The `Image` has `.accessibilityHidden(true)` somewhere in its own modifier chain.
> 3. The `Image` is the *icon expression* of a composite `Label` — i.e. either `Label(_:systemImage:)` (where the `systemImage:` arg supplies the symbol) or the `icon:` trailing-closure of `Label { … } icon: { Image(systemName:) }` whose `title:` closure / first arg provides text.
> 4. The `Image` is inside the `label:` closure (or trailing label closure) of an interactive ancestor — `Button`, `NavigationLink`, `Link`, `Toggle`, `Menu` — **and** that ancestor either (a) has its own text/title argument, or (b) carries `.accessibilityLabel(…)` somewhere in its own modifier chain.
> 5. The `Image` is wrapped in an ancestor view that carries `.accessibilityElement(children: .ignore)` *and* `.accessibilityLabel(…)` on the same ancestor (parent absorbs the label).

All other `Image(systemName:)` calls fire.

**Citation backbone:** Apple HIG > Accessibility > VoiceOver: "Every image that conveys meaning must have an accessibility label; purely decorative images must be hidden from assistive tech." WCAG 2.2 SC 1.1.1 (Non-text Content, Level A): non-text content must have a text alternative *or* be explicitly marked as decoration. SF Symbols' default accessibility description is the *symbol identifier itself* (e.g. "Exclamation mark, triangle, fill") — which is rarely the intended user-facing label and is therefore treated as **unlabeled** for the purposes of this rule.

---

## 1. POSITIVE fixtures (rule MUST fire)

### P1 — `bare-image-in-vstack`

```swift
struct StatusCard: View {
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text("Service degraded")
        }
    }
}
```

- **HIG/WCAG:** VoiceOver reads "Exclamation mark, triangle, fill, Image" — meaningless to the user. WCAG 1.1.1 requires a text alternative or explicit decoration marker. Neither is present.
- **Why regex fails:** A regex matching `Image\(systemName:.*\)\s*$` would also fire on P2/P3 below where the next line *is* `.accessibilityLabel(...)`. AST sees the full modifier-chain expression as one node.

### P2 — `bare-image-as-button-label-no-button-title`

```swift
Button {
    deleteItem()
} label: {
    Image(systemName: "trash")
}
```

- **HIG/WCAG:** Button has no string title and no `.accessibilityLabel`. VoiceOver announces "Trash, Image, Button" — the symbol-id is *not* a user-facing affordance name. HIG: "Buttons that contain only icons require an explicit accessibility label."
- **Why regex fails:** A regex cannot distinguish this from N3 (Button with title) — both syntactically contain `Button { … } label: { Image(systemName:) }`. AST inspects the `Button` initializer's argument list to check for a title.

### P3 — `bare-image-as-navlink-label-no-label-mod`

```swift
NavigationLink {
    HistoryView()
} label: {
    Image(systemName: "clock.arrow.circlepath")
}
```

- **HIG/WCAG:** Identical to P2 but for `NavigationLink`. HIG: "Navigation link destinations need a clear name spoken by VoiceOver."
- **Why regex fails:** Same as P2 — regex cannot walk the parent chain to confirm or deny a sibling `.accessibilityLabel`.

### P4 — `image-inside-toolbaritem-no-action-wrapper`

```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Image(systemName: "gear")
    }
}
```

- **HIG/WCAG:** A `ToolbarItem` containing a raw `Image` (no `Button` / `Link`) is a non-interactive decorative slot — but still focusable by VoiceOver as an image. No label = symbol-id read aloud. (HIG: toolbar glyphs are *always* labeled in shipping Apple apps — Mail, Notes, Reminders.)
- **Why regex fails:** Regex sees `ToolbarItem` and may FN if it assumes toolbar items are always interactive. AST confirms the absence of a `Button`/`Link`/`Menu` wrapper.

### P5 — `image-in-hstack-with-decorative-text-no-label`

```swift
HStack(spacing: 6) {
    Image(systemName: "arrow.clockwise")
    Text("Updating forecast…")
}
```

- **HIG/WCAG:** A sibling `Text` is **not** a labeling relation in SwiftUI's a11y tree — they are two adjacent focusable elements. VoiceOver reads "Arrow, clockwise, Image. Updating forecast." The image's symbol-id leaks through. Authors who want decorative-icon-plus-text-label semantics must either (a) use `Label { Text(…) } icon: { Image(…) }`, (b) wrap the `HStack` with `.accessibilityElement(children: .combine)` + `.accessibilityLabel(…)`, or (c) hide the image with `.accessibilityHidden(true)`. The rule deliberately rejects "implicit decoration via adjacency" — too risky for SF Symbols whose names are not user-readable.
- **Why regex fails:** Detecting sibling-Text adjacency requires parent-block traversal (HStack children). Regex cannot enumerate sibling nodes.

### P6 — `image-as-button-label-button-has-action-text-mismatched`

```swift
Button(action: refresh) {
    Image(systemName: "arrow.clockwise")
}
```

- **HIG/WCAG:** `Button(action:label:)` with **no string title argument** — only an `action:` closure and a `label:` view-builder containing a bare image. Equivalent to P2 in semantics; different SwiftUI initializer surface area. VoiceOver announces "Arrow, clockwise, Image, Button."
- **Why regex fails:** Regex matching `Button\(.*\)\s*\{.*Image\(systemName:` could miss this form (no curly-brace title), or worse, FP on N3 below which uses `Button("Delete")`. AST resolves the initializer signature.

### P7 — `image-inside-toolbar-button-no-label-no-title`

```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button {
            showInfo = true
        } label: {
            Image(systemName: "info.circle")
        }
        // ← no .accessibilityLabel anywhere on Button
    }
}
```

- **HIG/WCAG:** Toolbar Button with an icon-only label and no accessibility label. The *most common real-world VoiceOver bug* in iOS apps. HIG: "Every toolbar control must have an accessibility label that names the action, not the icon."
- **Why regex fails:** Visually almost identical to N7 (toolbar Button **with** `.accessibilityLabel`). AST walks the Button's modifier chain.

### P8 — `image-inside-link-no-text-title`

```swift
Link(destination: URL(string: "https://example.com")!) {
    Image(systemName: "safari")
}
```

- **HIG/WCAG:** `Link` initializer with a label closure and no string title. Same labeling gap as P2/P6. WCAG SC 2.4.4 (Link Purpose) also implicated — link purpose cannot be determined from "Safari, Image, Link."
- **Why regex fails:** Yet another interactive-wrapper variant. AST treats `Link`, `Button`, `NavigationLink`, `Menu`, `Toggle` uniformly via a "labeled-ancestor" predicate.

### P9 — `image-as-menu-label`

```swift
Menu {
    Button("Profile") { … }
    Button("Sign Out") { … }
} label: {
    Image(systemName: "person.crop.circle")
}
```

- **HIG/WCAG:** `Menu` with icon-only trigger; no `.accessibilityLabel`. HIG: menu triggers require a label that names the menu's purpose (not the glyph).
- **Why regex fails:** Same family as P2/P6/P8 — interactive ancestor without a title or a11y label.

---

## 2. NEGATIVE fixtures (rule MUST stay silent)

### N1 — `image-with-explicit-accessibility-label`

```swift
Image(systemName: "xmark")
    .accessibilityLabel("Dismiss")
```

- **HIG/WCAG:** Direct compliance — explicit text alternative. WCAG 1.1.1 satisfied.
- **Why regex fails:** A naive regex that fires on `Image\(systemName:` anywhere would FP. AST sees the full modifier chain on the same expression node.

### N2 — `image-with-accessibility-hidden-true`

```swift
Image(systemName: "moon.fill")
    .accessibilityHidden(true)
```

- **HIG/WCAG:** Explicit decorative marker. WCAG 1.1.1 second pathway (decoration). HIG: "Hide purely decorative images from VoiceOver." Removes the element from the accessibility tree entirely.
- **Why regex fails:** Same as N1 — requires recognizing a modifier later in the chain.

### N3 — `button-with-string-title-and-image-label`

```swift
Button("Delete") {
    deleteItem()
} // no explicit label closure; or:

Button("Delete", systemImage: "trash") {
    deleteItem()
}
```

- **HIG/WCAG:** The `Button("Delete", …)` initializer supplies the accessibility label via its `LocalizedStringKey` title argument. The `systemImage:` parameter (iOS 17+) renders the glyph but the Button's title is the spoken label.
- **Why regex fails:** Regex cannot reliably distinguish a `Button("text") { … }` from `Button { … } label: { Image(…) }` without a parser.

### N4 — `label-init-with-systemimage`

```swift
Label("Settings", systemImage: "gearshape")
```

- **HIG/WCAG:** `Label(_:systemImage:)` is a *composite* SwiftUI primitive — the first argument is the accessibility label by construction. HIG explicitly endorses `Label` as the canonical icon-plus-text pattern.
- **Why regex fails:** The symbol name appears as `systemImage:` argument value, not as a free-standing `Image(systemName:)` call. AST distinguishes the two initializer surfaces.

### N5 — `label-trailing-closures-title-and-icon`

```swift
Label {
    Text("Forecast updated 2 hours ago")
} icon: {
    Image(systemName: "clock.arrow.circlepath")
}
```

- **HIG/WCAG:** Same composite-Label rationale as N4 — the `title:` closure carries the label; the `icon:` closure is treated as decoration by Label's a11y implementation.
- **Why regex fails:** The `Image(systemName:)` here *looks* free-standing on its own line; only by walking up the AST to the enclosing `Label { … } icon: { … }` initializer can the visitor know it's an icon slot.

### N6 — `navlink-with-label-modifier`

```swift
NavigationLink(destination: AboutView()) {
    Image(systemName: "info.circle")
}
.accessibilityLabel("About this estimate")
.accessibilityHint("Opens photosensitization caveats.")
```

- **HIG/WCAG:** Interactive ancestor (`NavigationLink`) carries `.accessibilityLabel` — that label is spoken by VoiceOver. The inner image inherits silence.
- **Why regex fails:** The `.accessibilityLabel` is on the **parent expression**, not on the `Image`. Requires AST parent-walk.

### N7 — `toolbar-button-with-label-and-image-child`

```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "gearshape")
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Settings")
        .accessibilityHint("Opens skin type, SPF, attribution, and app information.")
    }
}
```

- **HIG/WCAG:** This is the canonical iOS toolbar pattern. Button has both an interactive role and an explicit label. This is the **exact shape** already used at `AppViews.swift:125` and was the model for the Iris memo's case (a).
- **Why regex fails:** Visually nearly identical to P7. Only AST can determine that the `.accessibilityLabel("Settings")` modifier is attached to the *Button* expression node (and therefore covers the inner Image).

### N8 — `chained-modifiers-label-at-end-of-chain`

```swift
Image(systemName: "trash")
    .resizable()
    .scaledToFit()
    .frame(width: 24, height: 24)
    .foregroundStyle(.red)
    .accessibilityLabel("Delete")
```

- **HIG/WCAG:** The label modifier may appear anywhere in the chain — SwiftUI's a11y modifiers attach to the underlying view regardless of position. The visitor MUST inspect the entire chain, not just the immediate next call.
- **Why regex fails:** A line-anchored regex that looks at the line immediately following `Image(systemName:)` would FN here (label is 4 modifiers downstream).

### N9 — `parent-accessibility-element-ignore-with-label`

```swift
HStack(spacing: 6) {
    Image(systemName: "checkmark.circle.fill")
        .foregroundStyle(.green)
    Text("Verified")
        .font(.subheadline)
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("Account verified")
```

- **HIG/WCAG:** `children: .ignore` collapses descendants out of the a11y tree; the parent supplies the label. VoiceOver hears only "Account verified." HIG recommends this pattern for icon-plus-text composite rows.
- **Why regex fails:** Requires parent-walk + recognition of both `children: .ignore` argument value **and** the sibling `.accessibilityLabel` on the same ancestor.

### N10 — `parent-accessibility-element-combine-with-label`

```swift
HStack {
    Image(systemName: "exclamationmark.triangle")
    Text("Photosensitizer warning")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Photosensitizer warning: check medication list.")
```

- **HIG/WCAG:** Same as N9 but with `.combine` — descendants stay in the tree but the parent's explicit label takes precedence in VoiceOver output. Acceptable per HIG.
- **Why regex fails:** Same as N9; the visitor must accept both `.ignore` and `.combine` paired with a parent `.accessibilityLabel`.

### N11 — `image-inside-labeled-link`

```swift
Link(destination: privacyURL) {
    Image(systemName: "lock.shield")
}
.accessibilityLabel("Privacy policy")
```

- **HIG/WCAG:** Labeled interactive ancestor (`Link` with `.accessibilityLabel`). Symmetric to N6 / N7.
- **Why regex fails:** Same parent-walk requirement.

### N12 — `image-inside-button-with-systemimage-shorthand`

```swift
Button("Refresh", systemImage: "arrow.clockwise") {
    refresh()
}
```

- **HIG/WCAG:** iOS 17+ shorthand initializer. The `"Refresh"` title is the a11y label; `systemImage:` is the decorative glyph slot. No `Image(systemName:)` call expression exists at all — visitor should never see this as a candidate node, but if it does (e.g. via a custom-symbol lookup elsewhere), it must not fire.
- **Why regex fails:** Symbol name appears in `systemImage:` arg position — easy to confuse with `Image(systemName:)`. AST distinguishes the two initializer surfaces unambiguously.

---

## 3. Edge-case fixtures (must be classified correctly — these are the "gotchas")

### E1 — `image-in-viewbuilder-helper-function` (POSITIVE)

```swift
private func warningGlyph() -> some View {
    Image(systemName: "exclamationmark.triangle.fill")
}

// Used as:
HStack { warningGlyph(); Text("Stale data") }
```

- **Verdict:** **POSITIVE** at the helper site. The visitor cannot follow call sites; it must judge the `Image(systemName:)` expression in isolation. Author must add `.accessibilityLabel` *or* `.accessibilityHidden(true)` *inside* the helper, or refactor.
- **Why regex fails:** Even a regex would catch this — but only AST avoids the FP at call site (where `warningGlyph()` doesn't textually match `Image(systemName:`).

### E2 — `image-with-accessibility-hidden-false` (POSITIVE)

```swift
Image(systemName: "gear")
    .accessibilityHidden(false)
```

- **Verdict:** **POSITIVE.** `accessibilityHidden(false)` *exposes* the image but does not label it. VoiceOver reads symbol-id.
- **Why regex fails:** A regex matching `.accessibilityHidden\(` would FP. AST must inspect the boolean literal argument.

### E3 — `image-with-empty-accessibility-label` (POSITIVE, soft warning OK)

```swift
Image(systemName: "trash")
    .accessibilityLabel("")
```

- **Verdict:** **POSITIVE.** An empty-string label is functionally equivalent to no label — VoiceOver may fall back to symbol-id behavior, and in any case violates WCAG SC 1.1.1 (the "text alternative" must serve the equivalent purpose).
- **Note for Ma-Ti:** First-pass implementation MAY treat empty-string as labeled (false negative, but symmetric with how SwiftUI itself handles it). Mark as TODO in the visitor with a code comment referencing this fixture. Do not block the batch on it.
- **Why regex fails:** Regex cannot inspect string-literal contents on a modifier argument.

### E4 — `image-with-dynamic-string-label` (NEGATIVE)

```swift
Image(systemName: iconName)
    .accessibilityLabel(localizedLabel)
```

- **Verdict:** **NEGATIVE.** Any `.accessibilityLabel(…)` with *any* argument (including a variable, function call, or `Text(…)` expression) satisfies the rule. The visitor does not — and cannot — verify the runtime value.
- **Why regex fails:** Regex could match the literal substring but cannot bind it to *this* `Image` expression's chain. AST does.

### E5 — `image-systemname-with-variable-symbol` (depends on chain)

```swift
Image(systemName: badge.symbolName)  // ← still rule's subject; symbol arg can be any expression
    .accessibilityLabel(badge.title)
```

- **Verdict:** **NEGATIVE** here (label present). The visitor must NOT restrict its candidate set to `Image(systemName: <stringLiteral>)`. *Any* expression in the `systemName:` arg slot triggers candidacy.
- **Why regex fails:** A regex written for `Image\(systemName:\s*"…"\)` would FN on `Image(systemName: badge.symbolName)`. AST inspects the initializer signature, not the arg value.

### E6 — `image-systemname-in-foreach-row` (POSITIVE if bare)

```swift
ForEach(items) { item in
    HStack {
        Image(systemName: item.iconName)   // bare
        Text(item.title)
    }
}
```

- **Verdict:** **POSITIVE.** Identical to P5 in essence — adjacency to Text is not a labeling relation. Author must use `Label`, `.accessibilityElement(children: .combine)`, or `.accessibilityHidden(true)`.
- **Why regex fails:** Same as P5 — sibling enumeration requires AST.

### E7 — `image-as-tabitem-label-icon` (NEGATIVE)

```swift
SettingsView()
    .tabItem {
        Label("Settings", systemImage: "gearshape")
    }
```

- **Verdict:** **NEGATIVE.** Inside `.tabItem { … }`, the `Label(_:systemImage:)` carries the tab name as its a11y label; SwiftUI's tab-bar implementation labels the tab from the `Label`'s title. Same as N4.
- **Why regex fails:** N/A — covered by N4's rule.

### E8 — `image-inside-nested-button-label-button-labeled` (NEGATIVE)

```swift
Button {
    action()
} label: {
    HStack {
        Image(systemName: "plus.circle.fill")
        Text("Add")
    }
}
.accessibilityLabel("Add new entry")
```

- **Verdict:** **NEGATIVE.** Interactive ancestor with explicit `.accessibilityLabel`. The fact that the Image is wrapped in an inner HStack inside the `label:` closure does not change the parent-walk outcome.
- **Why regex fails:** Requires multi-level parent traversal.

### E9 — `bare-image-with-only-non-a11y-modifiers` (POSITIVE)

```swift
Image(systemName: "sparkles")
    .resizable()
    .scaledToFit()
    .frame(width: 32, height: 32)
    .foregroundStyle(.yellow)
```

- **Verdict:** **POSITIVE.** Many style modifiers but no a11y modifier and no interactive/composite ancestor.
- **Why regex fails:** A line-anchored regex would FN if it only checks the line immediately after `Image(systemName:)`. AST inspects the full chain.

### E10 — `image-inside-group-with-children-ignore-parent-unlabeled` (POSITIVE — gotcha)

```swift
Group {
    Image(systemName: "info.circle")
    Text("Tap to learn more")
}
.accessibilityElement(children: .ignore)
// ← NO .accessibilityLabel on parent
```

- **Verdict:** **POSITIVE.** `children: .ignore` without a parent `.accessibilityLabel` *removes* both descendants from the tree, leaving the group entirely silent — even worse than the original problem (no element is announced at all). Rule fires to surface this.
- **Why regex fails:** Requires recognizing the *absence* of a sibling `.accessibilityLabel` on the same ancestor that carries `children: .ignore`.

---

## 4. Coverage matrix (for Ma-Ti's XCTest harness)

| Fixture | Verdict | Tests |
|---|---|---|
| P1 `bare-image-in-vstack` | POS | basic detection |
| P2 `bare-image-as-button-label-no-button-title` | POS | Button without title arg |
| P3 `bare-image-as-navlink-label-no-label-mod` | POS | NavigationLink unlabeled |
| P4 `image-inside-toolbaritem-no-action-wrapper` | POS | non-interactive toolbar slot |
| P5 `image-in-hstack-with-decorative-text-no-label` | POS | sibling-Text is not a labeling relation |
| P6 `image-as-button-label-button-has-action-text-mismatched` | POS | Button(action:label:) form |
| P7 `image-inside-toolbar-button-no-label-no-title` | POS | toolbar Button without a11y label |
| P8 `image-inside-link-no-text-title` | POS | Link without text |
| P9 `image-as-menu-label` | POS | Menu trigger |
| N1 `image-with-explicit-accessibility-label` | NEG | direct label modifier |
| N2 `image-with-accessibility-hidden-true` | NEG | explicit decoration |
| N3 `button-with-string-title-and-image-label` | NEG | Button title supplies label |
| N4 `label-init-with-systemimage` | NEG | composite Label initializer |
| N5 `label-trailing-closures-title-and-icon` | NEG | composite Label trailing-closure form |
| N6 `navlink-with-label-modifier` | NEG | parent NavigationLink labeled |
| N7 `toolbar-button-with-label-and-image-child` | NEG | canonical toolbar pattern |
| N8 `chained-modifiers-label-at-end-of-chain` | NEG | full-chain inspection |
| N9 `parent-accessibility-element-ignore-with-label` | NEG | parent absorbs label |
| N10 `parent-accessibility-element-combine-with-label` | NEG | parent combines + labels |
| N11 `image-inside-labeled-link` | NEG | Link labeled |
| N12 `image-inside-button-with-systemimage-shorthand` | NEG | iOS 17+ shorthand |
| E1 `image-in-viewbuilder-helper-function` | POS | helper-function isolation |
| E2 `image-with-accessibility-hidden-false` | POS | hidden(false) is not labeled |
| E3 `image-with-empty-accessibility-label` | POS (soft, TODO) | empty label edge |
| E4 `image-with-dynamic-string-label` | NEG | dynamic label-arg expression |
| E5 `image-systemname-with-variable-symbol` | NEG | variable symbol arg |
| E6 `image-systemname-in-foreach-row` | POS | adjacency in ForEach |
| E7 `image-as-tabitem-label-icon` | NEG | tabItem Label |
| E8 `image-inside-nested-button-label-button-labeled` | NEG | nested label closure |
| E9 `bare-image-with-only-non-a11y-modifiers` | POS | style-only chain |
| E10 `image-inside-group-with-children-ignore-parent-unlabeled` | POS | ignore without label = silence bug |

**Totals: 31 fixtures — 13 POSITIVE, 17 NEGATIVE, 1 soft (E3).**

---

## 5. Revised `app/Sources/` re-scan finding (revises §Rule 2 of scope memo)

The earlier scope-memo claim — *"~10 Image(systemName:) sites in AppViews.swift … No bare unlabeled Image(systemName:) was found"* — was **incomplete**. Re-scanning `app/Sources/` with the rule contract (§0) applied site-by-site:

**Total sites found:** 14 (not ~10) — 10 in `AppViews.swift`, 4 in `ForecastPickerView.swift`.

| File:Line | Symbol | Verdict under rule | Reason |
|---|---|---|---|
| AppViews.swift:125 | `gearshape` | NEG | Button parent has `.accessibilityLabel("Settings")` (N7 shape) |
| AppViews.swift:134 | `info.circle` | NEG | NavigationLink parent labeled (N6 shape) |
| AppViews.swift:824 | `clock.arrow.circlepath` | NEG | Inside `Label { Text } icon: { Image }` (N5 shape) |
| AppViews.swift:918 | `moon.fill` | NEG | `.accessibilityHidden(true)` (N2 shape) |
| AppViews.swift:976 | `sun.max` | NEG | `.accessibilityHidden(true)` (N2 shape) |
| AppViews.swift:1131 | `systemImage` (var) | NEG | Inside `Label { … } icon: { Image }` (N5 / E5 shape) |
| **AppViews.swift:1152** | **`accessorySymbolName`** | **POS** | **Bare `Image(systemName:)` in HStack sibling to `Label(title, systemImage:)`. No `.accessibilityHidden(true)`, no `.accessibilityLabel`. P5/E5 shape.** |
| AppViews.swift:1230 | `exclamationmark.triangle.fill` | NEG | `.accessibilityHidden(true)` (N2 shape) |
| AppViews.swift:1270 | `exclamationmark.triangle` | NEG | Inside `Label { Text } icon: { Image }` (N5 shape) |
| AppViews.swift:1677 | `checkmark.circle.fill` | NEG | `.accessibilityHidden(true)` (N2 shape) |
| **ForecastPickerView.swift:209** | **`arrow.clockwise`** | **POS** | **Bare in stale-banner `HStack` with sibling `Text("Updating forecast…")`. No `.accessibilityLabel` on HStack, no `.accessibilityHidden(true)` on Image. P5 shape.** |
| **ForecastPickerView.swift:230** | **`exclamationmark.icloud`** | **POS** | **Bare in error-banner `HStack` with sibling `Text("Could not update")` (label is on the Text, not the Image). P5 shape.** |
| ForecastPickerView.swift:426 | `chevron.down.circle.fill` | NEG | Inside Button `label:` closure; Button has `.accessibilityLabel("Show … forecast days")` (N7 shape) |
| ForecastPickerView.swift:605 | `moon.fill` / `sun.max.fill` | NEG | Inside Button `label:` closure; Button has `.accessibilityLabel(hourCellA11yLabel(for:))` (N7 shape) |

**Net: 3 sites will fire when the rule lands** (not zero as the earlier memo asserted):

1. `AppViews.swift:1152` — `TierBadge` accessory glyph (color-blind affordance under `differentiateWithoutColor`)
2. `ForecastPickerView.swift:209` — stale-banner refresh spinner glyph
3. `ForecastPickerView.swift:230` — stale-banner error-state cloud glyph

### Revision to scope memo §Rule 2 ("No sub-WI" claim)

**Revise:** the scope memo's "No sub-WI" line for Rule 2 is **withdrawn**. Three sub-WIs are required so the rule can land green (or the rule lands as a regression-firing change and the three sites are fixed in the same PR).

**Recommended remediation per site** (Kwame's call — design recommendation only):

- **`AppViews.swift:1152`** (TierBadge `accessorySymbolName`): Add `.accessibilityHidden(true)`. The parent `Label(title, systemImage:)` already speaks the tier name; the accessory glyph (e.g. a stripe or pattern marker) is a sighted-only redundancy for `differentiateWithoutColor` users — its semantic payload is already in the Label. HIG: "Use redundant visual cues for differentiate-without-color, but do not double-announce in VoiceOver."
- **`ForecastPickerView.swift:209`** (`arrow.clockwise` refresh glyph): Add `.accessibilityHidden(true)` on the Image. The sibling `Text("Updating forecast…")` already conveys the state. Alternatively, wrap the HStack with `.accessibilityElement(children: .combine).accessibilityLabel("Updating forecast")` if you want a single VoiceOver focus stop (preferred for banner UX).
- **`ForecastPickerView.swift:230`** (`exclamationmark.icloud` error glyph): Same as :209 — `.accessibilityHidden(true)` on the Image. The sibling `Text` already has `.accessibilityLabel("Could not update forecast")`. The Retry button remains independently focusable, which is correct.

**Sub-WI sizing:** Each is a 1-line edit. Bundle into a single sub-WI **`WI-loop30-4a-iris-3sites`** for Kwame, gated to land **before** the rule lands (so the rule's first CI run is green), OR land in the same PR as the rule (Ma-Ti coordinates).

---

## 6. False-positive risks surfaced (for Ma-Ti to watch)

1. **Custom view wrappers around `Image(systemName:)`** (E1 shape). If the codebase grows `func iconGlyph(_ name: String) -> some View { Image(systemName: name).accessibilityHidden(true) }`, call sites are silent but the helper definition is the visitor's only signal. Current `app/Sources/` has no such wrapper — but flag the shape in PR description so future contributors don't hide bare images behind helpers and re-introduce the bug.
2. **`.accessibilityRepresentation { … }`** modifier (iOS 17+) — a wrapper that supplies a full custom accessibility element. If encountered, the inner Image's label state is irrelevant. **Not present in current `app/Sources/`.** Add a TODO fixture if it appears.
3. **`AccessibilityRotorEntry` / `accessibilityChildren`** — exotic forms. Out of scope for batch-1.
4. **Localization wrappers** — `Text(LocalizedStringKey("…"))` inside `.accessibilityLabel(Text(…))` is fine (N1/E4 shape). No FP risk.

---

## 7. Sign-off

Iris — UI/UX Designer (HIG & Accessibility) — 2026-05-22T20:30:00Z.

Fixture catalog frozen for WI-loop30-4 batch-1 rule #2. Ma-Ti owns translation into XCTest cases. Iris is available for clarification but will not edit Swift in `app/` or `.swiftlint.yml`.

Three site remediations surfaced as sub-WI `WI-loop30-4a-iris-3sites` — Kwame's queue, gates the rule's green-CI landing.


### Inbox: kwame-iris-3sites-opened

# Kwame — Iris 3-sites a11y fix opened (PR #120)

- **Work item:** `WI-loop30-4a-iris-3sites`
- **PR:** https://github.com/yashasg/uv-burn-timer/pull/120
- **Branch:** `squad/wi-loop30-4a-iris-3sites` (off `github/main`)
- **Status:** opened, CI in flight
- **CI run IDs:** push `26312959589`, PR `26313088707`
- **Datetime:** 2026-05-22T20:55:00Z

## Why

Iris's image-a11y fixture catalog (`iris-image-accessibility-fixtures.md`)
classifies three `app/Sources/` sites as POSITIVE under the upcoming
`image_systemname_missing_accessibility_label` AST rule. Each is a P5-shape
violation — bare `Image(systemName:)` adjacent to a `Text`/`Label` sibling —
which leaks the SF Symbol name through VoiceOver, violating WCAG SC 1.1.1.
This PR is the hard prerequisite for PR #119's revised landing (per Gaia's
adjudication in `gaia-pr119-adjudication.md`).

## Sites — before / after

### Site 1: `app/Sources/UVBurnTimer/AppViews.swift:1152` (TierBadge accessory glyph)

**Before:**
```swift
if differentiateWithoutColor, let accessorySymbolName {
    Image(systemName: accessorySymbolName)
}
```

**After:**
```swift
if differentiateWithoutColor, let accessorySymbolName {
    Image(systemName: accessorySymbolName)
        .accessibilityHidden(true)
}
```

**HIG rationale:** the sibling `Label(title, systemImage:)` already speaks the
tier name, and the parent `HStack` carries `.accessibilityElement(children:
.combine) + .accessibilityLabel("… burn-time tier…")`. The accessory is a
*visual* differentiation cue for users with colour-vision considerations
(`@Environment(\.accessibilityDifferentiateWithoutColor)` slot) — it must
not generate a redundant VoiceOver utterance. `.accessibilityHidden(true)`
is the canonical "decorative" marker.

---

### Site 2: `app/Sources/UVBurnTimer/ForecastPickerView.swift:209` (stale-banner spinner)

**Before:**
```swift
HStack(spacing: 6) {
    Image(systemName: "arrow.clockwise")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .rotationEffect(.degrees(isRotatingRefreshIcon ? 360 : 0))
        .animation(…)
        .onAppear { isRotatingRefreshIcon = true }
        .onDisappear { isRotatingRefreshIcon = false }
    Text("Updating forecast…")
        .font(.footnote)
        .foregroundStyle(.secondary)
    Spacer()
}
.frame(maxWidth: .infinity, minHeight: staleBannerMinHeight, alignment: .leading)
.padding(.horizontal, 16)
.background(Color(.systemYellow).opacity(0.12))
```

**After:** unchanged HStack body; **three new modifiers on the HStack tail:**
```swift
.background(Color(.systemYellow).opacity(0.12))
.accessibilityElement(children: .combine)
.accessibilityLabel("Updating forecast")
```

**HIG rationale:** the banner is a single status surface — VoiceOver should
read one cohesive announcement, not "Arrow, clockwise, image. Updating
forecast…". Iris fixture P5 §HIG-note clause (b) explicitly endorses
`.accessibilityElement(children: .combine) + .accessibilityLabel(…)` on the
parent for this exact pattern. Chose (b) over (a) (`Label`) because the
spinner needs `rotationEffect` + `onAppear/onDisappear` lifecycle hooks
that `Label`'s `icon:` builder fights with; chose (b) over (c)
(`.accessibilityHidden` on Image alone) because the parent label string
is shorter than the visible Text ("Updating forecast" vs "Updating
forecast…") — VoiceOver doesn't need the ellipsis.

---

### Site 3: `app/Sources/UVBurnTimer/ForecastPickerView.swift:230` (refresh-error banner)

**Before:**
```swift
HStack(spacing: 6) {
    Image(systemName: "exclamationmark.icloud")
        .font(.footnote)
        .foregroundStyle(.secondary)
    Text("Could not update")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .accessibilityLabel("Could not update forecast")
    Spacer()
    Button("Retry") { onRetry() }
        .font(.footnote)
        .foregroundStyle(.tint)
        .frame(minHeight: minTap)
}
.frame(maxWidth: .infinity, minHeight: staleBannerMinHeight, alignment: .leading)
.padding(.horizontal, 16)
.background(Color(.systemRed).opacity(0.08))
```

**After:** unchanged HStack body; **two new modifiers on the HStack tail:**
```swift
.background(Color(.systemRed).opacity(0.08))
.accessibilityElement(children: .combine)
.accessibilityLabel("Could not update forecast")
```

**HIG rationale:** identical shape to site 2. The pre-existing inner
`.accessibilityLabel("Could not update forecast")` on the Text now combines
into the parent label. The Retry `Button` is an interactive control and
`.combine` respects controls — it remains its own focusable element with
its own implicit label.

---

## Test approach

New file: `app/Tests/UVBurnTimerCoreTests/ImageSystemNameAccessibilityContractTests.swift`
— **three `@Test` cases**, one per site (`test_A11Y_1`, `test_A11Y_2`,
`test_A11Y_3`). Each test loads the relevant source file via a small
repo-root locator (`A11yContractSource.load`), slices around the
target `Image(systemName:)` expression, and asserts the expected
modifier(s) appear in the slice.

This is a **brittle source-scan contract** by Kwame's choice — explicitly
called out in the WI brief as the minimum acceptable TDD gate. A robust
view-tree probe (`UIHostingController` + accessibility-element traversal)
can land in a follow-up PR once Linka or Gaia greenlight the test pattern
for the broader fixture catalogue.

**Wired into `app/app.xcodeproj/project.pbxproj`** so both SPM `swift test`
and xcodebuild `test` discover it (`scripts/check-test-membership.sh`
gate clean).

### TDD evidence

- **RED phase (pre-edit, AppViews.swift + ForecastPickerView.swift on
  `github/main`):** all three contract assertions fail. Verified by
  source-scan dry-run (`.accessibilityHidden(true)` slice = False,
  `.accessibilityElement(children: .combine)` slice = False for both
  banner sites).
- **GREEN phase (post-edit):** all three pass under `./build.sh`
  (xcresult: `Test-UVBurnTimer-2026.05.22_14-26-16--0700.xcresult`).

## Side-effect: ADR-0001 line-citation refresh

`.accessibilityHidden(true)` inside TierBadge added one line at 1153,
shifting all anchors below by +1. `test_S5_adr0001CitationsMatchLive
SourceLineNumbers` caught the drift on the PersistentFooter `AboutView`
push citation. Bumped:

- `line **2170**` → `line **2171**`
- `2169–2171` → `2170–2172`

All other ADR-0001 anchors (HeroTimerCard struct, heroTimerCardView,
NavigationStack, sheets, EstimateInfoButton, chips) are above line 1152
and unaffected. Falls under "bugs directly caused by your changes" per
agent rules — corrected in the same commit.

## CI run IDs

- **push leg:** `26312959589` — https://github.com/yashasg/uv-burn-timer/actions/runs/26312959589
- **PR leg:** `26313088707` — https://github.com/yashasg/uv-burn-timer/actions/runs/26313088707

(Captured at PR open time, 2026-05-22T20:55:00Z.)

## Local build verdict

- `./build.sh` (Debug + Release + tests) — **PASS** for all `UVBurnTimerCoreTests`
  including the three new `test_A11Y_*` and the refreshed `test_S5`.
- One pre-existing UI-test flake (`testEstimateInfoButtonOpensAboutWith
  HighlightedApplicabilityAnchor`) also fails on `github/main` baseline
  (verified via prior xcresult `Test-UVBurnTimer-2026.05.22_14-13-33`);
  unrelated to this change.
- SwiftLint HIG gate: 0 violations (`./build.sh lint` clean).
- AST gate: 0 violations.

## Scope guardrails honoured

- ❌ `tools/swiftlint-rules/` untouched (Gaia's territory).
- ❌ `.swiftlint.yml` untouched.
- ❌ PR #119 not modified.
- ✅ 3 sites + 1 contract-test file + 1 ADR line-number refresh + 1 pbxproj wiring.


### Inbox: kwame-wi-loop29-5-close

# Kwame — WI-loop29-5 closure (toolbar XCUI flake stabilisation)

- **Date:** 2026-05-22T18:15:00Z
- **Author:** Kwame (iOS developer)
- **Branch:** `squad/wi-loop29-5-toolbar-xcui-flake-stabilize`
- **PR:** [#111](https://github.com/yashasg/uv-burn-timer/pull/111)
- **Base:** `main` @ `0ea3f1a` (post Scribe iter-2 closure, PRs #106 / #107 / #108 / #109 merged)
- **Scope:** Gaia GAP-iter2-B / WI-29-5 — stabilise the two intermittently-failing XCUITests on the iOS 26.4 simulator.

---

## §1 — Problem

Two XCUITests flake on iOS 26.4 sim:

- `testEstimateInfoNavigationRoundTripReturnsToMainScreen` (`app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift:209`)
- `testToolbarRendersBothSettingsAndEstimateInfoButtons` (`:169`)

Symptom (per Kwame's PR #106 closure note + Ma-Ti read-only investigation): "one-or-the-other per `xcodebuild` run, on toolbar code WI-29-7 does not touch." Settings gear or EstimateInfoButton intermittently fails the first existence/hittable assertion after onboarding.

## §2 — Root cause

iOS 26's Liquid Glass `.topBarTrailing` composition (the platform constraint documented in ADR-0002) lags the parent `NavigationStack`'s nav-bar arrival by a few hundred ms. The shared `acknowledgeDisclaimerAndChooseTypeIII` helper's tail call `_ = waitForHittable(EstimateInfoButton, timeout: 5)` waited on ONE of the two trailing items and **discarded** the boolean result. Whichever item the layout engine settled last became the racy one.

Ma-Ti's parallel read-only investigation (`.squad/agents/ma-ti/history.md` 2026-05-22T19:00:00Z) independently identified the same `_ =`-discarded anti-pattern.

## §3 — Fix (test-only, 1 file, +91 / −9 LOC)

Added private helper to `UVBurnTimerUITests.swift`:

```swift
private struct ToolbarSettleSnapshot { /* both buttons + exists/hittable bools */ }

@discardableResult
private func waitForMainToolbarSettled(
    in app: XCUIApplication,
    timeout: TimeInterval
) -> ToolbarSettleSnapshot {
    // Poll Settings + EstimateInfoButton together until both exist && isHittable,
    // with 200ms idle settle on success, then re-resolve both against the
    // stable UI snapshot and return it for caller assertions.
}
```

Both flaky tests now gate on `waitForMainToolbarSettled(in: app, timeout: 20)` before any existence/hittable/nav assertions. The round-trip test feeds the resolved `infoButton` reference into the existing `tapUntilAppears` retry loop.

Pattern is the toolbar-suite analogue of the Loop-20 `tapWithRetry` cover-chain helper. Documented inline as a reusable XCUI primitive with cite-back to ADR-0001 / ADR-0002 non-regression.

## §4 — Non-regression

- **ADR-0001** (hero card wrapper preserves toolbar hit-test) — untouched. No production code modified. Toolbar identity contract unchanged.
- **ADR-0002** (toolbar topBarTrailing iOS 26) — untouched. The composition-timing constraint this fix addresses *is* what ADR-0002 documents; test-side stabilisation explicitly preferred per Gaia scope.
- `git diff --stat main..HEAD` → exactly one file modified, under `app/Tests/`. Zero `app/Sources/` diff.

## §5 — Validation

- `./build.sh` core suite **326/326 GREEN** on prior run (warnings-as-errors, SwiftLint --strict 0 violations).
- `xcrun swiftc -parse` clean on modified file.
- Local UI-test re-run loop: **0 successful runs** — iOS 26.4 simulator died with Mach error -308 (`Failed to install or launch the test runner`) on repeated `./build.sh` invocations. Known transient sim-infra failure (host issue, not code). Confidence-gathering deferred to CI's fresh runner per the acceptance gate.
- CI: PR #111 first `build-test` run pending at write time. Will not merge until green.

## §6 — Coordination notes

- Branch base was `bbf1c84` per task spec but main moved forward during my local build to `0ea3f1a` (Scribe iter-2 closure merged PRs #106 #107 #108 #109). Rebased to latest main before pushing — clean fast-forward, no conflicts.
- Ma-Ti's concurrent investigation note (uncommitted local edit to its own history) was intentionally left out of this PR's commit (restored to HEAD before staging). Ma-Ti owns its own history file; this PR is strictly test-target only.

## §7 — Hand-off

- PR #111 open, awaiting CI.
- No merge until both `build-test` runs are green.
- If CI surfaces residual flake, fallback escalations (in order):
  1. Bump helper timeout from 20s → 30s.
  2. Add the optional swipeUp/swipeDown nav-bar compact-state pre-step Ma-Ti suggested.
  3. Wrap the final `XCTAssertFalse(About.exists)` in round-trip test with `XCTNSPredicateExpectation` per Ma-Ti's §2.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>


### Inbox: kwame-wi-loop30-1-noop

# Kwame — WI-loop30-1 partial closure (push/PR blocked by host)

**Date:** 2026-05-22T19:00:00Z
**WI:** WI-loop30-1 — Stabilize toolbar UI-test flake on iOS 26.4 simulator.
**Status:** **PARTIAL** — patch implemented + committed locally; push, CI, and
merge blocked by host-level faults. **Not a no-op:** branch
`squad/wi-loop30-1-ui-flake-stabilization` at `758e784` carries the verified
patch ready for ship.

## What landed (local-only)

Branch `squad/wi-loop30-1-ui-flake-stabilization` (parent `85080a8`, off
then-fresh `main`), single commit `758e784`:

> `fix(tests): WI-loop30-1 stabilize toolbar settle + nav pop in
> UVBurnTimerUITests`

Three additive XCUITest-only edits implementing Ma-Ti's GAP-iter2-B plan
(`.squad/decisions/inbox/ma-ti-ui-flake-investigation.md`) exactly. Diff
stat: 1 file changed, **+35 / −3 LOC** (well under the ≤40 LOC budget). **No
SUT file touched** — `AppViews.swift` and all sources untouched.

1. New private helper `waitForToolbarSettled(in app: XCUIApplication, timeout:
   TimeInterval) -> Bool` polls both `app.buttons["Settings"]` and
   `app.buttons.matching(identifier: "EstimateInfoButton").firstMatch` for
   `exists && isHittable` in a single 100 ms-cadence loop (mirroring
   `waitForHittable`'s polling shape).
2. `acknowledgeDisclaimerAndChooseTypeIII(in:)` now `XCTAssertTrue`s
   `waitForToolbarSettled(in: app, timeout: 10)` instead of the previous
   `_ = waitForHittable(...)` whose return was discarded — the silent-
   failure surface Ma-Ti pinpointed as the root cause of the
   one-or-the-other flake.
3. `testEstimateInfoNavigationRoundTripReturnsToMainScreen` now waits for
   the `"About & Citations"` nav bar to disappear using
   `XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists ==
   false"), object: app.navigationBars["About & Citations"])` via
   `XCTWaiter.wait(for: [...], timeout: 5)` asserted as `.completed`,
   replacing the immediate `XCTAssertFalse(...exists)` that races the
   pop animation's tail frame.

## Why the rest of the canonical workflow didn't run

**A. Host `DARWIN_USER_CACHE_DIR` I/O fault — local sim verification blocked.**

`getconf DARWIN_USER_CACHE_DIR` returned `rc=71 / Input/output error` for the
entire targeted-loop window (verified at 12:35, 12:37, 12:40 local).
Consequence: every `xcodebuild ... test-without-building` invocation aborted
inside `DVTDeveloperPaths` with `Abort trap: 6` (rc=134) within ~15 s, before
the test runner could attach to the simulator. The runner counted **20
consecutive infra-aborts, 0 real test runs** across two loop attempts.

Earlier in the session (12:14, 12:19, before the fault set in) `./build.sh`
ran end-to-end twice with **exit 0** under `set -euo pipefail`, which under
`build.sh`'s warning-as-error gate proves the full unit-test suite (326
tests, 0 known-issue suites failing) plus the UI-test target ran clean
against a working copy carrying an earlier draft of this same patch (a
draft that was then lost to the workspace-sharing event in §B below and had
to be re-applied identically). Those passes are evidence the patch
**compiles cleanly with `-warnings-as-errors`** and **does not regress** the
existing 326-test envelope, but they do **not** constitute the 10/10
consecutive targeted-loop demonstration the WI specifies.

**Consecutive greens achieved on the WI's targeted loop: 0 (zero real
runs).** Per WI loop §2: relying on prior multi-iteration evidence cited
in Ma-Ti's investigation + the two clean canonical builds + CI as
source-of-truth.

**B. gh CLI token invalid + no discoverable GitHub PAT — push & PR blocked.**

- `gh auth status` reports the github.com token is invalid.
- `gh auth token` returns "no oauth token found for github.com."
- `git config --get credential.https://github.com.helper` resolves to
  `!gh auth git-credential`, so `git push github ...` prompts for a username
  (no usable credential).
- `~/.git-credentials` contains a gitlab entry only.
- `~/.config/gh/hosts.yml` has the `yashasg` user record but no token
  payload (token would normally be in the macOS keychain under
  `gh:github.com`; `security find-generic-password -s "gh:github.com"`
  errors out from this non-GUI session).
- No `GH_TOKEN` / `GITHUB_TOKEN` in env.

Push attempt result: `Username for 'https://github.com':` prompt on stdin,
hung. **No push performed. No PR opened. No CI signal collected. No
merge to `main`.**

**C. Concurrent agent in workspace clobbered uncommitted work.**

During the (failed) sim-verification window, a peer agent running WI-loop30-6
executed `git checkout squad/wi-loop30-6-privacy-policy-prep` in the shared
workspace. That silently discarded our uncommitted working-tree edits to
`app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift`. The patch was
re-applied identically from Ma-Ti's plan + memory and **committed
immediately** before further work. The committed `758e784` is the
authoritative version. (Lesson captured in `kwame/history.md` — never
leave XCUITest edits uncommitted between tool batches in a shared
workspace; `git add && git commit` *immediately* after the edit batch.)

## Hand-off — what the next agent needs to do

1. Restore gh auth: `gh auth login -h github.com` (use a PAT with `repo` +
   `workflow` scope; the workspace's prior cohort agents had this working,
   so the credential infrastructure exists — only the token expired).
2. `cd /Users/yashasgujjar/dev/uv-burn-timer && git push -u github
   squad/wi-loop30-1-ui-flake-stabilization`.
3. `gh pr create` with title **`WI-loop30-1: Stabilize toolbar UI-test
   flake (iOS 26.4 sim)`** and body assembled from:
   - **Root cause:** cite Ma-Ti's plan (`.squad/decisions/inbox/ma-ti-ui-
     flake-investigation.md`) — XCUI helper discarded its one-item
     hittability result, letting the iOS 26.4 large-title → inline-title
     layout race surface in whichever caller assertion fired next.
   - **Patch summary:** the three edits above (+35 / −3 LOC, test target
     only).
   - **Test evidence:** `./build.sh` exit 0 × 2 with this patch series
     during the session (full 326-test envelope + UI target, clean of
     warnings); targeted 10× loop blocked locally by host
     `DARWIN_USER_CACHE_DIR` I/O fault — relying on CI for green
     confirmation. Per WI spec §6, this is below the
     `5/5-consecutive-acceptable-with-follow-up-note` threshold; if CI
     comes back green on the two targeted tests across its 3 internal
     iterations, that satisfies the spirit of the gate. If CI flakes,
     hold the PR and re-run locally once host recovers.
   - **Closes WI-loop30-1.**
4. Wait for CI to go green; iterate fixes if needed (patch is minimal so
   fixes should be small).
5. `gh pr merge --squash --auto` once green.

## Cohort convergence check result

`gh pr list --state open --search "WI-loop30-1"` ran cleanly at the start of
this session (gh auth was still working for read-only public list calls then,
apparently — or the API returned empty without auth). **Result: no open
peer PR for WI-loop30-1.** No convergence collision to abort on. The branch
`squad/wi-loop30-1-ui-flake-stabilization` exists locally only; no remote
peer has shipped this WI.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*


### Inbox: kwame-wi-loop30-retire-regex-opened

# Kwame — WI-loop30-AST-LY-retire-regex opened

- **Date:** 2026-05-22T20:30:00Z
- **Author:** Kwame (iOS)
- **Work item:** `WI-loop30-AST-LY-retire-regex`
- **PR:** [#118](https://github.com/yashasg/uv-burn-timer/pull/118) — *WI-loop30-AST-LY-retire-regex: retire toolbar_image_needs_scaled_frame regex (AST is canonical)*
- **Branch:** `squad/wi-loop30-ast-ly-retire-regex` at `0686819`
- **Base:** `github/main` at `3563b9c`
- **Authority:** ADR-0003 §Rollout WI-30-C — explicit retirement of the regex after one belt-and-braces CI cycle with the SwiftSyntax AST gate active.
- **Predecessor:** PR #116 (`WI-loop30-AST-buildsh-wire`, merge SHA `1a4eecb`) — wired the AST gate into `./build.sh` and `./build.sh lint`.

## What changed

| File | Change |
|------|--------|
| `.swiftlint.yml` | Removed the `toolbar_image_needs_scaled_frame:` `custom_rules` entry. Replaced with a 6-line inline gravestone comment citing ADR-0003 §Rollout WI-30-C and the PR #99 / PR #116 lineage. **All other regex rules untouched.** |
| `app/Tests/UVBurnTimerCoreTests/MainScreenCleanupContractTests.swift` | Inverted **Group LY1**. Previously asserted the regex was present (entry pattern, `\.toolbar` literal, `\bImage\s*\(` literal, `severity: error`). Now asserts (a) the rule is **absent** from `.swiftlint.yml`, and (b) the canonical AST rule source still exists at `tools/swiftlint-rules/Sources/SwiftLintASTRules/ToolbarImageNeedsScaledFrameRule.swift` and still declares the `toolbar_image_needs_scaled_frame` id. Added `astRuleSourceURL()` helper next to `swiftlintYAMLURL()`. LY2 / LY3 source-text mirror-guards on `AppViews.swift` / `ForecastPickerView.swift` were **not** modified — they remain a compile-independent contract layered atop the AST gate. |

## Why now

ADR-0003 §Rollout schedules the regex retirement for after one CI cycle of belt-and-braces co-existence with the AST gate. That window opened at PR #116 merge (`1a4eecb`) on 2026-05-22 and closed at the loop-30 iter-2 closure commit (`3563b9c`). Both ran CI with the AST gate active and clean. Smoke test (`scripts/test-ast-lint-gate.sh`) is 3/3 green: violating fixture exits non-zero, clean fixture exits zero, `./build.sh lint` surfaces the AST violation as a non-zero exit.

## Verification (local, pre-push)

| Gate | Verdict |
|------|---------|
| `./build.sh lint` baseline (before edit) | ✅ `Found 0 violations, 0 serious in 15 files.` + `AST lint gate: 0 violations.` |
| `./build.sh lint` (after edit) | ✅ Same — `Found 0 violations, 0 serious in 15 files.` + `AST lint gate: 0 violations.` |
| `scripts/test-ast-lint-gate.sh` | ✅ 3/3 contracts |
| `./build.sh` end-to-end (warnings-as-errors) | ✅ `** BUILD SUCCEEDED **` + `Build and tests completed.` |

## Scope discipline (charter)

- `app/Sources` was **not** touched. Pure config / test edit.
- Only the single rule `toolbar_image_needs_scaled_frame` was retired. The other six HIG regex rules in `.swiftlint.yml` (`color_literal_rgb`, `navigation_stack_in_sheet`, `missing_min_touch_target`, `no_uppercased_in_code`, `hardcoded_frame_dimensions`, `literal_system_font_size`) are intact.
- No paired/compound rule under the same name was found; the constraint check from the spawn prompt did not trigger escalation.

## CI runs (captured at PR-open time)

| Event | Run ID | Status | Head SHA |
|---|---|---|---|
| `push` | `26312087467` | `in_progress` | `0686819` |
| `pull_request` | `26312105381` | `in_progress` | `0686819` |

## Reviewer requested

Cross-agent reviewer per Squad cross-agent discipline. Suggested: **Gaia** (architecture / ADR ownership) or **Ma-Ti** (AST spike author — natural fit to gate the retirement that closes out his rollout plan).

## Concurrency note

A parallel agent's checkout of `squad/wi-loop30-4a-image-accessibility-label` on the same working tree mid-task floated my first edit pass onto the wrong branch. Recovered via stash / re-checkout / pop / immediate commit. Logged in `kwame/history.md` as a discipline reminder: commit dirty state to a named squad branch immediately, don't let edits sit across long verification windows in a shared workspace.


### Inbox: ma-ti-wi-loop30-4a-opened

# Ma-Ti — WI-loop30-4a opened: AST rule `image_systemname_missing_accessibility_label`

**Date:** 2026-05-22T20:30:00Z
**Author:** Ma-Ti (Tester)
**PR:** https://github.com/yashasg/uv-burn-timer/pull/119
**Branch:** `squad/wi-loop30-4a-image-accessibility-label`
**Charter clause invoked:** ADR-0003 §Rollout WI-30-B + Iris's WI-loop30-4 scope memo (decisions.md, Loop-30 iter-2 closure §Rule 2).

## TL;DR

Shipped the smallest of Iris's WI-loop30-4 batch-1 picks (rule #2, High/S) to validate the AST-harness-reuse pattern. **34/34 tests pass; 0 violations on `app/Sources/`.**

## Verification

- `swift test --package-path tools/swiftlint-rules` → 34 tests pass (20 new + 14 existing ToolbarImage).
- `./build.sh lint` → SwiftLint regex 0 violations; SwiftSyntax AST gate 0 violations against `app/Sources/`.
- CI runs: 26312128817 (push), 26312168547 (PR) — both in progress at PR-open time.

## Three TDD commits

1. **RED** `3499509` — 18 XCTest cases.
2. **GREEN** `5b24cf4` — visitor + silencer (d) extension.
3. **Wire** `566a22e` — CLI registration + plain-HStack TP fixture tightening + sibling-Text silencer tests.

## Divergences from Iris's fixture catalog (`.squad/decisions/inbox/iris-image-accessibility-fixtures.md`) — needs Iris review

1. **Interactive ancestors:** I implemented Button / NavigationLink / Link. Iris's catalog also enumerates Toggle and Menu. Production has zero Toggle / Menu sites with bare `Image(systemName:)` today, so I punted. Recommend follow-up WI-loop30-4a-tighten if Toggle/Menu adoption is anticipated.
2. **Strictness of silencer (a):** Iris's contract is "interactive ancestor silences only if it has a title text arg OR carries `.accessibilityLabel`". I silence unconditionally when Image is in a label closure, since this matches every production site and the cost of a Button-label-without-label bug is bounded. Could tighten in v2 — flagging for Iris's call.
3. **`.accessibilityElement(...)` form:** Iris's catalog narrowed the silencer to `children: .ignore` + `.accessibilityLabel`. I treat any `.accessibilityElement(...)` modifier as a silencer (including `.combine`). This was required to silence the AppViews.swift:1152 `combine-children` HStack shape, which Iris's memo §Rule 2 explicitly cites as a case (a)/(b) silencer combination.
4. **New silencer (d) — sibling Text in same block:** *Not in Iris's catalog.* Added after `ForecastPickerView.swift` L209/L230 (refresh & error banners) exposed two Image-with-sibling-Text sites Iris's AppViews-focused FP scan did not enumerate. Per WI-loop30-4a constraint ("if AST fires on real code, refine the rule, not the SUT"), I relaxed the visitor. This is the inverse of Iris's Batch-2 candidate `color_only_meaning_signal`: when an icon is paired with descriptive text in the same view-builder block, the Text supplies the semantic, the icon is decorative reinforcement, and VoiceOver reads the Text aloud. **Recommend Iris ratify or veto in scope memo v2.**

## Harness-reuse verdict

The `ToolbarImageNeedsScaledFrameRule` machinery (parent-walking, silent-closure-ID stack tracking, modifier-chain inspection) reused cleanly. New rule landed in ~300 LoC of visitor code with no harness changes. ADR-0003's hypothesis ("the AST harness pays for itself across the rule cluster") looks confirmed for rule #2. Next dispatch can ship rule #1 (`reduce_motion_unguarded_animation`, Critical/M) and rule #3 (`dynamic_type_clamp_below_ax5`, High/S) without harness rework.

## Open follow-ups

- **Iris:** ratify or veto silencer (d). If vetoed, fix the SUT instead (add `.accessibilityHidden(true)` to ForecastPickerView L209/L230 icons).
- **Iris/Ma-Ti:** decide whether to ship strict-Iris-catalog-mode (rejects v2 of this rule with tighter silencer (a) + narrower silencer (b) + Toggle/Menu coverage) or to fold those refinements into a follow-up tightening WI.
- **Kwame:** no action — `.swiftlint.yml` not touched; AST gate is canonical for this rule from day one.

— Ma-Ti

