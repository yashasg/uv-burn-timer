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
    // WI-iris-c (Loop-11) — Pattern-B truth fix: the line must NOT claim
    // that "disclaimer acknowledgments" are not saved (the policy-version
    // integer IS persisted) and MUST name the acknowledgment-version
    // persistence explicitly.
    #expect(!ProductCopy.cacheRetentionLine.localizedCaseInsensitiveContains("disclaimer acknowledgments"))
    #expect(ProductCopy.cacheRetentionLine.localizedCaseInsensitiveContains("version of the informational disclaimer"))
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
    // WI-iris-c (Loop-11) — Pattern-B truth fix.
    #expect(!ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("disclaimer acknowledgments are not retained"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("version of the informational disclaimer"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("does not re-prompt"))
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


// MARK: - Group V: Forecast-vs-now affordance (WI-p)
//
// Loop-9 Wheeler/Iris polish — when the forecast picker selects a
// non-current hour, HeroTimerCard renders `forecastDateContext` (e.g.
// "Burn time on Wed at 6 PM") above the gauge. Prior to WI-p the
// rendering was a bare `.caption` Text in `.secondary` foreground style
// — visually quiet to the point of being easy to miss, even though it
// indicates the displayed estimate is for a future hour, NOT now.
// Wheeler's behavioral-safety follow-up flagged the
// countdown-vs-estimate misread risk that grows when users do not
// realise they are looking at a forecast.
//
// WI-p strengthens the affordance by wrapping the text in a SwiftUI
// `Label` with a `clock.arrow.circlepath` SF Symbol icon. The icon is
// the visual cue ("this is a different time, not now") while typography
// stays `.caption` so R5 (forecastDateContext caption-style guard) and
// the spec line ("rendered as a quiet `.font(.caption)` above the
// gauge — NOT as a `.headline`") both stay green. The HeroAccessibility
// Summary VoiceOver read-out (WI-s) already names the forecast time
// explicitly, so the icon is the sighted-user equivalent affordance.
//
// V1 — HeroTimerCard renders `clock.arrow.circlepath` Image inside the
//      same `if let forecastDateContext` block that owns the
//      HeroForecastDateContext identifier.
// V2 — typography remains `.font(.caption)` (regression guard paired
//      with R5). Promotion to `.subheadline` / `.headline` would also
//      fail R5, but V2 spells out the rule one more time at the new
//      Label-wrapped surface so the next refactor sees an explicit
//      guard naming the icon site.

/// V1 — HeroTimerCard renders the `clock.arrow.circlepath` icon inside
/// the forecastDateContext block.
@Test func test_V1_heroForecastDateContextRendersClockArrowIcon() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct HeroTimerCard: View") }) else {
        Issue.record("HeroTimerCard struct not found — covered by R1, skipping icon check")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: { $0.hasPrefix("struct ") || $0.hasPrefix("private struct ") }) ?? lines.endIndex
    let cardBody = lines[cardStart..<cardEnd].joined(separator: "\n")

    // The icon must live inside the same `if let forecastDateContext`
    // block that carries the HeroForecastDateContext identifier — i.e.
    // the icon appears within ~400 chars of the identifier.
    let iconNearIdentifier = #"clock\.arrow\.circlepath[\s\S]{0,400}HeroForecastDateContext"#
    let identifierNearIcon = #"HeroForecastDateContext[\s\S]{0,400}clock\.arrow\.circlepath"#
    let hasCoLocation =
        cardBody.range(of: iconNearIdentifier, options: .regularExpression) != nil
        || cardBody.range(of: identifierNearIcon, options: .regularExpression) != nil

    #expect(
        hasCoLocation,
        "HeroTimerCard must render `Image(systemName: \"clock.arrow.circlepath\")` inside the same conditional block as the HeroForecastDateContext identifier — WI-p uses the icon as the sighted-user 'this is a forecast time, not now' affordance while typography stays `.caption` (R5)."
    )
}

/// V2 — forecastDateContext typography stays `.font(.caption)` even
/// after the Label wrap. Reinforces R5 at the new icon site.
@Test func test_V2_forecastDateContextLabelStaysCaptionTypography() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct HeroTimerCard: View") }) else {
        Issue.record("HeroTimerCard struct not found — covered by R1")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: { $0.hasPrefix("struct ") || $0.hasPrefix("private struct ") }) ?? lines.endIndex
    let cardBody = lines[cardStart..<cardEnd].joined(separator: "\n")

    // After the WI-p Label wrap, the .font(.caption) modifier should
    // still apply to the Label (which carries the
    // HeroForecastDateContext identifier on the SAME line group).
    let labelCaptionPattern = #"clock\.arrow\.circlepath[\s\S]{0,200}\.font\(\.caption\)"#
    let identifierCaptionPattern = #"HeroForecastDateContext[\s\S]{0,200}\.font\(\.caption\)|\.font\(\.caption\)[\s\S]{0,200}HeroForecastDateContext"#

    let captionApplied =
        cardBody.range(of: labelCaptionPattern, options: .regularExpression) != nil
        || cardBody.range(of: identifierCaptionPattern, options: .regularExpression) != nil

    #expect(
        captionApplied,
        "After the WI-p Label wrap, the forecastDateContext surface must still apply `.font(.caption)` — promoting to `.subheadline` / `.headline` reverses the gauge-as-primary redesign (R5) and the spec's 'rendered as a quiet `.font(.caption)` above the gauge' contract."
    )
}





// MARK: - Group X: Hero ↔ UVIndex separator (WI-t, AX5 pass)
//
// Loop-9 Iris polish — at non-AX dynamic type sizes the previous
// `.thinMaterial` chrome on the UV-index card visually separated the
// chrome-free hero from the secondary UV data row. After WI-r inverted
// that chrome (W1/W2), and at AX dynamic type sizes generally, the two
// surfaces collapse into a single undifferentiated column with no visual
// boundary. Iris filed `wi-t-ax5-contrast-separator` (Eighth-loop
// closure log) so a `Divider()` between the two surfaces re-establishes
// the boundary in a way that survives AX5 reflow (Divider scales with
// the surrounding text style and inherits the system separator color
// across light/dark + Standard/Increased contrast).
//
// X1 — `navigationStackBase` body must render `Divider()` between
//      `heroTimerCardView` and `uvIndexCardView`. The order matters:
//      hero (primary output) → separator → UV data (secondary).

/// X1 — navigationStackBase renders `Divider()` between heroTimerCardView and uvIndexCardView.
@Test func test_X1_navigationStackBaseSeparatesHeroFromUVIndexCard() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let bodyStart = lines.firstIndex(where: { $0.contains("private var navigationStackBase: some View") }) else {
        Issue.record("navigationStackBase property not found")
        return
    }
    let bodyEnd: Int = lines[(bodyStart + 1)...].firstIndex(where: {
        $0.contains("private var ") && !$0.contains("navigationStackBase")
    }) ?? lines.endIndex
    let stackBody = lines[bodyStart..<bodyEnd].joined(separator: "\n")

    let heroToUVPattern = #"heroTimerCardView[\s\S]{0,200}Divider\(\)[\s\S]{0,200}uvIndexCardView"#
    #expect(
        stackBody.range(of: heroToUVPattern, options: .regularExpression) != nil,
        "navigationStackBase must render `Divider()` between `heroTimerCardView` and `uvIndexCardView` — WI-t (AX5 pass) re-establishes the hero/UV visual boundary that the WI-r chrome inversion (W1/W2) removed. Divider scales with the surrounding text style and inherits the system separator color, so it survives AX5 reflow + Standard/Increased contrast."
    )
}


// MARK: - Group W: UVIndexCard chrome inversion (WI-r)
//
// Loop-9 Iris polish — after the Eighth-loop hero-card-wrapper-restore cycle
// stripped the hero card's `.regularMaterial` + `cornerRadius: 24` chrome
// (commit `9da54cf`, guarded by R4), the secondary `UVIndexCard` /
// `UVIndexPlaceholderCard` continued to carry `.thinMaterial` + `cornerRadius:
// 16` chrome. Iris's end-of-Eighth-loop review filed `wi-r-uvindexcard-chrome-
// inversion` because the secondary card now visually outweighed the
// chrome-free primary hero — a visual hierarchy inversion. WI-r strips the
// material chrome from both UV cards so the secondary surface reads as data
// (UV index number + Apple Weather source line) without competing chrome.
// Section spacing in `navigationStackBase` (VStack spacing 20) preserves
// breathing room.
//
// W1 — `UVIndexCard` must NOT re-add `.thinMaterial` / `cornerRadius: 16`
//      card chrome. The card body is plain VStack with padding only; the
//      parent ScrollView VStack spacing handles visual separation.
// W2 — `UVIndexPlaceholderCard` (rendered when uvIndex is nil) must
//      similarly not re-add the material chrome. Otherwise launching with
//      no UV data still flashes a chromed card and reverses the hierarchy
//      inversion.
//
// These guards pair with R4 (hero chrome retired) — together they pin
// "no card-within-card chrome on the main screen" as an Iris-ratified
// architectural rule.

/// W1 — `UVIndexCard` body must NOT contain `.thinMaterial` background.
@Test func test_W1_uvIndexCardChromeIsInverted() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct UVIndexCard: View") }) else {
        Issue.record("UVIndexCard struct not found — guard the existence first, then inversion")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: { $0.hasPrefix("struct ") || $0.hasPrefix("private struct ") }) ?? lines.endIndex
    let cardBody = lines[cardStart..<cardEnd].joined(separator: "\n")
    #expect(
        !cardBody.contains(".thinMaterial"),
        "UVIndexCard body must not re-add `.thinMaterial` background — WI-r inverted the secondary-card chrome so it no longer visually outweighs the chrome-free hero (R4)."
    )
    #expect(
        !cardBody.contains("cornerRadius: 16"),
        "UVIndexCard body must not re-add `cornerRadius: 16` chrome — the secondary card stays chrome-free to preserve the hero's primary-surface visual weight."
    )
}

/// W2 — `UVIndexPlaceholderCard` body must NOT contain `.thinMaterial` background.
@Test func test_W2_uvIndexPlaceholderCardChromeIsInverted() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct UVIndexPlaceholderCard: View") }) else {
        Issue.record("UVIndexPlaceholderCard struct not found — guard the existence first, then inversion")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: { $0.hasPrefix("struct ") || $0.hasPrefix("private struct ") }) ?? lines.endIndex
    let cardBody = lines[cardStart..<cardEnd].joined(separator: "\n")
    #expect(
        !cardBody.contains(".thinMaterial"),
        "UVIndexPlaceholderCard body must not re-add `.thinMaterial` background — WI-r inverted the secondary-card chrome so the no-UV placeholder also reads as plain data, not as a chromed card competing with the hero."
    )
    #expect(
        !cardBody.contains("cornerRadius: 16"),
        "UVIndexPlaceholderCard body must not re-add `cornerRadius: 16` chrome."
    )
}

// MARK: - Group Y: mainInputsRow inputs-vs-outputs hierarchy (WI-q)
//
// Loop-9 Wheeler/Iris polish — the chip row (skinType + location + SPF)
// is the input surface that drives the burn-time estimate displayed in
// the hero region (the output surface). Prior to WI-q the row had no
// section label and the relationship to the gauge was implicit, leaving
// repeat users to infer that changing a chip should refresh the hero.
// WI-q adds a quiet "Inputs" caption header (uppercase + .secondary)
// above the chips so the visual reading order is:
//
//   Hero gauge / verdict      ← OUTPUT
//   Divider() (WI-t)
//   UV Index 6.2              ← DATA
//   Inputs                    ← LABEL
//     skinType  location  SPF ← INPUTS
//
// The header carries `.accessibilityAddTraits(.isHeader)` so VoiceOver
// users get the same hierarchy cue ("Inputs, heading" → "Skin type" →
// "Location" → "SPF") and `accessibilityIdentifier("MainInputsRowHeader")`
// so XCUI can pin the header's existence without depending on the
// user-facing string.
//
// Y1 — mainInputsRow body must render `Text("Inputs")` with
//      accessibilityIdentifier "MainInputsRowHeader" and the .isHeader
//      a11y trait.

/// Y1 — mainInputsRow renders the "Inputs" section header with the
/// MainInputsRowHeader identifier + .isHeader a11y trait.
@Test func test_Y1_mainInputsRowHasInputsHeader() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let bodyStart = lines.firstIndex(where: { $0.contains("private var mainInputsRow: some View") }) else {
        Issue.record("mainInputsRow property not found")
        return
    }
    let bodyEnd: Int = lines[(bodyStart + 1)...].firstIndex(where: {
        $0.contains("private var ") && !$0.contains("mainInputsRow")
    }) ?? lines.endIndex
    let stackBody = lines[bodyStart..<bodyEnd].joined(separator: "\n")

    #expect(
        stackBody.contains(#"Text("Inputs")"#),
        "mainInputsRow must render a `Text(\"Inputs\")` section header — WI-q surfaces the inputs-vs-outputs hierarchy that the chips drive the hero gauge."
    )
    #expect(
        stackBody.contains(#".accessibilityIdentifier("MainInputsRowHeader")"#),
        "mainInputsRow header must carry accessibilityIdentifier \"MainInputsRowHeader\" so XCUI can pin the header's existence without depending on the user-facing string."
    )
    #expect(
        stackBody.contains(".accessibilityAddTraits(.isHeader)"),
        "mainInputsRow header must carry `.accessibilityAddTraits(.isHeader)` so VoiceOver users get the same inputs-section cue as sighted users."
    )
}


