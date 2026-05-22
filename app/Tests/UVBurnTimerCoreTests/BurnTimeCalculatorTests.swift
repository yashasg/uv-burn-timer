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
    #expect(estimate.accessibilitySummary.contains("UV index is 0 at this hour"))
    #expect(estimate.accessibilitySummary.contains("when the sun is up"))
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
    // WI-bundleQ / Plunder L04 — `cacheRetentionLine` now discloses the
    // 10-day forecast cache. The legacy substring "does not save UV values
    // or burn estimates" is replaced by "Live UV values and burn estimates
    // are never persisted" so the same lane (UV values + burn estimates
    // are not persisted) is preserved without the false "no UV cache" claim.
    #expect(ProductCopy.cacheRetentionLine.localizedCaseInsensitiveContains("Live UV values and burn estimates are never persisted"))
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
    // WI-bundleQ / Plunder L06 — keep lock-step with privacy-policy.md
    // `**Last updated:**` header. Bumped 2026-05-20 → 2026-05-21.
    #expect(ProductCopy.lastUpdatedLine == "Last updated: 2026-05-21.")
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
    // Wheeler-L12-H1: the locked Schalka source for the linear-SPF-as-MED-multiplier
    // claim is the 2011 An Bras Dermatol review, not the 2009 PPP application-thickness
    // paper. See `.squad/decisions/archive/wheeler-fitzpatrick-and-med-anchor.md` §3.3.
    #expect(
        linksByTitle["Schalka & Reis 2011 — SPF as MED multiplier"]
            == "https://doi.org/10.1590/S0365-05962011000300013")
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
    // MT-H1: clearStoredPreferences must also remove the rationale + disclaimer
    // policy version keys. Regressions that drop those `removeObject` calls would
    // otherwise ship green.
    #expect(defaults.object(forKey: UserPreferenceStorage.selectedSkinTypeKey) == nil)
    #expect(defaults.object(forKey: UserPreferenceStorage.selectedSPFKey) == nil)
    #expect(defaults.object(forKey: UserPreferenceStorage.locationRationaleAcknowledgedKey) == nil)
    #expect(defaults.object(forKey: UserPreferenceStorage.disclaimerPolicyVersionKey) == nil)
}

/// MT-H1 — Direct, dedicated guard for the rationale + disclaimer-version key
/// removal. Complements the broader `userPreferenceStorageRestoresSkinTypeSPFAndSafeDefaults`
/// test so the regression is callable out on its own and survives editorial churn
/// of the broader restore/clear roundtrip test.
@Test func test_MT_H1_clearStoredPreferences_also_removes_rationale_and_disclaimer_keys() throws {
    let defaults = try #require(UserDefaults(suiteName: "UVBurnTimerPreferenceStorageMTH1Tests"))
    defaults.removePersistentDomain(forName: "UVBurnTimerPreferenceStorageMTH1Tests")

    defaults.set(true, forKey: UserPreferenceStorage.locationRationaleAcknowledgedKey)
    defaults.set(
        UserPreferenceStorage.currentDisclaimerPolicyVersion,
        forKey: UserPreferenceStorage.disclaimerPolicyVersionKey
    )
    UserPreferenceStorage.persist(skinType: .typeIII, to: defaults)
    UserPreferenceStorage.persist(spf: .spf50, to: defaults)

    UserPreferenceStorage.clearStoredPreferences(from: defaults)

    #expect(defaults.object(forKey: UserPreferenceStorage.selectedSkinTypeKey) == nil)
    #expect(defaults.object(forKey: UserPreferenceStorage.selectedSPFKey) == nil)
    #expect(defaults.object(forKey: UserPreferenceStorage.locationRationaleAcknowledgedKey) == nil)
    #expect(defaults.object(forKey: UserPreferenceStorage.disclaimerPolicyVersionKey) == nil)

    defaults.removePersistentDomain(forName: "UVBurnTimerPreferenceStorageMTH1Tests")
}

/// Ma-Ti L13-5 — `UserPreferenceStorage.restoredSPF` coerces a stored raw
/// value of `0` (no matching SPFLevel case → `SPFLevel(rawValue:)` returns nil)
/// to the safe default `.spf30`, exercising the guard's failure branch where
/// the key is present but the integer does not decode to a valid SPFLevel.
@Test func userPreferenceStorageCoercesNonSunscreenSPFToSpf30() throws {
    let defaults = try #require(UserDefaults(suiteName: "UVBurnTimerPreferenceStorageL13Tests"))
    defaults.removePersistentDomain(forName: "UVBurnTimerPreferenceStorageL13Tests")

    // Store raw value 0 — key is present (object(forKey:) != nil) but
    // SPFLevel(rawValue: 0) is nil → must coerce to .spf30.
    defaults.set(0, forKey: UserPreferenceStorage.selectedSPFKey)
    #expect(UserPreferenceStorage.restoredSPF(from: defaults) == .spf30,
            "Stored rawValue 0 (invalid SPFLevel) must coerce to .spf30")

    // Negative raw value is also invalid — same coercion path.
    defaults.set(-1, forKey: UserPreferenceStorage.selectedSPFKey)
    #expect(UserPreferenceStorage.restoredSPF(from: defaults) == .spf30,
            "Stored negative rawValue (invalid SPFLevel) must coerce to .spf30")

    defaults.removePersistentDomain(forName: "UVBurnTimerPreferenceStorageL13Tests")
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
    // WI-bundleQ / Wheeler L13-H1 + Suchi L04 — accessibility variant now
    // carries the time-bounded hedge instead of the categorical
    // "No burn risk." tail.
    #expect(
        ProductCopy.noUVAtThisHourAccessibilityLabel ==
            "No UV at this hour. Burn risk returns when the sun is up — check the next forecast hour."
    )
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


// MARK: - Group QQ: Loop-12 Bundle K — Wheeler citation hygiene (H1+H2)
//
// Closes two Wheeler-locked citation-discipline failures surfaced by the
// Loop-12 parallel gap-analysis pass (claude-opus-4.7-xhigh):
//
//   QQ1 — Schalka citation link now points to the 2011 *An Bras Dermatol*
//         review (`https://doi.org/10.1590/S0365-05962011000300013`),
//         which is the locked source for the linear-SPF-as-MED-multiplier
//         claim per `.squad/decisions/archive/wheeler-fitzpatrick-and-med-anchor.md`
//         §3.3. The previous 2009 PPP application-thickness paper was the
//         wrong target (different claim, different journal) and the
//         shipped About surface told one source story in prose ("Schalka &
//         Reis on real-world sunscreen/SPF use") and a different one when
//         the user tapped the link.
//
//   QQ2 — Sayre 1981 and Harrison & Young 2002 — the empirical MED-by-type
//         anchors per the EE2 per-row audit comments in
//         `FitzpatrickSkinType.swift` and per the Wheeler archive §2.2 —
//         now have clickable entries in `citationLinks`. Previously a
//         user tapping "Citations" could not reach the two papers that
//         empirically ground the MED column.

/// QQ1 — Wheeler-locked Schalka source is the 2011 *An Bras Dermatol*
/// review, NOT the 2009 PPP paper. Validates both the canonical URL
/// presence and that the retired URL is no longer shipped.
@Test func test_QQ1_schalkaCitationLinkPointsToLockedAnBrasDermatol2011() {
    let urls = Set(ProductCopy.citationLinks.map { $0.url.absoluteString })
    #expect(
        urls.contains("https://doi.org/10.1590/S0365-05962011000300013"),
        "Wheeler-locked Schalka source must ship as a clickable citationLinks entry."
    )
    #expect(
        !urls.contains("https://doi.org/10.1111/j.1600-0781.2009.00408.x"),
        "The 2009 PPP application-thickness paper must NOT be the link target for the SPF-as-MED-multiplier claim — that is a different paper. See Wheeler archive §3.3."
    )
    // The retired 2009 paper's bibliographic shape must also drop out of the
    // titles set so prose like "Schalka, dos Reis & Cucé sunscreen/SPF study"
    // does not silently survive after the URL was swapped.
    let titles = Set(ProductCopy.citationLinks.map(\.title))
    #expect(
        titles.contains("Schalka & Reis 2011 — SPF as MED multiplier"),
        "Schalka citation must carry the locked 2011 title (`Schalka & Reis 2011 — SPF as MED multiplier`)."
    )
    #expect(
        !titles.contains("Schalka, dos Reis & Cucé sunscreen/SPF study"),
        "The retired 2009 citation title must not survive after the URL swap."
    )
}

/// QQ2 — Sayre 1981 and Harrison & Young 2002 are the empirical MED-by-type
/// anchor papers. They are cited in `fitzpatrickCitations` prose and in
/// the per-row AUDIT-ONLY comments in `FitzpatrickSkinType.swift` (EE2)
/// but were previously not clickable in `citationLinks`. The
/// citation-per-claim rule in the health-adjacent-constant-adoption
/// SKILL §4 requires every value to have its own clickable citation.
@Test func test_QQ2_medAnchorPrimarySourcesAreClickable() {
    let urls = Set(ProductCopy.citationLinks.map { $0.url.absoluteString })
    // Sayre 1981 — empirical MED measurements (Types I/II/IV anchor).
    #expect(
        urls.contains("https://doi.org/10.1016/S0190-9622(81)70105-1"),
        "Sayre 1981 (MED-per-type empirical anchor for Types I/II/IV) must ship as a clickable citationLinks entry — referenced by FitzpatrickSkinType.swift EE2 audit comments."
    )
    // Harrison & Young 2002 — modern review tabulating MED-by-type
    // (Types III/V/VI anchor).
    #expect(
        urls.contains("https://doi.org/10.1016/S1046-2023(02)00205-0"),
        "Harrison & Young 2002 (erythema dose-response review, MED-by-type for Types III/V/VI) must ship as a clickable citationLinks entry — referenced by FitzpatrickSkinType.swift EE2 audit comments."
    )
    // Bibliographic title sanity — Wheeler archive §2.2 + decisions.md §4.5.
    let titles = Set(ProductCopy.citationLinks.map(\.title))
    #expect(titles.contains("Sayre et al. 1981 — MED-per-type empirical anchor"))
    #expect(titles.contains("Harrison & Young 2002 — erythema dose-response review"))
}

/// QQ3 — `citationLinks` count grew by exactly +2 (Sayre + Harrison) and
/// stays internally consistent (no duplicate URLs or titles).
@Test func test_QQ3_citationLinksCountAndIntegrityAfterWheelerBundle() {
    #expect(ProductCopy.citationLinks.count == 8)
    let urls = ProductCopy.citationLinks.map { $0.url.absoluteString }
    let titles = ProductCopy.citationLinks.map(\.title)
    #expect(urls.count == Set(urls).count, "citationLinks must not contain duplicate URLs.")
    #expect(titles.count == Set(titles).count, "citationLinks must not contain duplicate titles.")
}

// MARK: - Group EJ: Loop-11 Bundle D — Kwame iOS code hygiene + Iris-e

/// EJ1 — WI-kwame-k2: `RootView` no longer declares the dead
/// `@Environment(\.colorSchemeContrast)` env var. The Kwame Loop-11 gap
/// report confirmed it was declared but never read in RootView's body
/// (the only consumer is `TierBadge`, which declares its own copy at the
/// consumer site). Keeping a dead env declaration costs a SwiftUI
/// dependency edge and a redraw.
@Test func test_EJ1_rootViewDoesNotDeclareDeadColorSchemeContrastEnv() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let rootViewStart = lines.firstIndex(where: { $0.contains("struct RootView: View") }) else {
        Issue.record("RootView struct not found")
        return
    }
    // RootView's property block ends at the first `var body: some View`.
    guard let bodyIdx = lines[rootViewStart...].firstIndex(where: { $0.contains("var body: some View") }) else {
        Issue.record("RootView var body not found")
        return
    }
    let rootViewProperties = lines[rootViewStart..<bodyIdx].joined(separator: "\n")
    #expect(
        !rootViewProperties.contains("@Environment(\\.colorSchemeContrast)"),
        "RootView must not declare @Environment(\\.colorSchemeContrast) — it was dead code (never read in RootView's body). TierBadge declares its own copy at the consumer site."
    )
}

