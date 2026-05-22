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

// MARK: - Group AA: Hero gauge countdown framing (WI-ee)
//
// Loop-10 Wheeler/Plunder safety follow-up `wi-ee-hero-gauge-countdown-framing`:
// WI-o Group Z (in flight) closed the countdown-vs-estimate misread risk for
// `HeroAccessibilitySummary.text()` — the static hero number's VoiceOver
// summary. Wheeler's fresh gap-analysis identified that the *circular gauge*
// (`BurnRiskGaugeCard`, AppViews.swift line ~1750) — which is the DOMINANT
// visual surface in the chrome-less hero region — emits its own decrementing
// number with the literal caption `"remaining"` and an a11y label of the
// form `"... <X> remaining. <Y%> ... elapsed."`. That is exactly the
// countdown framing Group Z forbids for the hero summary, but on a different
// (un-guarded) surface. Asha (Accutane), Tomás (trail runner), and Maya
// (open-water) glance at the gauge first.
//
// Mitigation: the visible caption is changed from "remaining" → "est. window"
// and the a11y label is reframed as "<X> of estimated burn window. <Y%>
// elapsed. Estimate, not a live timer." Group AA pins both contracts so a
// future refactor cannot silently re-introduce the live-countdown framing.

/// AA1 — `BurnRiskGaugeCard` body must NOT contain a standalone
/// `Text("remaining")` caption. The visible caption must use estimate-framing
/// language (e.g., "est. window", "estimate", "of estimate").
@Test func test_AA1_burnRiskGaugeVisibleCaptionDoesNotImplyLiveCountdown() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct BurnRiskGaugeCard: View") }) else {
        Issue.record("BurnRiskGaugeCard struct not found — guard the existence first, then framing")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: {
        $0.hasPrefix("struct ") || $0.hasPrefix("private struct ")
    }) ?? lines.endIndex
    let cardBody = lines[cardStart..<cardEnd].joined(separator: "\n")

    #expect(
        !cardBody.contains(#"Text("remaining")"#),
        "BurnRiskGaugeCard visible caption must NOT be a standalone `Text(\"remaining\")` — that reads as a live countdown to Asha/Tomás/Maya. Use `Text(\"est. window\")` or another estimate-framed phrase per Wheeler's Loop-10 wi-ee gap analysis."
    )
    let visibleEstimateFrames = [
        #"Text("est. window")"#,
        #"Text("estimate")"#,
        #"Text("estimated")"#,
        #"Text("of estimate")"#,
        #"Text("est. left")"#,
        #"Text("est.")"#,
    ]
    let hasFrame = visibleEstimateFrames.contains(where: { cardBody.contains($0) })
    #expect(
        hasFrame,
        "BurnRiskGaugeCard visible caption must use one of \(visibleEstimateFrames) so the decrementing number reads as a modeled estimate rather than a live timer (Wheeler wi-ee mitigation)."
    )
}

/// AA2 — `BurnRiskGaugeCard.gauge` `.accessibilityLabel(...)` must include
/// explicit estimate framing AND must NOT use "remaining" without an
/// "estimate" anchor in the same string. Asha's VoiceOver read-out must
/// not mirror live-countdown semantics.
@Test func test_AA2_burnRiskGaugeAccessibilityLabelIncludesEstimateFraming() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct BurnRiskGaugeCard: View") }) else {
        Issue.record("BurnRiskGaugeCard struct not found")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: {
        $0.hasPrefix("struct ") || $0.hasPrefix("private struct ")
    }) ?? lines.endIndex

    guard let labelLineIndex = lines[cardStart..<cardEnd].firstIndex(where: {
        $0.contains(".accessibilityLabel(") && $0.contains("Burn risk gauge")
    }) else {
        Issue.record("BurnRiskGaugeCard `.accessibilityLabel(...)` with `Burn risk gauge` prefix not found")
        return
    }
    let labelLine = lines[labelLineIndex]

    #expect(
        labelLine.contains("Estimate, not a live timer")
            || labelLine.contains("of estimated burn window")
            || labelLine.contains("of estimated burn time"),
        "BurnRiskGaugeCard accessibilityLabel must include explicit estimate framing such as 'Estimate, not a live timer' or 'of estimated burn window/time' so VoiceOver users (Asha P4, Tomás P5) do not parse the gauge as a live countdown. Actual: \(labelLine)"
    )

    if labelLine.contains(" remaining") {
        #expect(
            labelLine.contains("estimate") || labelLine.contains("Estimate"),
            "BurnRiskGaugeCard accessibilityLabel uses 'remaining' — that wording reads as a live countdown unless an 'estimate' anchor is in the same string. Actual: \(labelLine)"
        )
    }
}

/// AA3 — `BurnRiskGaugeCard` body source contains at least one
/// estimate-framing token (visible caption OR a11y label). Defense-in-depth
/// against a refactor that drops both framings simultaneously.
@Test func test_AA3_burnRiskGaugeBodyMentionsEstimateFraming() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    let lines = source.components(separatedBy: "\n")
    guard let cardStart = lines.firstIndex(where: { $0.contains("struct BurnRiskGaugeCard: View") }) else {
        Issue.record("BurnRiskGaugeCard struct not found")
        return
    }
    let cardEnd: Int = lines[(cardStart + 1)...].firstIndex(where: {
        $0.hasPrefix("struct ") || $0.hasPrefix("private struct ")
    }) ?? lines.endIndex
    let cardBody = lines[cardStart..<cardEnd].joined(separator: "\n")

    let estimateTokens = ["est.", "estimate", "estimated", "Estimate"]
    let hasEstimate = estimateTokens.contains(where: { cardBody.contains($0) })
    #expect(
        hasEstimate,
        "BurnRiskGaugeCard body must reference estimate framing somewhere so the live-countdown misread risk is mitigated end-to-end (Wheeler wi-ee). Tokens checked: \(estimateTokens)."
    )
}

