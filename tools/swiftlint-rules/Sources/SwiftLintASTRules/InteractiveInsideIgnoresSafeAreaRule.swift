import Foundation
import SwiftSyntax
import SwiftParser

/// SwiftSyntax AST rule `interactive_inside_ignores_safe_area`
/// (WI-L32-IRIS-AST-BATCH2 rule #2).
///
/// Fires on Button / NavigationLink / Link / `.onTapGesture` placed
/// lexically inside an ancestor whose modifier chain calls
/// `.ignoresSafeArea(...)` without a restoring `.safeAreaPadding(...)`,
/// `.safeAreaInset(...)`, or `.padding(...)` on the path between the
/// interactive element and the file root.
///
/// HIG (Layout → Safe Areas, Inputs → Tap Targets): interactive
/// targets must respect the device's safe area so home-indicator /
/// notch / rotation-bar regions don't swallow taps. Extending
/// background art to the edge is fine; extending a tap target to the
/// edge is not.
///
/// ### Silencers (do NOT fire)
///   (a) Any of `.safeAreaPadding(...)`, `.safeAreaInset(...)`, or
///       `.padding(...)` appears on the ancestor modifier chain
///       (either side of the `.ignoresSafeArea`).
///   (b) Per-line disable marker:
///       `// swiftlint:disable:this interactive_inside_ignores_safe_area`
///       OR `// SAFE_AREA_OK: …`.
public struct InteractiveInsideIgnoresSafeAreaRule: Sendable {
    public static let id = "interactive_inside_ignores_safe_area"

    public init() {}

    public func violations(in source: String) -> [Violation] {
        let tree = Parser.parse(source: source)
        let locator = SourceLocationConverter(fileName: "<input>", tree: tree)
        let sourceLines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let visitor = InteractiveInsideIgnoresSafeAreaVisitor(locator: locator, sourceLines: sourceLines)
        visitor.walk(tree)
        return visitor.violations
    }
}

private let interactiveConstructorNames: Set<String> = [
    "Button", "NavigationLink", "Link"
]

private let safeAreaRestoringModifiers: Set<String> = [
    "safeAreaPadding", "safeAreaInset", "padding"
]

private final class InteractiveInsideIgnoresSafeAreaVisitor: SyntaxVisitor {
    let locator: SourceLocationConverter
    let sourceLines: [String]
    var violations: [Violation] = []

    init(locator: SourceLocationConverter, sourceLines: [String]) {
        self.locator = locator
        self.sourceLines = sourceLines
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if let ref = node.calledExpression.as(DeclReferenceExprSyntax.self),
           interactiveConstructorNames.contains(ref.baseName.text) {
            evaluate(triggerLocationOf: node)
        }
        if let member = node.calledExpression.as(MemberAccessExprSyntax.self),
           member.declName.baseName.text == "onTapGesture" {
            evaluate(triggerLocationOf: node)
        }
        return .visitChildren
    }

    private func evaluate(triggerLocationOf node: FunctionCallExprSyntax) {
        let scan = scanAncestorModifiers(of: node)
        guard scan.ignoresSafeAreaFound, !scan.restoringFound else {
            return
        }
        let loc = node.startLocation(converter: locator)
        if hasDisableComment(atLine: loc.line) {
            return
        }
        violations.append(
            Violation(
                ruleID: InteractiveInsideIgnoresSafeAreaRule.id,
                message: "HIG (Layout → Safe Areas): interactive target lives inside an `.ignoresSafeArea(...)` region without a restoring `.safeAreaPadding(...)`, `.safeAreaInset(...)`, or `.padding(...)` on the ancestor chain. Tap targets must respect the safe area.",
                line: loc.line,
                column: loc.column
            )
        )
    }

    private struct AncestorScan {
        var ignoresSafeAreaFound: Bool = false
        var restoringFound: Bool = false
    }

    private func scanAncestorModifiers(of node: FunctionCallExprSyntax) -> AncestorScan {
        var result = AncestorScan()
        var current: Syntax? = Syntax(node).parent
        while let n = current {
            if let call = n.as(FunctionCallExprSyntax.self),
               let member = call.calledExpression.as(MemberAccessExprSyntax.self) {
                let name = member.declName.baseName.text
                if name == "ignoresSafeArea" {
                    result.ignoresSafeAreaFound = true
                } else if safeAreaRestoringModifiers.contains(name) {
                    result.restoringFound = true
                }
            }
            current = n.parent
        }
        return result
    }

    private func hasDisableComment(atLine line: Int) -> Bool {
        guard line >= 1, line <= sourceLines.count else { return false }
        let text = sourceLines[line - 1]
        if text.contains("swiftlint:disable:this \(InteractiveInsideIgnoresSafeAreaRule.id)") {
            return true
        }
        if text.contains("SAFE_AREA_OK") { return true }
        return false
    }
}