/// EJ2 — WI-kwame-k3: `BurnRiskGaugeCard`'s gauge numeral is sized via
/// an @ScaledMetric so it scales with Dynamic Type at AX5 alongside the
/// outer ring (which already used `@ScaledMetric(relativeTo: .largeTitle)`
/// for `gaugeDiameter`). Previously the numeral stayed pinned at 42 pt
/// while the ring grew, producing a misshapen ratio at AX5.
@Test func test_EJ2_burnRiskGaugeCardNumeralIsScaledMetric() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct BurnRiskGaugeCard: View") }) else {
        Issue.record("BurnRiskGaugeCard struct not found")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: {
        $0.hasPrefix("struct ") || $0.hasPrefix("private struct ")
    }) ?? lines.endIndex
    let body = lines[cardStart..<cardEnd].joined(separator: "\n")

    #expect(
        body.contains("@ScaledMetric(relativeTo: .largeTitle) private var gaugeNumeralSize"),
        "BurnRiskGaugeCard must declare `@ScaledMetric(relativeTo: .largeTitle) private var gaugeNumeralSize` so the inner numeral scales with Dynamic Type alongside the outer ring at AX5."
    )
    #expect(
        body.contains("Text(remainingText)\n                    .font(.system(size: gaugeNumeralSize"),
        "BurnRiskGaugeCard's remainingText Text must use `.font(.system(size: gaugeNumeralSize, …))` — the dead literal `42` is replaced by the ScaledMetric."
    )
    #expect(
        !body.contains(".font(.system(size: 42"),
        "BurnRiskGaugeCard must not retain the hardcoded `.font(.system(size: 42` literal — replaced by gaugeNumeralSize ScaledMetric."
    )
}

/// EJ3 — WI-kwame-k3 sibling: `BurnRiskGaugeUnavailableCard`'s "—"
/// placeholder also uses an @ScaledMetric.
@Test func test_EJ3_burnRiskGaugeUnavailableCardNumeralIsScaledMetric() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct BurnRiskGaugeUnavailableCard: View") }) else {
        Issue.record("BurnRiskGaugeUnavailableCard struct not found")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: {
        $0.hasPrefix("struct ") || $0.hasPrefix("private struct ")
    }) ?? lines.endIndex
    let body = lines[cardStart..<cardEnd].joined(separator: "\n")

    #expect(
        body.contains("@ScaledMetric(relativeTo: .largeTitle) private var gaugePlaceholderNumeralSize"),
        "BurnRiskGaugeUnavailableCard must declare `gaugePlaceholderNumeralSize` ScaledMetric."
    )
    #expect(
        !body.contains(".font(.system(size: 48"),
        "BurnRiskGaugeUnavailableCard must not retain the hardcoded `.font(.system(size: 48` literal — replaced by gaugePlaceholderNumeralSize ScaledMetric."
    )
}

/// EJ4 — WI-iris-e: `PersistentFooter`'s NavigationLink Label carries
/// an explicit `.frame(minHeight: 44…)` so the always-visible Plunder
/// reach-back link stays above the HIG 44 pt hit-target floor at every
/// Dynamic Type size.
@Test func test_EJ4_persistentFooterMeetsHIG44ptHitTarget() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let footerStart = lines.firstIndex(where: { $0.contains("struct PersistentFooter: View") }) else {
        Issue.record("PersistentFooter struct not found")
        return
    }
    let footerEnd: Int = lines[(footerStart + 1)...].firstIndex(where: {
        $0.hasPrefix("struct ") || $0.hasPrefix("private struct ") || $0.hasPrefix("#if DEBUG")
    }) ?? lines.endIndex
    let body = lines[footerStart..<footerEnd].joined(separator: "\n")

    #expect(
        body.contains(".frame(minHeight: 44"),
        "PersistentFooter must apply `.frame(minHeight: 44…)` to its Label/NavigationLink — Plunder's always-visible disclaimer-reach surface must not fall below the 44 pt HIG hit-target floor at default Dynamic Type. See AppViews.swift chips at lines 295 / 315 / 337 for the existing pattern."
    )
}

// MARK: - Group GG: Loop-12 Bundle G — ForecastPickerView WeatherKit attribution + L3 reach-back
//
// Closes two HIGH-severity regulatory-floor breaches surfaced by the
// Loop-12 parallel gap-analysis pass (claude-opus-4.7-xhigh):
//
//   GG1 — WeatherKit license breach (§5.1.1): `ForecastPickerView` is a
//         WeatherKit-derived data surface that previously did not display
//         "Source: Apple Weather" anywhere in its rendered body. Apple's
//         WeatherKit terms require attribution on every surface that
//         consumes WeatherKit data; the hero/UV card carried the
//         attribution but the 10-day forecast picker did not.
//
//   GG2 — Plunder C3 floor breach: `ForecastPickerView` had no L3
//         photosensitizer reach-back surface. Users navigating to the
//         picker and staying there had no tap target to reach the
//         photosens cohort warning. The C3 floor (L3 reach-back from
//         every result surface) was satisfied only on the main hero
//         card via the toolbar ⓘ `EstimateInfoButton` — but the
//         picker is its own result surface (selecting a future hour
//         drives the burn-time gauge for that hour) and needs its own
//         reach-back path.

private func _forecastPickerSourceForGroupGG() throws -> String {
    let appRoot = try appRootURL()
    let url = appRoot.appendingPathComponent("Sources/UVBurnTimer/ForecastPickerView.swift")
    return try String(contentsOf: url, encoding: .utf8)
}

/// GG1 — `ForecastPickerView` must render the Apple Weather attribution
/// at the source-text level. Pinned by substring guard so any future
/// refactor that drops the attribution surface fails CI.
@Test func test_GG1_forecastPickerViewRendersAppleWeatherAttribution() throws {
    let source = try _forecastPickerSourceForGroupGG()
    #expect(
        source.contains("ProductCopy.weatherAttributionServiceName"),
        "ForecastPickerView must render `ProductCopy.weatherAttributionServiceName` (\"Apple Weather\") — WeatherKit §5.1.1 attribution requirement."
    )
    #expect(
        source.contains("ProductCopy.weatherAttributionLegalURL"),
        "ForecastPickerView must link to `ProductCopy.weatherAttributionLegalURL` so the attribution is a tappable WeatherKit-legal-page reference."
    )
    #expect(
        source.contains(".accessibilityIdentifier(\"ForecastPickerAttribution\")"),
        "ForecastPickerView must carry `accessibilityIdentifier(\"ForecastPickerAttribution\")` on its attribution surface so XCUI and the contrast checklist can find it."
    )
}

/// GG2 — `ForecastPickerView` must carry an L3 photosensitizer reach-back
/// surface — a NavigationLink that opens `AboutView(highlightEstimateApplicability: true)`
/// from inside the picker, paired with a stable accessibility identifier
/// so the contrast / launch-readiness checklists can target it.
@Test func test_GG2_forecastPickerViewExposesL3PhotosensReachBack() throws {
    let source = try _forecastPickerSourceForGroupGG()
    #expect(
        source.contains("AboutView(highlightEstimateApplicability: true)"),
        "ForecastPickerView must navigate to `AboutView(highlightEstimateApplicability: true)` — Plunder C3 floor (L3 reach-back from result surface)."
    )
    #expect(
        source.contains(".accessibilityIdentifier(\"ForecastPickerEstimateInfoButton\")"),
        "ForecastPickerView must carry `accessibilityIdentifier(\"ForecastPickerEstimateInfoButton\")` on its L3 reach-back surface — parity with the main-screen `EstimateInfoButton`."
    )
}

/// GG3 — Both the attribution surface and the L3 reach-back surface must
/// be rendered AFTER the hourly strip section (footer placement, per the
/// design intent that attribution + reach-back belong at the bottom of
/// the data surface so they don't interrupt the day/hour selection flow).
@Test func test_GG3_forecastPickerFooterSurfacesAppearAfterHourlyStrip() throws {
    let source = try _forecastPickerSourceForGroupGG()
    let lines = source.components(separatedBy: "\n")
    let hourlyIdx = lines.firstIndex { $0.contains("hourlyStripSection") }
    let attrIdx = lines.firstIndex { $0.contains("ForecastPickerAttribution") }
    let infoIdx = lines.firstIndex { $0.contains("ForecastPickerEstimateInfoButton") }
    #expect(hourlyIdx != nil, "hourlyStripSection must be present in ForecastPickerView body.")
    #expect(attrIdx != nil, "ForecastPickerAttribution surface must be present.")
    #expect(infoIdx != nil, "ForecastPickerEstimateInfoButton surface must be present.")
    if let h = hourlyIdx, let a = attrIdx, let i = infoIdx {
        #expect(h < a, "Attribution must appear AFTER the hourlyStripSection in the source body.")
        #expect(h < i, "L3 reach-back button must appear AFTER the hourlyStripSection in the source body.")
    }
}

// MARK: - Group II: Loop-12 Bundle I — Disclaimer state coherence (Kwame H1)
//
// Closes a HIGH-severity Pattern-B regression surfaced by the Loop-12
// Kwame gap-analysis pass (claude-opus-4.7-xhigh): the
// `UserPreferenceStorage.shouldShowDisclaimerCover` `isExistingUser`
// heuristic counted the existence of `selectedSkinTypeKey` in defaults
// as a signal that the user is a returning user — but `@AppStorage` on
// `RootView` writes the `unsetSkinTypeRawValue` (0) sentinel to disk
// the first time `handleAppear()` runs, which happens *while L1 is
// still on screen and unacknowledged*. If the user force-quits before
// tapping "I understand", the next launch sees `storedVersion == 0`
// AND `selectedSkinTypeKey != nil`, takes the migration branch, writes
// `currentVersion` to disk, and never re-fires L1 — a direct breach of
// the Plunder C6 / Asha "L1 must fire once on first launch" contract.
//
// Fix: require the stored rawValue to map to a real Fitzpatrick type
// (excluding the 0 sentinel) before treating the user as existing.

/// II1 — Fresh-install user who force-quits while L1 is on screen (no
/// disclaimer ack written, no skin type committed, but RootView's
/// `@AppStorage` already wrote the unset sentinel to disk) must still
/// see L1 on the next launch. The unset sentinel is NOT an existing-user
/// signal.
@Test func test_II1_freshInstallForceQuitDuringL1RefiresL1OnNextLaunch() throws {
    let (defaults, suiteName) = makeIsolatedDefaults()
    defer { tearDownIsolatedDefaults(defaults, suiteName: suiteName) }

    // Simulate handleAppear's @AppStorage write on first launch: the unset
    // sentinel for skinType plus the default SPF land on disk before the
    // user has interacted with the L1 cover.
    defaults.set(UserPreferenceStorage.unsetSkinTypeRawValue, forKey: UserPreferenceStorage.selectedSkinTypeKey)
    defaults.set(SPFLevel.spf30.rawValue, forKey: UserPreferenceStorage.selectedSPFKey)
    // User force-quits BEFORE acknowledging — disclaimerPolicyVersionKey is NEVER written.

    let shouldShowOnRelaunch = UserPreferenceStorage.shouldShowDisclaimerCover(
        defaults: defaults,
        currentVersion: UserPreferenceStorage.currentDisclaimerPolicyVersion
    )

    #expect(
        shouldShowOnRelaunch,
        "Force-quit-before-L1-ack must re-fire L1 on next launch. The unsetSkinTypeRawValue (0) is a placeholder written by @AppStorage before the user has interacted, NOT an existing-user signal. (Kwame-L12-H1 / Group II1)"
    )

    // And the migration write must NOT have fired — disclaimerPolicyVersionKey
    // should still be 0 so the next launch also sees L1 until the user actually
    // taps "I understand".
    let storedVersionAfter = defaults.integer(forKey: UserPreferenceStorage.disclaimerPolicyVersionKey)
    #expect(
        storedVersionAfter == 0,
        "Migration branch must NOT fire when the only existing-user signal is the unset sentinel — disclaimerPolicyVersionKey should remain unwritten."
    )
}

