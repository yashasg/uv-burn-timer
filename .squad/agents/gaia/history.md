
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

### 2026-05-22T22:15:00Z — Loop-30 closure — final review delivered. Goals: 4/5 PASS (Goal-5 hardware-blocked). 8 PRs merged. 10 WIs carry-forward.

## Learnings

**2026-05-23T00:30:00Z — WI-loop31-process-A — Lead BLOCKED-discipline charter rule + reviewer-discipline skill (PR #129, merged `1aca1f0`).**

Doc-only PR. Closes the procedural leg of the PR #119 bypass: every Lead verdict on a PR now binds (via charter) to a `gh pr review` call **before** any `.squad/` history or inbox write. Handshake codified in `.squad/agents/gaia/charter.md` § "Reviewer Discipline" and reusable skill at `.squad/skills/lead-reviewer-discipline/SKILL.md` (confidence: `medium`; bumps to `high` after first real BLOCKED re-application). Decision doc at `.squad/decisions/inbox/gaia-wi-process-a-discipline.md`.

**Two-layer model now in place:**
- *Technical* gate — branch protection (WI-process-B, PR #125, `6a27988`): `build-test` required + linear history. Enforced by GitHub.
- *Procedural* gate — Lead verdict ↔ `gh pr review` handshake (this WI). Enforced by Gaia's own charter.

**Protection-gate observations (second PR under new regime):**
- `mergeStateStatus` flipped to `BLOCKED` until `build-test` passed, exactly as designed.
- After CI passed, merge attempt initially rejected with "head branch is not up to date with the base branch" because `required_status_checks.strict = true`. Resolved cleanly via `gh api -X PUT .../pulls/129/update-branch`; second `build-test` run on the rebased head also passed, merge proceeded. The `strict` flag is doing real work — it prevented merging a PR whose CI had been run against a stale base.
- `--auto` flag rejected: `enablePullRequestAutoMerge` is off at the repo level. Not blocking — fall back to manual merge after `--watch`. Worth filing as a follow-up: enabling auto-merge would reduce attended-merge latency under the new strict-CI regime.

**Lesson:** branch protection without the discipline handshake leaves a Lead's design judgment invisible to the platform. Branch protection with the discipline handshake makes both CI verdicts AND Lead verdicts legible at the merge button. The cost is one `gh pr review` call per verdict — trivial compared to the cost of another #119-class bypass.
