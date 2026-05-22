import Foundation
import SwiftSyntax
import SwiftParser

/// SwiftSyntax AST rule `reduce_motion_unguarded_animation`
/// (WI-loop31-1, ADR-0003 §Rollout — Iris HIG catalog Batch-1 rule #1,
/// Critical/M).
///
/// Fires on SwiftUI animation expressions that would visibly move,
/// scale, or rotate content without honoring
/// `@Environment(\.accessibilityReduceMotion)`. Authors with Reduce
/// Motion enabled receive an explicit Apple HIG (Accessibility →
/// Motion) commitment that vestibular-triggering motion is suppressed.
///
/// ### Detection points
///   1. `.animation(...)` view modifier where the animation argument
///      is not `nil` and is not gated on a reduceMotion identifier.
///   2. `withAnimation { ... }` calls that are not gated on a
///      reduceMotion identifier (either via the first-argument
///      expression, or by lexically living inside an `if`/`guard`
///      whose condition references a reduceMotion identifier).
///   3. `.contentTransition(...)` view modifier whose argument is not
///      `.identity` and not gated on a reduceMotion identifier.
///   4. `.transition(...)` view modifier with a motion transition
///      (`.slide`, `.move(edge:)`, `.scale`, ...) that is not gated.
///      `.opacity` and `.identity` are allowed (Apple HIG: opacity-
///      only transitions are considered low-motion).
///
/// ### Silencers (do NOT fire)
///   (a) The argument expression's subtree contains a reduceMotion
///       identifier anywhere — covers ternaries (which SwiftSyntax
///       leaves as un-folded `SequenceExpr` pre operator-folding),
///       conditional helpers, or guarded local bindings. E.g.
///       `.animation(reduceMotion ? nil : .spring(), value: x)`.
///   (b) Expression is lexically inside an `if` / `guard` whose
///       condition references a reduceMotion identifier — covers the
///       production `if accessibilityReduceMotion { plain } else
///       { animated }` shape used at AppViews.swift:1000-1004 and
///       :1855-1864.
///   (c) Argument is literally `nil` (animation/withAnimation),
///       `.identity` (transition/contentTransition), `.opacity`
///       (transition only), or a plain identifier
///       (`.transition(expandTransition)`) deferred to a computed
///       property that itself ternaries on reduceMotion. The plain-
///       identifier carve-out mirrors the
///       ForecastPickerView.swift:338/341 production pattern.
///   (d) A per-line marker comment is present on the same source
///       line:
///       `// swiftlint:disable:this reduce_motion_unguarded_animation`
///       OR `// REDUCE_MOTION_OK: …` (free-form rationale after the
///       colon is encouraged).
///
/// ### Identifier matching for silencers (a)/(b)
///   An identifier counts as a reduceMotion identifier when its name,
///   lowercased, contains `reducemotion` or `reducedmotion`. This
///   covers `reduceMotion`, `accessibilityReduceMotion`, and
///   `prefersReducedMotion`. Intentionally lenient — to be tightened
///   in v2 if Iris's catalog review surfaces a false-negative
///   pattern.
public struct ReduceMotionUnguardedAnimationRule: Sendable {
    public static let id = "reduce_motion_unguarded_animation"

    public init() {}

    public func violations(in source: String) -> [Violation] {
        let tree = Parser.parse(source: source)
        let locator = SourceLocationConverter(fileName: "<input>", tree: tree)
        let sourceLines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let visitor = ReduceMotionVisitor(locator: locator, sourceLines: sourceLines)
        visitor.walk(tree)
        return visitor.violations
    }
}

private enum AnimationCallKind {
    case withAnimation
    case animation
    case contentTransition
    case transition
}

private final class ReduceMotionVisitor: SyntaxVisitor {
    let locator: SourceLocationConverter
    let sourceLines: [String]
    var violations: [Violation] = []

    init(locator: SourceLocationConverter, sourceLines: [String]) {
        self.locator = locator
        self.sourceLines = sourceLines
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let kind = classify(node) else {
            return .visitChildren
        }
        evaluate(node, kind: kind)
        return .visitChildren
    }

    // MARK: - Classification

    private func classify(_ node: FunctionCallExprSyntax) -> AnimationCallKind? {
        if let ref = node.calledExpression.as(DeclReferenceExprSyntax.self),
           ref.baseName.text == "withAnimation" {
            return .withAnimation
        }
        if let member = node.calledExpression.as(MemberAccessExprSyntax.self) {
            switch member.declName.baseName.text {
            case "animation":         return .animation
            case "contentTransition": return .contentTransition
            case "transition":        return .transition
            default:                  return nil
            }
        }
        return nil
    }

    // MARK: - Evaluation

