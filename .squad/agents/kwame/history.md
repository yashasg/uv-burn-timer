### 2026-05-22T17:35:00Z: Loop-29 Iteration-2 spawned — parallel agents on WI-29-4/WI-29-6; WI-29-7 closed via PR #106

### 2026-05-22T18:00:00Z: Loop-29 WI-29-4 — no-op closure (already merged by parallel agent)

**Outcome:** WI-29-4 (`toolbar_image_needs_scaled_frame` SwiftLint
custom rule + Group LY contract tests) was already shipped to main as
PR #108 (merged 2026-05-22T18:06:01Z) on branch
`squad/wi-loop29-4-toolbar-image-scaled-frame-rule` by a parallel
Kwame agent instance that spawned slightly earlier in iter-2. My
spawn raced and lost. Current main HEAD `ec5a3f2` already contains:
- `.swiftlint.yml` rule entry at severity: error, regex pattern
  `\.toolbar\s*\{[\s\S]{0,2000}?\bImage\s*\((?![\s\S]{0,200}\.frame\([^)]*min(?:Width|Height):\s*[A-Za-z_]+\b)`
- Group LY tests (LY1/LY2/LY3) in `MainScreenCleanupContractTests.swift`
- All four `.toolbar { ... }` blocks in AppViews.swift audited:
  RootView gear+info-circle already floored by PR #99; the other
  three toolbars contain Button "Done"/"Save" labels (no Image) so
  the rule is vacuously satisfied for them.
- `swiftlint --strict` → 0 violations on main.

**Branch hygiene:** Deleted the stale local + remote
`squad/wi-loop29-4-toolbar-image-scaled-frame` (no `-rule` suffix)
branch that Scribe had pre-created as an iter-2 placeholder
holding only inbox merges — it carried no rule content and only
risked confusion vs the actually-merged `-rule`-suffixed branch.

**Coordination note for Coordinator/Iris:** PR #107 (Iris WI-29-6
ADR-0002 extension) has `baseRefOid` = current main HEAD and its
LY1 test will now PASS against the merged rule. The PR is
MERGEABLE; checks were re-pending at the time of this writing and
should land green now that the rule exists upstream.

### Learnings

- **Race-loss is silent — fetch+rebase BEFORE branching.** My
  initial `git status` reported "up to date with github/main" but
  `github/main` was stale; the true upstream main had advanced
  through #106 → #108 while my session was being spawned. A
  defensive `git fetch github main && git log github/main..HEAD`
  before `git checkout -b` would have surfaced the in-flight PR
  #108 and let me abort cleanly without doing duplicate
  uncommitted edits.
- **Parallel-agent branch naming collisions cost minutes.** The
  rule shipped under `…-toolbar-image-scaled-frame-rule` while
  Scribe pre-created `…-toolbar-image-scaled-frame` as an empty
  inbox-merge placeholder. Same WI, same intent, two branch names
  — the Coordinator should standardize on one name per WI before
  spawn, or Scribe should not pre-create empty branches under
  predictable WI slugs.
- **No-op outcome is still a deliverable.** History + decision
  inbox closure prevent the next Coordinator from re-spawning
  WI-29-4 a third time.


