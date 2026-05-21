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

/// O1 — `photosensitizationBanner` view symbol must be absent from AppViews.swift.
///
/// WI-k (2026-05-21) — promoted from a `withKnownIssue` manual-verification
/// stub to a real source-text guard. The K-1 commit removed the
/// `photosensitizationBanner` SwiftUI computed property from RootView so the
/// banner no longer renders at the top of the main scroll content. The
/// `photosensitizationBannerLabel` *copy constant* in ProductCopy stays —
/// `DisclaimerCover` still uses it — but a reintroduction of the banner
/// view symbol would silently put the L0 surface back on the main screen,
/// undoing K-1.
///
/// This guard reads AppViews.swift source text at test-run time (compile-
/// independent, mirrors P1/R8/S1-S3) and asserts that no `photosensitizationBanner`
/// identifier exists in any context that would re-introduce the view —
/// matched as a Swift identifier rather than a substring so the unrelated
/// `photosensitizationBannerLabel` copy constant (used only inside the L1
/// cover, not RootView) is not falsely flagged.
@Test func test_O1_photosensitizationBannerSymbolAbsentFromAppViews() throws {
    let appViewsURL = appViewsSwiftURL()
    let sourceText = try String(contentsOf: appViewsURL, encoding: .utf8)

    // Match `photosensitizationBanner` only when it is NOT followed by an
    // identifier-continuation character — i.e., a true `photosensitizationBanner`
    // symbol use, distinct from the unrelated `photosensitizationBannerLabel`
    // ProductCopy constant which is allowed to remain.
    let viewSymbol = "photosensitizationBanner"
    var search = sourceText[...]
    var leakedReintroduction = false
    while let range = search.range(of: viewSymbol) {
        let next = range.upperBound
        if next == search.endIndex {
            leakedReintroduction = true
            break
        }
        let nextChar = search[next]
        // Identifier-continuation = letter / digit / underscore. If the next
        // char is one of those, this is `photosensitizationBannerLabel` (or a
        // similar suffix) — allowed. Anything else (`.`, ` `, `(`, `:`, `)`,
        // newline, etc.) is a view-symbol re-introduction — disallowed.
        if !(nextChar.isLetter || nextChar.isNumber || nextChar == "_") {
            leakedReintroduction = true
            break
        }
        search = search[next...]
    }

    #expect(
        !leakedReintroduction,
        "AppViews.swift must NOT define or reference a `photosensitizationBanner` view symbol — K-1 removed it from RootView. The `photosensitizationBannerLabel` copy constant (suffix `Label`) is allowed; a bare `photosensitizationBanner` identifier is not."
    )
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
    let sourceText = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    #expect(
        sourceText.contains("aboutSunSafetyActions"),
        "AppViews.swift must reference ProductCopy.aboutSunSafetyActions (K-11 notForMeAnchor VStack)"
    )
}

/// P2 — `AboutView` struct + `highlightEstimateApplicability` initializer surface.
///
/// WI-k (2026-05-21) — promoted from a `withKnownIssue` cross-target stub
/// to a real source-text guard. `AboutView` is defined in the UVBurnTimer
/// app target and cannot be `@testable import`ed from UVBurnTimerCoreTests
/// (no host-app test bundle exists), so the *next-best* compile-independent
/// guard is to assert the source text in AppViews.swift still defines:
///
///   * a `struct AboutView` declaration, AND
///   * the `highlightEstimateApplicability` initializer parameter, AND
///   * at least one call site that constructs `AboutView(highlightEstimateApplicability: true)`
///     — the L3 reach-back contract surfaced by the toolbar info button
///     (RootView toolbar `EstimateInfoButton` → AboutView push) and the
///     inline see-About link inside `DisclaimerCover`.
///
/// Together these three text-pattern asserts pin the public surface that
/// the WI-50–WI-53 / WI-i XCUI tests rely on, *without* paying the cost
/// of a host-app test bundle. A future contributor who accidentally renames
/// the parameter or removes the call site will fail this test even before
/// XCUI gets a chance to run.
@Test func test_P2_aboutViewSource_definesHighlightEstimateApplicabilityInit() throws {
    let sourceText = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)

    #expect(
        sourceText.contains("struct AboutView"),
        "AppViews.swift must declare `struct AboutView` — public reach-back surface"
    )
    #expect(
        sourceText.contains("highlightEstimateApplicability"),
        "AppViews.swift must keep the `highlightEstimateApplicability` parameter — XCUI L3 reach-back depends on it"
    )
    #expect(
        sourceText.contains("AboutView(highlightEstimateApplicability: true)"),
        "AppViews.swift must construct `AboutView(highlightEstimateApplicability: true)` at least once — the toolbar EstimateInfoButton / DisclaimerCover see-About link contract"
    )
}

