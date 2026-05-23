import XCTest
@testable import SwiftLintASTRules

// TDD tests for `missing_min_touch_target`
// (WI-L32-TOUCH-TARGET-AST; follows the WI-L32 Iris AST batch style).
//
// Rule fires on Button / NavigationLink / Link / `.onTapGesture` when the
// source declares no HIG 44pt floor. Textual controls may satisfy the rule
// with an explicit >=44pt height floor; icon-only controls must declare both
// axes (or a full-width variant such as `maxWidth: .infinity` + minHeight).

final class MissingMinTouchTargetRuleTests: XCTestCase {

    private func violations(_ source: String) -> [Violation] {
        MissingMinTouchTargetRule().violations(in: source)
    }

    // MARK: - True positives

    func test_truePositive_iconOnlyButtonHeightOnly() {
        let source = """
        import SwiftUI
        struct V: View {
            @ScaledMetric private var minTap: CGFloat = 44
            var body: some View {
                Button {
                } label: {
                    Image(systemName: "gearshape")
                        .frame(minHeight: minTap)
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_buttonExplicitlyUndersized() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Button("Go") { }
                    .frame(width: 30, height: 30)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_textOnTapGestureWithoutFloor() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("Refresh")
                    .onTapGesture { }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_linkWithoutDeclaredFloor() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Link("Open", destination: URL(string: "https://example.com")!)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    // MARK: - True negatives

    func test_trueNegative_textButtonHeightFloor() {
        let source = """
        import SwiftUI
        struct V: View {
            @ScaledMetric private var minTap: CGFloat = 44
            var body: some View {
                Button("Save") { }
                    .frame(minHeight: minTap)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_fullWidthLabelFloor() {
        let source = """
        import SwiftUI
        struct V: View {
            @ScaledMetric private var minTap: CGFloat = 44
            var body: some View {
                Button {
                } label: {
                    Label("Location", systemImage: "location")
                        .frame(maxWidth: .infinity, minHeight: minTap)
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_iconOnlyButtonBothAxes() {
        let source = """
        import SwiftUI
        struct V: View {
            @ScaledMetric private var minTap: CGFloat = 44
            var body: some View {
                Button {
                } label: {
                    Image(systemName: "gearshape")
                        .frame(minWidth: minTap, minHeight: minTap)
                        .contentShape(Rectangle())
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_textOnTapGestureWithFullWidthFloor() {
        let source = """
        import SwiftUI
        struct V: View {
            @ScaledMetric private var minTap: CGFloat = 44
            var body: some View {
                Text("Refresh")
                    .frame(maxWidth: .infinity, minHeight: minTap, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture { }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_rowButtonHeightFloorWithTextualLabel() {
        let source = """
        import SwiftUI
        struct V: View {
            @ScaledMetric private var rowMinHeight: CGFloat = 56
            var body: some View {
                Button {
                } label: {
                    HStack {
                        Text("Today")
                        Spacer()
                        Text("7")
                    }
                    .frame(minHeight: rowMinHeight)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Silencer

    func test_silencer_swiftlintDisableThisComment() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                NavigationLink("About") { Text("D") } // swiftlint:disable:this missing_min_touch_target
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencer_missingMinTouchTargetOKMarker() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                // MISSING_MIN_TOUCH_TARGET_OK: Form row chrome guarantees the floor.
                NavigationLink("About") { Text("D") }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Violation metadata

    func test_violationRuleIDAndLineColumn() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Link("Open", destination: URL(string: "https://example.com")!)
            }
        }
        """
        let result = violations(source)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.ruleID, "missing_min_touch_target")
        XCTAssertEqual(result.first?.line, 4)
    }

    // MARK: - Parity gate

    func test_appSources_zeroViolations_parity() throws {
        let dir = appSourcesPath()
        let fm = FileManager.default
        guard fm.fileExists(atPath: dir.path) else {
            throw XCTSkip("app/Sources/UVBurnTimer not present at \(dir.path)")
        }
        let enumerator = fm.enumerator(at: dir, includingPropertiesForKeys: nil)!
        var allViolations: [(file: String, line: Int, message: String)] = []
        for case let url as URL in enumerator where url.pathExtension == "swift" {
            let source = try String(contentsOf: url, encoding: .utf8)
            for v in violations(source) {
                allViolations.append((file: url.lastPathComponent, line: v.line, message: v.message))
            }
        }
        XCTAssertEqual(
            allViolations.count, 0,
            "app/Sources must be min-touch-target clean; got: " +
            allViolations.map { "\($0.file):\($0.line) \($0.message)" }.joined(separator: "\n")
        )
    }

    private func appSourcesPath() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("app/Sources/UVBurnTimer")
    }
}