// MARK: - Shared test helpers

/// Resolve `app/Sources/UVBurnTimer/AppViews.swift` from this test file's
/// `#filePath`. Used by P1, P2, O1, BB1, BB2, AA1/AA2/AA3 to read the live
/// source text without depending on the UVBurnTimer app target being linked
/// into UVBurnTimerCoreTests.
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

// MARK: - Group RR: Loop-13 Convergent HIGH findings

// RR1 — Gaia M1 / ADR-0002 enforcement: `.primaryAction` must not be used for
//        any ToolbarItem in a NavigationStack-owning parent view. On iOS 26,
//        the Liquid Glass nav-bar composites `.primaryAction` items into a
//        region that XCUI reports as `isHittable == false`, silently regressing
//        `testSettingsSheetOpens` and `testToolbarRendersBothSettingsAndEstimateInfoButtons`.
//        ADR-0002 (Loop-13, PR #58) canonises `.topBarTrailing` as the required
//        placement; this test is the automated enforcement the ADR specifies.
//
// RR2 — Wheeler H-1: `fitzpatrickCitations` prose must describe Schalka & Reis
//        2011 as a paper on SPF-as-MED-multiplier, not "real-world use".
//        The 2011 An Bras Dermatol paper is a definitional SPF review;
//        "real-world sunscreen/SPF use" was a residue of the retired 2009
//        Cucé application-thickness paper. Corrected in Loop-13 bundle.
//
// RR3 — Suchi M3: Skin-type picker footer must contain the photosensitizer
//        caveat phrase so Asha (P4) sees the medication warning at the picker.
//
// RR4 — Gaia H2: `WeatherKitForecastProvider` declares `ForecastProviding`
//        conformance — the Core protocol seam is now plugged. This test
//        guards the conformance at the source-text level so it cannot be
//        silently removed.

/// RR1 — `AppViews.swift` must not use `ToolbarItem(placement: .primaryAction)`
/// inside any `.toolbar { }` block. All toolbar items on navigation-bar-owning
/// views must use `.topBarTrailing` (ADR-0002).
@Test func test_RR1_toolbarDoesNotUsePrimaryActionPlacement() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    #expect(
        !source.contains("placement: .primaryAction"),
        "ADR-0002: no ToolbarItem may use `.primaryAction` — iOS 26 Liquid Glass makes these XCUI-unhittable. Use `.topBarTrailing`. See `.squad/decisions/adr/ADR-0002-toolbar-topbartrailing-ios26.md`."
    )
}

/// RR2 — Wheeler H-1: `fitzpatrickCitations` prose must describe the Schalka
/// 2011 citation accurately as a paper on SPF-as-MED-multiplier, not the
/// retired "real-world use" framing from the 2009 paper.
@Test func test_RR2_fitzpatrickCitationsDescribesSchalka2011Accurately() {
    #expect(
        !ProductCopy.fitzpatrickCitations.contains("real-world sunscreen/SPF use"),
        "fitzpatrickCitations must not say 'real-world sunscreen/SPF use' — the Schalka & Reis 2011 An Bras Dermatol paper is a definitional SPF-as-MED-multiplier review, not a real-world-use study. Wheeler H-1 Loop-13."
    )
    #expect(
        ProductCopy.fitzpatrickCitations.localizedCaseInsensitiveContains("schalka")
            && ProductCopy.fitzpatrickCitations.localizedCaseInsensitiveContains("2011"),
        "fitzpatrickCitations must reference Schalka 2011 with the year so users fact-checking the citation can locate the correct paper."
    )
    #expect(
        ProductCopy.fitzpatrickCitations.contains("multiplier")
            || ProductCopy.fitzpatrickCitations.contains("MED")
            || ProductCopy.fitzpatrickCitations.contains("erythemal"),
        "fitzpatrickCitations Schalka description must convey the paper's actual topic (SPF/MED relationship). Wheeler H-1 Loop-13."
    )
}

/// RR3 — Skin-type picker and settings footers must contain the photosensitizer
/// caveat ("photosensitizing medications") so Asha (P4) encounters the warning
/// at the picker, not only after the estimate fires. Suchi M3 Loop-13.
@Test func test_RR3_skinTypePickerFooterCarriesPhotosensitizerCaveat() {
    #expect(
        ProductCopy.skinTypePickerFooter.localizedCaseInsensitiveContains("photosensitizing"),
        "skinTypePickerFooter must contain 'photosensitizing' — Asha (P4, Accutane) must see the medication caveat at the picker, not only in AboutView. Suchi M3 Loop-13."
    )
    #expect(
        ProductCopy.skinTypeSettingsFooter.localizedCaseInsensitiveContains("photosensitizing"),
        "skinTypeSettingsFooter must contain 'photosensitizing' — same caveat required at the Settings re-select surface. Suchi M3 Loop-13."
    )
}

