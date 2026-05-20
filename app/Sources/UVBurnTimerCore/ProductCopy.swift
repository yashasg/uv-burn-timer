import Foundation

public struct ProductCitationLink: Equatable, Sendable {
    public let title: String
    public let url: URL

    public init(title: String, url: URL) {
        self.title = title
        self.url = url
    }
}

public enum ProductCopy {
    public static let burnTimeEstimateTitle = "Burn-time estimate"
    public static let disclaimerTitle = "How accurate is this for you?"
    public static let disclaimerBody =
        "UV Burn Timer is informational only and is not medical advice. It is a model calculation, not a measurement, and cannot replace professional medical advice, diagnosis, or treatment; it is not prevention guidance. Estimates assume healthy adult skin, consistent conditions, and that the labeled SPF is achieved through correct sunscreen amount and reapplication; skin response varies. For personal guidance, especially if you use photosensitizing medications or have photosensitive conditions, consult a dermatologist or qualified clinician. When in doubt: cover up, reapply sunscreen, or move into shade."
    public static let photosensitizerDisclaimerLine =
        "Photosensitizing medications, conditions, recent skin treatments, and pregnancy can make this estimate overstate your burn window."
    public static let photosensitizationAuthorityLine =
        "Informational overview: NIH MedlinePlus notes that some medicines can increase sun sensitivity; ask a clinician or pharmacist whether this applies to you."
    public static let childrenDisclaimerLine = "For children, consult a pediatrician."
    public static let photosensitizationBannerLabel = "Meds or photosensitive conditions? Learn more"
    public static let locationRationale =
        "UV Burn Timer needs your location once to fetch the current UV index from Apple Weather."
    public static let locationPrivacyLine =
        "The app asks iOS for approximate location where available. Coordinates are rounded to 2 decimals for Apple Weather, and only the last rounded coordinate may be saved on this device."
    public static let cacheRetentionLine =
        "The app stores only the last rounded coordinate for location context; it does not save UV values, burn estimates, skin type, or SPF."
    public static let clearSavedLocationButtonTitle = "Clear saved location"
    public static let locationDeniedEmptyState =
        "Location access is off. You can adjust SPF and skin type now; enable When In Use access in Settings, then tap Use my location again."
    public static let locationUnavailableMessage =
        "Could not determine your location. Check that Location Services are available, then try again."
    public static let locationRequestInProgressMessage = "UV Burn Timer is already checking your location."
    public static let weatherUnavailableTitle = "Weather unavailable"
    public static let weatherUnavailableMessage =
        "Could not reach Apple Weather. Check your connection, then try again."
    public static let estimateElapsedWarning =
        "Recalculate before relying on this estimate. Sunscreen should still be reapplied every 2 hours."
    public static let longEstimateHedge =
        "A long estimate does not mean prolonged sun exposure is safe; conditions and skin response can change."
    public static let sunscreenCapHedge =
        "SPF math may estimate a longer burn threshold, but sunscreen-protected windows are capped at 2 hours because sunscreen should be reapplied at least that often."
    public static let reapplicationFooter =
        "Cover up if skin reddens. Reapply sunscreen at least every 2 hours regardless of timer. Informational only. Not medical advice. Skin response varies."
    public static let mainVerdictCaveatLinkLabel = "Meds + conditions can shorten this. Learn more"
    public static let skinTypePickerPrompt = "Choose by how your skin burns and tans, not by how it looks."
    public static let skinTypePickerSubtext =
        "Pick the row that best matches what your skin does after about 30 minutes of midday summer sun, with no sunscreen and no recent tan. Each row covers a range of natural skin tones."
    public static let skinTypeSourcePointer =
        "Sources: Fitzpatrick 1988; NCBI Bookshelf 2017 (NBK481857). See About & Citations."
    public static let uvSourceLine = "Source: Apple Weather"
    public static let disclaimerLinkLabel = "About & applicability"
    public static let fitzpatrickCitations =
        "Picker descriptions are adapted and paraphrased from Fitzpatrick TB (1988) and Ward & Farma, Cutaneous Melanoma: Etiology and Therapy, NCBI Bookshelf NBK481857 (2017). UV guidance references WHO Global Solar UV Index practical guide (2002), https://iris.who.int/handle/10665/42459; Schalka & Reis on real-world sunscreen/SPF use; Diffey BL (1991) / CIE Standard S 007/E-1998."
    public static let skinTypePickerFooter =
        "No default is selected. Choose deliberately before location or UV lookup. Skin type self-assessment is approximate; consult a dermatologist before using this estimate to plan sun exposure. This model assumes healthy skin and no photosensitizing medications. Use the result screen Learn more link for details."
    public static let skinTypeSettingsFooter =
        "Skin type self-assessment is approximate; consult a dermatologist before using this estimate to plan sun exposure. This model assumes healthy skin and no photosensitizing medications. Use the result screen Learn more link for details."
    public static let aboutEstimateApplicability =
        "The estimate may overstate your burn window if you take certain medications known to increase sun sensitivity, including some retinoid acne treatments, tetracycline-class antibiotics, autoimmune-disease medications, diuretics, heart-rhythm medications, or antifungals; have photosensitive conditions such as lupus, vitiligo, albinism, or porphyria; have had recent skin treatments such as laser, chemical peel, microneedling, or retinoid therapy; are pregnant; or are unsure whether UV exposure guidance applies to you. Fitzpatrick IV–VI estimates carry wider uncertainty because published MED values are commonly represented as ranges. Consult a dermatologist before using this estimate to plan sun exposure."
    public static let aboutHowThisWorks =
        "How this works: the app estimates minutes to one minimal erythemal dose by combining your selected Fitzpatrick skin type, your SPF selection, and the current UV index. Higher UV shortens the estimate; SPF lengthens the model estimate only when sunscreen is applied correctly and reapplied, and sunscreen-protected displayed windows are capped at 2 hours. SPF 70+ is conservatively modeled as SPF 50."
    public static let aboutSunscreenAssumptions =
        "The estimate assumes sunscreen remains correctly applied. Reapply at least every 2 hours, and sooner when water, sweat, toweling, the label, or your situation calls for it."
    public static let aboutWeatherVariability =
        "Why this number changes with weather: UV can pass through clouds, haze, and reflected glare, and the UV index can change quickly with time of day and conditions. Recalculate before relying on an older estimate."
    public static let aboutModelLimitations =
        "Model limits: the estimate assumes the current UV remains constant over the displayed window and does not account for altitude, snow, sand, water, or other reflection changes, shade breaks, clothing coverage, or changing sun angle."
    public static let pediatricAndEscalationGuidance =
        "Children need pediatric guidance. Seek urgent care for severe sunburn symptoms such as blistering, fever, chills, dizziness, confusion, dehydration, or feeling very unwell."
    public static let aboutPrivacy =
        "Skin type and SPF stay in app memory only. The app asks iOS for approximate location where available; rounded coordinates are sent to Apple Weather to fetch UV index data, and only the last rounded coordinate may be saved on this device. No accounts, analytics, ads, crash SDKs, or third-party tracking."
    public static let outdoorReadabilityTip =
        "Bright sunlight? Try Settings → Accessibility → Display & Text Size → Increase Contrast."
    public static let weatherAttributionServiceName = "Apple Weather"
    public static let weatherDataAttributionBody =
        "UV Burn Timer uses Apple Weather for UV index data. Apple Weather data is sourced from a range of providers."
    public static let weatherAttributionLegalURL = URL(string: "https://weatherkit.apple.com/legal-attribution.html")!
    public static let weatherAttributionLegalURLString = "https://weatherkit.apple.com/legal-attribution.html"
    public static let medlinePlusSunSensitivityURL = URL(string: "https://medlineplus.gov/sunexposure.html")!
    public static let pricingLine = "One-time paid app. No subscription, in-app purchases, tip jar, or restore flow."
    public static let citationLinks = [
        ProductCitationLink(
            title: "Fitzpatrick TB 1988",
            url: URL(string: "https://doi.org/10.1001/archderm.1988.01670060015008")!
        ),
        ProductCitationLink(
            title: "Ward & Farma NCBI Bookshelf NBK481857",
            url: URL(string: "https://www.ncbi.nlm.nih.gov/books/NBK481857/")!
        ),
        ProductCitationLink(
            title: "WHO Global Solar UV Index practical guide",
            url: URL(string: "https://iris.who.int/handle/10665/42459")!
        ),
        ProductCitationLink(
            title: "Schalka, dos Reis & Cucé sunscreen/SPF study",
            url: URL(string: "https://doi.org/10.1111/j.1600-0781.2009.00408.x")!
        ),
        ProductCitationLink(
            title: "Diffey BL 1991",
            url: URL(string: "https://doi.org/10.1088/0031-9155/36/3/001")!
        ),
        ProductCitationLink(
            title: "CIE erythemal reference action spectrum",
            url: URL(
                string: "https://cie.co.at/publications/erythema-reference-action-spectrum-and-standard-erythema-dose")!
        ),
    ]