/// II2 — A user who genuinely picked a Fitzpatrick type and force-quit
/// without writing the policy-version key (i.e., true pre-Pattern-B
/// returning user OR a fresh-install user who tapped the cover, picked a
/// type, and then crashed) must continue to follow the migration path:
/// the existing-user heuristic still recognizes a genuine pick.
@Test func test_II2_genuinePreviousSkinTypePickContinuesToBeRecognizedAsExistingUser() throws {
    let (defaults, suiteName) = makeIsolatedDefaults()
    defer { tearDownIsolatedDefaults(defaults, suiteName: suiteName) }

    // Genuine pre-Pattern-B existing user — committed a Fitzpatrick type.
    defaults.set(FitzpatrickSkinType.typeIII.rawValue, forKey: UserPreferenceStorage.selectedSkinTypeKey)
    defaults.set(SPFLevel.spf30.rawValue, forKey: UserPreferenceStorage.selectedSPFKey)
    // No disclaimerPolicyVersionKey — the prior @State-only era never wrote it.

    let shouldShowOnRelaunch = UserPreferenceStorage.shouldShowDisclaimerCover(
        defaults: defaults,
        currentVersion: UserPreferenceStorage.currentDisclaimerPolicyVersion
    )

    #expect(
        !shouldShowOnRelaunch,
        "Genuine returning user (real Fitzpatrick raw value persisted) must continue to skip L1 on the migration path — Pattern-B contract preserved."
    )
    let migratedVersion = defaults.integer(forKey: UserPreferenceStorage.disclaimerPolicyVersionKey)
    #expect(
        migratedVersion == UserPreferenceStorage.currentDisclaimerPolicyVersion,
        "Migration must persist currentDisclaimerPolicyVersion for the genuine returning user."
    )
}

/// II3 — Negative guard: an invalid out-of-range stored rawValue (e.g.,
/// corrupted defaults or a future schema version writing a value outside
/// FitzpatrickSkinType's domain) must also fall back to "fresh install"
/// rather than silently migrating an unrecognized state.
@Test func test_II3_outOfRangeStoredSkinTypeRawValueDoesNotSuppressL1() throws {
    let (defaults, suiteName) = makeIsolatedDefaults()
    defer { tearDownIsolatedDefaults(defaults, suiteName: suiteName) }

    // Synthesize an out-of-range value (rawValue 99 — outside I…VI).
    defaults.set(99, forKey: UserPreferenceStorage.selectedSkinTypeKey)
    defaults.set(SPFLevel.spf30.rawValue, forKey: UserPreferenceStorage.selectedSPFKey)

    let shouldShowOnRelaunch = UserPreferenceStorage.shouldShowDisclaimerCover(
        defaults: defaults,
        currentVersion: UserPreferenceStorage.currentDisclaimerPolicyVersion
    )

    #expect(
        shouldShowOnRelaunch,
        "Out-of-range stored skin-type rawValue must not satisfy the existing-user heuristic — fall back to first-install behaviour and present L1."
    )
}

// MARK: - Group SS: Loop-12 Bundle M — GDPR Art.17 SPF erasure (Kwame H2)
//
// Closes the L1↔Settings erasure-symmetry gap surfaced by the Loop-12
// Kwame gap-analysis pass (claude-opus-4.7-xhigh).
//
// Plunder-ratified L1 storage-disclosure copy promises:
//
//   "Your skin type and SPF are saved on this device only … You can
//    clear them anytime in Settings."
//
// The Loop-11 erasure-path implementation (PR #47 BundleF / WI-plunder-aa)
// shipped only a "Clear stored skin type" button. SPF persisted with no
// documented erasure affordance, leaving the L1 promise unfulfilled — a
// GDPR Art.17 inconsistency between disclosed and actual erasure paths.
// Severity HIGH because the L1 copy is presented as a regulatory commitment.
//
// Fix: a parallel "Clear stored SPF" button in the Settings Privacy section,
// routed through the same `auditCopySurfaces`-enrolled `ProductCopy`
// constant, with verb continuity ("clear") so the consent ↔ erasure loop
// holds.

/// SS1 — Verb-continuity / coverage contract: every preference the L1
/// `disclaimerStorageLine` names as on-device must have a corresponding
/// `ProductCopy` "Clear …" button title naming that preference. This is
/// the cross-substring guard Kwame proposed in the L12 gap-analysis;
/// pinning it here means a future drift in either direction (the L1
/// copy adds a third preference but no button, or a button title loses
/// the noun) hard-fails CI.
@Test func test_SS1_disclaimerStorageLinePromisesAreFulfilledBySettingsErasureButtons() {
    let copy = ProductCopy.disclaimerStorageLine
    let l1NamedNouns: [String] = ["skin type", "SPF"]
    for noun in l1NamedNouns {
        #expect(
            copy.localizedCaseInsensitiveContains(noun),
            "L1 disclaimerStorageLine must enumerate '\(noun)' to satisfy GDPR Art.13 storage disclosure."
        )
        let hasButton = ProductCopy.auditCopySurfaces.contains { surface in
            surface.localizedCaseInsensitiveContains("Clear")
                && surface.localizedCaseInsensitiveContains(noun)
        }
        #expect(
            hasButton,
            "L1 disclaimerStorageLine promises '\(noun)' can be cleared in Settings — there MUST be a ProductCopy 'Clear …' constant naming '\(noun)' so the L1↔Settings verb-continuity loop holds. (WI-bundleM / SS1 — Kwame-L12 H2)"
        )
    }
}

/// SS2 — `clearStoredSPFButtonTitle` exists, carries the "Clear" verb +
/// "SPF" noun, and is audit-enrolled so the monetization-drift sieve
/// applies.
@Test func test_SS2_clearStoredSPFButtonTitleIsRoutedThroughProductCopyAndAuditEnrolled() {
    #expect(ProductCopy.clearStoredSPFButtonTitle == "Clear stored SPF")
    #expect(ProductCopy.clearStoredSPFButtonTitle.localizedCaseInsensitiveContains("clear"))
    #expect(ProductCopy.clearStoredSPFButtonTitle.localizedCaseInsensitiveContains("SPF"))
    #expect(ProductCopy.auditCopySurfaces.contains(ProductCopy.clearStoredSPFButtonTitle))
}

/// SS3 — Render-site source-text guard: `SettingsSheet` references the
/// `ProductCopy.clearStoredSPFButtonTitle` constant (not a literal) and
/// carries the `ClearStoredSPFButton` accessibility identifier so XCUI
/// and the contrast checklist can find it.
@Test func test_SS3_settingsSheetRendersClearStoredSPFButtonViaProductCopy() throws {
    let source = try _appViewsSourceForGroupR()
    #expect(
        source.contains("ProductCopy.clearStoredSPFButtonTitle"),
        "SettingsSheet must reference `ProductCopy.clearStoredSPFButtonTitle` so the GDPR Art.17 audit sieves apply."
    )
    #expect(
        !source.contains("Text(\"Clear stored SPF\")"),
        "SettingsSheet must NOT carry the inline `Text(\"Clear stored SPF\")` literal — must route through ProductCopy."
    )
    #expect(
        source.contains(".accessibilityIdentifier(\"ClearStoredSPFButton\")"),
        "SettingsSheet's Clear-SPF button must carry `accessibilityIdentifier(\"ClearStoredSPFButton\")` so the contrast / launch-readiness checklists can target it."
    )
    // Parity guard: the skin-type clear button continues to be present with its
    // own identifier (we extended the pair, did not replace the existing one).
    #expect(
        source.contains(".accessibilityIdentifier(\"ClearStoredSkinTypeButton\")"),
        "SettingsSheet's Clear-skin-type button must keep its `ClearStoredSkinTypeButton` identifier for L1↔Settings parity."
    )
}

/// SS4 — Erasure action contract: `UserPreferenceStorage.persist(spf:)`
/// with `.spf30` (the default) sets the SPF key on disk. The render-site
/// already calls this; the model-level test pins the API surface so a
/// future refactor of the storage layer cannot silently change the
/// erasure semantics (e.g., dropping the write to leave the previous
/// SPF on disk).
@Test func test_SS4_persistSPFDefaultRestoresStoredValueToDefault() throws {
    let (defaults, suiteName) = makeIsolatedDefaults()
    defer { tearDownIsolatedDefaults(defaults, suiteName: suiteName) }

    // Pre-condition: user previously stored SPF 50.
    UserPreferenceStorage.persist(spf: .spf50, to: defaults)
    #expect(UserPreferenceStorage.restoredSession(from: defaults).selectedSPF == .spf50)

    // Erasure action: write the default sentinel.
    UserPreferenceStorage.persist(spf: .spf30, to: defaults)

    #expect(
        UserPreferenceStorage.restoredSession(from: defaults).selectedSPF == .spf30,
        "Persisting `.spf30` (the default) must restore the stored SPF to the default — this is the SettingsSheet Clear-SPF action contract."    )
}

// MARK: - Group TT: Loop-12 Bundle P — clearSavedRoundedCoordinate state coherence (Kwame H3)
//
// Closes a state-coherence regression surfaced by the Loop-12 Kwame
// gap-analysis pass (claude-opus-4.7-xhigh).
//
// `clearSavedRoundedCoordinate()` did not reset the in-memory @State
// `uvIndex` or `fetchedAt`. The hero card's `activeEstimate` computation
// falls through `activeUVIndex` → `uvIndex` (the live state), so the
// burn-time number kept rendering after the erasure.
//
// Fix: in addition to the existing clears, also reset `uvIndex = nil`,
// `fetchedAt = nil`, `weatherFailureMessage = nil`, `locationFailureMessage = nil`.

/// TT1 — Render-site source-text guard: `clearSavedRoundedCoordinate()`
/// resets the in-memory location-derived @State alongside the on-disk
/// erasure. Required clears: `uvIndex`, `fetchedAt`, `weatherFailureMessage`,
/// `locationFailureMessage` — all in addition to the existing
/// `roundedCoordinate`, `forecastSnapshot`, `forecastRefreshState`, and
/// `cachedRoundedCoordinateStorage` resets.
@Test func test_TT1_clearSavedRoundedCoordinateResetsAllLocationDerivedLiveState() throws {
    let source = try _appViewsSourceForGroupR()
    let lines = source.components(separatedBy: "\n")
    guard let start = lines.firstIndex(where: { $0.contains("private func clearSavedRoundedCoordinate()") }) else {
        Issue.record("clearSavedRoundedCoordinate function not found")
        return
    }
    // Look 25 lines forward to find the function body.
    let end = min(start + 25, lines.endIndex)
    let body = lines[start..<end].joined(separator: "\n")

    let requiredResets: [String] = [
        "uvIndex = nil",
        "fetchedAt = nil",
        "weatherFailureMessage = nil",
        "locationFailureMessage = nil",
    ]
    for line in requiredResets {
        #expect(
            body.contains(line),
            "clearSavedRoundedCoordinate() must contain `\(line)` to honor the L1 storage-disclosure erasure promise — Kwame-L12 H3 / Group TT."
        )
    }
    // Sanity: the existing on-disk + snapshot clears must still be present
    // (we extended, not replaced, the cleanup contract).
    #expect(body.contains("roundedCoordinate = nil"))
    #expect(body.contains("forecastSnapshot = nil"))
    #expect(body.contains("cachedRoundedCoordinateStorage = CachedRoundedCoordinateStorage.clearedStorageValue"))
}

// MARK: - WI-loop14-high

/// K-H1 — existing users (those who don't see the L1 disclaimer cover) must
/// have their restored session pre-acknowledged so the first "Use my location"
/// tap doesn't throw `.disclaimerNotAcknowledged` and show "Review the
/// disclaimer before requesting UV." — there is no disclaimer to review.
///
/// Mirrors the init logic in `UVBurnTimerApp.swift`:
///   `restoredSession(from: defaults, acknowledgedDisclaimer: !initialShowDisclaimer)`
@Test func test_KH1_existingUserSessionIsPreAcknowledged() throws {
    let suiteName = "UVBurnTimerKH1Tests"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defaults.removePersistentDomain(forName: suiteName)

    // Seed an existing user: a valid stored Fitzpatrick skin type, plus the
    // current disclaimer policy version (i.e. they already migrated through
    // shouldShowDisclaimerCover on a prior launch).
    UserPreferenceStorage.persist(skinType: .typeIII, to: defaults)
    defaults.set(
        UserPreferenceStorage.currentDisclaimerPolicyVersion,
        forKey: UserPreferenceStorage.disclaimerPolicyVersionKey
    )

    let showDisclaimer = UserPreferenceStorage.shouldShowDisclaimerCover(
        defaults: defaults,
        currentVersion: UserPreferenceStorage.currentDisclaimerPolicyVersion
    )
    #expect(!showDisclaimer, "Existing user at current policy version must not see L1 cover")

    let session = UserPreferenceStorage.restoredSession(
        from: defaults,
        acknowledgedDisclaimer: !showDisclaimer
    )
    #expect(session.acknowledgedDisclaimer,
            "Existing users (no cover) must have acknowledgedDisclaimer == true so fetchEstimate doesn't throw .disclaimerNotAcknowledged")
    #expect(session.selectedSkinType == .typeIII)

    defaults.removePersistentDomain(forName: suiteName)
}

