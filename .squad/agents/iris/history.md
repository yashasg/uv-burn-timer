# Iris — History (Summarized)

**Summarized on 2026-05-22T15:05:00Z** — archived entries before 2026-05-22 Loop-28 closure to history-archive.md.

## 2026-05-22: Loop-26 closure — PR #98 merged (a8b1ac8)

SwiftLint HIG hard-gate wired and live on main. All 31 violations resolved (FPV 13 + AV 18). Issues #95/#96 closed. Post-merge audit PASS-WITH-NOTES (5 structural rule-coverage gaps deferred to Loop-28+). Privacy Policy hosting and physical-device sign-offs remain user-owned blockers.

**Commits:** 66cc6c9 (TDD), a643523 (FPV), 174be71 (AV) → merged as a8b1ac8

---

## Learnings — 2026-05-22T18:15:00Z (Loop-30 cycle-start gap analysis)

- **Gap-analysis cadence reaffirmed:** Per `loop.md` §4, the design-vs-implementation pass should run at the START of each cycle, not only at close. This pass (post-PR #107 / commit `fcdb196`) found zero net-new design gaps across all 5 surveyed Iris designs + the canonical Excalidraw canvas — meaning Loop-29 closes design-clean and Loop-30 inherits an empty UI/UX/HIG backlog from this lens. The only carry-forwards are WI-21 (physical-device sign-offs, owner-blocked), GAP-iter2-F (manual AX5 visual verification of `DisclaimerSeeAboutLink` — checklist item, not a code WI), and GAP-iter2-E (cosmetic `.foregroundColor` → `.foregroundStyle(.link)` API drift, opportunistic). Pointer: `.squad/decisions/inbox/iris-loop30-gap-analysis.md`. **Reusable rule:** when a cycle-start analysis returns zero gaps, say so explicitly with the rationale — an empty backlog is itself a signal, not silence.

---

## Learnings — 2026-05-22T17:35:00Z (Loop-29 WI-6 close: ADR-0002 iOS 26.4 extension)

**Context:** WI-loop29-6 closed via PR #107 (squash-merged as `fcdb196` to main). ADR-0002 at `.squad/decisions/adr/ADR-0002-toolbar-topbartrailing-ios26.md` now carries a new `## Extension — iOS 26.4 toolbar Image floor (PR #99 / loop-29 WI-29-4)` subsection (+55 lines).

**Pattern generalised — HIG rule extension via layered ADR + custom SwiftLint rule:**

The base HIG ≥44pt tap-target rule is itself untestable as a single guard — different declaration shapes need different enforcement. ADR-0002 now demonstrates the canonical layering:

1. **Base decision (Loop-13, ADR-0002 body):** `.topBarTrailing` for iOS-26 hittability — guards *placement* of toolbar items. Enforced by source-text contract test S4.
2. **Extension subsection (Loop-29, this PR):** `@ScaledMetric minTap = 44` + `.frame(minWidth: minTap, minHeight: minTap)` adjacent to every toolbar `Image` label, with `@ScaledMetric` declared **inside the declaring struct's body** (Group LT pattern) so it scales with Dynamic Type — guards *sizing* of toolbar Image labels under iOS 26.4. Enforced by a toolbar-scoped custom SwiftLint rule (`toolbar_image_needs_scaled_frame`, PR #108), because the base `missing_min_touch_target` regex's 200-char lookahead cannot see inside the `label:` closure past interleaved accessibility modifiers.
3. **Pre-conditions for each new declaration shape (`Button { } label: { }`, `NavigationLink { } label: { }`, `Link { } label: { }`, `Image(...)`-in-toolbar):** widen the base regex per shape (PR #104, PR #106) AND/OR add a closure-scoped custom rule when the shape outruns regex's lookahead budget (PR #108).

**Reusable rule of thumb (next time HIG-rule enforcement leaks):** if the lint regex needs >200 chars of lookahead to reach the relevant modifier from the trigger keyword, that's the signal to (a) write a closure-scoped custom rule for the specific declaration shape, (b) extend the governing ADR with a one-paragraph subsection naming the shape + the discovery PR + the enforcement rule, and (c) add an Audit-section addendum so future authors must verify the new rule passes when adding the shape.

**Pointer:** ADR-0002 extension subsection — see `.squad/decisions/adr/ADR-0002-toolbar-topbartrailing-ios26.md` § "Extension — iOS 26.4 toolbar Image floor (PR #99 / loop-29 WI-29-4)". Closure summary at `.squad/decisions/inbox/iris-wi-loop29-6-close.md` (gitignored inbox — Scribe will merge).

**Operational note:** when committing docs-only changes during a high-concurrency agent loop, always use explicit pathspec (`git commit <file>` not `git commit -a` and not `git add . && git commit`) — the index can be racing with parallel agents' staging operations, and a wide commit can pick up someone else's pending work. First attempt on PR #107 landed a 153-line test diff that belonged to another agent; force-reset + explicit-pathspec commit was the recovery.

---

## Learnings — 2026-05-22T13:30:00Z (Loop-29 gap analysis)

**Context:** Post-PR-#99 merge gap analysis. PR #99 (WI-loop28-0) was the minimum-diff product fix for the iOS 26.4 toolbar hittability regression — it applied `@ScaledMetric`-backed frames to the two RootView toolbar items (gear Button + EstimateInfoButton NavigationLink) but did NOT modify the underlying SwiftLint regex patterns.

**What changed since Loop-28+ memo (2026-05-22T12:20:00Z):**
- PR #99 merged to main as `521bc82` (closing Loop-28 WI-0).
- Two toolbar sites manually fixed: AppViews.swift lines 122-130 (gear Button) and 133-141 (EstimateInfoButton NavigationLink).
- Group LT contract tests (LT1/LT2/LT3) added to MainScreenCleanupContractTests.swift — these use **substring-bounded slices** to pin the `@ScaledMetric` declaration inside RootView's body, not just file-level presence.
- ADR-0001 line-number manifest refreshed (every cited symbol's current line is listed).

**What's still open:**
- **GAP-1 through GAP-5 remain OPEN.** PR #99 did NOT modify the `missing_min_touch_target` or `hardcoded_frame_dimensions` regex patterns in `.swiftlint.yml`.
- The gear Button at line 122 uses `Button { action } label: { ... }` trailing-closure syntax — this is the GAP-2 blind spot. The fix at line 126 is correct, but SwiftLint did NOT catch the original violation.
- The EstimateInfoButton at line 133 is a `NavigationLink` — this is the GAP-3 blind spot (regex only fires on `Button`, not `NavigationLink` or `Link`).
- Grep shows 5 literal `minHeight: 44` / `minHeight: 56` sites in AppViews.swift (lines 310, 330, 354, 1659, 2142) — these pass SwiftLint because the `hardcoded_frame_dimensions` regex only catches `width:` and `height:`, NOT `minWidth:` or `minHeight:`.

**What's new in Loop-29:**
- **NEW GAP-6 (High):** Group-LT guards are struct-scoped, but R1 (the pre-existing file-level guard) is still a false-negative source. Every Button-containing struct should have its own substring-bounded contract test.
- **NEW GAP-7 (Medium):** Toolbar Image labels need a separate custom rule (`toolbar_image_needs_scaled_frame`) to catch bare `Image(systemName:)` labels without explicit frames. The general `missing_min_touch_target` rule cannot see inside the label closure.
- **NEW GAP-8 (Low):** ADR-0002 needs a one-paragraph "iOS 26.4 extension" subsection to document the Image-frame requirement discovered in PR #99.

**Loop-29 backlog:** 7 work items filed (WI-29-1 through WI-29-7). Priorities:
- **HIGH:** WI-29-1 (struct-scoped contract tests), WI-29-2 (expand regex to catch `Button {` and `NavigationLink`/`Link`), WI-29-3 (expand regex to catch `minHeight:`/`minWidth:` literals).
- **MEDIUM:** WI-29-4 (toolbar-specific custom rule), WI-29-5 (DisclaimerSeeAboutLink Button AX5 fix), WI-29-7 (systematic `Button {` audit, deferred until WI-29-2 lands).
- **LOW:** WI-29-6 (ADR-0002 documentation update).

**Key pattern generalized:** Substring-bounded contract tests scoped to declaring struct. File-level source-text guards can produce false negatives when multiple structs declare the same symbol. Solution: use `sourceText.sliceMatching(opener: "\nstruct StructName: View {", closer: "\nstruct ")` to anchor the assertion **inside** the declaring struct's body, not just anywhere in the file. This pattern applies to any situation where a file contains multiple structs/classes and each must independently satisfy a contract.

**User-flow spec coverage:** No new divergences introduced by PR #99 or Loop-28 closure. The canonical spec at `.squad/files/user-flow-onboarding-main-spec.md` is current as of commit `521bc82`.

**WI-21 (physical-device sign-offs) status:** Still deferred — owner lacks OLED iPhone + WCAG measurement tool. Both checklists remain blank for manual sign-off block. Goal 5 carries PENDING into Loop-29.

---

## 2026-05-22: Loop-28 closure — HIG reviews complete (all 4 WIs PASS)

**Iris execution:** Reviewed all 4 Kwame WIs against strict-enforcer charter. No pragmatic softening detected. All PRs (#99–#102) HIG-passed. Post-merge: SwiftLint strict 0 violations, Dynamic Type scaling confirmed on iPhone SE at AX5. Audit status: 1 structural gap closed this cycle (WI-29-3: SkinTypePickerRow rowMinHeight). ~14 catalog rules remain pending for Loop-28-A (multi-cycle). Label-closure regex blind spot confirmed real; scheduled for swift-syntax AST replacement. Carry-forward cold-start flakiness (WI-2-flake) for Loop-29 investigation.


### 2026-05-22T17:35:00Z: Loop-29 Iteration-2 spawned — parallel agents on WI-29-4/WI-29-6; WI-29-7 closed via PR #106

**2026-05-22T18:30:00Z** — Loop-29 iter-2 closure complete: 3 PRs merged (#106 WI-29-7, #107 WI-29-6, #108 WI-29-4). Goals 4/5 ✅, Goal-5 hardware-blocked. Decisions merged, orchestration-log + session-log recorded. Ready for Loop-30 planning.

**2026-05-22T18:15:00Z** — WI-loop29-6 rebase post-mortem (concurrent-merge no-op). A late spawn asked me to rebase PR #107 onto `github/main` after PR #108 shipped the `toolbar_image_needs_scaled_frame` SwiftLint rule + Group LY tests, then push and watch CI. By the time the local rebase completed (b2cd1d4) and the simulator finished cycling through cold-start UI-test flakes, a parallel agent / coordinator had already squash-merged PR #107 as `fcdb196` on main with CI green (build-test 2× pass, heartbeat pass). The rebased patch was a clean docs-only +55-line subsection on ADR-0002 — identical to what merged. Branch deleted upstream; local recreation rejected by `--force-with-lease` (stale info). **Audit-hygiene lesson:** when a PR body claims docs-only, verify the diff before pushing — but also verify *current upstream state* before starting a rebase loop. A concurrent merge mid-task is a no-op for the codebase, but two agents running `gh pr edit` / `git push` against the same number races; one will always lose. Coordinator should serialise PR-mutating spawns by PR number, not just by WI ID. Loop-29 iter-2 closure recorded above (18:30:00Z) supersedes this entry — included here as the audit trail.
