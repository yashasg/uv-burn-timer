# Ma-Ti — History

## Core Context

- **Project:** A UV exposure and sunburn timer app
- **Role:** Tester
- **Joined:** 2026-05-19T06:26:01.547Z

## Learnings

<!-- Append learnings below -->

- 2026-05-19T10:56:40Z: Added TDD coverage for behavior-first Fitzpatrick picker copy; implementation should reorder copy to burn/tan behavior before skin-color descriptors.
- 2026-05-19T16:30:05-07:00 (work item #4): Discovered latent failure in `approvedMainScreenSafetyCopyIsCaptured` — `skinTypePickerPrompt` had been updated to behavior-first Wheeler-aligned copy ("Choose by how your skin burns and tans…") but the test was still asserting the old string. Fixed. Added 9 new core tests covering: all-six-rows invariant, behavior-first/no-color-anchor for prompt, Wheeler §3.1 subtext cues, Plunder §2.3 inline source pointer, no-default footer (D-2026-05-19-012), not-medical-advice on major surfaces, WeatherKit attribution URL, full citation links set (Wheeler §4), and onboarding commit-gate model invariant. Added 2 UI tests: main screen does not expose Fitzpatrick picker post-onboarding; Settings skin-type edit path (uses XCTExpectFailure until Kwame implements). Final count: 56 / 0 failures. Key blocker: Settings skin-type edit row not yet in app. Full plan at `.squad/decisions/inbox/ma-ti-redesign-test-plan.md`.

- 2026-05-19T16:47:52-07:00 (circular gauge guard): Kwame landed `BurnRiskGaugeCard` (AppViews.swift ~line 1338) and two initial gauge UI tests while I was scoping. I confirmed the implementation matches the Iris spec (Issue 2, iris-redesign-a11y-review.md): placed between HeroTimerCard and UVIndexCard, `accessibilityIdentifier("BurnRiskGauge")`, `accessibilityLabel("Burn risk gauge. N% of estimated burn window elapsed.")`, `accessibilityValue(percentText)`, suppressed when estimate is nil/tier=.none. Kwame's two tests covered: (1) gauge present on stale estimate + value not 0%; (2) gauge absent when no estimate. Gaps I filled: (3) `testCircularGaugePresentOnFreshEstimate` — guards against conditioning on stale-only; (4) `testHeroTimeEstimateRemainsDominantAlongsideGauge` — guards gauge-as-replacement regression; (5) `testCircularGaugeAccessibilityLabelIsNonColorAndMeaningful` — guards label contains "Burn risk gauge" + "elapsed" text, value ends with "%". All 5 tests should pass (implementation is in place). Cannot run in this environment (iOS simulator required). Decision doc at `.squad/decisions/inbox/ma-ti-circular-gauge-test-guard.md`.

### 2026-05-20T00:01:47Z: Team Decision

**Scribe Log Entry**

Team approvals and implementations completed for approved redesign and paraphrasing initiatives:
- Wheeler: Paraphrase traceability review (conditional accept, fixes noted)
- Ma-Ti: Redesign tests passing + gauge guard tests verified
- Iris: HIG/accessibility audit passed
- Kwame: Implementation and circular gauge both passing

All inbox decisions merged into decisions.md.


- 2026-05-19T22:50:27.684-07:00 (duration formatting tests): Aligned duration-format coverage with Kwame’s in-progress hours/minutes implementation. Core tests now cover under-1-hour minutes, exact 1 hour, over-1-hour burn estimates, the sunscreen 2-hour cap, and No UV unavailable display/accessibility. UI expectations now target compact hero strings such as `Up to 2 hr` and `~1 hr 20 min`. SwiftPM core tests pass (62/0); full Xcode build/test was attempted with project-local DerivedData but did not complete before timeout, so simulator UI validation remains blocked.