/// K-H2 — `handleAppear()` must kick off `refreshForecastIfNeeded()` so the
/// cached forecast loads at cold-start. scenePhase is already `.active` at
/// cold launch, so the onChange-based path in `handleScenePhaseChange` never
/// fires.
///
/// Source-text guard (matches the `_appViewsSourceForGroupR()` pattern used by
/// existing EJ/EK/Group-R tests).
@Test func test_KH2_handleAppearTriggersRefreshNotJustScenePhaseChange() throws {
    let source = try _appViewsSourceForGroupR()

    // Find the handleAppear function body and assert it contains the refresh call.
    guard let appearRange = source.range(of: "private func handleAppear()") else {
        Issue.record("handleAppear() not found in AppViews.swift")
        return
    }

    // Take a generous window after the declaration — handleAppear is short.
    let after = source[appearRange.upperBound...]
    let window = String(after.prefix(800))
    #expect(window.contains("refreshForecastIfNeeded"),
            "handleAppear must call refreshForecastIfNeeded so cold-start cached forecasts load (K-H2)")
}

/// S-H1 — `BurnRiskGaugeCard.supportingText` must always render as visible
/// caption text, not be gated behind `differentiateWithoutColor`. The giant
/// numeral inside a depleting ring otherwise reads as a live countdown timer
/// to sighted users; the "% elapsed" framing is the visible signal that it
/// is an estimate.
@Test func test_SH1_burnRiskGaugeSupportingTextAlwaysRendered() throws {
    let source = try _appViewsSourceForGroupR()

    // Locate the BurnRiskGaugeCard struct body.
    guard let structRange = source.range(of: "struct BurnRiskGaugeCard: View") else {
        Issue.record("struct BurnRiskGaugeCard not found in AppViews.swift")
        return
    }

    // Scope the search to the next ~2000 chars — well within the struct body.
    let scoped = String(source[structRange.upperBound...].prefix(2000))

    // supportingText must be referenced (rendered as Text).
    #expect(scoped.contains("Text(supportingText)"),
            "BurnRiskGaugeCard must render Text(supportingText)")

    // It must NOT be gated by `if differentiateWithoutColor { ... Text(supportingText) ... }`.
    // We assert no `if differentiateWithoutColor` appears between the struct
    // declaration and the first supportingText reference inside the body.
    if let supportingRange = scoped.range(of: "Text(supportingText)") {
        let beforeSupporting = scoped[..<supportingRange.lowerBound]
        #expect(!beforeSupporting.contains("if differentiateWithoutColor"),
                "Text(supportingText) must not be gated behind `if differentiateWithoutColor` (S-H1)")
    }
}

// MARK: - Group Q: Loop-13 Bundle Q — convergent HIGH closure
//
// Closes seven HIGH-severity findings surfaced by the Loop-13 parallel
// gap-analysis pass (claude-opus-4.7-xhigh):
//
//   Q1 — Wheeler L13-H1 + Suchi L04 (Tomás P5 + photobiology):
//        `noUVAtThisHourAccessibilityLabel` previously claimed "No burn
//        risk." — a categorical safety claim that overreached the WHO
//        2002 §2.1 rounded-integer UVI definition (true erythemal
//        irradiance may be present at sunrise/sunset, on snow, water,
//        sand). The string now ends with a time-bounded hedge naming
//        the next forecast hour. `BurnTimeCalculator.accessibilitySummary`
//        UVI=0 branch updated in parallel.
//
//   Q2 — Plunder L04 (GDPR Art.5(1)(a) accuracy):
//        `cacheRetentionLine` previously said the app "does not save
//        UV values or burn estimates between launches" but the WI-7
//        forecast pipeline DOES cache a 10-day UV forecast on-device.
//        The hosted privacy policy §2 has always disclosed this; the
//        in-app line now matches.
//
//   Q3 — Plunder L06 (GDPR Art.12 transparency):
//        `lastUpdatedLine` lagged the hosted policy `Last updated:`
//        header by one day. The pin keeps them locked together.
//
//   Q4 — Iris L03 (HIG 44pt tap-target floor):
//        `ForecastPickerAttribution` Link wrapped a `minHeight: 32`
//        hit region — below the 44×44pt floor — while the sibling
//        `ForecastPickerEstimateInfoButton` correctly carried 44.
//        Now raised to 44 with `.contentShape(Rectangle())`.
//
//   Q5 — Plunder L03 (GDPR Art.17 symmetry):
//        Hosted privacy policy §6 enumerated only "Clear stored skin
//        type" and "Clear saved location" as erasure affordances.
//        Group SS (#54) shipped a third destructive button "Clear
//        stored SPF"; the policy now names all three symmetrically.
//
//   Q6 — Gaia L13d (build.sh hygiene):
//        The local-dev branch of `build.sh` ignored the documented
//        `RUN_TESTS=false` env var (only the CI branch honored it).
//        Now wrapped in `if [[ "$run_tests" == "true" ]]; then ... fi`.
//
// Build script changes are validated by a source-text guard rather
// than a shell harness — keeps the test surface inside Swift Testing.

/// Q1 — UVI=0 visible + accessibility copy must drop categorical
/// "No burn risk." claims and carry a time-bounded hedge naming the
/// return of burn risk. Source-text guards cover both `ProductCopy`
/// and `BurnTimeCalculator.accessibilitySummary`.
@Test func test_Q1_uviZeroCopyDropsCategoricalSafetyClaim() throws {
    // ProductCopy visible label is unchanged ("No UV at this hour")
    #expect(ProductCopy.noUVAtThisHourLabel == "No UV at this hour")

    // Accessibility variant must NOT contain the categorical claim and
    // MUST contain the temporal hedge.
    #expect(
        !ProductCopy.noUVAtThisHourAccessibilityLabel.contains("No burn risk."),
        "noUVAtThisHourAccessibilityLabel must not claim categorical \"No burn risk.\" — overreaches WHO 2002 §2.1 rounded-UVI definition."
    )
    #expect(
        ProductCopy.noUVAtThisHourAccessibilityLabel.contains("when the sun is up"),
        "noUVAtThisHourAccessibilityLabel must hedge with \"when the sun is up\" to name the return of burn risk (Tomás P5 safety)."
    )

    // BurnTimeCalculator.accessibilitySummary UVI=0 branch carries the
    // same hedge and drops the "No erythemal irradiance detected." claim.
    let zeroUVCalculator = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .unprotectedReference,
        uvIndex: 0
    )
    #expect(
        !zeroUVCalculator.accessibilitySummary.contains("No erythemal irradiance detected"),
        "BurnTimeCalculator UVI=0 accessibilitySummary must not claim \"No erythemal irradiance detected.\" — the underlying UVI is rounded, not measured."
    )
    #expect(
        zeroUVCalculator.accessibilitySummary.contains("when the sun is up"),
        "BurnTimeCalculator UVI=0 accessibilitySummary must hedge with \"when the sun is up\"."
    )
}

/// Q2 — `cacheRetentionLine` must disclose the forecast cache so it
/// matches the hosted privacy policy §2 (GDPR Art.5(1)(a) accuracy).
@Test func test_Q2_cacheRetentionLineDisclosesForecastCache() throws {
    #expect(
        ProductCopy.cacheRetentionLine.contains("forecast"),
        "cacheRetentionLine must name the forecast cache (GDPR Art.5(1)(a) accuracy — must match hosted policy §2)."
    )
    #expect(
        ProductCopy.cacheRetentionLine.contains("Caches directory"),
        "cacheRetentionLine must name the iOS Caches directory so the eviction model is transparent."
    )
    #expect(
        ProductCopy.cacheRetentionLine.contains("Live UV values and burn estimates are never persisted"),
        "cacheRetentionLine must preserve the \"live UV values + burn estimates are never persisted\" lane intact."
    )
    #expect(
        !ProductCopy.cacheRetentionLine.contains("does not save UV values or burn estimates"),
        "cacheRetentionLine must not retain the old phrasing that contradicted the WI-7 forecast cache."
    )
}

/// Q3 — `lastUpdatedLine` in-app About must match the hosted privacy
/// policy `Last updated:` header (GDPR Art.12 transparency).
@Test func test_Q3_lastUpdatedLineMatchesHostedPolicy() throws {
    let appRoot = try appRootURL()
    let repoRoot = appRoot.deletingLastPathComponent()
    let policyURL = repoRoot.appendingPathComponent(".squad/files/privacy-policy.md")
    let policy = try String(contentsOf: policyURL, encoding: .utf8)

    // Extract the "Last updated:" date from the policy file.
    let pattern = #/\*\*Last updated:\*\*\s+(\d{4}-\d{2}-\d{2})/#
    guard let match = policy.firstMatch(of: pattern) else {
        Issue.record("privacy-policy.md must contain a `**Last updated:** YYYY-MM-DD` header")
        return
    }
    let policyDate = String(match.output.1)

    #expect(
        ProductCopy.lastUpdatedLine.contains(policyDate),
        "ProductCopy.lastUpdatedLine must contain the same date (\(policyDate)) as privacy-policy.md `**Last updated:**` (GDPR Art.12 transparency, Loop-13 Plunder L06)."
    )
}

/// Q4 — `ForecastPickerAttribution` tappable Link must carry the 44pt
/// HIG hit-target floor, parity with the sibling
/// `ForecastPickerEstimateInfoButton`.
@Test func test_Q4_forecastPickerAttributionMeets44ptTapTarget() throws {
    let appRoot = try appRootURL()
    let url = appRoot.appendingPathComponent("Sources/UVBurnTimer/ForecastPickerView.swift")
    let source = try String(contentsOf: url, encoding: .utf8)

    // Find the ForecastPickerAttribution identifier line.
    guard let identifierRange = source.range(of: ".accessibilityIdentifier(\"ForecastPickerAttribution\")") else {
        Issue.record("ForecastPickerAttribution accessibilityIdentifier not found")
        return
    }
    // Take the ~500 chars after the identifier to capture the modifier chain.
    let after = source[identifierRange.upperBound...]
    let window = String(after.prefix(500))

    #expect(
        window.contains("minHeight: 44"),
        "ForecastPickerAttribution Link must carry `.frame(...minHeight: 44...)` — HIG 44pt tap target (Iris L03)."
    )
    #expect(
        !window.contains("minHeight: 32"),
        "ForecastPickerAttribution Link must not still carry `minHeight: 32`."
    )
}

/// Q5 — Hosted privacy policy §6 must enumerate all three erasure
/// affordances (skin type, SPF, location) symmetrically.
@Test func test_Q5_privacyPolicyNamesAllThreeErasureAffordances() throws {
    let appRoot = try appRootURL()
    let repoRoot = appRoot.deletingLastPathComponent()
    let policyURL = repoRoot.appendingPathComponent(".squad/files/privacy-policy.md")
    let policy = try String(contentsOf: policyURL, encoding: .utf8)

    for affordance in [
        ProductCopy.clearStoredSkinTypeButtonTitle,
        ProductCopy.clearStoredSPFButtonTitle,
        ProductCopy.clearSavedLocationButtonTitle,
    ] {
        #expect(
            policy.contains(affordance),
            "privacy-policy.md must name \"\(affordance)\" as an Art.17 erasure path (Plunder L03 symmetry)."
        )
    }
}

