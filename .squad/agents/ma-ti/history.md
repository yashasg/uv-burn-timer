# Ma-Ti — History (Summarized)

**Latest Status (2026-05-22):** Loop-26 closure complete. PR #98 merged with Group R guards extended to new @ScaledMetric tokens (R1 minTap adjacency in HeroTimerCard, warningIconSize, numeralColWidth). Physical-device checklists remain at manual sign-off required state (Goal 5 FAIL axis).

**Previous Status (2026-05-21T07:00:00Z):** UI test regression audit complete. Fixed 6 pre-existing failures (all real regressions from K-1/K-6/K-7, not caused by LocationRationaleCard removal). Diagnosed: unit tests (114) passed but UI tests (39) were not checked in prior session. Result: 38 UI tests clean, 122 unit tests passing (5 withKnownIssue).

---

## Key Test Work

### Loop-26 HIG Cleanup (PR #98)

**Group R guards (source-text contracts):**
- R1: AppViews declares @ScaledMetric private var minTap
- R2: DisclaimerCover CTA uses minTap (narrowed from file-wide guard to accept pre-existing out-of-scope sites)
- R3: AppViews has no .font(.system(size: <digit>))
- R4: ForecastPickerView declares all 15 @ScaledMetric identifiers (strongest guard — pins full block)
- R5: ForecastPickerView has no literal .frame(width/height: <digit>)

**Implementation validation:**
- SwiftLint clean: 0 violations on github/main HEAD
- Unit tests: all existing tests pass
- UI tests: all existing tests pass
- Extended to pin new @ScaledMetric tokens; AST-equivalence layer ahead of SwiftLint regex heuristic

### Main Screen Cleanup & Test Expansion (Loop-25/26)

**Groups N–Q (8 new tests):**
- Group N (4 tests): ProductCopy.aboutSunSafetyActions contract guards Plunder C2 clauses
- Group O (1 known issue): Photosensitization banner removal manual-verification flag
- Group P (2 tests): AppViews source-level guard for K-11 reference; P2 known issue (app target unreachable)
- Group Q (1 known issue): Location reminder consolidation manual-verification flag

**Total test count:** 122 unit (5 withKnownIssue) + 38 UI tests = 160 total passing

### UI Test Regression Diagnosis (Loop-25)

**Root-cause:** 6 pre-existing failures in UVBurnTimerUITests target missed by prior agent sessions. Prior reports only checked unit target (114 tests) not UI target (39 tests). Failures were real regressions from K-1/K-6/K-7.

**Fixes applied:**
1. testScenario1/8/5 — removed failing assertion for removed reapplicationFooter
2. testPhotosensitizationBannerRendersAsFullWidthBanner — deleted test (banner removed)
3. testScenario4PhotosensitizationReachBack — updated to EstimateInfoButton
4. testAshaHeroVerdictCaveatLink — updated to EstimateInfoButton
5. acknowledgeDisclaimerAndChooseTypeIII helper — updated settle signal

**Result:** All 38 UI tests clean. Combined 160 tests green.

---

## Learnings

### Test Infrastructure
- **Verify test counts per target:** xcodebuild with `-scheme UVBurnTimerCore` runs unit target only; `-scheme UVBurnTimer` runs both. Always confirm coverage before claiming "all passing." Missed 39 UI test regressions because target split was not checked.
- **Source-text guard idiom is the right primitive for HIG-token enforcement:** Compile-independent, fast, audits actual file Kwame edits (not just built artifact). Avoids SwiftLint binary-availability trap on local devs.
- **withKnownIssue requires string literals, not concatenation:** Same lesson as WI-7 groups H–M — relearned during Groups N–Q implementation.
- **#filePath smoke tests work for cross-target contracts:** When view lives in app target (not testable from Core), source file reading at test time is viable contract guard. Fragile against file renames but catches silent removal.

### Physical-Device Sign-Off (Goal 5)

