import Foundation
import SwiftSyntax
import SwiftParser

/// SwiftSyntax AST rule `missing_min_touch_target`
/// (WI-L32-TOUCH-TARGET-AST; mirrors the WI-L32 Iris AST batch style).
///
/// Fires on SwiftUI interactive surfaces whose declared touch-target floor
/// is missing or undersized for the HIG 44×44pt minimum:
///   - `Button`, `NavigationLink`, `Link`
///   - `.onTapGesture { ... }` applied to any view
///
/// ### Acceptable floors
///   (a) `.frame(minWidth: ..., minHeight: ...)` / `.frame(width: ..., height: ...)`
///       with both axes >= 44pt (or identifier-backed / computed expressions).
///   (b) `.frame(maxWidth: .infinity, minHeight: ...)` — common full-row SwiftUI
///       control shape.
///   (c) Textual controls (string-title Button/NavigationLink/Link, or label trees
///       containing `Text` / `Label`) with an explicit >=44pt height floor. This
///       covers full-width list rows and text-bearing controls whose intrinsic width
///       already exceeds the HIG floor.
///
/// `.contentShape(...)` is NOT a silencer by itself; it only helps once an adequate
/// width/height floor exists.
///
/// ### Silencers (do NOT fire)
///   (a) Per-line disable marker on the same source line or the immediately
///       preceding line:
///       `// swiftlint:disable:this missing_min_touch_target`
///       `// swiftlint:disable:next missing_min_touch_target`
///       `// MISSING_MIN_TOUCH_TARGET_OK: …`
public struct MissingMinTouchTargetRule: Sendable {
    public static let id = "missing_min_touch_target"

    public init() {}

    public func violations(in source: String) -> [Violation] {
        let tree = Parser.parse(source: source)
        let locator = SourceLocationConverter(fileName: "<input>", tree: tree)
        let sourceLines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let visitor = MissingMinTouchTargetVisitor(locator: locator, sourceLines: sourceLines)
        visitor.walk(tree)
        return visitor.violations
    }
}

private let touchTargetConstructorNames: Set<String> = [
    "Button", "NavigationLink", "Link"
]

private final class MissingMinTouchTargetVisitor: SyntaxVisitor {
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
           touchTargetConstructorNames.contains(ref.baseName.text) {
            evaluateInteractive(node, textual: isTextualConstructor(node))
            return .visitChildren
        }

        if let member = node.calledExpression.as(MemberAccessExprSyntax.self),
           member.declName.baseName.text == "onTapGesture" {
            let textual = member.base.map { containsTextualView(in: Syntax($0)) } ?? false
            let extraRoots = member.base.map { [Syntax($0)] } ?? []
            evaluateInteractive(node, textual: textual, extraRoots: extraRoots)
            return .visitChildren
        }

