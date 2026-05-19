import Foundation
import Testing
@testable import UVBurnTimerCore

@Test func typeOneWithoutSPFAtUVTenIsShortWindow() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeI,
        spf: .none,
        uvIndex: 10
    )

    #expect(estimate.roundedDisplayMinutes == 13)
    #expect(estimate.tier == .short)
    #expect(estimate.displayText == "~13 min")
}

@Test func typeThreeWithSPFThirtyAtUVEightCapsDisplayButKeepsRawModel() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .spf30,
        uvIndex: 8
    )

    #expect(estimate.rawMinutes == 750)
    #expect(estimate.tier == .long)
    #expect(estimate.isCappedForDisplay)
    #expect(estimate.displayText == "240+ min")
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
        spf: .none,
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
        spf: .none,
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
    #expect(!DisclaimerReattestationPolicy.shouldPresentOnForeground(
        returnedFromBackground: true,
        acknowledgedDisclaimer: false,
        estimateWindowElapsed: true
    ))
    #expect(DisclaimerReattestationPolicy.shouldPresentOnForeground(
        returnedFromBackground: true,
        acknowledgedDisclaimer: true,
        estimateWindowElapsed: true
    ))
    #expect(!DisclaimerReattestationPolicy.shouldPresentOnForeground(
        returnedFromBackground: false,
        acknowledgedDisclaimer: true,
        estimateWindowElapsed: true
    ))
    #expect(!DisclaimerReattestationPolicy.shouldPresentOnForeground(
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
        spf: .none,
        uvIndex: 10
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
        .typeVI: "Almost never burns, deeply pigmented. Dark brown to black skin."
    ]
    let behaviorFirstPrefixes: [FitzpatrickSkinType: String] = [
        .typeI: "Always burns, never tans.",
        .typeII: "Burns easily, tans minimally.",
        .typeIII: "Burns moderately, tans gradually.",
        .typeIV: "Burns minimally, tans easily.",
        .typeV: "Rarely burns, tans deeply.",
        .typeVI: "Almost never burns, deeply pigmented."
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
        .typeVI: 1_000
    ]

    for skinType in FitzpatrickSkinType.allCases {
        #expect(skinType.minimalErythemalDoseJoules == expectedMED[skinType])
    }
}

@Test func spfContextLabelsAreHumanReadable() {
    #expect(SPFLevel.none.contextLabel == "none")
    #expect(SPFLevel.spf15.contextLabel == "15")
    #expect(SPFLevel.spf30.contextLabel == "30")
    #expect(SPFLevel.spf50.contextLabel == "50")
    #expect(SPFLevel.spf70Plus.contextLabel == "70+")
}

