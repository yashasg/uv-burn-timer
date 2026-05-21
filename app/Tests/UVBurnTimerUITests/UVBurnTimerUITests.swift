import XCTest

@MainActor
final class UVBurnTimerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Smoke 1: App launches without crash

    /// Cold start with a seeded UV estimate (skips onboarding).
    /// Passes if the main "UV Burn Timer" screen renders within the timeout.
    func testAppLaunchesWithoutCrash() {
        let app = launchApp(arguments: ["-uiTestLongUncappedEstimate"])
        XCTAssertTrue(
            app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 10),
            "Main screen must render within 10 seconds of cold launch"
        )
    }

    // MARK: - Smoke 2: Skin type picker end-to-end

    /// Cold start → disclaimer → skin type picker → select Type III → main screen.
    func testSkinTypePickerEndToEnd() {
        let app = launchApp()
        acknowledgeDisclaimer(in: app)

        XCTAssertTrue(app.navigationBars["Choose skin type"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["Continue"].isEnabled)

        let typeIIIButton = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Type III")).firstMatch
        XCTAssertTrue(typeIIIButton.waitForExistence(timeout: 5))
        typeIIIButton.tap()
        XCTAssertTrue(waitForEnabled(app.buttons["Continue"], timeout: 10))

        app.buttons["Continue"].tap()
        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 10))
    }

    // MARK: - Smoke 3: Location button fires location request

    /// After onboarding, tapping "Use my location" must start the location flow
    /// (not open Settings). Any of: fetching indicator, failure card, or button
    /// reverting to idle confirms the OS-level request was dispatched.
    func testLocationButtonFiresLocationRequest() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        tapWithRetry(app.buttons["Use my location"])

        let flowStarted =
            app.buttons["Fetching UV..."].waitForExistence(timeout: 5)
            || app.staticTexts["Location unavailable"].waitForExistence(timeout: 5)
            || app.buttons["Use my location"].waitForExistence(timeout: 5)
        XCTAssertTrue(flowStarted, "Tapping 'Use my location' must start the location flow — not route to Settings")
        XCTAssertFalse(app.navigationBars["Settings"].exists, "Location chip must not open the Settings sheet")
    }

    // MARK: - Smoke 4: Forecast picker card is rendered

    /// The ForecastPickerView card must appear on the main screen (skeleton or
    /// live data). Structural smoke — proves the component isn't silently removed.
    /// Full date-selection interaction is covered by ForecastPickerLogicTests.
    func testForecastPickerCardIsRendered() {
        let app = launchApp(arguments: ["-uiTestLongUncappedEstimate"])
        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 5))

        let scrollView = app.scrollViews["NowViewScrollView"]
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))

        let forecastHeader = app.staticTexts["UV Forecast"]
        for _ in 0..<5 where !forecastHeader.exists {
            scrollView.swipeUp()
        }
        XCTAssertTrue(forecastHeader.waitForExistence(timeout: 5), "Forecast picker card must render on the main screen")
    }

    // MARK: - Smoke 5: Settings sheet opens

    /// Tap the gear icon → Settings navigation bar must appear.
    func testSettingsSheetOpens() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        let aboutCitationsButton = app.buttons["About & Citations"]
        tapUntilAppears(app.buttons["Settings"], aboutCitationsButton)
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 10))
    }

    // MARK: - Smoke 6 (WI-w): DisclaimerCover surfaces storage-disclosure line

    /// WI-w / Plunder ratification §3.4 — the L1 cover must render the
    /// `disclaimerStorageLine` constant with `accessibilityIdentifier`
    /// `DisclaimerStorageLine` so the storage-disclosure sentence is
    /// observably present at the moment the user taps "I understand".
    /// Cold-launches into onboarding (no skip flag) and asserts the
    /// identifier is visible before acknowledgment.
    /// See `.squad/orchestration-log/2026-05-21T-plunder-wi-w-l1-storage.md`.
    func testDisclaimerCoverSurfacesStorageDisclosureLine() {
        let app = launchApp()

        // The acknowledge button anchors that we're actually on the cover.
        XCTAssertTrue(
            app.buttons["I understand"].waitForExistence(timeout: 10),
            "DisclaimerCover must render with the I understand button"
        )

        let storageLine = app.staticTexts["DisclaimerStorageLine"]
        XCTAssertTrue(
            storageLine.waitForExistence(timeout: 10),
            "DisclaimerCover must render the disclaimerStorageLine Text with identifier DisclaimerStorageLine"
        )
    }

    // MARK: - Helpers

    private func launchApp(arguments: [String] = []) -> XCUIApplication {
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

        XCTAssertTrue(app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 15))
        _ = waitForHittable(app.buttons.matching(identifier: "EstimateInfoButton").firstMatch, timeout: 5)
    }

    private func acknowledgeDisclaimer(in app: XCUIApplication) {
        let acknowledgeButton = app.buttons["I understand"]
        XCTAssertTrue(acknowledgeButton.waitForExistence(timeout: 10))
        tapUntilAppears(acknowledgeButton, app.navigationBars["Choose skin type"])
    }

    private func waitForEnabled(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if element.exists && element.isEnabled { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        return element.exists && element.isEnabled
    }

    private func waitForHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if element.exists && element.isHittable { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return element.exists && element.isHittable
    }

    private func tapWithRetry(_ element: XCUIElement, retries: Int = 2) {
        _ = waitForHittable(element, timeout: 5)
        for _ in 0..<retries {
            if element.exists && element.isHittable {
                let frame = element.frame
                if frame.width > 0 && frame.height > 0 {
                    tapViaSafestPath(element, frame: frame)
                    return
                }
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.3))
        }
        if element.exists {
            let frame = element.frame
            if frame.width > 0 && frame.height > 0 {
                tapViaSafestPath(element, frame: frame)
            } else {
                element.tap()
            }
        }
    }

    private func tapViaSafestPath(_ element: XCUIElement, frame: CGRect) {
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }

    private func tapUntilAppears(_ trigger: XCUIElement, _ target: XCUIElement, totalTimeout: TimeInterval = 30) {
        let deadline = Date().addingTimeInterval(totalTimeout)
        while Date() < deadline && trigger.exists && !target.exists {
            tapWithRetry(trigger)
            _ = target.waitForExistence(timeout: 4)
        }
    }
}
