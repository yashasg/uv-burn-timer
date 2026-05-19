import Foundation

public enum ProductCopy {
    public static let disclaimerTitle = "How accurate is this for you?"
    public static let disclaimerBody = "UV Burn Timer is informational only and is not medical advice. It is a model calculation, not a measurement, and cannot replace professional medical advice, diagnosis, or treatment. Estimates assume healthy adult skin, consistent conditions, and that the labeled SPF is achieved through correct sunscreen amount and reapplication; skin response varies. For personal guidance, consult a dermatologist. When in doubt: cover up, reapply sunscreen, or move into shade."
    public static let photosensitizerDisclaimerLine = "Photosensitizing medications and conditions can make this estimate overstate your burn window."
    public static let childrenDisclaimerLine = "For children, consult a pediatrician."
    public static let photosensitizationBannerLabel = "Meds or photosensitive conditions? Learn more"
    public static let locationRationale = "UV Burn Timer needs your location once to fetch the current UV index from Apple Weather."
    public static let locationPrivacyLine = "Coordinates are rounded to 2 decimals for Apple Weather and cached only as the last UV lookup on this device."
    public static let locationDeniedEmptyState = "Location access is off. You can adjust SPF and skin type now; enable When In Use access in Settings, then tap Use my location again."
    public static let locationUnavailableMessage = "Could not determine your location. Check that Location Services are available, then try again."
    public static let locationRequestInProgressMessage = "UV Burn Timer is already checking your location."
    public static let estimateElapsedWarning = "Recalculate before relying on this estimate. Sunscreen should still be reapplied every 2 hours."
    public static let reapplicationFooter = "Cover up if skin reddens. Reapply sunscreen every 2 hours regardless of timer. Informational only. Not medical advice. Skin response varies."
    public static let mainVerdictCaveatLinkLabel = "Meds + conditions can shorten this. Learn more"
    public static let skinTypePickerPrompt = "Pick the row that matches what your skin does, not its color."
    public static let uvSourceLine = "Source: Apple Weather"
    public static let disclaimerLinkLabel = "Informational only. Not medical advice."
    public static let fitzpatrickCitations = "Fitzpatrick TB (1988); Ward & Farma, Cutaneous Melanoma: Etiology and Therapy, NCBI Bookshelf NBK481857 (2017); WHO Global Solar UV Index practical guide (2002); Schalka & Reis on real-world sunscreen/SPF use; Diffey BL (1991) / CIE Standard S 007/E-1998."
    public static let skinTypePickerFooter = "No default is selected. Choose deliberately before location or UV lookup. Skin type self-assessment is approximate; consult a dermatologist before using this estimate to plan sun exposure. This model assumes healthy skin and no photosensitizing medications. Use the result screen Learn more link for details."
    public static let skinTypeSettingsFooter = "Skin type self-assessment is approximate; consult a dermatologist before using this estimate to plan sun exposure. This model assumes healthy skin and no photosensitizing medications. Use the result screen Learn more link for details."
    public static let aboutEstimateApplicability = "The estimate may overstate your burn window if you take certain medications, have photosensitive conditions, recently had a dermatologic procedure, are pregnant, or are unsure whether UV exposure guidance applies to you. Consult a dermatologist before using this estimate to plan sun exposure."
    public static let aboutHowThisWorks = "How this works: the app estimates minutes to one minimal erythemal dose by combining your selected Fitzpatrick skin type, your SPF selection, and the current UV index. Higher UV shortens the estimate; SPF lengthens the model estimate only when sunscreen is applied correctly and reapplied."
    public static let aboutWeatherVariability = "Why this number changes with weather: UV can pass through clouds, haze, and reflected glare, and the UV index can change quickly with time of day and conditions. Recalculate before relying on an older estimate."
    public static let aboutPrivacy = "Skin type and SPF stay on this device. Rounded coordinates are sent to Apple Weather to fetch UV index data and may be cached only as part of the last UV lookup on this device."
    public static let outdoorReadabilityTip = "Bright sunlight? Try Settings → Accessibility → Display & Text Size → Increase Contrast."
    public static let weatherAttributionServiceName = "Apple Weather"
    public static let weatherAttributionLegalURL = URL(string: "https://weatherkit.apple.com/legal-attribution.html")!
    public static let pricingLine = "One-time paid app. No subscription and no in-app purchase to restore."

    public static let auditCopySurfaces = [
        disclaimerTitle,
        disclaimerBody,
        photosensitizerDisclaimerLine,
        childrenDisclaimerLine,
        photosensitizationBannerLabel,
        locationRationale,
        locationPrivacyLine,
        locationDeniedEmptyState,
        locationUnavailableMessage,
        locationRequestInProgressMessage,
        estimateElapsedWarning,
        reapplicationFooter,
        mainVerdictCaveatLinkLabel,
        skinTypePickerPrompt,
        uvSourceLine,
        disclaimerLinkLabel,
        fitzpatrickCitations,
        skinTypePickerFooter,
        skinTypeSettingsFooter,
        aboutEstimateApplicability,
        aboutHowThisWorks,
        aboutWeatherVariability,
        aboutPrivacy,
        outdoorReadabilityTip,
        weatherAttributionServiceName,
        pricingLine
    ]
}

public enum ProductTiming {
    public static let sunscreenReapplicationIntervalSeconds: TimeInterval = 2 * 60 * 60
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
        let uvText = uvIndex.map { "Current UV index: \($0.formatted(.number.precision(.fractionLength(1))))." } ?? "UV index unavailable."
        return "\(estimate.accessibilitySummary) \(uvText) \(verdict) tier. Estimated only, not medical advice."
    }
}