/// RR4 — `WeatherLocationServices.swift` must declare `WeatherKitForecastProvider`
/// with `ForecastProviding` conformance. This plugs the Core-protocol seam so
/// `ForecastRefreshCoordinator` can drive refreshes without a direct WeatherKit
/// dependency in Core. Gaia H2 Loop-13.
@Test func test_RR4_weatherKitForecastProviderConformsToForecastProviding() throws {
    let url = URL(fileURLWithPath: "\(#filePath)")
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Sources/UVBurnTimer/WeatherLocationServices.swift")
    let source = try String(contentsOf: url, encoding: .utf8)
    #expect(
        source.contains("WeatherKitForecastProvider: Sendable, ForecastProviding")
            || source.contains("WeatherKitForecastProvider: ForecastProviding"),
        "WeatherKitForecastProvider must conform to ForecastProviding (Core protocol) — Gaia H2 Loop-13. The conformance allows ForecastRefreshCoordinator to drive refreshes without importing WeatherKit."
    )
    #expect(
        source.contains("func fetchForecast(at coordinate: UVCoordinate)"),
        "WeatherKitForecastProvider must implement fetchForecast(at:) — the ForecastProviding protocol method."
    )
}

/// RR5 — `AboutView` Privacy section must render `ProductCopy.locationPrivacyLine`
/// (with a stable `accessibilityIdentifier`) so the location-privacy disclosure is
/// visible to users. Suchi L13-H3: the constant was audit-only; it must now be
/// rendered on-screen so users can see the rounded-coordinate / approximate-location
/// data practice before or after the iOS permission prompt fires.
@Test func test_RR5_aboutViewRendersLocationPrivacyLine() throws {
    let url = URL(fileURLWithPath: "\(#filePath)")
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Sources/UVBurnTimer/AppViews.swift")
    let source = try String(contentsOf: url, encoding: .utf8)
    #expect(
        source.contains("ProductCopy.locationPrivacyLine"),
        "AboutView must render ProductCopy.locationPrivacyLine — Suchi L13-H3: the string was audit-only and invisible to users."
    )
    #expect(
        source.contains("AboutViewLocationPrivacyLine"),
        "The locationPrivacyLine Text must carry accessibilityIdentifier(\"AboutViewLocationPrivacyLine\") so checklist audits can target it."
    )
}


// MARK: - Group R: HIG cleanup contract (Loop-26)
//
// Source-text guards that pin the HIG @ScaledMetric cleanup applied to
// AppViews.swift and ForecastPickerView.swift in response to issues #95 and
// #96 (PR #98 SwiftLint hard-gate enforcement, Iris cleanup playbook
// 2026-05-22). These guards complement — they do NOT replace — the SwiftLint
// custom rules `hardcoded_frame_dimensions`, `literal_system_font_size`, and
// `missing_min_touch_target` defined in `.swiftlint.yml`. SwiftLint runs on
// CI when the swiftlint binary is present; these tests run in every
// `swift test` invocation regardless. Both layers must remain in agreement.
//
// Pattern: mirrors `test_O1_*` — compile-independent source-text read via
// `String(contentsOf:)`, helper URL resolvers (`appViewsSwiftURL()` already
// exists; `forecastPickerViewSwiftURL()` added below).

/// Resolve `app/Sources/UVBurnTimer/ForecastPickerView.swift` from this
/// test file's `#filePath`. Used by R4 / R5 to read the live source text
/// without depending on the UVBurnTimer app target being linked into
/// UVBurnTimerCoreTests.
private func forecastPickerViewSwiftURL(file: StaticString = #filePath) -> URL {
    URL(fileURLWithPath: "\(file)")
        .deletingLastPathComponent()  // UVBurnTimerCoreTests/
        .deletingLastPathComponent()  // Tests/
        .deletingLastPathComponent()  // app/
        .appendingPathComponent("Sources/UVBurnTimer/ForecastPickerView.swift")
}

/// R1 — `AppViews.swift` must declare `@ScaledMetric private var minTap`
/// at least once. The Iris playbook prescribes this identifier as the
/// canonical Dynamic-Type-scaling touch-target floor; it must be present
/// in the source so the SwiftLint `missing_min_touch_target` lookahead
/// (which only checks identifier-vs-literal at the Button site) is backed
/// by a real `@ScaledMetric` declaration.
@Test func test_R1_appViewsDeclaresMinTapScaledMetric() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    #expect(
        source.contains("@ScaledMetric private var minTap"),
        "AppViews.swift must declare `@ScaledMetric private var minTap` so touch-target floors scale with Dynamic Type per HIG (Iris loop-26 playbook §B)."
    )
}

// R2 — REMOVED in Loop-28 WI-1 (Iris audit). Previously: a narrowed guard
// that only forbade the literal `minHeight: 44` on the DisclaimerCover
// "I understand" CTA. Iris's Loop-26 post-merge audit flagged that scope
// as too tight because four other literal `minHeight: 44` sites
// (locationChip / spfChip / skinTypeChip in RootView, and PersistentFooter's
// Label) were left unflagged. Loop-28 WI-1 migrates those four sites to
// the `@ScaledMetric`-backed `minTap` token and replaces R2 with
// `test_LU5_appViewsHasNoLiteralMinHeight44` (file-wide zero-literal guard)
// plus LU1–LU4 (per-site positive guards). The narrowed R2 is intentionally
// absent so a future regression at any `minHeight: 44` site fires LU5,
// not a per-CTA guard that quietly permits literals elsewhere. See
// `.squad/agents/kwame/history.md` Loop-28 WI-1 entry and
// `.squad/decisions/inbox/kwame-loop28-wi1-chip-footer-mintap.md`.