    private func evaluate(_ node: FunctionCallExprSyntax, kind: AnimationCallKind) {
        let firstArg = node.arguments.first?.expression

        if let firstArg = firstArg, isArgumentSilenced(firstArg, kind: kind) {
            return
        }

        if hasReduceMotionGuardAncestor(node) {
            return
        }

        let loc = node.startLocation(converter: locator)
        if hasDisableComment(atLine: loc.line) {
            return
        }

        let message: String
        switch kind {
        case .withAnimation:
            message = "HIG/Accessibility (Reduce Motion): `withAnimation { … }` must be gated on `accessibilityReduceMotion` (use a ternary, `if !reduceMotion`, or `// REDUCE_MOTION_OK:` if intentional)."
        case .animation:
            message = "HIG/Accessibility (Reduce Motion): `.animation(...)` must pass `nil` under `reduceMotion` (use `reduceMotion ? nil : <animation>` or an `if reduceMotion / else` branch)."
        case .contentTransition:
            message = "HIG/Accessibility (Reduce Motion): `.contentTransition(...)` must use `.identity` (or be gated on `reduceMotion`) when Reduce Motion is on."
        case .transition:
            message = "HIG/Accessibility (Reduce Motion): `.transition(...)` with a motion transition must collapse to `.identity` (or `.opacity`) under `reduceMotion`."
        }

        violations.append(
            Violation(
                ruleID: ReduceMotionUnguardedAnimationRule.id,
                message: message,
                line: loc.line,
                column: loc.column
            )
        )
    }

    // MARK: - Argument silencers

    private func isArgumentSilenced(_ expr: ExprSyntax, kind: AnimationCallKind) -> Bool {
        if expr.is(NilLiteralExprSyntax.self) {
            return true
        }

        // Silencer (a): a reduceMotion identifier appears anywhere in
        // the argument subtree — covers un-folded ternaries
        // (`SequenceExpr` + `UnresolvedTernaryExpr` pre operator-fold),
        // helper calls, etc. Intentionally lenient per rule doc.
        if containsReduceMotionIdentifier(Syntax(expr)) {
            return true
        }

        if isImplicitMember(expr, named: "identity") {
            return true
        }

        if kind == .transition, isImplicitMember(expr, named: "opacity") {
            return true
        }

        // Plain identifier (e.g. `.transition(expandTransition)`) for
        // transition / contentTransition — deferred to author's
        // computed property.
        if (kind == .transition || kind == .contentTransition),
           expr.is(DeclReferenceExprSyntax.self) {
            return true
        }

        return false
    }

    /// True if `expr` is an implicit-member access of the given name,
    /// either bare (`.identity`) or as a function call (`.identity()`).
    private func isImplicitMember(_ expr: ExprSyntax, named name: String) -> Bool {
        if let member = expr.as(MemberAccessExprSyntax.self),
           member.base == nil,
           member.declName.baseName.text == name {
            return true
        }
        if let call = expr.as(FunctionCallExprSyntax.self),
           let member = call.calledExpression.as(MemberAccessExprSyntax.self),
           member.base == nil,
           member.declName.baseName.text == name {
            return true
        }
        return false
    }

    // MARK: - Ancestor silencer (b)

    private func hasReduceMotionGuardAncestor(_ node: FunctionCallExprSyntax) -> Bool {
        var current: Syntax? = Syntax(node).parent
        while let n = current {
            if let ifExpr = n.as(IfExprSyntax.self),
               containsReduceMotionIdentifier(Syntax(ifExpr.conditions)) {
                return true
            }
            if let guardStmt = n.as(GuardStmtSyntax.self),
               containsReduceMotionIdentifier(Syntax(guardStmt.conditions)) {
                return true
            }
            current = n.parent
        }
        return false
    }

    /// Recursive token-scan: does any token in this subtree have an
    /// identifier name containing `reducemotion` / `reducedmotion`
    /// (case-insensitive)?
    private func containsReduceMotionIdentifier(_ syntax: Syntax) -> Bool {
        for token in syntax.tokens(viewMode: .sourceAccurate) {
            let lowered = token.text.lowercased()
            if lowered.contains("reducemotion") || lowered.contains("reducedmotion") {
                return true
            }
        }
        return false
    }

    // MARK: - Comment silencer (d)

    private func hasDisableComment(atLine line: Int) -> Bool {
        guard line >= 1, line <= sourceLines.count else {
            return false
        }
        let text = sourceLines[line - 1]
        if text.contains("swiftlint:disable:this \(ReduceMotionUnguardedAnimationRule.id)") {
            return true
        }
        if text.contains("REDUCE_MOTION_OK") {
            return true
        }
        return false
    }
}
