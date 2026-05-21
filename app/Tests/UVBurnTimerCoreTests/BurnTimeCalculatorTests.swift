import Foundation
import Testing

@testable import UVBurnTimerCore

@Test func unprotectedReferenceAtUVTenIsShortWindow() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeI,
        spf: .unprotectedReference,
        uvIndex: 10
    )

    #expect(estimate.roundedDisplayMinutes == 13)
    #expect(estimate.tier == .short)
    #expect(estimate.displayText == "~13 min")
}

@Test func typeThreeWithSPFThirtyAtUVEightCapsSunscreenWindowButKeepsRawModel() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .spf30,
        uvIndex: 8
    )

    #expect(estimate.rawMinutes == 750)
    #expect(estimate.tier == .long)
    #expect(estimate.isSunscreenProtected)
    #expect(estimate.isCappedForSunscreenReapplication)
    #expect(estimate.isCappedForDisplay)
    #expect(estimate.effectiveWindowMinutes == 120)
    #expect(estimate.roundedDisplayMinutes == 120)
    #expect(estimate.displayText == "Up to 2 hr")
    #expect(estimate.accessibilitySummary.localizedCaseInsensitiveContains("up to 2 hours"))
    #expect(estimate.accessibilitySummary.localizedCaseInsensitiveContains("reapply sunscreen at least every 2 hours"))
}

@Test func sunscreenEstimateUnderTwoHoursIsNotCapped() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeI,
        spf: .spf15,
        uvIndex: 20
    )

    #expect(estimate.rawMinutes == 100)
    #expect(estimate.isSunscreenProtected)
    #expect(!estimate.isCappedForSunscreenReapplication)
    #expect(estimate.effectiveWindowMinutes == 100)
    #expect(estimate.displayText == "~1 hr 40 min")
    #expect(estimate.accessibilitySummary == "Estimated burn time: 1 hour 40 minutes.")
}

@Test func exactOneHourEstimateDoesNotShowRawSixtyMinutes() {
    let estimate = BurnTimeEstimate(rawMinutes: 60, tier: .long, isSunscreenProtected: false)

    #expect(estimate.roundedDisplayMinutes == 60)
    #expect(estimate.displayText == "~1 hr")
    #expect(estimate.accessibilitySummary == "Estimated burn time: 1 hour.")
}

@Test func unprotectedReferenceEstimateOverTwoHoursKeepsUnprotectedWindow() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeVI,
        spf: .unprotectedReference,
        uvIndex: 4
    )

    #expect(estimate.rawMinutes > 120)
    #expect(!estimate.isSunscreenProtected)
    #expect(!estimate.isCappedForSunscreenReapplication)
    #expect(estimate.effectiveWindowMinutes == estimate.rawMinutes)
    #expect(estimate.displayText == "~2 hr 47 min")
    #expect(estimate.accessibilitySummary == "Estimated burn time: 2 hours 47 minutes.")
}

@Test func zeroUVProducesNoUVState() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeVI,
        spf: .spf70Plus,
        uvIndex: 0
    )

    #expect(estimate.rawMinutes == .infinity)
    #expect(estimate.tier == .none)
    #expect(estimate.displayText == "No UV")
    #expect(estimate.roundedDisplayMinutes == nil)
    #expect(estimate.accessibilitySummary.contains("No erythemal irradiance"))
}

@Test func moderateBurnWindowHasExpectedDisplayAndAccessibilitySummary() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .unprotectedReference,
        uvIndex: 6
    )

    #expect(estimate.roundedDisplayMinutes == 33)
    #expect(estimate.tier == .moderate)
    #expect(estimate.displayText == "~33 min")
    #expect(estimate.accessibilitySummary == "Estimated burn time: 33 minutes.")
}

@Test func negativeUVIsRejected() {
    #expect(throws: BurnTimeCalculatorError.negativeUVIndex) {
        try BurnTimeCalculator.estimate(
            skinType: .typeIII,
            spf: .spf30,
            uvIndex: -1
        )
    }
}

@Test func burnTimeTierBoundariesAreInclusiveAtApprovedThresholds() throws {
    #expect(BurnTimeCalculator.tier(for: 19.99) == .short)
    #expect(BurnTimeCalculator.tier(for: 20) == .moderate)
    #expect(BurnTimeCalculator.tier(for: 59.99) == .moderate)
    #expect(BurnTimeCalculator.tier(for: 60) == .long)
}

@Test func fractionalUVValuesRoundDisplayWithoutChangingTier() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .unprotectedReference,
        uvIndex: 6.2
    )

    #expect(estimate.rawMinutes > 32)
    #expect(estimate.rawMinutes < 33)
    #expect(estimate.roundedDisplayMinutes == 32)
    #expect(estimate.displayText == "~32 min")
    #expect(estimate.tier == .moderate)
}

@Test func coldLaunchHasNoDefaultSkinTypeAndReattestsWhenEstimateWindowElapsed() {
    let session = UVBurnTimerSession()

    #expect(session.selectedSkinType == nil)
    #expect(session.selectedSPF == .spf30)
    #expect(session.acknowledgedDisclaimer == false)
    #expect(
        !DisclaimerReattestationPolicy.shouldPresentOnForeground(
            returnedFromBackground: true,
            acknowledgedDisclaimer: false,
            estimateWindowElapsed: true
        ))
    #expect(
        DisclaimerReattestationPolicy.shouldPresentOnForeground(
            returnedFromBackground: true,
            acknowledgedDisclaimer: true,
            estimateWindowElapsed: true
        ))
    #expect(
        !DisclaimerReattestationPolicy.shouldPresentOnForeground(
            returnedFromBackground: false,
            acknowledgedDisclaimer: true,
            estimateWindowElapsed: true
        ))
    #expect(
        !DisclaimerReattestationPolicy.shouldPresentOnForeground(
            returnedFromBackground: true,
            acknowledgedDisclaimer: true,
            estimateWindowElapsed: false
        ))
}

@Test func foregroundReattestationSurvivesInactiveHopAfterBackground() {
    var tracker = ForegroundReattestationTracker()

    tracker.recordBackgroundEntry()
    let shouldPresent = tracker.shouldPresentOnForeground(
        acknowledgedDisclaimer: true,
        estimateWindowElapsed: true
    )

    #expect(shouldPresent)
}

@Test func requiringDisclaimerReattestationClearsAcknowledgement() {
    var session = UVBurnTimerSession(
        selectedSkinType: .typeIII,
        selectedSPF: .spf30,
        acknowledgedDisclaimer: true
    )

    session.requireDisclaimerReattestation()

    #expect(session.selectedSkinType == .typeIII)
    #expect(session.selectedSPF == .spf30)
    #expect(!session.acknowledgedDisclaimer)
}

@Test func foregroundReturnAfterElapsedEstimateRequiresDisclaimerReattestation() throws {
    var session = UVBurnTimerSession(
        selectedSkinType: .typeII,
        selectedSPF: .spf30,
        acknowledgedDisclaimer: true
    )
    var tracker = ForegroundReattestationTracker()
    let fetchedAt = Date(timeIntervalSince1970: 1_000)
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeII,
        spf: .spf15,
        uvIndex: 200
    )

    tracker.recordBackgroundEntry()
    if tracker.shouldPresentOnForeground(
        acknowledgedDisclaimer: session.acknowledgedDisclaimer,
        estimateWindowElapsed: estimate.isElapsed(
            fetchedAt: fetchedAt,
            now: fetchedAt.addingTimeInterval((estimate.rawMinutes * 60) + 1)
        )
    ) {
        session.requireDisclaimerReattestation()
    }

    #expect(session.selectedSkinType == .typeII)
    #expect(session.selectedSPF == .spf30)
    #expect(!session.acknowledgedDisclaimer)
}

@Test func skinTypeOnboardingRequiresSelectionBeforeCommit() {
    var draft = SkinTypeOnboardingDraft()
    var session = UVBurnTimerSession()

    #expect(draft.pendingSkinType == nil)
    #expect(!draft.canContinue)
    #expect(!draft.commit(to: &session))
    #expect(session.selectedSkinType == nil)

    draft.select(.typeV)

    #expect(draft.pendingSkinType == .typeV)
    #expect(draft.canContinue)
    #expect(draft.commit(to: &session))
    #expect(session.selectedSkinType == .typeV)
}

@Test func foregroundReattestationResetsAfterForegroundDecision() {
    var tracker = ForegroundReattestationTracker()

    tracker.recordBackgroundEntry()
    let firstForegroundDecision = tracker.shouldPresentOnForeground(
        acknowledgedDisclaimer: true,
        estimateWindowElapsed: false
    )
    let secondForegroundDecision = tracker.shouldPresentOnForeground(
        acknowledgedDisclaimer: true,
        estimateWindowElapsed: true
    )

    #expect(!firstForegroundDecision)
    #expect(!secondForegroundDecision)
}

@Test func fitzpatrickPickerCopyStartsWithBurnTanBehavior() {
    let approvedCopy: [FitzpatrickSkinType: String] = [
        .typeI: "Always burns, never tans. Very fair; often freckles, red/blonde hair.",
        .typeII: "Burns easily, tans minimally. Fair skin; light eyes common.",
        .typeIII: "Burns moderately, tans gradually. Medium skin tone.",
        .typeIV: "Burns minimally, tans easily. Olive or medium-brown skin.",
        .typeV: "Rarely burns, tans deeply. Brown skin.",
        .typeVI: "Almost never burns, deeply pigmented. Dark brown to black skin.",
    ]
    let behaviorFirstPrefixes: [FitzpatrickSkinType: String] = [
        .typeI: "Always burns, never tans.",
        .typeII: "Burns easily, tans minimally.",
        .typeIII: "Burns moderately, tans gradually.",
        .typeIV: "Burns minimally, tans easily.",
        .typeV: "Rarely burns, tans deeply.",
        .typeVI: "Almost never burns, deeply pigmented.",
    ]

    for skinType in FitzpatrickSkinType.allCases {
        let description = skinType.pickerDescription

        #expect(description == approvedCopy[skinType])
        #expect(description.hasPrefix(behaviorFirstPrefixes[skinType] ?? ""))
    }
}