// MARK: - Group GD: UserPreferenceStorage.shouldShowDisclaimerCover (WI-ff)
//
// Loop-10 Suchi gap analysis P0: the Pattern-B L1 cover gating implemented at
// UserPreferenceStorage.shouldShowDisclaimerCover(defaults:currentVersion:) is
// the single function that determines Asha's (P4 Accutane) re-attestation
// cadence AND Greta's (P1 gram-counter) "stop asking me every cold launch"
// friction relief. Per decisions.md (2026-05-21T07:00Z Iris persistence spec)
// the function ratified the four contracts G-D1..G-D4 below; this group
// finally pins them as tests so a future refactor cannot silently break
// either persona's experience.

/// G-D1 — Fresh install (no stored skin type, no rationale ack, no
/// stored policy version) shows the L1 disclaimer cover.
@Test func test_GD1_freshInstallShowsDisclaimerCover() throws {
    let (defaults, suiteName) = makeIsolatedDefaults()
    defer { tearDownIsolatedDefaults(defaults, suiteName: suiteName) }

    let shouldShow = UserPreferenceStorage.shouldShowDisclaimerCover(
        defaults: defaults,
        currentVersion: UserPreferenceStorage.currentDisclaimerPolicyVersion
    )

    #expect(
        shouldShow,
        "Fresh install (no stored data) must trigger L1 disclaimer cover — Asha and every new user must see L1 once on first launch. (WI-ff G-D1)"
    )
}

/// G-D2 — Returning user at the current policy version (already acked,
/// stored version == currentVersion) does NOT see L1 again.
@Test func test_GD2_returningUserAtCurrentPolicyVersionSkipsDisclaimerCover() throws {
    let (defaults, suiteName) = makeIsolatedDefaults()
    defer { tearDownIsolatedDefaults(defaults, suiteName: suiteName) }

    defaults.set(
        UserPreferenceStorage.currentDisclaimerPolicyVersion,
        forKey: UserPreferenceStorage.disclaimerPolicyVersionKey
    )
    defaults.set(FitzpatrickSkinType.typeIII.rawValue, forKey: UserPreferenceStorage.selectedSkinTypeKey)

    let shouldShow = UserPreferenceStorage.shouldShowDisclaimerCover(
        defaults: defaults,
        currentVersion: UserPreferenceStorage.currentDisclaimerPolicyVersion
    )

    #expect(
        !shouldShow,
        "Returning user at currentDisclaimerPolicyVersion must NOT see L1 — this is the Greta-friction relief that Pattern B was ratified to provide. (WI-ff G-D2)"
    )
}

/// G-D3 — A bump in `currentDisclaimerPolicyVersion` re-fires L1 for
/// a returning user whose stored version is now stale.
@Test func test_GD3_policyVersionBumpRefiresDisclaimerCoverForReturningUser() throws {
    let (defaults, suiteName) = makeIsolatedDefaults()
    defer { tearDownIsolatedDefaults(defaults, suiteName: suiteName) }

    let storedOldVersion = 1
    let bumpedNewVersion = storedOldVersion + 1
    defaults.set(storedOldVersion, forKey: UserPreferenceStorage.disclaimerPolicyVersionKey)
    defaults.set(FitzpatrickSkinType.typeIV.rawValue, forKey: UserPreferenceStorage.selectedSkinTypeKey)

    let shouldShow = UserPreferenceStorage.shouldShowDisclaimerCover(
        defaults: defaults,
        currentVersion: bumpedNewVersion
    )

    #expect(
        shouldShow,
        "A bumped currentDisclaimerPolicyVersion must re-fire L1 for returning users — this is Asha's regulatory re-attestation surface when Plunder ships a material policy change. (WI-ff G-D3)"
    )
}

/// G-D4 — Existing user upgrading from @State-only era (stored skin type
/// or location-rationale ack present, but no policyVersion key) is
/// silently migrated to currentVersion and does NOT re-fire L1.
@Test func test_GD4_legacyAckMigratedToCurrentPolicyVersionWithoutRefire() throws {
    let (defaults, suiteName) = makeIsolatedDefaults()
    defer { tearDownIsolatedDefaults(defaults, suiteName: suiteName) }

    defaults.set(FitzpatrickSkinType.typeII.rawValue, forKey: UserPreferenceStorage.selectedSkinTypeKey)

    let initialShouldShow = UserPreferenceStorage.shouldShowDisclaimerCover(
        defaults: defaults,
        currentVersion: UserPreferenceStorage.currentDisclaimerPolicyVersion
    )

    #expect(
        !initialShouldShow,
        "Existing user upgrading from @State-only era must NOT see L1 re-fire — Pattern B migration path silently writes currentVersion so the prior cold-launch L1 firings are honored. (WI-ff G-D4 migration)"
    )

    let migratedVersion = defaults.integer(forKey: UserPreferenceStorage.disclaimerPolicyVersionKey)
    #expect(
        migratedVersion == UserPreferenceStorage.currentDisclaimerPolicyVersion,
        "Migration must persist currentDisclaimerPolicyVersion to disclaimerPolicyVersionKey on the existing-user path so subsequent launches read the right version. Migrated value: \(migratedVersion). (WI-ff G-D4 persistence)"
    )
}

// MARK: - Shared helpers for Group GD

private func makeIsolatedDefaults() -> (defaults: UserDefaults, suiteName: String) {
    let suiteName = "UVBurnTimerTests.GD.\(UUID().uuidString)"
    guard let defaults = UserDefaults(suiteName: suiteName) else {
        Issue.record("Failed to construct isolated UserDefaults (suite=\(suiteName))")
        return (.standard, suiteName)
    }
    defaults.removePersistentDomain(forName: suiteName)
    return (defaults, suiteName)
}

private func tearDownIsolatedDefaults(_ defaults: UserDefaults, suiteName: String) {
    defaults.removePersistentDomain(forName: suiteName)
}

// MARK: - Group Z: Suchi persona priming — countdown-vs-estimate misread guard (WI-o)
//
// Loop-9 Suchi/Wheeler behavioural-safety follow-up wi-o-suchi-persona-prime-test:
// the hero region after commit `9da54cf` shows a bold rounded number ("47 min",
// "~1 hr 20 min", "Up to 2 hr", "4+ hr") that stands alone without the retired
// "Burn-time estimate" header label (R3). Wheeler flagged the risk that a
// user — especially Asha (Accutane), Tomás (trail-runner), and Maya (open-water)
// in Suchi's persona overlay — could glance at the number and misread it as a
// live countdown timer they can "trust" until it hits zero, rather than as a
// modeled erythemal-dose estimate that ignores cloud cover, reflectance,
// photosensitizers, and other input drift.
//
// Mitigation already shipped: HeroAccessibilitySummary.text() composes a
// VoiceOver read-out that ALWAYS leads with "Estimated burn time:" (or the
// "Sunscreen reapplication window" / "Estimated burn time: 4 or more hours"
// variants for capped cases) and ALWAYS terminates with "Estimated only, not
// medical advice." for the verdict phrase.
//
// Group Z formalises that mitigation as a hard contract across all four
// active tier shapes. A future copy refactor that drops "Estimated" or
// introduces "remaining" / "countdown" / "until" phrasing without explicit
// Plunder + Wheeler ratification will fail Z1/Z2 and cannot ship.

private func _heroSummaryCases() throws -> [(name: String, summary: String)] {
    let short = try BurnTimeCalculator.estimate(
        skinType: .typeI, spf: .unprotectedReference, uvIndex: 10)
    let moderate = try BurnTimeCalculator.estimate(
        skinType: .typeIII, spf: .unprotectedReference, uvIndex: 7)
    let cappedSunscreen = try BurnTimeCalculator.estimate(
        skinType: .typeIII, spf: .spf30, uvIndex: 8)
    let cappedDisplay = try BurnTimeCalculator.estimate(
        skinType: .typeVI, spf: .unprotectedReference, uvIndex: 2)

    return [
        ("short", HeroAccessibilitySummary.text(estimate: short, uvIndex: 10, verdict: "Short")),
        ("moderate", HeroAccessibilitySummary.text(estimate: moderate, uvIndex: 7, verdict: "Moderate")),
        ("sunscreen-capped", HeroAccessibilitySummary.text(estimate: cappedSunscreen, uvIndex: 8, verdict: "Long")),
        ("display-capped", HeroAccessibilitySummary.text(estimate: cappedDisplay, uvIndex: 2, verdict: "Long")),
    ]
}

/// Z1 — every active tier's summary contains estimate-language so VoiceOver
/// users hear it as a model output, not a live countdown.
@Test func test_Z1_heroSummaryAlwaysNamesEstimateNotCountdown() throws {
    for (name, summary) in try _heroSummaryCases() {
        let mentionsEstimate =
            summary.contains("Estimated burn time")
            || summary.contains("Sunscreen reapplication window")
            || summary.contains("Estimated only, not medical advice")
        #expect(
            mentionsEstimate,
            "Hero accessibility summary for \(name) tier must contain estimate-language so Asha/Tomás/Maya hear this as a modeled estimate, not a live countdown. Actual summary: \(summary)"
        )
    }
}

/// Z2 — no active tier's summary contains countdown-implying tokens.
@Test func test_Z2_heroSummaryNeverImpliesLiveCountdown() throws {
    let forbiddenTokens = [
        "remaining",
        "countdown",
        "until zero",
        "in seconds",
    ]
    for (name, summary) in try _heroSummaryCases() {
        for token in forbiddenTokens {
            #expect(
                !summary.lowercased().contains(token.lowercased()),
                "Hero accessibility summary for \(name) tier must not contain '\(token)' — that wording reads as a live countdown rather than a modeled estimate. Actual summary: \(summary)"
            )
        }
    }
}

/// Z3 — a forecast-date prefix (WI-s) does not strip the estimate semantics.
@Test func test_Z3_forecastDatePrefixPreservesEstimateDisclaimer() throws {
    let moderate = try BurnTimeCalculator.estimate(
        skinType: .typeIII, spf: .unprotectedReference, uvIndex: 7)
    let withForecast = HeroAccessibilitySummary.text(
        estimate: moderate,
        uvIndex: 7,
        verdict: "Moderate",
        forecastDateContext: "Burn time on Wed at 6 PM"
    )
    #expect(
        withForecast.hasPrefix("Burn time on Wed at 6 PM."),
        "Forecast-date prefix must terminate as its own sentence so VoiceOver users hear it as a separate forecast-time cue ahead of the estimate body. Actual: \(withForecast)"
    )
    #expect(
        withForecast.contains("Estimated only, not medical advice"),
        "Forecast read-out must still close with the estimate disclaimer so a future-hour read-out does not drop the medical-advice guard. Actual: \(withForecast)"
    )
}


// MARK: - Group EG: Loop-11 Bundle C — Plunder regulatory polish (M1, M2, M4)
//
// Bundle C converges three Plunder WIs:
//
//   WI-plunder-m1  Hosted Privacy Policy stub + on-device-copy sync guard (EH1, EH2)
//   WI-plunder-m2  Apple Weather AX5 attribution adjacency source-text guard (EG1, EG2)
//   WI-plunder-m4  EU counsel pre-submit checklist (docs-only — sibling
//                  file at .squad/files/plunder-eu-counsel-checklist.md)

/// EG1 — WI-plunder-m2: `UVIndexCard` body renders `Text(sourceLine)` and
/// `WeatherAttributionView()` as immediate siblings, with no other view
/// between them. Per D-2026-05-19-002/003/004 the Apple Weather
/// attribution is a launch-blocker; this guard fires if a future refactor
/// silently moves the attribution out of the same card surface.
@Test func test_EG1_uvIndexCardSourceLineAndAttributionAreAdjacent() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct UVIndexCard: View") }) else {
        Issue.record("UVIndexCard struct not found")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: {
        $0.hasPrefix("struct ") || $0.hasPrefix("private struct ")
    }) ?? lines.endIndex
    let body = lines[cardStart..<cardEnd]

    guard let sourceLineIdx = body.firstIndex(where: { $0.contains("Text(sourceLine)") }) else {
        Issue.record("UVIndexCard body must render Text(sourceLine)")
        return
    }
    guard let attributionIdx = body.firstIndex(where: { $0.contains("WeatherAttributionView()") }) else {
        Issue.record("UVIndexCard body must render WeatherAttributionView()")
        return
    }
    #expect(
        sourceLineIdx < attributionIdx,
        "UVIndexCard must render `Text(sourceLine)` BEFORE `WeatherAttributionView()` so the source line precedes the legal attribution block visually and in VoiceOver order."
    )
    // The two view literals must be within 12 lines of each other (allowing
    // for `if let updatedText` interstitial). If a substantive new view
    // wedges between them this guard fires.
    #expect(
        attributionIdx - sourceLineIdx <= 12,
        "UVIndexCard's Text(sourceLine) and WeatherAttributionView() must remain adjacent (currently \(attributionIdx - sourceLineIdx) lines apart). Per D-2026-05-19-003 the Apple Weather attribution must visually accompany every render of the UV index."
    )
}