        return .visitChildren
    }

    private func evaluateInteractive(
        _ node: FunctionCallExprSyntax,
        textual: Bool,
        extraRoots: [Syntax] = []
    ) {
        let loc = node.startLocation(converter: locator)
        if hasDisableComment(atLine: loc.line) {
            return
        }

        var roots: [Syntax] = [Syntax(node)]
        roots.append(contentsOf: extraRoots)
        roots.append(contentsOf: labelRootExpressions(of: node))

        if roots.contains(where: { declaredTouchFloor(startingAt: $0, textual: textual) }) {
            return
        }

        violations.append(
            Violation(
                ruleID: MissingMinTouchTargetRule.id,
                message: "HIG: tappable controls need a declared 44×44pt floor (`frame(minWidth:minHeight:)`, `frame(width:height:)`, or a textual/full-width variant with explicit >=44pt height).",
                line: loc.line,
                column: loc.column
            )
        )
    }

    private func labelRootExpressions(of node: FunctionCallExprSyntax) -> [Syntax] {
        var roots: [Syntax] = []
        for closure in labelClosures(of: node) {
            for statement in closure.statements {
                if let expr = statement.item.as(ExprSyntax.self) {
                    roots.append(Syntax(expr))
                }
            }
        }
        return roots
    }

    private func labelClosures(of node: FunctionCallExprSyntax) -> [ClosureExprSyntax] {
        guard let ref = node.calledExpression.as(DeclReferenceExprSyntax.self) else {
            return []
        }
        let interestedLabel: String
        switch ref.baseName.text {
        case "Button", "NavigationLink", "Link":
            interestedLabel = "label"
        default:
            return []
        }

        var closures: [ClosureExprSyntax] = []
        for arg in node.arguments {
            if arg.label?.text == interestedLabel,
               let closure = arg.expression.as(ClosureExprSyntax.self) {
                closures.append(closure)
            }
        }
        for additional in node.additionalTrailingClosures where additional.label.text == interestedLabel {
            closures.append(additional.closure)
        }
        if (ref.baseName.text == "NavigationLink" || ref.baseName.text == "Link"),
           node.additionalTrailingClosures.isEmpty,
           let trailing = node.trailingClosure {
            closures.append(trailing)
        }
        if ref.baseName.text == "Button",
           node.additionalTrailingClosures.isEmpty,
           node.arguments.contains(where: { $0.label?.text == "action" }),
           let trailing = node.trailingClosure {
            closures.append(trailing)
        }
        return closures
    }

    private func isTextualConstructor(_ node: FunctionCallExprSyntax) -> Bool {
        if let first = node.arguments.first,
           first.label == nil,
           first.expression.is(StringLiteralExprSyntax.self) {
            return true
        }
        for root in labelRootExpressions(of: node) where containsTextualView(in: root) {
            return true
        }
        return false
    }

    private func containsTextualView(in syntax: Syntax) -> Bool {
        let visitor = TextualViewDetector()
        visitor.walk(syntax)
        return visitor.found
    }

    private func declaredTouchFloor(startingAt syntax: Syntax, textual: Bool) -> Bool {
        let evidence = collectFrameEvidence(startingAt: syntax)
        let widthSatisfied = evidence.hasAdequateWidth || evidence.hasMaxWidthInfinity
        let heightSatisfied = evidence.hasAdequateHeight || evidence.hasMaxHeightInfinity

        if widthSatisfied && heightSatisfied {
            return true
        }
        if textual && heightSatisfied && !evidence.hasUndersizedWidth {
            return true
        }
        return false
    }

    private func collectFrameEvidence(startingAt syntax: Syntax) -> FrameEvidence {
        var evidence = FrameEvidence()

        if let expr = syntax.as(ExprSyntax.self) {
            var current: ExprSyntax? = expr
            while let call = current?.as(FunctionCallExprSyntax.self) {
                if let member = call.calledExpression.as(MemberAccessExprSyntax.self),
                   member.declName.baseName.text == "frame" {
                    evidence.absorb(frameEvidence(of: call))
                }
                if let member = call.calledExpression.as(MemberAccessExprSyntax.self),
                   let base = member.base {
                    current = base
                } else {
                    break
                }
            }
        }

        var current = syntax
        while let parent = current.parent {
            guard
                let member = parent.as(MemberAccessExprSyntax.self),
                let base = member.base,
                base.id == current.id,
                let call = parent.parent?.as(FunctionCallExprSyntax.self),
                call.calledExpression.id == Syntax(member).id
            else {
                break
            }
            if member.declName.baseName.text == "frame" {
                evidence.absorb(frameEvidence(of: call))
            }
            current = Syntax(call)
        }
        return evidence
    }

    private func frameEvidence(of call: FunctionCallExprSyntax) -> FrameEvidence {
        var evidence = FrameEvidence()
        for arg in call.arguments {
            guard let label = arg.label?.text else {
                continue
            }
            switch label {
            case "width", "minWidth":
                if isAdequateDimension(arg.expression) {
                    evidence.hasAdequateWidth = true
                } else if isExplicitNumericDimension(arg.expression) {
                    evidence.hasUndersizedWidth = true
                }
            case "height", "minHeight":
                if isAdequateDimension(arg.expression) {
                    evidence.hasAdequateHeight = true
                } else if isExplicitNumericDimension(arg.expression) {
                    evidence.hasUndersizedHeight = true
                }
            case "maxWidth":
                if isInfinity(arg.expression) {
                    evidence.hasMaxWidthInfinity = true
                }
            case "maxHeight":
                if isInfinity(arg.expression) {
                    evidence.hasMaxHeightInfinity = true
                }
            default:
                break
            }
        }
        return evidence
    }

    private func isAdequateDimension(_ expr: ExprSyntax) -> Bool {
        if let value = numericLiteralValue(expr) {
            return value >= 44
        }
        return !isExplicitNumericDimension(expr)
    }

    private func isExplicitNumericDimension(_ expr: ExprSyntax) -> Bool {
        numericLiteralValue(expr) != nil
    }

    private func numericLiteralValue(_ expr: ExprSyntax) -> Double? {
        if let integer = expr.as(IntegerLiteralExprSyntax.self) {
            return Double(integer.literal.text)
        }
        if let float = expr.as(FloatLiteralExprSyntax.self) {
            return Double(float.literal.text)
        }
        if let prefix = expr.as(PrefixOperatorExprSyntax.self),
           let value = numericLiteralValue(prefix.expression) {
            return prefix.operator.text == "-" ? -value : value
        }
        return nil
    }

    private func isInfinity(_ expr: ExprSyntax) -> Bool {
        if let member = expr.as(MemberAccessExprSyntax.self),
           member.declName.baseName.text == "infinity" {
            return true
        }
        return false
    }

    private func hasDisableComment(atLine line: Int) -> Bool {
        if line >= 1, line <= sourceLines.count {
            let text = sourceLines[line - 1]
            if text.contains("swiftlint:disable:this \(MissingMinTouchTargetRule.id)") {
                return true
            }
            if text.contains("MISSING_MIN_TOUCH_TARGET_OK") {
                return true
            }
        }
        if line > 1, line - 2 < sourceLines.count {
            let text = sourceLines[line - 2]
            if text.contains("swiftlint:disable:next \(MissingMinTouchTargetRule.id)") {
                return true
            }
            if text.contains("MISSING_MIN_TOUCH_TARGET_OK") {
                return true
            }
        }
        return false
    }
}

private struct FrameEvidence {
    var hasAdequateWidth = false
    var hasAdequateHeight = false
    var hasMaxWidthInfinity = false
    var hasMaxHeightInfinity = false
    var hasUndersizedWidth = false
    var hasUndersizedHeight = false

    mutating func absorb(_ other: FrameEvidence) {
        hasAdequateWidth = hasAdequateWidth || other.hasAdequateWidth
        hasAdequateHeight = hasAdequateHeight || other.hasAdequateHeight
        hasMaxWidthInfinity = hasMaxWidthInfinity || other.hasMaxWidthInfinity
        hasMaxHeightInfinity = hasMaxHeightInfinity || other.hasMaxHeightInfinity
        hasUndersizedWidth = hasUndersizedWidth || other.hasUndersizedWidth
        hasUndersizedHeight = hasUndersizedHeight || other.hasUndersizedHeight
    }
}

private final class TextualViewDetector: SyntaxVisitor {
    var found = false

    init() {
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let ref = node.calledExpression.as(DeclReferenceExprSyntax.self) else {
            return .visitChildren
        }
        if ref.baseName.text == "Text" || ref.baseName.text == "Label" {
            found = true
            return .skipChildren
        }
        return .visitChildren
    }
}