// MARK: - Group Q: First-Launch Cover Gating (Source-Text Smoke)

/// Q1 — First-launch sequence is gated by `DisclaimerCover` → `SkinTypeOnboardingView`.
///
/// WI-k (2026-05-21) — re-scoped from the original `LocationRationaleCard +
/// hero status + CTA` manual-verification stub. That earlier shape no longer
/// exists in the source after the L1/L2 disclaimer-cover redesign and the
/// SkinTypeOnboardingView full-screen-cover gate. The *current* first-launch
/// architecture lives in `UVBurnTimerApp.body` and is the new contract to
/// pin:
///
///   1. RootView is wrapped in `.disclaimerPresentation(isPresented:onDismiss:)`
///      whose content renders `DisclaimerCover` — the L1 cover the user
///      must acknowledge before any main-screen surface is reachable.
///   2. On dismiss, `.skinTypePresentation(isPresented:)` renders
///      `SkinTypeOnboardingView` until the user picks a Fitzpatrick type.
///   3. Only after both gates are cleared does RootView actually receive
///      taps — there is no path that surfaces 5 simultaneous location
///      reminders the way the K-8 / K-9-era main scroll did.
///
/// Reads UVBurnTimerApp.swift source text at test-run time (compile-
/// independent, mirrors P1/P2 in this same file) and asserts the three
/// modifier + content-type pairs above are wired. A future contributor
/// who silently removes either cover gate — accidentally exposing
/// RootView without an acknowledged disclaimer or without a chosen skin
/// type — will fail this test before any XCUI run.
@Test func test_Q1_firstLaunchSequenceIsGatedByDisclaimerThenSkinTypeCover() throws {
    let appURL = uvBurnTimerAppSwiftURL()
    let sourceText = try String(contentsOf: appURL, encoding: .utf8)

    #expect(
        sourceText.contains(".disclaimerPresentation("),
        "UVBurnTimerApp.body must apply `.disclaimerPresentation(...)` — the L1 gate that blocks RootView on first launch."
    )
    #expect(
        sourceText.contains("DisclaimerCover {") || sourceText.contains("DisclaimerCover("),
        "UVBurnTimerApp.body must render `DisclaimerCover` inside the `.disclaimerPresentation` content — the actual L1 cover view."
    )
    #expect(
        sourceText.contains(".skinTypePresentation("),
        "UVBurnTimerApp.body must apply `.skinTypePresentation(...)` — the post-L1 gate that blocks RootView until Fitzpatrick is picked."
    )
    #expect(
        sourceText.contains("SkinTypeOnboardingView("),
        "UVBurnTimerApp.body must render `SkinTypeOnboardingView` inside the `.skinTypePresentation` content — the actual onboarding view."
    )
}

// MARK: - Group BB: Suchi persona P0 contract guards (WI-ff)
//
// Loop-10 Suchi fresh gap analysis (parallel review pass, claude-opus-4.7-xhigh)
// identified three load-bearing persona invariants that were unguarded after
// the WI-aa (#37) main-spec reconciliation:
//
//   BB1 — Asha (P4 Accutane): tapping the new Fitzpatrick chip on the main
//         screen must NOT re-fire the L1 disclaimer cover. Suchi
//         skin-type-friction-research §4.1 + §6.4 explicitly decoupled L1
//         re-attestation cadence from Fitzpatrick picker access. A future
//         refactor coupling chip-tap to disclaimer reattestation would
//         re-introduce the friction that Pattern B was ratified to remove
//         (.squad/decisions.md 2026-05-21T07:00Z).
//
//   BB2 — Tomás (P5 trail-runner): the window-elapsed SafetyStatusCard
//         (estimateElapsedWarning + exclamationmark.shield.fill) — explicitly
//         flagged by spec LANE 4 row 5 as "the whole app's existence is
//         justified by this state firing" — must remain wired in
//         HeroTimerCard's body. The copy alone (BurnTimeCalculatorTests:376
//         approvedMainScreenSafetyCopyIsCaptured) is not enough; a refactor
//         could drop the if-isEstimateStale branch and the copy guard would
//         still pass.