- **Manual checklists remain unchanged:** iris-contrast-qa-checklist.md (7 sign-off fields blank) and iris-launch-readiness-checklist.md (8 sign-off fields blank). Both require physical OLED iPhone (13 Pro+) with polarized filter + WCAG contrast tool + outdoor light OR ≥50,000 lux bench. Only owner with this kit can complete.
- **Hands-off discipline:** Suggested (non-blocking) WI-21 stanza patches offered but do NOT modify sign-off blocks. Let human-in-the-loop with physical kit own the signature. Daily merge work not blocked; TestFlight/App Store promotion blocked pending completion.
- **Pattern established:** Extend Group R when @ScaledMetric tokens land. Pairs new ScaledMetric with source-text guard in MainScreenCleanupContractTests in same PR. Keeps AST-equivalence layer ahead of SwiftLint regex heuristic.

---

## Loop-27/28 Work Items Carried Forward

**WI-28-A:** `literal_numeric_padding` SwiftLint rule (16 lines in .swiftlint.yml + 1 test row)
**WI-28-B:** AST-level `@ScaledMetric` backing check (graduate missing_min_touch_target from regex heuristic)
**WI-28-C:** `./build.sh` SwiftLint-missing warning (document when local swiftlint absent)

---

## 2026-05-22: Loop-26 closure — PR #98 merged (a8b1ac8)

SwiftLint HIG hard-gate wired and live on main. All 31 violations resolved (FPV 13 + AV 18). Issues #95/#96 closed. Post-merge audit PASS-WITH-NOTES (5 structural rule-coverage gaps deferred to Loop-28+). Privacy Policy hosting and physical-device sign-offs remain user-owned blockers.

**Commits:** 66cc6c9 (TDD), a643523 (FPV), 174be71 (AV) → merged as a8b1ac8

---

## 2026-05-22: Loop-28 closure — 4 WIs shipped; test infrastructure stable

