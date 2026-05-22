// ImageSystemNameAccessibilityContractTests.swift
// Contract tests for WI-loop30-4a-iris-3sites.
//
// Iris's image-a11y fixture catalog (decisions/inbox/iris-image-accessibility-fixtures.md)
// identified 3 POSITIVE sites that fail the upcoming
// `image_systemname_missing_accessibility_label` rule. These tests gate each site
// at the source level so the fix cannot regress.
//
// Sites under contract:
//   1. AppViews.swift            — TierBadge accessory glyph (differentiateWithoutColor slot)
//   2. ForecastPickerView.swift  — stale-data refresh banner ("arrow.clockwise")
//   3. ForecastPickerView.swift  — refresh-error banner ("exclamationmark.icloud")
//
// WCAG SC 1.1.1 (Non-text Content): SF Symbol images must carry a text alternative
// or be marked decorative — adjacency to a sibling Text is NOT a labeling relation
// in SwiftUI's accessibility tree (Iris P5 / E5).
//
// Reference: CURRENT_DATETIME = 2026-05-22T20:55:00Z

import Foundation
import Testing

// MARK: - Source loader helper

private enum A11yContractSource {
    /// Locates a Swift source file under `app/Sources/UVBurnTimer/` relative to the
    /// repository root. We walk up from the test bundle / current file until we find
    /// `app/Sources/UVBurnTimer/<name>.swift`. This is a brittle-but-honest TDD gate
    /// per Kwame's WI-loop30-4a-iris-3sites brief; a richer view-tree probe can land later.
    static func load(_ relativeName: String, file: StaticString = #filePath) throws -> String {
        let here = URL(fileURLWithPath: String(describing: file))
        var dir = here.deletingLastPathComponent()
        for _ in 0..<10 {
            let candidate = dir
                .appendingPathComponent("app")
                .appendingPathComponent("Sources")
                .appendingPathComponent("UVBurnTimer")
                .appendingPathComponent(relativeName)
            if FileManager.default.fileExists(atPath: candidate.path) {
                return try String(contentsOf: candidate, encoding: .utf8)
            }
            dir = dir.deletingLastPathComponent()
        }
        throw NSError(
            domain: "A11yContractSource",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Could not locate app/Sources/UVBurnTimer/\(relativeName) walking up from \(here.path)"]
        )
    }
}

// MARK: - Site 1: TierBadge accessory glyph (AppViews.swift)

/// A11Y-1 — TierBadge accessory `Image(systemName:)` is marked `.accessibilityHidden(true)`.
///
/// The badge's primary `Label(title, systemImage:)` already carries the user-readable
/// label; the differentiate-without-color glyph is purely visual and MUST be hidden
/// from the accessibility tree so VoiceOver does not announce its symbol-id.
@Test func test_A11Y_1_tierBadge_accessoryGlyph_isAccessibilityHidden() throws {
    let source = try A11yContractSource.load("AppViews.swift")

    // Slice around the TierBadge body so the assertion can't be satisfied by an
    // unrelated `.accessibilityHidden(true)` elsewhere in the file.
    guard let tierBadgeRange = source.range(of: "struct TierBadge: View") else {
        Issue.record("TierBadge not found in AppViews.swift")
        return
    }
    let tail = source[tierBadgeRange.lowerBound...]
    let slice = String(tail.prefix(2_000))

    #expect(
        slice.contains("Image(systemName: accessorySymbolName)"),
        "TierBadge accessory glyph (Iris fixture POS@1152) not found — site may have moved"
    )
    #expect(
        slice.contains(".accessibilityHidden(true)"),
        """
        TierBadge accessory `Image(systemName: accessorySymbolName)` must carry \
        `.accessibilityHidden(true)` (Iris POS@AppViews.swift:1152 — WCAG 1.1.1; \
        sibling Label already announces the badge content).
        """
    )
}

// MARK: - Site 2: ForecastPickerView stale-banner spinner

/// A11Y-2 — Stale-data refresh banner (`arrow.clockwise`) combines children with a label.
///
/// The HStack wrapping the spinner + "Updating forecast…" Text MUST present as a
/// single combined accessibility element with a cohesive label so VoiceOver reads
/// one status announcement instead of "Arrow, clockwise, image. Updating forecast."
@Test func test_A11Y_2_forecastStaleBanner_combinesChildrenWithLabel() throws {
    let source = try A11yContractSource.load("ForecastPickerView.swift")

    guard let bannerRange = source.range(of: "Image(systemName: \"arrow.clockwise\"") else {
        Issue.record("arrow.clockwise spinner not found in ForecastPickerView.swift")
        return
    }
    // Look from the spinner forward to the next case label so we only see the
    // refreshing-state HStack's modifier chain.
    let tail = source[bannerRange.lowerBound...]
    let slice = String(tail.prefix(1_500))

    #expect(
        slice.contains(".accessibilityElement(children: .combine)"),
        """
        Stale-data refresh banner HStack must carry `.accessibilityElement(children: .combine)` \
        (Iris POS@ForecastPickerView.swift:209 — WCAG 1.1.1).
        """
    )
    #expect(
        slice.contains(".accessibilityLabel(\"Updating forecast\")"),
        """
        Stale-data refresh banner HStack must carry `.accessibilityLabel(\"Updating forecast\")` \
        alongside `.accessibilityElement(children: .combine)` so VoiceOver announces a single \
        cohesive status (Iris POS@ForecastPickerView.swift:209).
        """
    )
}

// MARK: - Site 3: ForecastPickerView refresh-error banner

/// A11Y-3 — Refresh-error banner (`exclamationmark.icloud`) combines children with a label.
///
/// Same shape as A11Y-2 but for the `.error` case. The Retry button remains its own
/// focusable element by virtue of `Button` being interactive (combine respects controls).
@Test func test_A11Y_3_forecastErrorBanner_combinesChildrenWithLabel() throws {
    let source = try A11yContractSource.load("ForecastPickerView.swift")

    guard let bannerRange = source.range(of: "Image(systemName: \"exclamationmark.icloud\"") else {
        Issue.record("exclamationmark.icloud glyph not found in ForecastPickerView.swift")
        return
    }
    let tail = source[bannerRange.lowerBound...]
    let slice = String(tail.prefix(1_500))

    #expect(
        slice.contains(".accessibilityElement(children: .combine)"),
        """
        Refresh-error banner HStack must carry `.accessibilityElement(children: .combine)` \
        (Iris POS@ForecastPickerView.swift:230 — WCAG 1.1.1).
        """
    )
    #expect(
        slice.contains(".accessibilityLabel(\"Could not update forecast\")"),
        """
        Refresh-error banner HStack must carry `.accessibilityLabel(\"Could not update forecast\")` \
        alongside `.accessibilityElement(children: .combine)` (Iris POS@ForecastPickerView.swift:230).
        """
    )
}
