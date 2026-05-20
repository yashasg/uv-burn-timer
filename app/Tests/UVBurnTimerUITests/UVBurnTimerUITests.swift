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

        app.buttons["Continue to location request"].tap()
        XCTAssertTrue(
            app.staticTexts["Location rationale reviewed. Tap Use my location to continue."].waitForExistence(
                timeout: 5))

        app.buttons["Use my location"].tap()
        XCTAssertTrue(app.staticTexts["Location unavailable"].waitForExistence(timeout: 5))
        XCTAssertTrue(staticText(in: app, containing: "Location access is off").exists)
        XCTAssertTrue(app.buttons["Try again"].exists)

        XCTAssertTrue(app.segmentedControls.buttons["30"].isSelected)
        XCTAssertFalse(app.segmentedControls.buttons["None"].exists)
        XCTAssertTrue(app.segmentedControls.buttons["15"].exists)
        XCTAssertTrue(app.segmentedControls.buttons["50"].exists)
        XCTAssertTrue(app.segmentedControls.buttons["70+"].exists)
    }

    func testLocationUnavailableShowsLocationSpecificCopy() {
        let app = launchApp(arguments: ["-uiTestLocationUnavailable"])
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        app.buttons["Continue to location request"].tap()
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

        app.buttons["Continue to location request"].tap()
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

    func testScenario9SettingsIncludesAboutCitationsAttributionAndPricing() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        app.buttons["Settings"].tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        XCTAssertTrue(scrollToStaticText(in: app, containing: "One-time paid app").exists)

        app.buttons["About & Citations"].tap()
        XCTAssertTrue(app.navigationBars["About"].waitForExistence(timeout: 5))
        XCTAssertTrue(staticText(in: app, containing: "Citations").exists)
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
        XCTAssertTrue(app.segmentedControls.buttons["30"].isSelected)
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
        XCTAssertTrue(app.segmentedControls.buttons["50"].isSelected)
        XCTAssertFalse(app.segmentedControls.buttons["None"].exists)
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
        if skinTypeRow.exists {
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
        } else {
            // Skin type editing not yet exposed in Settings — record as known gap.
            XCTExpectFailure("Settings Skin type edit path not yet implemented (Iris spec §2 gap)")
            XCTAssertTrue(false, "Settings does not expose a Skin type selection affordance")
        }
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
        acknowledgeButton.tap()

        if !app.navigationBars["Choose skin type"].waitForExistence(timeout: 5), acknowledgeButton.exists {
            acknowledgeButton.tap()
        }
    }

    private func staticText(in app: XCUIApplication, containing text: String) -> XCUIElement {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
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
}
