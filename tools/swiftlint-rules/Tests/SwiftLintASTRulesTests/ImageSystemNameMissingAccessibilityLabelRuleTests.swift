import XCTest
@testable import SwiftLintASTRules

// TDD-first tests for the SwiftSyntax AST rule
// `image_systemname_missing_accessibility_label` (WI-loop30-4a, ADR-0003
// §Rollout WI-30-B). Iris's scope memo (Loop-30 iter-2 closure) defines
// the FP contract: every existing `Image(systemName:)` site in
// `app/Sources/` must remain silent because every one of them is either
//   (a) inside an interactive ancestor's label closure that carries
//       `.accessibilityLabel(...)` (or a parent that combines children
//       under a single accessibility label), or
//   (b) carries `.accessibilityHidden(true)` / `.accessibilityLabel(...)`
//       directly on its own modifier chain, or
//   (c) lives inside a `Label { ... } icon: { Image(...) }` block whose
//       title closure supplies the label.
//
// The rule fires on a bare `Image(systemName: ...)` that satisfies NONE
// of (a)/(b)/(c) — i.e. an unlabeled VoiceOver-blind icon.

final class ImageSystemNameMissingAccessibilityLabelRuleTests: XCTestCase {

    private func violations(_ source: String) -> [Violation] {
        let rule = ImageSystemNameMissingAccessibilityLabelRule()
        return rule.violations(in: source)
    }

    // MARK: - True positives (rule MUST fire)

