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
    public static let emptyStateAwaitingSkinType = "Pick a skin type to see your estimate."
    public static let emptyStateAwaitingLocation = "Tap Use my location to compute your estimate."

    /// Hero empty-state prompt derived from session state so the copy can
    /// never drift out of sync with what the user has already done. Once a
    /// Fitzpatrick skin type has been committed (via onboarding or Settings),
    /// the prompt directs the user to the next action (location); otherwise
    /// it asks them to pick a skin type.
    public static func heroEmptyStatePrompt(hasSkinType: Bool) -> String {
        hasSkinType ? emptyStateAwaitingLocation : emptyStateAwaitingSkinType
    }

    public static let disclaimerTitle = "How accurate is this for you?"
    public static let disclaimerBody =
        "UV Burn Timer is informational only and is not medical advice. It is a model calculation, not a measurement, and cannot replace professional medical advice, diagnosis, or treatment; it is not prevention guidance. Estimates assume healthy adult skin, consistent conditions, and that the labeled SPF is achieved through correct sunscreen amount and reapplication; skin response varies. For personal guidance, especially if you use photosensitizing medications or have photosensitive conditions, consult a dermatologist or qualified clinician. When in doubt: cover up, reapply sunscreen, or move into shade."
    public static let photosensitizerDisclaimerLine =
        "Photosensitizing medications, conditions, recent skin treatments, and pregnancy can make this estimate overstate your burn window."
    public static let photosensitizationAuthorityLine =
        "Informational overview: NIH MedlinePlus notes that some medicines can increase sun sensitivity; ask a clinician or pharmacist whether this applies to you."
    public static let childrenDisclaimerLine = "For children, consult a pediatrician."

    /// AUDIT-ONLY — not rendered at runtime since the K-1 banner retirement
    /// (Loop-7 / `.squad/decisions.md` ~L739). The yellow photosens banner
    /// was retired in favor of the toolbar ⓘ button (`EstimateInfoButton` →
    /// `AboutView(highlightEstimateApplicability: true)`) per K-7 /
    /// WI-50–WI-53; this constant is retained for spec/audit fidelity
    /// because LANE 2 #3 of `.squad/files/user-flow-onboarding-main-spec.md`
    /// (pre-WI-cc reconcile) referenced the row by this exact wording, and
    /// any future banner-style L3 surface should re-use the same prose to
    /// preserve Plunder review continuity. Pinned by
    /// `requiredSafetyDisclaimerCopyIsCaptured` so accidental drift still
    /// fails CI.
    public static let photosensitizationBannerLabel = "Meds or photosensitive conditions? Learn more"

    /// AUDIT-ONLY — not used at runtime. In-app deep-link URL that documents the
    /// deep-link contract for the inline see-About reach-back. The scheme is
    /// intentionally a private app scheme so the tap would never escape to the
    /// system browser; the host names the About anchor
    /// (`notForMe` → `aboutEstimateApplicability`). `DisclaimerCover` currently
    /// opens `AboutView` via a `.sheet` (Button path) rather than routing this URL.
    public static let disclaimerSeeAboutLinkURL = URL(string: "uvburntimer://about-applicability")!

    /// Plain-text variant of the inline reach-back prompt. Used by copy
    /// audits, accessibility-label fallbacks, and any non-Markdown
    /// rendering path. Mirrors the persona-overlay phrasing in
    /// `.squad/files/suchi-persona-annotations.md` Screen 1 (Asha row).
    public static let disclaimerSeeAboutInlinePrompt =
        "If you take a photosensitizing medication or have a sun-sensitive condition — see About."

    /// Lead prose preceding the inline link span. Together with
    /// `disclaimerSeeAboutInlineLinkLabel` and
    /// `disclaimerSeeAboutInlineTail` these compose
    /// `disclaimerSeeAboutInlinePrompt` for accessibility-stable
    /// rendering via a `Button` with `.accessibilityIdentifier(
    /// "DisclaimerSeeAboutLink")`. Splitting the prompt into three
    /// pieces lets `DisclaimerCover` style the `see About` span with
    /// the accent color and underline (link affordance) while keeping
    /// the entire sentence inside a single tappable `Button` that
    /// XCUITest can find by identifier across all supported iOS
    /// versions (the previous `Text(LocalizedStringKey:)` Markdown
    /// rendering's link a11y exposure varied between iOS 17 and
    /// iOS 18+, which made the test unreliable on the CI runner).
    public static let disclaimerSeeAboutInlineLead =
        "If you take a photosensitizing medication or have a sun-sensitive condition — "
    public static let disclaimerSeeAboutInlineLinkLabel = "see About"
    public static let disclaimerSeeAboutInlineTail = "."

    /// AUDIT-ONLY — not rendered at runtime. Retained for spec/audit fidelity even though
    /// `DisclaimerCover` now renders the prompt through a styled
    /// `Button` rather than `Text(LocalizedStringKey:)`. The link
    /// target (`disclaimerSeeAboutLinkURL`) still documents the
    /// deep-link contract so future surfaces can re-use the same URL
    /// scheme if they need a true Markdown rendering path.
    /// See `disclaimerSurfacesInlineSeeAboutDeepLinkForPhotosensitiveCohort`
    /// in `BurnTimeCalculatorTests` for the audit test that validates
    /// these constants without depending on them being rendered.
    public static let disclaimerSeeAboutInlineMarkdown =
        "If you take a photosensitizing medication or have a sun-sensitive condition — [see About](\(disclaimerSeeAboutLinkURL.absoluteString))."
    public static let locationPrivacyLine =
        "The app asks iOS for approximate location where available. Coordinates are rounded to 2 decimals for Apple Weather, and only the last rounded coordinate may be saved on this device."

    /// WI-iris-c (Loop-11) — Pattern-B truth fix.
    ///
    /// Before WI-ff (Pattern B, ratified 2026-05-21T07:00Z) the L1 cover
    /// refired every cold launch; "disclaimer acknowledgments are NOT
    /// retained" was true because the in-memory `@State` was the only ack
    /// record. Under Pattern B `UserPreferenceStorage.disclaimerPolicyVersionKey`
    /// IS written to `UserDefaults` on acknowledge (see
    /// `UVBurnTimerApp.swift:88`), so the previous wording shipped factually
    /// false GDPR-load-bearing prose. WI-iris-c rewrites the line to name
    /// the acknowledgment-version persistence explicitly while keeping
    /// Plunder's "what is NOT saved" lane intact.
    public static let cacheRetentionLine =
        "The app stores skin type, SPF, the last rounded coordinate, and the version of the informational disclaimer you acknowledged on this device; it does not save UV values or burn estimates between launches."

    /// WI-w / Plunder-ratified 2026-05-21 — L1 storage-disclosure sentence.
    ///
    /// Rendered on `DisclaimerCover` immediately after `disclaimerBody` and
    /// BEFORE the inline see-About reach-back. Kept as a SEPARATE constant
    /// from `disclaimerBody` so the FDA-pre-approved substring guard
    /// (`requiredSafetyDisclaimerCopyIsCaptured`) keeps its audit lane
    /// clean and so future targeted edits to either lane stay independent.
    ///
    /// Wording is GDPR-load-bearing: it names *what* is persisted
    /// (skin type + SPF), the *scope* (this device only — Art.5(1)(f)),
    /// the *purpose* ("so the app can remember them between launches" —
    /// Art.9(2)(a) specificity per EDPB Guidelines 05/2020 §3.2), the
    /// *off-device* complement (mirror of `aboutPrivacy`), and the
    /// *erasure path* (Art.17, via the Settings "Clear stored skin type"
    /// and "Clear saved location" buttons — verb match with K-8). Any
    /// edit MUST re-open the Plunder gate.
    ///
    /// See `.squad/orchestration-log/2026-05-21T-plunder-wi-w-l1-storage.md`.
    public static let disclaimerStorageLine =
        "Your skin type and SPF are saved on this device only so the app can remember them between launches; the app never sends them off-device. You can clear them anytime in Settings."
    public static let clearSavedLocationButtonTitle = "Clear saved location"

    /// WI-bundleF / Plunder P-2 (Loop-11) — GDPR Art.17 erasure-path button.
    ///
    /// Routed through `ProductCopy` so the `auditCopySurfaces`-driven
    /// monetization-drift + banned-clinical-claim sieves apply, and so the
    /// L1 `disclaimerStorageLine` promise *"You can clear them anytime in
    /// Settings"* keeps verb-continuity with the button title (the consent
    /// specificity ↔ erasure-affordance loop only holds while the button
    /// keeps the verb "clear"). Pinned by `test_FF1_*`.
    public static let clearStoredSkinTypeButtonTitle = "Clear stored skin type"

    /// WI-bundleM / Kwame-L12 H2 (Loop-12) — GDPR Art.17 erasure-path button
    /// for the SPF preference. The L1 `disclaimerStorageLine` promises
    /// *"Your skin type **and SPF** are saved on this device only … You can
    /// clear them anytime in Settings."* The Loop-11 erasure surface shipped
    /// only a skin-type clear button; SPF persisted with no documented
    /// erasure affordance. This constant closes the L1 ↔ Settings
    /// verb-continuity symmetry so the promise is fulfilled for both
    /// disclosed preferences. Pinned by `test_SS1_*` (Plunder P-2 floor).
    public static let clearStoredSPFButtonTitle = "Clear stored SPF"

    /// WI-bundleF / Plunder P-1 (Loop-11) — Pattern-B `skinTypeChip` labels.
    ///
    /// The chip is the per-session re-attestation surface for the Asha (P4
    /// Accutane) cohort. Drift to measurement-like phrasing ("Burn risk
    /// III", "Phototype III", "Skin score III") re-classifies the chip
    /// from a self-declared *input* echo (general-wellness territory) to
    /// an inferred *output* (potentially MDSW/Class IIa under MDR Annex
    /// VIII Rule 11 + MDCG 2019-11 §3.3). The 🚫/✅ list lives at
    /// `.squad/designs/plunder-skin-type-persistence-floor.md` §4.4. Both
    /// the unset label and the parameterised set-label are pinned by
    /// `test_FF2_*` and audit-enrolled via `auditCopySurfaces`.
    public static let skinTypeChipUnsetLabel = "Set skin type"
    public static func skinTypeChipSetLabel(for type: FitzpatrickSkinType) -> String {
        "Type \(type.romanNumeral)"
    }
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

    /// Sun-safety action clauses A+B from `reapplicationFooter`, factored out for
    /// placement in `AboutView` at the `notForMeAnchor` VStack (K-10 / K-11).
    /// Satisfies Plunder C2(i) (biological-feedback override) and C2(ii)
    /// (reapplication-cadence reminder) within one tap from the ⓘ toolbar button.
    public static let aboutSunSafetyActions =
        "Cover up if skin reddens. Reapply sunscreen at least every 2 hours regardless of timer."
    public static let mainVerdictCaveatLinkLabel = "Meds + conditions can shorten this. Learn more"

    /// WI-iris-d (Loop-11) — single source of truth for "UVI = 0" copy.
    ///
    /// Three render sites used to ship three different glyphs for the same
    /// state ("No UV detected" in `TierBadge`, "No UV at this hour" in
    /// `HeroTimerCard.heroContent`, "No active burn time because the UV
    /// index is 0" in `BurnRiskGaugeUnavailableCard`). A VoiceOver user
    /// hearing one and reading another would mistrust the surface.
    /// WI-iris-d collapses the trio onto this single Iris + Wheeler-approved
    /// constant. The accessibility-label variant adds the "No burn risk"
    /// tail because the hero `Label`'s VoiceOver read-out previously
    /// spelled it that way.
    public static let noUVAtThisHourLabel = "No UV at this hour"
    public static let noUVAtThisHourAccessibilityLabel = "No UV at this hour. No burn risk."

    public static let skinTypePickerPrompt = "Choose by how your skin burns and tans, not by how it looks."
    public static let skinTypePickerSubtext =
        "Pick the row that best matches what your skin does after about 30 minutes of midday summer sun, with no sunscreen and no recent tan. Each row covers a range of natural skin tones."
    public static let skinTypeSourcePointer =
        "Sources: Fitzpatrick 1988; NCBI Bookshelf 2017 (NBK481857). See About & Citations."
    public static let uvSourceLine = "Source: Apple Weather"
    public static let disclaimerLinkLabel = "Informational only. Not medical advice."
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
        "Skin type and SPF persist in app preferences on this device only and are never transmitted off-device. The app asks iOS for approximate location where available; rounded coordinates are sent to Apple Weather to fetch UV index data, and only the last rounded coordinate may be saved on this device. UV values and burn estimates are not retained between launches. The version of the informational disclaimer you acknowledged is stored on this device so the app does not re-prompt unless the disclaimer materially changes. No accounts, analytics, ads, crash SDKs, or third-party tracking."
    public static let whatTheAppDoesNotDo =
        "UV Burn Timer does not diagnose, prevent, or treat sunburn; does not replace professional medical advice; does not track your exposure over time; does not send alerts or timers; and does not account for shade, clothing, altitude, reflected glare, water, sweat, toweling, or changing weather after the UV value is fetched."
    public static let lastUpdatedLine = "Last updated: 2026-05-20."
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
        // Wheeler-L12 H1: locked Schalka source is the 2011 An Bras Dermatol
        // review (SPF-as-MED-multiplier claim) per
        // `.squad/decisions/archive/wheeler-fitzpatrick-and-med-anchor.md` §3.3.
        // The previous 2009 PPP application-thickness paper was the wrong target.
        ProductCitationLink(
            title: "Schalka & Reis 2011 — SPF as MED multiplier",
            url: URL(string: "https://doi.org/10.1590/S0365-05962011000300013")!
        ),
        // Wheeler-L12 H2: Sayre 1981 anchors the empirical MED measurements
        // for Fitzpatrick Types I/II/IV — cited by the EE2 per-row audit
        // comments in `FitzpatrickSkinType.swift` and by the prose in
        // `fitzpatrickCitations`. Citation-per-claim per health-adjacent-
        // constant-adoption SKILL §4.
        ProductCitationLink(
            title: "Sayre et al. 1981 — MED-per-type empirical anchor",
            url: URL(string: "https://doi.org/10.1016/S0190-9622(81)70105-1")!
        ),
        // Wheeler-L12 H2: Harrison & Young 2002 anchors the modern review
        // tabulating MED-by-type for Fitzpatrick Types III/V/VI — same
        // citation-per-claim rule.
        ProductCitationLink(
            title: "Harrison & Young 2002 — erythema dose-response review",
            url: URL(string: "https://doi.org/10.1016/S1046-2023(02)00205-0")!
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
        emptyStateAwaitingSkinType,
        emptyStateAwaitingLocation,
        disclaimerTitle,
        disclaimerBody,
        photosensitizerDisclaimerLine,
        photosensitizationAuthorityLine,
        childrenDisclaimerLine,
        photosensitizationBannerLabel,
        disclaimerSeeAboutInlinePrompt,
        disclaimerStorageLine,
        locationPrivacyLine,
        cacheRetentionLine,
        clearSavedLocationButtonTitle,
        clearStoredSkinTypeButtonTitle,
        clearStoredSPFButtonTitle,
        skinTypeChipUnsetLabel,
        skinTypeChipSetLabel(for: .typeIII),
        locationDeniedEmptyState,
        locationUnavailableMessage,
        locationRequestInProgressMessage,
        weatherUnavailableTitle,
        weatherUnavailableMessage,
        estimateElapsedWarning,
        longEstimateHedge,
        sunscreenCapHedge,
        reapplicationFooter,
        aboutSunSafetyActions,
        mainVerdictCaveatLinkLabel,
        noUVAtThisHourLabel,
        noUVAtThisHourAccessibilityLabel,
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
        whatTheAppDoesNotDo,
        lastUpdatedLine,
        outdoorReadabilityTip,
        weatherAttributionServiceName,
        weatherAttributionLegalURLString,
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
    /// Compose the VoiceOver read-out for the hero card.
    ///
    /// - Parameter forecastDateContext: WI-s — optional date prefix the
    ///   hero card renders above the gauge when the user selects a
    ///   forecast time other than "now" (e.g., "Burn time on Wed, 6 PM").
    ///   When non-nil and non-blank, the resulting summary leads with the
    ///   context as its own sentence so screen reader users know they
    ///   are inspecting a forecasted moment rather than the live UV
    ///   reading. When nil or blank (whitespace-only), the read-out is
    ///   byte-for-byte identical to the pre-WI-s shape — preserving the
    ///   "now" backward-compatibility contract pinned by
    ///   `heroAccessibilitySummaryCombinesSafetyCriticalVerdictContext`.
    public static func text(
        estimate: BurnTimeEstimate,
        uvIndex: Double?,
        verdict: String,
        forecastDateContext: String? = nil
    ) -> String {
        let uvText =
            uvIndex.map { "Current UV index: \($0.formatted(.number.precision(.fractionLength(1))))." }
            ?? "UV index unavailable."
        let baseSummary = "\(estimate.accessibilitySummary) \(uvText) \(verdict) tier. Estimated only, not medical advice."

        guard let trimmed = forecastDateContext?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return baseSummary
        }

        let terminated = trimmed.last.map { ".!?".contains($0) } == true ? trimmed : "\(trimmed)."
        return "\(terminated) \(baseSummary)"
    }
}

public struct LocationActionPresentation: Equatable, Sendable {
    public let title: String
    public let systemImageName: String
    public let accessibilityHint: String

    public init(
        hasUVIndex: Bool,
        isFetching: Bool
    ) {
        if isFetching {
            self.title = "Fetching UV..."
            self.systemImageName = "location.fill"
            self.accessibilityHint = "Fetching your location and current UV index from Apple Weather."
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