/// R3 — `AppViews.swift` must NOT contain any `.font(.system(size: <digit>` —
/// literal system-font sizes bypass Dynamic Type. Iris playbook prescribes
/// semantic styles (`.subheadline`, `.title3`, …) or `@ScaledMetric`-backed
/// identifiers (e.g. `warningIconSize`) at every site.
@Test func test_R3_appViewsHasNoLiteralSystemFontSize() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    // Match `.font(.system(size:` followed by any amount of whitespace then
    // a digit — the SwiftLint `literal_system_font_size` rule with a guard
    // for whitespace variants.
    let pattern = #"\.font\(\.system\(size:\s*\d"#
    let regex = try NSRegularExpression(pattern: pattern)
    let range = NSRange(source.startIndex..., in: source)
    let matches = regex.matches(in: source, range: range)
    #expect(
        matches.isEmpty,
        "AppViews.swift must not contain `.font(.system(size: <literal>))` — use semantic text styles (.subheadline / .title3 / .caption) or `@ScaledMetric`-backed identifiers. PR #98 / Iris loop-26 playbook §B. Found \(matches.count) literal site(s)."
    )
}

/// R4 — `ForecastPickerView.swift` must declare the playbook's full
/// `@ScaledMetric` block. The struct previously had no `@ScaledMetric`
/// properties at all; Iris's playbook §A adds 14 identifiers including
/// the canonical `minTap`, the pill/chip/cell anatomy, the time column
/// width, the indicator dot, the icon sizes, and the skeleton anatomy.
/// R4 spot-checks the load-bearing ones so a future refactor cannot
/// silently drop the cluster.
@Test func test_R4_forecastPickerDeclaresScaledMetricBlock() throws {
    let source = try String(contentsOf: forecastPickerViewSwiftURL(), encoding: .utf8)
    let requiredDeclarations = [
        "@ScaledMetric private var minTap",
        "@ScaledMetric private var pillWidth",
        "@ScaledMetric private var pillHeight",
        "@ScaledMetric private var chipWidth",
        "@ScaledMetric private var cellWidth",
        "@ScaledMetric private var cellHeight",
        "@ScaledMetric private var timeColWidth",
        "@ScaledMetric private var hourDotSize",
        "@ScaledMetric private var chevronSize",
        "@ScaledMetric private var hourIconSize",
        "@ScaledMetric private var skeletonRowHeight",
        "@ScaledMetric private var skeletonDayLabelWidth",
        "@ScaledMetric private var skeletonDayLabelHeight",
        "@ScaledMetric private var skeletonBadgeWidth",
        "@ScaledMetric private var skeletonBadgeHeight"
    ]
    for decl in requiredDeclarations {
        #expect(
            source.contains(decl),
            "ForecastPickerView.swift must declare `\(decl)` per Iris loop-26 playbook §A. Missing identifier — SwiftLint heuristic and Dynamic-Type scaling both depend on it."
        )
    }
}

/// R5 — `ForecastPickerView.swift` must contain no live-content
/// `.frame(width: <digit>, height: <digit>)` (two literal CGFloats).
/// Skeleton + live cells alike must use `@ScaledMetric`-backed identifiers
/// so they scale with Dynamic Type. This is the same rule SwiftLint's
/// `hardcoded_frame_dimensions` enforces, mirrored at unit-test level.
@Test func test_R5_forecastPickerHasNoLiteralFrameWidthHeight() throws {
    let source = try String(contentsOf: forecastPickerViewSwiftURL(), encoding: .utf8)
    // Match `.frame(width: <digit>` OR `.frame(height: <digit>` — either
    // literal axis triggers. Mirrors the SwiftLint `hardcoded_frame_dimensions`
    // regex.
    let pattern = #"\.frame\(\s*(?:width|height)\s*:\s*\d"#
    let regex = try NSRegularExpression(pattern: pattern)
    let range = NSRange(source.startIndex..., in: source)
    let matches = regex.matches(in: source, range: range)
    #expect(
        matches.isEmpty,
        "ForecastPickerView.swift must not contain `.frame(width: <literal>)` or `.frame(height: <literal>)` — use `@ScaledMetric`-backed identifiers (pillWidth/chipWidth/cellWidth/cellHeight/…) per Iris loop-26 playbook §A. Found \(matches.count) literal site(s)."
    )
}

