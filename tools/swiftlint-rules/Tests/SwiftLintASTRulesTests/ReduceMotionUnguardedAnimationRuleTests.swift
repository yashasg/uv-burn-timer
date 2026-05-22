import XCTest
@testable import SwiftLintASTRules

// TDD tests for the SwiftSyntax AST rule
// `reduce_motion_unguarded_animation` (WI-loop31-1, ADR-0003 §Rollout —
// Iris HIG catalog Batch-1 rule #1, Critical/M).
//
// Rule fires on SwiftUI animation expressions that visibly move/scale/
// rotate content without honoring `accessibilityReduceMotion`. See the
// rule's doc-comment for the full contract.
//
// Silencers tested below:
//   (a) ternary on a reduceMotion-named identifier in the argument,
//   (b) lexically inside an `if reduceMotion / if !reduceMotion / else`
//       branch whose condition references a reduceMotion identifier,
//   (c) argument is `nil` / `.identity` / `.opacity` (transition only)
//       / a plain identifier (deferred to author's computed var),
//   (d) per-line disable marker:
//       `// swiftlint:disable:this reduce_motion_unguarded_animation`
//       or the alternative `// REDUCE_MOTION_OK` comment marker on the
//       same source line.

final class ReduceMotionUnguardedAnimationRuleTests: XCTestCase {

    private func violations(_ source: String) -> [Violation] {
        let rule = ReduceMotionUnguardedAnimationRule()
        return rule.violations(in: source)
    }

    // MARK: - True positives — .animation(...) modifier

