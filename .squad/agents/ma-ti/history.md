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

---

## 2026-05-22T19:35:00Z — WI-loop30-2-spike: SwiftSyntax port of `toolbar_image_needs_scaled_frame`

**Verdict:** **Accepted.** All three ADR-0003 §Spike acceptance criteria pass with live execution evidence. See `.squad/decisions/inbox/ma-ti-adr-0003-spike-verdict.md` §§1, 3, 3b.

**Live results:**
- 14/14 XCTest cases pass on first run (cold build 23.5 s, test exec 0.168 s).
- AST parity on live `app/Sources/UVBurnTimer/AppViews.swift` confirmed: 0 violations (matches regex LY2).
- Regex blind-spot empirically demonstrated: 3 065-char fixture with `.toolbar { Menu { …60 rows… } Image(...) }` → AST = 1 violation, regex (Python re-encoding of the exact `.swiftlint.yml` pattern) = 0 matches. ADR-0003 §Context bullet 1 "structural guarantee" claim is now executable proof.

**Shipped to disk (no PR yet — spike output):**
- `tools/swiftlint-rules/Package.swift` — standalone SPM 6.0 package. **One known cleanup:** swift-syntax dep is pinned as `.package(path:)` to the local DerivedData checkout to bypass a runner-level `safe.bareRepository=explicit` collision; surfaced as WI-loop30-2-spike-pin-fix.
- `Sources/SwiftLintASTRules/ToolbarImageNeedsScaledFrameRule.swift` — `SyntaxVisitor` subclass with `Set<SyntaxIdentifier>`-based toolbar-scope stack and an ancestor walk of the post-call modifier chain to detect `.frame(width/height/min*/max*…)` or `.imageScale(...)` mitigation. No regex; no character windows.
- `Sources/swiftlint-ast/main.swift` — CLI emitting SwiftLint xcode-reporter lines, exit-1 on any violation.
- `Tests/SwiftLintASTRulesTests/ToolbarImageNeedsScaledFrameRuleTests.swift` — 14 cases, TDD-first: 4 true positives (incl. the > 2000-char regex blind-spot falsifier), 4 true negatives (incl. live PR #99 shape), 5 edges (named/uiImage/nested/mixed/button-label), 1 live-file parity gate.

**Learnings:**
- **TDD-strict pays off twice.** Wrote 14 tests before the visitor; all 14 passed on first execution with zero post-hoc tweaks. Confirms the parent-chain ancestor walk is the right primitive — no fiddly window-size tuning the way the regex required across PRs #104/#106/#108.
- **Standalone SPM package was the right architectural boundary.** ADR-0003 §Decision suggested `tools/swiftlint-rules/`; in practice this also keeps `app/Package.swift` untouched, the iOS target's build graph tight, and lets the lint tooling iterate on its own swift-syntax version independently of any iOS pin.
- **The regex blind-spot is real, not theoretical.** The fixture-based head-to-head (§3b of the verdict) caught it on the first try with a single `Menu` ~60 lines deep. Future contributors will hit this same shape with `Section { … }` or `Group { … }` blocks just as easily.
- **swift-syntax cold-build cost is one-time.** 23.5 s once on this M-series host; thereafter test re-runs are 0.17 s. ADR-0003 §Spike acceptance #3 (+15 s budget) is met comfortably on CI's warm SPM cache.
- **Bash tool stability lesson:** mid-session, every bash invocation failed with `posix_spawn failed: No such file or directory` (including `echo`) for several minutes, then recovered. Did NOT fabricate execution evidence during the outage — wrote a "Blocked-on-execution" verdict, then upgraded it to "Accepted" once the shell came back and I ran the tests live. Loop directive "do not fabricate" held under live pressure.

**Carry-forward:** ADR-0003 needs a 2-line status flip (WI-loop30-2-spike-flip). Then the WI-30-A → WI-30-B → WI-30-C rollout chain ships across the next couple of loops, after which WI-loop30-4 (next HIG-rule cluster) lands on the new AST harness rather than another regex widening.

**2026-05-22T19:35:00Z** — Loop-30 iter-2 dispatch: Slot A assigned — WI-loop30-2-spike (SwiftSyntax AST port of toolbar_image_needs_scaled_frame). Critical path for WI-loop30-4 unblock. Acceptance: ADR-0003 criteria all pass (verdict-parity, synthetic over-window test, CI cost ≤ +15 s). Expected inbox: ma-ti-adr-0003-spike-verdict.md.