    func test_truePositive_bareImageSystemName_noWrappers() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Image(systemName: "trash")
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_imageInPlainHStack_noLabels() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                HStack {
                    Image(systemName: "trash")
                    Text("Some sibling text")
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_imageInBareButtonActionClosure_noLabel() {
        // `Button { Image(...) }` — single trailing closure is the
        // *action* (returns Void), so this is malformed SwiftUI, but the
        // shape is something a careless author could write. The Image is
        // NOT in a label closure → fire. (Even if SwiftUI rejected the
        // expression at typecheck, the lint rule fires structurally.)
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                VStack {
                    Image(systemName: "trash")
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    // MARK: - True negatives — case (b): own modifier on the Image

    func test_trueNegative_imageWithAccessibilityLabel() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Image(systemName: "trash")
                    .accessibilityLabel("Delete")
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_imageWithAccessibilityHiddenTrue() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Image(systemName: "trash")
                    .accessibilityHidden(true)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - True negatives — case (a): interactive ancestor label closure

    func test_trueNegative_imageInsideButtonLabelClosure() {
        // `Button { ... } label: { Image(...) }` — Image is in the label
        // closure → silent.
        let source = """
        import SwiftUI
        struct V: View {
            @State private var x = false
            var body: some View {
                Button {
                    x = true
                } label: {
                    Image(systemName: "trash")
                }
                .accessibilityLabel("Delete")
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_imageInsideNavigationLinkLabel() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                NavigationLink(destination: Text("About")) {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel("About this estimate")
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_imageInsideLinkLabel() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Link(destination: URL(string: "https://example.com")!) {
                    Image(systemName: "link")
                }
                .accessibilityLabel("Open site")
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - True negatives — case (c): Label-wrapped Image

    func test_trueNegative_labelWithSystemImageString_noImageExpr() {
        // `Label(_:systemImage:)` takes a String — there is no
        // `Image(systemName:)` *expression* in this source at all, so
        // the rule trivially does not fire.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Label("Delete", systemImage: "trash")
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_imageInsideLabelIconClosure() {
        // `Label { Text(...) } icon: { Image(systemName: ...) }` — Label
        // derives the accessibility label from the title closure, so the
        // icon Image is silent.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Label {
                    Text("Delete this item")
                } icon: {
                    Image(systemName: "trash")
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Edge — combine-children HStack with parent label

    func test_trueNegative_combineChildrenWithParentAccessibilityLabel() {
        // AppViews.swift:1152 shape — standalone Image inside an HStack
        // whose modifier chain carries
        // `.accessibilityElement(children: .combine).accessibilityLabel(...)`.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                HStack(spacing: 6) {
                    Text("Long")
                    Image(systemName: "exclamationmark.triangle")
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Long burn-time tier")
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Edge — nested Button containing Label containing Image

    func test_edge_buttonContainsLabelContainsImage() {
        // `Button { } label: { Label { Text } icon: { Image(systemName) } }`
        // — Image is inside Label.icon AND inside Button.label. Either
        // silencer alone should suffice; together, silent.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Button {
                } label: {
                    Label {
                        Text("Settings")
                    } icon: {
                        Image(systemName: "gearshape")
                    }
                }
                .accessibilityLabel("Settings")
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_edge_toolbarItemWithButtonLabelImage() {
        // Production shape from AppViews.swift:125 — `ToolbarItem { Button
        // { ... } label: { Image(systemName: ...) } .accessibilityLabel(...) }`
        let source = """
        import SwiftUI
        struct V: View {
            @State private var showSettings = false
            var body: some View {
                Text("hi").toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .frame(width: 22, height: 22)
                        }
                        .accessibilityLabel("Settings")
                    }
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_edge_imageInsideLabelIconClosureInsideNavigationLink() {
        // Defense in depth — Image silenced by Label.icon (innermost)
        // even when also inside NavigationLink.label.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                NavigationLink(destination: Text("x")) {
                    Label {
                        Text("Info")
                    } icon: {
                        Image(systemName: "info.circle")
                    }
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Edge — multiple sites in one body, mixed labelings

    func test_edge_multipleImages_oneLabeledOneNot() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                VStack {
                    Image(systemName: "moon.fill")
                        .accessibilityHidden(true)
                    Image(systemName: "alert")
                }
            }
        }
        """
        let v = violations(source)
        XCTAssertEqual(v.count, 1)
        XCTAssertTrue(v.first?.message.contains("Image(systemName:)") ?? false)
    }

    // MARK: - Negative case to confirm `accessibilityHidden(false)` does NOT silence

    func test_truePositive_accessibilityHiddenFalseStillFires() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Image(systemName: "trash")
                    .accessibilityHidden(false)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    // MARK: - Parity gate against live app source (Iris FP scan: 0 expected)

    func test_appViewsSwift_zeroViolations_parity() throws {
        let here = URL(fileURLWithPath: #filePath)
        let repoRoot = here
            .deletingLastPathComponent() // …/SwiftLintASTRulesTests
            .deletingLastPathComponent() // …/Tests
            .deletingLastPathComponent() // …/swiftlint-rules
            .deletingLastPathComponent() // …/tools
            .deletingLastPathComponent() // repo root
        let appViews = repoRoot
            .appendingPathComponent("app/Sources/UVBurnTimer/AppViews.swift")
        guard FileManager.default.fileExists(atPath: appViews.path) else {
            throw XCTSkip("AppViews.swift not found at \(appViews.path)")
        }
        let source = try String(contentsOf: appViews, encoding: .utf8)
        let v = violations(source)
        XCTAssertEqual(v.count, 0,
                       "FP-scan break: AST flagged \(v.count) site(s) in AppViews.swift that Iris's scope memo says are clean. Sites: \(v.map { "L\($0.line)" })")
    }

    func test_forecastPickerViewSwift_zeroViolations_parity() throws {
        let here = URL(fileURLWithPath: #filePath)
        let repoRoot = here
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let target = repoRoot
            .appendingPathComponent("app/Sources/UVBurnTimer/ForecastPickerView.swift")
        guard FileManager.default.fileExists(atPath: target.path) else {
            throw XCTSkip("ForecastPickerView.swift not found at \(target.path)")
        }
        let source = try String(contentsOf: target, encoding: .utf8)
        let v = violations(source)
        XCTAssertEqual(v.count, 0,
                       "FP-scan break: AST flagged \(v.count) site(s) in ForecastPickerView.swift. Sites: \(v.map { "L\($0.line)" })")
    }
}