@Test func spfRawValuesMatchMultiplierContract() throws {
    #expect(SPFLevel.none.rawValue == 1)
    #expect(SPFLevel.spf15.rawValue == 15)
    #expect(SPFLevel.spf30.rawValue == 30)
    #expect(SPFLevel.spf50.rawValue == 50)
    #expect(SPFLevel.spf70Plus.rawValue == 70)
    #expect(SPFLevel.spf70Plus.modelMultiplier == 50)

    let unprotected = try BurnTimeCalculator.estimate(
        skinType: .typeII,
        spf: .none,
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
    #expect(estimate.displayText == "240+ min")
}

@Test func approvedMainScreenSafetyCopyIsCaptured() {
    #expect(ProductCopy.burnTimeEstimateTitle == "Burn-time estimate")
    #expect(ProductCopy.photosensitizerDisclaimerLine.contains("Photosensitizing"))
    #expect(ProductCopy.photosensitizationAuthorityLine.localizedCaseInsensitiveContains("informational"))
    #expect(ProductCopy.photosensitizationAuthorityLine.localizedCaseInsensitiveContains("NIH MedlinePlus"))
    #expect(ProductCopy.photosensitizationBannerLabel.localizedCaseInsensitiveContains("meds"))
    #expect(ProductCopy.photosensitizationBannerLabel.localizedCaseInsensitiveContains("conditions"))
    #expect(ProductCopy.locationRationale == "UV Burn Timer needs your location once to fetch the current UV index from Apple Weather.")
    #expect(ProductCopy.locationPrivacyLine.contains("2 decimals"))
    #expect(ProductCopy.locationPrivacyLine.localizedCaseInsensitiveContains("last rounded coordinate"))
    #expect(ProductCopy.cacheRetentionLine.localizedCaseInsensitiveContains("last rounded coordinate"))
    #expect(ProductCopy.cacheRetentionLine.localizedCaseInsensitiveContains("does not save UV values"))
    #expect(ProductCopy.clearSavedLocationButtonTitle == "Clear saved location")
    #expect(!ProductCopy.locationPrivacyLine.localizedCaseInsensitiveContains("never saved"))
    #expect(ProductCopy.childrenDisclaimerLine == "For children, consult a pediatrician.")
    #expect(ProductCopy.locationDeniedEmptyState.contains("tap Use my location again"))
    #expect(ProductCopy.locationUnavailableMessage.localizedCaseInsensitiveContains("could not determine your location"))
    #expect(ProductCopy.locationRequestInProgressMessage.localizedCaseInsensitiveContains("already checking"))
    #expect(ProductCopy.estimateElapsedWarning.contains("Recalculate"))
    #expect(ProductCopy.reapplicationFooter.contains("Reapply sunscreen every 2 hours"))
    #expect(ProductCopy.reapplicationFooter.localizedCaseInsensitiveContains("cover up"))
    #expect(ProductCopy.reapplicationFooter.localizedCaseInsensitiveContains("skin reddens"))
    #expect(ProductCopy.mainVerdictCaveatLinkLabel == "Meds + conditions can shorten this. Learn more")
    #expect(ProductCopy.mainVerdictCaveatLinkLabel.localizedCaseInsensitiveContains("can shorten"))
    #expect(ProductCopy.longEstimateHedge.localizedCaseInsensitiveContains("does not mean"))
    #expect(ProductCopy.longEstimateHedge.localizedCaseInsensitiveContains("safe"))
    #expect(ProductCopy.skinTypePickerPrompt == "Pick the row that matches what your skin does, not its color.")
    #expect(ProductCopy.uvSourceLine == "Source: Apple Weather")
    #expect(ProductCopy.disclaimerLinkLabel == "About & applicability")
    #expect(ProductCopy.fitzpatrickCitations.contains("NCBI Bookshelf NBK481857"))
    #expect(ProductCopy.fitzpatrickCitations.localizedCaseInsensitiveContains("WHO Global Solar UV Index"))
    #expect(ProductCopy.fitzpatrickCitations.localizedCaseInsensitiveContains("Schalka"))
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

@Test func skinTypeCaveatIsConsistentAcrossEntryPoints() {
    for copy in [ProductCopy.skinTypePickerFooter, ProductCopy.skinTypeSettingsFooter] {
        #expect(copy.localizedCaseInsensitiveContains("self-assessment"))
        #expect(copy.localizedCaseInsensitiveContains("consult a dermatologist before using this estimate to plan sun exposure"))
        #expect(copy.localizedCaseInsensitiveContains("Learn more"))
        #expect(copy.localizedCaseInsensitiveContains("result screen"))
        #expect(copy.localizedCaseInsensitiveContains("healthy skin"))
        #expect(copy.localizedCaseInsensitiveContains("photosensitizing medications"))
    }
}

@Test func aboutCopyIncludesApplicabilityAndWeatherMentalModel() {
    let aboutCopy = ProductCopy.aboutEstimateApplicability + " " + ProductCopy.aboutWeatherVariability + " " + ProductCopy.aboutSunscreenAssumptions

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
    #expect(ProductCopy.aboutHowThisWorks.localizedCaseInsensitiveContains("Fitzpatrick"))
    #expect(ProductCopy.aboutHowThisWorks.localizedCaseInsensitiveContains("SPF"))
    #expect(ProductCopy.outdoorReadabilityTip.localizedCaseInsensitiveContains("Increase Contrast"))
}

@Test func photosensitizerCopyAvoidsBrandAndOverSpecificMedicationNames() {
    let aboutCopy = ProductCopy.aboutEstimateApplicability
    let excludedMedicationNames = [
        "Accutane",
        "Plaquenil",
        "doxycycline",
        "hydroxychloroquine",
        "isotretinoin"
    ]

    for medicationName in excludedMedicationNames {
        #expect(!aboutCopy.localizedCaseInsensitiveContains(medicationName))
    }
}

@Test func aboutPrivacyCopyDescribesRoundedCoordinatesToAppleWeather() {
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("rounded coordinates"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("Apple Weather"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("skin type and SPF"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("app memory only"))
    #expect(ProductCopy.aboutPrivacy.localizedCaseInsensitiveContains("last rounded coordinate"))
}

@Test func attributionAndPricingCopyAreCanonical() {
    #expect(ProductCopy.weatherAttributionServiceName == "Apple Weather")
    #expect(ProductCopy.weatherAttributionLegalURL.absoluteString == "https://weatherkit.apple.com/legal-attribution.html")
    #expect(ProductCopy.pricingLine.localizedCaseInsensitiveContains("one-time paid app"))
    #expect(ProductCopy.pricingLine.localizedCaseInsensitiveContains("no in-app purchase to restore"))
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
        "skin cancer prevention"
    ]

    for copy in copySurfaces {
        for phrase in bannedPhrases {
            #expect(!copy.localizedCaseInsensitiveContains(phrase))
        }
    }
}

@Test func sunscreenReapplicationReminderUsesTwoHourInterval() {
    #expect(ProductTiming.sunscreenReapplicationIntervalSeconds == 7_200)
}

@Test func visibleEstimateContextLineIncludesInputsAndOneDecimalUV() {
    #expect(EstimateContextLine.text(
        skinType: .typeIII,
        spf: .spf30,
        uvIndex: 6.24
    ) == "Fitzpatrick III · SPF 30 · UV index 6.2")
    #expect(EstimateContextLine.text(
        skinType: .typeI,
        spf: .none,
        uvIndex: 10
    ) == "Fitzpatrick I · SPF none · UV index 10.0")
}