/// EG2 — WI-plunder-m2: `UVIndexPlaceholderCard` (the no-UV-fetched
/// placeholder) also renders the same source-line ↔ attribution adjacency
/// so cold-launch and post-failure render paths cannot drop the
/// attribution either.
@Test func test_EG2_uvIndexPlaceholderCardSourceLineAndAttributionAreAdjacent() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct UVIndexPlaceholderCard: View") }) else {
        Issue.record("UVIndexPlaceholderCard struct not found")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: {
        $0.hasPrefix("struct ") || $0.hasPrefix("private struct ")
    }) ?? lines.endIndex
    let body = lines[cardStart..<cardEnd]

    guard let sourceLineIdx = body.firstIndex(where: { $0.contains("Text(sourceLine)") }) else {
        Issue.record("UVIndexPlaceholderCard body must render Text(sourceLine)")
        return
    }
    guard let attributionIdx = body.firstIndex(where: { $0.contains("WeatherAttributionView()") }) else {
        Issue.record("UVIndexPlaceholderCard body must render WeatherAttributionView()")
        return
    }
    #expect(sourceLineIdx < attributionIdx)
    #expect(
        attributionIdx - sourceLineIdx <= 12,
        "UVIndexPlaceholderCard's Text(sourceLine) and WeatherAttributionView() must remain adjacent (currently \(attributionIdx - sourceLineIdx) lines apart)."
    )
}

// MARK: - Group EH: WI-plunder-m1 — hosted Privacy Policy stub ↔ in-app copy

/// EH1 — WI-plunder-m1: the hosted Privacy Policy stub at
/// `.squad/files/privacy-policy.md` carries the load-bearing on-device
/// data sentences that mirror `ProductCopy.aboutPrivacy`. If a copy
/// editor changes only the stub OR only the in-app copy, this guard
/// fires.
@Test func test_EH1_hostedPrivacyPolicyStubMirrorsOnDeviceCopy() throws {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let policyURL = testFileURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent(".squad/files/privacy-policy.md")
    let policy = try String(contentsOf: policyURL, encoding: .utf8)

    // Substrings present in both sources of truth.
    let sharedPhrases = [
        "two decimal places",
        "Apple Weather",
        "device only",
        "version of the informational disclaimer",
        "no advertising identifier",
        "third-party",
        "informational only",
        "not medical advice",
    ]
    for phrase in sharedPhrases {
        #expect(
            policy.localizedCaseInsensitiveContains(phrase),
            "Hosted Privacy Policy stub at .squad/files/privacy-policy.md must contain '\(phrase)' — keeps the hosted-URL copy aligned with `ProductCopy.aboutPrivacy` and `ProductCopy.locationPrivacyLine` lanes."
        )
    }
}

/// EH2 — WI-plunder-m1: the hosted Privacy Policy stub explicitly
/// covers the Pattern-B disclaimer-version persistence (matching the
/// WI-iris-c truth fix in `cacheRetentionLine` and `aboutPrivacy`).
@Test func test_EH2_hostedPrivacyPolicyDescribesDisclaimerVersionPersistence() throws {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let policyURL = testFileURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent(".squad/files/privacy-policy.md")
    let policy = try String(contentsOf: policyURL, encoding: .utf8)

    #expect(
        policy.contains("disclaimerPolicyVersion"),
        "Hosted Privacy Policy stub must name the `disclaimerPolicyVersion` UserDefaults key so a hosted-policy reviewer sees the same Pattern-B implementation reference as the in-app reviewer."
    )
    #expect(
        policy.localizedCaseInsensitiveContains("re-prompt"),
        "Hosted Privacy Policy stub must describe the re-prompt cadence (the `disclaimerPolicyVersion` bump → cover re-fires) consistently with `ProductCopy.aboutPrivacy`."
    )
}

// MARK: - Group EI: WI-iris-i — orphan photosensitizationBannerLabel
//                              AUDIT-ONLY annotation

/// EI1 — WI-iris-i: `photosensitizationBannerLabel` is still in
/// `ProductCopy` but is no longer rendered at runtime (the K-1 banner
/// retirement, see `.squad/decisions.md` ~L739, moved L3 reach-back to
/// the toolbar ⓘ button). The constant is retained for spec/audit
/// fidelity; this guard pins that **no Swift source file under
/// `Sources/UVBurnTimer/`** references the constant for rendering.
@Test func test_EI1_photosensitizationBannerLabelIsNotRenderedAtRuntime() throws {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let appViewsURL = testFileURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Sources/UVBurnTimer/AppViews.swift")
    let appViews = try String(contentsOf: appViewsURL, encoding: .utf8)
    let appURL = testFileURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Sources/UVBurnTimer/UVBurnTimerApp.swift")
    let app = try String(contentsOf: appURL, encoding: .utf8)

    #expect(
        !appViews.contains("photosensitizationBannerLabel"),
        "AppViews.swift must not reference ProductCopy.photosensitizationBannerLabel at the render layer — the K-1 banner retirement moved L3 reach-back to the toolbar ⓘ button. The constant is retained AUDIT-ONLY in ProductCopy for spec fidelity."
    )
    #expect(
        !app.contains("photosensitizationBannerLabel"),
        "UVBurnTimerApp.swift must not reference ProductCopy.photosensitizationBannerLabel at the render layer (banner retired by K-1)."
    )
}


// MARK: - Group EE: Loop-11 Bundle B — Wheeler photobiology citation hygiene
//
// Bundle B converges five WIs that all hit FitzpatrickSkinType.swift,
// BurnTimeCalculator.swift, or ProductCopy / ProductTiming and that all carry
// photobiology citation discipline:
//
//   WI-wheeler-gg  2-hour reapplication ↔ ProductTiming source-text guard (EE1)
//   WI-wheeler-ff  per-row MED + picker citation comments               (EE2, EE3)
//   WI-wheeler-nn  UVI 0.025 AUDIT-ONLY comment at the call site        (EE4)
//   WI-wheeler-oo  Fitz IV–VI wider-uncertainty disclosure guard        (EE5)
//   WI-wheeler-pp  UVI=0 SPF-branch uniformity guard                    (EE6)

/// EE1 — WI-wheeler-gg: every user-visible "2 hour(s)" / "Up to 2 hr" copy
/// lane is derived from (or numerically matches)
/// `ProductTiming.sunscreenReapplicationIntervalMinutes`. If a future
/// maintainer tunes the reapplication interval (e.g., to 90 minutes
/// post-water exposure), this guard fires every copy lane that would
/// silently continue to read "2 hours".
/// Anchor: `.squad/decisions/archive/wheeler-fitzpatrick-and-med-anchor.md`
/// §3.4 + AAD/CDC/FDA reapplication discipline.
@Test func test_EE1_reapplicationCopyMirrorsProductTimingConstant() throws {
    let minutes = Int(ProductTiming.sunscreenReapplicationIntervalMinutes)
    #expect(
        minutes == 120,
        "If ProductTiming.sunscreenReapplicationIntervalMinutes changes, every assertion below must be re-derived deliberately."
    )

    let hourPhrase = "\(minutes / 60) hours"  // "2 hours"
    let shortPhrase = "\(minutes / 60) hr"    // "2 hr"

    let capped = try BurnTimeCalculator.estimate(skinType: .typeIII, spf: .spf30, uvIndex: 8)
    #expect(capped.displayText == "Up to \(shortPhrase)")
    #expect(capped.accessibilitySummary.localizedCaseInsensitiveContains("up to \(hourPhrase)"))
    #expect(capped.accessibilitySummary.localizedCaseInsensitiveContains(
        "reapply sunscreen at least every \(hourPhrase)"))

    #expect(ProductCopy.estimateElapsedWarning.localizedCaseInsensitiveContains("every \(hourPhrase)"))
    #expect(ProductCopy.sunscreenCapHedge.localizedCaseInsensitiveContains("capped at \(hourPhrase)"))
    #expect(ProductCopy.reapplicationFooter.localizedCaseInsensitiveContains(
        "reapply sunscreen at least every \(hourPhrase)"))
    #expect(ProductCopy.aboutSunSafetyActions.localizedCaseInsensitiveContains("every \(hourPhrase)"))
    #expect(ProductCopy.aboutHowThisWorks.localizedCaseInsensitiveContains("capped at \(hourPhrase)"))
    #expect(ProductCopy.aboutSunscreenAssumptions.localizedCaseInsensitiveContains(
        "at least every \(hourPhrase)"))
}

/// EE2 — WI-wheeler-ff: every Fitzpatrick MED row carries an AUDIT-ONLY
/// citation comment naming the paper(s) and page that ratified the value.
/// Anchored by reading the source file directly so the comments survive
/// future refactors.
@Test func test_EE2_fitzpatrickMEDRowsAllHaveAuditOnlyCitations() throws {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let fitzpatrickURL = testFileURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Sources/UVBurnTimerCore/FitzpatrickSkinType.swift")
    let source = try String(contentsOf: fitzpatrickURL, encoding: .utf8)

    // The block must lead with the Wheeler MED MARK + sources block.
    #expect(
        source.contains("Minimal Erythemal Dose (J/m², erythemally weighted per CIE S 007/E:1998)"),
        "FitzpatrickSkinType.swift must carry the Wheeler MED MARK block citing CIE S 007/E:1998 and the Fitzpatrick/Sayre/Diffey/Harrison anchor papers."
    )

    // All six per-row AUDIT-ONLY citations must appear, in numerical order,
    // each naming the row value and at least one citation source.
    let perRowMatches: [(String, String)] = [
        ("200 J/m²", "Fitzpatrick 1988"),
        ("250 J/m²", "Fitzpatrick 1988"),
        ("300 J/m²", "Fitzpatrick 1988"),
        ("450 J/m²", "Sayre 1981"),
        ("600 J/m²", "Harrison & Young 2002"),
        ("1_000 J/m²", "Harrison & Young 2002"),
    ]
    for (value, citationSource) in perRowMatches {
        #expect(
            source.contains("AUDIT-ONLY: \(value)"),
            "FitzpatrickSkinType.swift must carry an AUDIT-ONLY comment naming the MED value \(value) on its row."
        )
        // Tolerate citation-source spread across multiple comment lines per row.
        #expect(
            source.contains(citationSource),
            "FitzpatrickSkinType.swift must cite \(citationSource) for the \(value) row."
        )
    }
}

/// EE3 — WI-wheeler-ff: pickerDescription block carries an AUDIT-ONLY
/// comment naming the NCBI Bookshelf NBK481857 paraphrase provenance + the
/// D-CYCLE-1-001 reorder ratification.
@Test func test_EE3_fitzpatrickPickerDescriptionCarriesPararphraseAuditComment() throws {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let fitzpatrickURL = testFileURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Sources/UVBurnTimerCore/FitzpatrickSkinType.swift")
    let source = try String(contentsOf: fitzpatrickURL, encoding: .utf8)

    #expect(
        source.contains("NCBI"),
        "pickerDescription block must cite NCBI as paraphrase source."
    )
    #expect(
        source.contains("NBK481857"),
        "pickerDescription block must cite NBK481857 Bookshelf identifier as paraphrase source."
    )
    #expect(
        source.contains("D-CYCLE-1-001"),
        "pickerDescription block must cite the D-CYCLE-1-001 behavior-first reorder decision."
    )
    #expect(
        source.contains("D-2026-05-19-009"),
        "pickerDescription block must cite D-2026-05-19-009 (paraphrase-not-verbatim NCBI)."
    )
}