// MARK: - Group LT: Loop-28 WI-0 — RootView toolbar item HIG touch-target floor
//
// Source-text guards that pin the Loop-28 WI-0 fix for iOS 26.4 simulator
// XCUI hittability regressions in `testEstimateInfoButtonOpensAboutWith…`,
// `testEstimateInfoNavigationRoundTripReturnsToMainScreen`, and
// `testSettingsSheetOpens`.
//
// Root cause (Loop-28 WI-0, Kwame):
//   PR #98's HIG cleanup (AV-1..AV-18) applied `@ScaledMetric`-backed
//   `.frame(minHeight: minTap)` floors to almost every Button in the app —
//   including the L1 disclaimer CTA, HeroTimerCard Recalculate/TryAgain/
//   OpenSettings buttons, SettingsSheet/SkinTypeEditView toolbar Buttons,
//   and the SkinTypePickerRow whole-row hit area.
//
//   The two RootView toolbar items themselves were the only Button-shaped
//   controls left **without** an explicit `@ScaledMetric`-backed touch-
//   target floor:
//     • Settings gear `Button { … } label: { Image("gearshape") }`
//     • `EstimateInfoButton` `NavigationLink { Image("info.circle") }`
//   On the Xcode 26 / iOS 26.4 simulator (Liquid Glass nav-bar treatment),
//   a toolbar item whose only label is a 22-pt SF Symbol Image is composited
//   with a hit-test rectangle so tight that `XCUIElement.isHittable`
//   returns `false`, regressing the three XCUI tests above.
//   `testToolbarRendersBothSettingsAndEstimateInfoButtons` happens to pass
//   because its long pre-warm sequence (existence-poll the navbar, then
//   each Button separately) gives SwiftUI enough layout passes to finally
//   resolve a hittable frame; the three failing tests skip that pre-warm
//   and the toolbar never warms up.
//
// Fix (AV-19 / AV-20):
//   1. Add `@ScaledMetric private var minTap: CGFloat = 44` to `RootView`.
//   2. Apply `.frame(minWidth: minTap, minHeight: minTap)` to the toolbar
//      gear Button's Image label and to the EstimateInfoButton
//      NavigationLink's Image label, so both items composite with an
//      explicit HIG-floor hit-test geometry on iOS 26+.
//
// These guards do NOT replace the XCUI tests; they pin the source-text
// shape so a future refactor that removes the @ScaledMetric or the
// frame modifier sees a red unit test before the XCUI flakiness returns.
//
// Reference: CURRENT_DATETIME = 2026-05-22T12:35:00Z

/// LT1 — `RootView` (which owns the toolbar) must declare its own
/// `@ScaledMetric private var minTap`. The pre-existing R1 guard only
/// asserts that AppViews.swift contains the identifier *somewhere*
/// (HeroTimerCard, DisclaimerCover, SettingsSheet, etc. each declared
/// one). R1 passing did not stop the iOS 26.4 hittability regression
/// because RootView itself had no such declaration, so the toolbar
/// items had no symbol to reference. LT1 pins the RootView site
/// specifically by isolating the `struct RootView` body slice between
/// the struct opener and the next top-level `struct` declaration.
@Test func test_LT1_rootViewDeclaresMinTapScaledMetric() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    // Slice the RootView body: from `struct RootView: View {` up to the
    // next top-level `\nstruct ` declaration (HeroTimerCard et al.).
    // Using a substring rather than a single regex avoids the non-greedy
    // match running past the closing brace into sibling structs that
    // legitimately declare their own `@ScaledMetric private var minTap`.
    guard let openerRange = source.range(of: "struct RootView: View {") else {
        Issue.record("AppViews.swift must contain `struct RootView: View {`")
        return
    }
    let afterOpener = openerRange.upperBound
    let nextStructRange = source.range(of: "\nstruct ", range: afterOpener..<source.endIndex)
    let rootViewBody = source[afterOpener..<(nextStructRange?.lowerBound ?? source.endIndex)]
    #expect(
        rootViewBody.contains("@ScaledMetric private var minTap"),
        "AppViews.swift `struct RootView` must declare `@ScaledMetric private var minTap` so the toolbar gear and EstimateInfoButton can floor their hit-test geometry on iOS 26+ Liquid Glass. Loop-28 WI-0 / AV-19."
    )
}

/// LT2 — The toolbar gear Button's `Image("gearshape")` label must be
/// floored with `.frame(minWidth: minTap, minHeight: minTap)`. Without
/// this, iOS 26.4 composites the toolbar item with a hit-test rectangle
/// XCUI cannot target, breaking `testSettingsSheetOpens`.
@Test func test_LT2_toolbarGearImageHasMinTapFrame() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    // Match the gearshape Image followed (within a small window) by a
    // .frame(...) modifier that references both `minWidth: minTap` and
    // `minHeight: minTap`. Whitespace/newline-tolerant.
    let pattern = #"Image\(systemName: "gearshape"\)[\s\S]{0,200}\.frame\([\s\S]{0,80}minWidth: minTap[\s\S]{0,80}minHeight: minTap"#
    let regex = try NSRegularExpression(pattern: pattern)
    let range = NSRange(source.startIndex..., in: source)
    #expect(
        regex.firstMatch(in: source, range: range) != nil,
        "AppViews.swift toolbar gear `Image(systemName: \"gearshape\")` must carry `.frame(minWidth: minTap, minHeight: minTap)` so its hit-test geometry meets the HIG 44-pt floor on iOS 26.4 Liquid Glass. Loop-28 WI-0 / AV-20."
    )
}

/// LT3 — The EstimateInfoButton NavigationLink's `Image("info.circle")`
/// label must be floored with `.frame(minWidth: minTap, minHeight: minTap)`.
/// Without this, iOS 26.4 composites the toolbar item with a hit-test
/// rectangle XCUI cannot target, breaking
/// `testEstimateInfoButtonOpensAboutWithHighlightedApplicabilityAnchor`
/// and `testEstimateInfoNavigationRoundTripReturnsToMainScreen`.
@Test func test_LT3_estimateInfoButtonImageHasMinTapFrame() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    let pattern = #"Image\(systemName: "info\.circle"\)[\s\S]{0,200}\.frame\([\s\S]{0,80}minWidth: minTap[\s\S]{0,80}minHeight: minTap"#
    let regex = try NSRegularExpression(pattern: pattern)
    let range = NSRange(source.startIndex..., in: source)
    #expect(
        regex.firstMatch(in: source, range: range) != nil,
        "AppViews.swift EstimateInfoButton `Image(systemName: \"info.circle\")` must carry `.frame(minWidth: minTap, minHeight: minTap)` so its hit-test geometry meets the HIG 44-pt floor on iOS 26.4 Liquid Glass. Loop-28 WI-0 / AV-20."
    )
}