/// Q6 — `build.sh` local-dev branch must honor `RUN_TESTS=false`. The
/// CI branch already does (line 158); this pins the local-dev branch
/// parity (Gaia L13d).
@Test func test_Q6_buildSctiptHonorsRunTestsInLocalDevBranch() throws {
    let appRoot = try appRootURL()
    let repoRoot = appRoot.deletingLastPathComponent()
    let buildScriptURL = repoRoot.appendingPathComponent("build.sh")
    let source = try String(contentsOf: buildScriptURL, encoding: .utf8)

    // Local-dev branch lives in the `else` block that runs Debug build +
    // tests + Release build. The tests stanza must now be gated on
    // `$run_tests`.
    guard let elseRange = source.range(of: "else\n  # Local dev mode") else {
        Issue.record("build.sh must contain the `else` block with `# Local dev mode` comment")
        return
    }
    // Look at the body of the else block — up to the closing `fi`.
    let after = source[elseRange.upperBound...]
    let localDevWindow = String(after.prefix(2000))

    #expect(
        localDevWindow.contains("if [[ \"$run_tests\" == \"true\" ]]; then"),
        "build.sh local-dev branch must gate the test xcodebuild invocation on `$run_tests` — parity with the CI branch (Gaia L13d)."
    )
}

// MARK: - Group R-bundle: Loop-13 follow-on HIGH closure
//
// Closes the next tier of HIGH-severity findings from the Loop-13
// parallel gap-analysis pass:
//
//   R1 — Iris L01: WHO-band pill text color (WCAG 2.2 AA).
//        Apple system colors against white at `.headline` size fall
//        below 4.5:1 for green/yellow/orange/red. The pill now uses
//        `.black` for every band below Extreme and reserves `.white`
//        for the Purple/Extreme band where black-on-purple < 4.5:1.
//
//   R2 — Kwame L13-3: `clearStoredPreferences` GDPR Art.17 completeness.
//        The function now also removes `lastRoundedCoordinate` and the
//        legacy `lastUVSnapshot` key. Both were named by the L1
//        storage-disclosure as device-resident state, but only the
//        UI-test-reset path was clearing them.
//
//   R3 — Suchi L01: "Clear stored skin type" must re-fire L1.
//        Asha P4 photosens cohort safety: the button now also clears
//        the disclaimer policy version on disk and immediately
//        re-presents the L1 cover so the photosens reach-back is on
//        screen before the next interaction. Source-text guards pin
//        the SettingsSheet wiring + the RootView helper.

private func _forecastPickerSourceForGroupR_bundleR() throws -> String {
    let appRoot = try appRootURL()
    let url = appRoot.appendingPathComponent("Sources/UVBurnTimer/ForecastPickerView.swift")
    return try String(contentsOf: url, encoding: .utf8)
}

/// R1 — WHO-band pill text color: `.black` for every band below
/// Extreme, `.white` only at the Extreme threshold (UVI ≥ 11).
@Test func test_R1_whoBandPillUsesBlackBelowExtreme() throws {
    let source = try _forecastPickerSourceForGroupR_bundleR()
    guard let range = source.range(of: "private func whoBandTextColor(for uvi: Double) -> Color {") else {
        Issue.record("whoBandTextColor function not found")
        return
    }
    // Take the next ~300 chars to capture the function body.
    let after = source[range.upperBound...]
    let body = String(after.prefix(300))

    // The body must read `uvi < 11 ? .black : .white` (or equivalent
    // boundary literal `11`) so that .systemPurple is the only band
    // whose pill text is white.
    #expect(
        body.contains("uvi < 11"),
        "whoBandTextColor must branch on `uvi < 11` to keep .white only for the Extreme band (Iris L01 WCAG 2.2 AA fix)."
    )
    #expect(
        !body.contains("uvi < 6"),
        "whoBandTextColor must not retain the legacy `uvi < 6` branch — that flipped to .white at the Moderate→High boundary and failed AA on orange + red bands."
    )
}

/// R2 — `clearStoredPreferences` must remove every Pattern-B persistence
/// key including the location pair (`lastRoundedCoordinate` +
/// `lastUVSnapshot`). The L1 storage-disclosure named these as
/// device-resident state; the function is now the single Art.17 entry
/// point.
@Test func test_R2_clearStoredPreferencesCoversLocationKeys() throws {
    let (defaults, suiteName) = makeIsolatedDefaults()
    defer { tearDownIsolatedDefaults(defaults, suiteName: suiteName) }

    // Seed every Pattern-B key including the location pair.
    defaults.set(FitzpatrickSkinType.typeIII.rawValue, forKey: UserPreferenceStorage.selectedSkinTypeKey)
    defaults.set(SPFLevel.spf50.rawValue, forKey: UserPreferenceStorage.selectedSPFKey)
    defaults.set(true, forKey: UserPreferenceStorage.locationRationaleAcknowledgedKey)
    defaults.set(UserPreferenceStorage.currentDisclaimerPolicyVersion, forKey: UserPreferenceStorage.disclaimerPolicyVersionKey)
    defaults.set("seeded-coordinate", forKey: UserPreferenceStorage.lastRoundedCoordinateKey)
    defaults.set("seeded-uv-snapshot", forKey: UserPreferenceStorage.legacyUVSnapshotKey)

    UserPreferenceStorage.clearStoredPreferences(from: defaults)

    // All six keys must be removed (object == nil, not just default-coerced).
    #expect(defaults.object(forKey: UserPreferenceStorage.selectedSkinTypeKey) == nil)
    #expect(defaults.object(forKey: UserPreferenceStorage.selectedSPFKey) == nil)
    #expect(defaults.object(forKey: UserPreferenceStorage.locationRationaleAcknowledgedKey) == nil)
    #expect(defaults.object(forKey: UserPreferenceStorage.disclaimerPolicyVersionKey) == nil)
    #expect(defaults.object(forKey: UserPreferenceStorage.lastRoundedCoordinateKey) == nil)
    #expect(defaults.object(forKey: UserPreferenceStorage.legacyUVSnapshotKey) == nil)
}

/// R2b — the key-name constants themselves must match the raw strings
/// used by `RootView`'s `@AppStorage` declarations in AppViews.swift.
/// A drift in either name (e.g. someone renames the @AppStorage key
/// without updating the constant) would silently bypass erasure.
@Test func test_R2b_locationKeyConstantsMatchAppStorageDeclarations() throws {
    let appRoot = try appRootURL()
    let appViews = try String(
        contentsOf: appRoot.appendingPathComponent("Sources/UVBurnTimer/AppViews.swift"),
        encoding: .utf8
    )
    #expect(
        appViews.contains("@AppStorage(\"\(UserPreferenceStorage.lastRoundedCoordinateKey)\")"),
        "AppViews.swift must declare `@AppStorage(\"\(UserPreferenceStorage.lastRoundedCoordinateKey)\")` so the centralized erasure constant matches the rendered key."
    )
    #expect(
        appViews.contains("@AppStorage(\"\(UserPreferenceStorage.legacyUVSnapshotKey)\")"),
        "AppViews.swift must declare `@AppStorage(\"\(UserPreferenceStorage.legacyUVSnapshotKey)\")` so the centralized erasure constant matches the rendered key."
    )
}

/// R3 — `SettingsSheet` Clear stored skin type button routes through
/// `onClearStoredSkinType` (parent-supplied closure) instead of
/// in-lining the wipe. The parent's closure
/// `clearStoredSkinTypeAndRequireReattestation` resets the policy
/// version key on disk + flips `acknowledgedDisclaimer = false` +
/// presents L1.
@Test func test_R3_clearStoredSkinTypeReFiresL1Disclaimer() throws {
    let appRoot = try appRootURL()
    let appViews = try String(
        contentsOf: appRoot.appendingPathComponent("Sources/UVBurnTimer/AppViews.swift"),
        encoding: .utf8
    )

    // SettingsSheet must carry the new callback.
    #expect(
        appViews.contains("let onClearStoredSkinType: () -> Void"),
        "SettingsSheet must declare `let onClearStoredSkinType: () -> Void` — Asha P4 photosens cohort safety (Suchi L01)."
    )

    // The Clear stored skin type Button must call `onClearStoredSkinType()`.
    guard let buttonRange = appViews.range(of: ".accessibilityIdentifier(\"ClearStoredSkinTypeButton\")") else {
        Issue.record("ClearStoredSkinTypeButton not found in SettingsSheet")
        return
    }
    // Look at the ~500 chars BEFORE the identifier (the Button body).
    let buttonBodyStart = appViews.index(buttonRange.lowerBound, offsetBy: -800, limitedBy: appViews.startIndex) ?? appViews.startIndex
    let beforeButton = String(appViews[buttonBodyStart..<buttonRange.lowerBound])
    #expect(
        beforeButton.contains("onClearStoredSkinType()"),
        "SettingsSheet ClearStoredSkinTypeButton must invoke `onClearStoredSkinType()` (Suchi L01)."
    )

    // RootView must define a helper that resets the policy version key,
    // calls `requireDisclaimerReattestation()`, and sets
    // `showDisclaimer = true`.
    guard let helperRange = appViews.range(of: "private func clearStoredSkinTypeAndRequireReattestation()") else {
        Issue.record("clearStoredSkinTypeAndRequireReattestation helper not found in RootView")
        return
    }
    let helperAfter = appViews[helperRange.upperBound...]
    let helperBody = String(helperAfter.prefix(800))
    #expect(
        helperBody.contains("disclaimerPolicyVersionKey"),
        "clearStoredSkinTypeAndRequireReattestation must remove `disclaimerPolicyVersionKey` so the next cold launch re-fires L1."
    )
    #expect(
        helperBody.contains("requireDisclaimerReattestation"),
        "clearStoredSkinTypeAndRequireReattestation must call `session.requireDisclaimerReattestation()` so the in-session ack is flipped."
    )
    #expect(
        helperBody.contains("showDisclaimer = true"),
        "clearStoredSkinTypeAndRequireReattestation must set `showDisclaimer = true` so L1 re-presents immediately after the Settings sheet dismisses."
    )
}

// MARK: - Group S: Loop-14 Bundle S — convergent HIGH closure
//
// Closes three HIGH-severity findings carried forward from the Loop-13
// gap-analysis pass (claude-opus-4.7-xhigh) and listed in the Loop-13
// closure log §"Backlog state (entering Loop-14)":
//
//   S5 — Gaia L13a/b/c (architecture / ADR drift x3):
//        ADR-0001 References § + Addendum + Lightweight-inlining
//        worked-example line citations drifted vs. the live
//        AppViews.swift / UVBurnTimerApp.swift / BurnTimeCalculatorTests.swift
//        positions during Loop-12/13 churn. The pre-existing EK2 guard
//        only fired against the original WI-l-era sentinels (1090/1102)
//        and silently accepted further drift. Bundle S refreshes the
//        citations to current values and adds a forward-pinning guard
//        (S5) that asserts the cited symbols actually resolve at the
//        current source positions — closing the silent-drift escape
//        hatch.
//
//   S6 — Plunder L01 (privacy-policy {TBD} placeholders):
//        `.squad/files/privacy-policy.md` ships with `{LAUNCH_DATE_TBD}`
//        and `{CONTACT_EMAIL_TBD}` placeholders that an automated agent
//        cannot fill (the launch date is a business decision; the
//        contact email is the repo owner's). Bundle S adds a
//        WI-21-style `Automation status` block to the stub explaining
//        the manual-completion gate, and adds a contract test that
//        keeps the TBDs visible (blank-sign-off = fail) until a
//        hardware/business-owner pass replaces them.
//
//   S7 — Ma-Ti L06 (test coverage — SPF on forecast):
//        The picker-driven `activeEstimate` path in
//        `RootView` feeds `session.selectedSPF` into
//        `BurnTimeCalculator.estimate(...)` so SPF applies symmetrically
//        to the live-now reading AND any future-hour forecast
//        selection. A regression that hardcoded `.unprotectedReference`
//        (or omitted the SPF parameter) would silently produce wrong
//        numbers for sunscreen-protected forecast hours. Bundle S adds
//        a source-text guard that pins the SPF wiring at the
//        `activeEstimate` call site.
//
// Test names use the S5/S6/S7 suffix to disambiguate from the
// pre-existing Loop-12 `test_S1`/`test_S2`/`test_S3` triad at lines
// 1715/1731/1762 and ADR-0002's reserved-but-unlanded `S4` slot.

// MARK: - Helper: resolve repo-root URLs for Group S source-text guards.

/// Returns the absolute URL of `<repo-root>/.squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md`.
private func _adr0001URLForGroupS() -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // UVBurnTimerCoreTests/
        .deletingLastPathComponent()  // Tests/
        .deletingLastPathComponent()  // app/
        .deletingLastPathComponent()  // <repo-root>
        .appendingPathComponent(".squad/decisions/adr/ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md")
}

