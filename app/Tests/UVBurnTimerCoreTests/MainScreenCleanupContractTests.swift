// MainScreenCleanupContractTests.swift — Main Screen Cleanup contract tests
// Groups N (ProductCopy sun safety actions), O (photosensitization banner removal),
// P (AboutView sun safety rendering), Q (location reminder reduction)
//
// Constants under test (ProductCopy.swift):
//   aboutSunSafetyActions  — K-10 (Kwame)
//   disclaimerLinkLabel    — C1 persistent footer anchor
//
// View source contract (AppViews.swift, K-11):
//   AboutView.notForMeAnchor VStack must reference aboutSunSafetyActions
//
// Reference: CURRENT_DATETIME = 2026-05-21T04:40:00Z
// Regulatory floor: Plunder C1–C4 (plunder-disclaimer-relocation-floor.md §3)

import Foundation
import Testing
@testable import UVBurnTimerCore

// MARK: - Group N: ProductCopy Sun Safety Actions Contract

/// N1 — `aboutSunSafetyActions` exists and is non-empty.
///
/// Guards the K-10 constant presence. A missing or empty constant means neither
/// Plunder C2(i) nor C2(ii) clause is available for placement in AboutView.
@Test func test_N1_aboutSunSafetyActions_isNonEmpty() {
    #expect(
        !ProductCopy.aboutSunSafetyActions.isEmpty,
        "aboutSunSafetyActions must be non-empty (Plunder C2 carrier; K-10)"
    )
}

/// N2 — `aboutSunSafetyActions` contains the biological-feedback safety clause.
///
/// Asserts the constant contains "cover up" OR "skin reddens" (case-insensitive).
/// Guards Plunder C2(i): biological-feedback override action that tells the user
/// to cover up when their skin signals overexposure.
@Test func test_N2_aboutSunSafetyActions_containsBiologicalFeedbackClause() {
    let copy = ProductCopy.aboutSunSafetyActions.lowercased()
    let hasCoverUp = copy.contains("cover up")
    let hasSkinReddens = copy.contains("skin reddens")
    #expect(
        hasCoverUp || hasSkinReddens,
        "aboutSunSafetyActions must contain 'cover up' or 'skin reddens' (Plunder C2(i))"
    )
}

/// N3 — `aboutSunSafetyActions` contains the reapplication-cadence clause.
///
/// Asserts the constant contains both "reapply" AND "2 hours" (case-insensitive).
/// Guards Plunder C2(ii): reapplication-cadence reminder that sunscreen must be
/// reapplied at least every two hours regardless of the timer output.
@Test func test_N3_aboutSunSafetyActions_containsReapplicationCadenceClause() {
    let copy = ProductCopy.aboutSunSafetyActions.lowercased()
    #expect(
        copy.contains("reapply"),
        "aboutSunSafetyActions must contain 'reapply' (Plunder C2(ii))"
    )
    #expect(
        copy.contains("2 hours"),
        "aboutSunSafetyActions must contain '2 hours' (Plunder C2(ii))"
    )
}

/// N4 — Plunder C1 substance is carried by `disclaimerLinkLabel`.
///
/// `aboutSunSafetyActions` carries Plunder C2 (clauses A+B). Plunder C1
/// ("Informational only / Not medical advice" SaMD anchor) is intentionally
/// carried by `disclaimerLinkLabel` in `PersistentFooter` — not in
/// `aboutSunSafetyActions`. This test guards the C1 floor at the ProductCopy
/// constant level: `disclaimerLinkLabel` must contain the C1 phrase so the
/// persistent footer never silently loses its regulatory load.
@Test func test_N4_disclaimerLinkLabel_carriesPlunderC1Anchor() {
    let copy = ProductCopy.disclaimerLinkLabel.lowercased()
    let hasInformationalOnly = copy.contains("informational only")
    let hasNotMedicalAdvice = copy.contains("not medical advice")
    #expect(
        hasInformationalOnly || hasNotMedicalAdvice,
        "disclaimerLinkLabel must carry C1 anchor — PersistentFooter regulatory load must not be silently removed"
    )
}