@Test func fitzpatrickMEDConstantsRemainCanonical() {
    let expectedMED: [FitzpatrickSkinType: Double] = [
        .typeI: 200,
        .typeII: 250,
        .typeIII: 300,
        .typeIV: 450,
        .typeV: 600,
        .typeVI: 1_000,
    ]

    for skinType in FitzpatrickSkinType.allCases {
        #expect(skinType.minimalErythemalDoseJoules == expectedMED[skinType])
    }
}

@Test func spfContextLabelsAreHumanReadable() {
    #expect(SPFLevel.unprotectedReference.contextLabel == "unprotected reference")
    #expect(SPFLevel.spf15.contextLabel == "15")
    #expect(SPFLevel.spf30.contextLabel == "30")
    #expect(SPFLevel.spf50.contextLabel == "50")
    #expect(SPFLevel.spf70Plus.contextLabel == "70+")
}

@Test func spfUserFacingCasesAreOnlySunscreenProducts() {
    #expect(SPFLevel.allCases == [.spf15, .spf30, .spf50, .spf70Plus])
    #expect(!SPFLevel.allCases.contains(.unprotectedReference))
    #expect(SPFLevel.allCases.map(\.isSunscreen) == [true, true, true, true])
    #expect(UVBurnTimerSession().selectedSPF == .spf30)
}

@Test func spfRawValuesMatchMultiplierContract() throws {
    #expect(SPFLevel.unprotectedReference.rawValue == 1)
    #expect(SPFLevel.spf15.rawValue == 15)
    #expect(SPFLevel.spf30.rawValue == 30)
    #expect(SPFLevel.spf50.rawValue == 50)
    #expect(SPFLevel.spf70Plus.rawValue == 70)
    #expect(SPFLevel.spf70Plus.modelMultiplier == 50)

    let unprotected = try BurnTimeCalculator.estimate(
        skinType: .typeII,
        spf: .unprotectedReference,
        uvIndex: 7
    )

    let expectedUnprotectedMinutes = 250.0 / (7.0 * 0.025) / 60.0
    #expect(unprotected.rawMinutes == expectedUnprotectedMinutes)
}

@Test func spfSeventyPlusUsesConservativeModelMultiplier() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeII,
        spf: .spf70Plus,
        uvIndex: 10
    )
    let unprotectedMinutes = 250.0 / (10.0 * 0.025) / 60.0

    #expect(estimate.rawMinutes == unprotectedMinutes * 50)
    #expect(estimate.displayText == "Up to 2 hr")
}

@Test func longUnprotectedEstimateAtFourHoursShowsApprovedDisplayCap() {
    let estimate = BurnTimeEstimate(rawMinutes: 240, tier: .long, isSunscreenProtected: false)

    #expect(estimate.rawMinutes == 240)
    #expect(estimate.isCappedForDisplay)
    #expect(estimate.effectiveWindowMinutes == 240)
    #expect(estimate.roundedDisplayMinutes == 240)
    #expect(estimate.displayText == "4+ hr")
    #expect(estimate.accessibilitySummary == "Estimated burn time: 4 or more hours.")
}

@Test func approvedMainScreenSafetyCopyIsCaptured() {
    #expect(ProductCopy.photosensitizerDisclaimerLine.contains("Photosensitizing"))
    #expect(ProductCopy.photosensitizationAuthorityLine.localizedCaseInsensitiveContains("informational"))
    #expect(ProductCopy.photosensitizationAuthorityLine.localizedCaseInsensitiveContains("NIH MedlinePlus"))
    #expect(ProductCopy.photosensitizationBannerLabel.localizedCaseInsensitiveContains("meds"))
    #expect(ProductCopy.photosensitizationBannerLabel.localizedCaseInsensitiveContains("conditions"))
    #expect(
        ProductCopy.locationPrivacyLine.contains("2 decimals"))
    #expect(ProductCopy.locationPrivacyLine.localizedCaseInsensitiveContains("approximate location"))
    #expect(ProductCopy.locationPrivacyLine.localizedCaseInsensitiveContains("last rounded coordinate"))
    #expect(ProductCopy.cacheRetentionLine.localizedCaseInsensitiveContains("last rounded coordinate"))
    #expect(ProductCopy.cacheRetentionLine.localizedCaseInsensitiveContains("does not save UV values"))
    #expect(ProductCopy.cacheRetentionLine.localizedCaseInsensitiveContains("skin type"))
    #expect(ProductCopy.cacheRetentionLine.localizedCaseInsensitiveContains("SPF"))
    #expect(ProductCopy.clearSavedLocationButtonTitle == "Clear saved location")
    #expect(!ProductCopy.locationPrivacyLine.localizedCaseInsensitiveContains("never saved"))
    #expect(ProductCopy.childrenDisclaimerLine == "For children, consult a pediatrician.")
    #expect(ProductCopy.locationDeniedEmptyState.contains("tap Use my location again"))
    #expect(
        ProductCopy.locationUnavailableMessage.localizedCaseInsensitiveContains("could not determine your location"))
    #expect(ProductCopy.locationRequestInProgressMessage.localizedCaseInsensitiveContains("already checking"))
    #expect(ProductCopy.weatherUnavailableTitle == "Weather unavailable")
    #expect(ProductCopy.weatherUnavailableMessage.localizedCaseInsensitiveContains("Apple Weather"))
    #expect(ProductCopy.weatherUnavailableMessage.localizedCaseInsensitiveContains("try again"))
    #expect(ProductCopy.estimateElapsedWarning.contains("Recalculate"))
    #expect(ProductCopy.reapplicationFooter.contains("Reapply sunscreen at least every 2 hours"))
    #expect(ProductCopy.sunscreenCapHedge.localizedCaseInsensitiveContains("capped at 2 hours"))
    #expect(ProductCopy.reapplicationFooter.localizedCaseInsensitiveContains("cover up"))
    #expect(ProductCopy.reapplicationFooter.localizedCaseInsensitiveContains("skin reddens"))
    #expect(ProductCopy.mainVerdictCaveatLinkLabel == "Meds + conditions can shorten this. Learn more")
    #expect(ProductCopy.mainVerdictCaveatLinkLabel.localizedCaseInsensitiveContains("can shorten"))
    #expect(ProductCopy.longEstimateHedge.localizedCaseInsensitiveContains("does not mean"))
    #expect(ProductCopy.longEstimateHedge.localizedCaseInsensitiveContains("safe"))
    #expect(ProductCopy.skinTypePickerPrompt == "Choose by how your skin burns and tans, not by how it looks.")
    #expect(ProductCopy.uvSourceLine == "Source: Apple Weather")
    #expect(ProductCopy.disclaimerLinkLabel == "Informational only. Not medical advice.")
    #expect(ProductCopy.fitzpatrickCitations.contains("NCBI Bookshelf NBK481857"))
    #expect(ProductCopy.fitzpatrickCitations.localizedCaseInsensitiveContains("WHO Global Solar UV Index"))
    #expect(ProductCopy.fitzpatrickCitations.localizedCaseInsensitiveContains("Schalka"))
}

@Test func heroEmptyStatePromptForSelectedSkinTypeAsksForLocation() {
    // WI-11 (P1): after the user has committed a skin type in onboarding,
    // the hero empty state must stop asking them to do something they have
    // already done and prompt them for the *next* action (location).
    let prompt = ProductCopy.heroEmptyStatePrompt(hasSkinType: true)

    #expect(prompt.localizedCaseInsensitiveContains("use my location"))
    #expect(!prompt.localizedCaseInsensitiveContains("pick a skin type"))
}

@Test func heroEmptyStatePromptWithoutSkinTypePromptsForSkinType() {
    // WI-11: until a skin type is set (e.g. Settings → Edit skin type →
    // cancel without selecting), the empty state should still ask for one.
    let prompt = ProductCopy.heroEmptyStatePrompt(hasSkinType: false)

    #expect(prompt.localizedCaseInsensitiveContains("pick a skin type"))
    #expect(!prompt.localizedCaseInsensitiveContains("use my location"))
}

@Test func heroEmptyStateConstantsArePartOfAuditCopySurfaces() {
    // Both empty-state strings must be auditable so the monetization-drift
    // and banned-clinical-claim guards apply to them too.
    #expect(ProductCopy.auditCopySurfaces.contains(ProductCopy.emptyStateAwaitingSkinType))
    #expect(ProductCopy.auditCopySurfaces.contains(ProductCopy.emptyStateAwaitingLocation))
}

@Test func productCopyAvoidsMonetizationDriftLanguage() {
    let bannedPhrases = [
        "premium",
        "unlock",
        "paywall",
        "upgrade",
        "pro tier",
    ]

    for copy in ProductCopy.auditCopySurfaces {
        for phrase in bannedPhrases {
            #expect(!copy.localizedCaseInsensitiveContains(phrase))
        }
    }
}

@Test func requiredSafetyDisclaimerCopyIsCaptured() {
    let copy = ProductCopy.disclaimerTitle + " " + ProductCopy.disclaimerBody

    #expect(ProductCopy.disclaimerTitle == "How accurate is this for you?")
    #expect(copy.localizedCaseInsensitiveContains("not medical advice"))
    #expect(copy.localizedCaseInsensitiveContains("professional medical advice, diagnosis, or treatment"))
    #expect(copy.localizedCaseInsensitiveContains("model calculation, not a measurement"))
    #expect(copy.localizedCaseInsensitiveContains("healthy adult skin"))
    #expect(copy.localizedCaseInsensitiveContains("consistent conditions"))
    #expect(copy.localizedCaseInsensitiveContains("labeled SPF"))
    #expect(copy.localizedCaseInsensitiveContains("correct sunscreen amount and reapplication"))
    #expect(copy.localizedCaseInsensitiveContains("dermatologist"))
    #expect(copy.localizedCaseInsensitiveContains("cover up"))
    #expect(copy.localizedCaseInsensitiveContains("reapply"))
    #expect(copy.localizedCaseInsensitiveContains("shade"))
}

