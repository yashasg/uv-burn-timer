import Foundation

public enum ProductCopy {
    public static let disclaimerTitle = "How accurate is this for you?"
    public static let disclaimerBody = "UV Burn Timer is informational only and is not medical advice. It is a model calculation, not a measurement, and cannot replace professional medical advice, diagnosis, or treatment. Estimates assume healthy adult skin, consistent conditions, and that the labeled SPF is achieved through correct sunscreen amount and reapplication; skin response varies. For personal guidance, consult a dermatologist. When in doubt: cover up, reapply sunscreen, or move into shade."
    public static let photosensitizerDisclaimerLine = "Photosensitizing medications and conditions can make this estimate overstate your burn window."
    public static let locationRationale = "UV Burn Timer needs your location once to fetch the current UV index from Apple Weather."
    public static let locationPrivacyLine = "Coordinates are rounded to 2 decimals for Apple Weather and cached only as the last UV lookup on this device."
    public static let locationDeniedEmptyState = "Location access is off. You can adjust SPF and skin type now; enable When In Use access in Settings, then tap Use my location again."
    public static let locationUnavailableMessage = "Could not determine your location. Check that Location Services are available, then try again."
    public static let locationRequestInProgressMessage = "UV Burn Timer is already checking your location."
    public static let estimateElapsedWarning = "Recalculate before relying on this estimate. Sunscreen should still be reapplied every 2 hours."
    public static let reapplicationFooter = "Reapply sunscreen every 2 hours regardless of timer. Informational only. Not medical advice. Skin response varies."
    public static let mainVerdictCaveatLinkLabel = "Is this estimate for me?"
    public static let skinTypePickerPrompt = "Pick the row that matches what your skin does, not its color."
    public static let uvSourceLine = "Source: Apple Weather"
    public static let disclaimerLinkLabel = "Informational only. Not medical advice."
    public static let fitzpatrickCitations = "Fitzpatrick TB (1988); Ward & Farma, Cutaneous Melanoma: Etiology and Therapy, NCBI Bookshelf NBK481857 (2017); WHO Global Solar UV Index practical guide (2002); Schalka & Reis on real-world sunscreen/SPF use; Diffey BL (1991) / CIE Standard S 007/E-1998."
    public static let skinTypePickerFooter = "No default is selected. Choose deliberately before location or UV lookup. Skin type self-assessment is approximate; consult a dermatologist before using this estimate to plan sun exposure. This model assumes healthy skin and no photosensitizing medications. See \"Is this estimate for me?\" on the result screen for details."
    public static let skinTypeSettingsFooter = "Skin type self-assessment is approximate; consult a dermatologist before using this estimate to plan sun exposure. This model assumes healthy skin and no photosensitizing medications. See \"Is this estimate for me?\" on the result screen for details."
    public static let aboutEstimateApplicability = "The estimate may overstate your burn window if you take photosensitizing medications such as isotretinoin, tetracycline-class antibiotics including doxycycline, or hydroxychloroquine; have a photosensitive skin condition such as lupus, vitiligo, albinism, or porphyria; recently had a dermatologic procedure; or are pregnant. Consult a dermatologist before using this estimate to plan sun exposure."
    public static let aboutHowThisWorks = "How this works: the app estimates minutes to one minimal erythemal dose by combining your selected Fitzpatrick skin type, your SPF selection, and the current UV index. Higher UV shortens the estimate; SPF lengthens the model estimate only when sunscreen is applied correctly and reapplied."
    public static let aboutWeatherVariability = "Why this number changes with weather: UV can pass through clouds, haze, and reflected glare, and the UV index can change quickly with time of day and conditions. Recalculate before relying on an older estimate."
    public static let outdoorReadabilityTip = "Bright sunlight? Try Settings → Accessibility → Display & Text Size → Increase Contrast."
    public static let weatherAttributionServiceName = "Apple Weather"
    public static let weatherAttributionLegalURL = URL(string: "https://developer.apple.com/weatherkit/data-source-attribution/")!
    public static let pricingLine = "One-time paid app. No subscription and no in-app purchase to restore."

    public static let auditCopySurfaces = [
        disclaimerTitle,
        disclaimerBody,
        photosensitizerDisclaimerLine,
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
        outdoorReadabilityTip,
        weatherAttributionServiceName,
        pricingLine
    ]
}

public enum ProductTiming {
    public static let sunscreenReapplicationIntervalSeconds: TimeInterval = 2 * 60 * 60
}
