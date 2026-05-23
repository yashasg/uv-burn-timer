import Foundation
import SwiftSyntax
import SwiftParser

/// SwiftSyntax AST rule `color_only_meaning_signal`
/// (WI-L32-IRIS-AST-BATCH2 rule #1).
///
/// Fires on a `.foregroundStyle(...)` / `.foregroundColor(...)` /
/// `.tint(...)` modifier whose underlying receiver chain ends at a
/// primitive SwiftUI Shape leaf — `Circle()`, `Rectangle()`,
/// `RoundedRectangle(...)`, `Capsule()`, `Ellipse()` — and whose
/// ancestor modifier chain carries no `.accessibilityLabel(...)`,
/// `.accessibilityHidden(true)`, `.accessibilityElement(...)`, or
/// `.accessibilityValue(...)` silencer. HIG (Accessibility → Color
/// & Effects): never convey state with color alone — a red dot with
/// no SF Symbol, text label, or accessibility label is invisible to
/// VoiceOver users and to users with Differentiate Without Color
/// enabled.
///
/// ### Silencers (do NOT fire)
///   (a) Any ancestor modifier-call on the parent chain whose name
///       is one of: `accessibilityLabel`, `accessibilityHidden`
///       (when argument is anything other than literal `false`),
///       `accessibilityElement`, `accessibilityValue`.
///   (b) Per-line disable marker on the same source line:
///       `// swiftlint:disable:this color_only_meaning_signal`
///       OR `// COLOR_ONLY_OK: …`.
///
/// ### Non-silencers (intentional, per Iris HIG catalog stance)
///   Sibling `Text`/`Label`/`Image(systemName:)` adjacency in the
///   same view-builder block is NOT a silencer (mirrors the
///   WI-loop30-4b decision for the image_systemname rule).
public struct ColorOnlyMeaningSignalRule: Sendable {
    public static let id = "color_only_meaning_signal"

    public init() {}

    public func violations(in source: String) -> [Violation] {
        let tree = Parser.parse(source: source)
        let locator = SourceLocationConverter(fileName: "<input>", tree: tree)
        let sourceLines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let visitor = ColorOnlyMeaningSignalVisitor(locator: locator, sourceLines: sourceLines)
        visitor.walk(tree)
        return visitor.violations
    }
}

private let shapeLeafNames: Set<String> = [
    "Circle", "Rectangle", "RoundedRectangle", "Capsule", "Ellipse"
]

private let colorModifierNames: Set<String> = [
    "foregroundStyle", "foregroundColor", "tint"
]

private let accessibilitySilencerNames: Set<String> = [
    "accessibilityLabel", "accessibilityElement", "accessibilityValue"
]

private final class ColorOnlyMeaningSignalVisitor: SyntaxVisitor {
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
            colorModifierNames.contains(member.declName.baseName.text),
            let base = member.base,
            receiverChainEndsAtShape(base)
        else {
            return .visitChildren
        }

        if hasAccessibilitySilencerInChain(node) {
            return .visitChildren
        }

        let loc = node.startLocation(converter: locator)
        if hasDisableComment(atLine: loc.line) {
            return .visitChildren
        }

        violations.append(
            Violation(
                ruleID: ColorOnlyMeaningSignalRule.id,
                message: "HIG/Accessibility (Color & Effects): \(member.declName.baseName.text)(...) on a bare primitive Shape conveys meaning by color alone. Add `.accessibilityLabel(...)`, `.accessibilityHidden(true)`, or pair the shape with an SF Symbol / Text label inside `.accessibilityElement(children: .combine)`.",
                line: loc.line,
                column: loc.column
            )
        )
        return .visitChildren
    }

    // MARK: - Receiver chain ends at a primitive Shape leaf?

    private func receiverChainEndsAtShape(_ expr: ExprSyntax) -> Bool {
        var current: ExprSyntax = expr
        while true {
            guard let call = current.as(FunctionCallExprSyntax.self) else {
                return false
            }
            if let ref = call.calledExpression.as(DeclReferenceExprSyntax.self) {
                return shapeLeafNames.contains(ref.baseName.text)
            }
            if let inner = call.calledExpression.as(MemberAccessExprSyntax.self),
               let innerBase = inner.base {
                current = innerBase
                continue
            }
            return false
        }
    }

    // MARK: - Ancestor silencer scan

    private func hasAccessibilitySilencerInChain(_ node: FunctionCallExprSyntax) -> Bool {
        var current: Syntax? = Syntax(node).parent
        while let n = current {
            if let call = n.as(FunctionCallExprSyntax.self),
               let member = call.calledExpression.as(MemberAccessExprSyntax.self) {
                let name = member.declName.baseName.text
                if accessibilitySilencerNames.contains(name) {
                    return true
                }
                if name == "accessibilityHidden",
                   !isAccessibilityHiddenExplicitlyFalse(call) {
                    return true
                }
            }
            current = n.parent
        }
        return false
    }

    private func isAccessibilityHiddenExplicitlyFalse(_ call: FunctionCallExprSyntax) -> Bool {
        guard
            let firstArg = call.arguments.first,
            let bool = firstArg.expression.as(BooleanLiteralExprSyntax.self)
        else {
            return false
        }
        return bool.literal.text == "false"
    }

    // MARK: - Per-line disable comment

    private func hasDisableComment(atLine line: Int) -> Bool {
        guard line >= 1, line <= sourceLines.count else {
            return false
        }
        let text = sourceLines[line - 1]
        if text.contains("swiftlint:disable:this \(ColorOnlyMeaningSignalRule.id)") {
            return true
        }
        if text.contains("COLOR_ONLY_OK") {
            return true
        }
        return false
    }
}