// MARK: - Group O: Photosensitization Banner Removal (Symbol-Level)

/// O1 — Manual verification surface: photosensitization banner removal.
///
/// The `photosensitizationBannerLabel` constant may still exist in ProductCopy
/// (used in DisclaimerCover) but the banner VIEW (K-1: photosensitizationBanner
/// computed property in AppViews.swift) should no longer render at the top of
/// RootView's main scroll content after Kwame's K-1 commit.
///
/// This cannot be asserted at the ProductCopy level. Flagged as a known issue
/// so it appears in test results as a visible reminder for manual QA.
@Test func test_O1_photosensitizationBannerRemovedFromRootView_manualVerification() {
    withKnownIssue("Manual: verify in simulator that no banner renders at top of RootView main scroll. K-1 removes photosensitizationBanner computed property. Not automatable without SwiftUI view introspection.") {
        #expect(Bool(false), "Manual check required")
    }
}

// MARK: - Group P: AboutView Sun Safety Actions Rendering

/// P1 — `AboutView` source references `aboutSunSafetyActions` (K-11 smoke guard).
///
/// Reads AppViews.swift source text at test-run time and asserts that the constant
/// `aboutSunSafetyActions` is referenced. This is a compile-independent guard:
/// even if the app builds, we want to know if Kwame's K-11 wiring was dropped.
///
/// Path is derived from the test file's `#filePath` macro so it survives directory
/// moves that keep the app/ structure intact.
@Test func test_P1_aboutViewSource_referencesAboutSunSafetyActions() throws {
    let testFileURL = URL(fileURLWithPath: #filePath)
    // Traverse: UVBurnTimerCoreTests/ -> Tests/ -> app/ -> app/Sources/UVBurnTimer/AppViews.swift
    let appViewsURL = testFileURL
        .deletingLastPathComponent()  // UVBurnTimerCoreTests/
        .deletingLastPathComponent()  // Tests/
        .deletingLastPathComponent()  // app/
        .appendingPathComponent("Sources/UVBurnTimer/AppViews.swift")

    let sourceText = try String(contentsOf: appViewsURL, encoding: .utf8)
    #expect(
        sourceText.contains("aboutSunSafetyActions"),
        "AppViews.swift must reference ProductCopy.aboutSunSafetyActions (K-11 notForMeAnchor VStack)"
    )
}

/// P2 — `AboutView` instantiation smoke test.
///
/// `AboutView` is defined in the `UVBurnTimer` app target, which is not linked
/// into `UVBurnTimerCoreTests`. SwiftUI view init cannot be tested here without
/// a host app test bundle or ViewInspector. Flagged as a known issue so the gap
/// is visible in CI output.
@Test func test_P2_aboutView_initWithHighlightDoesNotCrash() {
    withKnownIssue("AboutView is in UVBurnTimer app target, not UVBurnTimerCore. UVBurnTimerCoreTests cannot import UVBurnTimer. Add a host-app test bundle or ViewInspector to run this smoke test.") {
        // Placeholder: AboutView(highlightEstimateApplicability: true)
        // would be instantiated here if the target were available.
        #expect(Bool(false), "Test target lacks access to UVBurnTimer module")
    }
}

// MARK: - Group Q: Location Reminder Reduction (Smoke Only)

/// Q1 — Manual verification surface: first-launch location reminder consolidation.
///
/// After K-8 and K-9, first-launch should show only:
///   1. LocationRationaleCard (kept)
///   2. Hero status nudge (kept, non-redundant)
///   3. Primary CTA button (kept)
/// — not the prior 5 simultaneous location messages. Not automatable at the
/// ProductCopy or view-model level; requires simulator walkthrough.
@Test func test_Q1_firstLaunchLocationReminderConsolidation_manualVerification() {
    withKnownIssue("Manual: verify in simulator that first-launch shows only LocationRationaleCard + hero status + CTA, not 5 prior surfaces. K-8 removes 'Use your location' sentence; K-9 simplifies transient statusMessage. Requires UI test host.") {
        #expect(Bool(false), "Manual check required")
    }
}
