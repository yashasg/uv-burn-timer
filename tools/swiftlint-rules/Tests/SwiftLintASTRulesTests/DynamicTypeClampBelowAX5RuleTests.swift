import XCTest
@testable import SwiftLintASTRules

// TDD tests for `dynamic_type_clamp_below_ax5`
// (WI-L32-IRIS-AST-BATCH2 rule #3).
//
// Rule fires on `.dynamicTypeSize(...)` whose upper bound is below
// `.accessibility5`. Recognized argument shapes: single value, closed
// range, partial-through range, partial-from range (silent).
//
// Silencers tested below:
//   (a) Partial-from (`.large...`) → unbounded upper.
//   (b) Upper bound is exactly `.accessibility5`.
//   (c) Argument is a dynamic expression (variable, function call).
//   (d) Per-line disable marker.

final class DynamicTypeClampBelowAX5RuleTests: XCTestCase {

    private func violations(_ source: String) -> [Violation] {
        DynamicTypeClampBelowAX5Rule().violations(in: source)
    }

    // MARK: - True positives

    func test_truePositive_singleValueLarge() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").dynamicTypeSize(.large)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_closedRangeUpperXXXLarge() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").dynamicTypeSize(.xSmall ... .xxxLarge)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_closedRangeUpperAccessibility3() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").dynamicTypeSize(.xSmall ... .accessibility3)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_partialThroughBelowAX5() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").dynamicTypeSize(...DynamicTypeSize.accessibility3)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_partialThroughDottedShorthand() {
        // Standard partial-through form with type-qualified upper —
        // the canonical syntax SwiftUI authors use. The bare
        // `... .accessibility4` shorthand without an explicit type
        // qualifier is parser-ambiguous; that variant is out of scope
        // for batch-2 and may be added as a follow-up if it appears.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").dynamicTypeSize(...DynamicTypeSize.accessibility4)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_singleValueMedium() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").dynamicTypeSize(.medium)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    // MARK: - Silencer (a) — partial-from is unbounded

    func test_silencerA_partialFromLarge() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").dynamicTypeSize(.large...)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerA_partialFromAccessibility1() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").dynamicTypeSize(.accessibility1...)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Silencer (b) — upper bound at exactly AX5

    func test_silencerB_closedRangeUpperAccessibility5() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").dynamicTypeSize(.xSmall ... .accessibility5)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerB_partialThroughAccessibility5() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").dynamicTypeSize(... .accessibility5)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerB_singleValueAccessibility5() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").dynamicTypeSize(.accessibility5)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Silencer (c) — dynamic / unrecognised argument

    func test_silencerC_variableArgument() {
        let source = """
        import SwiftUI
        struct V: View {
            let upper: DynamicTypeSize = .accessibility5
            var body: some View {
                Text("hi").dynamicTypeSize(upper)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerC_functionCallArgument() {
        let source = """
        import SwiftUI
        struct V: View {
            func computed() -> DynamicTypeSize { .accessibility5 }
            var body: some View {
                Text("hi").dynamicTypeSize(computed())
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Silencer (d) — per-line disable

    func test_silencerD_swiftlintDisableThisComment() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").dynamicTypeSize(.large) // swiftlint:disable:this dynamic_type_clamp_below_ax5
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerD_dynamicTypeOKMarker() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Text("hi").dynamicTypeSize(.large) // DYNAMIC_TYPE_OK: numeric tick label, layout audited
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - True negatives — no .dynamicTypeSize modifier

    func test_trueNegative_environmentReadOnly() {
        // `@Environment(\.dynamicTypeSize)` is a property wrapper read,
        // not a modifier call — rule silent.
        let source = """
        import SwiftUI
        struct V: View {
            @Environment(\\.dynamicTypeSize) private var dynamicTypeSize
            var body: some View {
                Text("\\(dynamicTypeSize.isAccessibilitySize ? 1 : 0)")
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
                Text("hi").dynamicTypeSize(.large)
            }
        }
        """
        let result = violations(source)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.ruleID, "dynamic_type_clamp_below_ax5")
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
            "app/Sources must be dynamic-type-clamp-clean; got: " +
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