/// EE4 — WI-wheeler-nn: the magic `0.025` UVI→irradiance constant is
/// commented with the WHO 2002 Practical Guide citation at the call site
/// so a future maintainer does not silently retune the conversion.
@Test func test_EE4_uvIndexConversionConstantCarriesWHO2002Citation() throws {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let calculatorURL = testFileURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Sources/UVBurnTimerCore/BurnTimeCalculator.swift")
    let source = try String(contentsOf: calculatorURL, encoding: .utf8)

    let lines = source.components(separatedBy: "\n")
    guard let calcLineIdx = lines.firstIndex(where: { $0.contains("uvIndex * 0.025") }) else {
        Issue.record("0.025 UVI→irradiance call site not found")
        return
    }
    // The AUDIT-ONLY comment must sit within the 8 lines preceding the
    // call site (long enough to include the multi-line WHO 2002 prose).
    let lo = max(0, calcLineIdx - 8)
    let window = lines[lo..<calcLineIdx].joined(separator: "\n")
    #expect(
        window.contains("WHO 2002"),
        "BurnTimeCalculator.swift must cite WHO 2002 Practical Guide above the `uvIndex * 0.025` call site so a future maintainer does not silently retune the erythemal-irradiance conversion."
    )
    #expect(
        window.contains("0.025"),
        "BurnTimeCalculator.swift's audit comment must name the 0.025 constant explicitly."
    )
}

/// EE5 — WI-wheeler-oo: `aboutEstimateApplicability` discloses that
/// Fitzpatrick IV–VI estimates carry wider uncertainty because the
/// published MED values are commonly represented as ranges. This guard
/// keeps the disclosure intact even if the surrounding copy is refactored.
@Test func test_EE5_aboutCopyDisclosesFitzIVtoVIWiderUncertainty() {
    let copy = ProductCopy.aboutEstimateApplicability
    #expect(copy.contains("Fitzpatrick IV–VI"))
    #expect(copy.localizedCaseInsensitiveContains("wider uncertainty"))
    #expect(copy.localizedCaseInsensitiveContains("ranges"))
}

/// EE6 — WI-wheeler-pp: the UVI=0 branch returns `.tier == .none` and
/// `displayText == "No UV"` for both unprotected and SPF-protected inputs.
/// (Anchors the polar-night = nighttime ratification: SPF does not change
/// the no-UV outcome.)
@Test func test_EE6_zeroUVStateIsIdenticalAcrossSPFBranches() throws {
    let unprotected = try BurnTimeCalculator.estimate(
        skinType: .typeIII, spf: .unprotectedReference, uvIndex: 0)
    let protected = try BurnTimeCalculator.estimate(
        skinType: .typeIII, spf: .spf30, uvIndex: 0)

    #expect(unprotected.tier == .none)
    #expect(protected.tier == .none)
    #expect(unprotected.displayText == "No UV")
    #expect(protected.displayText == "No UV")
    // The only allowed difference is the sunscreen-protected flag.
    #expect(!unprotected.isSunscreenProtected)
    #expect(protected.isSunscreenProtected)
}


// MARK: - Group EK: Loop-11 Bundle E — Gaia ADR maintenance + Suchi/Mati docs

/// EK1 — WI-gaia-ii (R8 chip watchlist): `skinTypeChip` stays lightweight
/// per ADR-0001 Addendum 2026-05-21. The chip is permitted as an inline
/// computed property only while it (a) carries no `@State`/`@StateObject`
/// and (b) stays short (≤ 40 LOC). If anyone adds local state or grows
/// the chip into a substantive subtree, this guard fires and the chip
/// must be extracted into `struct SkinTypeChip: View` to preserve the
/// architectural invariant.
@Test func test_EK1_skinTypeChipStaysLightweight() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let bodyStart = lines.firstIndex(where: { $0.contains("private var skinTypeChip: some View") }) else {
        Issue.record("skinTypeChip property not found")
        return
    }
    let bodyEnd: Int = lines[(bodyStart + 1)...].firstIndex(where: {
        $0.contains("private var ") && !$0.contains("skinTypeChip")
    }) ?? lines.endIndex
    let body = lines[bodyStart..<bodyEnd]
    let bodyText = body.joined(separator: "\n")

    #expect(
        !bodyText.contains("@State"),
        "skinTypeChip must not declare its own @State — ADR-0001 Addendum (2026-05-21, WI-gaia-hh) requires extraction to `struct SkinTypeChip: View` if state is added."
    )
    #expect(
        !bodyText.contains("@StateObject"),
        "skinTypeChip must not declare its own @StateObject — ADR-0001 Addendum requires extraction if state is added."
    )
    #expect(
        body.count <= 40,
        "skinTypeChip body is now \(body.count) lines; ADR-0001 Addendum caps inline chip computed properties at ≤ 40 LOC. Extract to `struct SkinTypeChip: View` before growing further."
    )
}

/// EK2 — WI-gaia-gg (line refresh): the ADR-0001 References § now cites
/// the post-Loop-10 line numbers, not the WI-l-era ones. This guard
/// reads the ADR and fails if it still cites the retired pointers.
@Test func test_EK2_adr0001ReferencesPointAtCurrentLineNumbers() throws {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let adrURL = testFileURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent(".squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md")
    let adr = try String(contentsOf: adrURL, encoding: .utf8)

    // The retired (pre-Loop-10) line refs must not appear in the
    // References § block (test-file lines drifted +217 by Loop-10 close).
    #expect(
        !adr.contains("`test_R1_heroTimerCardWrapperStructStillExists` — line **1090**"),
        "ADR-0001 must not cite the retired R1 line (was 1090, now 1307+)."
    )
    #expect(
        !adr.contains("`test_R2_rootViewDelegatesToHeroTimerCardConstructor` — line **1102**"),
        "ADR-0001 must not cite the retired R2 line (was 1102, now 1319+)."
    )
    // The refreshed pointers must be present.
    #expect(adr.contains("test_R1_heroTimerCardWrapperStructStillExists"))
    #expect(adr.contains("test_R2_rootViewDelegatesToHeroTimerCardConstructor"))
}

/// EK3 — WI-gaia-hh (multi-sheet addendum): ADR-0001 carries the
/// addendum naming the four presentation modifiers + two NavigationLink
/// pushes that resolve against RootView's identity, plus the
/// lightweight-inlining clarification.
@Test func test_EK3_adr0001CarriesMultiSheetAddendum() throws {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let adrURL = testFileURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent(".squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md")
    let adr = try String(contentsOf: adrURL, encoding: .utf8)

    #expect(
        adr.contains("Multi-sheet / multi-cover on a single parent"),
        "ADR-0001 must carry the WI-gaia-hh addendum naming the multi-sheet-on-parent pattern."
    )
    #expect(adr.contains("$showSkinTypeEdit"))
    #expect(adr.contains("$showDisclaimer"))
    #expect(adr.contains("$showSkinTypeOnboarding"))
    #expect(adr.contains("EstimateInfoButton"))
    #expect(adr.contains("PersistentFooter"))
    // Worked examples block.
    #expect(adr.contains("skinTypeChip"))
    #expect(adr.contains("mainNavigationStack"))
}

/// EK4 — WI-suchi-g (persona-annotations Pattern-B reconcile): the
/// persona doc no longer claims L1 fires "every cold launch"; it now
/// names Pattern B + WI-ff Group GD as the gating mechanism.
@Test func test_EK4_personaAnnotationsReconciledToPatternB() throws {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let docURL = testFileURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent(".squad/files/suchi-persona-annotations.md")
    let doc = try String(contentsOf: docURL, encoding: .utf8)

    #expect(
        doc.contains("Pattern B"),
        "suchi-persona-annotations.md must reference Pattern B after WI-suchi-g (Loop-11) reconcile."
    )
    #expect(
        doc.contains("disclaimerPolicyVersion"),
        "suchi-persona-annotations.md must name the disclaimerPolicyVersion key — that is the Pattern-B gating mechanism."
    )
    #expect(
        doc.contains("WI-ff Group GD"),
        "suchi-persona-annotations.md must reference WI-ff Group GD (the Loop-10 PR that ratified Pattern B)."
    )
    // The Diagram-note line and the L1-hard-gate annotation must no
    // longer carry the unconditional "every cold launch" wording.
    #expect(
        !doc.contains("L1 is a hard gate every cold launch (Donatello M1)."),
        "Diagram note must no longer claim L1 is a hard gate every cold launch — reconciled to Pattern B per WI-suchi-g."
    )
}

// MARK: - Group FF: Loop-11 Bundle F — Plunder regulatory-floor audit hardening
//
// Source: Plunder gap-analysis (claude-opus-4.7-xhigh), 2026-05-21 loop-11
// pass. Closes the §2/§3 gap candidates that were NOT covered by Bundle A
// (Group CC) / Bundle B (Group EE) / Bundle C (Groups EG, EH, EI). Each
// guard cites the regulation it protects and the failure-mode it prevents
// so future contributors understand why the substring is load-bearing.

/// FF1 — GDPR Art.17 erasure-path button "Clear stored skin type" routed
/// through `ProductCopy` so the audit sieves apply, and so the L1 storage-
/// line promise ("You can clear them anytime in Settings") preserves verb
/// continuity with the button title.
///
/// **Regulatory anchor:** GDPR Art.17 (right to erasure); Plunder P-2; the
/// docstring on `ProductCopy.disclaimerStorageLine` explicitly names this
/// button by string as the erasure surface.
@Test func test_FF1_clearStoredSkinTypeButtonTitleIsRoutedThroughProductCopy() throws {
    #expect(ProductCopy.clearStoredSkinTypeButtonTitle == "Clear stored skin type")
    #expect(ProductCopy.auditCopySurfaces.contains(ProductCopy.clearStoredSkinTypeButtonTitle))
    // Verb continuity with `disclaimerStorageLine` ("You can *clear* them …")
    // — the GDPR Art.9(2)(a) consent specificity ↔ Art.17 erasure-affordance
    // loop only holds while the button title keeps the verb "clear".
    #expect(ProductCopy.clearStoredSkinTypeButtonTitle.localizedCaseInsensitiveContains("clear"))
    #expect(ProductCopy.clearStoredSkinTypeButtonTitle.localizedCaseInsensitiveContains("skin type"))
    // Render-site source-text guard: `SettingsSheet` must reference the
    // ProductCopy constant and NOT carry the inline literal anymore.
    let source = try _appViewsSourceForGroupR()
    #expect(source.contains("ProductCopy.clearStoredSkinTypeButtonTitle"))
    #expect(!source.contains("Text(\"Clear stored skin type\")"))
}

/// FF2 — Pattern-B `skinTypeChip` labels ("Type III" / "Set skin type")
/// flow through `ProductCopy` so they cannot silently drift into
/// measurement-like phrasing that would re-classify the chip from a
/// self-declared input echo (general-wellness) to an output (MDR Annex
/// VIII Rule 11 / MDCG 2019-11 §3.3 territory).
///
/// **Regulatory anchor:** Plunder P-1; FDA 2019 §III.B.2 foreseeable-
/// misuse reachability for Asha (P4); `.squad/designs/plunder-skin-type-
/// persistence-floor.md` §3 (Pattern B verdict) + §4.4 (🚫/✅ list).
@Test func test_FF2_skinTypeChipLabelsAreRoutedThroughProductCopy() throws {
    #expect(ProductCopy.skinTypeChipUnsetLabel == "Set skin type")
    // The chip-set label is a Roman-numeral-parameterised format.
    // Validate the format for every Fitzpatrick row.
    for type in FitzpatrickSkinType.allCases {
        let rendered = ProductCopy.skinTypeChipSetLabel(for: type)
        #expect(rendered.hasPrefix("Type "), "Chip label must keep 'Type ' prefix: \(rendered)")
        #expect(rendered.contains(type.romanNumeral), "Chip label must include Roman numeral: \(rendered)")
        // Negative: no measurement-like phrasing per Plunder Pattern-B floor.
        // A drift to any of these strings re-classifies the chip from
        // self-declared input to inferred output and reopens the MDR
        // Annex VIII Rule 11 / MDCG 2019-11 §3.3 stake.
        #expect(!rendered.localizedCaseInsensitiveContains("score"))
        #expect(!rendered.localizedCaseInsensitiveContains("risk"))
        #expect(!rendered.localizedCaseInsensitiveContains("phototype"))
        #expect(!rendered.localizedCaseInsensitiveContains("burn rating"))
    }
    // Audit-sieve membership: the unset label and a representative set-state
    // rendering must flow through `auditCopySurfaces`.
    #expect(ProductCopy.auditCopySurfaces.contains(ProductCopy.skinTypeChipUnsetLabel))
    #expect(ProductCopy.auditCopySurfaces.contains(ProductCopy.skinTypeChipSetLabel(for: .typeIII)))
    // Render-site source-text guard.
    let source = try _appViewsSourceForGroupR()
    #expect(source.contains("ProductCopy.skinTypeChipUnsetLabel"))
    #expect(source.contains("ProductCopy.skinTypeChipSetLabel"))
    #expect(!source.contains("\"Set skin type\""))
    // The inline Roman-numeral interpolation is gone too — the only remaining
    // "Type \(...romanNumeral)" pattern must live in ProductCopy.skinTypeChipSetLabel.
    #expect(!source.contains("\"Type \\(\\(.+).romanNumeral)\""))
}