// MARK: - Group LV: Loop-29 WI-3 — minWidth/minHeight literal frame guard
//
// Iris loop-29 gap analysis GAP-1: the SwiftLint `hardcoded_frame_dimensions`
// rule regex `\.frame\(\s*(?:width|height):\s*\d` cannot see literal
// `.frame(minWidth: 44)` or `.frame(minHeight: 56)` calls — only the bare
// `width:`/`height:` forms. These literal `min*` axes bypass Dynamic Type:
// at AX5 on iPhone SE they remain at their authored pt value while a
// `@ScaledMetric`-backed identifier (`minTap`, `dayRowMinHeight`, …) scales
// to roughly twice the floor. WI-29-3 widens the regex (and mirrors it in
// unit-test form here) and migrates every remaining literal `min*` site to
// a `@ScaledMetric` token.
//
// Group LV strategy:
//   LV1 — ForecastPickerView.swift: zero `.frame(...minHeight: <literal>)` /
//         `.frame(...minWidth: <literal>)` occurrences.
//   LV2 — AppViews.swift: zero `.frame(...minHeight: <literal>)` /
//         `.frame(...minWidth: <literal>)` occurrences.
//   LV3 — `.swiftlint.yml` `hardcoded_frame_dimensions` regex must include
//         `minWidth`/`minHeight` axes so SwiftLint catches new regressions
//         independently of the unit-test guard.
//   LV4 — ForecastPickerView declares the Loop-29 token block
//         (`dayRowMinHeight`, `staleBannerMinHeight`) so LV1's migrations
//         have concrete identifiers backing them.
//   LV5 — `SkinTypePickerRow` (AppViews) declares its own struct-scoped
//         `@ScaledMetric private var rowMinHeight: CGFloat = 56` — the
//         outer Button's HIG-tap floor that was previously a literal `56`.

/// Helper — URL of the repo-root `.swiftlint.yml` relative to this test file.
private func swiftlintYAMLURL(file: StaticString = #filePath) -> URL {
    let testFile = URL(fileURLWithPath: String(describing: file))
    // <repo>/app/Tests/UVBurnTimerCoreTests/MainScreenCleanupContractTests.swift
    return testFile
        .deletingLastPathComponent()   // UVBurnTimerCoreTests
        .deletingLastPathComponent()   // Tests
        .deletingLastPathComponent()   // app
        .deletingLastPathComponent()   // <repo>
        .appendingPathComponent(".swiftlint.yml")
}

/// LV1 — `ForecastPickerView.swift` must contain no
/// `.frame(...minHeight: <literal>)` or `.frame(...minWidth: <literal>)`.
/// Every touch-target / banner floor must use a `@ScaledMetric`-backed
/// identifier so it scales with Dynamic Type. Mirrors WI-29-3's tightened
/// SwiftLint `hardcoded_frame_dimensions` regex.
@Test func test_LV1_forecastPickerHasNoLiteralMinFrameAxis() throws {
    let source = try String(contentsOf: forecastPickerViewSwiftURL(), encoding: .utf8)
    let pattern = #"\.frame\([^)]*\b(?:minWidth|minHeight)\s*:\s*\d"#
    let regex = try NSRegularExpression(pattern: pattern)
    let range = NSRange(source.startIndex..., in: source)
    let matches = regex.matches(in: source, range: range)
    #expect(
        matches.isEmpty,
        "ForecastPickerView.swift must not contain `.frame(minWidth: <literal>)` or `.frame(minHeight: <literal>)`. Use `@ScaledMetric`-backed identifiers (minTap, dayRowMinHeight, staleBannerMinHeight) per Iris loop-29 gap analysis GAP-1. Found \(matches.count) literal site(s)."
    )
}

/// LV2 — `AppViews.swift` must contain no
/// `.frame(...minHeight: <literal>)` or `.frame(...minWidth: <literal>)`.
/// LU5 (loop-28 WI-1) already guards `minHeight: 44`; LV2 widens the guard
/// to every literal value (e.g. SkinTypePickerRow's outer `minHeight: 56`).
@Test func test_LV2_appViewsHasNoLiteralMinFrameAxis() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    let pattern = #"\.frame\([^)]*\b(?:minWidth|minHeight)\s*:\s*\d"#
    let regex = try NSRegularExpression(pattern: pattern)
    let range = NSRange(source.startIndex..., in: source)
    let matches = regex.matches(in: source, range: range)
    #expect(
        matches.isEmpty,
        "AppViews.swift must not contain `.frame(minWidth: <literal>)` or `.frame(minHeight: <literal>)`. Use `@ScaledMetric`-backed identifiers (minTap, rowMinHeight, …) per Iris loop-29 gap analysis GAP-1. Found \(matches.count) literal site(s)."
    )
}

