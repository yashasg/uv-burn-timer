import Foundation
import SwiftSyntax
import SwiftParser

/// A single violation reported by an AST rule.
public struct Violation: Equatable, Sendable {
    public let ruleID: String
    public let message: String
    public let line: Int
    public let column: Int

    public init(ruleID: String, message: String, line: Int, column: Int) {
        self.ruleID = ruleID
        self.message = message
        self.line = line
        self.column = column
    }
}

/// SwiftSyntax port of the regex SwiftLint rule
/// `toolbar_image_needs_scaled_frame` (Group LY).
///
/// Fires on any `Image(...)` call lexically inside a `.toolbar { ... }`
/// trailing closure whose ascending modifier chain contains neither
/// `.frame(...)` (with any width/height/minWidth/minHeight arg) nor
/// `.imageScale(...)`. Walks the parent chain in the AST — no fixed
/// character window — so the regex's 2000-char balanced-brace fragility
/// (ADR-0003 §Context bullet 1) is eliminated.
public struct ToolbarImageNeedsScaledFrameRule: Sendable {
    public static let id = "toolbar_image_needs_scaled_frame"

    public init() {}

    public func violations(in source: String) -> [Violation] {
        let tree = Parser.parse(source: source)
        let locator = SourceLocationConverter(fileName: "<input>", tree: tree)
        let visitor = Visitor(locator: locator)
        visitor.walk(tree)
        return visitor.violations
    }
}

private final class Visitor: SyntaxVisitor {
    let locator: SourceLocationConverter
    var violations: [Violation] = []

    /// Stack of ClosureExpr identities that are the trailing/argument
    /// closure of a `.toolbar { … }` call. We treat an Image as in-toolbar
    /// iff at least one ancestor closure on this stack is one of these.
    private var toolbarClosureIDs: Set<SyntaxIdentifier> = []

    init(locator: SourceLocationConverter) {
        self.locator = locator
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        // Detect `.toolbar { … }` or `.toolbar(content: { … })` — mark
        // every closure argument as a toolbar scope.
        if isToolbarCall(node) {
            for closure in toolbarClosures(of: node) {
                toolbarClosureIDs.insert(closure.id)
            }
        }

        // Detect `Image(...)` calls and report if inside a toolbar scope
        // and unmitigated by a frame/imageScale modifier in the chain.
        if isImageCall(node), isInsideToolbar(node), !hasMitigatingModifier(node) {
            let loc = node.startLocation(converter: locator)
            violations.append(
                Violation(
                    ruleID: ToolbarImageNeedsScaledFrameRule.id,
                    message: "HIG: toolbar Image labels need a `.frame(...)` floor or `.imageScale(...)` modifier.",
                    line: loc.line,
                    column: loc.column
                )
            )
        }

        return .visitChildren
    }

    override func visitPost(_ node: FunctionCallExprSyntax) {
        if isToolbarCall(node) {
            for closure in toolbarClosures(of: node) {
                toolbarClosureIDs.remove(closure.id)
            }
        }
    }

    // MARK: - Predicates

    private func isToolbarCall(_ node: FunctionCallExprSyntax) -> Bool {
        guard let member = node.calledExpression.as(MemberAccessExprSyntax.self) else {
            return false
        }
        return member.declName.baseName.text == "toolbar"
    }

    private func toolbarClosures(of node: FunctionCallExprSyntax) -> [ClosureExprSyntax] {
        var closures: [ClosureExprSyntax] = []
        if let trailing = node.trailingClosure {
            closures.append(trailing)
        }
        for additional in node.additionalTrailingClosures {
            closures.append(additional.closure)
        }
        // Paren-form: `.toolbar(content: { … })`
        for arg in node.arguments {
            if let closure = arg.expression.as(ClosureExprSyntax.self) {
                closures.append(closure)
            }
        }
        return closures
    }

    private func isImageCall(_ node: FunctionCallExprSyntax) -> Bool {
        // Bare `Image(...)` — DeclReferenceExpr with baseName "Image".
        // Excludes `.imageScale(...)`, `SomeView.Image(...)` (unlikely).
        if let ref = node.calledExpression.as(DeclReferenceExprSyntax.self),
           ref.baseName.text == "Image" {
            return true
        }
        return false
    }

    private func isInsideToolbar(_ node: FunctionCallExprSyntax) -> Bool {
        var current: Syntax? = Syntax(node).parent
        while let n = current {
            if let closure = n.as(ClosureExprSyntax.self),
               toolbarClosureIDs.contains(closure.id) {
                return true
            }
            current = n.parent
        }
        return false
    }

    /// Walk up the post-call modifier chain applied to this Image call.
    /// Returns true if any modifier in the chain is `.frame(...)` with at
    /// least one width-ish argument, or `.imageScale(...)`.
    private func hasMitigatingModifier(_ imageCall: FunctionCallExprSyntax) -> Bool {
        var current: Syntax = Syntax(imageCall)
        while let parent = current.parent {
            guard
                let member = parent.as(MemberAccessExprSyntax.self),
                let base = member.base,
                base.id == current.id,
                let grandparent = parent.parent?.as(FunctionCallExprSyntax.self),
                grandparent.calledExpression.id == Syntax(member).id
            else {
                break
            }
            let name = member.declName.baseName.text
            if name == "imageScale" {
                return true
            }
            if name == "frame", hasSizingArgument(grandparent) {
                return true
            }
            current = Syntax(grandparent)
        }
        return false
    }

    private func hasSizingArgument(_ call: FunctionCallExprSyntax) -> Bool {
        let sizingLabels: Set<String> = [
            "width", "height", "minWidth", "minHeight", "maxWidth", "maxHeight"
        ]
        for arg in call.arguments {
            if let label = arg.label?.text, sizingLabels.contains(label) {
                return true
            }
        }
        return false
    }
}