    func test_truePositive_animationSpringUnconditional() {
        let source = """
        import SwiftUI
        struct V: View {
            @State var x = 0
            var body: some View {
                Text("hi")
                    .animation(.spring(), value: x)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_animationEaseInOutUnconditional() {
        let source = """
        import SwiftUI
        struct V: View {
            @State var x = 0
            var body: some View {
                Text("hi").animation(.easeInOut, value: x)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_animationDefaultUnconditional() {
        let source = """
        import SwiftUI
        struct V: View {
            @State var y = 0
            var body: some View {
                Text("hi").animation(.default, value: y)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    // MARK: - True positives — withAnimation { ... }

    func test_truePositive_withAnimationBareCall() {
        let source = """
        import SwiftUI
        struct V: View {
            @State var open = false
            var body: some View {
                Button("Toggle") {
                    withAnimation {
                        open.toggle()
                    }
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_withAnimationWithExplicitAnimationArg() {
        let source = """
        import SwiftUI
        struct V: View {
            @State var open = false
            var body: some View {
                Button("Toggle") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        open.toggle()
                    }
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    // MARK: - True positives — .contentTransition(...) and .transition(...)

    func test_truePositive_contentTransitionNumericText() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("12").contentTransition(.numericText())
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_transitionSlide() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").transition(.slide)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_transitionMoveEdge() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").transition(.move(edge: .top))
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_transitionScale() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").transition(.scale)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    // MARK: - Silencer (a) — ternary on reduceMotion identifier

    func test_silencerA_ternaryReduceMotionInAnimation() {
        let source = """
        import SwiftUI
        struct V: View {
            @Environment(\\.accessibilityReduceMotion) var reduceMotion
            @State var x = 0
            var body: some View {
                Text("hi")
                    .animation(reduceMotion ? nil : .spring(), value: x)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerA_ternaryAccessibilityReduceMotionInAnimation() {
        let source = """
        import SwiftUI
        struct V: View {
            @Environment(\\.accessibilityReduceMotion) var accessibilityReduceMotion
            @State var x = 0
            var body: some View {
                Text("hi")
                    .animation(accessibilityReduceMotion ? nil : .easeInOut, value: x)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerA_ternaryReduceMotionInWithAnimation() {
        let source = """
        import SwiftUI
        struct V: View {
            @State var open = false
            var reduceMotion = false
            var body: some View {
                Button("Toggle") {
                    withAnimation(reduceMotion ? nil : .default) {
                        open.toggle()
                    }
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerA_ternaryReduceMotionInTransition() {
        let source = """
        import SwiftUI
        struct V: View {
            var reduceMotion = false
            var body: some View {
                Text("hi").transition(reduceMotion ? .identity : .slide)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Silencer (b) — inside if/else gated on reduceMotion

    func test_silencerB_insideIfReduceMotionElseBranch() {
        // Production AppViews.swift:1000-1004 shape.
        let source = """
        import SwiftUI
        struct V: View {
            var accessibilityReduceMotion = false
            var content: some View { Text("hi") }
            var body: some View {
                if accessibilityReduceMotion {
                    content
                } else {
                    content.contentTransition(.numericText())
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerB_insideIfNotReduceMotionThenBranch() {
        let source = """
        import SwiftUI
        struct V: View {
            var reduceMotion = false
            var body: some View {
                if !reduceMotion {
                    Text("hi").transition(.slide)
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerB_withAnimationInsideElseOfIfReduceMotion() {
        // Production AppViews.swift:1855-1864 shape.
        let source = """
        import SwiftUI
        struct V: View {
            var accessibilityReduceMotion = false
            func go() {
                if accessibilityReduceMotion {
                    print("skip")
                } else {
                    withAnimation {
                        print("animate")
                    }
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Silencer (c) — literal nil / .identity / plain identifier

    func test_silencerC_animationNilLiteral() {
        let source = """
        import SwiftUI
        struct V: View {
            @State var x = 0
            var body: some View {
                Text("hi").animation(nil, value: x)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerC_transitionIdentity() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").transition(.identity)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerC_transitionOpacityAllowed() {
        // Apple HIG: opacity-only transitions are low-motion and OK.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").transition(.opacity)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerC_contentTransitionIdentity() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").contentTransition(.identity)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerC_transitionPlainIdentifierDeferredToAuthor() {
        // Production ForecastPickerView.swift:338 shape — argument is a
        // computed `var expandTransition: AnyTransition` that itself
        // ternaries on reduceMotion. Rule trusts the author.
        let source = """
        import SwiftUI
        struct V: View {
            var expandTransition: AnyTransition { .identity }
            var body: some View {
                Text("hi").transition(expandTransition)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Silencer (d) — per-line disable comment

    func test_silencerD_swiftlintDisableThisComment() {
        let source = """
        import SwiftUI
        struct V: View {
            @State var x = 0
            var body: some View {
                Text("hi").animation(.spring(), value: x) // swiftlint:disable:this reduce_motion_unguarded_animation
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerD_reduceMotionOKMarkerSameLine() {
        let source = """
        import SwiftUI
        struct V: View {
            @State var x = 0
            var body: some View {
                Text("hi").animation(.spring(), value: x) // REDUCE_MOTION_OK: intentional micro-bounce
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
                Text("hi").transition(.slide)
            }
        }
        """
        let result = violations(source)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.ruleID, "reduce_motion_unguarded_animation")
        XCTAssertEqual(result.first?.line, 4)
    }

    // MARK: - Parity gates — production app source must stay clean

    func test_appViewsSwift_zeroViolations_parity() throws {
        let path = appSourcesPath().appendingPathComponent("AppViews.swift")
        guard FileManager.default.fileExists(atPath: path.path) else {
            throw XCTSkip("AppViews.swift not present at \(path.path)")
        }
        let source = try String(contentsOf: path, encoding: .utf8)
        let vios = violations(source)
        XCTAssertEqual(
            vios.count, 0,
            "AppViews.swift must remain reduce-motion-clean; got: " +
            vios.map { "\($0.line):\($0.column) \($0.message)" }.joined(separator: "\n")
        )
    }

    func test_forecastPickerViewSwift_zeroViolations_parity() throws {
        let path = appSourcesPath().appendingPathComponent("ForecastPickerView.swift")
        guard FileManager.default.fileExists(atPath: path.path) else {
            throw XCTSkip("ForecastPickerView.swift not present at \(path.path)")
        }
        let source = try String(contentsOf: path, encoding: .utf8)
        let vios = violations(source)
        XCTAssertEqual(
            vios.count, 0,
            "ForecastPickerView.swift must remain reduce-motion-clean; got: " +
            vios.map { "\($0.line):\($0.column) \($0.message)" }.joined(separator: "\n")
        )
    }

    private func appSourcesPath() -> URL {
        // This test file lives at:
        //   tools/swiftlint-rules/Tests/SwiftLintASTRulesTests/<this>.swift
        // Repo root is 4 directory-ups from the file's parent dir.
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // drop filename → …/SwiftLintASTRulesTests
            .deletingLastPathComponent() // → …/Tests
            .deletingLastPathComponent() // → …/swiftlint-rules
            .deletingLastPathComponent() // → …/tools
            .deletingLastPathComponent() // → repo root
            .appendingPathComponent("app/Sources/UVBurnTimer", isDirectory: true)
    }
}