/// FF3 — `disclaimerBody` carries four SaMD-classification anchor
/// phrasings that `requiredSafetyDisclaimerCopyIsCaptured` did not pin.
/// Each is load-bearing per `.squad/designs/plunder-disclaimer-relocation-
/// floor.md` §2.1 rows C/D and the FDA 2019 General Wellness §V.B.2
/// carve-out.
///
/// **Failure mode:** Drift in any of these phrasings re-opens the
/// classification gate (e.g., losing "informational only" weakens the
/// labeling object's wellness-classification anchor; losing "is not
/// prevention guidance" puts us on the wrong side of the disease-
/// prevention exclusion).
@Test func test_FF3_disclaimerBodyPinsPlunderSaMDClassificationAnchors() {
    let body = ProductCopy.disclaimerBody
    // FDA §V.B.2 wellness-classification anchor — the labeling object's
    // SaMD/General-Wellness posture verb.
    #expect(body.localizedCaseInsensitiveContains("informational only"))
    // FDA §V.B.2 disease-prevention carve-out — Plunder explicitly enumerates
    // "is not prevention guidance" (not "is not a prevention guide") as the
    // load-bearing phrasing per the disclaimer-relocation memo §2.1 row C.
    #expect(body.localizedCaseInsensitiveContains("is not prevention guidance"))
    // Wellness-classification escalation phrasing. The substring
    // "dermatologist" is pinned by `requiredSafetyDisclaimerCopyIsCaptured`,
    // but the full clinician-escalation pattern was not — so drift to
    // "see a dermatologist" alone would silently weaken the escalation lane.
    #expect(body.localizedCaseInsensitiveContains("consult a dermatologist or qualified clinician"))
    // FTC §5 individual-applicability hedge — also clause D of
    // `reapplicationFooter` per the disclaimer-relocation memo §2.1 row D.
    #expect(body.localizedCaseInsensitiveContains("skin response varies"))
    // Negative: no clinical-recommendation verbs leak into disclaimerBody itself.
    #expect(!body.localizedCaseInsensitiveContains("we recommend"))
    #expect(!body.localizedCaseInsensitiveContains("prescribed"))
    #expect(!body.localizedCaseInsensitiveContains("guaranteed"))
}

/// FF4 — `reapplicationFooter` carries all four Plunder regulatory clauses
/// (A biological-feedback override, B reapplication-cadence, C SaMD
/// classification anchor, D variance hedge). Clauses A/B/C are pinned
/// piecewise elsewhere; clause D (FTC §5 variance hedge) was not.
///
/// **Source:** `.squad/designs/plunder-disclaimer-relocation-floor.md` §2.1.
@Test func test_FF4_reapplicationFooterCarriesAllFourPlunderRegulatoryClauses() {
    let footer = ProductCopy.reapplicationFooter
    // Clause A — FDA §III.B.2 biological-feedback override.
    #expect(footer.contains("Cover up if skin reddens."))
    // Clause B — FDA 21 CFR §352.52(c)(2) reapplication cadence (mirrors
    // `aboutSunSafetyActions` per Bundle B EE1).
    #expect(footer.contains("Reapply sunscreen at least every 2 hours regardless of timer."))
    // Clause C — SaMD classification anchor (two-sentence form).
    #expect(footer.contains("Informational only."))
    #expect(footer.contains("Not medical advice."))
    // Clause D — FTC §5 individual-applicability variance hedge.
    // Pinning this closes the lane that prior tests left open.
    #expect(footer.contains("Skin response varies."))
}

/// FF5 — `photosensitizationAuthorityLine` keeps the Plunder-ratified
/// cohort-disclosure trigger ("ask a clinician or pharmacist") and the
/// wellness-classification carve-out prefix ("Informational overview:").
///
/// **Regulatory anchor:** GDPR Art.9(2)(a) explicit-consent specificity
/// (EDPB Guidelines 05/2020 §3.2) — the cohort self-identification
/// trigger names a discoverable third-party authority; FDA 2019 §III.B.2
/// foreseeable-misuse reachability for Asha (P4 Accutane cohort).
@Test func test_FF5_photosensitizationAuthorityLinePinsClinicianPharmacistTrigger() {
    let line = ProductCopy.photosensitizationAuthorityLine
    // Wellness-classification carve-out prefix.
    #expect(line.hasPrefix("Informational overview:"))
    // Cohort self-identification trigger naming third-party authority
    // (Plunder-ratified phrasing per the skin-type persistence memo §2.5).
    #expect(line.localizedCaseInsensitiveContains("ask a clinician or pharmacist"))
    // Soft, non-prescriptive framing that avoids the FDA §V.B.2
    // recommendation/prescription verbs.
    #expect(line.localizedCaseInsensitiveContains("some medicines"))
    // Cohort-self-identification cue (the lay-language synonym for the
    // medical term "photosensitivity").
    #expect(line.localizedCaseInsensitiveContains("sun sensitivity"))
    // Negative: no recommendation/prescription verbs.
    #expect(!line.localizedCaseInsensitiveContains("recommended"))
    #expect(!line.localizedCaseInsensitiveContains("prescribed"))
    #expect(!line.localizedCaseInsensitiveContains("we advise"))
}

/// FF6 — Pattern-B re-attestation cadence regulatory-floor pins:
///   (a) `currentDisclaimerPolicyVersion == 1` so any future bump must be
///       a deliberate test-edit (Plunder sign-off, per the source comment
///       on `UVBurnTimerSession.swift`); the Group GD tests use this value
///       parametrically but never assert it equals 1, so a drive-by bump
///       to 2 silently re-fires L1 for every returning user (violating
///       Greta's G-D2 friction-relief promise).
///   (b) `disclaimerStorageLine` render-site source-text guard — the XCUI
///       option (a) from WI-w §3.4 is foreclosed by the 2026-05-21T07:45Z
///       user directive freezing the XCUI smoke set at 9; option (b) Core
///       source-text substitute keeps the L1 GDPR Art.13 fair-processing
///       surface from silently vanishing.
///
/// **Source:** `.squad/designs/plunder-skin-type-persistence-floor.md`
/// §4.1(3); `.squad/orchestration-log/2026-05-21T-plunder-wi-w-l1-storage.md`
/// §3.4.
@Test func test_FF6_patternBRegulatoryFloorPinsCadenceAndStorageLineRender() throws {
    // (a) Cadence pin.
    #expect(UserPreferenceStorage.currentDisclaimerPolicyVersion == 1)
    #expect(UserPreferenceStorage.disclaimerPolicyVersionKey == "disclaimerPolicyVersion")

    // (b) DisclaimerCover render-site source-text guard.
    let source = try _appViewsSourceForGroupR()
    #expect(source.contains("Text(ProductCopy.disclaimerStorageLine)"))
    #expect(source.contains(".accessibilityIdentifier(\"DisclaimerStorageLine\")"))

    // Render-order check: storage line appears AFTER disclaimerBody and
    // BEFORE the see-About button — per WI-w §2.2 placement requirement
    // (consent-relevant prose grouped with disclaimerBody).
    let lines = source.components(separatedBy: "\n")
    let bodyIdx = lines.firstIndex { $0.contains("Text(ProductCopy.disclaimerBody)") }
    let storeIdx = lines.firstIndex { $0.contains("Text(ProductCopy.disclaimerStorageLine)") }
    let aboutIdx = lines.firstIndex {
        $0.contains(".accessibilityIdentifier(\"DisclaimerSeeAboutLink\")")
    }
    #expect(bodyIdx != nil, "DisclaimerCover must render disclaimerBody")
    #expect(storeIdx != nil, "DisclaimerCover must render disclaimerStorageLine")
    #expect(aboutIdx != nil, "DisclaimerCover must carry DisclaimerSeeAboutLink button")
    if let b = bodyIdx, let s = storeIdx, let a = aboutIdx {
        #expect(b < s, "disclaimerStorageLine must follow disclaimerBody (WI-w §2.2)")
        #expect(s < a, "disclaimerStorageLine must precede DisclaimerSeeAboutLink (WI-w §2.2)")
    }
}

// MARK: - Group HH: Loop-12 Bundle H — README truthfulness (Gaia H1+H2+H3)
//
// Three README↔code truth gaps closed by Bundle H. The README is the
// public-surface source of truth for App Store reviewers, external
// auditors, and EU counsel; the Plunder regulatory floor + the
// `D-2026-05-19-honest-privacy-copy` decision both turn on the README
// being literally true about what is stored and how the disclaimer fires.
//
// HH1 — Scenario 1 must describe Pattern-B (policyVersion-gated) cadence,
//       not the retired "every app session" cold-launch model. Pattern B
//       was ratified in Loop-9 (`.squad/decisions.md:10–43`) and is now
//       pinned by `UserPreferenceStorage.shouldShowDisclaimerCover` +
//       Group GD contract family (BurnTimeCalculatorTests.swift line ~1964).
// HH2 — Privacy line must not claim `location-rationale acknowledgment`
//       persists. The `locationRationaleAcknowledgedKey` is declared in
//       `UVBurnTimerSession.swift` but no production code writes it after
//       Kwame-8 dropped the LocationRationaleCard. Cross-pinned to source.
// HH3 — README user-scenarios must list the WI-7 10-day forecast picker —
//       the largest post-launch feature; omission breaks the
//       README ↔ loop.md Goal 3 ("User scenarios captured") contract.

private func _readmeContents() throws -> String {
    let repoRoot = try appRootURL().deletingLastPathComponent()
    let url = repoRoot.appendingPathComponent("README.md")
    return try String(contentsOf: url, encoding: .utf8)
}

/// HH1 — README Scenario 1 must describe Pattern-B (policyVersion-gated)
/// cadence, not the retired "every app session" cold-launch model.
@Test func test_HH1_readmeScenario1DescribesPolicyVersionedL1() throws {
    let readme = try _readmeContents()
    #expect(
        !readme.contains("required disclaimer every app session"),
        "README Scenario 1 must not claim L1 fires every app session — Pattern B (policyVersion-gated) shipped Loop-9; see GD1–GD4."
    )
    #expect(
        readme.localizedCaseInsensitiveContains("policyversion")
            || readme.localizedCaseInsensitiveContains("policy version"),
        "README Scenario 1 must reference the policyVersion mechanism that actually gates L1."
    )
}

/// HH2 — README must not claim `location-rationale acknowledgment`
/// persists in UserDefaults: no production code writes that key after
/// Kwame-8 dropped the LocationRationaleCard.
@Test func test_HH2_readmePrivacyDoesNotClaimDeadStoragePersistence() throws {
    let readme = try _readmeContents()
    #expect(
        !readme.contains("location-rationale acknowledgment"),
        "README Privacy line must not claim location-rationale acknowledgment persists — the LocationRationaleCard was retired (Kwame-8) and no production code writes `locationRationaleAcknowledged`."
    )
    let repoRoot = try appRootURL().deletingLastPathComponent()
    let appSwift = try String(
        contentsOf: repoRoot.appendingPathComponent("app/Sources/UVBurnTimer/AppViews.swift"),
        encoding: .utf8
    )
    let coreSwift = try String(
        contentsOf: repoRoot.appendingPathComponent("app/Sources/UVBurnTimerCore/UVBurnTimerSession.swift"),
        encoding: .utf8
    )
    let writePatterns = [
        ".set(true, forKey: UserPreferenceStorage.locationRationaleAcknowledgedKey",
        "defaults.set(true, forKey: locationRationaleAcknowledgedKey",
        "@AppStorage(UserPreferenceStorage.locationRationaleAcknowledgedKey)",
    ]
    for pattern in writePatterns {
        #expect(
            !appSwift.contains(pattern) && !coreSwift.contains(pattern),
            "Production code now writes `locationRationaleAcknowledgedKey` — either restore the README claim or this guard is wrong."
        )
    }
}

/// HH3 — README must list the WI-7 forecast picker as a shipped user
/// scenario. The picker is the largest post-launch feature and its
/// absence from public surface is a documented-behavior gap.
@Test func test_HH3_readmeListsForecastPickerScenario() throws {
    let readme = try _readmeContents()
    let tokens = ["forecast", "10-day", "hourly", "WHO"]
    let presentCount = tokens.filter { readme.localizedCaseInsensitiveContains($0) }.count
    #expect(
        presentCount >= 2,
        "README must describe the shipped forecast picker (≥ 2 of: forecast, 10-day, hourly, WHO). Current matches: \(presentCount)."
    )
}