/// Returns the absolute URL of `<repo-root>/.squad/files/privacy-policy.md`.
private func _privacyPolicyURLForGroupS() -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent(".squad/files/privacy-policy.md")
}

/// Returns the absolute URL of `<repo-root>/app/Sources/UVBurnTimer/UVBurnTimerApp.swift`.
private func _uvBurnTimerAppSwiftURLForGroupS() -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()  // app/
        .appendingPathComponent("Sources/UVBurnTimer/UVBurnTimerApp.swift")
}

/// Returns the 1-based line number of the first line in `source` that
/// contains `needle`, or nil if none.
private func _firstLineNumberContaining(_ needle: String, in source: String) -> Int? {
    let lines = source.components(separatedBy: "\n")
    for (idx, line) in lines.enumerated() where line.contains(needle) {
        return idx + 1
    }
    return nil
}

// MARK: - S5 — ADR-0001 line citations refreshed and forward-pinned

/// S5 — Gaia L13a/b/c (ADR drift x3): the ADR-0001 References § +
/// Addendum citations + Lightweight-inlining worked-example line
/// citations must match the *current* AppViews.swift /
/// UVBurnTimerApp.swift / BurnTimeCalculatorTests.swift positions.
/// This guard reads each cited symbol's actual source line and asserts
/// the ADR cites that same line, so further silent drift fails CI
/// instead of accumulating.
///
/// The pre-existing EK2 guard (`test_EK2_adr0001ReferencesPointAtCurrentLineNumbers`)
/// only checked that the *retired* WI-l-era sentinels (1090 / 1102)
/// were absent — that left the door open to unbounded forward drift
/// from the WI-gaia-gg refresh. S5 closes the door by anchoring each
/// citation to the symbol it is supposed to point at.
///
/// Test name uses the S5 suffix to disambiguate from the pre-existing
/// Loop-12 `test_S1_toolbarInfoButtonRoutesToHighlightedAboutView` /
/// `test_S2_aboutEstimateApplicabilityHeaderHasStableIdentifier` /
/// `test_S3_toolbarKeepsBothSettingsAndEstimateInfoButtons` triad
/// (BurnTimeCalculatorTests.swift line 1715+). ADR-0002 reserved an
/// `S4_toolbarGearButtonUsesTopBarTrailingNotPrimaryAction` slot that
/// has not yet landed in the test suite; S5 is therefore the next
/// available number in the S-prefixed bundle.
@Test func test_S5_adr0001CitationsMatchLiveSourceLineNumbers() throws {
    let adr = try String(contentsOf: _adr0001URLForGroupS(), encoding: .utf8)
    let appViews = try _appViewsSourceForGroupR()
    let appSwift = try String(contentsOf: _uvBurnTimerAppSwiftURLForGroupS(), encoding: .utf8)
    let tests = try String(contentsOf: URL(fileURLWithPath: #filePath), encoding: .utf8)

    // Each citation is (description, ADR substring, source string, anchor).
    // The ADR must contain the substring; the anchor must resolve at the
    // line stated in the substring.
    struct Citation {
        let description: String
        let adrSubstring: String
        let source: String
        let anchor: String
        let expectedLine: Int
    }

    // Pre-compute current lines for each anchor so the test mirrors the
    // file rather than re-hard-coding numerics.
    let heroStructLine = _firstLineNumberContaining("struct HeroTimerCard: View", in: appViews)
    let heroDelegateLine = _firstLineNumberContaining("private var heroTimerCardView: some View", in: appViews)
    // RootView's NavigationStack wrapper — the first `NavigationStack {`
    // occurrence in AppViews.swift is RootView's (inside `navigationStackBase`).
    // The ADR Alternative 3 + References § both cite this line as the
    // identity wrapper that *did not* substitute for the struct boundary.
    let navStackBaseLine = _firstLineNumberContaining("NavigationStack {", in: appViews)
    let r1Line = _firstLineNumberContaining("@Test func test_R1_heroTimerCardWrapperStructStillExists()", in: tests)
    let r2Line = _firstLineNumberContaining("@Test func test_R2_rootViewDelegatesToHeroTimerCardConstructor()", in: tests)
    let settingsSheetLine = _firstLineNumberContaining(".sheet(isPresented: $showSettings)", in: appViews)
    let skinTypeEditSheetLine = _firstLineNumberContaining(".sheet(isPresented: $showSkinTypeEdit)", in: appViews)
    let disclaimerCoverLine = _firstLineNumberContaining("isPresented: $showDisclaimer,", in: appSwift)
    let skinTypeOnboardingCoverLine = _firstLineNumberContaining(".skinTypePresentation(isPresented: $showSkinTypeOnboarding)", in: appSwift)
    let estimateInfoButtonLine = _firstLineNumberContaining("NavigationLink(destination: AboutView(highlightEstimateApplicability: true)) {", in: appViews)
    let estimateInfoIdentifierLine = _firstLineNumberContaining(".accessibilityIdentifier(\"EstimateInfoButton\")", in: appViews)
    // PersistentFooter's AboutView push — search for the AboutView call
    // AFTER the `struct PersistentFooter: View` declaration so we don't
    // pick up the toolbar ⓘ at line 123 or the DisclaimerCover sheet push
    // at line 1263.
    let persistentFooterAboutLine = { () -> Int? in
        let lines = appViews.components(separatedBy: "\n")
        guard let pfStart = lines.firstIndex(where: { $0.contains("struct PersistentFooter: View") }) else {
            return nil
        }
        for idx in pfStart..<lines.count where lines[idx].contains("AboutView(highlightEstimateApplicability: true)") {
            return idx + 1
        }
        return nil
    }()
    let skinTypeChipLine = _firstLineNumberContaining("private var skinTypeChip: some View", in: appViews)
    let locationChipLine = _firstLineNumberContaining("private var locationChip: some View", in: appViews)
    let spfChipLine = _firstLineNumberContaining("private var spfChip: some View", in: appViews)

    #expect(heroStructLine != nil, "struct HeroTimerCard must exist in AppViews.swift")
    #expect(heroDelegateLine != nil, "RootView.heroTimerCardView must exist in AppViews.swift")
    #expect(navStackBaseLine != nil, "RootView NavigationStack wrapper must exist in AppViews.swift")
    #expect(r1Line != nil, "test_R1_heroTimerCardWrapperStructStillExists must exist in BurnTimeCalculatorTests.swift")
    #expect(r2Line != nil, "test_R2_rootViewDelegatesToHeroTimerCardConstructor must exist in BurnTimeCalculatorTests.swift")
    #expect(settingsSheetLine != nil, "Settings .sheet(isPresented: $showSettings) must exist in AppViews.swift")
    #expect(skinTypeEditSheetLine != nil, "SkinTypeEdit .sheet(isPresented: $showSkinTypeEdit) must exist in AppViews.swift")
    #expect(disclaimerCoverLine != nil, "$showDisclaimer cover binding must exist in UVBurnTimerApp.swift")
    #expect(skinTypeOnboardingCoverLine != nil, ".skinTypePresentation must exist in UVBurnTimerApp.swift")
    #expect(estimateInfoButtonLine != nil, "EstimateInfoButton NavigationLink must exist in AppViews.swift")
    #expect(estimateInfoIdentifierLine != nil, "EstimateInfoButton accessibility identifier must exist in AppViews.swift")
    #expect(persistentFooterAboutLine != nil, "PersistentFooter's AboutView push must exist in AppViews.swift (second occurrence of AboutView(highlightEstimateApplicability: true))")
    #expect(skinTypeChipLine != nil, "private var skinTypeChip must exist in AppViews.swift")
    #expect(locationChipLine != nil, "private var locationChip must exist in AppViews.swift")
    #expect(spfChipLine != nil, "private var spfChip must exist in AppViews.swift")

    // The ADR's References § block + Addendum + worked examples must
    // mention the current line numbers. The test refuses to be brittle
    // about column-precise formatting: it only asserts the integer line
    // is present in the file. Each ADR-author convention (e.g. `lines
    // **218–232**` or `at `AppViews.swift:68`` or `at line **88**`) is
    // tolerated as long as the integer appears somewhere in the ADR.
    let expectations: [(label: String, line: Int?)] = [
        ("struct HeroTimerCard: View declaration line",     heroStructLine),
        ("RootView.heroTimerCardView delegation site line", heroDelegateLine),
        ("navigationStackBase NavigationStack wrapper",     navStackBaseLine),
        ("test_R1 line in BurnTimeCalculatorTests.swift",   r1Line),
        ("test_R2 line in BurnTimeCalculatorTests.swift",   r2Line),
        ("$showSettings .sheet line in AppViews.swift",     settingsSheetLine),
        ("$showSkinTypeEdit .sheet line in AppViews.swift", skinTypeEditSheetLine),
        ("$showDisclaimer cover line in UVBurnTimerApp.swift",        disclaimerCoverLine),
        ("$showSkinTypeOnboarding cover line in UVBurnTimerApp.swift", skinTypeOnboardingCoverLine),
        ("EstimateInfoButton NavigationLink line in AppViews.swift", estimateInfoButtonLine),
        ("EstimateInfoButton accessibility identifier line",         estimateInfoIdentifierLine),
        ("PersistentFooter AboutView push line",            persistentFooterAboutLine),
        ("skinTypeChip line",                                skinTypeChipLine),
        ("locationChip line",                                locationChipLine),
        ("spfChip line",                                     spfChipLine),
    ]
    for expectation in expectations {
        guard let line = expectation.line else { continue }
        #expect(
            adr.contains(String(line)),
            "ADR-0001 must mention the current source line \(line) for \(expectation.label). If you moved the symbol, refresh the citation in the ADR; do not let drift accumulate silently (Gaia L13a/b/c)."
        )
    }

    // The retired WI-l-era sentinels (1090/1102) — kept as a guard so we
    // don't accidentally re-introduce them.
    #expect(
        !adr.contains("line **1090**"),
        "ADR-0001 must not cite the retired pre-Loop-10 R1 line (1090)."
    )
    #expect(
        !adr.contains("line **1102**"),
        "ADR-0001 must not cite the retired pre-Loop-10 R2 line (1102)."
    )

    // The pre-Loop-13 R1/R2 sentinels (1307/1319) — must also not appear
    // in the current ADR; the test_EK2 retired-line guard would still
    // pass if someone left those in by accident, but the citations
    // should follow the live test positions.
    #expect(
        !adr.contains("test_R1_heroTimerCardWrapperStructStillExists` — line **1307**"),
        "ADR-0001 must not cite the retired Loop-13-era R1 line (1307); refresh to the current line."
    )
    #expect(
        !adr.contains("test_R2_rootViewDelegatesToHeroTimerCardConstructor` — line **1319**"),
        "ADR-0001 must not cite the retired Loop-13-era R2 line (1319); refresh to the current line."
    )
}

// MARK: - S6 — Privacy-policy {TBD} automation-status block