@Test func heroAccessibilitySummaryCombinesSafetyCriticalVerdictContext() throws {
    let estimate = try BurnTimeCalculator.estimate(
        skinType: .typeIII,
        spf: .none,
        uvIndex: 6
    )

    #expect(HeroAccessibilitySummary.text(
        estimate: estimate,
        uvIndex: 6,
        verdict: "Moderate"
    ) == "Estimated burn time: 33 minutes. Current UV index: 6.0. Moderate tier. Estimated only, not medical advice.")
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
        hasAcknowledgedRationale: true,
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
        hasAcknowledgedRationale: true,
        isFetching: true
    )

    #expect(fetching.title == "Fetching UV...")
    #expect(fetching.systemImageName == "location.fill")
}

@Test func locationActionPresentationMatchesReadyStates() {
    #expect(LocationActionPresentation(
        hasUVIndex: false,
        hasAcknowledgedRationale: false,
        isFetching: false
    ).title == "Continue to location request")
    #expect(LocationActionPresentation(
        hasUVIndex: false,
        hasAcknowledgedRationale: true,
        isFetching: false
    ).title == "Use my location")
    #expect(LocationActionPresentation(
        hasUVIndex: true,
        hasAcknowledgedRationale: true,
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
    #expect(try CachedRoundedCoordinateStorage.roundedCoordinate(from: storageValue) == UVCoordinate(latitude: 37.77, longitude: -122.42))
    #expect(try CachedRoundedCoordinateStorage.roundedCoordinate(from: CachedRoundedCoordinateStorage.clearedStorageValue) == nil)
    #expect(decoded.roundedCoordinate == UVCoordinate(latitude: 37.77, longitude: -122.42))
    #expect(decoded.roundedCoordinate.privacyDisplayText == "Approx. 37.77, -122.42")
    #expect(encodedObject["uvIndex"] == nil)
    #expect(encodedObject["fetchedAt"] == nil)
    #expect(encodedObject["selectedSkinType"] == nil)
    #expect(encodedObject["selectedSPF"] == nil)
}

@Test func relativeAgeCopyIsHumanReadable() {
    let fetchedAt = Date(timeIntervalSince1970: 1_000)

    #expect(RelativeAgeText.text(fetchedAt: fetchedAt, now: Date(timeIntervalSince1970: 1_000)) == "Updated 1 min ago")
    #expect(RelativeAgeText.text(fetchedAt: fetchedAt, now: Date(timeIntervalSince1970: 1_059)) == "Updated 1 min ago")
    #expect(RelativeAgeText.text(fetchedAt: fetchedAt, now: Date(timeIntervalSince1970: 1_090)) == "Updated 1 min ago")
    #expect(RelativeAgeText.text(fetchedAt: fetchedAt, now: Date(timeIntervalSince1970: 1_300)) == "Updated 5 min ago")
}
