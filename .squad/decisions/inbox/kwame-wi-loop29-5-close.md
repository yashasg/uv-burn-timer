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
