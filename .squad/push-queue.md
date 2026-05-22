# Squad Push Queue

Local commits waiting for `gh` auth restoration.

**Status legend:**
- `queued` — local commit exists on a feature branch; ready to push + open PR when auth restored
- `pending` — work in progress on a feature branch; not yet ready
- `blocked-on-network` — design/spec lives locally but the artifact itself can only be safely landed online (CI workflow files, URL wiring after a real host exists)
- `pushed` — pushed to origin, PR open
- `merged` — merged to `main` (will be pruned)

## Entries

### `squad/wi-loop30-1-ui-flake-stabilization`
- **Base:** `main` (`85080a8`)
- **Head:** `758e784`
- **Status:** queued
- **PR title:** `WI-loop30-1: stabilize toolbar settle + nav pop in UVBurnTimerUITests`
- **PR body:**

  > Implements Ma-Ti's GAP-iter2-B plan (`.squad/decisions/inbox/ma-ti-ui-flake-investigation.md`) to remove the iOS 26.4-only one-or-the-other flake between `testToolbarRendersBothSettingsAndEstimateInfoButtons` and `testEstimateInfoNavigationRoundTripReturnsToMainScreen`.
  >
  > Three additive XCUITest-only edits (no SUT touched):
  > 1. New helper `waitForToolbarSettled(in:timeout:)` polls BOTH `buttons["Settings"]` AND `buttons.matching("EstimateInfoButton").firstMatch` for `exists && isHittable`, mirroring `waitForHittable` semantics.
  > 2. Replace the discarded `_ = waitForHittable(...)` in `acknowledgeDisclaimerAndChooseTypeIII` with an `XCTAssertTrue` on the new helper — closes the silent-failure surface.
  > 3. In `testEstimateInfoNavigationRoundTripReturnsToMainScreen`, replace the immediate `XCTAssertFalse(navigationBars["About & Citations"].exists)` with an `XCTNSPredicateExpectation` (`exists == false`) awaited via `XCTWaiter.wait(timeout: 5)` so the pop-animation tail does not flake.
  >
  > **Acceptance signal deferred:** Statistical validation (≥20 consecutive UI-test legs green on `main`) requires CI re-enablement; this PR is the implementation half. Pair with the WI-loop30-9 CI-workflow PR for the infra half.
  >
  > Closes WI-loop30-1 (implementation).
  >
  > Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
