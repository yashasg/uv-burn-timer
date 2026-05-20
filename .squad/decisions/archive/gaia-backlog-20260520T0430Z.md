# Design Gap Analysis & Backlog — 2026-05-20T04:30Z

**Author:** Gaia (Lead / Architect)
**Date:** 2026-05-20T04:30:00Z
**Branch under review:** `main` at `7daac21` (post WI-1..WI-10 loop closure)
**Prior backlog:** `.squad/decisions/inbox/gaia-backlog-20260520T031000Z.md` — closed:
WI-1..WI-8, WI-10 merged via MRs !10–!18; WI-9 deferred to v1.1.

**Inputs cross-checked:**

- Approved flow: `user-flow-onboarding-main.excalidraw` + textual snapshot
  `.squad/files/user-flow-onboarding-main-spec.md`
- Persona overlays: `.squad/files/suchi-persona-annotations.md`
- Repo `README.md` ("User scenarios captured" + "Privacy and product
  guardrails")
- iOS sources: `app/Sources/UVBurnTimer/AppViews.swift`,
  `UVBurnTimerApp.swift`, `WeatherLocationServices.swift`, and all of
  `app/Sources/UVBurnTimerCore/*.swift`
- Tests: `app/Tests/UVBurnTimerCoreTests/{BurnTimeCalculatorTests,UVWorkflowTests}.swift`
  and `app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift`
- Decisions ledger tail (last 500 lines) of `.squad/decisions.md`,
  plus four files in `.squad/decisions/inbox/` not yet merged
- Recent commit log: `git log --oneline -30 main` (12 squash-merges
  this loop, newest `7daac21`)

---

## Summary

The shipped app now matches the approved 4-lane Excalidraw canvas at the
structural and copy level. WI-1..WI-10 closed the load-bearing gaps from
the prior backlog (truthful privacy copy, README scenario parity,
compact inputs row, display-cap copy, photosens yellow banner, hero
label, IAP guard test, attribution audit, persistence ADR). Five
**small** new gaps remain — none are launch blockers, one is a runtime
copy bug (P1), one is an unresolved ADR open question (P2), the rest
are spec-alignment polish or out-of-code-process items (P3). No
unmerged feature branches; CI is green on every recently merged MR.

---

## 1. Goals Status (loop.md §6)

| # | Goal | Status | Evidence |
|---|------|--------|----------|
| 1 | **Working app** | ✅ pass | External GitHub-runner CI green on every merged MR (!10..!18). Local `./build.sh` Debug+Release succeeds. `7daac21` is the current `main` HEAD with a clean working tree. |
| 2 | **UI/UX approved** | ✅ pass | LANE 2 fully implemented in `AppViews.swift`: large-title nav (line 80–92), yellow photosens banner above hero (line 160–196), hero card with `Burn-time estimate` label and inline `Meds + conditions can shorten this. Learn more` caveat (line 528–605, 594), UV secondary card with always-visible `WeatherAttributionView` (line 762–807), compact `Location + SPF` chip row that reflows to VStack at AX sizes (line 198–248), persistent footer with `Informational only. Not medical advice.` link (line 1675–1693). Hero number renders with `.contentTransition(.numericText)` (line 707, 726) per spec §LANE 1 #6. |
| 3 | **User scenarios captured** | ✅ pass | README `User scenarios captured` (lines 17–28) and `Privacy and product guardrails` (lines 30–37) now list 4 SPF tiers without "None", explicitly state skin type + SPF + rationale-ack persistence, and list the four UV-display caps verbatim (`~45 min`, `~1 hr`, `Up to 2 hr`, `4+ hr`). |
| 4 | **Expert approved** | ✅ pass | Wheeler: 2-hour sunscreen cap (`ProductTiming.sunscreenReapplicationIntervalSeconds = 7_200`, BurnTimeCalculator line 22–35), behavior-first picker copy (FitzpatrickSkinType.pickerDescription line 24–39), MED constants. Plunder: 8 pre-submit flags — IAP guard `pricingGuardrailsRejectInAppPurchaseFrameworks` (BurnTimeCalculatorTests line 640), prohibited-integrations guard line 595, privacy copy aligned with persistence (`aboutPrivacy` line 73–74, `cacheRetentionLine` line 28–29), attribution audit (UI tests line 143–192). Iris: gauge inside hero card (HeroTimerCard line 562+587), banner styling (line 160–196), compact chip row (line 198–248). Suchi: persona-keyed L1/L2/L3 surfaces all present; cold-launch L1 re-attestation preserved (UVBurnTimerApp.swift line 13 `initialShowDisclaimer = true`); `ForegroundReattestationTracker` re-fires on `estimateWindowElapsed` (AppViews line 110–116). |
| 5 | **Code tested and validated** | ✅ pass | 64 Swift Testing tests (`@Test` count: 60 in `BurnTimeCalculatorTests.swift` + 8 in `UVWorkflowTests.swift`, of which 4 added this loop) plus 30 XCUI tests including the WI-merged additions `testAppleWeatherAttributionVisible{OnFreshUVEstimate,OnStaleEstimate,OnCappedEstimate,WhenWeatherUnavailable,WhenLocationDenied}` (lines 143–192), `testPhotosensitizationBannerRendersAsFullWidthBannerAboveHero` (363), `testMainScreenShowsLocationAndSPFInCompactRow` (516), `testMainScreenSPFChipOpensMenuWithAllFourLevels` (566), `testPersistentFooterDisclaimerLinkUsesSpecCopyAndOpensAbout` (590), `testLocationRationaleAcknowledgementSurvivesRelaunch` (478). External GitHub-runner CI is green per `loop-closure-20260520T043000Z.md`. Local concurrent-agent flakiness is environmental (NSMachErrorDomain -308 sim restarts), documented as a non-blocker. |

All five goals **pass**.

---

## 2. Design Gap Analysis (by LANE)

### LANE 1 — Onboarding (`.squad/files/user-flow-onboarding-main-spec.md` §LANE 1)

| Screen | Spec requirement | Implementation | Verdict |
|---|---|---|---|
| 1 Cold Launch | Splash → gated by L1 | `UVBurnTimerApp.init` sets `initialShowDisclaimer = true` unconditionally on each cold launch | ✅ aligned |
| 2 L1 Disclaimer (`.fullScreenCover`) | Mandatory ack + inline *see About* + photosensitizer line + "I understand" | `DisclaimerCover` (AppViews line 924–984): renders title, photosensitizer line, body, children line, then a **separate Button** labelled "See About: when estimates may not apply" — not an inline link inside body prose. Function works (`testScenario4PhotosensitizationReachBackOpensAboutApplicability` covers the deep-link from the banner; `DisclaimerCover` deep-link is functional via the `showAbout` sheet) but the spec says **inline** *see About* within the body sentence. | ⚠️ small visual drift → WI-13 |
| 3 Skin-Type Picker | Fitzpatrick I–VI, **no default**, Wheeler-edited copy | `SkinTypePickerList` + `SkinTypePickerRow` (line 1133–1217). No default selection (`SkinTypeOnboardingDraft.canContinue` requires `pendingSkinType != nil`). `pickerDescription` uses behavior-first phrasing (`FitzpatrickSkinType.swift` line 26–37). Asserted by `fitzpatrickPickerCopyStartsWithBurnTanBehavior` + `skinTypePickerFooterExplicitlyStatesNoDefault`. | ✅ aligned |
| 4 Location Permission | Privacy rationale BEFORE iOS prompt; CTA in `.safeAreaInset(.bottom)`. **Spec also says: "SPF picker also shown"** | `LocationRationaleCard` (line 907–922) renders pre-prompt rationale + privacy line. Primary action in `.safeAreaInset(edge: .bottom)` (line 93–101). The first tap on `primaryAction` calls `allowSystemPromptOrAcknowledgeRationale()` and persists the ack only on the *next* tap (per `LocationPromptGate.allowSystemPromptOrAcknowledgeRationale`, UVWorkflow line 85–92). **SPF is NOT shown on this onboarding step** — it lives on the main screen's compact chip row (line 232–248). | ⚠️ spec/canvas text drift → WI-14 (the canonical IA decision is SPF-on-main; the canvas should be updated to match, not the code) |
| 5 Photo-Sens Awareness | NOT a separate screen — three surfaces: (a) inside L1, (b) L3 link, (c) L4 About anchor. **No "I'm photosensitive" toggle** | (a) L1 photosensitizer line + see-About button: ✅ DisclaimerCover line 941–958. (b) L3 main-screen photosens banner: ✅ AppViews line 160–196. (c) L4 About anchor `notForMe`: ✅ AppViews line 1286–1305. Source code grep confirms zero toggles, zero stored "photosensitive: Bool" state. | ✅ aligned |
| 6 First Verdict → Main | Animates `.contentTransition(.numericText)`; success haptic | HeroTimerCard `estimateText` uses `.contentTransition(.numericText())` (line 707, 726). `RootView.body` attaches `.sensoryFeedback(.success, trigger: uvIndex)` (line 143). | ✅ aligned |

**Inter-screen onboarding empty-state copy** — Suchi Screen 2 notes
that the hero empty state should read *"Tap **Use my location** to
compute your estimate"*. The implementation initializes
`statusMessage = "Pick a skin type to see your estimate."` (AppViews
line 31) and only mutates it on subsequent user actions. After the
onboarding `SkinTypeOnboardingView` commits a skin type, the
`statusMessage` is **not refreshed**, so a user who has just selected
Type III lands on a main screen whose hero says "Pick a skin type to
see your estimate." — i.e. the copy still asks them to do something
they have already done. **This is a P1 runtime copy bug → WI-11.**

### LANE 2 — Main Screen (`.squad/files/user-flow-onboarding-main-spec.md` §LANE 2)

| Region | Spec requirement | Implementation | Verdict |
|---|---|---|---|
| 1 Status bar | Annotated only | OS owns | ✅ |
| 2 Large Title nav + ⚙︎ gear | `UV Burn Timer` + trailing gear (SettingsSheet) | `.navigationTitle("UV Burn Timer")` + `.navigationBarTitleDisplayMode(.large)` + `ToolbarItem(.primaryAction)` gear → `showSettings` sheet (line 80–92). | ✅ |
| 3 Photosens loop banner | Yellow, full-width, above hero card, opens L1 reach-back | Line 160–196: `Color.yellow.opacity(.18/.35)` fill with `Color.orange` border, full-width via `frame(maxWidth: .infinity, alignment: .leading)`, NavigationLink → `AboutView(highlightEstimateApplicability: true)`. Asserted by `testPhotosensitizationBannerRendersAsFullWidthBannerAboveHero` (≥85% screen width, sits above `Burn-time estimate`). | ✅ |
| 4 Hero verdict card | Label `Burn-time estimate`, hero number, verdict, inline caveat `Meds + conditions can shorten this. Learn more →` | HeroTimerCard line 528–760: label line 546, heroContent line 633–689, TierBadge line 554, inline NavigationLink with `mainVerdictCaveatLinkLabel` + `info.circle` line 590–597. Caveat copy literal-matches spec: `"Meds + conditions can shorten this. Learn more"` (ProductCopy line 47). | ✅ |
| 5 UV Index secondary card | `UV Index 6.2` + `Source: Apple Weather` lockup always visible | `UVIndexCard` (line 762–785) and `UVIndexPlaceholderCard` (line 787–807). Both embed `WeatherAttributionView()` plus the `uvSourceLine` text. Audit suite passes for every weather-derived state (lines 143–192). | ✅ |
| 6 Location + SPF row | Compact 44pt controls, no segmented control on main | `mainInputsRow` line 198–211 (HStack at standard sizes, VStack at AX sizes); chips with `minHeight: 44` (lines 222, 242). Menu-style SPF chip (line 232–248) — never segmented on main. Verified by `testMainScreenShowsLocationAndSPFInCompactRow` (line 516–564) and `testMainScreenSPFChipOpensMenuWithAllFourLevels`. | ✅ |
| 7 L1 disclaimer link | Inline `Informational only. Not medical advice. →` at footer | `PersistentFooter` (line 1675–1693) shows `ProductCopy.disclaimerLinkLabel` ("Informational only. Not medical advice.") with `info.circle` chevron, NavigationLink to AboutView at applicability anchor. Verified by `testPersistentFooterDisclaimerLinkUsesSpecCopyAndOpensAbout`. | ✅ |
| 8 Home indicator | safe-area completeness | `.safeAreaInset(edge: .bottom)` wraps footer + primary action | ✅ |
| 9 HIG note (Dynamic Type AX5 reflow, ≥44pt, semantic colors, VO combined-card) | Compliance | AX5 reflow: `dynamicTypeSize.isAccessibilitySize` branches in `mainInputsRow` (line 200) and `estimateText` (line 716). 44pt min: chips (line 222, 242), primaryAction `.controlSize(.large)` (line 312). Semantic colors: `Color("SeverityLong"/"Moderate"/"Short")` with luminosity-dark + contrast-high variants in `Assets.xcassets/Severity*.colorset/Contents.json`. VO combined: HeroTimerCard `.accessibilityElement(children: .contain)` + custom `accessibilityLabel` (line 603–604). Reduce Motion: `accessibilityReduceMotion` branch in `staleEstimateContent` (line 704) and `estimateText` (line 721). Increase Contrast: `colorSchemeContrast` adjusts banner and SafetyStatusCard opacities (line 181, 187, 829). | ✅ |

**Hero empty-state copy issue (Screen 2 ↔ LANE 2):** see WI-11.

### LANE 3 — Branch points / annotations

| Callout | Status | Evidence |
|---|---|---|
| 1 🚨 No-default Fitzpatrick (D-2026-05-19-012) | ✅ | `SkinTypeOnboardingDraft.canContinue` (UVBurnTimerSession line 31); `coldLaunchHasNoDefaultSkinTypeAndReattestsWhenEstimateWindowElapsed` test (BurnTimeCalculatorTests line 133); `skinTypePickerFooterExplicitlyStatesNoDefault` (line 860). |
| 2 🚨 L1 sticky + photo-sens reach-back | ✅ | Disclaimer re-fires on cold launch (UVBurnTimerApp line 13–69); banner reach-back tested by `testScenario4PhotosensitizationReachBackOpensAboutApplicability` (UI tests line 341–350). |
| 3 📌 Compact duration display cap | ✅ | `BurnTimeEstimate.displayText` (BurnTimeCalculator line 42–56) produces `~45 min` / `~1 hr` / `~1 hr 20 min` / `Up to 2 hr` / `4+ hr`. Verified by `longUnprotectedEstimateAtFourHoursShowsApprovedDisplayCap`, `exactOneHourEstimateDoesNotShowRawSixtyMinutes`, `typeThreeWithSPFThirtyAtUVEightCapsSunscreenWindowButKeepsRawModel`, `testLongUncappedEstimateStillRendersSafetyCaveat` (renders `~1 hr 20 min`), `testScenario5CappedEstimateRendersLongCaveatAndFooter` (renders `Up to 2 hr`). |
| 4 📌 WeatherKit attribution always visible | ✅ | `WeatherAttributionView` embedded in UVIndexCard, UVIndexPlaceholderCard, AboutView, AttributionView. Audit suite at UI-tests line 134–192 verifies fresh / stale / capped / weather-unavailable / location-denied / attribution-unavailable. |
| 5 📌 Verdict-card learn-more deep-link | ✅ | HeroTimerCard line 590–597 (inline NavigationLink with `mainVerdictCaveatLinkLabel`). |
| 6 ⚖️ Plunder's 8 pre-submit flags (non-blocking) | ✅ | All eight flags now have either a copy-or-source-guard test (`appSourcesAvoidProhibitedIntegrations`, `pricingGuardrailsRejectInAppPurchaseFrameworks`, `productCopyAvoidsMonetizationDriftLanguage`, `productCopyAvoidsBannedClinicalClaims`, `aboutPrivacyCopyDescribesRoundedCoordinatesToAppleWeather`, `attributionAndPricingCopyAreCanonical`, `weatherKitAttributionCopyMeetsAppleRequirements`, `appleWeatherAttributionVisibleOn*` family). |
| 7 🔁 Re-attestation on window-elapsed | ✅ | `ForegroundReattestationTracker.shouldPresentOnForeground` requires `returnedFromBackground && acknowledgedDisclaimer && estimateWindowElapsed` (UVBurnTimerSession line 114–137). Verified by `foregroundReattestationSurvivesInactiveHopAfterBackground` + `foregroundReturnAfterElapsedEstimateRequiresDisclaimerReattestation` + UI test `testScenario8ForegroundAfterElapsedEstimateReattestsDisclaimer`. |
| 8 📌 A11y conformance gate (AX5, VoiceOver, Reduce Motion, Increase Contrast, **polarized OLED test**) | ⚠️ mostly | AX5 + VoiceOver + Reduce Motion + Increase Contrast all wired (see LANE 2 row 9). The **polarized OLED outdoor-readability test** is listed as a launch-readiness gate but is not automated and has no captured manual checklist. → WI-16 |

### LANE 4 — Persona overlays (Suchi)

| Persona | Load-bearing surface | Status |
|---|---|---|
| P1 Greta (gram-counter, II/III) | L2 footer on repeating use | ✅ `PersistentFooter` always present in `.safeAreaInset(.bottom)` (AppViews line 93–101). |
| P2 Maya (open-water swim, III) | Pull-to-refresh on repeating use | ✅ `.refreshable { await refreshUV() }` on the main ScrollView (line 77–79). |
| P3 Devon (PCT thru-hike, Fitz I) | No-default Fitzpatrick | ✅ See LANE 3 callout 1. |
| P4 Asha (Accutane, IV) | L1 + L3 visibility loop, cold-launch re-attestation | ✅ L1 cover every cold launch (UVBurnTimerApp); L1 → AboutView at `notForMe` anchor (DisclaimerCover.showAbout, line 952–958, 977–981); L3 banner + hero caveat both deep-link to `AboutView(highlightEstimateApplicability: true)` which auto-scrolls to `notForMe` (line 1371–1385). |
| P5 Tomás (trail run, IV/V) | Window-elapsed safety moment, warning haptic | ✅ `.sensoryFeedback(.warning, trigger: isEstimateStale)` (line 144); `SafetyStatusCard` with `exclamationmark.shield.fill` for elapsed window (line 563–569); UI-tested by `testScenario8StaleEstimateShowsWarningRecalculateAndAccessibleTierSeverity`. |

### "What's deliberately NOT on the canvas" — verified absent

- No "Photosensitization Attestation" hard screen → confirmed: zero
  toggles, no `@AppStorage` for photosensitive status, no medical-form
  surfaces (`grep -r "photosensitive.*Bool\|attestation.*State" app/Sources/` returns nothing).
- No Live Activity, no Dynamic Island, no watchOS surfaces → confirmed
  (no `ActivityKit` / `WatchKit` / `WKExtensionDelegate` imports).
- No reapplication timer UI → confirmed.
- No "Outdoor Mode" toggle → confirmed (relies on system True Tone +
  Increase Contrast asset variants).
- No push-notification surfaces → confirmed (no `UNUserNotificationCenter`
  usage in `app/Sources/`).

### Inflight inbox files not yet folded into the ledger

- `.squad/decisions/inbox/loop-closure-20260520T043000Z.md` — loop
  closure summary written this session.
- `.squad/decisions/inbox/gaia-model-default-loop.md` — default-model
  decision (proposed status).

These two files exist in the inbox and have not been merged into
`.squad/decisions.md`. **Not a code gap; a Scribe action → WI-17.**

---

## 3. Backlog — NEW work items (WI-11 onward)

WI-1..WI-10 are closed per loop-closure note; not re-listed.

### WI-11: Refresh hero empty-state status copy after skin-type selection

- **Priority:** P1
- **Owner:** Kwame
- **Reviewer:** Iris
- **Type:** fix (runtime copy bug)
- **Source of gap:** `.squad/files/suchi-persona-annotations.md` Screen
  2 ("Hero shows sun symbol + prompt 'Tap **Use my location** to
  compute your estimate'"). `app/Sources/UVBurnTimer/AppViews.swift`
  initializes `statusMessage = "Pick a skin type to see your
  estimate."` at line 31 and only mutates it on explicit user actions
  (line 328, 347, 350, 362, 366, …). After the user lands the
  `SkinTypeOnboardingView` and commits Type III (or any type), the
  message remains the stale "Pick a skin type to see your estimate."
  on the hero card. Every persona who completes onboarding sees a
  prompt to do something they have already done.
- **Acceptance criteria:**
  1. When the user has a `session.selectedSkinType` but no `uvIndex`
     and no `locationFailureMessage`/`weatherFailureMessage`, the hero
     empty-state copy reads (or is logically equivalent to)
     `"Tap Use my location to compute your estimate."`.
  2. When `session.selectedSkinType == nil` (which can only happen via
     Settings → Edit skin type → cancel without selecting, since
     onboarding gates it), the prompt remains the original
     `"Pick a skin type to see your estimate."`.
  3. The change derives the hero empty-state copy *from* the session
     state rather than from a mutable `@State` string. Recommended:
     move the empty-state line into a computed property on `RootView`
     (or into `ProductCopy` as
     `emptyStateAwaitingLocation`/`emptyStateAwaitingSkinType`) so the
     copy cannot drift out of sync with state again.
  4. Hero `accessibilityLabel` when no estimate is present must reflect
     the updated copy (currently `HeroTimerCard.accessibilityLabel`
     falls back to `statusMessage` on line 750–752).
- **Test plan (TDD — write FIRST, then refactor):**
  - Add `coldLaunchAfterSkinTypeSelectedPromptsForLocation` to
    `BurnTimeCalculatorTests.swift`: build an `UVBurnTimerSession` with
    `selectedSkinType = .typeIII, acknowledgedDisclaimer = true,
    selectedSPF = .spf30` and assert the new computed copy contains
    `"Use my location"` (and does NOT contain `"Pick a skin type"`).
  - Add a sibling assertion for the
    `session.selectedSkinType == nil` branch that retains
    `"Pick a skin type"`.
  - Add `testHeroEmptyStateAfterOnboardingPromptsForLocation` to
    `UVBurnTimerUITests.swift`: launch app, acknowledge disclaimer,
    pick Type III, assert the hero copy is `"Tap Use my location..."`
    (or whatever exact ProductCopy string is chosen) BEFORE any
    location action. This will also detect regressions in
    `verdictText` (line 732–747) if the chosen approach moves the
    string into the verdict.
- **Estimated touched files:**
  - `app/Sources/UVBurnTimerCore/ProductCopy.swift` (new copy
    constants)
  - `app/Sources/UVBurnTimer/AppViews.swift` (compute hero empty
    state from session, not from `@State`)
  - `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift`
  - `app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift`

### WI-12: Close ADR Guardrail #2 — `Clear saved location` × rationale-ack

- **Priority:** P2
- **Owner:** Plunder (ratify) → Kwame (implement if behavior changes)
- **Reviewer:** Gaia
- **Type:** ADR addendum + (possibly) fix
- **Source of gap:** `.squad/decisions/inbox/gaia-location-rationale-persistence.md`
  Guardrail #2 explicitly leaves an open product/legal question:
  > "Currently the Settings → 'Clear saved location' button only
  > clears the rounded coordinate. Confirm with Plunder whether this
  > also needs to clear the rationale ack… **Flag to Plunder for
  > sign-off.**"
  Today `RootView.clearSavedRoundedCoordinate` (AppViews line 470–475)
  clears only `cachedRoundedCoordinateStorage` +
  `legacyCachedUVSnapshotStorage` + the in-memory `roundedCoordinate`;
  it does **not** clear `persistedLocationRationaleAcknowledged`. The
  ADR rationale says "rationale is about *what gets sent to Apple
  Weather when location is granted*, not about the saved coordinate
  itself," but no Plunder sign-off is recorded in the ledger. Without
  the sign-off the behavior is undocumented intent.
- **Acceptance criteria:** **One of:**
  - **(a) Ratify current behavior.** Plunder writes a one-paragraph
    addendum to `gaia-location-rationale-persistence.md` (or a new
    `plunder-rationale-ack-clear-decision.md`) stating that
    `Clear saved location` intentionally does NOT clear the
    rationale-ack flag, and tying that to a documented mental model
    (rationale = what coordinates we send; saved coord = where we
    last sent them; the two are decoupled). Add a Swift test
    `clearSavedLocationDoesNotClearRationaleAcknowledgment` that pins
    this contract.
  - **(b) Change behavior.** Modify `clearSavedRoundedCoordinate` to
    also reset `persistedLocationRationaleAcknowledged` and the
    in-memory `locationPromptGate`. Add UI regression
    `testClearSavedLocationAlsoForgetsRationaleAck`: launch with
    `-uiTestSavedPreferences`, open Settings, tap
    `Clear saved location`, relaunch, assert the
    `LocationRationaleCard` (`"Location permission"`) reappears.
- **Test plan (TDD):** Path (a) — add a UI assertion that
  `LocationRationaleCard` does *not* reappear after
  `Clear saved location` (the inverse of the current implicit
  contract). Path (b) — flip the assertion. Whichever path Plunder
  chooses, the test is small and isolates the ack lifecycle from the
  coordinate lifecycle.
- **Estimated touched files:**
  - `.squad/decisions/inbox/plunder-rationale-ack-clear-decision.md` (new ADR)
  - (Path b only) `app/Sources/UVBurnTimer/AppViews.swift`
    (`clearSavedRoundedCoordinate`)
  - `app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift`

### WI-13: Inline "see About" deep-link inside L1 disclaimer body

- **Priority:** P3
- **Owner:** Iris (copy + layout decision) → Kwame (impl)
- **Reviewer:** Plunder
- **Type:** UI polish + spec/code alignment
- **Source of gap:** Spec §LANE 1 Screen 2:
  > `"How accurate is this for you?" + inline *see About* + photosensitizer line + "I understand"`
  Current `DisclaimerCover` (AppViews line 924–984) renders the body
  copy as a single `Text(ProductCopy.disclaimerBody)` and then places
  a **separate** `Button { showAbout = true }` labelled
  `"See About: when estimates may not apply"` below the body. The deep
  link is functional but is visually a button, not an inline link in
  the disclaimer sentence. Asha's reach-back works regardless (she
  taps either the button now or, with the change, an in-prose link),
  so this is polish, not safety.
- **Acceptance criteria:**
  - Either: (a) inline the deep-link by re-rendering
    `disclaimerBody` with a Markdown attributed string (SwiftUI
    `Text(AttributedString(...))` with the URL/internal route on the
    "see About" span), so the body reads as continuous prose with
    `see About` as an inline link, OR (b) update the spec snapshot
    (`user-flow-onboarding-main-spec.md`) and the persona overlay
    (`suchi-persona-annotations.md` Screen 1, Asha row) to acknowledge
    that the link is presented as a bordered button below the body
    and that this still satisfies the visibility-not-attestation
    architecture.
  - Whichever path: the photosensitizer line ("Photosensitizing
    medications, conditions, recent skin treatments, and pregnancy
    can make this estimate overstate your burn window.") stays
    visually distinct and above the I-understand action.
- **Test plan (TDD):** If path (a), extend
  `testScenario1ColdLaunchShowsRequiredDisclaimerThenScenario2RequiresSkinTypeSelection`
  (UVBurnTimerUITests line 9) to find the inline link by
  predicate-matching link text. If path (b), add no test; commit the
  spec/copy changes only.
- **Estimated touched files:**
  - `app/Sources/UVBurnTimer/AppViews.swift` (DisclaimerCover) OR
  - `.squad/files/user-flow-onboarding-main-spec.md` and
    `.squad/files/suchi-persona-annotations.md`

### WI-14: Spec text correction — SPF picker location on LANE 1 Screen 4

- **Priority:** P3
- **Owner:** Iris
- **Reviewer:** Gaia
- **Type:** docs (spec ↔ implementation alignment)
- **Source of gap:** Spec table line 44:
  > "**4 | Location Permission** | … | Grant 'When in Use'; **SPF
  > picker also shown** | Privacy rationale BEFORE iOS prompt; CTA in
  > `.safeAreaInset(.bottom)`"
  The current canonical IA — ratified in
  `gaia-onboarding-settings-main-scope.md` (top of `.squad/decisions.md`)
  — places SPF on the main-screen compact chip row (AppViews line
  232–248), **not** on the location-permission onboarding step. The
  picker is reachable in Settings (`SettingsSheet.Section("SPF")`
  line 1055) and on the main screen, but never on the location step.
  The spec text is therefore stale.
- **Acceptance criteria:**
  - `user-flow-onboarding-main-spec.md` line 44 either drops "SPF
    picker also shown" or rephrases it as "SPF picker is on the main
    screen (Location + SPF row) and in Settings — not on this
    onboarding step."
  - `user-flow-onboarding-main.excalidraw` (and any
    `.kwame-fix`/`.bak` variant) updated to match, normalized via
    `.squad/files/excalidraw-normalize.py` before commit (per
    `D-2026-05-19-016` skill section). Element count delta noted in
    the export history block at the end of the spec.
  - A new short decision drop confirming the spec change so the
    canvas-vs-code argument is closed.
- **Test plan (TDD):** N/A (docs-only). Optional: extend
  `testScenarios3And6And7LocationRationaleDeniedStateAndSPFChoices`
  to assert that the SPF chip is **not** visible during the
  rationale-card step (it isn't visible until the user is in the main
  screen after the rationale acknowledgement).
- **Estimated touched files:**
  - `.squad/files/user-flow-onboarding-main-spec.md`
  - `user-flow-onboarding-main.excalidraw`
  - `.squad/decisions/inbox/iris-spec-spf-location-correction.md` (new)

### WI-15: Increased-contrast / outdoor-readability automated contrast assertion

- **Priority:** P3
- **Owner:** Ma-Ti
- **Reviewer:** Iris
- **Type:** test (covers a previously-implicit Iris acceptance bullet)
- **Source of gap:** WI-5 (merged via !18) ratified the photosens
  banner styling as "yellow banner with chevron". Iris's earlier copy
  expected the banner to pass `≥4.5:1` text contrast and `≥7:1` in
  Increase-Contrast mode. The current implementation uses
  `Color.yellow.opacity(0.18/0.35)` fill with `Color.orange.opacity(0.55/0.85)`
  border and `.foregroundStyle(.primary)` text (AppViews line 168–190).
  The ratios are not computed in code; no test asserts them. Tier
  colors (`SeverityLong/Moderate/Short`) have HC variants in
  `Assets.xcassets`, but the gauge ring (`Color.secondary.opacity(0.22)`,
  line 1553) and SafetyStatusCard (`Color.orange.opacity(0.14/0.28)`,
  line 829) are not measured.
- **Acceptance criteria:**
  - One automated test (preferred: an XCTest in
    `BurnTimeCalculatorTests.swift` that asserts on the
    `Assets.xcassets/Severity*.colorset/Contents.json` luminance
    values — JSON is already parseable, no need for a rendering
    pipeline) verifies that all three Severity color tokens have
    `appearance: contrast / value: high` variants AND that the
    sRGB-luminance contrast vs. `.label` (system foreground) clears
    `≥4.5:1` in default and `≥7:1` in Increase-Contrast.
  - Alternatively, if Iris would rather keep this as a manual
    accessibility QA pass: produce a one-page
    `.squad/files/iris-contrast-qa-checklist.md` enumerating the
    surfaces (banner, gauge ring track, gauge progress arc per tier,
    SafetyStatusCard, hero number, footer link) with ratio targets
    and pin the responsibility on the launch-readiness review.
- **Test plan (TDD):** Add
  `severityColorTokensMeetIrisContrastFloors` (or the docs variant).
  Either path is acceptable; pick one and stop. Avoid adding both —
  duplicate ownership tends to drift.
- **Estimated touched files:**
  - `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift` OR
  - `.squad/files/iris-contrast-qa-checklist.md`

### WI-16: Polarized-OLED outdoor-readability launch-readiness checklist

- **Priority:** P3
- **Owner:** Iris (define) → launch-readiness reviewer (execute)
- **Reviewer:** Argos
- **Type:** docs (process gap, not a code gap)
- **Source of gap:** Spec §LANE 3 callout #8:
  > "📌 **Accessibility conformance gate** (AX5, VoiceOver, Reduce
  > Motion, Increase Contrast, **polarized OLED test**) — no arrow
  > (cross-cutting)."
  Every other sub-gate has automation. The polarized-OLED test is
  cross-cutting outdoor readability and cannot reasonably be
  automated on simulator — but there is no captured manual
  procedure either. At launch we will not know whether the gate has
  been satisfied.
- **Acceptance criteria:**
  - A short
    `.squad/files/iris-launch-readiness-checklist.md` enumerating:
    (a) device + polarized-sunglass test setup, (b) screens to
    visit (NowView fresh / stale / capped / weather-unavailable / About,
    + SettingsSheet), (c) glare-readability acceptance rule
    ("the hero number, tier badge, footer link, and photosens banner
    must each be legible at 30° polarization tilt"), (d) sign-off
    line where the reviewer initials.
  - The checklist is referenced from `loop.md` Section "Code tested
    and validated" so each future loop knows to execute it before
    declaring launch-ready.
- **Test plan (TDD):** N/A.
- **Estimated touched files:**
  - `.squad/files/iris-launch-readiness-checklist.md` (new)
  - `loop.md` (one-line pointer)

### WI-17: Scribe — fold pending inbox decisions into the ledger

- **Priority:** P3
- **Owner:** Scribe
- **Reviewer:** Gaia
- **Type:** docs (process)
- **Source of gap:** `.squad/decisions/inbox/` currently contains
  `loop-closure-20260520T043000Z.md` and `gaia-model-default-loop.md`
  that have not been folded into `.squad/decisions.md`. The
  loop-closure file is the authoritative loop-end record;
  `gaia-model-default-loop.md` is marked "Proposed" and either needs
  ratification or removal.
- **Acceptance criteria:**
  - Both inbox files appear as appended sections of
    `.squad/decisions.md` (with the existing
    `<!-- Source: .squad/decisions/inbox/... -->` pattern).
  - The "Proposed" status on `gaia-model-default-loop.md` is either
    flipped to "Ratified" (with reviewer sign-off) or the file is
    closed out as "Rejected — see X".
- **Test plan (TDD):** N/A.
- **Estimated touched files:**
  - `.squad/decisions.md`
  - `.squad/decisions/inbox/{loop-closure-20260520T043000Z,gaia-model-default-loop}.md`
    (will be removed when merged, per existing inbox convention)

---

## 4. Items already in flight

**None.** Local branches that diverge from `main` are stale (e.g.
`squad/4-approved-redesign-paraphrasing` 16 commits ahead but inactive;
`squad/add-run-script` 47 ahead, unused; `squad/fix-app-icon-catalog`
3 ahead, superseded). The post-merge feature branches
(`squad/honest-privacy-copy`, `squad/main-compact-inputs-row`,
`squad/docs-align-display-cap-spec`, `squad/photosens-banner-style`,
`squad/spec-hero-title-align`, `squad/storekit-guard`,
`squad/attribution-audit`, `squad/location-rationale-adr`,
`squad/main-disclaimer-link-copy`, `squad/fix-location-gauge-ui`) all
report 0 commits ahead of `main` — they are fully merged.

No work-in-progress MRs are open. The next loop starts cleanly.

---

## 5. Open questions / blockers

- **No launch blockers.**
- **One open question (WI-12):** Plunder's sign-off on whether
  `Clear saved location` should also clear the rationale-ack. The
  ADR explicitly delegated this to Plunder; closing it is a
  small ADR addendum + a one-line behavior decision.
- **Reviewer rotation discipline:** WI-11 must be reviewed by Iris,
  not Kwame, because the gap is partly a copy/IA call (which empty
  state copy is correct) — not just a code fix. WI-12 must be
  reviewed by Gaia (architect) after Plunder ratifies, to preserve
  the ADR-first workflow. WI-13/14/15/16 all have natural reviewers
  who are independent of the author (Iris → Plunder, Iris → Gaia,
  Ma-Ti → Iris, Iris → Argos).
- **One observation:** the loop is unusually small. Of the 7 new
  WIs, only WI-11 touches Swift source. The remainder are docs,
  process, or single-line behavior choices. This is consistent with
  a healthy maintenance loop following a feature-heavy one — the
  honest reading is that the canvas-implementation parity is now
  high enough that future loops should rotate toward v1.1 scope
  (WI-9 plan-for-elsewhere) and toward strengthening process
  artifacts (WI-15/16 contrast & polarized-OLED gates) before the
  next feature wave.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