/// AUDIT-ONLY — validates ProductCopy constants that are NOT rendered at runtime.
/// `DisclaimerCover` ships the see-About reach-back as a styled Button (WI-13,
/// merged 90ecf26); the Markdown + OpenURLAction path was retired due to iOS
/// 17/18 a11y instability. `disclaimerSeeAboutLinkURL` and
/// `disclaimerSeeAboutInlineMarkdown` are retained in ProductCopy for spec/audit
/// fidelity only; this test ensures they remain consistent with each other and
/// with the plain-text `disclaimerSeeAboutInlinePrompt` that IS rendered.
/// See spec.md §LANE 1 Screen 2 implementation note for full rationale.
///
/// Spec §LANE 1 Screen 2 and `suchi-persona-annotations.md` (Screen 1 — Asha):
/// the L1 disclaimer must surface "see About" as an **inline** deep-link
/// inside a short sentence about photosensitizing medications and
/// conditions, NOT as a separate bordered button below the body. Asha
/// (P4, Accutane) reads "If you take a photosensitizing medication or
/// have a sun-sensitive condition — see About", taps the inline link,
/// reads the cohort list in About at the `notForMe` anchor, returns to
/// the still-present cover, and taps `I understand`.
///
/// This test pins:
///   1. The plain-text variant exposes both the cohort framing and the
///      `see About` reach-back text so screen-readers and copy audits
///      see continuous prose.
///   2. The Markdown variant embeds `see About` as a `[see About](...)`
///      Markdown link that SwiftUI's `Text(LocalizedStringKey:)` would
///      render as a tappable inline link (AUDIT-ONLY; not currently rendered).
///   3. The link target uses the in-app `uvburntimer://about-applicability`
///      route documenting the deep-link contract.
///   4. The inline prompt is part of the audited copy surfaces so any
///      future copy drift is caught by `productCopyAvoidsBannedClinicalClaims`
///      and the monetization-drift guard.
@Test func disclaimerSurfacesInlineSeeAboutDeepLinkForPhotosensitiveCohort() {
    let prompt = ProductCopy.disclaimerSeeAboutInlinePrompt
    let markdown = ProductCopy.disclaimerSeeAboutInlineMarkdown

    #expect(prompt.localizedCaseInsensitiveContains("photosensitizing medication"))
    #expect(prompt.localizedCaseInsensitiveContains("sun-sensitive condition"))
    #expect(prompt.localizedCaseInsensitiveContains("see About"))
    #expect(!prompt.contains("["))
    #expect(!prompt.contains("]("))

    #expect(markdown.contains("[see About]("))
    #expect(markdown.contains(ProductCopy.disclaimerSeeAboutLinkURL.absoluteString))
    #expect(ProductCopy.disclaimerSeeAboutLinkURL.scheme == "uvburntimer")
    #expect(ProductCopy.disclaimerSeeAboutLinkURL.host == "about-applicability")

    #expect(ProductCopy.auditCopySurfaces.contains(prompt))

    let composed =
        ProductCopy.disclaimerSeeAboutInlineLead
        + ProductCopy.disclaimerSeeAboutInlineLinkLabel
        + ProductCopy.disclaimerSeeAboutInlineTail
    #expect(composed == prompt)
    #expect(ProductCopy.disclaimerSeeAboutInlineLinkLabel == "see About")
}

// MARK: - WI-w: L1 storage-disclosure sentence (Plunder ratified 2026-05-21)
//
// Spec source of truth:
//   .squad/orchestration-log/2026-05-21T-plunder-wi-w-l1-storage.md
//
// The L1 cover must carry an explicit, GDPR Art.9(2)(a)-grade sentence
// naming what is stored (skin type, SPF), where (device only), why (so the
// app can remember them between launches), and how to remove it (Settings).
// Plunder requires this as a SEPARATE constant from `disclaimerBody` so the
// FDA-pre-approved substring guard (`requiredSafetyDisclaimerCopyIsCaptured`)
// keeps its audit lane clean.

@Test func disclaimerStorageLineMatchesPlunderRatifiedWordingExactly() {
    // Plunder §3.1 — case-sensitive identity. ANY edit to this string must
    // re-open the Plunder gate. The exact phrasing is GDPR-load-bearing
    // (purpose specificity for special-category-adjacent consent).
    #expect(
        ProductCopy.disclaimerStorageLine
            == "Your skin type and SPF are saved on this device only so the app can remember them between launches; the app never sends them off-device. You can clear them anytime in Settings."
    )
}

@Test func disclaimerStorageLineSurfacesAllSevenPlunderRequiredSubstrings() {
    // Plunder §3.2 — derived substring pins so future copy refactors that
    // accidentally drop a load-bearing phrase still fail loudly even before
    // a reviewer notices the exact-match drift.
    let line = ProductCopy.disclaimerStorageLine

    #expect(line.localizedCaseInsensitiveContains("skin type"))   // persisted data #1
    #expect(line.localizedCaseInsensitiveContains("spf"))         // persisted data #2
    #expect(line.localizedCaseInsensitiveContains("this device only"))  // scope (Art.5(1)(f))
    #expect(line.localizedCaseInsensitiveContains("remember"))    // purpose (Art.9(2)(a))
    #expect(line.localizedCaseInsensitiveContains("off-device"))  // never-transmitted complement
    #expect(line.localizedCaseInsensitiveContains("settings"))    // erasure path (Art.17)
    #expect(line.localizedCaseInsensitiveContains("clear"))       // matches K-8 button verb
}

@Test func disclaimerStorageLineIsRegisteredInAuditCopySurfaces() {
    // Plunder §3.3 — the banned-clinical-claim guard, monetization-drift
    // guard, and any future audit guards (e.g., PII-leak) apply to every
    // entry in `auditCopySurfaces`. Membership is the contract.
    #expect(ProductCopy.auditCopySurfaces.contains(ProductCopy.disclaimerStorageLine))
}

@Test func disclaimerStorageLineIsLaneSeparatedFromDisclaimerBody() {
    // Plunder §3.5 — the FDA-pre-approved `disclaimerBody` MUST NOT absorb
    // the GDPR storage-disclosure prose; mixing the lanes would break
    // `requiredSafetyDisclaimerCopyIsCaptured` and muddy the audit boundary
    // for future targeted edits to either lane.
    #expect(!ProductCopy.disclaimerBody.contains(ProductCopy.disclaimerStorageLine))
    #expect(!ProductCopy.disclaimerStorageLine.localizedCaseInsensitiveContains("medical advice"))
}

@Test func skinTypeCaveatIsConsistentAcrossEntryPoints() {
    for copy in [ProductCopy.skinTypePickerFooter, ProductCopy.skinTypeSettingsFooter] {
        #expect(copy.localizedCaseInsensitiveContains("self-assessment"))
        #expect(
            copy.localizedCaseInsensitiveContains(
                "consult a dermatologist before using this estimate to plan sun exposure"))
        #expect(copy.localizedCaseInsensitiveContains("Learn more"))
        #expect(copy.localizedCaseInsensitiveContains("result screen"))
        #expect(copy.localizedCaseInsensitiveContains("healthy skin"))
        #expect(copy.localizedCaseInsensitiveContains("photosensitizing medications"))
    }
}

@Test func aboutCopyIncludesApplicabilityAndWeatherMentalModel() {
    let aboutCopy =
        ProductCopy.aboutEstimateApplicability
        + " " + ProductCopy.aboutWeatherVariability
        + " " + ProductCopy.aboutSunscreenAssumptions
        + " " + ProductCopy.aboutModelLimitations
        + " " + ProductCopy.whatTheAppDoesNotDo
        + " " + ProductCopy.pediatricAndEscalationGuidance

    #expect(aboutCopy.localizedCaseInsensitiveContains("certain medications"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("photosensitive conditions"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("retinoid acne treatments"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("tetracycline-class antibiotics"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("autoimmune-disease medications"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("diuretics"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("heart-rhythm medications"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("antifungals"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("lupus"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("vitiligo"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("albinism"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("porphyria"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("recent skin treatments"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("laser"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("chemical peel"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("microneedling"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("pregnant"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("water"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("sweat"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("toweling"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("correctly applied"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("cloud"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("UV"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("wider uncertainty"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("Fitzpatrick IV–VI"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("current UV remains constant"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("altitude"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("reflection"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("children"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("blistering"))
    #expect(aboutCopy.localizedCaseInsensitiveContains("fever"))
    #expect(ProductCopy.aboutHowThisWorks.localizedCaseInsensitiveContains("Fitzpatrick"))
    #expect(ProductCopy.aboutHowThisWorks.localizedCaseInsensitiveContains("SPF"))
    #expect(ProductCopy.aboutHowThisWorks.localizedCaseInsensitiveContains("70+"))
    #expect(ProductCopy.aboutHowThisWorks.localizedCaseInsensitiveContains("modeled as SPF 50"))
    #expect(ProductCopy.aboutHowThisWorks.localizedCaseInsensitiveContains("capped at 2 hours"))
    #expect(ProductCopy.aboutSunscreenAssumptions.localizedCaseInsensitiveContains("at least every 2 hours"))
    #expect(ProductCopy.whatTheAppDoesNotDo.localizedCaseInsensitiveContains("does not diagnose"))
    #expect(ProductCopy.whatTheAppDoesNotDo.localizedCaseInsensitiveContains("does not track"))
    #expect(ProductCopy.whatTheAppDoesNotDo.localizedCaseInsensitiveContains("does not send alerts"))
    #expect(ProductCopy.lastUpdatedLine == "Last updated: 2026-05-20.")
    #expect(ProductCopy.outdoorReadabilityTip.localizedCaseInsensitiveContains("Increase Contrast"))
}

@Test func photosensitizerCopyAvoidsBrandAndOverSpecificMedicationNames() {
    let aboutCopy = ProductCopy.aboutEstimateApplicability
    let excludedMedicationNames = [
        "Accutane",
        "Plaquenil",
        "doxycycline",
        "hydroxychloroquine",
        "isotretinoin",
    ]

    for medicationName in excludedMedicationNames {
        #expect(!aboutCopy.localizedCaseInsensitiveContains(medicationName))
    }
}