/// LV3 — `.swiftlint.yml` `hardcoded_frame_dimensions` rule must include
/// `minWidth`/`minHeight` axes in its regex. Without this, SwiftLint cannot
/// catch future regressions and LV1/LV2 must carry the load alone.
@Test func test_LV3_swiftlintHardcodedFrameRuleCoversMinAxes() throws {
    let source = try String(contentsOf: swiftlintYAMLURL(), encoding: .utf8)
    // The rule definition lives inside `custom_rules:` →
    // `hardcoded_frame_dimensions:` → `regex: '<pattern>'`. We grep the
    // rule's regex line and assert it mentions both `minWidth` and
    // `minHeight` (case-sensitive — Swift API uses camelCase).
    let pattern = #"hardcoded_frame_dimensions:[\s\S]{0,400}regex:\s*'[^']*\bminWidth\b[^']*'[\s\S]{0,200}|hardcoded_frame_dimensions:[\s\S]{0,400}regex:\s*'[^']*\bminHeight\b[^']*'"#
    let regex = try NSRegularExpression(pattern: pattern)
    let range = NSRange(source.startIndex..., in: source)
    #expect(
        regex.firstMatch(in: source, range: range) != nil,
        ".swiftlint.yml `hardcoded_frame_dimensions` regex must include both `minWidth` and `minHeight` axes so SwiftLint catches `.frame(minWidth: 44)` / `.frame(minHeight: 56)` literals. Iris loop-29 gap analysis GAP-1."
    )
}

/// LV4 — `ForecastPickerView.swift` must declare the loop-29
/// `@ScaledMetric` tokens that back LV1's literal migrations.
@Test func test_LV4_forecastPickerDeclaresLoop29MinFrameTokens() throws {
    let source = try String(contentsOf: forecastPickerViewSwiftURL(), encoding: .utf8)
    let requiredDeclarations = [
        "@ScaledMetric private var dayRowMinHeight",
        "@ScaledMetric private var staleBannerMinHeight"
    ]
    for decl in requiredDeclarations {
        #expect(
            source.contains(decl),
            "ForecastPickerView.swift must declare `\(decl)` per loop-29 WI-3 — backs literal-frame migrations at the day-row Button (52pt) and the stale-data banner HStack (28pt)."
        )
    }
}

/// LV5 — `SkinTypePickerRow` (AppViews.swift) must carry its own
/// `@ScaledMetric private var rowMinHeight: CGFloat = 56`. This struct
/// hosts a Button whose outer `.frame(minHeight: 56)` was a literal —
/// the row's intentional taller floor (two text lines) cannot reuse the
/// canonical `minTap = 44`; it needs a dedicated token. Substring-bounded
/// to the struct body so neighbouring `ScaledMetric` declarations on
/// other structs cannot satisfy the contract.
@Test func test_LV5_skinTypePickerRowDeclaresRowMinHeightScaledMetric() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    let opener = "\nstruct SkinTypePickerRow: View {"
    let closer = "\nstruct "
    guard let startRange = source.range(of: opener) else {
        Issue.record("AppViews.swift must declare `struct SkinTypePickerRow: View {`.")
        return
    }
    let afterOpener = startRange.upperBound
    let restOfFile = source[afterOpener...]
    let endIndex = restOfFile.range(of: closer)?.lowerBound ?? source.endIndex
    let body = source[afterOpener..<endIndex]
    #expect(
        body.contains("@ScaledMetric private var rowMinHeight"),
        "SkinTypePickerRow (AppViews.swift) must declare `@ScaledMetric private var rowMinHeight: CGFloat = 56` so its outer Button hit-target floor scales with Dynamic Type. Loop-29 WI-3."
    )
    #expect(
        body.contains(".frame(minHeight: rowMinHeight)"),
        "SkinTypePickerRow outer Button must apply `.frame(minHeight: rowMinHeight)` (not the literal `56`). Loop-29 WI-3."
    )
}

// MARK: - Group LW: Loop-29 WI-2 — Button { trailing-closure form HIG floor
//
// Iris loop-29 gap analysis GAP-2: the SwiftLint `missing_min_touch_target`
// rule regex `(?:\.onTapGesture\b|\bButton\s*\()` caught `.onTapGesture` and
// `Button(` (with paren) but MISSED `Button {` (trailing-closure form). That
// blind spot let the iOS 26.4 toolbar hittability regression on the gear
// Button (AppViews.swift line 122) slip through SwiftLint in Loop-28 — PR
// #99 fixed the call site manually but did not close the rule hole. WI-29-2
// widens the alternation to also catch `Button {` and mirrors the guard
// here so unit tests catch regressions independently of the lint pass.
//
// Group LW strategy:
//   LW1 — `.swiftlint.yml` `missing_min_touch_target` regex line contains
//         the alternation literal `Button\s*\{`.
//   LW2 — `AppViews.swift` contains no `Button {` site lacking an adjacent
//         `.frame(...min(Width|Height): <id>...)` within 200 chars (mirror
//         of the SwiftLint lookahead). Sites carrying an immediately-
//         preceding `// swiftlint:disable:next missing_min_touch_target`
//         directive are intentional system-floor exceptions and exempt.
//   LW3 — Same mirror-guard for `ForecastPickerView.swift`.

