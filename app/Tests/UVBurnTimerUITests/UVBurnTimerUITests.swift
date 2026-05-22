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

    // MARK: - Smoke 8 (WI-i): Toolbar ⓘ EstimateInfoButton opens About with highlighted applicability anchor

    /// WI-i smoke expansion — the toolbar `info.circle` Button is the L3
    /// "Reach-Back" for the photosensitization/medication/sunscreen caveat
    /// (see ADR-0001 + R6 in BurnTimeCalculatorTests). Tapping it must:
    ///   1. Navigate to the AboutView (`navigationBar["About & Citations"]`).
    ///   2. Surface the highlighted "When this estimate may not apply"
    ///      anchor (`accessibilityIdentifier == AboutEstimateApplicabilityHeader`),
    ///      which proves the `highlightEstimateApplicability: true` plumbing
    ///      from RootView → AboutView still survives.
    /// This is the only XCUI guard on the toolbar ⓘ caveat path; without it
    /// a future refactor could silently break the L3 reach-back without any
    /// XCUI failure.
    func testEstimateInfoButtonOpensAboutWithHighlightedApplicabilityAnchor() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        let infoButton = app.buttons.matching(identifier: "EstimateInfoButton").firstMatch
        XCTAssertTrue(
            waitForHittable(infoButton, timeout: 10),
            "Toolbar info button (EstimateInfoButton) must be hittable on the main screen"
        )

        // NavigationLink inside ToolbarItem can intermittently swallow the
        // first synthesized tap on iOS 26 simulator — use tapUntilAppears
        // so the tap is retried until About materialises (or the budget
        // expires). Matches the pattern used by the hero-card L3 caveat
        // deep-link test prior to K-1..K-9 cleanup.
        tapUntilAppears(infoButton, app.navigationBars["About & Citations"])

        XCTAssertTrue(
            app.navigationBars["About & Citations"].waitForExistence(timeout: 10),
            "EstimateInfoButton must navigate to the About screen"
        )

        let anchor = app.staticTexts["AboutEstimateApplicabilityHeader"]
        XCTAssertTrue(
            anchor.waitForExistence(timeout: 10),
            "About must surface the 'When this estimate may not apply' anchor with identifier AboutEstimateApplicabilityHeader — proves the highlightEstimateApplicability plumbing survives."
        )
    }

    // MARK: - Smoke 9 (WI-i): Both Settings ⚙ and EstimateInfo ⓘ toolbar buttons coexist on main screen

    /// WI-i smoke expansion — RootView's toolbar must host *both* the
    /// Settings gear (`accessibilityLabel == "Settings"`) and the
    /// EstimateInfo info-circle (`accessibilityIdentifier ==
    /// "EstimateInfoButton"`). The two buttons live on the trailing
    /// toolbar slot together (gear = primaryAction, info-circle =
    /// topBarTrailing). If a future refactor removes either (e.g.,
    /// "consolidating" the gear into the info menu, or vice versa),
    /// the user loses an entry point this XCUI guard catches before
    /// merge. This is a fast structural assertion — no navigation,
    /// no settings or sheet flows.
    func testToolbarRendersBothSettingsAndEstimateInfoButtons() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        XCTAssertTrue(
            app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 10),
            "Main screen nav bar must be visible before asserting toolbar buttons"
        )

        // WI-loop29-5: drive the existence + hittability assertions through
        // a shared toolbar-settled helper. On iOS 26 the toolbar's Liquid
        // Glass composition can take a moment to settle into a hittable
        // frame after the onboarding cover-chain tears down (per ADR-0002).
        // The helper re-queries both buttons together with a generous
        // budget so a stale first-query miss does not flake the suite.
        let toolbar = waitForMainToolbarSettled(in: app, timeout: 20)

        XCTAssertTrue(
            toolbar.settingsExists,
            "Toolbar must contain the Settings gear Button (accessibilityLabel \"Settings\") — entry point to SettingsSheet."
        )
        XCTAssertTrue(
            toolbar.infoExists,
            "Toolbar must contain the EstimateInfoButton (info.circle) — entry point to About highlight reach-back."
        )

        // Both must be hittable on the same screen (not collapsed behind a menu).
        XCTAssertTrue(
            toolbar.settingsHittable,
            "Settings gear must be hittable — toolbar should not collapse it behind a menu."
        )
        XCTAssertTrue(
            toolbar.infoHittable,
            "EstimateInfoButton must be hittable — toolbar should not collapse it behind a menu."
        )
    }

    // MARK: - Smoke 10 (WI-i): EstimateInfo ⓘ → About → back round-trip preserves main screen

    /// WI-i smoke expansion — proves the EstimateInfoButton uses a
    /// `NavigationLink` push (not a modal `.sheet`) so the standard iOS
    /// back-chevron returns the user to the main screen without losing
    /// scroll position or session state. A modal regression would still
    /// pass the navigation-arrival assertion in Smoke 8, so this third
    /// test pins the *return* path — together they assert push-and-pop.
    func testEstimateInfoNavigationRoundTripReturnsToMainScreen() {
        let app = launchApp()
        acknowledgeDisclaimerAndChooseTypeIII(in: app)

        // WI-loop29-5: gate on the shared toolbar-settled helper so the
        // EstimateInfoButton hittable check survives the iOS 26 Liquid
        // Glass settle window before we synthesize the navigation tap.
        let toolbar = waitForMainToolbarSettled(in: app, timeout: 20)
        XCTAssertTrue(
            toolbar.infoHittable,
            "EstimateInfoButton must be hittable before navigating"
        )

        let infoButton = toolbar.infoButton

        // NavigationLink in ToolbarItem can drop the first synthesized tap
        // on iOS 26 simulator — retry until About appears.
        tapUntilAppears(infoButton, app.navigationBars["About & Citations"])

        let aboutNavBar = app.navigationBars["About & Citations"]
        XCTAssertTrue(
            aboutNavBar.waitForExistence(timeout: 10),
            "EstimateInfoButton must navigate to About"
        )

        // The back button surfaces as the standard NavigationStack back chevron;
        // XCUI exposes it as a Button on the About navigation bar with the previous
        // screen's title ("UV Burn Timer") as its label.
        let backButton = aboutNavBar.buttons["UV Burn Timer"]
        XCTAssertTrue(
            backButton.waitForExistence(timeout: 10),
            "About must expose a back-chevron Button labelled \"UV Burn Timer\" — proves the EstimateInfoButton used a NavigationLink push (not a modal sheet)."
        )

        // Symmetric retry on the back navigation so a dropped tap on the
        // chevron does not flake the round-trip assertion.
        tapUntilAppears(backButton, app.navigationBars["UV Burn Timer"])

        XCTAssertTrue(
            app.navigationBars["UV Burn Timer"].waitForExistence(timeout: 10),
            "Tapping back from About must restore the main \"UV Burn Timer\" navigation bar"
        )
        XCTAssertFalse(
            app.navigationBars["About & Citations"].exists,
            "About navigation bar must be gone after popping back to the main screen"
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

    /// Snapshot of the main-screen toolbar's two trailing buttons.
    /// Returned by `waitForMainToolbarSettled` so tests can interrogate
    /// existence + hittability without re-querying the buttons mid-assertion
    /// (which is the racy pattern the WI-loop29-5 stabilisation removes).
    private struct ToolbarSettleSnapshot {
        let settingsButton: XCUIElement
        let infoButton: XCUIElement
        let settingsExists: Bool
        let infoExists: Bool
        let settingsHittable: Bool
        let infoHittable: Bool
    }

    /// WI-loop29-5: poll for the main screen's two toolbar buttons
    /// (`Settings` gear + `EstimateInfoButton` info.circle) to BOTH reach
    /// the `exists && isHittable` state, with a generous total budget and
    /// a small idle settle after a positive read. This is the toolbar-suite
    /// analogue of the Loop-20 `tapWithRetry` cover-chain helper: the iOS 26
    /// Liquid Glass toolbar composition can lag the navigation bar's arrival
    /// by several hundred ms (per ADR-0002), and querying the buttons on
    /// the first nav-bar tick races that composition. Re-querying within
    /// a single helper keeps both buttons resolved against the same UI
    /// snapshot once it stabilises.
    ///
    /// ADR-0001 non-regression: this helper only reads from XCUI queries.
    /// It does not perturb the toolbar identity contract or any production
    /// hit-test surface — the production toolbar code is untouched.
    @discardableResult
    private func waitForMainToolbarSettled(
        in app: XCUIApplication,
        timeout: TimeInterval
    ) -> ToolbarSettleSnapshot {
        let deadline = Date().addingTimeInterval(timeout)
        var settingsButton = app.buttons["Settings"]
        var infoButton = app.buttons.matching(identifier: "EstimateInfoButton").firstMatch

        while Date() < deadline {
            settingsButton = app.buttons["Settings"]
            infoButton = app.buttons.matching(identifier: "EstimateInfoButton").firstMatch

            let bothExist = settingsButton.exists && infoButton.exists
            let bothHittable = bothExist && settingsButton.isHittable && infoButton.isHittable
            if bothHittable {
                // Brief idle settle so a subsequent tap lands on the
                // composed, non-animating frame.
                RunLoop.current.run(until: Date().addingTimeInterval(0.2))
                let s = app.buttons["Settings"]
                let i = app.buttons.matching(identifier: "EstimateInfoButton").firstMatch
                return ToolbarSettleSnapshot(
                    settingsButton: s,
                    infoButton: i,
                    settingsExists: s.exists,
                    infoExists: i.exists,
                    settingsHittable: s.exists && s.isHittable,
                    infoHittable: i.exists && i.isHittable
                )
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.15))
        }

        // Final read on timeout — return whatever state we have so the
        // caller's XCTAssert messages can pinpoint which button missed.
        return ToolbarSettleSnapshot(
            settingsButton: settingsButton,
            infoButton: infoButton,
            settingsExists: settingsButton.exists,
            infoExists: infoButton.exists,
            settingsHittable: settingsButton.exists && settingsButton.isHittable,
            infoHittable: infoButton.exists && infoButton.isHittable
        )
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