@Test func aboutPrivacyCopyDescribesRoundedCoordinatesToAppleWeather() {
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("rounded coordinates"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("approximate location"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("Apple Weather"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("skin type"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("SPF"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("persist"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("on this device"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("never transmitted off-device"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("last rounded coordinate"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("not retained between launches"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("no accounts"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("analytics"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("ads"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("crash SDKs"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("third-party tracking"))
}

@Test func attributionAndPricingCopyAreCanonical() {
    #expect(ProductCopy.weatherAttributionServiceName == "Apple Weather")
    #expect(
        ProductCopy.weatherAttributionLegalURL.absoluteString == "https://weatherkit.apple.com/legal-attribution.html")
    #expect(ProductCopy.weatherAttributionLegalURLString == "https://weatherkit.apple.com/legal-attribution.html")
    #expect(ProductCopy.weatherDataAttributionBody.localizedCaseInsensitiveContains("uses Apple Weather"))
    #expect(ProductCopy.weatherDataAttributionBody.localizedCaseInsensitiveContains("range of providers"))
    #expect(ProductCopy.medlinePlusSunSensitivityURL.host() == "medlineplus.gov")
    #expect(ProductCopy.pricingLine.localizedCaseInsensitiveContains("one-time paid app"))
    #expect(ProductCopy.pricingLine.localizedCaseInsensitiveContains("no subscription"))
    #expect(ProductCopy.pricingLine.localizedCaseInsensitiveContains("in-app purchases"))
    #expect(ProductCopy.pricingLine.localizedCaseInsensitiveContains("tip jar"))
    #expect(ProductCopy.pricingLine.localizedCaseInsensitiveContains("restore flow"))
}

@Test func citationLinksUseApprovedCanonicalSources() {
    let linksByTitle = Dictionary(
        uniqueKeysWithValues: ProductCopy.citationLinks.map { ($0.title, $0.url.absoluteString) })

    #expect(linksByTitle["Fitzpatrick TB 1988"] == "https://doi.org/10.1001/archderm.1988.01670060015008")
    #expect(linksByTitle["Ward & Farma NCBI Bookshelf NBK481857"] == "https://www.ncbi.nlm.nih.gov/books/NBK481857/")
    #expect(linksByTitle["WHO Global Solar UV Index practical guide"] == "https://iris.who.int/handle/10665/42459")
    #expect(
        linksByTitle["Schalka, dos Reis & Cucé sunscreen/SPF study"]
            == "https://doi.org/10.1111/j.1600-0781.2009.00408.x")
    #expect(linksByTitle["Diffey BL 1991"] == "https://doi.org/10.1088/0031-9155/36/3/001")
    #expect(
        linksByTitle["CIE erythemal reference action spectrum"]
            == "https://cie.co.at/publications/erythema-reference-action-spectrum-and-standard-erythema-dose")
}

@Test func citationCopyUsesAdaptedFramingAndRequiredSourceIdentifiers() {
    #expect(ProductCopy.fitzpatrickCitations.localizedCaseInsensitiveContains("adapted"))
    #expect(ProductCopy.fitzpatrickCitations.localizedCaseInsensitiveContains("paraphrased"))
    #expect(!ProductCopy.fitzpatrickCitations.localizedCaseInsensitiveContains("CC BY-NC-SA"))
    #expect(
        ProductCopy.fitzpatrickCitations.localizedCaseInsensitiveContains("https://iris.who.int/handle/10665/42459"))
}

@Test func productCopyAvoidsBannedClinicalClaims() {
    let copySurfaces = ProductCopy.auditCopySurfaces + FitzpatrickSkinType.allCases.map(\.pickerDescription)
    let bannedPhrases = [
        "skin cancer",
        "cancer prevention",
        "fda",
        "clinically proven",
        "guaranteed safe",
        "safe sun time",
        "prevents",
        "burn-free",
        "medical-grade",
        "dermatologist-approved",
        "doctor-recommended",
        "safe to stay out for",
        "burn protection",
        "you will not burn",
        "protects you from",
        "skin cancer prevention",
    ]

    for copy in copySurfaces {
        for phrase in bannedPhrases {
            #expect(!copy.localizedCaseInsensitiveContains(phrase))
        }
    }
}

@Test func appSourcesAvoidProhibitedIntegrations() throws {
    let appRoot = try appRootURL()
    let sourceFiles = try swiftSourceFiles(in: appRoot.appending(path: "Sources"))
    let filesToScan =
        [
            appRoot.appending(path: "Package.swift"),
            appRoot.appending(path: "UVBurnTimer.entitlements"),
            appRoot.appending(path: "app.xcodeproj/project.pbxproj"),
        ] + sourceFiles

    let prohibitedIntegrationTokens = [
        "HealthKit",
        "StoreKit",
        "AdSupport",
        "AppTrackingTransparency",
        "Firebase",
        "Crashlytics",
        "GoogleMobileAds",
        "RevenueCat",
        "Amplitude",
        "Mixpanel",
        "Sentry",
        "FacebookSDK",
        "AuthenticationServices",
    ]
    let prohibitedUITokens = [
        "apple.logo",
        "accessibilitySortPriority(-",
    ]

    for file in filesToScan {
        let contents = try String(contentsOf: file, encoding: .utf8)
        for token in prohibitedIntegrationTokens {
            #expect(
                !contents.localizedCaseInsensitiveContains(token),
                "\(file.path(percentEncoded: false)) contains prohibited integration token \(token)")
        }
        for token in prohibitedUITokens {
            #expect(
                !contents.localizedCaseInsensitiveContains(token),
                "\(file.path(percentEncoded: false)) contains prohibited UI token \(token)")
        }
    }
}

@Test func pricingGuardrailsRejectInAppPurchaseFrameworks() throws {
    // Argos's 90-day post-launch rule (see .squad ledger): the app ships as a
    // one-time paid download with no in-app purchase, subscription, tip jar,
    // or restore flow. The existing `appSourcesAvoidProhibitedIntegrations`
    // test scans for `StoreKit` as a substring, which catches
    // `import StoreKit`/`import StoreKit2` but not specific StoreKit symbols
    // whose names do not contain the literal substring "StoreKit". This
    // guards against those symbols being introduced via copy-paste.
    let appRoot = try appRootURL()
    let sourceFiles = try swiftSourceFiles(in: appRoot.appending(path: "Sources"))
    let filesToScan =
        [
            appRoot.appending(path: "Package.swift"),
            appRoot.appending(path: "UVBurnTimer.entitlements"),
            appRoot.appending(path: "app.xcodeproj/project.pbxproj"),
        ] + sourceFiles

    let prohibitedIAPTokens = [
        "SubscriptionStoreView",
        "AppTransaction",
        "SKPaymentTransactionObserver",
        "Product.products",
        "requestReview",
    ]

    for file in filesToScan {
        let contents = try String(contentsOf: file, encoding: .utf8)
        for token in prohibitedIAPTokens {
            #expect(
                !contents.localizedCaseInsensitiveContains(token),
                "\(file.path(percentEncoded: false)) contains prohibited IAP/monetization token \(token)")
        }
    }
}

@Test func sunscreenReapplicationReminderUsesTwoHourInterval() {
    #expect(ProductTiming.sunscreenReapplicationIntervalSeconds == 7_200)
}

@Test func visibleEstimateContextLineIncludesInputsAndOneDecimalUV() {
    #expect(
        EstimateContextLine.text(
            skinType: .typeIII,
            spf: .spf30,
            uvIndex: 6.24
        ) == "Fitzpatrick III · SPF 30 · UV index 6.2")
    #expect(
        EstimateContextLine.text(
            skinType: .typeI,
            spf: .spf15,
            uvIndex: 10
        ) == "Fitzpatrick I · SPF 15 · UV index 10.0")
}

@Test func heroAccessibilitySummaryCombinesSafetyCriticalVerdictContext() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .unprotectedReference,
        uvIndex: 6
    )

    #expect(
        HeroAccessibilitySummary.text(
            estimate: estimate,
            uvIndex: 6,
            verdict: "Moderate"
        )
            == "Estimated burn time: 33 minutes. Current UV index: 6.0. Moderate tier. Estimated only, not medical advice."
    )
}

// MARK: - WI-s: forecastDateContext folds into HeroAccessibilitySummary
//
// Without WI-s, the VoiceOver summary for the hero card always reads as
// if the gauge is showing "now" — even when the user has tapped a future
// forecast date in ForecastPickerView and the visual hero card is
// displaying "Burn time on Wed, 6 PM" above the gauge. Sighted users see
// the date context as a quiet caption; VoiceOver users hear nothing and
// believe they are looking at a live "now" estimate. WI-s closes that
// gap by folding the forecastDateContext String into HeroAccessibilitySummary
// when it is non-nil, so the VO read-out leads with the forecast date.
//
// Contract:
//   * nil forecastDateContext (the "now" case) — VO summary is byte-for-byte
//     identical to the pre-WI-s string (backward compatible — no existing
//     test regression, no surprise read-out for users on "now").
//   * non-nil forecastDateContext (e.g., "Burn time on Wed, 6 PM") — VO
//     summary is prefixed with the date context as its own sentence, so
//     screen reader users know they are inspecting a forecasted moment
//     rather than the live UV reading.

@Test func heroAccessibilitySummaryOmitsForecastContextWhenNil() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .unprotectedReference,
        uvIndex: 6
    )

    let nowSummary = HeroAccessibilitySummary.text(
        estimate: estimate,
        uvIndex: 6,
        verdict: "Moderate",
        forecastDateContext: nil
    )

    #expect(
        nowSummary
            == "Estimated burn time: 33 minutes. Current UV index: 6.0. Moderate tier. Estimated only, not medical advice."
    )
}

@Test func heroAccessibilitySummaryLeadsWithForecastContextWhenProvided() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .unprotectedReference,
        uvIndex: 6
    )

    let forecastSummary = HeroAccessibilitySummary.text(
        estimate: estimate,
        uvIndex: 6,
        verdict: "Moderate",
        forecastDateContext: "Burn time on Wed, 6 PM"
    )

    #expect(
        forecastSummary
            == "Burn time on Wed, 6 PM. Estimated burn time: 33 minutes. Current UV index: 6.0. Moderate tier. Estimated only, not medical advice."
    )
}

