# Loop Closure — 2026-05-21T00:19Z (seventh loop)

- **Date:** 2026-05-20T17:19:00-07:00 (UTC: 2026-05-21T00:19Z)
- **Prior loop closure:** `loop-closure-20260520T1922Z.md` (sixth loop, in
  `.squad/decisions/archive/`)
- **Opening HEAD at loop start:** `ffe9e40`
  (`WI-44: Scribe fold — archive 5 inbox decisions into decisions.md (#10)`).
  The sixth-loop closure (`a347b30`, PR #14) opened on top of `ffe9e40`
  and merged early in the seventh loop, putting the seventh-loop opening
  effective HEAD at `a347b30`.
- **Closing HEAD at loop end:** `9fd32fb` after PR #15 (WI-50), PR #16
  (WI-51/52/53), and PR #17 (WI-57) merged. The seventh-loop closure
  PR (this note) opens on top of `9fd32fb` and additionally carries
  WI-59 / WI-60 (two more doc-only spec reconciliations surfaced
  during the closing-pass — see §4 below).
- **Carry-forwards from sixth loop:** WI-28 (hardware-blocked OLED
  sign-off) — still the only carry-forward.

## What this loop did

1. **Seventh-loop opening design-gap analysis (loop §3).** Ran via
   parallel explore agent against all four sources of truth
   (`.squad/files/user-flow-onboarding-main-spec.md`,
   `.squad/files/suchi-persona-annotations.md`,
   `.squad/files/iris-contrast-qa-checklist.md`,
   `.squad/files/iris-launch-readiness-checklist.md`) and `README.md`,
   against the full shipped surface
   (`app/Sources/UVBurnTimer/AppViews.swift` +
   `app/Sources/UVBurnTimerCore/*.swift`). Result: **three new gaps**
   (one functional, two doc reconciliations) filed as WI-50, WI-51,
   WI-57. The functional gap (WI-50) re-opened from sixth-loop
   stabilization fallout; the doc gaps surfaced as the spec was
   read in parallel with the shipped strings.

2. **WI-50 (PR #15) — stabilize Maya pull-to-refresh probe.** The
   sixth-loop WI-47 XCUI gesture was flaky on the GitHub `macos-15`
   CI runner; the pre-WI-50 mitigation (commit `42a9d48`,
   `@Environment(\.refresh)` probe button) was *itself* failing
   under iOS 26 because the `\.refresh` env value installed by
   `.refreshable` does not propagate to descendants of a `ScrollView`.
   The probe reported `RefreshActionNil` even though `.refreshable`
   was installed on `NowViewScrollView`. Closed with a two-signal
   probe that does not depend on `\.refresh` env propagation:
   - **Custom `\.refreshableInstalled` env key** (default `false`),
     set by a new `View.nowViewRefreshable(action:)` helper that
     wraps `.refreshable` and chains
     `.environment(\.refreshableInstalled, true)`. Custom env keys
     propagate the standard SwiftUI way, so descendants of the
     `ScrollView` (including the probe button) see the value. If a
     refactor drops `.nowViewRefreshable`, the marker reverts to
     `false` and the probe surfaces `RefreshActionNil` — same
     modifier-dropped regression WI-47 was designed to catch.
   - **Explicit closure injection** — `UITestRefreshableProbeButton`
     now receives the same `{ await refreshUV() }` closure body
     that `.nowViewRefreshable` wraps. Tapping the probe invokes
     that closure directly, so the post-tap `UV Index 4.0`
     assertion still proves the closure body is reachable through
     `refreshUV()`.
   No test files modified — the existing
   `testMayaPullToRefreshGestureRefetchesUVOnRepeatUse` already
   specifies the contract; this PR only changes production code to
   make the contract pass. Merged at `ed2759f`.

3. **WI-51 / WI-52 / WI-53 (PR #16) — hero verdict L3 caveat XCUI
   guard + link affordance + anchor-highlight assertion.** Closes
   the design-gap on Suchi `persona-annotations.md:108`:
   **"the single most important L3 interaction in the entire app"**
   for Asha (P4 Accutane). Until this PR the surface had zero XCUI
   coverage.
   - **WI-51** — XCUI guard for the deep-link. Added
     `.accessibilityIdentifier("HeroVerdictCaveatLink")` on the
     `NavigationLink` so XCUITest can target it reliably, plus
     `.buttonStyle(.plain)` (matching the `PhotosensitizationBanner`
     pattern) so the link renders as a single hit-testable button
     in the AX tree. Default `NavigationLink` rendering layered the
     inner `Label` and coordinate-based taps did not dispatch
     navigation on iOS 26. New test
     `testAshaHeroVerdictCaveatLinkRendersAndDeepLinksToApplicabilityAnchor`
     seeds via `-uiTestLongUncappedEstimate`, swipes the
     `NowViewScrollView` until the link is hittable, uses
     `tapUntilAppears` for iOS 26 hit-point robustness, then
     verifies the About nav bar lands.
   - **WI-52** — restore link affordance with
     `.foregroundStyle(.tint)`. Squad review (Iris UX + Kwame iOS)
     flagged that WI-51's `.buttonStyle(.plain)` stripped tint
     coloring that signals tappability, leaving the `Label`
     rendered as ordinary body text + `info.circle`. The
     `.buttonStyle(.plain)` is non-negotiable for XCUITest hit-
     testing; compensated by explicitly tinting the `Label` so the
     spec's "Learn more" deep-link affordance
     (`user-flow-onboarding-main-spec.md:65,87`) is preserved.
   - **WI-53** — assert the applicability anchor actually scrolled
     into view. Squad review (Ma-Ti Tester) flagged that the
     original WI-53 assertion
     (`staticText("When this estimate may not apply").exists`) was
     true even when `highlightEstimateApplicability:false` because
     XCUITest's `.exists` walks off-screen elements. The
     `notForMe` section lives ~1500 pt below the AboutView top.
     With the highlight flag, `.onAppear` runs
     `proxy.scrollTo(notForMeAnchor, anchor: .top)` and the header
     becomes hittable; without it, the section exists but is below
     the fold. Strengthened the test to assert `.isHittable` so a
     refactor that drops the flag or short-circuits the scroll
     fails the deep-link contract instead of silently degrading to
     a generic "About" open.

   Merged at `6f23587`.

4. **WI-57 (PR #17) — reconcile spec L2 banner copy + re-lock L2
   footer string.** Docs-only reconciliation closing two spec
   drifts on the LANE 2 (always-visible main-screen) layer of
   `.squad/files/user-flow-onboarding-main-spec.md`.
   - **Part A (Iris)** — banner copy drift. Spec LANE 2 §3
     documented the photosensitization-loop banner as
     `Taking photosensitizing meds? →`, but the shipped string
     (`ProductCopy.photosensitizationBannerLabel`) reads
     `Meds or photosensitive conditions? Learn more`. The shipped
     copy is the canonical form (broader trigger surface — Asha
     P4 covers Accutane meds AND conditions like lupus, per
     Suchi's persona annotations). Spec updated with an inline
     `WI-57` reconciliation note.
   - **Part B (Plunder)** — L2 footer string re-lock.
     `D-2026-05-19-011` originally locked the L2 footer to a
     draft string. The shipped string
     (`ProductCopy.reapplicationFooter`) is now richer and
     includes all five required L2 elements (redden-cover +
     reapply-cadence + informational-only + not-medical-advice +
     skin-variance qualifier):
     > "Cover up if skin reddens. Reapply sunscreen at least
     > every 2 hours regardless of timer. Informational only.
     > Not medical advice. Skin response varies."
     New decision `D-2026-05-20-001` re-locks the L2 footer to
     the shipped form, superseding D-2026-05-19-011's L2 wording
     only (L1/L3/L4 layers unchanged).

   No code change. No test change. No persona/user-flow
   architecture change. Pure docs reconciliation. Merged at
   `9fd32fb`.

5. **WI-59 / WI-60 (this loop-closure PR, on top of `9fd32fb`) —
   reconcile spec LANE 1 picker prompt + LANE 2 footer arrow.**
   Closing-pass copy-exactness review against the strings locked
   by `BurnTimeCalculatorTests.approvedMainScreenSafetyCopyIsCaptured`
   surfaced two more doc-only spec drifts that the opening
   functional gap analysis had not flagged. Both are paraphrase-vs-
   verbatim issues; no code or test changes are necessary because
   the shipped strings are already exact-match locked.
   - **WI-59** — `.squad/files/user-flow-onboarding-main-spec.md:43`
     (LANE 1 row 3). The spec quoted
     *"Pick the row that matches what your skin does, not its
     color"* as the picker header. That string was a paraphrase
     of two separate shipped strings
     (`ProductCopy.skinTypePickerPrompt` prompt header +
     `ProductCopy.skinTypePickerSubtext` first sentence) and never
     matched a single shipped surface. Updated to quote both
     shipped strings verbatim and cite the three copy-lock tests
     (`approvedMainScreenSafetyCopyIsCaptured` exact-match,
     `skinTypePickerHeaderIsBehaviorFirstPerWheelerSpec`,
     `skinTypePickerSubtextCapturesBehaviorCuesAndRangeOfTones`).
   - **WI-60** — `.squad/files/user-flow-onboarding-main-spec.md:68`
     (LANE 2 #7 footer disclaimer link). The spec rendered the
     footer disclaimer link as `Informational only. Not medical
     advice. →`, but the shipped surface is
     `ProductCopy.disclaimerLinkLabel` (`Informational only. Not
     medical advice.`) rendered via `Label(systemImage:
     "info.circle")` inside a `NavigationLink`
     (`AppViews.swift:1757`). Same precedent the spec already
     uses at LANE 2 #4 for the hero-card caveat: the design `→`
     was a spec-time link indicator, not a literal rendered
     character. Updated to drop the arrow, name the rendered
     `Label` + `NavigationLink` structure, and cite the existing
     exact-match copy-lock at
     `approvedMainScreenSafetyCopyIsCaptured`.

   Also updated the "Last reconciled with code" marker at the
   foot of the spec from `8a3406a` (WI-41) to `9fd32fb` (WI-59 +
   WI-60). Commit `12aae0a` on this PR branch.

6. **Seventh-loop closing design-gap analysis (loop §3 second
   pass).** Re-ran the parallel explore agent against the same
   sources of truth at the closing HEAD (post-WI-57, pre-WI-59 /
   WI-60). Result: **zero new functional gaps.** WI-59 + WI-60
   landed as out-of-band doc-exactness reconciliations during
   the closing pass (see §5 above). After both, every persona
   load-bearing annotation, every L1–L4 disclaimer-layer state
   transition, every README user scenario 1–10, every Iris
   contrast / launch-readiness checklist row that is testable in
   software, **and every spec-vs-shipped-copy exact-match
   reconciliation** is now under either unit-test or XCUI-test
   coverage. The only remaining yellow is the WI-28 polarized-
   OLED physical-device sign-off, which requires hardware no
   automated agent has and has been carry-forwarded since loop
   two.

## Backlog disposition

| WI | Title | Status | Evidence |
|---|---|---|---|
| WI-28 | Physical-device Iris polarized-OLED sign-off | ⛔ Carry-forward | Requires OLED iPhone + polarized-lens setup; no agent path |
| WI-50 | Stabilize Maya pull-to-refresh probe (env-key indirection) | ✅ Merged | PR #15 (`ed2759f`) |
| WI-51 | Hero verdict L3 caveat XCUI guard | ✅ Merged | PR #16 (`6f23587`) |
| WI-52 | Restore hero verdict link affordance with `.foregroundStyle(.tint)` | ✅ Merged | PR #16 (`6f23587`) |
| WI-53 | Assert applicability anchor `.isHittable` after scroll | ✅ Merged | PR #16 (`6f23587`) |
| WI-57 | Reconcile spec L2 banner copy + re-lock L2 footer string | ✅ Merged | PR #17 (`9fd32fb`) |
| WI-58 | This seventh-loop closure note | ✅ This file | PR (this one) |
| WI-59 | Reconcile spec LANE 1 row 3 picker prompt vs shipped `ProductCopy.skinTypePickerPrompt` + `skinTypePickerSubtext` | ✅ This PR | Commit `12aae0a` on this branch |
| WI-60 | Reconcile spec LANE 2 #7 footer disclaimer-link arrow vs shipped `Label(systemImage: "info.circle")` + `NavigationLink` | ✅ This PR | Commit `12aae0a` on this branch |
| WI-9 | Plan-for-elsewhere affordance | ⏸ v1.1-deferred | Intentional |

## Goals Checklist (loop.md §6)

- [x] **Working app** — Debug + Release builds green locally;
  `xcodebuild` completes with `-warnings-as-errors`. 69/69 Swift
  Testing unit tests pass locally on iPhone 17 Pro / iOS 26.4. CI
  on PRs #15, #16, #17 all green (`success` per
  `gh run list --branch main`).
- [x] **UI/UX approved** — Opening design-gap analysis closed three
  gaps (WI-50, WI-51/52/53, WI-57). Closing design-gap analysis at
  HEAD `9fd32fb` returned zero new actionable gaps. Iris
  affordance review approved WI-52's tint restoration on
  `HeroVerdictCaveatLink`.
- [x] **User scenarios captured** — `README.md` user scenarios
  1–10 remain accurate. Scenario 4
  (photosensitization reach-back) now has full Asha-P4 hero-verdict
  deep-link XCUI coverage via
  `testAshaHeroVerdictCaveatLinkRendersAndDeepLinksToApplicabilityAnchor`.
- [x] **Expert approved** — Plunder (L2 footer relock via
  D-2026-05-20-001), Iris (banner copy reconciliation + tint
  restoration), Suchi (Asha P4 deep-link is the single most
  important L3 interaction — now under XCUI coverage), Wheeler
  (banner trigger surface broadened from "meds" to "meds or
  photosensitive conditions" preserves photosensitization safety
  reach). End-of-loop nine-member parallel review returned all
  green (see § Parallel squad-member review below).
- [~] **Code tested and validated** — **69 Swift Testing unit
  tests + 39 XCUI tests** on the closing HEAD (verified by hard
  count: `grep -cE "@Test|func test"` returns 60 + 9 unit and 39
  XCUI). Net delta this loop: **+1 XCUI test** (WI-51 added
  `testAshaHeroVerdictCaveatLinkRendersAndDeepLinksToApplicabilityAnchor`),
  unit tests unchanged. **WI-28 manual launch-readiness gates
  remain unsigned** — carry-forward.

## Delta since prior loop closure

- **Test count:** 38 XCUI (baseline at `ffe9e40`) → 39 XCUI (after
  WI-51 lands). Unit tests: 69 → 69 (no change). Net: **+1 XCUI
  test** (WI-51).
- **Accessibility identifiers added:** `HeroVerdictCaveatLink` on
  the NavigationLink in `HeroTimerCard.applicabilityCaveatLink`.
  This complements `NowViewScrollView`, `PhotosensitizationBanner`,
  `LocationChip`, `SPFChip`, `DisclaimerSeeAboutLink`,
  `BurnRiskGauge`, and `BurnRiskGaugePlaceholder`.
- **Production code changes (functional):** Custom
  `\.refreshableInstalled` `EnvironmentKey` +
  `View.nowViewRefreshable(action:)` helper (WI-50);
  `.buttonStyle(.plain)` + `.foregroundStyle(.tint)` on the hero
  verdict caveat `NavigationLink` (WI-51 + WI-52); no other
  production-code surface touched.
- **Production code changes (test seams):** None new this loop —
  WI-50 reused the existing `-uiTestRefreshableEcho` seam, and
  WI-51/52/53 layer on top of existing `-uiTestLongUncappedEstimate`
  seam + the existing `highlightEstimateApplicability` AboutView
  flag.
- **Spec/docs changes:** Single-line reconciliation in
  `.squad/files/user-flow-onboarding-main-spec.md` LANE 2 §3
  (banner copy) + appended `D-2026-05-20-001` in
  `.squad/decisions.md` (L2 footer re-lock) — both via WI-57 in
  PR #17. Plus two more single-line reconciliations in the same
  spec file in this PR: LANE 1 row 3 picker prompt (WI-59) and
  LANE 2 #7 footer disclaimer-link arrow (WI-60). All four
  changes are doc-only and quote strings already exact-match
  locked by `BurnTimeCalculatorTests.approvedMainScreenSafetyCopyIsCaptured`.
  No persona / IA / user-flow-architecture changes.
- **Decision archive:** No fold operation this loop — inbox was
  already empty after WI-44 (sixth loop). No new inbox arrivals
  to fold.
- **Persona coverage update:** Asha's "single most important L3
  interaction in the entire app" (per
  `suchi-persona-annotations.md:108`) is now XCUI-guarded. All
  five persona load-bearing annotations from Suchi's overlay are
  now under XCUI test coverage:
  - **Greta** — L2 footer
    (`testScenario5CappedEstimateRendersLongCaveatAndFooter`,
    `testScenario8StaleEstimateShowsWarningRecalculateAndAccessibleTierSeverity`).
  - **Maya** — pull-to-refresh
    (`testMayaPullToRefreshGestureRefetchesUVOnRepeatUse` — now
    backed by the WI-50 env-key probe so the modifier-dropped
    regression is caught even when iOS 26
    `\.refresh`-env-propagation behaviour shifts).
  - **Devon** — no-default Fitzpatrick validator
    (`testScenario1ColdLaunchShowsRequiredDisclaimerThenScenario2RequiresSkinTypeSelection`).
  - **Asha** — L1 visibility loop + see-About round-trip
    (`testDisclaimerCoverSurfacesInlineSeeAboutLinkInsteadOfButton`,
    `testDisclaimerL1SeeAboutSheetRoundTripLeavesL1CoverPresent`),
    re-attestation on foreground
    (`testScenario8ForegroundAfterElapsedEstimateReattestsDisclaimer`),
    **and now hero-verdict deep-link to About applicability anchor**
    (`testAshaHeroVerdictCaveatLinkRendersAndDeepLinksToApplicabilityAnchor`
    — added this loop).
  - **Tomás** — window-elapsed safety state
    (`testScenario8StaleEstimateShowsWarningRecalculateAndAccessibleTierSeverity`).

## Parallel squad-member review (loop §6/§7)

Nine-member parallel review ran against post-merge HEAD `9fd32fb`.
Full transcript in `.squad/files/seventh-loop-end-of-loop-review.md`.
Verdict: **9 green, 0 yellow, 0 red, 0 new gaps**.

| Member | Status | One-line summary |
|---|---|---|
| Gaia | 🟢 | Three merged PRs internally consistent; D-2026-05-20-001 coherent with L1/L3/L4 footer decisions; spec reconciliation in WI-57 leaves no other layer un-reconciled. |
| Kwame | 🟢 | `nowViewRefreshable` env-key indirection is the right call given iOS 26 `\.refresh` propagation behaviour; `.buttonStyle(.plain)` + `.foregroundStyle(.tint)` is a clean restoration. No swiftlint nits in the new code. |
| Iris | 🟢 (with standing WI-28 yellow) | WI-52 tint restoration meets WCAG AA contrast on hero card; hit-target ≥ 44 pt; VoiceOver labels intact. WI-57 banner copy preserves trigger-surface inclusivity. |
| Ma-Ti | 🟢 | WI-53 `.exists` → `.isHittable` upgrade closes the silent-degradation class on the applicability anchor. No remaining `.exists` assertions on scroll-target headers in About. |
| Wheeler | 🟢 | "Meds or photosensitive conditions" preserves the medical safety reach (Accutane + lupus + tetracyclines + retinoids). L2 footer "skin response varies" qualifier still anchored on Fitzpatrick variance literature. |
| Suchi | 🟢 | All five persona load-bearing annotations now under XCUI coverage (Greta, Maya, Devon, Asha, Tomás). Asha-P4's hero-verdict deep-link — flagged as "the single most important L3 interaction in the entire app" — was the last open gap and is now closed. |
| Plunder | 🟢 | D-2026-05-20-001 re-locks the L2 footer to the shipped string which contains all five required L2 elements (redden-cover + reapply-cadence + informational-only + not-medical-advice + skin-variance). |
| Argos | 🟢 | No subscription, account, analytics, or third-party tracking surface touched this loop. Anti-subscription wedge intact. |
| Gi | 🟢 | `RefreshableInstalledKey` is an SwiftUI `EnvironmentKey`, not a `UserDefaults` key — does not persist across launches. Donatello-M7 (zero-data) boundary intact: SPF + Fitzpatrick + rationale-ack + optional rounded coord remain the only on-device persisted state. |

**Iris standing-yellow restated:** WI-28 (polarized-OLED physical-
device sign-off) remains unsigned. This is **not** a new gap — it
is the documented hardware-blocked carry-forward that no automated
agent has a path to resolve. It does not block the seventh-loop
closure, and it does not change the consolidated "9 green, 0
yellow, 0 red" verdict on the seventh-loop scope.

## Risk / known issues

- Local UI test runs remain flaky on this shared workstation
  (concurrent Copilot agents → cross-process simulator
  contamination; `Simulator device failed to launch
  com.yashasgujjar.uvburntimer.uitests.xctrunner` /
  `FBSApplicationLibrary returned nil` after the first XCUI test).
  GitHub-runner CI is the authoritative source of truth for the
  XCUI suite. Unit tests + Debug build + Release build all pass
  locally with `-warnings-as-errors` clean.
- WI-28 remains the only open launch blocker and requires human
  action with physical hardware (OLED iPhone + polarized-lens
  setup).

## Next loop seeds

1. **No automated blockers.** The backlog is empty save WI-28.
2. The eighth-loop opening design-gap analysis is expected to
   return zero new actionable gaps in software, just like the
   seventh-loop closing analysis did. The eighth loop is
   procedural unless a new design / spec / persona change lands.
3. Consider a v1.0 TestFlight build once WI-28 physical-device
   pass is obtained.
4. WI-9 (plan-for-elsewhere affordance) remains deferred to v1.1.

## Provenance note

This closure note is committed directly into
`.squad/decisions/archive/` rather than `.squad/decisions/inbox/`,
following the same convention as the fourth, fifth, and sixth
loop closures: `.squad/decisions/inbox/` is `.gitignored`, so
closure notes have always landed straight in `archive/`.

The end-of-loop nine-member parallel review transcript is
committed alongside this note in
`.squad/files/seventh-loop-end-of-loop-review.md` so future loops
can read each member's reasoning without re-running the explore
agent.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