    public static let auditCopySurfaces = [
        burnTimeEstimateTitle,
        disclaimerTitle,
        disclaimerBody,
        photosensitizerDisclaimerLine,
        photosensitizationAuthorityLine,
        childrenDisclaimerLine,
        photosensitizationBannerLabel,
        locationRationale,
        locationPrivacyLine,
        cacheRetentionLine,
        clearSavedLocationButtonTitle,
        locationDeniedEmptyState,
        locationUnavailableMessage,
        locationRequestInProgressMessage,
        weatherUnavailableTitle,
        weatherUnavailableMessage,
        estimateElapsedWarning,
        longEstimateHedge,
        sunscreenCapHedge,
        reapplicationFooter,
        mainVerdictCaveatLinkLabel,
        skinTypePickerPrompt,
        skinTypePickerSubtext,
        skinTypeSourcePointer,
        uvSourceLine,
        disclaimerLinkLabel,
        fitzpatrickCitations,
        skinTypePickerFooter,
        skinTypeSettingsFooter,
        aboutEstimateApplicability,
        aboutHowThisWorks,
        aboutSunscreenAssumptions,
        aboutWeatherVariability,
        aboutModelLimitations,
        pediatricAndEscalationGuidance,
        aboutPrivacy,
        outdoorReadabilityTip,
        weatherAttributionServiceName,
        weatherDataAttributionBody,
        pricingLine,
    ]
}