@Test func heroAccessibilitySummaryDefaultForecastContextIsNilForBackwardCompatibility() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .unprotectedReference,
        uvIndex: 6
    )

    // Existing callers that pass only the three legacy parameters must
    // continue to compile AND return the pre-WI-s string exactly.
    // The forecastDateContext parameter MUST default to nil.
    let legacySummary = HeroAccessibilitySummary.text(
        estimate: estimate,
        uvIndex: 6,
        verdict: "Moderate"
    )
    let explicitNilSummary = HeroAccessibilitySummary.text(
        estimate: estimate,
        uvIndex: 6,
        verdict: "Moderate",
        forecastDateContext: nil
    )

    #expect(legacySummary == explicitNilSummary)
}

@Test func heroAccessibilitySummaryTrimsLeadingAndTrailingWhitespaceFromForecastContext() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .unprotectedReference,
        uvIndex: 6
    )

    // A defensive trim guards against the upstream ForecastPickerLogic
    // ever emitting padded strings (newline / leading-space drift). The
    // VO read-out should never start with whitespace nor include a
    // trailing space before the next sentence.
    let trimmedSummary = HeroAccessibilitySummary.text(
        estimate: estimate,
        uvIndex: 6,
        verdict: "Moderate",
        forecastDateContext: "  Burn time on Wed, 6 PM  "
    )

    #expect(
        trimmedSummary
            == "Burn time on Wed, 6 PM. Estimated burn time: 33 minutes. Current UV index: 6.0. Moderate tier. Estimated only, not medical advice."
    )
}

@Test func heroAccessibilitySummaryTreatsBlankForecastContextAsNoContext() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .unprotectedReference,
        uvIndex: 6
    )

    // Empty / whitespace-only forecastDateContext must not leak a
    // standalone period into the read-out (e.g., ". Estimated...").
    // The function should fall back to the nil-equivalent string.
    let blankSummary = HeroAccessibilitySummary.text(
        estimate: estimate,
        uvIndex: 6,
        verdict: "Moderate",
        forecastDateContext: "   "
    )
    let nilSummary = HeroAccessibilitySummary.text(
        estimate: estimate,
        uvIndex: 6,
        verdict: "Moderate",
        forecastDateContext: nil
    )

    #expect(blankSummary == nilSummary)
}

@Test func heroAccessibilitySummaryAppendsTerminatingPeriodToForecastContextWhenMissing() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .unprotectedReference,
        uvIndex: 6
    )

    // If the upstream context already terminates with punctuation, we
    // must not double it. If it does NOT terminate (the common case for
    // the current "Burn time on Wed, 6 PM" string), we must add a single
    // period so VoiceOver pauses between sentences.
    let unterminatedSummary = HeroAccessibilitySummary.text(
        estimate: estimate,
        uvIndex: 6,
        verdict: "Moderate",
        forecastDateContext: "Burn time on Wed, 6 PM"
    )
    let terminatedSummary = HeroAccessibilitySummary.text(
        estimate: estimate,
        uvIndex: 6,
        verdict: "Moderate",
        forecastDateContext: "Burn time on Wed, 6 PM."
    )

    #expect(unterminatedSummary == terminatedSummary)
    #expect(unterminatedSummary.hasPrefix("Burn time on Wed, 6 PM. "))
    #expect(!unterminatedSummary.contains("PM.."))
}

@Test func locationPromptGateAcknowledgesRationaleBeforeAllowingSystemPrompt() {
    var gate = LocationPromptGate()

    #expect(!gate.hasAcknowledgedRationale)
    let firstAttemptAllowsPrompt = gate.allowSystemPromptOrAcknowledgeRationale()
    #expect(!firstAttemptAllowsPrompt)
    #expect(gate.hasAcknowledgedRationale)
    let secondAttemptAllowsPrompt = gate.allowSystemPromptOrAcknowledgeRationale()
    #expect(secondAttemptAllowsPrompt)
}

@Test func locationActionPresentationShowsVisibleFetchProgress() {
    let fetching = LocationActionPresentation(
        hasUVIndex: false,
        isFetching: true
    )

    #expect(fetching.title == "Fetching UV...")
    #expect(fetching.systemImageName == "location.fill")
    #expect(fetching.accessibilityHint.localizedCaseInsensitiveContains("fetching"))
    #expect(fetching.accessibilityHint.localizedCaseInsensitiveContains("Apple Weather"))
}

@Test func locationActionPresentationPrioritizesFetchingOverRecalculate() {
    let fetching = LocationActionPresentation(
        hasUVIndex: true,
        isFetching: true
    )

    #expect(fetching.title == "Fetching UV...")
    #expect(fetching.systemImageName == "location.fill")
}

@Test func locationActionPresentationMatchesReadyStates() {
    #expect(
        LocationActionPresentation(
            hasUVIndex: false,
            isFetching: false
        ).title == "Use my location")
    #expect(
        LocationActionPresentation(
            hasUVIndex: true,
            isFetching: false
        ).title == "Recalculate")
}

@Test func cachedRoundedCoordinateRoundTripsWithoutUVSkinTypeOrSPF() throws {
    let snapshot = UVSnapshot(
        uvIndex: 6.5,
        fetchedAt: Date(timeIntervalSince1970: 1_000),
        roundedCoordinate: UVCoordinate(latitude: 37.77, longitude: -122.42)
    )

    let cached = CachedRoundedCoordinate(snapshot: snapshot)
    let storageValue = try CachedRoundedCoordinateStorage.storageValue(for: snapshot)
    let encoded = try #require(storageValue.data(using: .utf8))
    let encodedObject = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
    let decoded = try JSONDecoder().decode(CachedRoundedCoordinate.self, from: encoded)

    #expect(decoded == cached)
    #expect(
        try CachedRoundedCoordinateStorage.roundedCoordinate(from: storageValue)
            == UVCoordinate(latitude: 37.77, longitude: -122.42))
    #expect(
        try CachedRoundedCoordinateStorage.roundedCoordinate(from: CachedRoundedCoordinateStorage.clearedStorageValue)
            == nil)
    #expect(decoded.roundedCoordinate == UVCoordinate(latitude: 37.77, longitude: -122.42))
    #expect(decoded.roundedCoordinate.privacyDisplayText == "Approx. 37.77, -122.42")
    #expect(encodedObject["uvIndex"] == nil)
    #expect(encodedObject["fetchedAt"] == nil)
    #expect(encodedObject["selectedSkinType"] == nil)
    #expect(encodedObject["selectedSPF"] == nil)
}

@Test func corruptCachedRoundedCoordinateStorageThrowsWithoutProducingCoordinate() {
    #expect(throws: (any Error).self) {
        try CachedRoundedCoordinateStorage.roundedCoordinate(from: "not-json")
    }
}

@Test func relativeAgeCopyIsHumanReadable() {
    let fetchedAt = Date(timeIntervalSince1970: 1_000)

    #expect(RelativeAgeText.text(fetchedAt: fetchedAt, now: Date(timeIntervalSince1970: 1_000)) == "Updated 1 min ago")
    #expect(RelativeAgeText.text(fetchedAt: fetchedAt, now: Date(timeIntervalSince1970: 1_059)) == "Updated 1 min ago")
    #expect(RelativeAgeText.text(fetchedAt: fetchedAt, now: Date(timeIntervalSince1970: 1_090)) == "Updated 1 min ago")
    #expect(RelativeAgeText.text(fetchedAt: fetchedAt, now: Date(timeIntervalSince1970: 1_300)) == "Updated 5 min ago")
}

// MARK: - Work item #4: approved redesign + source-backed paraphrasing

@Test func fitzpatrickPickerPresentsSixRowsForTypesIThroughVI() {
    let allCases = FitzpatrickSkinType.allCases
    #expect(allCases.count == 6)

    let expectedRomanNumerals = ["I", "II", "III", "IV", "V", "VI"]
    let actualRomanNumerals = allCases.map(\.romanNumeral)
    #expect(actualRomanNumerals == expectedRomanNumerals)

    for skinType in allCases {
        #expect(!skinType.pickerDescription.isEmpty)
    }
}

@Test func skinTypePickerHeaderIsBehaviorFirstPerWheelerSpec() {
    // Wheeler §3.1 behavior-first requirement: prompt must lead with burns/tans behavior,
    // not visual skin color, to avoid anchor-effect bias (D-2026-05-19-012, Suchi).
    let prompt = ProductCopy.skinTypePickerPrompt
    #expect(prompt.localizedCaseInsensitiveContains("burns") || prompt.localizedCaseInsensitiveContains("burn"))
    #expect(prompt.localizedCaseInsensitiveContains("tans") || prompt.localizedCaseInsensitiveContains("tan"))
    // Must not position color as the primary classification signal.
    #expect(
        !prompt.localizedCaseInsensitiveContains("skin color")
            && !prompt.localizedCaseInsensitiveContains("skin colour"))
    // Must not be empty.
    #expect(!prompt.isEmpty)
}

@Test func skinTypePickerSubtextCapturesBehaviorCuesAndRangeOfTones() {
    // Wheeler §3.1 subtext: references unprotected sun, no sunscreen, no recent tan,
    // and range of natural skin tones — all source-backed cues.
    let subtext = ProductCopy.skinTypePickerSubtext
    #expect(subtext.localizedCaseInsensitiveContains("what your skin does"))
    #expect(subtext.localizedCaseInsensitiveContains("no sunscreen"))
    #expect(subtext.localizedCaseInsensitiveContains("no recent tan"))
    #expect(subtext.localizedCaseInsensitiveContains("range of natural skin tones"))
    #expect(subtext.localizedCaseInsensitiveContains("30 minutes"))
}

