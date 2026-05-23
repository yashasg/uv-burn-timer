import Foundation
import SwiftSyntax
import SwiftParser

/// SwiftSyntax AST rule `dynamic_type_clamp_below_ax5`
/// (WI-L32-IRIS-AST-BATCH2 rule #3).
///
/// Fires on a `.dynamicTypeSize(...)` view modifier whose argument
/// expresses an upper bound below `.accessibility5`. HIG
/// (Accessibility → Dynamic Type, iOS 17+): apps must support the
/// full Dynamic Type range up to AX5; clamping below AX5 excludes
/// users who configure their system at AX1–AX5.
///
/// ### Recognized argument shapes
///   Single value:           `.dynamicTypeSize(.large)`  — upper = .large
///   Closed range:           `.dynamicTypeSize(.xSmall ... .xxxLarge)`
///   Partial-through range:  `.dynamicTypeSize(...DynamicTypeSize.accessibility3)`
///   Partial-from range:     `.dynamicTypeSize(.large...)` — unbounded (OK)
///
/// ### Silencers (do NOT fire)
///   (a) Partial-from form (trailing `...` with no upper case).
///   (b) Upper bound is `.accessibility5`.
///   (c) Argument contains no recognizable DynamicTypeSize case
///       (variable, function call, computed expression).
///   (d) Per-line disable marker:
///       `// swiftlint:disable:this dynamic_type_clamp_below_ax5`
///       OR `// DYNAMIC_TYPE_OK: …`.
public struct DynamicTypeClampBelowAX5Rule: Sendable {
    public static let id = "dynamic_type_clamp_below_ax5"

    public init() {}

    public func violations(in source: String) -> [Violation] {
        let tree = Parser.parse(source: source)
        let locator = SourceLocationConverter(fileName: "<input>", tree: tree)
        let sourceLines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let visitor = DynamicTypeClampVisitor(locator: locator, sourceLines: sourceLines)
        visitor.walk(tree)
        return visitor.violations
    }
}

private let dynamicTypeSizeOrder: [String] = [
    "xSmall", "small", "medium", "large", "xLarge", "xxLarge", "xxxLarge",
    "accessibility1", "accessibility2", "accessibility3", "accessibility4", "accessibility5"
]

private let dynamicTypeSizeRank: [String: Int] = {
    var dict: [String: Int] = [:]
    for (i, name) in dynamicTypeSizeOrder.enumerated() { dict[name] = i }
    return dict
}()

private let ax5Rank = dynamicTypeSizeOrder.count - 1 // 11

private final class DynamicTypeClampVisitor: SyntaxVisitor {
    let locator: SourceLocationConverter
    let sourceLines: [String]
    var violations: [Violation] = []

    init(locator: SourceLocationConverter, sourceLines: [String]) {
        self.locator = locator
        self.sourceLines = sourceLines
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard
            let member = node.calledExpression.as(MemberAccessExprSyntax.self),
            member.declName.baseName.text == "dynamicTypeSize",
            let firstArg = node.arguments.first?.expression
        else {
            return .visitChildren
        }

        guard let upper = extractUpperBoundCase(from: Syntax(firstArg)) else {
            return .visitChildren
        }

        guard let rank = dynamicTypeSizeRank[upper], rank < ax5Rank else {
            return .visitChildren
        }

        let loc = node.startLocation(converter: locator)
        if hasDisableComment(atLine: loc.line) {
            return .visitChildren
        }

        violations.append(
            Violation(
                ruleID: DynamicTypeClampBelowAX5Rule.id,
                message: "HIG (Accessibility → Dynamic Type): `.dynamicTypeSize(...)` upper bound `.\(upper)` is below `.accessibility5`. Clamping below AX5 excludes Dynamic Type users — extend the range to `.accessibility5` or remove the clamp.",
                line: loc.line,
                column: loc.column
            )
        )
        return .visitChildren
    }

    /// Returns the unqualified DynamicTypeSize case name of the
    /// argument's upper bound, or nil if the upper is unbounded /
    /// unrecognised.
    private func extractUpperBoundCase(from argument: Syntax) -> String? {
        let tokens = Array(argument.tokens(viewMode: .sourceAccurate))
        guard !tokens.isEmpty else { return nil }

        var lastEllipsisIndex: Int? = nil
        for (i, t) in tokens.enumerated() where t.text == "..." {
            lastEllipsisIndex = i
        }

        if let ellipsisIdx = lastEllipsisIndex {
            // Look for a case identifier after the last `...`.
            var i = ellipsisIdx + 1
            var result: String? = nil
            while i < tokens.count {
                let tok = tokens[i]
                if tok.text == "," { break }
                if i - 1 >= 0,
                   tokens[i - 1].text == ".",
                   dynamicTypeSizeRank[tok.text] != nil {
                    result = tok.text
                }
                i += 1
            }
            return result // nil ⇒ partial-from ⇒ silent
        }

        // No `...`: single value. Find the last case identifier
        // preceded by `.`.
        var single: String? = nil
        for i in 1 ..< tokens.count {
            let tok = tokens[i]
            if tokens[i - 1].text == ".",
               dynamicTypeSizeRank[tok.text] != nil {
                single = tok.text
            }
        }
        return single
    }

    private func hasDisableComment(atLine line: Int) -> Bool {
        guard line >= 1, line <= sourceLines.count else { return false }
        let text = sourceLines[line - 1]
        if text.contains("swiftlint:disable:this \(DynamicTypeClampBelowAX5Rule.id)") {
            return true
        }
        if text.contains("DYNAMIC_TYPE_OK") { return true }
        return false
    }
}
