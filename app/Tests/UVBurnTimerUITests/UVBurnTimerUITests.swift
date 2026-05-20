import XCTest

@MainActor
final class UVBurnTimerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testScenario1ColdLaunchShowsRequiredDisclaimerThenScenario2RequiresSkinTypeSelection() {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["How accurate is this for you?"].waitForExistence(timeout: 5))
        XCTAssertTrue(staticText(in: app, containing: "Photosensitizing medications").isHittable)
        XCTAssertFalse(app.buttons["Don't Show Again"].exists)

        acknowledgeDisclaimer(in: app)

        XCTAssertTrue(app.navigationBars["Choose skin type"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["Continue"].isEnabled)
        XCTAssertFalse(app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Selected")).firstMatch.exists)

        app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Type III")).firstMatch.tap()

        XCTAssertTrue(app.buttons["Continue"].isEnabled)
        app.buttons["Continue"].tap()

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Ready when you are"].exists)
        XCTAssertTrue(staticText(in: app, containing: "Reapply sunscreen at least every 2 hours").exists)
        XCTAssertTrue(staticText(in: app, containing: "Not medical advice").exists)
    }

    func testScenarios3And6And7LocationRationaleDeniedStateAndSPFChoices() {
        let app = launchApp(arguments: ["-uiTestLocationDenied"])
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        XCTAssertTrue(app.staticTexts["Location permission"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            staticText(
                in: app,
                containing:
                    "Coordinates are rounded to 2 decimals for Apple Weather, and only the last rounded coordinate may be saved on this device."
            ).exists)
        XCTAssertTrue(app.buttons["Continue to location request"].exists)

        // Cover-chain race: the skin-type fullScreenCover may still be tearing
        // down when this tap fires, producing a {-1, -1} hit point silently
        // dropped by XCUITest. Re-tap until the rationale-reviewed banner
        // appears (or the budget expires).
        tapUntilAppears(
            app.buttons["Continue to location request"],
            app.staticTexts["Location rationale reviewed. Tap Use my location to continue."]
        )
        XCTAssertTrue(
            app.staticTexts["Location rationale reviewed. Tap Use my location to continue."].waitForExistence(
                timeout: 5))

        app.buttons["Use my location"].tap()
        XCTAssertTrue(app.staticTexts["Location unavailable"].waitForExistence(timeout: 5))
        XCTAssertTrue(staticText(in: app, containing: "Location access is off").exists)
        XCTAssertTrue(app.buttons["Try again"].exists)

        // Spec §6: SPF chip on main screen — Menu-style, compact, no "None" option.
        XCTAssertTrue(spfChipButton(in: app).waitForExistence(timeout: 5))
        XCTAssertEqual(spfChipButton(in: app).label, "SPF 30")
        spfChipButton(in: app).tap()
        XCTAssertTrue(menuOptionButton(in: app, label: "15").waitForExistence(timeout: 3))
        XCTAssertTrue(menuOptionButton(in: app, label: "30").exists)
        XCTAssertTrue(menuOptionButton(in: app, label: "50").exists)
        XCTAssertTrue(menuOptionButton(in: app, label: "70+").exists)
        XCTAssertFalse(menuOptionButton(in: app, label: "None").exists)
        menuOptionButton(in: app, label: "15").tap()
        XCTAssertTrue(spfChipButton(in: app).waitForExistence(timeout: 5))
        XCTAssertEqual(spfChipButton(in: app).label, "SPF 15")
    }

    func testLocationUnavailableShowsLocationSpecificCopy() {
        let app = launchApp(arguments: ["-uiTestLocationUnavailable"])
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        tapUntilAppears(
            app.buttons["Continue to location request"],
            app.staticTexts["Location rationale reviewed. Tap Use my location to continue."]
        )
        XCTAssertTrue(
            app.staticTexts["Location rationale reviewed. Tap Use my location to continue."].waitForExistence(
                timeout: 5))

        app.buttons["Use my location"].tap()
        XCTAssertTrue(app.staticTexts["Location unavailable"].waitForExistence(timeout: 5))
        XCTAssertTrue(staticText(in: app, containing: "Could not determine your location").exists)
        XCTAssertFalse(staticText(in: app, containing: "Could not reach Apple Weather").exists)
        assertUnavailableBurnRiskGaugeExists(in: app)
    }

    func testWeatherUnavailableShowsRetryAffordance() {
        let app = launchApp(arguments: ["-uiTestWeatherUnavailable"])
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        tapUntilAppears(
            app.buttons["Continue to location request"],
            app.staticTexts["Location rationale reviewed. Tap Use my location to continue."]
        )
        XCTAssertTrue(
            app.staticTexts["Location rationale reviewed. Tap Use my location to continue."].waitForExistence(
                timeout: 5))

        app.buttons["Use my location"].tap()
        XCTAssertTrue(app.staticTexts["Weather unavailable"].waitForExistence(timeout: 5))
        XCTAssertTrue(staticText(in: app, containing: "Could not reach Apple Weather").exists)
        XCTAssertTrue(app.buttons["Try again"].exists)
        assertUnavailableBurnRiskGaugeExists(in: app)
    }

    func testLocationButtonStartsLocationFlowInsteadOfSettings() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        app.buttons["Location"].tap()

        XCTAssertFalse(
            app.navigationBars["Settings"].waitForExistence(timeout: 1),
            "The Location chip must not route to the Settings sheet")
        XCTAssertTrue(
            app.staticTexts["Location rationale reviewed. Tap Use my location to continue."].waitForExistence(
                timeout: 5))
        XCTAssertTrue(app.buttons["Use my location"].exists)
    }

    func testScenario4WeatherAttributionFallbackRemainsVisible() {
        let app = launchApp(arguments: ["-uiTestWeatherAttributionUnavailable"])
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        XCTAssertTrue(app.staticTexts["Source: Apple Weather"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Apple Weather"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Apple Weather attribution unavailable"].waitForExistence(timeout: 5))
        XCTAssertTrue(actionElement(in: app, named: "Data sources").exists)
    }

    func testScenario4NormalWeatherAttributionLinkRemainsFocusable() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        XCTAssertTrue(actionElement(in: app, named: "Data sources").exists)
    }

    // MARK: - WeatherKit attribution audit (Plunder pre-submit flag #2)
    //
    // WeatherKit's terms of use require the official Apple Weather lockup
    // (or the "Apple Weather" service-name fallback) to be visible in the
    // same viewport as any Apple-Weather-sourced data. Audit every weather-
    // derived main-screen state to confirm the attribution survives the
    // success path, the stale-estimate path, the sunscreen-capped path,
    // the WeatherKit-unreachable path, and the location-denied empty state.

    func testAppleWeatherAttributionVisibleOnFreshUVEstimate() {
        let app = launchApp(arguments: ["-uiTestLongUncappedEstimate"])

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))
        assertAppleWeatherAttributionVisible(in: app)
    }

    func testAppleWeatherAttributionVisibleOnStaleEstimate() {
        let app = launchApp(arguments: ["-uiTestStaleEstimate"])

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Estimate window elapsed"].waitForExistence(timeout: 5))
        assertAppleWeatherAttributionVisible(in: app)
    }

    func testAppleWeatherAttributionVisibleOnCappedEstimate() {
        let app = launchApp(arguments: ["-uiTestCappedEstimate"])

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Up to 2 hr"].waitForExistence(timeout: 5))
        assertAppleWeatherAttributionVisible(in: app)
    }

    func testAppleWeatherAttributionVisibleWhenWeatherUnavailable() {
        let app = launchApp(arguments: ["-uiTestWeatherUnavailable"])
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        tapUntilAppears(
            app.buttons["Continue to location request"],
            app.staticTexts["Location rationale reviewed. Tap Use my location to continue."]
        )
        XCTAssertTrue(
            app.staticTexts["Location rationale reviewed. Tap Use my location to continue."].waitForExistence(
                timeout: 5))

        app.buttons["Use my location"].tap()
        XCTAssertTrue(app.staticTexts["Weather unavailable"].waitForExistence(timeout: 5))
        assertAppleWeatherAttributionVisible(in: app)
    }

    func testAppleWeatherAttributionVisibleWhenLocationDenied() {
        let app = launchApp(arguments: ["-uiTestLocationDenied"])
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        tapUntilAppears(
            app.buttons["Continue to location request"],
            app.staticTexts["Location rationale reviewed. Tap Use my location to continue."]
        )
        XCTAssertTrue(
            app.staticTexts["Location rationale reviewed. Tap Use my location to continue."].waitForExistence(
                timeout: 5))

        app.buttons["Use my location"].tap()
        XCTAssertTrue(app.staticTexts["Location unavailable"].waitForExistence(timeout: 5))
        assertAppleWeatherAttributionVisible(in: app)
    }

    func testScenario8StaleEstimateShowsWarningRecalculateAndAccessibleTierSeverity() {
        let app = launchApp(arguments: ["-uiTestStaleEstimate"])

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Estimate window elapsed"].exists)
        XCTAssertTrue(app.buttons["Recalculate"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["Short burn-time tier — critical"].exists)
        XCTAssertTrue(staticText(in: app, containing: "Reapply sunscreen at least every 2 hours").exists)
    }

    func testScenario8ForegroundAfterElapsedEstimateReattestsDisclaimer() {
        let app = launchApp(arguments: ["-uiTestStaleEstimate"])

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))
        XCUIDevice.shared.press(.home)
        app.activate()

        XCTAssertTrue(app.staticTexts["How accurate is this for you?"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Don't Show Again"].exists)
    }

    func testScenario5CappedEstimateRendersLongCaveatAndFooter() {
        let app = launchApp(arguments: ["-uiTestCappedEstimate"])

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Up to 2 hr"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Sunscreen reapplication limit"].exists)
        XCTAssertTrue(staticText(in: app, containing: "capped at 2 hours").exists)
        XCTAssertTrue(app.staticTexts["Long estimate caveat"].exists)
        XCTAssertTrue(staticText(in: app, containing: "does not mean prolonged sun exposure is safe").exists)
        XCTAssertTrue(staticText(in: app, containing: "Reapply sunscreen at least every 2 hours").exists)
    }

    func testLongUncappedEstimateStillRendersSafetyCaveat() {
        let app = launchApp(arguments: ["-uiTestLongUncappedEstimate"])

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["~1 hr 20 min"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Long estimate caveat"].exists)
        XCTAssertTrue(
            app.descendants(matching: .any)["Long burn-time tier — longer estimate, not safe exposure"].exists)
        XCTAssertTrue(staticText(in: app, containing: "does not mean prolonged sun exposure is safe").exists)
    }

    func testBurnRiskGaugeExistsAndIsMeaningfulOnStaleEstimate() {
        // The -uiTestStaleEstimate seed sets uvIndex=10, fetchedAt 15 min ago, typeI.
        // With elapsed > 0 and a valid estimate the gauge must be present and not at 0%.
        let app = launchApp(arguments: ["-uiTestStaleEstimate"])

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))

        let gauge = app.descendants(matching: .any)["BurnRiskGauge"]
        XCTAssertTrue(
            gauge.waitForExistence(timeout: 5),
            "BurnRiskGaugeCard must appear when an estimate and fetchedAt are available")

        // Gauge value must not read 0% — 15 minutes have elapsed against a burn window.
        let gaugeValue = gauge.value as? String ?? ""
        XCTAssertFalse(gaugeValue == "0%", "Gauge must reflect elapsed burn time, not 0%")
    }

    func testBurnRiskGaugeShellExistsWhenNoEstimate() {
        // Cold launch with no UV data — keep the circular shell visible, but label it unavailable
        // so simulator/development no-location states are testable without fake weather data.
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        let gauge = app.descendants(matching: .any)["BurnRiskGauge"]
        XCTAssertTrue(gauge.waitForExistence(timeout: 5), "BurnRiskGauge shell must appear without a UV estimate")
        XCTAssertTrue(gauge.label.localizedCaseInsensitiveContains("unavailable"))
        XCTAssertEqual(gauge.value as? String, "Unavailable")
    }

    func testCircularGaugePresentOnFreshEstimate() {
        // Fresh estimate — not stale, not capped — gauge must be present as the secondary visual cue.
        // Regression guard: gauge must not be silently removed or conditioned on stale state only.
        let app = launchApp(arguments: ["-uiTestLongUncappedEstimate"])

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["~1 hr 20 min"].waitForExistence(timeout: 5))

        let gauge = app.descendants(matching: .any)["BurnRiskGauge"]
        XCTAssertTrue(
            gauge.waitForExistence(timeout: 5),
            "BurnRiskGauge must be present on a fresh estimate, not only on stale ones"
        )
        XCTAssertTrue(
            gauge.isHittable,
            "BurnRiskGauge must be visible without scrolling or being covered by the persistent footer"
        )
        XCTAssertTrue(
            gauge.frame.width >= 150 && gauge.frame.height >= 150,
            "BurnRiskGauge must render as a prominent circular gauge, not a tiny accessory control"
        )
    }

    func testHeroTimeEstimateRemainsDominantAlongsideGauge() {
        // Gauge is the secondary cue; the hero estimate must remain the primary surface.
        // Regression guard: gauge must NOT replace the hero number.
        let app = launchApp(arguments: ["-uiTestLongUncappedEstimate"])

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))

        // Hero estimate visible as the dominant element.
        XCTAssertTrue(
            app.staticTexts["~1 hr 20 min"].waitForExistence(timeout: 5),
            "Hero time estimate must be visible — it is the primary cue, not the gauge"
        )

        // Gauge co-exists with the hero — it does not replace it.
        let gauge = app.descendants(matching: .any)["BurnRiskGauge"]
        XCTAssertTrue(
            gauge.waitForExistence(timeout: 5),
            "Gauge must co-exist with the hero estimate as a secondary cue"
        )
    }

    func testCircularGaugeAccessibilityLabelIsNonColorAndMeaningful() {
        // Iris spec (iris-redesign-a11y-review.md Issue 2): gauge must carry a text label
        // that names the concept and gives a percentage — color is never the only differentiator.
        // Spec: accessibilityLabel("Burn risk gauge. N% of estimated burn window elapsed.")
        //       accessibilityValue(percentText)  e.g. "0%"
        let app = launchApp(arguments: ["-uiTestLongUncappedEstimate"])

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))

        let gauge = app.descendants(matching: .any)["BurnRiskGauge"]
        XCTAssertTrue(gauge.waitForExistence(timeout: 5))

        // Label must name the gauge concept, not rely on color alone.
        XCTAssertTrue(
            gauge.label.localizedCaseInsensitiveContains("Burn risk gauge"),
            "accessibilityLabel must contain 'Burn risk gauge' — color is never the sole differentiator"
        )
        XCTAssertTrue(
            gauge.label.localizedCaseInsensitiveContains("elapsed"),
            "accessibilityLabel must describe elapsed progress in text, not color alone"
        )

        // Value must be a percentage string so VoiceOver announces a number, not silence.
        let value = gauge.value as? String ?? ""
        XCTAssertTrue(
            value.hasSuffix("%"),
            "accessibilityValue must be a percentage (e.g. '0%') so VoiceOver announces it"
        )
    }

    func testScenario4PhotosensitizationReachBackOpensAboutApplicability() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        app.buttons["Meds or photosensitive conditions? Learn more"].tap()

        XCTAssertTrue(app.navigationBars["About"].waitForExistence(timeout: 5))
        XCTAssertTrue(staticText(in: app, containing: "When this estimate may not apply").exists)
        XCTAssertTrue(scrollToActionElement(in: app, named: "NIH MedlinePlus sun-sensitivity overview").exists)
    }

    /// Spec §LANE 2 #3 + LANE 3 callout #2 (Suchi Asha overlay): the
    /// photosensitization reach-back is a *banner*, not a chip — it spans
    /// the full row, sits above the hero card, and serves as the L1
    /// reach-back surface for users on photosensitizing meds. The previous
    /// `Button.buttonStyle(.bordered).tint(.orange)` rendered as an
    /// orange-tinted chip that was easy to mistake for a regular content
    /// button. Lock the layout contract:
    ///   1. The banner is reachable on the main screen with the dedicated
    ///      `PhotosensitizationBanner` accessibility identifier.
    ///   2. It spans ≥85% of the screen width.
    ///   3. It sits above the hero `Burn-time estimate` card.
    func testPhotosensitizationBannerRendersAsFullWidthBannerAboveHero() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        let banner = app.buttons["PhotosensitizationBanner"]
        XCTAssertTrue(
            banner.waitForExistence(timeout: 5),
            "Photosensitization affordance must expose the PhotosensitizationBanner accessibility identifier"
        )

        let screenWidth = app.windows.firstMatch.frame.width
        XCTAssertGreaterThanOrEqual(
            banner.frame.width,
            screenWidth * 0.85,
            "Photosensitization affordance must render as a banner spanning ≥85% of screen width, not a chip"
        )

        let heroTitle = app.staticTexts["Burn-time estimate"]
        XCTAssertTrue(heroTitle.waitForExistence(timeout: 5))
        XCTAssertLessThan(
            banner.frame.midY,
            heroTitle.frame.midY,
            "Photosensitization banner must sit above the Burn-time estimate card"
        )
    }

    func testScenario9SettingsIncludesAboutCitationsAttributionAndPricing() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        app.buttons["Settings"].tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        XCTAssertTrue(scrollToStaticText(in: app, containing: "One-time paid app").exists)

        app.buttons["About & Citations"].tap()
        XCTAssertTrue(app.navigationBars["About"].waitForExistence(timeout: 5))
        XCTAssertTrue(staticText(in: app, containing: "Citations").exists)
        XCTAssertTrue(scrollToStaticText(in: app, containing: "What this app does not do").exists)
        XCTAssertTrue(scrollToStaticText(in: app, containing: "Version 1.0").exists)
        XCTAssertTrue(scrollToStaticText(in: app, containing: "Last updated: 2026-05-20").exists)
        XCTAssertTrue(scrollToActionElement(in: app, named: "WHO Global Solar UV Index practical guide").exists)
        app.navigationBars["About"].buttons.firstMatch.tap()

        app.buttons["Attribution & Legal"].tap()
        XCTAssertTrue(app.navigationBars["Attribution"].waitForExistence(timeout: 5))
        XCTAssertTrue(actionElement(in: app, named: "Apple Weather data sources").exists)
        XCTAssertTrue(app.staticTexts["https://weatherkit.apple.com/legal-attribution.html"].exists)
    }

    func testScenario10CorruptSavedLocationIsClearedAndPrivacyControlDisabled() {
        let app = launchApp(arguments: ["-uiTestCorruptRoundedCoordinate"])
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        app.buttons["Settings"].tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        XCTAssertTrue(scrollToStaticText(in: app, containing: "does not save UV values").exists)
        let clearSavedLocationButton = scrollToActionElement(in: app, named: "Clear saved location")
        XCTAssertTrue(clearSavedLocationButton.exists)
        XCTAssertFalse(clearSavedLocationButton.isEnabled)
    }

    func testScenario10SavedLocationRestoresAndCanBeCleared() {
        let app = launchApp(arguments: ["-uiTestSavedRoundedCoordinate"])

        acknowledgeDisclaimer(in: app)
        XCTAssertTrue(app.navigationBars["Choose skin type"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["Continue"].isEnabled)
        XCTAssertFalse(app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Selected")).firstMatch.exists)
        app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Type III")).firstMatch.tap()
        app.buttons["Continue"].tap()

        XCTAssertTrue(staticText(in: app, containing: "Approx. 37.77, -122.42").waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Ready when you are"].exists)
        XCTAssertEqual(spfChipButton(in: app).label, "SPF 30")
        XCTAssertFalse(app.staticTexts["4+ hr"].exists)
        XCTAssertFalse(app.staticTexts["UV Index 8.0"].exists)
        app.buttons["Settings"].tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        XCTAssertTrue(scrollToStaticText(in: app, containing: "does not save UV values").exists)
        XCTAssertTrue(app.buttons["Clear saved location"].isEnabled)
        app.buttons["Clear saved location"].tap()
        app.buttons["Done"].tap()

        XCTAssertTrue(app.buttons["Location"].waitForExistence(timeout: 5))
        XCTAssertFalse(staticText(in: app, containing: "Approx. 37.77, -122.42").exists)
    }

    func testSavedPreferencesRestoreAfterDisclaimerWithoutRepeatingPrompts() {
        let app = launchApp(arguments: ["-uiTestSavedPreferences"])

        XCTAssertTrue(app.staticTexts["How accurate is this for you?"].waitForExistence(timeout: 5))
        app.buttons["I understand"].tap()

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.navigationBars["Choose skin type"].exists)
        XCTAssertFalse(app.staticTexts["Location permission"].exists)
        XCTAssertTrue(staticText(in: app, containing: "Approx. 37.77, -122.42").waitForExistence(timeout: 5))
        XCTAssertEqual(spfChipButton(in: app).label, "SPF 50")
        XCTAssertFalse(app.buttons["None"].exists)
    }

    /// Explicit regression for the location-rationale persistence ADR
    /// (`.squad/decisions/inbox/gaia-location-rationale-persistence.md`):
    /// once a user has acknowledged the inline `LocationRationaleCard`,
    /// subsequent cold launches must restore the ack from UserDefaults so
    /// the rationale card is *not* re-rendered. This isolates the
    /// rationale-ack contract from
    /// `testSavedPreferencesRestoreAfterDisclaimerWithoutRepeatingPrompts`,
    /// which bundles skin type + SPF + rounded coordinate restoration into
    /// a single assertion. The L1 safety disclaimer continues to re-fire on
    /// every cold launch and that is correct — only the rationale card
    /// persists.
    func testLocationRationaleAcknowledgementSurvivesRelaunch() {
        let app = launchApp(arguments: ["-uiTestSavedPreferences"])

        XCTAssertTrue(app.staticTexts["How accurate is this for you?"].waitForExistence(timeout: 5))
        app.buttons["I understand"].tap()

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))
        XCTAssertFalse(
            app.staticTexts["Location permission"].exists,
            "LocationRationaleCard must not re-appear on a launch where the user already acknowledged it"
        )

        // Headline + body of the LocationRationaleCard must both be absent.
        XCTAssertFalse(
            staticText(
                in: app,
                containing:
                    "Coordinates are rounded to 2 decimals for Apple Weather, and only the last rounded coordinate may be saved on this device."
            ).exists,
            "Rationale body copy must not re-appear once the ack is restored from UserDefaults"
        )
    }

    /// WI-11 (P1): after the user finishes onboarding (Type III committed),
    /// the hero empty state must prompt them to fetch a UV index — NOT to do
    /// the skin-type step they just completed. The previous implementation
    /// initialised `RootView.statusMessage` to "Pick a skin type to see your
    /// estimate." and never refreshed it when the session got a skin type,
    /// so every persona landed on a main screen telling them to do something
    /// they had already done.
    func testHeroEmptyStateAfterOnboardingPromptsForLocation() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        // Hero copy after onboarding must direct the user to the next action
        // (location) — not loop them back to the just-completed step.
        XCTAssertTrue(
            staticText(in: app, containing: "Tap Use my location to compute your estimate").waitForExistence(
                timeout: 5),
            "Hero empty-state copy must prompt for location once a skin type is selected"
        )
        XCTAssertFalse(
            app.staticTexts["Pick a skin type to see your estimate."].exists,
            "Hero must stop asking for skin type after one has been committed via onboarding"
        )
    }

    func testMainScreenDoesNotExposeFitzpatrickPickerAfterOnboarding() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        // Main screen must not show the skin-type picker — Fitzpatrick selection
        // belongs in onboarding/Settings only (Iris spec + D-2026-05-19-012).
        XCTAssertFalse(app.navigationBars["Choose skin type"].exists)
        XCTAssertFalse(app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Type I")).firstMatch.isHittable)
        XCTAssertFalse(
            app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Type VI")).firstMatch.isHittable)

        // Main screen remains — the UV dashboard is the active surface.
        XCTAssertTrue(app.navigationBars["UV Burn Timer"].exists)
    }

    func testMainScreenShowsLocationAndSPFInCompactRow() {
        // Spec §6: "Location + SPF row — compact 44pt controls for `📍 ... ›` and `SPF 30`."
        // Both chips must coexist in a single row, both ≥44pt tap targets, both reachable
        // (possibly after scrolling on small/dense layouts), and SPF must not be presented
        // as a full-width segmented control on the main screen.
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        let location = app.buttons["Location"]
        let spf = spfChipButton(in: app)
        XCTAssertTrue(location.waitForExistence(timeout: 5), "Location chip must exist on main screen")
        XCTAssertTrue(spf.waitForExistence(timeout: 5), "SPF chip must exist on main screen")

        scrollInputsRowIntoView(in: app, location: location, spf: spf)

        XCTAssertTrue(location.isHittable, "Location chip must be reachable on the main screen")
        XCTAssertTrue(spf.isHittable, "SPF chip must be reachable on the main screen")

        XCTAssertGreaterThanOrEqual(location.frame.height, 44, "Location chip must be at least 44pt tall")
        XCTAssertGreaterThanOrEqual(spf.frame.height, 44, "SPF chip must be at least 44pt tall")

        // Chips share a single horizontal row at standard Dynamic Type sizes.
        let verticalDistance = abs(location.frame.midY - spf.frame.midY)
        XCTAssertLessThanOrEqual(
            verticalDistance,
            max(location.frame.height, spf.frame.height),
            "Location and SPF chips must share a single horizontal row, not stacked vertically"
        )

        // Neither chip occupies the entire screen width — they share the row.
        let screenWidth = app.windows.firstMatch.frame.width
        XCTAssertLessThan(
            location.frame.width,
            screenWidth * 0.85,
            "Location chip must not consume the full row width; SPF must sit beside it"
        )
        XCTAssertLessThan(
            spf.frame.width,
            screenWidth * 0.85,
            "SPF chip must not consume the full row width; Location must sit beside it"
        )

        // SPF picker on the main screen must NOT be a segmented control — that pattern
        // is reserved for Settings. The chip is a Menu trigger.
        XCTAssertEqual(
            app.segmentedControls.count, 0,
            "Main screen must not render a segmented control for SPF; use the compact chip menu"
        )
    }

    func testMainScreenSPFChipOpensMenuWithAllFourLevels() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        let spf = spfChipButton(in: app)
        XCTAssertTrue(spf.waitForExistence(timeout: 5))
        XCTAssertEqual(spf.label, "SPF 30", "Default SPF is 30")

        scrollInputsRowIntoView(in: app, location: app.buttons["Location"], spf: spf)
        spf.tap()
        XCTAssertTrue(menuOptionButton(in: app, label: "15").waitForExistence(timeout: 3))
        XCTAssertTrue(menuOptionButton(in: app, label: "30").exists)
        XCTAssertTrue(menuOptionButton(in: app, label: "50").exists)
        XCTAssertTrue(menuOptionButton(in: app, label: "70+").exists)
        XCTAssertFalse(
            menuOptionButton(in: app, label: "None").exists,
            "SPF 'None' must not appear in the main-screen menu"
        )

        menuOptionButton(in: app, label: "70+").tap()
        XCTAssertTrue(spfChipButton(in: app).waitForExistence(timeout: 5))
        XCTAssertEqual(spfChipButton(in: app).label, "SPF 70+")
    }

    func testPersistentFooterDisclaimerLinkUsesSpecCopyAndOpensAbout() {
        // Spec §7 (user-flow-onboarding-main-spec.md): "inline bottom-of-content link:
        // `Informational only. Not medical advice. →`." The persistent footer must
        // surface this exact label and route to the About applicability anchor.
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        let footerLink = actionElement(in: app, named: "Informational only. Not medical advice.")
        XCTAssertTrue(
            footerLink.waitForExistence(timeout: 5),
            "Footer must surface the spec-mandated disclaimer link copy"
        )
        XCTAssertFalse(
            app.buttons["About & applicability"].exists,
            "Legacy disclaimer-link copy must no longer appear"
        )

        footerLink.tap()

        XCTAssertTrue(app.navigationBars["About"].waitForExistence(timeout: 5))
        XCTAssertTrue(staticText(in: app, containing: "When this estimate may not apply").exists)
    }

    func testSkinTypePickerInSettingsReusesOnboardingPattern() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Settings should provide a Skin type edit affordance (Iris spec §2).
        // Type I–VI rows must all be reachable.
        let skinTypeRow =
            app.cells["Skin type"].firstMatch.exists
            ? app.cells["Skin type"].firstMatch
            : app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Skin type")).firstMatch
        XCTAssertTrue(skinTypeRow.waitForExistence(timeout: 5))
        skinTypeRow.tap()

        // All six Fitzpatrick rows must be reachable. Scroll down if needed —
        // the sheet may start at medium detent, placing later rows below the fold.
        for numeral in ["I", "II", "III", "IV", "V", "VI"] {
            let rowButton = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Type \(numeral)"))
                .firstMatch
            for _ in 0..<3 where !rowButton.exists {
                app.swipeUp()
            }
            XCTAssertTrue(
                rowButton.waitForExistence(timeout: 5),
                "Type \(numeral) row missing in Settings skin-type selector"
            )
        }

        scrollToActionElement(in: app, named: "Open About & Citations").tap()
        XCTAssertTrue(app.navigationBars["About"].waitForExistence(timeout: 5))
        XCTAssertTrue(staticText(in: app, containing: "Citations").exists)
    }

    private func launchApp(arguments: [String] = []) -> XCUIApplication {
        // Explicitly terminate any running instance before launching to avoid
        // "Failed to terminate" races between test methods on CI (Xcode 26).
        XCUIApplication().terminate()
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestResetDefaults"] + arguments
        app.launch()
        return app
    }

    private func acknowledgeDisclaimerAndChooseTypeIII(in app: XCUIApplication) {
        acknowledgeDisclaimer(in: app)

        XCTAssertTrue(app.navigationBars["Choose skin type"].waitForExistence(timeout: 15))
        let typeIIIButton = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Type III")).firstMatch
        XCTAssertTrue(typeIIIButton.waitForExistence(timeout: 5))
        typeIIIButton.tap()

        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 5))
        if !waitForEnabled(continueButton, timeout: 5) {
            typeIIIButton.tap()
        }
        XCTAssertTrue(waitForEnabled(continueButton, timeout: 10))
        continueButton.tap()

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))
    }

    private func acknowledgeDisclaimer(in app: XCUIApplication) {
        let acknowledgeButton = app.buttons["I understand"]
        XCTAssertTrue(acknowledgeButton.waitForExistence(timeout: 10))

        // Cover-chain race: on iOS 26 / Xcode 26, XCUITest can synthesize a
        // tap at hit point {-1, -1} while the `.fullScreenCover` disclaimer is
        // mid-presentation animation, silently dropping the tap even though
        // the element reports `exists` + `isHittable` from a stale snapshot.
        // Re-tap the acknowledge button until either the skin-type cover
        // claims the presentation slot (signalled by the "Choose skin type"
        // navigation bar) or the budget expires. This keeps tests honest about
        // any real regression — if the cover-chain is actually broken, the
        // assertion below will still fire after the budget.
        tapUntilAppears(acknowledgeButton, app.navigationBars["Choose skin type"])
    }

    private func staticText(in app: XCUIApplication, containing text: String) -> XCUIElement {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    private func spfChipButton(in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "SPF ")).firstMatch
    }

    /// Matches a menu option whose label contains the option text. Picker-in-Menu items
    /// can be rendered with a "Selected" prefix/suffix on the currently chosen option,
    /// so an exact match would miss them.
    private func menuOptionButton(in app: XCUIApplication, label: String) -> XCUIElement {
        let exact = app.buttons[label]
        if exact.exists {
            return exact
        }
        return app.buttons.matching(NSPredicate(format: "label MATCHES %@", "(?i)(?:selected,?\\s*)?\(NSRegularExpression.escapedPattern(for: label))(?:,?\\s*selected)?")).firstMatch
    }

    /// Scrolls the main-screen ScrollView so the compact Location + SPF row enters the
    /// hit-test region. On dense iPhone simulator layouts the row can land below the fold
    /// behind the persistent bottom inset before any user gesture.
    private func scrollInputsRowIntoView(in app: XCUIApplication, location: XCUIElement, spf: XCUIElement) {
        let scrollView = app.scrollViews.firstMatch
        guard scrollView.exists else {
            return
        }
        for _ in 0..<6 where !(location.exists && spf.exists && location.isHittable && spf.isHittable) {
            scrollView.swipeUp()
        }
    }

    private func scrollToStaticText(in app: XCUIApplication, containing text: String) -> XCUIElement {
        let element = staticText(in: app, containing: text)
        let scrollView = app.scrollViews.firstMatch

        for _ in 0..<5 where !element.exists {
            scrollView.swipeUp()
        }

        return element
    }

    private func actionElement(in app: XCUIApplication, named label: String) -> XCUIElement {
        let link = app.links[label]
        if link.exists {
            return link
        }

        return app.buttons[label]
    }

    private func scrollToActionElement(in app: XCUIApplication, named label: String) -> XCUIElement {
        let element = actionElement(in: app, named: label)
        let scrollView = app.scrollViews.firstMatch

        for _ in 0..<5 where !element.exists {
            scrollView.swipeUp()
        }

        return element
    }

    private func assertUnavailableBurnRiskGaugeExists(in app: XCUIApplication) {
        let gauge = app.descendants(matching: .any)["BurnRiskGauge"]
        XCTAssertTrue(
            gauge.waitForExistence(timeout: 5), "BurnRiskGauge shell must remain visible when UV is unavailable")
        XCTAssertTrue(gauge.isHittable, "BurnRiskGauge shell must be visible in unavailable states")
        XCTAssertTrue(gauge.label.localizedCaseInsensitiveContains("unavailable"))
        XCTAssertEqual(gauge.value as? String, "Unavailable")
    }

    /// Asserts WeatherKit's required "Apple Weather" attribution lockup or
    /// service-name fallback is on the main screen for any state that
    /// displays Apple-Weather-derived data (live UV, stale UV, capped UV,
    /// weather-unreachable error, location-denied empty state).
    ///
    /// WeatherAttributionView renders `Text(ProductCopy.weatherAttributionServiceName)`
    /// when `WeatherService.shared.attribution` throws (the common case on
    /// the test simulator without a real WeatherKit network round-trip), so
    /// the literal "Apple Weather" string must remain accessible in every
    /// weather-derived viewport. UVIndexCard/UVIndexPlaceholderCard also
    /// renders `ProductCopy.uvSourceLine` ("Source: Apple Weather") above
    /// the lockup; either surface satisfies the visibility requirement.
    private func assertAppleWeatherAttributionVisible(
        in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line
    ) {
        let sourceLine = scrollToStaticText(in: app, containing: "Source: Apple Weather")
        let attributionName = app.staticTexts.matching(NSPredicate(format: "label == %@", "Apple Weather")).firstMatch

        let sourceLineVisible = sourceLine.exists
        let attributionNameVisible = attributionName.waitForExistence(timeout: 3)

        XCTAssertTrue(
            sourceLineVisible || attributionNameVisible,
            "WeatherKit attribution must remain visible on every weather-derived surface — "
                + "expected 'Source: Apple Weather' or the WeatherAttributionView 'Apple Weather' label.",
            file: file, line: line
        )
    }

    private func waitForEnabled(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if element.exists && element.isEnabled {
                return true
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }

        return element.exists && element.isEnabled
    }

    private func waitForHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if element.exists && element.isHittable {
                return true
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }

        return element.exists && element.isHittable
    }

    /// XCUITest on iOS 26 occasionally computes hit point {-1, -1} for views
    /// mid-presentation animation, swallowing the tap. Retry with a short
    /// settle delay before giving up so transient layout races do not produce
    /// flaky failures in the chained disclaimer → onboarding flow.
    ///
    /// `element.tap()` resolves the tap target via the accessibility
    /// activation point, which iOS 26 sometimes reports as `{-1, -1}` while
    /// a `.fullScreenCover` is still animating in — the resulting tap is
    /// dropped without an error. Computing the hit point from the element's
    /// frame via `coordinate(withNormalizedOffset:)` bypasses that resolver
    /// and reliably lands the synthesized event inside the rendered bounds.
    private func tapWithRetry(_ element: XCUIElement, retries: Int = 2) {
        _ = waitForHittable(element, timeout: 5)
        for _ in 0..<retries {
            if element.exists && element.isHittable {
                let frame = element.frame
                if frame.width > 0 && frame.height > 0 {
                    element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
                    return
                }
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.3))
        }

        if element.exists {
            let frame = element.frame
            if frame.width > 0 && frame.height > 0 {
                element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            } else {
                element.tap()
            }
        }
    }

    /// Re-taps `trigger` until `target` appears, the trigger disappears, or
    /// the total budget expires. Defends against the iOS 26 / Xcode 26
    /// cover-presentation race where XCUITest synthesizes a tap at hit point
    /// {-1, -1} for an element whose host view is still animating in; that
    /// tap is silently dropped even though `exists` + `isHittable` return
    /// true from a stale snapshot. A single re-tap is normally enough; the
    /// loop keeps the contract honest by polling for the expected state
    /// change and bailing once observed (or once the trigger goes away,
    /// indicating an earlier tap landed and the host view has dismissed).
    private func tapUntilAppears(_ trigger: XCUIElement, _ target: XCUIElement, totalTimeout: TimeInterval = 30) {
        let deadline = Date().addingTimeInterval(totalTimeout)
        while Date() < deadline && trigger.exists && !target.exists {
            tapWithRetry(trigger)
            _ = target.waitForExistence(timeout: 4)
        }
    }
}