// MARK: - Group LL: Loop-12 Bundle L — persona render-site + a11y header safety guards
//
// Bundle L converges Loop-12 HIGH-priority parallel gap-analysis findings
// (Iris, Suchi, Ma-Ti — claude-opus-4.7-xhigh) that share the property
// "the implementation is correct on main today, but a refactor could
// silently break a load-bearing persona safety surface and every
// existing test would still pass." Each LL test is a source-text or
// audit-membership guard pinning a load-bearing render site.
//
//   LL1  Suchi P1 Greta — RootView .safeAreaInset(.bottom) hosts PersistentFooter
//   LL2  Suchi P2 Maya  — NowViewScrollView carries .nowViewRefreshable { await refreshUV() }
//   LL3  Suchi P5 Tomás — RootView carries .sensoryFeedback(.warning, trigger: isEstimateStale)
//                         AND the fetch-completed .success sibling stays bound to uvIndex
//   LL4  Ma-Ti — BurnRiskGaugeCard render-site existence guard (ADR-0001 pattern)
//                + BurnRiskGauge a11y identifier stability
//   LL5  Iris IR1 — SkinTypePickerList header .accessibilityAddTraits(.isHeader)
//                   + accessibilityIdentifier("SkinTypePickerPromptHeader")
//   LL6  Iris IR9 — UVIndexCard + UVIndexPlaceholderCard "UV Index" titles
//                   carry .accessibilityAddTraits(.isHeader)
//   LL7  Iris IR10 — ForecastPickerView "UV Forecast" + "Hourly" section
//                    titles carry .accessibilityAddTraits(.isHeader)
//   LL8  Ma-Ti GAP-4 — ProductCopy.weatherAttributionLegalURLString is
//                      registered in auditCopySurfaces (the rendered string
//                      must be subject to the monetization-drift and
//                      banned-clinical-claim sieves alongside its sibling
//                      weatherAttributionServiceName).
//   LL9  Ma-Ti GAP-5 — DisclaimerCover renders the three see-About inline
//                      fragments (lead + linkLabel + tail) as separate Text
//                      nodes inside the Button label, and the composed
//                      prompt round-trips to the audited
//                      disclaimerSeeAboutInlinePrompt constant.

/// LL1 — Suchi P1 Greta — RootView .safeAreaInset(.bottom) hosts PersistentFooter.
///
/// **Why this guard matters:** LANE 4 row 1 ★ of the user flow names the
/// L2 footer as Greta's "primary reading on repeating use" and the
/// Plunder C1 SaMD `Informational only. Not medical advice.` anchor. The
/// `disclaimerLinkLabel` string itself is pinned (N4 + Bundle B EE6),
/// but no existing test asserts that `PersistentFooter()` is actually
/// **invoked** inside `RootView.body`'s `.safeAreaInset(edge: .bottom)`
/// closure. A refactor that deletes the call site silently retires
/// Greta's only persistent surface and the Plunder C1 render-site.
@Test func test_LL1_persistentFooterIsHostedInRootViewBottomSafeAreaInset() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains(".safeAreaInset(edge: .bottom)"),
        "RootView must keep `.safeAreaInset(edge: .bottom)` — Greta's L2 footer host (LANE 4 row 1) and the Plunder C1 SaMD anchor render-site."
    )
    #expect(
        source.contains("PersistentFooter()"),
        "RootView .safeAreaInset(.bottom) must invoke `PersistentFooter()` — Greta's primary reading on repeating use + Plunder C1 'Informational only. Not medical advice.' render-site (suchi-l12a / LL1)."
    )

    // Render-order check: PersistentFooter() must appear inside the
    // .safeAreaInset(edge: .bottom) closure body, not as a stray reference
    // elsewhere (e.g., in a comment block).
    let lines = source.components(separatedBy: "\n")
    let insetIdx = lines.firstIndex { $0.contains(".safeAreaInset(edge: .bottom)") }
    let footerIdx = lines.firstIndex { $0.contains("PersistentFooter()") }
    #expect(insetIdx != nil, "RootView must declare .safeAreaInset(edge: .bottom)")
    #expect(footerIdx != nil, "RootView must invoke PersistentFooter()")
    if let i = insetIdx, let f = footerIdx {
        #expect(i < f, "PersistentFooter() must be invoked inside the .safeAreaInset(edge: .bottom) closure body (line below the opener) — LL1.")
        #expect(f - i < 12, "PersistentFooter() must be within ~12 lines of .safeAreaInset(edge: .bottom) so the footer host binding is direct, not lost across an unrelated view tree (LL1).")
    }
}

/// LL2 — Suchi P2 Maya — `NowViewScrollView` carries `.nowViewRefreshable`
/// bound to `await refreshUV()`.
///
/// **Why this guard matters:** LANE 4 row 2 ★ names pull-to-refresh as
/// Maya's "primary affordance on repeating use" (wet-handed mid-swim, the
/// only re-fetch path). WI-47/WI-50 wired the modifier and the
/// `UITestRefreshableProbeButton` two-signal probe, but no test asserts
/// the modifier site itself. A refactor that drops the modifier or
/// re-homes it to an unreachable view silently retires Maya's only
/// re-fetch path while leaving the probe + machinery intact.
@Test func test_LL2_nowViewScrollViewCarriesRefreshableBoundToRefreshUV() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains(".accessibilityIdentifier(\"NowViewScrollView\")"),
        "RootView must keep `.accessibilityIdentifier(\"NowViewScrollView\")` on the main ScrollView — Maya pull-to-refresh probe target (LL2)."
    )
    #expect(
        source.contains(".nowViewRefreshable {"),
        "RootView ScrollView must keep `.nowViewRefreshable { ... }` — Maya's primary affordance per LANE 4 row 2 (suchi-l12b / LL2). Dropping this modifier silently retires the only re-fetch path she has mid-swim."
    )
    #expect(
        source.contains("await refreshUV()"),
        "RootView `.nowViewRefreshable` closure must still invoke `await refreshUV()` — the closure-body half of the WI-50 two-signal probe (LL2)."
    )

    // Bind the modifier to the NowViewScrollView identifier: the
    // .nowViewRefreshable line must appear within a small window of the
    // .accessibilityIdentifier("NowViewScrollView") line so a refactor
    // that re-homes the modifier to a different view fails the guard.
    let lines = source.components(separatedBy: "\n")
    let idIdx = lines.firstIndex { $0.contains(".accessibilityIdentifier(\"NowViewScrollView\")") }
    let refreshableIdx = lines.firstIndex { $0.contains(".nowViewRefreshable {") }
    #expect(idIdx != nil, "RootView ScrollView must carry the NowViewScrollView identifier (LL2).")
    #expect(refreshableIdx != nil, "RootView must declare .nowViewRefreshable on the main ScrollView (LL2).")
    if let i = idIdx, let r = refreshableIdx {
        let delta = abs(i - r)
        #expect(delta < 4, "`.nowViewRefreshable` must be modifier-stacked within a few lines of `.accessibilityIdentifier(\"NowViewScrollView\")` so the modifier stays bound to the probe-target ScrollView (LL2). Observed delta=\(delta).")
    }
}

/// LL3 — Suchi P5 Tomás — RootView carries the window-elapsed warning
/// haptic AND the fetch-completed success haptic.
///
/// **Why this guard matters:** LANE 4 row 5 ★ names `.sensoryFeedback(.warning,
/// trigger: isEstimateStale)` as Tomás's safety moment — he dismissed L1
/// in 2 seconds, his phone is in his arm pocket at mile 8, and the
/// warning haptic is the one signal that reaches him without a glance at
/// the screen. BB2 guards the **visual** SafetyStatusCard wiring inside
/// HeroTimerCard, but the haptic is bound at `RootView.body` and is
/// untested. The `.success` sibling on `uvIndex` change is what confirms
/// his fetch tap (persona-annotations Screen 5 location prompt) and
/// would naturally be dropped alongside in a "remove all sensoryFeedback"
/// refactor.
@Test func test_LL3_rootViewCarriesWarningAndSuccessSensoryFeedback() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains(".sensoryFeedback(.warning, trigger: isEstimateStale)"),
        "RootView must keep `.sensoryFeedback(.warning, trigger: isEstimateStale)` — Tomás's window-elapsed warning haptic is the half of his safety moment that reaches him without looking at the screen (LANE 4 row 5; suchi-persona-annotations.md Screen 5+ + Branch 5). BB2 only guards the visual SafetyStatusCard (suchi-l12c / LL3)."
    )
    #expect(
        source.contains(".sensoryFeedback(.success, trigger: uvIndex)"),
        "RootView must keep `.sensoryFeedback(.success, trigger: uvIndex)` so the warning haptic's sibling fetch-completed signal — Tomás's primary tap-registered confirmation per persona-annotations.md Screen 5 location-prompt — is not silently removed alongside (LL3)."
    )
}

/// LL4 — Ma-Ti — `BurnRiskGaugeCard` render-site existence guard (ADR-0001
/// pattern) + `BurnRiskGauge` accessibility-identifier stability.
///
/// **Why this guard matters:** `BurnRiskGaugeCard` is the dominant visual
/// surface in the hero region (post `9da54cf` chrome-less hero, per Group
/// AA). It is invoked by `HeroTimerCard.burnRiskGauge` and carries the
/// `accessibilityIdentifier("BurnRiskGauge")` that XCUI smoke + a11y
/// audits depend on. The hero card itself is guarded (R1), but the gauge
/// card has no source-text existence guard — an inliner refactor would
/// silently retire the standalone struct and the a11y identifier in one
/// motion (same failure mode ADR-0001 documents for HeroTimerCard).
@Test func test_LL4_burnRiskGaugeCardStructAndIdentifierAreRenderSiteLocked() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains("struct BurnRiskGaugeCard: View"),
        "`BurnRiskGaugeCard` must remain a standalone View struct (ADR-0001 pattern: inlining the hero region's load-bearing surfaces caused the XCUI testSettingsSheetOpens regression). suchi-l12 + mati-G2 / LL4."
    )
    #expect(
        source.contains("BurnRiskGaugeCard(estimate: estimate, fetchedAt: fetchedAt, now: now)"),
        "`HeroTimerCard.burnRiskGauge` must invoke `BurnRiskGaugeCard(estimate:fetchedAt:now:)` with the canonical argument list — render-site lock for the gauge surface (LL4)."
    )
    #expect(
        source.contains(".accessibilityIdentifier(\"BurnRiskGauge\")"),
        "`BurnRiskGaugeCard.gauge` must keep `.accessibilityIdentifier(\"BurnRiskGauge\")` — XCUI smoke + Iris contrast-QA checklist row pinning depend on this identifier (LL4)."
    )
}

/// LL5 — Iris IR1 — `SkinTypePickerList` section header carries
/// `.accessibilityAddTraits(.isHeader)` and a stable accessibility
/// identifier.
///
/// **Why this guard matters:** Suchi's persona spec names the
/// `skinTypePickerPrompt` ("Pick the row that best matches what your
/// skin does, not what color it is.") as load-bearing for Maya (SE Asia,
/// Fitz III) — without it she risks Eurocentric "Type IV = olive
/// Mediterranean" mis-mapping. SwiftUI does not auto-apply `.isHeader`
/// to custom Section header content, so VoiceOver rotor "Headings"
/// navigation skipped it entirely until this guard was added.
@Test func test_LL5_skinTypePickerPromptHeaderCarriesHeaderTraitAndIdentifier() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let promptIdx = lines.firstIndex(where: { $0.contains("Text(ProductCopy.skinTypePickerPrompt)") }) else {
        Issue.record("SkinTypePickerList must render Text(ProductCopy.skinTypePickerPrompt) (LL5)")
        return
    }
    // The header trait + identifier modifiers must appear within a small
    // window of the Text declaration (the modifier-chain depth allowed for
    // .textCase + .font + .accessibilityAddTraits + .accessibilityIdentifier).
    let modifierWindow = lines[promptIdx..<min(promptIdx + 8, lines.count)].joined(separator: "\n")
    #expect(
        modifierWindow.contains(".accessibilityAddTraits(.isHeader)"),
        "`Text(ProductCopy.skinTypePickerPrompt)` must carry `.accessibilityAddTraits(.isHeader)` — VoiceOver rotor 'Headings' navigation depends on it, and the prompt is load-bearing for Maya (LANE 4 row 2 — Eurocentric mis-mapping protection). iris-IR1 / LL5."
    )
    #expect(
        modifierWindow.contains(".accessibilityIdentifier(\"SkinTypePickerPromptHeader\")"),
        "`Text(ProductCopy.skinTypePickerPrompt)` must carry `.accessibilityIdentifier(\"SkinTypePickerPromptHeader\")` so XCUI rotor walkthrough and future a11y audits can locate the prompt header (LL5)."
    )
}