@Test func skinTypeSourcePointerNamesRequiredSources() {
    // Plunder §2.3: inline source pointer must name at least one source by author/year.
    let pointer = ProductCopy.skinTypeSourcePointer
    #expect(pointer.localizedCaseInsensitiveContains("Fitzpatrick"))
    #expect(pointer.localizedCaseInsensitiveContains("NCBI"))
    #expect(pointer.localizedCaseInsensitiveContains("NBK481857"))
    // Must include a path to the About surface.
    #expect(pointer.localizedCaseInsensitiveContains("About"))
}

@Test func skinTypePickerFooterExplicitlyStatesNoDefault() {
    // D-2026-05-19-012: no default selection is a hard safety rule.
    let footer = ProductCopy.skinTypePickerFooter
    #expect(footer.localizedCaseInsensitiveContains("No default"))
    #expect(footer.localizedCaseInsensitiveContains("deliberately"))
}

@Test func notMedicalAdviceLimitsAppearOnReapplicationAndAboutSurfaces() {
    // L2 persistent footer and About copy both carry "not medical advice" per D-2026-05-19-011.
    #expect(ProductCopy.reapplicationFooter.localizedCaseInsensitiveContains("not medical advice"))
    #expect(
        ProductCopy.aboutHowThisWorks.localizedCaseInsensitiveContains("not medical advice")
            || ProductCopy.disclaimerBody.localizedCaseInsensitiveContains("not medical advice"))
}

@Test func weatherKitAttributionCopyMeetsAppleRequirements() {
    // D-2026-05-19-004: WeatherKit attribution must name "Apple Weather" and link to the legal URL.
    #expect(ProductCopy.weatherAttributionServiceName == "Apple Weather")
    #expect(ProductCopy.weatherDataAttributionBody.localizedCaseInsensitiveContains("Apple Weather"))
    #expect(ProductCopy.weatherAttributionLegalURLString.hasPrefix("https://weatherkit.apple.com/"))
    #expect(ProductCopy.weatherAttributionLegalURL.host() == "weatherkit.apple.com")
}

@Test func aboutCitationLinksSatisfyWheelerSection4Requirements() {
    // Wheeler §4.1–4.4: NCBI, Fitzpatrick, WHO, Schalka, Diffey, CIE all required in About.
    let titles = Set(ProductCopy.citationLinks.map(\.title))
    let urls = Set(ProductCopy.citationLinks.map { $0.url.absoluteString })

    // §4.1 skin-type classification
    #expect(urls.contains("https://doi.org/10.1001/archderm.1988.01670060015008"))  // Fitzpatrick TB 1988
    #expect(urls.contains("https://www.ncbi.nlm.nih.gov/books/NBK481857/"))  // NCBI Bookshelf

    // §4.2–4.3 MED math and UVI conversion
    #expect(urls.contains("https://iris.who.int/handle/10665/42459"))  // WHO UV Index
    #expect(urls.contains("https://doi.org/10.1088/0031-9155/36/3/001"))  // Diffey 1991

    // At least 6 distinct citations listed.
    #expect(ProductCopy.citationLinks.count >= 6)
    // No two citations share the same URL (deduplication guard).
    #expect(ProductCopy.citationLinks.count == urls.count)
    _ = titles  // ensure set was computed
}

@Test func mainScreenFitzpatrickExposureIsLimitedToOnboardingAndSettings() {
    // Architecture invariant: the main app session starts without a skin type, enforcing
    // that skin-type selection is an explicit onboarding step (D-2026-05-19-012).
    // The SkinTypeOnboardingDraft commit gate is the only write path into the session.
    let freshSession = UVBurnTimerSession()
    #expect(freshSession.selectedSkinType == nil)

    // Draft cannot commit without an explicit selection.
    var draft = SkinTypeOnboardingDraft()
    #expect(!draft.canContinue)

    var session = freshSession
    #expect(!draft.commit(to: &session))
    #expect(session.selectedSkinType == nil)

    // Only after an explicit select() call can the draft commit.
    draft.select(.typeIII)
    #expect(draft.canContinue)
    #expect(draft.commit(to: &session))
    #expect(session.selectedSkinType == .typeIII)
}

@Test func userPreferenceStorageRestoresSkinTypeSPFAndSafeDefaults() throws {
    let defaults = try #require(UserDefaults(suiteName: "UVBurnTimerPreferenceStorageTests"))
    defaults.removePersistentDomain(forName: "UVBurnTimerPreferenceStorageTests")

    #expect(UserPreferenceStorage.restoredSession(from: defaults).selectedSkinType == nil)
    #expect(UserPreferenceStorage.restoredSession(from: defaults).selectedSPF == .spf30)

    UserPreferenceStorage.persist(skinType: .typeIV, to: defaults)
    UserPreferenceStorage.persist(spf: .spf50, to: defaults)

    var restoredSession = UserPreferenceStorage.restoredSession(from: defaults)
    #expect(restoredSession.selectedSkinType == .typeIV)
    #expect(restoredSession.selectedSPF == .spf50)
    #expect(!restoredSession.acknowledgedDisclaimer)

    defaults.set(SPFLevel.unprotectedReference.rawValue, forKey: UserPreferenceStorage.selectedSPFKey)
    restoredSession = UserPreferenceStorage.restoredSession(from: defaults)
    #expect(restoredSession.selectedSPF == .spf30)

    defaults.set(999, forKey: UserPreferenceStorage.selectedSPFKey)
    restoredSession = UserPreferenceStorage.restoredSession(from: defaults)
    #expect(restoredSession.selectedSPF == .spf30)

    UserPreferenceStorage.clearStoredPreferences(from: defaults)
    #expect(UserPreferenceStorage.restoredSession(from: defaults).selectedSkinType == nil)
    #expect(UserPreferenceStorage.restoredSession(from: defaults).selectedSPF == .spf30)
}

private func appRootURL() throws -> URL {
    var url = URL(filePath: #filePath)

    while url.lastPathComponent != "app" {
        let parent = url.deletingLastPathComponent()
        if parent == url {
            throw AppSourceLookupError.appRootNotFound
        }
        url = parent
    }

    return url
}

private func swiftSourceFiles(in directory: URL) throws -> [URL] {
    let resourceKeys: Set<URLResourceKey> = [.isRegularFileKey]
    guard
        let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: Array(resourceKeys)
        )
    else {
        throw AppSourceLookupError.sourcesNotFound
    }

    return try enumerator.compactMap { item in
        guard let url = item as? URL, url.pathExtension == "swift" else {
            return nil
        }

        let values = try url.resourceValues(forKeys: resourceKeys)
        return values.isRegularFile == true ? url : nil
    }
}

private enum AppSourceLookupError: Error {
    case appRootNotFound
    case sourcesNotFound
}

// MARK: - Group R: HeroTimerCard Refactor (Wrapper + Chrome Removal) Contract
//
// These guards belong logically in MainScreenCleanupContractTests.swift, but
// that file is not currently wired into app.xcodeproj's UVBurnTimerCoreTests
// target (see WI for follow-up: wire the dead contract-test files into the
// xcodeproj or move their content into wired files like this one). Placed
// here so they actually compile and run.

private func _appViewsSourceForGroupR() throws -> String {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let appViewsURL = testFileURL
        .deletingLastPathComponent()  // UVBurnTimerCoreTests/
        .deletingLastPathComponent()  // Tests/
        .deletingLastPathComponent()  // app/
        .appendingPathComponent("Sources/UVBurnTimer/AppViews.swift")
    return try String(contentsOf: appViewsURL, encoding: .utf8)
}

/// R1 — `HeroTimerCard` View struct still exists as a wrapper around the hero card.
///
/// **Why this guard matters:** an earlier refactor attempt (`9da54cf`) inlined the
/// entire HeroTimerCard body into `RootView.heroTimerCardView`, removing the
/// `struct HeroTimerCard: View` boundary. That broke `testSettingsSheetOpens` in
/// XCUI because the toolbar `gearshape` Button's tap stopped opening the
/// `.sheet(isPresented: $showSettings)`. The fix was to restore the `HeroTimerCard`
/// View struct (still without card chrome / title row), which re-isolated the hero
/// card's SwiftUI identity from RootView's toolbar and re-enabled tap dispatch.
/// This test pins that architectural decision so the next inliner sees a green
/// guard and knows why the wrapper must stay.
@Test func test_R1_heroTimerCardWrapperStructStillExists() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains("struct HeroTimerCard: View"),
        "HeroTimerCard View struct must remain a wrapper — inlining it into RootView regresses XCUI testSettingsSheetOpens (toolbar gear button stops opening Settings sheet). See .squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md for the architectural rationale."
    )
}

/// R2 — RootView delegates to `HeroTimerCard(...)` instead of inlining the body.
///
/// Pins the call-site shape: `heroTimerCardView` must return a `HeroTimerCard(...)`
/// instance rather than a raw `VStack { ... }`. Pairs with R1 to guard the wrapper.
@Test func test_R2_rootViewDelegatesToHeroTimerCardConstructor() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains("HeroTimerCard("),
        "RootView.heroTimerCardView must instantiate HeroTimerCard(...) — see R1 and .squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md for the regression this guards."
    )
}

/// R3 — `burnTimeEstimateTitle` constant is permanently retired.
///
/// The "Burn-time estimate" header row was removed from the hero card per
/// commit `9da54cf` (the circular gauge stands alone as the main-screen primary).
/// Re-adding the constant or rendering it as a label would resurrect a UX
/// regression the team explicitly approved removing.
@Test func test_R3_burnTimeEstimateTitleIsRetired() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        !source.contains("burnTimeEstimateTitle"),
        "ProductCopy.burnTimeEstimateTitle was retired with the hero card chrome — do not re-introduce the 'Burn-time estimate' label row above the gauge."
    )
}

