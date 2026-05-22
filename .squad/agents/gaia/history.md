# Gaia — History

## Core Context

- **Project:** A UV exposure and sunburn timer app
- **Role:** Lead
- **Joined:** 2026-05-19T06:26:01.545Z

## Learnings

### 2026-05-19T22:33:50.504-07:00: Preference Persistence Architecture Decision

**Context:** User raised that app does not persist skin type and location preferences, forcing re-entry on every cold launch. Gaia reconciled product requirements with prior decisions (D-2026-05-19-011 L1–L4 disclaimer safety boundary, D-2026-05-19-012 no-default Fitzpatrick).

**Key findings:**
- **Current state:** Skin type + SPF held in @State only (session object). Location (lastRoundedCoordinate) partially persisted via @AppStorage. Disclaimer in @State (transient, correct for re-attestation).
- **Conflict identified:** Prior guidance said "keep Fitzpatrick in @State, zero-data architecture" but user feedback requires persistence to avoid re-entry friction.
- **Resolution:** Persist skin type + SPF to UserDefaults (@AppStorage). Keep disclaimer @State (safety boundary). Do NOT persist permission status (OS-owned) or UV snapshots (time-sensitive).

**Decision locked:** Skin type + SPF → UserDefaults; disclaimer remains transient. (See `.squad/decisions/inbox/gaia-preference-persistence.md` for full spec.)

**Handoff:** Kwame to migrate session properties to @AppStorage layer, restore on init, sync on change. No UI changes.

### 2026-05-20: Commit-split decision for squad/fix-location-gauge-ui working tree

Split uncommitted work into two commits: (1) `docs: fold decision inbox into ledger` (decisions.md + 7 inbox deletions; pure decision hygiene, no code) and (2) `fix: move Fitzpatrick off main; unify onboarding/settings picker; expand About` (app + tests + spec + excalidraw + tool log). The app/spec/diagram diffs are one cohesive scope — the branch-name feature — because every change serves the same IA goal (Fitzpatrick lives in onboarding/Settings, not main; Settings → About cross-link; About becomes the authoritative caveats destination). One drive-by test (`longUnprotectedEstimateAtFourHoursShowsApprovedDisplayCap`) was folded in rather than split into a third commit — splitting a single test into its own commit is bookkeeping overhead, not signal.

### 2026-05-20: Onboarding cover-chain flake decision

Tests `testLocationButtonStartsLocationFlowInsteadOfSettings`, `testBurnRiskGaugeShellExistsWhenNoEstimate`, and `testScenario10SavedLocationRestoresAndCanBeCleared` were intermittently failing on the iPhone 17 Pro / iOS 26.4 simulator with `Computed hit point {-1, -1}` for the disclaimer "I understand" button and the toolbar gear. Root cause: (a) XCUITest taps fired before the just-presented `fullScreenCover` had a hittable frame and (b) chaining two `.fullScreenCover` modifiers (disclaimer → skin-type onboarding) inside the same window sometimes had the second presentation swallowed because it was assigned while the first cover's dismissal animation was still tearing down its presentation slot. **Decision:** keep the dual-cover structure (it cleanly separates disclaimer re-attestation from skin-type onboarding) and instead (1) defer `showSkinTypeOnboarding = true` past the disclaimer cover's transition with a 500 ms `Task.sleep`, and (2) add a `tapWithRetry` test helper that waits for `isHittable` and a non-empty frame before tapping. This is the smallest-surface-area fix and avoids a state-machine refactor of the App scene.

### 2026-05-22T02:26:49.194-07:00: HIG issue bundling and filing

Chose **per-file** bundling for Iris’s Apple-idiom audit rather than per-category or top-5-only slicing. `ForecastPickerView.swift` and `AppViews.swift` are self-contained SwiftUI cleanup surfaces; category slicing would create cross-file merge collisions, and top-5-only would hide the long tail that is already concrete.

Created repo routing labels `squad`, `squad:kwame`, and `squad:iris` because the workflows already expect them, but applied only `squad:kwame` on the implementation issues. Reviewer ownership stays in the body because the current `squad:*` automation treats every member label as pickup ownership, so dual-labeling Kwame + Iris would misroute the work.

Filed:
- `#95` — `[HIG] Apple-idiom layout cleanup in ForecastPickerView.swift`
- `#96` — `[HIG] Apple-idiom layout cleanup in AppViews.swift`

