import XCTest
@testable import SwiftLintASTRules

// TDD tests for `color_only_meaning_signal` (WI-L32-IRIS-AST-BATCH2 rule #1).
//
// Rule fires on a `.foregroundStyle/.foregroundColor/.tint` modifier
// whose receiver chain ends at a primitive Shape leaf
// (Circle/Rectangle/RoundedRectangle/Capsule/Ellipse) and whose ancestor
// modifier chain carries no accessibility silencer.
//
// Silencers tested below:
//   (a) `.accessibilityLabel(...)` / `.accessibilityHidden(true)` /
//       `.accessibilityElement(...)` / `.accessibilityValue(...)` on any
//       ancestor modifier-call.
//   (b) Per-line disable marker (`swiftlint:disable:this …` or
//       `COLOR_ONLY_OK`).

final class ColorOnlyMeaningSignalRuleTests: XCTestCase {

    private func violations(_ source: String) -> [Violation] {
        ColorOnlyMeaningSignalRule().violations(in: source)
    }

    // MARK: - True positives (rule MUST fire)

    func test_truePositive_circleForegroundStyleBare() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Circle().foregroundStyle(.red)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_circleForegroundColorBare() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Circle().foregroundColor(.red)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_capsuleTintBare() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Capsule().tint(.orange)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_rectangleColorBareWithFrameChain() {
        // Frame/padding in the receiver chain does not silence — only
        // accessibility modifiers do.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Rectangle().frame(width: 10, height: 10).foregroundStyle(.green)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_roundedRectangleColorWithArgs() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                RoundedRectangle(cornerRadius: 4).foregroundStyle(.yellow)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_ellipseColor() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Ellipse().foregroundColor(.blue)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_circleSiblingTextNotASilencer() {
        // Sibling adjacency is NOT a silencer (Iris HIG catalog stance).
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                HStack {
                    Circle().foregroundStyle(.red)
                    Text("Alert")
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    // MARK: - Silencer (a) — accessibility chain modifier

    func test_silencerA_circleWithAccessibilityLabel() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Circle()
                    .foregroundStyle(.red)
                    .accessibilityLabel("UV alert")
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerA_circleWithAccessibilityHiddenTrue() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Circle()
                    .foregroundStyle(.red)
                    .accessibilityHidden(true)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerA_circleWithAccessibilityHiddenFalseStillFires() {
        // .accessibilityHidden(false) is explicit opt-in, NOT a silencer.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Circle()
                    .foregroundStyle(.red)
                    .accessibilityHidden(false)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_silencerA_parentStackAccessibilityElementCombine() {
        // The TierBadge pattern: HStack-level combine + label.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                HStack {
                    Circle().foregroundStyle(.red)
                    Text("Alert")
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("UV alert")
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Silencer (b) — per-line disable comment

    func test_silencerB_swiftlintDisableThisComment() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Circle().foregroundStyle(.red) // swiftlint:disable:this color_only_meaning_signal
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerB_colorOnlyOKMarker() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Circle().foregroundStyle(.red) // COLOR_ONLY_OK: decorative bullet
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - True negatives — modifier does NOT apply to a shape

    func test_trueNegative_foregroundStyleOnText() {
        // Text carries semantic content; the rule does not fire.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").foregroundStyle(.red)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_foregroundStyleOnImage() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Image(systemName: "exclamationmark.triangle").foregroundStyle(.orange)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_foregroundStyleOnHStack() {
        // HStack with sibling Label provides semantic identity at the
        // stack level — rule only fires at the shape-leaf boundary.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                HStack {
                    Label("Hot", systemImage: "flame.fill")
                }
                .foregroundStyle(.red)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_capsuleAsBackgroundShape() {
        // Capsule passed as the `in:` argument to .background(...) is
        // not the receiver of any color modifier — rule silent.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi")
                    .foregroundStyle(.red)
                    .background(.orange, in: Capsule())
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_circleFillNotForeground() {
        // .fill is a Shape-specific colorization that VoiceOver treats
        // identically — but Iris's scope for batch-2 is the
        // foregroundStyle/foregroundColor/tint trio (production
        // patterns). `.fill` deferred to a future rule.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Circle().fill(.red)
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
                Circle().foregroundStyle(.red)
            }
        }
        """
        let result = violations(source)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.ruleID, "color_only_meaning_signal")
        XCTAssertEqual(result.first?.line, 4)
    }

    // MARK: - Parity gate — production app source must stay clean

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
            "app/Sources must be color-only-clean; got: " +
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
            .appendingPathComponent("app/Sources/UVBurnTimer", isDirectory: true)
    }
}