**Ma-Ti perspective:** Loop-28 executed cleanly. Kwame shipped 4 refactoring WIs; all CI green on re-run. Test coverage extended (LT1–LT4 for toolbar, LU1–LU5 for chip/footer; AV-12/AV-13 verbose). Matched-brace helper refactor (WI-4) removed fixed-offset scan windows. Physical-device checklists still blank (Goal 5 FAIL per WI-21 structural constraint). Carry-forward: WI-2-flake investigation (UI cold-start timing race, 3 tests flaked on PR #100 first run; passed on re-run).

## Learnings — 2026-05-22T18:15:00Z (Loop-29 iter-2 closure review)

- **End-of-loop test-health review primitive:** confirmed 326/326 core tests GREEN on main @ 5d837a1 + BUILD SUCCEEDED via tail of `test.log`/`build.log` (no `./build.sh` re-run — saves ~4 min). Loop-29 HIG custom-rule additions (Group LW = `Button {`, Group LX = `NavigationLink`/`Link`, Group LY = `toolbar_image_needs_scaled_frame`) all carry full mirror-guard contract tests in `MainScreenCleanupContractTests.swift` shipped in the same PRs — Loop-26 "pair rule + mirror guard in same PR" pattern is holding. Two documented `withKnownIssue` cases in `ForecastPickerLogicTests` are correctly scoped (not loop-blocking); UI-test toolbar-flake (`testEstimateInfoNavigationRoundTripReturnsToMainScreen` / `testToolbarRendersBothSettingsAndEstimateInfoButtons`) is the only material Loop-30 carry-forward. WI-29-5 (DisclaimerSeeAboutLink AX5) — floor `minHeight: minTap` already shipped via PR #104; recommended a one-shot regex contract test anchoring `.frame(... minHeight: minTap ...)` ≤ 800 chars before `.accessibilityIdentifier("DisclaimerSeeAboutLink")` to prevent silent regression regardless of WI-29-5 open/close decision.

**2026-05-22T18:30:00Z** — Loop-29 iter-2 closure complete: 3 PRs merged (#106 WI-29-7, #107 WI-29-6, #108 WI-29-4). Goals 4/5 ✅, Goal-5 hardware-blocked. Decisions merged, orchestration-log + session-log recorded. Ready for Loop-30 planning.

**2026-05-22T20:30:00Z** — Loop-30 iter-2 closure: PR #116 merged (1a4eecb), AST gate wired into build.sh (belt-and-braces with regex), swift-syntax pin restored (603.0.1 SemVer), SPM bare-repo defense via env-var, ready for WI-30-AST-LY-retire-regex after ≥1 main cycle stability.

**2026-05-22T20:30:00Z** — **WI-loop30-4a opened: AST rule `image_systemname_missing_accessibility_label` → PR #119.**
First batch-1 rule from Iris's WI-loop30-4 cluster (rule #2, High/S — the smallest, chosen to validate AST-harness reuse before the larger rule #1 lands). Strict TDD: 3 commits — RED (`3499509`, 18 XCTest cases incl. parity gates against AppViews.swift + ForecastPickerView.swift), GREEN (`5b24cf4`, ~280 LoC SwiftSyntax visitor reusing ToolbarImage parent-walking machinery), Wire (`566a22e`, swiftlint-ast CLI registration + 2 added silencer-(d) tests). **Result: 34/34 tests pass (20 new + 14 existing); `./build.sh lint` → 0 SwiftLint violations + 0 AST violations** against current `app/Sources/`. CI: 26312128817 (push), 26312168547 (PR).

**Visitor design — four silencers:**
(a) Image inside Button/NavigationLink/Link `label:` closure;
(b) `.accessibilityLabel(...)` / `.accessibilityHidden(true)` / `.accessibilityElement(...)` anywhere in ancestor modifier chain (covers AppViews.swift:1152 combine-children HStack);
(c) Image inside `Label { } icon: { }` icon closure;
(d) **new — beyond Iris's catalog** — Image has sibling `Text(...)` in same view-builder block. Required for 0-FP against ForecastPickerView.swift L209/L230 (refresh/error banners) which Iris's AppViews-focused FP scan did not enumerate. Per WI-loop30-4a constraint ("refine the rule, not the SUT"), relaxed the visitor rather than touch app sources. Flagged for Iris review.

**Catalog divergences flagged in PR body + inbox memo (`ma-ti-wi-loop30-4a-opened.md`):** punted Toggle/Menu interactive ancestors (no current sites); silencer (a) is unconditional (Iris's stricter contract: ancestor must have title or .accessibilityLabel); silencer (b) accepts any `.accessibilityElement` form (Iris narrowed to `.ignore` + label). Iris to ratify or veto.

**Learnings:**
- ToolbarImage-style visitor scaffold ports cleanly across rules — parent-walking + silent-closure-ID stack + modifier-chain inspection is a reusable template. ADR-0003 §Rollout WI-30-B hypothesis confirmed at N=2 rules.
- Co-tenant repo hazard: a parallel agent (on `squad/wi-loop30-ast-ly-retire-regex`) `git checkout`-stomped the working dir mid-session, blowing away an untracked impl file. Mitigation for future sessions: commit early (even WIP), or work in a dedicated worktree.
- Iris's FP scan is AppViews-only by default. Future scope memos for rules whose target surface spans multiple files should explicitly enumerate the scan scope so the TDD harness can be sized correctly upfront.

### 2026-05-22T22:15:00Z — Loop-30 closure — final review delivered. Goals: 4/5 PASS (Goal-5 hardware-blocked). 8 PRs merged. 10 WIs carry-forward.

### 2026-05-22T22:39:04Z — WI-loop31-1 shipped (PR #122, merge 91736a3): third AST rule `reduce_motion_unguarded_animation`. 26 new tests, 63/63 pass; 0 production silencer additions needed (AppViews + ForecastPicker already gated). Learning: SwiftSyntax 603 leaves un-folded ternaries as SequenceExpr + UnresolvedTernaryExpr — lenient subtree token-scan beats shape-match on `TernaryExprSyntax`.