Both issues carry `enhancement` + `squad:kwame`, list every offender by exact `path:line`, cite `.squad/decisions.md` → `2026-05-22 / Apple-idiom SwiftUI layout policy`, point at `.squad/skills/swiftui-apple-layout-audit/SKILL.md`, and include the gate: **Iris must HIG-pass before merge.**

Kwame nuance: the worst offenders remain the forecast cell/chip sizing and disclaimer `.padding(32)`. Literal SF Symbol sizes plus tiny dot/tap-target-adjacent frame sites are lower severity, but they should still be cleaned opportunistically inside the same file pass rather than spun into separate issues.

No GitHub assignee was set because the repo currently exposes only `yashasg` as an assignable user; squad routing here is label-driven, not GitHub-user-driven.

## 2026-05-22T02:58:03-07:00 — SwiftLint HIG gate landed

Kwame completed SwiftLint 0.63.2 install and pushed branch `squad/swiftlint-hig-error-gate` with 4 starter HIG rules (error severity) integrated into CI; 16 baseline violations confirmed. Iris produced 20-rule HIG SwiftLint catalog. Likely next: orchestrate branch merge after Iris HIG-pass and integrate all 20 rules (10 immediate error, 5 grace-period warn→error).
Model assignment updated 2026-05-22T04:01: claude-opus-4.7 (premium Opus, always-on — overrides prior auto selection).

## 2026-05-22T12:20:00Z — Loop-27 closed: SwiftLint HIG gate + cleanup landed in a single PR

PR #98 merged at `a8b1ac8` (2026-05-22T12:16:39Z) carrying **all three** Loop-26 work items together: the 4-rule SwiftLint HIG error-gate (WI-loop-26-A), the ForecastPickerView cleanup (WI-loop-26-B, 13 → 0), and the AppViews cleanup (WI-loop-26-C, 18 → 0). Iris HIG-passed both files against the strict-enforcer charter before merge. `swiftlint lint --strict app/Sources/` reports 0 violations on `main`.

**Key planning lesson — overruled my own Loop-26 sequencing:** the Loop-26 plan called for "merge #98 first (red main by design), then ship one of {#95, #96}". In execution this would have (a) blocked PR #97's CI for the entire intermediate window and (b) trained the team to tolerate an intentionally-red `main`. Folding both cleanups into the same branch as the gate inverts the risk: `main` is gate-on **and** green from the same merge commit. The trade-off named is a larger single-PR diff and harder per-WI rollback, which I accept because rolling back the gate without the cleanup would re-introduce a red main anyway — they are coupled in practice. Carry this lesson forward: **when a policy gate and its baseline-cleanup are coupled, ship them in the same merge commit, not in sequence.**

**Goal 5 stays FAIL — explicitly and on the record.** Both `iris-contrast-qa-checklist.md` and `iris-launch-readiness-checklist.md` sign-off blocks remain blank. WI-21 automation-status clause: these cannot be filled by any agent or CI runner — they require a physical OLED iPhone + WCAG measurement tool + linear polarizing filter. The next build cycle whose owner has that hardware MUST fill the blocks. Until then the loop report must say FAIL, not PARTIAL.

**Loop-28 seeded:** `.squad/decisions/inbox/gaia-loop-28-plan.md` carries forward the 16-rule HIG expansion (WI-loop-28-A, sliced into ~3 PRs by rule cluster), the two manual checklists (WI-loop-28-B, hardware-gated), the Privacy Policy hosting (WI-loop-28-C), plus two new SwiftLint gaps surfaced post-cleanup: hardcoded color literals (G-5 / WI-loop-28-D) and hardcoded animation durations (G-6 / WI-loop-28-E). PR #97 also tracked as WI-loop-28-F housekeeping.

## 2026-05-22T04:05:00-07:00 — Loop-26 plan filed

Filed `gaia-loop-26-plan.md`. Key learnings from the planning pass:

