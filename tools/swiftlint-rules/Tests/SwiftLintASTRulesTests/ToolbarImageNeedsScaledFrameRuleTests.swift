import XCTest
@testable import SwiftLintASTRules

// TDD-first tests for the SwiftSyntax port of the SwiftLint regex rule
// `toolbar_image_needs_scaled_frame` (Group LY).
//
// Acceptance per ADR-0003 §Spike scope:
//   1. Verdict parity with regex on the Group LY contract corpus
//      (LY1/LY2/LY3 — covered indirectly: see `appViewsParity` test).
//   2. Catches at least one synthetic case the regex misses (the
//      ">2000 char balanced-brace" case below).
//   3. CI cost bounded — covered by the swift-test wall-clock metric in
//      the spike report.

final class ToolbarImageNeedsScaledFrameRuleTests: XCTestCase {

    private func violations(_ source: String) -> [Violation] {
        let rule = ToolbarImageNeedsScaledFrameRule()
        return rule.violations(in: source)
    }

    // MARK: - True positives (rule MUST fire)

    func test_truePositive_bareImageInToolbar() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").toolbar {
                    Image(systemName: "gear")
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_imageInToolbarItem() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_imageInToolbarItemGroup() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Image(systemName: "back")
                        Image(systemName: "forward")
                    }
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 2)
    }

    func test_truePositive_balancedBraceLongBody_regexBlindSpotCase() {
        // ADR-0003 §Spike acceptance #2 — synthetic case the regex misses.
        // The regex caps its outer toolbar window at 2000 chars; we
        // intentionally pad with a deeply nested Menu to push the Image past
        // that window. AST sees the toolbar parent regardless of length.
        let filler = String(repeating: "                    Text(\"padding row payload xyz\")\n",
                            count: 60)
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").toolbar {
                    Menu("More") {
        \(filler)
                    }
                    Image(systemName: "gear")
                }
            }
        }
        """
        XCTAssertGreaterThan(source.count, 2000, "Fixture must exceed regex's 2000-char window")
        XCTAssertEqual(violations(source).count, 1, "AST must catch the post-window Image")
    }

    // MARK: - True negatives (rule MUST stay silent)

    func test_trueNegative_imageWithFrameWidthHeight() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").toolbar {
                    Image(systemName: "gear")
                        .frame(width: 22, height: 22)
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_imageWithFrameMinScaled() {
        let source = """
        import SwiftUI
        struct V: View {
            @ScaledMetric private var minTap: CGFloat = 44
            var body: some View {
                Text("hi").toolbar {
                    Image(systemName: "gear")
                        .frame(minWidth: minTap, minHeight: minTap)
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_imageWithImageScale() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").toolbar {
                    Button { } label: {
                        Image(systemName: "gear").imageScale(.large)
                    }
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_imageOutsideToolbar() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Image(systemName: "gear")  // not in toolbar — fine
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Edge cases

    func test_edge_imageNamedVariant() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").toolbar {
                    Image("logo")
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_edge_imageUIImageVariant() {
        let source = """
        import SwiftUI
        struct V: View {
            var ui: UIImage
            var body: some View {
                Text("hi").toolbar {
                    Image(uiImage: ui)
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_edge_nestedToolbars() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").toolbar {
                    Image(systemName: "a")
                }
                Text("yo").toolbar {
                    Image(systemName: "b").frame(width: 22, height: 22)
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_edge_multipleItemsMixedFloors() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { } label: {
                            Image(systemName: "gear")
                                .frame(minWidth: 44, minHeight: 44)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Image(systemName: "info")  // missing floor
                    }
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_edge_buttonLabelImageScaled() {
        // The exact AppViews.swift line-122 shape from PR #99 — rule must
        // stay silent here (this is the live production shape).
        let source = """
        import SwiftUI
        struct V: View {
            @ScaledMetric private var minTap: CGFloat = 44
            @State private var showSettings = false
            var body: some View {
                Text("hi").toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .frame(minWidth: minTap, minHeight: minTap)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Parity gate against live app source (ADR-0003 §Spike #1)

    func test_appViewsSwift_zeroViolations_parity() throws {
        // Walk up from this test file to repo root.
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
                       "Parity break: AST flagged \(v.count) site(s) in AppViews.swift that the regex says are clean. Sites: \(v.map { "L\($0.line)" })")
    }
}
