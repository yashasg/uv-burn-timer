import XCTest
@testable import SwiftLintASTRules

// TDD tests for `interactive_inside_ignores_safe_area`
// (WI-L32-IRIS-AST-BATCH2 rule #2).
//
// Rule fires on Button / NavigationLink / Link / `.onTapGesture` placed
// lexically inside an ancestor whose modifier chain calls
// `.ignoresSafeArea(...)` without a restoring `.safeAreaPadding(...)`,
// `.safeAreaInset(...)`, or `.padding(...)` on the path.
//
// Silencers tested below:
//   (a) `.safeAreaPadding`, `.safeAreaInset`, or `.padding` on any
//       ancestor modifier-call (either side of the ignoresSafeArea).
//   (b) Per-line disable marker.

final class InteractiveInsideIgnoresSafeAreaRuleTests: XCTestCase {

    private func violations(_ source: String) -> [Violation] {
        InteractiveInsideIgnoresSafeAreaRule().violations(in: source)
    }

    // MARK: - True positives

    func test_truePositive_buttonInsideIgnoresSafeArea() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                VStack {
                    Button("Tap") { }
                }
                .ignoresSafeArea()
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_buttonInsideIgnoresSafeAreaWithEdgesArg() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                ZStack {
                    Button("Tap") { }
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_navigationLinkInsideIgnoresSafeArea() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                VStack {
                    NavigationLink("Open", destination: Text("d"))
                }
                .ignoresSafeArea()
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_linkInsideIgnoresSafeArea() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                VStack {
                    Link("Open", destination: URL(string: "https://example.com")!)
                }
                .ignoresSafeArea()
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    func test_truePositive_onTapGestureInsideIgnoresSafeArea() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                VStack {
                    Text("Tap me").onTapGesture { }
                }
                .ignoresSafeArea()
            }
        }
        """
        XCTAssertEqual(violations(source).count, 1)
    }

    // MARK: - Silencer (a) — restoring modifier on chain

    func test_silencerA_safeAreaPaddingOutsideIgnoresSafeArea() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                VStack {
                    Button("Tap") { }
                }
                .ignoresSafeArea()
                .safeAreaPadding(.bottom, 24)
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerA_safeAreaInsetOutsideIgnoresSafeArea() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                VStack {
                    Button("Tap") { }
                }
                .ignoresSafeArea()
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 24) }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerA_perButtonPaddingInsideIgnoresSafeArea() {
        // Padding sits between Button and the ignoresSafeArea ancestor.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                VStack {
                    Button("Tap") { }.padding(.bottom, 24)
                }
                .ignoresSafeArea()
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - Silencer (b) — per-line disable

    func test_silencerB_swiftlintDisableThisComment() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                VStack {
                    Button("Tap") { } // swiftlint:disable:this interactive_inside_ignores_safe_area
                }
                .ignoresSafeArea()
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_silencerB_safeAreaOKMarker() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                VStack {
                    Button("Tap") { } // SAFE_AREA_OK: full-bleed onboarding CTA verified on iPhone SE
                }
                .ignoresSafeArea()
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    // MARK: - True negatives — no ignoresSafeArea anywhere

    func test_trueNegative_buttonWithoutIgnoresSafeArea() {
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                VStack {
                    Button("Tap") { }
                }
            }
        }
        """
        XCTAssertEqual(violations(source).count, 0)
    }

    func test_trueNegative_ignoresSafeAreaWithoutInteractive() {
        // Background art extends to edge — no interactive inside.
        let source = """
        import SwiftUI
        struct V: View {
            var body: some View {
                Color.blue.ignoresSafeArea()
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
                VStack {
                    Button("Tap") { }
                }
                .ignoresSafeArea()
            }
        }
        """
        let result = violations(source)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.ruleID, "interactive_inside_ignores_safe_area")
        XCTAssertEqual(result.first?.line, 5)
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
            "app/Sources must be safe-area-clean for interactive elements; got: " +
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