/// S6 — Plunder L01: `.squad/files/privacy-policy.md` carries two
/// load-bearing placeholders — `{LAUNCH_DATE_TBD}` (the Effective date
/// header) and `{CONTACT_EMAIL_TBD}` (the developer contact +
/// privacy-questions footer). Neither can be filled by an automated
/// agent: the launch date is a business decision the repo owner makes
/// at App Store submission time, and the contact email is the repo
/// owner's personal/business email.
///
/// To keep this gate visible (and prevent the policy from shipping
/// with literal `{...TBD}` markers in the App Store URL), Bundle S
/// adds a WI-21-style `Automation status` block to the policy stub
/// that explicitly calls out the manual-completion ownership. This
/// guard asserts:
///
/// 1. The placeholders are still present (the policy has not shipped
///    yet — replacing them prematurely with fake values would be
///    worse than the visible TBD).
/// 2. The `Automation status` block exists and names the manual-
///    completion gate.
/// 3. The block also names the responsible role (Plunder + repo
///    owner) so future loops know who to ping.
@Test func test_S6_privacyPolicyTBDsCarryAutomationStatusBlock() throws {
    let policy = try String(contentsOf: _privacyPolicyURLForGroupS(), encoding: .utf8)

    // (1) Placeholders are still visible — blank "fill it in or ship
    //     broken" is the gate.
    #expect(
        policy.contains("{LAUNCH_DATE_TBD}"),
        "privacy-policy.md must keep `{LAUNCH_DATE_TBD}` until the repo owner fills the App Store launch date at submission. A premature replacement (e.g. literal `TBD`, `2026-01-01`, or a guess) violates the truthfulness contract (Plunder L01)."
    )
    #expect(
        policy.contains("{CONTACT_EMAIL_TBD}"),
        "privacy-policy.md must keep `{CONTACT_EMAIL_TBD}` until the repo owner fills a real contact email. Faking the address would violate GDPR Art.12 transparency + App Store §5.1.1 (Plunder L01)."
    )

    // (2) The Automation status block must exist and explain the gate.
    #expect(
        policy.contains("Automation status (WI-21"),
        "privacy-policy.md must carry a WI-21-style `Automation status` block explaining why the {LAUNCH_DATE_TBD} + {CONTACT_EMAIL_TBD} placeholders cannot be filled by an automated agent (Plunder L01)."
    )

    // (3) The block names the responsible role(s).
    #expect(
        policy.contains("repo owner"),
        "privacy-policy.md Automation status block must name the repo owner as the responsible role for filling the App Store launch date + contact email (Plunder L01)."
    )

    // (4) The block names the load-bearing placeholders directly so a
    //     future reader can search for either marker and land on the
    //     block.
    #expect(
        policy.contains("LAUNCH_DATE_TBD") && policy.contains("CONTACT_EMAIL_TBD"),
        "privacy-policy.md Automation status block must name BOTH `LAUNCH_DATE_TBD` and `CONTACT_EMAIL_TBD` so either grep lands on the block."
    )

    // (5) The block must say a blank/TBD-still-present block is a
    //     submission-blocker, mirroring the iris-contrast-qa-checklist
    //     and iris-launch-readiness-checklist conventions.
    #expect(
        policy.contains("blocks") || policy.contains("blocker") || policy.contains("must be filled"),
        "privacy-policy.md Automation status block must mark unfilled TBDs as a submission blocker (mirrors `iris-*-checklist.md` blocking-on-blank convention)."
    )
}

// MARK: - S7 — ForecastPicker SPF wiring contract

/// S7 — Ma-Ti L06: `RootView.activeEstimate` (the SPF-aware burn
/// estimate driven by the WI-7 forecast picker) must feed
/// `session.selectedSPF` into `BurnTimeCalculator.estimate(...)`.
/// A regression that hardcoded `.unprotectedReference` (or any
/// other constant) would silently strip sunscreen protection from
/// every future-hour selection while leaving the live-now reading
/// correct — the worst kind of inconsistency for a safety surface.
///
/// This guard pins the SPF wiring at the activeEstimate call site so
/// the next refactor cannot omit `session.selectedSPF` without
/// breaking CI.
@Test func test_S7_activeEstimateAppliesSelectedSPFToForecastSelection() throws {
    let source = try _appViewsSourceForGroupR()

    // The activeEstimate computed property is the canonical forecast-
    // aware estimate source for the hero card.
    guard let activeEstimateRange = source.range(of: "private var activeEstimate: BurnTimeEstimate?") else {
        Issue.record("RootView.activeEstimate computed property not found in AppViews.swift")
        return
    }

    // Body slice — look ~500 chars after the declaration. The body is
    // small (≤ 10 lines) so 500 chars is generous.
    let bodyStart = activeEstimateRange.upperBound
    let bodyEnd = source.index(bodyStart, offsetBy: 500, limitedBy: source.endIndex) ?? source.endIndex
    let body = String(source[bodyStart..<bodyEnd])

    // It must invoke BurnTimeCalculator.estimate(...).
    #expect(
        body.contains("BurnTimeCalculator.estimate("),
        "RootView.activeEstimate must invoke `BurnTimeCalculator.estimate(...)` (Ma-Ti L06)."
    )

    // It must pass `session.selectedSPF` as the spf parameter —
    // hardcoding `.unprotectedReference`, `.spf30`, etc. would silently
    // break SPF wiring for forecast picks.
    #expect(
        body.contains("spf: session.selectedSPF"),
        "RootView.activeEstimate must pass `spf: session.selectedSPF` so SPF applies symmetrically to live + forecast estimates (Ma-Ti L06). Hardcoding any other SPFLevel would strip sunscreen protection from forecast picks."
    )

    // It must also pass the active UV index (forecast value or live
    // fallback) — `activeUVIndex` is the source-of-truth here.
    #expect(
        body.contains("activeUVIndex"),
        "RootView.activeEstimate must read `activeUVIndex` (the forecast-or-live UV) — not the bare `uvIndex` live state (Ma-Ti L06)."
    )

    // And the skin type must come from `session.selectedSkinType`.
    #expect(
        body.contains("session.selectedSkinType"),
        "RootView.activeEstimate must read `skinType:` from `session.selectedSkinType` (Ma-Ti L06)."
    )
}

// MARK: - Group T: WI-bundleT — Loop-14 follow-on HIGH closure
//
// T1 — Iris L02 (Loop-13) — WCAG 2.1 SC 1.4.3 contrast on the L1 cover
// photosensitizer disclaimer text.
//
// The pre-Loop-14 render shape was:
//
//     Label(ProductCopy.photosensitizerDisclaimerLine,
//           systemImage: "exclamationmark.triangle")
//         .font(.callout.weight(.semibold))
//         .foregroundStyle(.orange)
//
// `.foregroundStyle(.orange)` applied to a Label tints both the icon
// AND the text. SwiftUI's `.orange` maps to `UIColor.systemOrange`,
// which against the `.regularMaterial` cover background measures
// roughly 2.3–2.5:1 in Light Mode + Standard Contrast — a WCAG 2.1
// SC 1.4.3 (Contrast Minimum, 4.5:1) failure for the *text* path.
// The text is health-critical for Asha (P4 Accutane / photosensitizer
// cohort): she must be able to read "Photosensitizing medications,
// conditions, recent skin treatments, and pregnancy can make this
// estimate overstate your burn window." at every contrast mode.
//
// Bundle T's fix is to decompose the Label into separate text and
// icon closures so the *text* inherits `.primary` (system-adaptive
// label color that meets ≥ 7:1 against any system background in both
// Standard and Increased contrast) while the *icon* keeps the orange
// warning hue as a decorative visual signal. The icon's accessibility
// remains masked by the outer `.accessibilityLabel(ProductCopy
// .photosensitizerDisclaimerLine)` + `.accessibilityElement(children:
// .combine)` (pinned by Group JJ5), so the rendered VoiceOver string
// is unchanged.
//
// The pre-existing decorative 48pt `exclamationmark.triangle.fill`
// glyph above the title block (DisclaimerCover line ~1190) remains
// `.foregroundStyle(.orange)` because it is `.accessibilityHidden(
// true)` AND it is a pure-icon surface (no text payload), so WCAG
// SC 1.4.3 does not apply to it. The 4.5:1 floor only governs *text*
// and *images of text*.

/// T1 — DisclaimerCover photosens disclaimer Label renders the text
/// in `.primary` (not `.orange`) for WCAG 2.1 SC 1.4.3 compliance.
///
/// **Why this guard matters:** SwiftUI's `.orange` against the
/// `.regularMaterial` L1 cover background measures ~2.3–2.5:1 in
/// Light Mode + Standard Contrast — a WCAG 2.1 SC 1.4.3 (4.5:1)
/// failure for text content. The photosens disclaimer line is the
/// load-bearing surface for the Asha (P4 Accutane / photosensitizer)
/// cohort and must be legible at every contrast mode. Pinning the
/// `.foregroundStyle(.primary)` modifier on the text closure ensures
/// the system-adaptive label color is used (≥ 7:1 against any system
/// background). A future "tighten styling" refactor that re-applies
/// `.foregroundStyle(.orange)` to the Label as a whole would silently
/// regress contrast for Asha and fail Iris L02 again.
///
/// **Decorative icon retention:** the `exclamationmark.triangle`
/// SF Symbol inside the Label is preserved with `.foregroundStyle(
/// .orange)` because it is a pure-icon surface (no text payload) and
/// the outer `.accessibilityLabel(photosensitizerDisclaimerLine)` +
/// `.accessibilityElement(children: .combine)` keeps VoiceOver output
/// identical to the pre-T1 shape. SC 1.4.3 does not apply to pure
/// icons; SC 1.4.11 (3:1 for non-text contrast) is met by `.orange`
/// against `.regularMaterial`.
@Test func test_T1_photosensitizerLineLabelOnL1CoverUsesPrimaryTextColor() throws {
    let source = try _appViewsSourceForGroupR()

    // Anchor on the DisclaimerCover declaration so we scope the
    // assertions to the L1 cover render site and not, e.g., the
    // Settings sheet or About sheet.
    guard let coverStart = source.range(of: "struct DisclaimerCover: View")?.lowerBound else {
        Issue.record("DisclaimerCover struct declaration not found in AppViews.swift")
        return
    }

    // Scan ~6000 chars into the body — DisclaimerCover's body is
    // approximately 100 LOC (~4500 chars) including the comment block,
    // so 6000 chars is a comfortable upper bound that stops well
    // before the next top-level struct.
    let coverScanEnd = source.index(coverStart, offsetBy: 6000, limitedBy: source.endIndex) ?? source.endIndex
    let coverRegion = String(source[coverStart..<coverScanEnd])

    // (a) The text render must use `.foregroundStyle(.primary)` —
    // this is the WCAG-compliant rendering. Look for the Text node
    // and assert its immediate modifier chain contains `.primary`.
    guard let textHit = coverRegion.range(of: "Text(ProductCopy.photosensitizerDisclaimerLine)") else {
        Issue.record(
            "DisclaimerCover must render `Text(ProductCopy.photosensitizerDisclaimerLine)` inside a decomposed Label so the text color can be controlled independently of the icon hue. The pre-Loop-14 shape `Label(ProductCopy.photosensitizerDisclaimerLine, systemImage: ...).foregroundStyle(.orange)` failed WCAG 2.1 SC 1.4.3 (~2.4:1 in Light Mode Std). (WI-bundleT / Iris L02 — Loop-14)"
        )
        return
    }

    // Look at the next 300 chars after the Text node for the modifier
    // chain. The fix attaches `.foregroundStyle(.primary)` directly to
    // the Text inside the Label's content closure.
    let modifierScanEnd = coverRegion.index(textHit.upperBound, offsetBy: 300, limitedBy: coverRegion.endIndex) ?? coverRegion.endIndex
    let modifierRegion = String(coverRegion[textHit.upperBound..<modifierScanEnd])
    #expect(
        modifierRegion.contains(".foregroundStyle(.primary)"),
        "L1 cover photosens text must use `.foregroundStyle(.primary)` for WCAG 2.1 SC 1.4.3 (4.5:1) — SwiftUI `.orange` against `.regularMaterial` measures ~2.4:1 in Light Mode Std Contrast (FAIL AA). The photosens text is health-critical for Asha (P4 Accutane / photosensitizer cohort). (WI-bundleT / Iris L02 — Loop-14)"
    )

    // (b) The decorative `exclamationmark.triangle` icon inside the
    // Label may still use `.foregroundStyle(.orange)` because it is a
    // pure-icon surface (no text payload). Verify the icon is still
    // present somewhere in the cover — the orange warning hue must
    // remain as a visual signal.
    #expect(
        coverRegion.contains("Image(systemName: \"exclamationmark.triangle\")"),
        "L1 cover must still render an inline `exclamationmark.triangle` SF Symbol inside the photosens Label as the decorative warning glyph (WI-bundleT / Iris L02)."
    )
    #expect(
        coverRegion.contains(".foregroundStyle(.orange)"),
        "L1 cover must retain `.foregroundStyle(.orange)` on a decorative surface — at minimum the 48pt `exclamationmark.triangle.fill` glyph and/or the inline icon — so the warning-hue visual signal remains (WI-bundleT / Iris L02)."
    )

    // (c) The old failing shape must not return — the Label initializer
    // that takes a title + systemImage applies the foreground style
    // uniformly to both the icon and the text, which is exactly the
    // pattern that failed WCAG. Pin its absence so a future refactor
    // cannot regress.
    #expect(
        !coverRegion.contains("Label(ProductCopy.photosensitizerDisclaimerLine, systemImage:"),
        "L1 cover photosens Label must not use the title-string + systemImage Label initializer — that shape applies `.foregroundStyle(...)` uniformly to icon + text and was the source of the Iris L02 contrast failure. Use the decomposed `Label { Text(... ).foregroundStyle(.primary) } icon: { Image(... ).foregroundStyle(.orange) }` shape instead. (WI-bundleT / Iris L02 — Loop-14)"
    )
}