public enum ProductTiming {
    public static let sunscreenReapplicationIntervalSeconds: TimeInterval = 2 * 60 * 60
    public static let sunscreenReapplicationIntervalMinutes: Double = sunscreenReapplicationIntervalSeconds / 60
}

public enum EstimateContextLine {
    public static func text(
        skinType: FitzpatrickSkinType,
        spf: SPFLevel,
        uvIndex: Double
    ) -> String {
        "Fitzpatrick \(skinType.romanNumeral) · SPF \(spf.contextLabel) · UV index \(uvIndex.formatted(.number.precision(.fractionLength(1))))"
    }
}

public enum HeroAccessibilitySummary {
    public static func text(
        estimate: BurnTimeEstimate,
        uvIndex: Double?,
        verdict: String
    ) -> String {
        let uvText =
            uvIndex.map { "Current UV index: \($0.formatted(.number.precision(.fractionLength(1))))." }
            ?? "UV index unavailable."
        return "\(estimate.accessibilitySummary) \(uvText) \(verdict) tier. Estimated only, not medical advice."
    }
}

public struct LocationActionPresentation: Equatable, Sendable {
    public let title: String
    public let systemImageName: String
    public let accessibilityHint: String

    public init(
        hasUVIndex: Bool,
        hasAcknowledgedRationale: Bool,
        isFetching: Bool
    ) {
        if isFetching {
            self.title = "Fetching UV..."
            self.systemImageName = "location.fill"
            self.accessibilityHint = "Fetching your location and current UV index from Apple Weather."
        } else if !hasUVIndex, !hasAcknowledgedRationale {
            self.title = "Continue to location request"
            self.systemImageName = "location"
            self.accessibilityHint = "Reviews why location is needed before the system permission prompt."
        } else if hasUVIndex {
            self.title = "Recalculate"
            self.systemImageName = "arrow.clockwise"
            self.accessibilityHint = "Requests current location and fetches a fresh UV index from Apple Weather."
        } else {
            self.title = "Use my location"
            self.systemImageName = "location"
            self.accessibilityHint = "Requests current location and fetches the UV index from Apple Weather."
        }
    }
}