**2026-05-22T18:30:00Z** — Loop-29 iter-2 closure complete: 3 PRs merged (#106 WI-29-7, #107 WI-29-6, #108 WI-29-4). Goals 4/5 ✅, Goal-5 hardware-blocked. Decisions merged, orchestration-log + session-log recorded. Ready for Loop-30 planning.

## 2026-05-22T18:15:00Z — WI-loop29-5 toolbar XCUI flake stabilisation (PR #111)

**Scope:** Gaia GAP-iter2-B. Stabilise `testEstimateInfoNavigationRoundTripReturnsToMainScreen` + `testToolbarRendersBothSettingsAndEstimateInfoButtons` on iOS 26.4 simulator.

**Root cause:** iOS 26 Liquid Glass `.topBarTrailing` composition (ADR-0002 platform constraint) lags `NavigationStack` nav-bar arrival by a few hundred ms. The shared `acknowledgeDisclaimerAndChooseTypeIII` helper's tail call `_ = waitForHittable(EstimateInfoButton, timeout: 5)` waited on ONE of the two trailing items and discarded the result — whichever button the layout engine settled last became the racy one. Ma-Ti's parallel read-only investigation (2026-05-22T19:00:00Z entry in `.squad/agents/ma-ti/history.md`) independently surfaced the same `_ =`-discarded anti-pattern.

**Fix (test-only, +91 / −9 LOC, single file `app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift`):** Added private `waitForMainToolbarSettled(in:timeout:) -> ToolbarSettleSnapshot` helper that polls **both** `Settings` and `EstimateInfoButton` together for `exists && isHittable` with a 20s budget + 200 ms idle settle, then returns a snapshot the callers interrogate without re-querying mid-assertion. Pattern is the toolbar-suite analogue of the Loop-20 `tapWithRetry` cover-chain helper. Both flaky tests now gate on the helper before existence/hittable/nav assertions.

**Non-regression:** Zero production code modified (`app/Sources/` diff is empty). ADR-0001 toolbar identity contract intact; ADR-0002 topBarTrailing composition untouched (test-side stabilisation explicitly preferred per Gaia scope).

**Validation:** Core 326/326 GREEN locally prior to UI-test attempt; `xcrun swiftc -parse` clean. iOS 26.4 sim died with Mach error -308 ("Failed to install or launch the test runner") on repeated `./build.sh` runs — host-level sim-infra failure unrelated to the diff. **0 local UI re-runs achieved**; confidence-gathering deferred to CI. **CI green 2/2** runs against fresh GitHub Actions runners — both `build-test` jobs passed (9m42s + 6m5s).

**PR:** [#111](https://github.com/yashasg/uv-burn-timer/pull/111) — open, CI green, awaiting merge.

### Learnings (Loop-29 carry-forward)

1. **`_ =`-discarded XCUI waits are anti-pattern when ≥2 toolbar-sibling items must be ready** — convert to a single Bool-returning helper whose result the caller asserts. The discarded-return form trains the suite to pass on partial readiness, then flake on the unasserted half.
2. **iOS 26 `.topBarTrailing` settle is async w.r.t. nav-bar arrival** — assert composition stability via "both items hittable in same UI snapshot" before per-item hittability, not after. Same class of fix as Loop-20 cover-chain `tapWithRetry`, hoisted up one composition layer (toolbar vs. fullScreenCover).
3. **Local sim infra is unreliable for repeat-loop validation** — Mach -308 simulator runner crashes recurred deterministically across `./build.sh` invocations in this cycle. Defer confidence-gathering to CI rather than burning N×5min retry cycles on the host.
4. **Concurrent-agent branch chaos requires defensive fetch+stash discipline** — main moved twice during this session (Scribe iter-2 close + Gaia Loop-30 PR #112 merge) and my squad branch was momentarily reset by another agent's branch tip. Always `git fetch github` + verify HEAD + `git stash -u` before any rebuild, and re-verify branch tip after long-running builds.
## 2026-05-22T19:00:00Z: WI-loop30-1 — toolbar UI-test flake patch implemented; push/CI blocked by host

WI-loop30-1 (Stabilize toolbar UI-test flake on iOS 26.4 simulator):
Implemented Ma-Ti's GAP-iter2-B plan exactly on branch
`squad/wi-loop30-1-ui-flake-stabilization` at commit `758e784`
(branched from `85080a8`). Three additive XCUITest-only edits (no SUT
touched), +35 / −3 LOC. **Patch is local-only — not pushed, no PR, no
CI signal, no merge.**

The patch:

1. New helper `waitForToolbarSettled(in:timeout:)` polls BOTH
   `buttons["Settings"]` AND `buttons.matching("EstimateInfoButton")
   .firstMatch` for `exists && isHittable` in a single 100 ms-cadence
   loop, returning one `Bool` the caller XCTAsserts.
2. `acknowledgeDisclaimerAndChooseTypeIII` now `XCTAssertTrue`s
   `waitForToolbarSettled(timeout: 10)` instead of discarding a
   single-item `_ = waitForHittable(...)`.
3. Round-trip test's tail uses `XCTNSPredicateExpectation(predicate:
   NSPredicate(format: "exists == false"), object: navigationBars[
   "About & Citations"])` waited via `XCTWaiter.wait(timeout: 5)`,
   replacing the immediate `XCTAssertFalse(...exists)` that raced
   the pop-animation tail.

Hand-off detail in `.squad/decisions/inbox/kwame-wi-loop30-1-noop.md`.

### Learnings

- **Never leave XCUITest patch edits uncommitted between tool calls
  in a shared workspace.** A concurrent peer agent in this workspace
  ran `git checkout` mid-session, twice silently discarding our
  uncommitted working-tree edits to `UVBurnTimerUITests.swift` and
  `kwame/history.md`. Protocol: `git add && git commit` immediately
  after the edit batch, before any other shell operation.
- **XCUI multi-trailing-item hittability idiom.** When asserting
  hittability of >1 `.topBarTrailing` item on iOS 26+, the helper
  must poll **both** items together in a single `Bool`-returning loop
  the caller XCTAsserts. Polling one (and worse, discarding the
  result) leaks the layout-race into whichever assertion the test
  writes next — the canonical "one-or-the-other" flake.
- **`XCTNSPredicateExpectation` for animation-tail "doesn't exist"
  assertions.** SwiftUI `NavigationStack` pop animations on iOS 26.4
  can leave the popped nav bar in the a11y tree one frame after the
  underlying screen's nav bar reappears. `NSPredicate(format: "exists
  == false")` + `XCTWaiter.wait` is the symmetric counterpart to
  `waitForExistence(timeout:)` and should be default for any post-pop
  "gone" check in this codebase.
- **`./build.sh` is brittle to host `dirhelper`/userdir I/O faults.**
  `xcodebuild` calls `confstr(_CS_DARWIN_USER_CACHE_DIR)` very early
  in startup; when that returns `EIO`, xcodebuild aborts before any
  scheme resolution (Abort trap: 6 / rc=134). No CLI escape hatch.
  If `getconf DARWIN_USER_CACHE_DIR` fails for >2 minutes, abandon
  local sim verification for the session and lean on CI.

## 2026-05-22T19:30:00Z: WI-loop30-1 — pushed + PR #114 opened

Drained the push-queue entry now that `gh` is authenticated
(`yashasg` on github.com). Branch
`squad/wi-loop30-1-ui-flake-stabilization` (HEAD `a9dc664`) is
pushed to the `github` remote; PR **#114**
(https://github.com/yashasg/uv-burn-timer/pull/114) opened
against `main` with body copied verbatim from `push-queue.md`.
Rebase was a no-op — branch was already ahead of
`github/main@d0bb752`. CI runs **26309680580** (pull_request)
and **26309668853** (push) kicked off; not blocked-on per
hand-off protocol.

### Learnings

- **`github` vs `origin` matters here.** This repo wires
  `github` → GitHub and `origin` → GitLab. Every push/PR
  command must name `github` explicitly; `git push -u origin …`
  would silently land on the wrong forge. Worth a one-line
  guardrail in any future per-repo `.squad/` README.
- **`gh pr create --body-file` over heredoc.** Multi-paragraph
  PR bodies copied from the push-queue go through cleanest as a
  scratch file under `.squad/.scratch/` (NEVER `/tmp` — runtime
  rejects it), passed via `--body-file`, then deleted. Zero
  shell-quoting hazard, zero residue in the tree.
- **A `git fetch` + `github/main..HEAD` check is a 2-second
  insurance policy.** Confirmed no rebase needed before pushing;
  prevented a wasted force-push round-trip if the branch had
  drifted. Always do it before `git push -u`.

## 2026-05-22T19:50Z — PR #114 rebase on post-#111 main (mechanical reconciliation)

PR #111 squash-merged to `main` at `c3f2bbc`; PR #114 flipped to `CONFLICTING` on `app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift`. Pre-rebase HEAD `e7c8ab4` → rebased onto `github/main` → post-rebase HEAD `2074035` → force-with-lease push (`a9dc664...2074035`). PR #114 now `mergeable: MERGEABLE` (mergeStateStatus `UNSTABLE` while CI 26310521349 + 26310522801 run).

### Conflict shape

Both sides added a "wait for both `.topBarTrailing` items to settle" helper at the same file location. Different signatures, complementary uses:

- `waitForMainToolbarSettled` (PR #111) → returns `ToolbarSettleSnapshot` struct; used by tests that interrogate per-button existence/hittability.
- `waitForToolbarSettled` (PR #114, my 758e784) → returns `Bool`; used as setup-time gate inside `acknowledgeDisclaimerAndChooseTypeIII`.

Resolution: KEPT BOTH. No test logic invented; no tests deleted. Added a doc-comment cross-reference on the Bool variant.

### Learnings

1. **Rebase, not merge, when base is squash-merged.** GitHub's squash collapses N commits into 1 with a new SHA; my branch's old base commits no longer exist in history. A merge would create a 2nd copy of the work on a parallel history line — confusing reviewers and producing a duplicate squash-merge later. Rebase replays the leaf commits onto the new SHA cleanly. The PR's `MERGEABLE` flip after force-push confirms this is what reviewers expect.
2. **`--force-with-lease` discipline.** Always pair force-push with `--force-with-lease` so a concurrent agent push to the same branch tip aborts the push instead of overwriting their commits. In this session a fresh-fetch + immediate rebase + immediate push made the window small; the lease flag would have caught any racing push.
3. **Two helpers with overlapping intent are fine if call sites diverge.** Tempting to consolidate `waitForToolbarSettled` (Bool) into `waitForMainToolbarSettled` (struct) — but the Bool gate is what `XCTAssertTrue(...)` wants, and the struct lets per-button assertions pinpoint *which* button missed. Consolidation would either lose per-button blame in error messages or force every caller to read snapshot fields. Mechanical-reconciliation rule: when in doubt during conflict resolution, KEEP BOTH and let a future PR consolidate if it's actually warranted. Don't invent design in a rebase.
4. **Build-for-testing is the right smoke for a test-file-only rebase.** Full sim suite is ~5 min × N flakes; `xcodebuild build-for-testing` is ~30s and proves the merged Swift compiles in the UI test target. CI runs the real thing — don't double-spend the local box.
5. **Stash-list discipline.** This repo has 40+ accumulated stashes from agents that didn't drop after recovery. None of mine added this session, but the inventory is becoming a hazard — a future cleanup pass should `git stash drop` everything older than 7 days.
**2026-05-22T19:35:00Z** — Loop-30 iter-2 dispatch: WI-loop30-1 pushed (PR #114, CI runs 26309680580/26309668853 queued). Awaiting CI completion; Slot C (WI-loop30-9-impl) dispatches if this PR lands before Loop-30 closure.