/// BB1 — `skinTypeChip` Button body must NOT call any disclaimer-
/// reattestation reset. Asha's L1 cadence is gated only by
/// policyVersion + foreground-with-elapsed-window per Pattern B.
@Test func test_BB1_skinTypeChipActionDoesNotTriggerDisclaimerReattestation() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    let lines = source.components(separatedBy: "\n")
    guard let chipStart = lines.firstIndex(where: { $0.contains("private var skinTypeChip:") }) else {
        Issue.record("skinTypeChip property not found in AppViews.swift — Suchi BB1 cannot verify")
        return
    }
    let chipEnd: Int = lines[(chipStart + 1)...].firstIndex(where: {
        $0.contains("private var ") && !$0.contains("skinTypeChip")
    }) ?? lines.endIndex
    let chipBody = lines[chipStart..<chipEnd].joined(separator: "\n")

    let forbiddenTokens = [
        "requireDisclaimerReattestation",
        "acknowledgedDisclaimer = false",
        "showDisclaimer = true",
        "disclaimerPolicyVersion",
    ]
    for token in forbiddenTokens {
        #expect(
            !chipBody.contains(token),
            "skinTypeChip body must NOT contain '\(token)' — coupling Fitzpatrick chip tap to L1 re-fire would re-introduce the Pattern-A friction that Suchi skin-type-friction-research §4.1/§6.4 + Plunder Pattern-B (2026-05-21T07:00Z) explicitly decoupled. Asha's L1 cadence is policyVersion-only. (WI-ff BB1)"
        )
    }

    let expectedTokens = [
        "showSkinTypeEdit = true",
        "showSkinTypeOnboarding = true",
    ]
    for token in expectedTokens {
        #expect(
            chipBody.contains(token),
            "skinTypeChip body must contain '\(token)' — the chip's only two action paths are sheet-edit (selectedSkinType != nil) and onboarding (selectedSkinType == nil) per the Pattern-B persistence floor. (WI-ff BB1)"
        )
    }
}

/// BB2 — `HeroTimerCard` body must render `SafetyStatusCard` for the
/// `isEstimateStale` branch with Tomás's load-bearing copy + glyph.
/// Spec LANE 4 row 5 explicitly names this as the single state whose
/// firing justifies the app's existence.
@Test func test_BB2_heroTimerCardRendersWindowElapsedSafetyStatusCardWhenEstimateIsStale() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct HeroTimerCard: View") }) else {
        Issue.record("HeroTimerCard struct not found in AppViews.swift — Suchi BB2 cannot verify")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: {
        $0.hasPrefix("struct ") || $0.hasPrefix("private struct ")
    }) ?? lines.endIndex
    let cardBody = lines[cardStart..<cardEnd].joined(separator: "\n")

    #expect(
        cardBody.contains("if isEstimateStale"),
        "HeroTimerCard body must contain `if isEstimateStale` branch — Tomás's window-elapsed safety moment must remain conditionally rendered per spec LANE 4 row 5. (WI-ff BB2)"
    )
    #expect(
        cardBody.contains("SafetyStatusCard("),
        "HeroTimerCard body must call `SafetyStatusCard(...)` constructor — Tomás's safety surface must remain wired. (WI-ff BB2)"
    )
    #expect(
        cardBody.contains(#"title: "Estimate window elapsed""#),
        "HeroTimerCard SafetyStatusCard must keep the title `\"Estimate window elapsed\"` — this is the Plunder-vetted hedge copy for the stale-window safety moment. (WI-ff BB2)"
    )
    #expect(
        cardBody.contains("ProductCopy.estimateElapsedWarning"),
        "HeroTimerCard SafetyStatusCard must use ProductCopy.estimateElapsedWarning as message — the constant is the Plunder-audited safety copy carrier. (WI-ff BB2)"
    )
    #expect(
        cardBody.contains(#"systemImage: "exclamationmark.shield.fill""#),
        "HeroTimerCard SafetyStatusCard must use the `exclamationmark.shield.fill` glyph — Iris launch-readiness checklist row 78 pins this glyph as part of Tomás's recognizable safety surface. (WI-ff BB2)"
    )
}

// MARK: - Shared test helpers

/// Resolve `app/Sources/UVBurnTimer/AppViews.swift` from this test file's
/// `#filePath`. Used by P1, P2, O1, BB1, BB2 to read the live source text
/// without depending on the UVBurnTimer app target being linked into
/// UVBurnTimerCoreTests.
private func appViewsSwiftURL(file: StaticString = #filePath) -> URL {
    URL(fileURLWithPath: "\(file)")
        .deletingLastPathComponent()  // UVBurnTimerCoreTests/
        .deletingLastPathComponent()  // Tests/
        .deletingLastPathComponent()  // app/
        .appendingPathComponent("Sources/UVBurnTimer/AppViews.swift")
}

/// Resolve `app/Sources/UVBurnTimer/UVBurnTimerApp.swift` from this test
/// file's `#filePath`. Used by Q1 to read the live source text of the
/// app entry point.
private func uvBurnTimerAppSwiftURL(file: StaticString = #filePath) -> URL {
    URL(fileURLWithPath: "\(file)")
        .deletingLastPathComponent()  // UVBurnTimerCoreTests/
        .deletingLastPathComponent()  // Tests/
        .deletingLastPathComponent()  // app/
        .appendingPathComponent("Sources/UVBurnTimer/UVBurnTimerApp.swift")
}