/// R4 — Card chrome (regularMaterial + cornerRadius 24) is permanently removed.
///
/// The previous card body wrapped its content with
/// `.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))`
/// and `.padding(24)`. After the cleanup the gauge stands alone with no card
/// surface. Re-adding the material chrome to HeroTimerCard would re-introduce
/// the visual "card-within-card" the redesign explicitly removed.
@Test func test_R4_heroTimerCardChromeIsRetired() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct HeroTimerCard: View") }) else {
        Issue.record("HeroTimerCard struct not found — covered by R1, skipping chrome check")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: { $0.hasPrefix("struct ") || $0.hasPrefix("private struct ") }) ?? lines.endIndex
    let cardBody = lines[cardStart..<cardEnd].joined(separator: "\n")
    #expect(
        !cardBody.contains(".regularMaterial"),
        "HeroTimerCard body must not re-add .regularMaterial card chrome — the gauge stands alone."
    )
    #expect(
        !cardBody.contains("cornerRadius: 24"),
        "HeroTimerCard body must not re-add cornerRadius: 24 chrome — the gauge stands alone."
    )
}

/// R5 — `forecastDateContext` is rendered as a `.caption` (not `.headline`).
///
/// Per the redesign, when a forecast time is selected the date context is shown
/// as a quiet caption above the gauge — NOT as a bold headline replacing the
/// removed "Burn-time estimate" label. Guards against accidental promotion to
/// `.headline` / `.title` weight during future refactors.
@Test func test_R5_forecastDateContextIsCaptionStyle() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct HeroTimerCard: View") }) else {
        Issue.record("HeroTimerCard struct not found — covered by R1, skipping caption check")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: { $0.hasPrefix("struct ") || $0.hasPrefix("private struct ") }) ?? lines.endIndex
    let cardBody = lines[cardStart..<cardEnd].joined(separator: "\n")

    let hasCaptionDate =
        cardBody.contains("forecastDateContext")
        && cardBody.range(of: #"forecastDateContext[\s\S]{0,200}\.font\(\.caption\)"#, options: .regularExpression) != nil
    #expect(
        hasCaptionDate,
        "HeroTimerCard must render forecastDateContext with .font(.caption) — promotion to .headline reverses the gauge-as-primary redesign."
    )
}

/// R6 — `mainVerdictCaveatLinkLabel` copy is still wired into RootView surfaces.
///
/// Plunder C2 / L3 — the inline caveat link ("Meds + conditions can shorten this.
/// Learn more") must remain reachable. The cleanup removed the
/// `mainVerdictCaveatLinkLabel` `NavigationLink` block from inside the hero card
/// (the toolbar ⓘ button replaces that reach-back per WI-50/WI-51/K-7), but the
/// underlying ProductCopy constant must still exist for the toolbar info button's
/// destination view (`AboutView(highlightEstimateApplicability: true)`).
@Test func test_R6_mainVerdictCaveatLinkLabelConstantStillExists() {
    #expect(
        !ProductCopy.mainVerdictCaveatLinkLabel.isEmpty,
        "ProductCopy.mainVerdictCaveatLinkLabel must remain non-empty — required by AboutView highlight anchor and the toolbar ⓘ Reach-Back (K-2)."
    )
}

// MARK: - Group R causal binding (WI-h)
//
// R1 and R2 pin the *static* facts: HeroTimerCard exists as a struct and is
// invoked from RootView. They do not by themselves prove the *causal chain*
// that the wrapper is what protects the toolbar ⓘ → Settings sheet flow. The
// XCUI testSettingsSheetOpens is the behavioral check; R7 closes the gap at
// the source-text layer by pinning the co-location invariants that, if
// violated, reproduce the 8th-loop regression class even when R1 and R2 stay
// green:
//
//   * R7a — RootView body co-locates `HeroTimerCard(`,
//     `.sheet(isPresented: $showSettings)`, and the `showSettings = true`
//     Button action. If a future refactor moves the sheet off RootView (e.g.,
//     onto HeroTimerCard or onto a separate `SettingsHost` view) the
//     identity-boundary protection R1/R2 provide becomes irrelevant because
//     the regression mechanism is no longer the same.
//   * R7b — `HeroTimerCard`'s own body must NOT host the toolbar Button, the
//     `.sheet(isPresented: $showSettings)` modifier, or the
//     `showSettings = true` action. Inlining any of those into the wrapper
//     would re-create the identity collapse: the sheet would be owned by a
//     descendant of the same struct whose body contains the gear Button,
//     scrambling presentation-slot resolution exactly as `9da54cf` did.
//
// Together R7a + R7b pin the *binding* between (toolbar Button, sheet
// modifier, hero card wrapper invocation) and prove they remain three
// siblings of RootView rather than collapsing into a single nested chain.
//
// Reference: .squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md

private func _rootViewBodySliceForGroupR() throws -> String {
    let source = try _appViewsSourceForGroupR()
    guard let rootStart = source.range(of: "struct RootView: View {") else {
        Issue.record("Could not locate `struct RootView: View {` in AppViews.swift")
        return ""
    }
    let after = source[rootStart.upperBound...]
    // Slice from RootView start up to the *next* top-level `struct ...: View {`
    // declaration. That puts every nested member of RootView (computed `var`s,
    // helper functions, the body modifier chain) into the slice while excluding
    // sibling structs such as HeroTimerCard, SettingsSheet, AboutView, etc.
    if let nextStruct = after.range(of: #"\nstruct [A-Z]\w*: View \{"#, options: .regularExpression) {
        return String(after[..<nextStruct.lowerBound])
    }
    return String(after)
}

private func _heroTimerCardBodySliceForGroupR() throws -> String {
    let source = try _appViewsSourceForGroupR()
    guard let heroStart = source.range(of: "struct HeroTimerCard: View {") else {
        Issue.record("Could not locate `struct HeroTimerCard: View {` in AppViews.swift")
        return ""
    }
    let after = source[heroStart.upperBound...]
    if let nextStruct = after.range(of: #"\nstruct [A-Z]\w*: View \{"#, options: .regularExpression) {
        return String(after[..<nextStruct.lowerBound])
    }
    return String(after)
}

/// R7a — RootView body co-locates the three pieces whose binding the wrapper
/// architecture protects.
///
/// If any of these three predicates fails, the wrapper is no longer doing
/// the job it was restored to do — either the call-site moved away from the
/// toolbar/sheet pair, or the sheet/toolbar moved away from the call-site,
/// either of which invalidates the causal chain that R1 and R2 implicitly
/// assume. Reference: ADR-0001.
@Test func test_R7a_rootViewBodyColocatesHeroSheetAndToolbarButton() throws {
    let body = try _rootViewBodySliceForGroupR()
    #expect(
        body.contains("HeroTimerCard("),
        "RootView body must invoke `HeroTimerCard(` so the wrapper sits as a sibling of the toolbar Button + sheet. If you moved the hero into a different parent view, you also moved it away from the toolbar/sheet that R1/R2 protect — and the wrapper no longer carries the architectural load described in .squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md."
    )
    #expect(
        body.contains(".sheet(isPresented: $showSettings)"),
        "RootView body must host `.sheet(isPresented: $showSettings)`. Moving this sheet onto HeroTimerCard, SettingsHost, or anywhere else re-introduces the regression class the wrapper was restored to prevent (see ADR-0001)."
    )
    #expect(
        body.contains("showSettings = true"),
        "RootView body must contain the `showSettings = true` toolbar Button action. If the toolbar gear Button is moved onto a child view (e.g., HeroTimerCard) the identity-boundary protection collapses for the same reason the original 9da54cf inlining broke `testSettingsSheetOpens` (see ADR-0001)."
    )
}

/// R7b — HeroTimerCard's own body must NOT host the toolbar Button, the
/// Settings sheet modifier, or the `showSettings` flip.
///
/// Inlining any of those into the wrapper would defeat the wrapper: the
/// presentation slot would be owned by the same struct whose body contains
/// the gear Button, which is exactly the identity collapse `9da54cf`
/// produced. Reference: ADR-0001.
@Test func test_R7b_heroTimerCardBodyDoesNotHostToolbarSheetOrShowSettingsFlip() throws {
    let body = try _heroTimerCardBodySliceForGroupR()
    #expect(
        !body.contains(".sheet(isPresented: $showSettings)"),
        "HeroTimerCard must NOT host `.sheet(isPresented: $showSettings)` — putting the Settings sheet inside the wrapper re-creates the SwiftUI identity collapse the wrapper was restored to prevent (see ADR-0001). Keep the sheet on RootView."
    )
    #expect(
        !body.contains(".toolbar {"),
        "HeroTimerCard must NOT host its own `.toolbar { ... }` modifier — the toolbar belongs to RootView. Hosting it inside the wrapper would re-introduce the regression class (see ADR-0001). Keep `.toolbar` on RootView's navigationStackBase."
    )
    #expect(
        !body.contains("showSettings = true"),
        "HeroTimerCard must NOT contain a `showSettings = true` action — that Button action belongs in RootView so the toolbar sibling tap reaches RootView's `.sheet(isPresented: $showSettings)` without crossing the wrapper's identity boundary (see ADR-0001)."
    )
}

// MARK: - Group R follow-up audit (WI-m): sibling card delegates remain non-inlining
//
// ADR-0001 captured the architectural rule that complex card content owned by
// RootView's body must delegate to a standalone `View` struct so the parent
// keeps a stable SwiftUI identity boundary (toolbar `.sheet`/`.toolbar`
// modifier hit-test). The hero card regression class (commit `9da54cf`) was
// caught and fixed by R1/R2/R7a/R7b. WI-m audits the two other heavyweight
// child cards that share the same RootView body — `uvIndexCardView` and
// `forecastPickerCardView` — to confirm they already delegate to standalone
// View structs (UVIndexCard / UVIndexPlaceholderCard / ForecastPickerView)
// and have not silently slipped back into inlined form.
//
// R8 freezes that audit result so a future refactor cannot inline either
// card's body into RootView and re-create the 8th-loop regression on a
// different surface (e.g., UV-card tap collapses toolbar hit-test, or
// forecast-picker date selection breaks the gear → Settings sheet flow).
//
// Reference: .squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md