/// LL6 — Iris IR9 — `UVIndexCard` + `UVIndexPlaceholderCard` "UV Index"
/// titles carry `.accessibilityAddTraits(.isHeader)`.
///
/// **Why this guard matters:** The secondary UV card sits below the hero
/// region in the main scroll view. Without the header trait, VoiceOver
/// rotor "Headings" navigation jumps from the hero card straight to the
/// forecast picker, skipping the UV value entirely. Persona impact: Maya
/// (mid-swim pull-to-refresh, must rotor-jump back to the UV Index card
/// to check the latest fetched value).
@Test func test_LL6_uvIndexCardTitlesCarryHeaderTrait() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")

    // UVIndexCard — the live title that interpolates uvIndex.
    guard let liveIdx = lines.firstIndex(where: { $0.contains(#"Text("UV Index \(uvIndex"#) }) else {
        Issue.record("UVIndexCard must render the live 'UV Index <value>' Text (LL6)")
        return
    }
    let liveWindow = lines[liveIdx..<min(liveIdx + 4, lines.count)].joined(separator: "\n")
    #expect(
        liveWindow.contains(".accessibilityAddTraits(.isHeader)"),
        "`UVIndexCard` live title must carry `.accessibilityAddTraits(.isHeader)` — VoiceOver rotor 'Headings' must include the UV Index card so Maya can jump to the latest fetched value (iris-IR9 / LL6)."
    )

    // UVIndexPlaceholderCard — the empty-state placeholder title.
    guard let placeholderIdx = lines.firstIndex(where: { $0.contains(#"Text("UV Index")"#) }) else {
        Issue.record("UVIndexPlaceholderCard must render the placeholder 'UV Index' Text (LL6)")
        return
    }
    let placeholderWindow = lines[placeholderIdx..<min(placeholderIdx + 4, lines.count)].joined(separator: "\n")
    #expect(
        placeholderWindow.contains(".accessibilityAddTraits(.isHeader)"),
        "`UVIndexPlaceholderCard` placeholder title must carry `.accessibilityAddTraits(.isHeader)` — same rationale as the live title; placeholder must remain rotor-discoverable (LL6)."
    )
}

/// LL7 — Iris IR10 — `ForecastPickerView` "UV Forecast" + "Hourly" section
/// titles carry `.accessibilityAddTraits(.isHeader)`.
///
/// **Why this guard matters:** The Forecast picker card is its own
/// result surface (selecting a future hour drives the burn-time gauge
/// for that hour). Without header traits on the picker card title + the
/// hourly strip section header, VoiceOver rotor "Headings" navigation
/// skips the entire forecast block. Persona impact: every rotor-using
/// VoiceOver user navigating the main scroll view.
@Test func test_LL7_forecastPickerSectionTitlesCarryHeaderTrait() throws {
    let source = try _forecastPickerSourceForGroupR()
    let lines = source.components(separatedBy: "\n")

    guard let forecastIdx = lines.firstIndex(where: { $0.contains(#"Text("UV Forecast")"#) }) else {
        Issue.record("ForecastPickerView must render the 'UV Forecast' headerLabel Text (LL7)")
        return
    }
    let forecastWindow = lines[forecastIdx..<min(forecastIdx + 5, lines.count)].joined(separator: "\n")
    #expect(
        forecastWindow.contains(".accessibilityAddTraits(.isHeader)"),
        "`ForecastPickerView.headerLabel` must carry `.accessibilityAddTraits(.isHeader)` — VoiceOver rotor 'Headings' must include the forecast card title (iris-IR10 / LL7)."
    )

    guard let hourlyIdx = lines.firstIndex(where: { $0.contains(#"Text("Hourly")"#) }) else {
        Issue.record("ForecastPickerView must render the 'Hourly' hourlyStripSection header Text (LL7)")
        return
    }
    let hourlyWindow = lines[hourlyIdx..<min(hourlyIdx + 6, lines.count)].joined(separator: "\n")
    #expect(
        hourlyWindow.contains(".accessibilityAddTraits(.isHeader)"),
        "`ForecastPickerView.hourlyStripSection` 'Hourly' title must carry `.accessibilityAddTraits(.isHeader)` — the hourly strip is the inner sub-section of the forecast picker; without the trait the rotor jump lands on the day-list and the hourly grid is invisible to rotor users (LL7)."
    )
}

/// LL8 — Ma-Ti GAP-4 — `ProductCopy.weatherAttributionLegalURLString`
/// must be enrolled in `auditCopySurfaces`.
///
/// **Why this guard matters:** The string is rendered as `Text(...)` at
/// two render sites (one in `WeatherAttributionView` body + one in
/// `AttributionView` Settings sheet). Its sibling
/// `weatherAttributionServiceName` is audit-enrolled; the URL string is
/// not. Without enrolment, the monetization-drift sieve and banned-
/// clinical-claim guard cannot apply to it — and any future edit that
/// redirected the URL to an affiliate / non-WeatherKit page would pass
/// CI silently (same defect class Bundle A closed for
/// `cacheRetentionLine` / `aboutPrivacy`).
@Test func test_LL8_weatherAttributionLegalURLStringIsAuditEnrolled() {
    #expect(
        ProductCopy.auditCopySurfaces.contains(ProductCopy.weatherAttributionLegalURLString),
        "`ProductCopy.weatherAttributionLegalURLString` must be enrolled in `auditCopySurfaces` — the rendered legal-URL string is subject to the same monetization-drift and banned-clinical-claim sieves as its sibling `weatherAttributionServiceName` (mati-GAP-4 / LL8)."
    )
}

/// LL9 — Ma-Ti GAP-5 — `DisclaimerCover` see-About Button renders the three
/// inline fragments (lead + linkLabel + tail) as separate Text nodes, and
/// the composed prompt round-trips to the audit-enrolled
/// `disclaimerSeeAboutInlinePrompt` constant.
///
/// **Why this guard matters:** The three-fragment Button styling was
/// introduced because iOS 17/18 Markdown a11y diverged (see
/// `ProductCopy.swift:62-79`). Render-site truth lives in the fragments,
/// not the composed prompt. Without a render-site source-text guard on
/// the three Text nodes, a styled-Button refactor that drops one
/// fragment (e.g., the tail period) would pass `composition == prompt`
/// equality if the constants themselves were edited together, but would
/// silently change DisclaimerCover output for Asha (P4 Accutane).
@Test func test_LL9_disclaimerSeeAboutInlineFragmentsAreRenderedAsThreeTextNodes() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains("Text(ProductCopy.disclaimerSeeAboutInlineLead)"),
        "DisclaimerCover Button label must render `Text(ProductCopy.disclaimerSeeAboutInlineLead)` — first of the three audit-stable fragments (mati-GAP-5 / LL9)."
    )
    #expect(
        source.contains("Text(ProductCopy.disclaimerSeeAboutInlineLinkLabel)"),
        "DisclaimerCover Button label must render `Text(ProductCopy.disclaimerSeeAboutInlineLinkLabel)` — the styled 'see About' span (LL9)."
    )
    #expect(
        source.contains("Text(ProductCopy.disclaimerSeeAboutInlineTail)"),
        "DisclaimerCover Button label must render `Text(ProductCopy.disclaimerSeeAboutInlineTail)` — completes the three-segment composition (LL9)."
    )

    // Round-trip: the three fragments composed in order must equal the
    // audit-enrolled disclaimerSeeAboutInlinePrompt constant.
    let composed = ProductCopy.disclaimerSeeAboutInlineLead
        + ProductCopy.disclaimerSeeAboutInlineLinkLabel
        + ProductCopy.disclaimerSeeAboutInlineTail
    #expect(
        composed == ProductCopy.disclaimerSeeAboutInlinePrompt,
        "The three rendered DisclaimerCover Button fragments must concatenate to `disclaimerSeeAboutInlinePrompt`; a drift between fragments and prompt would silently change Asha's L1 cohort-self-identification path (LL9)."
    )
    #expect(
        ProductCopy.auditCopySurfaces.contains(ProductCopy.disclaimerSeeAboutInlinePrompt),
        "The composed prompt must remain enrolled in `auditCopySurfaces` so the monetization-drift sieve applies (LL9)."
    )
}


// MARK: - Group CC: Loop-11 Bundle A — persona safety + a11y critical
//
// Bundle A converges seven WIs that all hit ProductCopy or AppViews and that
// all carry persona-load-bearing safety, accessibility, or factual-truth
// stakes:
//
//   WI-suchi-d  Asha L1 DisclaimerSeeAboutLink Button render-site guard (CC1–CC4)
//   WI-iris-a   DisclaimerCover warning glyph hidden from VoiceOver       (CC5)
//   WI-iris-b   HeroTimerCard sun.max + moon.fill decorative-icon a11y    (CC6, CC7)
//   WI-iris-c   cacheRetentionLine + aboutPrivacy Pattern-B truth fix     (CC8 — see
//                                                                          existing
//                                                                          required-disclaimer-copy
//                                                                          + about-privacy
//                                                                          tests above;
//                                                                          CC8 pins the two
//                                                                          surfaces stay in
//                                                                          sync with each
//                                                                          other)
//   WI-iris-d   UVI=0 copy convergence on `noUVAtThisHourLabel`           (CC9–CC11)
//   WI-mati-1   aboutSunSafetyActions registered in auditCopySurfaces     (CC12)

/// CC1 — DisclaimerCover Button retains the persona-load-bearing
/// `DisclaimerSeeAboutLink` accessibility identifier at the rendering site.
/// Without the identifier XCUI cannot find the Button, and Suchi's P4 Asha
/// (Accutane) JTBD ("read the L1 prompt → tap inline see-About → read the
/// applicability anchor → return → I understand") loses its tap surface
/// guarantee.
@Test func test_CC1_disclaimerSeeAboutLinkIdentifierIsAtRenderSite() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains(#".accessibilityIdentifier("DisclaimerSeeAboutLink")"#),
        "DisclaimerCover must expose accessibilityIdentifier(\"DisclaimerSeeAboutLink\") so XCUI and Asha (P4 Accutane) can find the inline see-About reach-back Button. See suchi-persona-annotations.md Screen 1 — Asha row."
    )
}

/// CC2 — DisclaimerCover Button carries the `.isLink` a11y trait so
/// VoiceOver announces it as a link, not a plain button.
@Test func test_CC2_disclaimerSeeAboutLinkExposesLinkTrait() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains(".accessibilityAddTraits(.isLink)"),
        "DisclaimerCover's see-About Button must `.accessibilityAddTraits(.isLink)` so VoiceOver users hear it as a link affordance, matching Plunder's body-prose intent and Suchi's Asha screen-reader flow."
    )
}

/// CC3 — DisclaimerCover Button composes the prompt from the three
/// audit-stable Text segments (lead + label + tail). If any of the three
/// constants is dropped from the render site the prompt stops being
/// substring-stable for copy audits.
@Test func test_CC3_disclaimerSeeAboutLinkRendersAllThreeProductCopySegments() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains("ProductCopy.disclaimerSeeAboutInlineLead"),
        "DisclaimerCover Button label must reference ProductCopy.disclaimerSeeAboutInlineLead — keeps the prompt copy audit-stable."
    )
    #expect(
        source.contains("ProductCopy.disclaimerSeeAboutInlineLinkLabel"),
        "DisclaimerCover Button label must reference ProductCopy.disclaimerSeeAboutInlineLinkLabel — pins the 'see About' link span."
    )
    #expect(
        source.contains("ProductCopy.disclaimerSeeAboutInlineTail"),
        "DisclaimerCover Button label must reference ProductCopy.disclaimerSeeAboutInlineTail — completes the three-segment composition."
    )
}

/// CC4 — DisclaimerCover Button carries the accessibilityLabel built from
/// the plain-text `disclaimerSeeAboutInlinePrompt`, so VoiceOver reads the
/// full cohort sentence rather than the styled three-segment concatenation
/// (whose mid-segment underline would otherwise be announced).
@Test func test_CC4_disclaimerSeeAboutLinkAccessibilityLabelUsesPlainTextPrompt() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains(".accessibilityLabel(ProductCopy.disclaimerSeeAboutInlinePrompt)"),
        "DisclaimerCover Button must use ProductCopy.disclaimerSeeAboutInlinePrompt as its accessibilityLabel — VoiceOver hears the full cohort sentence as a single continuous read-out, not the three styled segments."
    )
}

/// CC5 — WI-iris-a: DisclaimerCover's decorative warning glyph carries
/// `.accessibilityHidden(true)` so Asha (P4 Accutane) hears the disclaimer
/// title first, not "Exclamation mark, triangle, fill, Image".
@Test func test_CC5_disclaimerCoverWarningIconIsAccessibilityHidden() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let iconLineIdx = lines.firstIndex(where: { $0.contains(#"Image(systemName: "exclamationmark.triangle.fill")"#) }) else {
        Issue.record("DisclaimerCover warning glyph not found")
        return
    }
    // The .accessibilityHidden(true) modifier must appear within 6 lines of
    // the Image declaration (which is the modifier chain depth allowed for
    // .font + .foregroundStyle + .accessibilityHidden).
    let modifierWindow = lines[iconLineIdx..<min(iconLineIdx + 7, lines.count)].joined(separator: "\n")
    #expect(
        modifierWindow.contains(".accessibilityHidden(true)"),
        "DisclaimerCover's exclamationmark.triangle.fill Image must carry .accessibilityHidden(true) — the warning glyph is decorative reinforcement; the load-bearing semantic is in `disclaimerTitle`. Without the modifier VoiceOver reads the SF Symbol's auto-generated label before the disclaimer title (Asha P4 flow)."
    )
}