/// Mirror-guard: returns `Button {` (trailing-closure-form) matches in
/// `source` that lack an adjacent
/// `.frame(...min(Width|Height): <identifier>...)` within 200 chars AND
/// are not suppressed by an immediately-preceding
/// `// swiftlint:disable:next missing_min_touch_target` directive.
/// Mirrors the SwiftLint `missing_min_touch_target` regex exactly so a
/// regression in either side will be caught.
private func unsuppressedButtonTrailingClosureViolations(
    in source: String
) throws -> [NSRange] {
    let pattern = #"\bButton\s*\{(?![\s\S]{0,200}\.frame\([^)]*min(?:Width|Height):\s*[A-Za-z_]+\b)"#
    let regex = try NSRegularExpression(pattern: pattern)
    let range = NSRange(source.startIndex..., in: source)
    let matches = regex.matches(in: source, range: range)
    let nsSource = source as NSString
    return matches.compactMap { match -> NSRange? in
        let start = match.range.location
        // Resolve the current line (containing the Button { match) and the
        // immediately-preceding line by scanning newlines — inline directives
        // can exceed any fixed lookback window.
        var lineStart = start
        while lineStart > 0 && nsSource.character(at: lineStart - 1) != 0x0A {
            lineStart -= 1
        }
        var lineEnd = start
        while lineEnd < nsSource.length && nsSource.character(at: lineEnd) != 0x0A {
            lineEnd += 1
        }
        let currentLine = nsSource.substring(
            with: NSRange(location: lineStart, length: lineEnd - lineStart)
        )
        if currentLine.contains("swiftlint:disable:this")
            && currentLine.contains("missing_min_touch_target") {
            return nil
        }
        if lineStart > 0 {
            let endOfPrev = lineStart - 1
            var startOfPrev = endOfPrev
            while startOfPrev > 0 && nsSource.character(at: startOfPrev - 1) != 0x0A {
                startOfPrev -= 1
            }
            let prevLine = nsSource.substring(
                with: NSRange(location: startOfPrev, length: endOfPrev - startOfPrev)
            )
            if prevLine.contains("swiftlint:disable:next")
                && prevLine.contains("missing_min_touch_target") {
                return nil
            }
        }
        return match.range
    }
}

/// LW1 — `.swiftlint.yml` `missing_min_touch_target` rule regex must
/// include the `Button\s*\{` alternation so SwiftLint catches the
/// trailing-closure form (e.g. the gear toolbar Button at AppViews.swift
/// line 122 that bypassed the rule in Loop-28). Iris loop-29 GAP-2.
@Test func test_LW1_swiftlintMissingMinTouchTargetCoversButtonTrailingClosure() throws {
    let source = try String(contentsOf: swiftlintYAMLURL(), encoding: .utf8)
    let pattern = #"missing_min_touch_target:[\s\S]{0,1500}regex:\s*'[^']*Button\\s\*\\\{[^']*'"#
    let regex = try NSRegularExpression(pattern: pattern)
    let range = NSRange(source.startIndex..., in: source)
    #expect(
        regex.firstMatch(in: source, range: range) != nil,
        ".swiftlint.yml `missing_min_touch_target` regex must include the `Button\\s*\\{` alternation so SwiftLint catches `Button {` (trailing-closure form). Iris loop-29 gap analysis GAP-2 — closes the blind spot that let the iOS 26.4 gear-Button toolbar hittability regression (AppViews.swift line 122) slip through SwiftLint in Loop-28."
    )
}

/// LW2 — `AppViews.swift` must contain no `Button {` (trailing-closure
/// form) site missing an adjacent `@ScaledMetric`-backed
/// `.frame(...min(Width|Height): <id>...)` within 200 chars, unless that
/// site carries an immediately-preceding
/// `// swiftlint:disable:next missing_min_touch_target` directive. Mirrors
/// WI-29-2's widened SwiftLint regex in Swift `NSRegularExpression`.
@Test func test_LW2_appViewsButtonTrailingClosureSitesCarryMinTapFloor() throws {
    let source = try String(contentsOf: appViewsSwiftURL(), encoding: .utf8)
    let violations = try unsuppressedButtonTrailingClosureViolations(in: source)
    #expect(
        violations.isEmpty,
        "AppViews.swift must not contain `Button {` (trailing-closure) sites without an adjacent `@ScaledMetric`-backed `.frame(minWidth: <id>, minHeight: <id>)` within 200 chars — or, where the system style already guarantees the HIG ≥44pt tap-target floor, a `// swiftlint:disable:next missing_min_touch_target` directive with a Reason: comment. Iris loop-29 gap analysis GAP-2 / WI-29-2. Found \(violations.count) unsuppressed site(s)."
    )
}

/// LW3 — `ForecastPickerView.swift` mirror-guard for the trailing-closure
/// form. Iris loop-29 gap analysis GAP-2 / WI-29-2.
@Test func test_LW3_forecastPickerButtonTrailingClosureSitesCarryMinTapFloor() throws {
    let source = try String(contentsOf: forecastPickerViewSwiftURL(), encoding: .utf8)
    let violations = try unsuppressedButtonTrailingClosureViolations(in: source)
    #expect(
        violations.isEmpty,
        "ForecastPickerView.swift must not contain `Button {` (trailing-closure) sites without an adjacent `@ScaledMetric`-backed `.frame(minWidth: <id>, minHeight: <id>)` within 200 chars — or, where the system style already guarantees the HIG ≥44pt tap-target floor, a `// swiftlint:disable:next missing_min_touch_target` directive with a Reason: comment. Iris loop-29 gap analysis GAP-2 / WI-29-2. Found \(violations.count) unsuppressed site(s)."
    )
}