/// T2 — Iris contrast-QA checklist tracks the new L1 cover photosens
/// disclaimer row so the next physical-device contrast pass
/// re-measures it after the Bundle T fix.
///
/// **Why this guard matters:** the contrast-QA checklist is the
/// hardware-gated manual sign-off surface (per WI-21). When a render
/// surface changes color tokens, the checklist must reflect the new
/// surface so the next TestFlight gate doesn't accidentally skip it.
/// Bundle T introduces a new color-token boundary (orange icon +
/// primary text on `.regularMaterial`) that needs to be measured on
/// device. This guard pins the checklist row title until the
/// hardware-equipped owner records the actual ratio.
@Test func test_T2_irisContrastChecklistTracksL1CoverPhotosensRow() throws {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let checklistURL = testFileURL
        .deletingLastPathComponent()  // UVBurnTimerCoreTests/
        .deletingLastPathComponent()  // Tests/
        .deletingLastPathComponent()  // app/
        .deletingLastPathComponent()  // repo root
        .appendingPathComponent(".squad/files/iris-contrast-qa-checklist.md")
    let contents = try String(contentsOf: checklistURL, encoding: .utf8)

    // The new row title — kept stable so the manual sign-off block
    // and the post-fix re-measurement are both traceable to WI-bundleT.
    #expect(
        contents.contains("L1 cover photosens disclaimer Label text"),
        "iris-contrast-qa-checklist.md must list a row for the L1 cover photosens disclaimer Label text — Bundle T (Iris L02 — Loop-14) decomposed the Label so the text now uses `.primary` and the icon keeps `.orange`. The next hardware-gated contrast pass must re-measure this row."
    )
    #expect(
        contents.contains("WI-bundleT") || contents.contains("Iris L02"),
        "iris-contrast-qa-checklist.md row for the L1 cover photosens disclaimer must reference Bundle T / Iris L02 so the hardware-equipped reviewer knows which fix introduced the new color-token boundary."
    )
}

// MARK: - Group U: WI-bundleU — Loop-15 Plunder L02 + L07 closure
//
// Two HIGH-severity Plunder findings carried forward from the Loop-13
// parallel gap-analysis pass and re-flagged in the Loop-14 closure log:
//
// U1 — Plunder L02 (Loop-13): the hosted privacy-policy stub does NOT
//      currently disclose an EU representative under GDPR Art.27.
//      Article 27 of the GDPR requires non-EU controllers/processors
//      offering goods or services to EU/EEA data subjects to designate
//      a representative *in writing* in the Union, except for narrow
//      processing-frequency / risk-level exemptions. The UV Burn Timer
//      Apple Weather pipeline transmits rounded coordinates each time a
//      user taps Recalculate, which is not "occasional" under the
//      EDPB Art.27 Guidelines 03/2021 (§3.1); a designated rep is
//      therefore required before EU/EEA App Store distribution.
//
//      Like the `{LAUNCH_DATE_TBD}` and `{CONTACT_EMAIL_TBD}`
//      placeholders that Bundle S §S6 enrolled, the EU-rep contact
//      information is **outside-of-codebase** business data the repo
//      owner must supply — an automated agent cannot invent a UK/EU
//      rep on the owner's behalf. Bundle U therefore adds §15 with a
//      `{EU_REPRESENTATIVE_TBD}` placeholder and extends the
//      `Automation status` block to enroll the new TBD under the
//      Plunder L02 manual-completion gate, mirroring §S6's pattern.
//
// U2 — Plunder L07 (Loop-13): the Settings sheet does NOT currently
//      surface the "Informational only — not medical advice."
//      disclaimer reach-back. The Settings sheet is presented modally
//      and covers the persistent footer that normally carries
//      `ProductCopy.disclaimerLinkLabel`, so a user in the Settings
//      sheet has no in-modal cue that the app is informational and not
//      medical advice. Plunder's regulatory floor (Loop-12
//      `.squad/designs/plunder-disclaimer-relocation-floor.md`)
//      requires the not-medical-advice line to remain reachable from
//      *every* high-level surface where the user is modifying inputs
//      that drive the burn-time model. The fix is to add a Disclaimer
//      Section to the SettingsSheet `Form` that renders the same
//      `ProductCopy.disclaimerLinkLabel` line that the persistent
//      footer carries. Identifier `SettingsDisclaimerLine` is added so
//      XCUI can find it, and the substring guard below pins the
//      ProductCopy routing.

/// U1 — Privacy-policy stub carries a §15 EU representative section
/// with a `{EU_REPRESENTATIVE_TBD}` placeholder + automation-status
/// block (WI-21-style — Plunder L02).
///
/// **Why this guard matters:** GDPR Art.27 requires non-EU controllers
/// offering services to EU/EEA data subjects to designate a
/// representative in the Union before processing begins. UV Burn
/// Timer's Apple Weather pipeline transmits rounded coordinates each
/// time the user taps Recalculate (the EDPB Art.27 Guidelines
/// 03/2021 §3.1 do not classify this as "occasional" processing,
/// so the carve-out at Art.27(2)(a) does not apply). Shipping the
/// hosted policy without a designated rep — or without at least a
/// visible `{TBD}` placeholder that flags the gap to App Store
/// reviewers and EU counsel — would violate GDPR Art.12 transparency
/// AND App Store §5.1.1.4 ("clear and accessible information about
/// your privacy practices"). The fix mirrors the Bundle S §S6 pattern:
/// add the section, flag the placeholder as a submission blocker, and
/// pin it with a contract test so the placeholder stays visible until
/// the repo owner + Plunder fill it in.
///
/// **Manual-completion gate:** the actual representative's name +
/// EU/EEA address + contact email must come from the repo owner. An
/// automated agent cannot designate an EU rep on the owner's behalf
/// (the legal contract is between the controller and the rep firm).
/// Filling the TBD with a guess would violate the Art.27 written-
/// designation requirement.
@Test func test_U1_privacyPolicyDeclaresEURepresentativeSectionWithTBDPlaceholder() throws {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let policyURL = testFileURL
        .deletingLastPathComponent()  // UVBurnTimerCoreTests/
        .deletingLastPathComponent()  // Tests/
        .deletingLastPathComponent()  // app/
        .deletingLastPathComponent()  // repo root
        .appendingPathComponent(".squad/files/privacy-policy.md")
    let policy = try String(contentsOf: policyURL, encoding: .utf8)

    // The Art.27 section heading must exist. Wording is locked to the
    // GDPR Article number so EU counsel can find the section without
    // ambiguity.
    #expect(
        policy.contains("## 15. EU representative") || policy.contains("## 15. EU/EEA representative"),
        ".squad/files/privacy-policy.md must declare a §15 EU representative section (GDPR Art.27). Non-EU controllers offering services to EU/EEA data subjects must designate a representative under Art.27; shipping the hosted policy without one — or without a visible placeholder — violates Art.12 transparency. (WI-bundleU / Plunder L02 — Loop-15)"
    )
    #expect(
        policy.contains("Art.27") || policy.contains("Article 27"),
        ".squad/files/privacy-policy.md §15 must cite GDPR Art.27 explicitly so EU counsel can verify the legal basis for the section. (WI-bundleU / Plunder L02 — Loop-15)"
    )

    // The TBD placeholder must be present until the repo owner
    // designates an actual representative. Mirrors §S6's
    // `{LAUNCH_DATE_TBD}` / `{CONTACT_EMAIL_TBD}` pattern.
    #expect(
        policy.contains("{EU_REPRESENTATIVE_TBD}"),
        ".squad/files/privacy-policy.md §15 must carry a `{EU_REPRESENTATIVE_TBD}` placeholder until the repo owner designates an actual Art.27 representative. An automated agent cannot designate a rep on the owner's behalf — the designation is a written legal contract with a EU/EEA-resident party. (WI-bundleU / Plunder L02 — Loop-15)"
    )

    // The automation-status block must explicitly call out Plunder L02
    // so the manual-completion gate is traceable. Mirrors the §S6 and
    // WI-21 conventions.
    #expect(
        policy.contains("Plunder L02"),
        ".squad/files/privacy-policy.md must reference Plunder L02 in the automation-status section so the manual-completion gate is traceable to the Loop-13 finding. (WI-bundleU / Plunder L02 — Loop-15)"
    )

    // The automation-status block must mark the placeholder as a
    // submission blocker, mirroring the §S6 pattern. The word
    // "submission blocker" is the agreed-on Plunder vocabulary across
    // §S6 + §15.
    #expect(
        policy.range(of: "submission blocker", options: .caseInsensitive) != nil,
        ".squad/files/privacy-policy.md automation-status block must treat the EU-rep TBD as a `submission blocker` — shipping the App Store URL with literal `{EU_REPRESENTATIVE_TBD}` would violate App Store §5.1.1.4 + GDPR Art.12 transparency. (WI-bundleU / Plunder L02 — Loop-15)"
    )
}

/// U2 — SettingsSheet renders the `disclaimerLinkLabel` footnote
/// (`Informational only. Not medical advice.`) so the modal in-Settings
/// surface keeps the not-medical-advice reach-back visible.
///
/// **Why this guard matters:** the Settings sheet is presented modally
/// and covers the `PersistentFooter` that normally carries the
/// `ProductCopy.disclaimerLinkLabel` reach-back. A user in Settings —
/// adjusting skin type, SPF, or any other input that drives the
/// burn-time model — has no in-modal cue that the app is informational
/// only and not medical advice. Plunder's regulatory floor
/// (`.squad/designs/plunder-disclaimer-relocation-floor.md`) requires
/// the not-medical-advice line to remain reachable from every
/// high-level surface where the user is modifying model inputs.
/// Bundle U adds a `Disclaimer` Section to the Settings Form that
/// renders the same `ProductCopy.disclaimerLinkLabel` line that the
/// persistent footer carries. The text is routed through `ProductCopy`
/// so the substring guard (Group EH) keeps the wording aligned with
/// the hosted privacy policy.
@Test func test_U2_settingsSheetRendersDisclaimerLineFromProductCopy() throws {
    let source = try _appViewsSourceForGroupR()

    // Anchor on the SettingsSheet declaration so the assertion is
    // scoped to the Settings sheet and not, e.g., the AboutView.
    guard let settingsStart = source.range(of: "struct SettingsSheet: View")?.lowerBound else {
        Issue.record("SettingsSheet struct declaration not found in AppViews.swift")
        return
    }

    // Scan ~7000 chars into the body — SettingsSheet's body is ~130
    // LOC (~5500 chars after Bundle R's Asha P4 routing additions and
    // Bundle U's Disclaimer Section), so 7000 chars is a comfortable
    // upper bound that stops before the next top-level struct
    // (SkinTypeEditView).
    let settingsScanEnd = source.index(settingsStart, offsetBy: 7000, limitedBy: source.endIndex) ?? source.endIndex
    let settingsRegion = String(source[settingsStart..<settingsScanEnd])

    // (a) The Settings sheet must render `Text(ProductCopy
    // .disclaimerLinkLabel)` — the same line the PersistentFooter
    // carries. Routing through `ProductCopy` keeps the substring guard
    // (Group EH) honest and prevents copy drift.
    #expect(
        settingsRegion.contains("Text(ProductCopy.disclaimerLinkLabel)"),
        "SettingsSheet must render `Text(ProductCopy.disclaimerLinkLabel)` so the modal Settings sheet keeps the not-medical-advice reach-back visible — the PersistentFooter that normally carries this line is covered by the Settings modal. (WI-bundleU / Plunder L07 — Loop-15)"
    )

    // (b) The Settings disclaimer text must carry a stable
    // `accessibilityIdentifier` so XCUI smoke can find it without
    // matching against the localized string. The identifier name is
    // pinned here so a future rename doesn't silently break the XCUI
    // pickup.
    #expect(
        settingsRegion.contains(".accessibilityIdentifier(\"SettingsDisclaimerLine\")"),
        "SettingsSheet disclaimer line must carry `.accessibilityIdentifier(\"SettingsDisclaimerLine\")` for XCUI pickup. (WI-bundleU / Plunder L07 — Loop-15)"
    )
}