- **The spec is a poor source of "outstanding work" this iteration.** LANE 1–4 is so heavily reconciled (Loop-10 WI-cc + later patches) that every gap in-canvas is already retired or shipped. Real gaps live in cross-cutting gates: SwiftLint HIG enforcement (PR #98 + #95/#96 cleanup) and the two manual physical-device checklists. Future loop-planning should default to scanning cross-cutting quality gates first, not the canvas spec, once a design is this mature.
- **Goal 5 will remain FAIL until a human with an OLED iPhone + WCAG measurement tool + linear polarizing filter signs off both checklists.** No agent loop can close it. This needs to be surfaced in every loop report so it doesn't quietly drift into "PARTIAL" — the checklists explicitly say blank = fail.
- **Loop-scope realism:** with PR #98 in flight and red CI by design, attempting both #95 and #96 in one Squad session risks landing #98 alone with no cleanup, leaving `main` red. Recommend strict 1-cleanup-PR-per-loop pacing. AppViews (#96) chosen first over ForecastPicker (#95) because the disclaimer `.padding(32)` is the highest-impact single fix and the file is the L1 entry surface.
- **Privacy Policy hosting (Plunder WI-plunder-m1) is the silent Goal-4 blocker.** It's outside the iOS code scope but blocks "Expert approved" from going green. Flagged as WI-loop-26-G owned by yashasg.

## 2026-05-22: Loop-26 closure — PR #98 merged (a8b1ac8)

SwiftLint HIG hard-gate wired and live on main. All 31 violations resolved (FPV 13 + AV 18). Issues #95/#96 closed. Post-merge audit PASS-WITH-NOTES (5 structural rule-coverage gaps deferred to Loop-28+). Privacy Policy hosting and physical-device sign-offs remain user-owned blockers.

**Commits:** 66cc6c9 (TDD), a643523 (FPV), 174be71 (AV) → merged as a8b1ac8

---

## 2026-05-22: Loop-28 closure — 4 WIs shipped; Goal 5 remains hardware-gated

**Gaia (Lead/Architect) perspective:** Loop-28 executed cleanly. Kwame shipped 4 refactoring WIs (toolbar, chip/footer, hardcoded-frame-dimensions audit, matched-brace helper); all PR CI green on re-run. Iris HIG-passed all 4. Plunder compliance verified (no new gaps). SwiftLint strict 0 violations post-merge. Goals 1–4 tracking PASS/PARTIAL (Goal 5 intentionally FAIL per WI-21 structural constraint — hardware-gated sign-offs remain blank). Carry-forward: WI-loop-28-A (14 HIG catalog rules pending, multi-cycle), WI-loop-28-C (Privacy Policy URL user-action-gated), WI-2-flake (UI cold-start flakiness investigation).

### 2026-05-22T17:35:00Z: Loop-29 Iteration-2 spawned (observer note); WI-29-7 closed, parallel iter-2 agents in flight

### 2026-05-22T18:15:00Z — Loop-29 iter-2 closure: cohort-convergence pattern

- **Convergent shipping without orchestration:** Of the three Loop-29 iter-2 WIs (#106 WI-29-7, #108 WI-29-4, #107 WI-29-6), two were independently shipped by parallel cohort agents before this session's dispatch landed its own PR. Same diagnoses, same fixes, no rework, no duplicate PRs. Treat this as a coordination *signal*, not a race condition: when WIs are concrete enough (regex extension, custom SwiftLint rule), multiple agents in the same window will converge.
- **Lead role under convergence:** When cohort convergence happens, the Lead's value shifts from dispatch-and-track to closure-and-disposition — verify the convergent fix is correct, retire the duplicate work item without ceremony, and harvest the lesson. That's exactly what this iter-2 review is. Do not punish or "undo" convergent work; it is the system functioning as designed.
- **Planning implication for Loop-30:** When concrete WIs are filed, expect parallel pickup. Plan Loop-30 with WIs that are *either* (a) intentionally cohort-shippable (sliced for parallelism) *or* (b) explicitly serialised behind a named owner (e.g., the UI-runner flake stabilisation, which needs single-author bisection). Do not file ambiguous WIs that look concrete but actually require single-owner judgment — they invite duplicate work whose diagnoses don't converge cleanly.

**2026-05-22T18:30:00Z** — Loop-29 iter-2 closure complete: 3 PRs merged (#106 WI-29-7, #107 WI-29-6, #108 WI-29-4). Goals 4/5 ✅, Goal-5 hardware-blocked. Decisions merged, orchestration-log + session-log recorded. Ready for Loop-30 planning.

## 2026-05-22T19:00:00Z — Loop-30 WI-loop30-2: ADR-0003 SwiftSyntax/AST-aware lints filed

PR **#112** merged (squash) at `42c97e9`. Docs-only ADR proposing replacement of regex-based custom SwiftLint rules with SwiftSyntax/AST-aware lints, motivated by the Loop-29 brittleness cascade (LW → LX → LX' → LY across PRs #104, #106, #108 — each cycle's regex revealed a new false-negative in the prior cycle's pattern). Status filed as **Proposed**; flips to **Accepted** only after the WI-loop30-2 follow-up spike ports `toolbar_image_needs_scaled_frame` (Group LY) and meets three acceptance criteria: (1) verdict-parity on the existing LY contract corpus, (2) catches ≥1 synthetic case the regex misses (toolbar body > 2000-char window), (3) CI cost ≤ +15 s on the SwiftLint leg.

**Decision-shape lesson:** The right moment to make a regex-vs-AST decision is *before* the next batch of rules ships, not after. If WI-loop30-4 (next HIG-rule cluster) had landed first with five more regex rules, we would have locked in the brittleness tax for another cycle. Filed WI-loop30-4 as dependency-gated on this ADR's spike outcome in the Loop-30 backlog seed.

**Recommendation 1-liner:** Adopt SwiftSyntax-based custom lints for net-new structural HIG rules (Option A); keep regex only for single-token rules where no syntactic context is needed. Spike scope = port Group LY (most fragile / most recent regex). Major-decision note filed to `.squad/decisions/inbox/gaia-wi-loop30-2-ast-lints.md`.

**2026-05-22T20:30:00Z** — Loop-30 iter-2 closure: ADR-0003 flipped Accepted (PR #115, f616517), all 3 review PRs merged first-pass (PR #114 Kwame, PR #116 Ma-Ti), merge-sweep discipline documented, ready for iter-3 dispatch.

**2026-05-22T21:30:00Z** — Loop-30 iter-4: PR #120 merge + PR #121 opened (post-hoc cleanup of #119 BLOCKED-bypass).

**PR #120 (Kwame, WI-loop30-4a-iris-3sites)** — merged squash `29a0435`. Three SF Symbol a11y sites fixed per Iris's HIG fixture catalog §P5: TierBadge accessory glyph (`.accessibilityHidden(true)`), refresh banner spinner + error banner glyph (both `.accessibilityElement(children: .combine) + .accessibilityLabel(...)`). Contract tests + ADR-0001 line-number bump (2170→2171). CI green push `26312959589`, PR `26313088707` (build-test passed, SwiftLint HIG gate passed, warnings-as-errors clean).

**PR #121 (Lead, WI-loop30-4b-strict-rule)** — opened https://github.com/yashasg/uv-burn-timer/pull/121. Removes silencer-(d) (sibling-Text exemption) from `image_systemname_missing_accessibility_label` AST rule per Iris §P5 (sibling adjacency is NOT a labeling relation in SwiftUI's a11y tree). TDD-split: tests-first `0033874` (5 new POSITIVE tests — 2 Iris-P5 reassertions + 3 production-shape regression guards mirroring #120 sites minus their silencers), impl `840c19c` (deleted `hasSiblingTextInSameBlock` + `codeBlockItemRootsAtTextCall`; trimmed doc + violation message). 23/23 unit tests green; `./build.sh lint` 0 violations on `app/Sources/`. CI runs push `26314180661`, PR `26314207940`. Lockout discipline: Ma-Ti (author of #119) locked out of revising (d); Lead authored per charter §Boundaries "On rejection, I may require a different agent to revise (not the original author)."

**Orchestration incident — PR #119 BLOCKED-bypass.** Lead BLOCKED verdict on #119 posted `21:20:00Z`; #119 merged at `21:35:01Z` (commit `33b061c`) despite the open verdict — 15-minute window too wide for a same-process race. Working hypothesis: a coordinator tick from a parallel agent did not check unresolved Lead comments before merging. Zero user-facing harm (the 3 motivating sites carry correct a11y modifiers in main post-#120; #121 then restores the rule spec). Sub-WIs filed for next loop: (A) hard merge gate on Lead BLOCKED (switch to `gh pr review --request-changes` + a `lead-verdict-gate` CI check); (B) prevent direct-to-`main` pushes from feature-branch agents (branch protection + a `pre-push` hook), prompted by Kwame's `cf4c504` direct-to-main commit. Per user instruction, `cf4c504` is left in place; process fix is forward-looking. Filed `.squad/decisions/inbox/gaia-pr119-bypass-incident.md` and `.squad/decisions/inbox/gaia-loop30-iter4-summary.md`.

**Architectural lesson:** When a Lead verdict has been issued, the orchestrator's merge eligibility check must treat that verdict as a structured signal — either by translating it to a GitHub-native `CHANGES_REQUESTED` review (so branch protection enforces it) or by surfacing it via a CI check. Unstructured PR comments are not a reliable merge gate.