/// R8a — `UVIndexCard` survives as a standalone `View` struct in AppViews.swift.
///
/// Inlining its body into RootView (or merging it into another wrapper)
/// would re-create the identity-collapse regression class ADR-0001 documents,
/// just on the UV-index surface instead of the hero surface.
@Test func test_R8a_uvIndexCardSurvivesAsViewStruct() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains("struct UVIndexCard: View"),
        "UVIndexCard must remain a standalone `View` struct — inlining it into RootView would re-create the SwiftUI identity-collapse regression class ADR-0001 documents (see R1 for the hero-card analogue). Reference: .squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md"
    )
    #expect(
        source.contains("struct UVIndexPlaceholderCard: View"),
        "UVIndexPlaceholderCard must remain a standalone `View` struct (the no-UV-data fallback paired with UVIndexCard). Inlining it shares the same regression-class risk as inlining UVIndexCard. Reference: ADR-0001."
    )
}

/// R8b — `ForecastPickerView` survives as a standalone `public View` struct
/// in its own source file.
///
/// The forecast picker is the heaviest child card on the main screen (685
/// lines of view logic plus a separate target-internal logic module). If it
/// is ever moved inline into RootView's body — or its struct shell collapsed
/// — the identity-collapse regression class becomes a candidate on the
/// forecast surface. Pinning the standalone declaration prevents that drift.
@Test func test_R8b_forecastPickerViewSurvivesAsViewStruct() throws {
    let pickerSource = try _forecastPickerSourceForGroupR()
    #expect(
        pickerSource.contains("public struct ForecastPickerView: View"),
        "ForecastPickerView must remain a standalone `public View` struct in ForecastPickerView.swift — inlining its body into RootView (or merging it into another wrapper) would re-create the SwiftUI identity-collapse regression class ADR-0001 documents on the forecast-picker surface. Reference: .squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md"
    )
}

/// R8c — RootView delegates to BOTH `UVIndexCard(`/`UVIndexPlaceholderCard(`
/// AND `ForecastPickerView(` rather than inlining either card's body.
///
/// This is the call-site companion to R8a/R8b: even if both child structs
/// exist (R8a/R8b green) a refactor could still inline a *copy* of their
/// body content into RootView and stop calling the standalone struct,
/// silently re-creating the regression class. R8c freezes the delegation
/// contract at the call-site, mirroring how R2 freezes the `HeroTimerCard(`
/// call-site.
@Test func test_R8c_rootViewDelegatesToSiblingCardStructs() throws {
    let body = try _rootViewBodySliceForGroupR()
    #expect(
        body.contains("UVIndexCard(") || body.contains("UVIndexPlaceholderCard("),
        "RootView must instantiate either UVIndexCard(...) or UVIndexPlaceholderCard(...) rather than inlining the UV-index card body — see R2 for the hero-card analogue and ADR-0001 for the architectural rationale."
    )
    #expect(
        body.contains("ForecastPickerView("),
        "RootView must instantiate ForecastPickerView(...) rather than inlining the forecast picker body — see R2 for the hero-card analogue and ADR-0001 for the architectural rationale."
    )
}

/// Loads ForecastPickerView.swift for R8b text-pattern asserts.
/// Mirrors `_appViewsSourceForGroupR()` for the picker file.
private func _forecastPickerSourceForGroupR() throws -> String {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let pickerURL = testFileURL
        .deletingLastPathComponent()  // UVBurnTimerCoreTests/
        .deletingLastPathComponent()  // Tests/
        .deletingLastPathComponent()  // app/
        .appendingPathComponent("Sources/UVBurnTimer/ForecastPickerView.swift")
    return try String(contentsOf: pickerURL, encoding: .utf8)
}

// MARK: - Group S: Toolbar ⓘ L3 Reach-Back (WI-i)
//
// The toolbar `info.circle` Button (accessibilityIdentifier
// "EstimateInfoButton") in RootView is the L3 Reach-Back surface for the
// photosensitization / medication / sunscreen caveat — it navigates the
// user to `AboutView(highlightEstimateApplicability: true)`, which then
// scrolls to and highlights the "When this estimate may not apply"
// section. WI-i added three XCUI smoke tests covering this affordance
// (`testEstimateInfoButtonOpensAboutWithHighlightedApplicabilityAnchor`,
// `testToolbarRendersBothSettingsAndEstimateInfoButtons`, and
// `testEstimateInfoNavigationRoundTripReturnsToMainScreen`) and those
// tests rely on three source-text contracts that S1, S2, and S3 pin
// here so a future refactor cannot silently strip them and turn the
// XCUI guards into no-ops.
//
// S1 — the toolbar Button must keep accessibilityIdentifier
//      "EstimateInfoButton" and navigate to AboutView with
//      highlightEstimateApplicability: true. Without the identifier
//      XCUI cannot locate the button; without the highlight flag the
//      About scroll-to-anchor + highlight chrome does not render.
//
// S2 — AboutView must render the "When this estimate may not apply"
//      Text with accessibilityIdentifier "AboutEstimateApplicabilityHeader".
//      This is the identifier the XCUI test asserts visible after
//      navigation, and it is the only stable handle on the highlighted
//      caveat section (the user-facing string is Plunder-vetted and
//      MUST NOT be the assertion target because copy edits would then
//      silently break XCUI without any source guard catching it).
//
// S3 — the toolbar must keep BOTH the Settings gear (accessibilityLabel
//      "Settings") AND the EstimateInfoButton (accessibilityIdentifier
//      "EstimateInfoButton") as siblings of the RootView body, AND the
//      info button must remain a NavigationLink push (not a modal
//      sheet). Collapsing either button into a Menu, removing either
//      entry point, or converting the info push into a sheet would
//      regress the K-7/WI-50–WI-53 design and the back-chevron
//      round-trip the user expects on iOS.

/// S1 — RootView's toolbar still routes the L3 caveat info button at
/// EstimateInfoButton → AboutView(highlightEstimateApplicability: true).
@Test func test_S1_toolbarInfoButtonRoutesToHighlightedAboutView() throws {
    let body = try _rootViewBodySliceForGroupR()
    #expect(
        body.contains("AboutView(highlightEstimateApplicability: true)"),
        "RootView toolbar must navigate to AboutView(highlightEstimateApplicability: true) — the L3 Reach-Back relies on the highlight flag to scroll to and visually emphasize the 'When this estimate may not apply' section. See WI-i smoke test testEstimateInfoButtonOpensAboutWithHighlightedApplicabilityAnchor."
    )
    #expect(
        body.contains(#".accessibilityIdentifier("EstimateInfoButton")"#),
        "RootView toolbar info button must keep accessibilityIdentifier \"EstimateInfoButton\" — required by XCUI smoke testEstimateInfoButtonOpensAboutWithHighlightedApplicabilityAnchor + the existing acknowledgeDisclaimerAndChooseTypeIII helper. See WI-i."
    )
}

/// S2 — AboutView's "When this estimate may not apply" header still
/// carries accessibilityIdentifier "AboutEstimateApplicabilityHeader"
/// so XCUI can assert the highlight anchor is visible after the L3
/// Reach-Back navigation.
@Test func test_S2_aboutEstimateApplicabilityHeaderHasStableIdentifier() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains(#"Text("When this estimate may not apply")"#),
        "AboutView must render the canonical 'When this estimate may not apply' Text header — it is the destination of the highlightEstimateApplicability scroll anchor and the visible target the L3 Reach-Back delivers the user to."
    )
    #expect(
        source.contains(#".accessibilityIdentifier("AboutEstimateApplicabilityHeader")"#),
        "AboutView's 'When this estimate may not apply' Text must keep accessibilityIdentifier \"AboutEstimateApplicabilityHeader\" — the XCUI smoke testEstimateInfoButtonOpensAboutWithHighlightedApplicabilityAnchor depends on this stable handle (we deliberately do NOT assert on the Plunder-vetted user-facing string because copy edits would silently break XCUI without a source guard). See WI-i."
    )
}

/// S3 — RootView's toolbar must keep *both* the Settings gear and the
/// EstimateInfoButton as **siblings** (not collapsed into a single menu
/// or removed in favour of the other). The XCUI smoke
/// testToolbarRendersBothSettingsAndEstimateInfoButtons pins the
/// runtime co-existence; this source-text guard pins the static intent
/// so the XCUI guard cannot silently turn into a no-op by losing one of
/// the toolbar slots.
///
/// We assert against the toolbar Button accessibilityLabel "Settings"
/// (gear ⚙ entry to SettingsSheet) and the accessibilityIdentifier
/// "EstimateInfoButton" (info.circle ⓘ entry to AboutView highlight
/// reach-back). Both must remain in RootView's body slice — collapsing
/// either behind a Menu, or moving either to a child View, would defeat
/// the wrapper architecture ratified in ADR-0001 because the two
/// presentation slots (.sheet + NavigationLink) MUST stay siblings of
/// the toolbar Buttons on RootView for SwiftUI presentation-slot
/// resolution to succeed (see R7a/R7b for the identity-boundary
/// argument). The toolbar-slot S3 guard is the counterpart of R7a's
/// sheet/button co-location guard.
@Test func test_S3_toolbarKeepsBothSettingsAndEstimateInfoButtons() throws {
    let body = try _rootViewBodySliceForGroupR()
    #expect(
        body.contains(#".accessibilityLabel("Settings")"#),
        "RootView toolbar must keep a Button with accessibilityLabel \"Settings\" (the gear ⚙ entry to SettingsSheet) — XCUI smoke testToolbarRendersBothSettingsAndEstimateInfoButtons + testSettingsSheetOpens rely on this label. See WI-i."
    )
    #expect(
        body.contains(#".accessibilityIdentifier("EstimateInfoButton")"#),
        "RootView toolbar must keep a Button with accessibilityIdentifier \"EstimateInfoButton\" (the info.circle ⓘ entry to AboutView highlight reach-back) — XCUI smoke testEstimateInfoButtonOpensAboutWithHighlightedApplicabilityAnchor + testToolbarRendersBothSettingsAndEstimateInfoButtons rely on this identifier. See WI-i."
    )
    #expect(
        body.contains(#"NavigationLink(destination: AboutView(highlightEstimateApplicability: true))"#),
        "RootView toolbar EstimateInfoButton must remain a NavigationLink push (not a .sheet) so the standard back-chevron returns the user to the main screen — XCUI smoke testEstimateInfoNavigationRoundTripReturnsToMainScreen asserts the round-trip behaviour. See WI-i."
    )
}