/// CC6 — WI-iris-b: HeroTimerCard's empty-state sun.max glyph carries
/// `.accessibilityHidden(true)` so screen-reader users do not hear the
/// SF Symbol's auto-generated label before the status message.
@Test func test_CC6_heroTimerCardSunMaxIconIsAccessibilityHidden() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let iconLineIdx = lines.firstIndex(where: { $0.contains(#"Image(systemName: "sun.max")"#) }) else {
        Issue.record("HeroTimerCard sun.max glyph not found")
        return
    }
    let modifierWindow = lines[iconLineIdx..<min(iconLineIdx + 7, lines.count)].joined(separator: "\n")
    #expect(
        modifierWindow.contains(".accessibilityHidden(true)"),
        "HeroTimerCard's sun.max empty-state Image must carry .accessibilityHidden(true) — the icon is decorative; the actual semantic payload is the status message. Without the modifier the .accessibilityElement(children: .contain) container leaks the SF Symbol's auto-generated label."
    )
}

/// CC7 — WI-iris-b sibling: HeroTimerCard's UVI=0 moon.fill glyph also
/// carries `.accessibilityHidden(true)` — same reasoning, different branch.
@Test func test_CC7_heroTimerCardMoonFillIconIsAccessibilityHidden() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let iconLineIdx = lines.firstIndex(where: { $0.contains(#"Image(systemName: "moon.fill")"#) }) else {
        Issue.record("HeroTimerCard moon.fill glyph not found")
        return
    }
    let modifierWindow = lines[iconLineIdx..<min(iconLineIdx + 7, lines.count)].joined(separator: "\n")
    #expect(
        modifierWindow.contains(".accessibilityHidden(true)"),
        "HeroTimerCard's UVI=0 moon.fill Image must carry .accessibilityHidden(true) — the .accessibilityLabel(noUVAtThisHourAccessibilityLabel) on the parent Label is the load-bearing read-out."
    )
}

/// CC8 — WI-iris-c sibling: cacheRetentionLine and aboutPrivacy now both
/// name the disclaimer-version persistence consistently. If one drifts but
/// not the other, GDPR copy lanes desync.
@Test func test_CC8_cacheRetentionAndAboutPrivacyAgreeOnDisclaimerVersionPersistence() {
    let cache = ProductCopy.cacheRetentionLine
    let about = ProductCopy.aboutPrivacy

    #expect(cache.localizedCaseInsensitiveContains("version of the informational disclaimer"))
    #expect(about.localizedCaseInsensitiveContains("version of the informational disclaimer"))
    #expect(!cache.localizedCaseInsensitiveContains("disclaimer acknowledgments"))
    #expect(!about.localizedCaseInsensitiveContains("disclaimer acknowledgments are not retained"))
}

/// CC9 — WI-iris-d: `ProductCopy.noUVAtThisHourLabel` is the single source
/// of truth for the UVI=0 copy. The constant must read exactly "No UV at
/// this hour" so polarized-OLED + Dynamic Type rows in
/// `iris-contrast-qa-checklist.md` and `iris-launch-readiness-checklist.md`
/// can pin the rendered string.
@Test func test_CC9_noUVAtThisHourLabelIsSingleSourceOfTruth() {
    #expect(ProductCopy.noUVAtThisHourLabel == "No UV at this hour")
    #expect(ProductCopy.noUVAtThisHourAccessibilityLabel == "No UV at this hour. No burn risk.")
}

/// CC10 — WI-iris-d: `AppViews.swift` references the new constant from all
/// three render sites and does NOT carry the retired alternate phrasings.
@Test func test_CC10_uvZeroCopyConvergedOnSingleConstantAcrossThreeRenderSites() throws {
    let source = try _appViewsSourceForGroupR()
    let referencesCount = source.components(separatedBy: "ProductCopy.noUVAtThisHourLabel").count - 1
    #expect(
        referencesCount >= 2,
        "AppViews.swift must reference ProductCopy.noUVAtThisHourLabel at least twice (TierBadge.title + heroContent UVI=0 branch + burnRiskGaugeUnavailableMessage UVI=0 branch). Found: \(referencesCount). WI-iris-d collapses the trio onto one constant."
    )
    #expect(
        !source.contains(#""No UV detected""#),
        "AppViews.swift must not carry the retired 'No UV detected' literal — WI-iris-d collapsed all three UVI=0 surfaces onto ProductCopy.noUVAtThisHourLabel."
    )
    #expect(
        !source.contains(#""No active burn time because the UV index is 0.""#),
        "AppViews.swift must not carry the retired 'No active burn time because the UV index is 0.' literal — collapsed onto noUVAtThisHourLabel."
    )
    #expect(
        !source.contains(#"Text("No UV at this hour")"#),
        "AppViews.swift must not carry the literal `Text(\"No UV at this hour\")` — it must reference `ProductCopy.noUVAtThisHourLabel` so the copy stays auditable and audit-surface-stable."
    )
}

/// CC11 — WI-iris-d: the new constants are registered in
/// `auditCopySurfaces` so the monetization-drift sieve and the banned-
/// clinical-claim guard apply to them too.
@Test func test_CC11_noUVCopyConstantsAreRegisteredInAuditCopySurfaces() {
    #expect(ProductCopy.auditCopySurfaces.contains(ProductCopy.noUVAtThisHourLabel))
    #expect(ProductCopy.auditCopySurfaces.contains(ProductCopy.noUVAtThisHourAccessibilityLabel))
}

/// CC12 — WI-mati-1: `aboutSunSafetyActions` (Plunder C2(i)+C2(ii)
/// reapplication-cadence guidance, rendered in AboutView at the
/// notForMeAnchor) was missing from `auditCopySurfaces`. Membership is the
/// audit contract — the monetization-drift and banned-clinical-claim
/// guards must apply to it.
@Test func test_CC12_aboutSunSafetyActionsIsRegisteredInAuditCopySurfaces() {
    #expect(ProductCopy.auditCopySurfaces.contains(ProductCopy.aboutSunSafetyActions))
}

// MARK: - Group JJ: Loop-12 Bundle J — Iris VoiceOver hygiene (5 MEDIUM + 1 LOW + 1 HIGH)
//
// Closes six SF-Symbol auto-label leaks and the AboutView H2 duplication
// surfaced by the Loop-12 Iris gap-analysis pass (claude-opus-4.7-xhigh).
//
// Every `Label(_:systemImage:)` Apple SwiftUI construct that hosts a
// control or Plunder-load-bearing prose reads the icon's auto-generated
// label ("Info, circle, Image", "Sun, dust, Image", …) ahead of the
// semantic text unless an explicit `.accessibilityLabel(...)` overrides
// it. The shipped main-screen surfaces that previously leaked were:
// `spfChip`, `primaryAction`, `PersistentFooter`, `HeroForecastDateContext`,
// `DisclaimerCover` photosensitizer + children Labels.
//
// Separately, IRIS-L12-H2: `AboutView` rendered two competing H1
// headings — in-body `Text("About & Citations")` with `.title.bold()` +
// `.accessibilityAddTraits(.isHeader)` AND `.navigationTitle("About")`.
// VoiceOver rotor → Headings listed both with disagreeing wording.
// Fix: rename `.navigationTitle` to match the in-body title, then drop
// the in-body Text so a single H1 (the nav title) remains.

/// JJ1 — `spfChip` Menu carries `.accessibilityLabel("SPF \(displayName)")`
/// so the `sun.dust` icon's auto-label does NOT prefix every read.
@Test func test_JJ1_spfChipAccessibilityLabelOverridesIconAutoLabel() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let chipStart = lines.firstIndex(where: { $0.contains("private var spfChip: some View {") }) else {
        Issue.record("spfChip not found")
        return
    }
    let chipEnd: Int = lines[(chipStart + 1)...].firstIndex(where: { $0.contains("private var ") || $0.contains("private func ") }) ?? lines.endIndex
    let body = lines[chipStart..<chipEnd].joined(separator: "\n")
    #expect(
        body.contains(".accessibilityLabel(\"SPF \\(session.selectedSPF.displayName)\")"),
        "spfChip must carry `.accessibilityLabel(\"SPF \\(...)\")` so the sun.dust icon's auto-label does not prefix the chip read in VoiceOver."
    )
}

/// JJ2 — `PersistentFooter` NavigationLink carries
/// `.accessibilityLabel(ProductCopy.disclaimerLinkLabel)` so the
/// `info.circle` icon's auto-label does NOT prefix Plunder's L2 anchor.
@Test func test_JJ2_persistentFooterAccessibilityLabelOverridesIconAutoLabel() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let footerStart = lines.firstIndex(where: { $0.contains("struct PersistentFooter: View") }) else {
        Issue.record("PersistentFooter not found")
        return
    }
    let footerEnd: Int = lines[(footerStart + 1)...].firstIndex(where: { $0.hasPrefix("struct ") || $0.hasPrefix("#if DEBUG") }) ?? lines.endIndex
    let body = lines[footerStart..<footerEnd].joined(separator: "\n")
    #expect(
        body.contains(".accessibilityLabel(ProductCopy.disclaimerLinkLabel)"),
        "PersistentFooter must carry `.accessibilityLabel(ProductCopy.disclaimerLinkLabel)` so the info.circle icon does not noise the Plunder L2 anchor read."
    )
}

/// JJ3 — `HeroForecastDateContext` Label carries
/// `.accessibilityLabel(forecastDateContext)` so the
/// `clock.arrow.circlepath` icon's auto-label does NOT prefix the
/// date-context read. The icon was added for visual affordance only.
@Test func test_JJ3_heroForecastDateContextLabelOverridesIconAutoLabel() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    // Look in a window starting at the forecastDateContext rendering site.
    guard let renderIdx = lines.firstIndex(where: {
        $0.contains("if let forecastDateContext {")
    }) else {
        Issue.record("forecastDateContext render site not found")
        return
    }
    let windowEnd = min(renderIdx + 20, lines.endIndex)
    let window = lines[renderIdx..<windowEnd].joined(separator: "\n")
    #expect(
        window.contains(".accessibilityLabel(forecastDateContext)"),
        "HeroForecastDateContext Label must carry `.accessibilityLabel(forecastDateContext)` to override the clock.arrow.circlepath auto-label."
    )
}

/// JJ4 — `primaryAction` Button carries
/// `.accessibilityLabel(primaryActionPresentation.title)` so the
/// `location` / `arrow.clockwise` / `location.fill` icon auto-labels
/// do NOT prefix the primary CTA read.
@Test func test_JJ4_primaryActionAccessibilityLabelOverridesIconAutoLabel() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains(".accessibilityLabel(primaryActionPresentation.title)"),
        "primaryAction Button must carry `.accessibilityLabel(primaryActionPresentation.title)` to override the location/arrow.clockwise/location.fill icon auto-labels."
    )
}

/// JJ5 — `DisclaimerCover` photosensitizer + children Labels carry
/// explicit `.accessibilityLabel(...)` overrides so the
/// `exclamationmark.triangle` and `figure.and.child.holdinghands` icon
/// auto-labels do NOT noise the persona-load-bearing prose (Asha P4
/// reads the photosensitizer line; pediatric guidance is an
/// independent accessibility surface).
@Test func test_JJ5_disclaimerCoverInnerLabelsOverrideIconAutoLabels() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains(".accessibilityLabel(ProductCopy.photosensitizerDisclaimerLine)"),
        "DisclaimerCover photosensitizer Label must carry `.accessibilityLabel(ProductCopy.photosensitizerDisclaimerLine)` — Asha persona-load-bearing surface."
    )
    #expect(
        source.contains(".accessibilityLabel(ProductCopy.childrenDisclaimerLine)"),
        "DisclaimerCover children Label must carry `.accessibilityLabel(ProductCopy.childrenDisclaimerLine)` — pediatric accessibility surface."
    )
}

/// JJ6 — `AboutView` ships exactly ONE H1 heading: the
/// `.navigationTitle("About & Citations")`. The in-body
/// `Text("About & Citations").font(.title.bold()).accessibilityAddTraits(.isHeader)`
/// was retired because VoiceOver rotor → Headings was listing both as
/// H1-equivalent with disagreeing wording ("About" vs "About & Citations").
@Test func test_JJ6_aboutViewHasExactlyOneCanonicalH1() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains(".navigationTitle(\"About & Citations\")"),
        "AboutView navigation title must be \"About & Citations\" — matches the three NavigationLink entry-point labels (SettingsSheet, SkinTypePickerList footer, EstimateInfoButton)."
    )
    #expect(
        !source.contains("Text(\"About & Citations\")"),
        "AboutView in-body H1 `Text(\"About & Citations\")` must be retired — duplicates the nav title and creates two H1 entries in VoiceOver's Headings rotor with disagreeing wording."
    )
    #expect(
        !source.contains(".navigationTitle(\"About\")"),
        "Retired short-form `.navigationTitle(\"About\")` must not return — it disagreed with the NavigationLink entry-point labels."
    )
}
