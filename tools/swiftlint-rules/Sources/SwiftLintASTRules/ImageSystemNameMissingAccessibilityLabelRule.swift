import Foundation
import SwiftSyntax
import SwiftParser

/// SwiftSyntax AST rule `image_systemname_missing_accessibility_label`
/// (WI-loop30-4a + 4b, ADR-0003 §Rollout WI-30-B; design = Iris's
/// Loop-30 iter-2 fixture catalog §P5).
///
/// Fires on any standalone `Image(systemName: …)` call expression that
/// is not labeled for VoiceOver via any of the three structural
/// silencers below:
///
///   (a) Image lives inside the `label:` closure of an interactive
///       ancestor (`Button`, `NavigationLink`, `Link`) — the ancestor
///       supplies the accessibility label for the whole control.
///   (b) Image's own modifier chain (or any ancestor view's modifier
///       chain that the Image lexically sits inside) carries one of
///       `.accessibilityLabel(...)`, `.accessibilityHidden(true)`, or
///       `.accessibilityElement(children: .combine)`. The combine form
///       indicates a parent merges children's semantics under a single
///       label, so the child Image is silent.
///   (c) Image lives inside the `icon:` closure of a
///       `Label { title } icon: { image }` initializer — the Label's
///       title closure supplies the accessibility label. (Note: the
///       sibling form `Label(_:systemImage:)` takes a `String` for
///       `systemImage:`, not an `Image` expression — so it never has
///       an `Image(systemName:)` expression inside it and the rule
///       trivially does not fire.)
///
/// WI-loop30-4b history: an earlier draft of this rule (merged in #119)
/// also exempted Images with a sibling `Text(...)` view in the same
/// view-builder block — silencer "(d)". Iris's catalog §P5 is explicit
/// that sibling adjacency is NOT a labeling relation in SwiftUI's
/// accessibility tree (VoiceOver announces the bare
/// `Image(systemName: "<id>")` symbol-id regardless of an adjacent
/// Text). Silencer (d) was therefore removed; authors of icon-plus-
/// descriptor banners must reach for silencer (b) explicitly
/// (`.accessibilityElement(children: .combine)` + an explicit
/// `.accessibilityLabel(...)` on the parent stack, or
/// `.accessibilityHidden(true)` on the icon).
///
/// The visitor reuses the parent-walking machinery proven out by
/// `ToolbarImageNeedsScaledFrameRule` (the WI-30-B spike rule).
public struct ImageSystemNameMissingAccessibilityLabelRule: Sendable {
    public static let id = "image_systemname_missing_accessibility_label"

    public init() {}

    public func violations(in source: String) -> [Violation] {
        let tree = Parser.parse(source: source)
        let locator = SourceLocationConverter(fileName: "<input>", tree: tree)
        let visitor = ImageSystemNameVisitor(locator: locator)
        visitor.walk(tree)
        return visitor.violations
    }
}

private final class ImageSystemNameVisitor: SyntaxVisitor {
    let locator: SourceLocationConverter
    var violations: [Violation] = []

    /// Closures that are the `label:` / `icon:` providers of an
    /// enclosing labeling container. Any `Image(systemName:)` lexically
    /// inside one of these closures is silent — its label is supplied
    /// by the container.
    private var silentClosureIDs: Set<SyntaxIdentifier> = []

    init(locator: SourceLocationConverter) {
        self.locator = locator
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        for closure in labelingClosures(of: node) {
            silentClosureIDs.insert(closure.id)
        }

        if isImageSystemNameCall(node),
           !isInsideSilentClosure(node),
           !hasAccessibilitySilencerInChain(node) {
            let loc = node.startLocation(converter: locator)
            violations.append(
                Violation(
                    ruleID: ImageSystemNameMissingAccessibilityLabelRule.id,
                    message: "HIG/WCAG 1.1.1: Image(systemName:) needs `.accessibilityLabel(...)`, `.accessibilityHidden(true)`, or an enclosing Label/Button/NavigationLink/Link that supplies the label.",
                    line: loc.line,
                    column: loc.column
                )
            )
        }

        return .visitChildren
    }

    override func visitPost(_ node: FunctionCallExprSyntax) {
        for closure in labelingClosures(of: node) {
            silentClosureIDs.remove(closure.id)
        }
    }

    // MARK: - Predicates

    /// `Image(systemName: ...)` — `Image` DeclReference with at least
    /// one argument labeled `systemName`.
    private func isImageSystemNameCall(_ node: FunctionCallExprSyntax) -> Bool {
        guard
            let ref = node.calledExpression.as(DeclReferenceExprSyntax.self),
            ref.baseName.text == "Image"
        else {
            return false
        }
        for arg in node.arguments where arg.label?.text == "systemName" {
            return true
        }
        return false
    }

    /// Returns the closure arguments of `node` that are the "labeling"
    /// closure of a labeling container — `label:` for Button /
    /// NavigationLink / Link, `icon:` for Label. Trailing-closure rules:
    ///   - Button: `label:` is in `additionalTrailingClosures` (the
    ///     first trailing closure is the unlabeled `action:`).
    ///   - NavigationLink / Link: a single trailing closure binds to
    ///     `label:` (these initializers' trailing parameter is `label`).
    ///     With multiple trailing closures, only the one labeled
    ///     `label:` is the label provider.
    ///   - Label: `icon:` is in `additionalTrailingClosures` (the first
    ///     trailing closure is the unlabeled `title:`).
    private func labelingClosures(of node: FunctionCallExprSyntax) -> [ClosureExprSyntax] {
        guard let ref = node.calledExpression.as(DeclReferenceExprSyntax.self) else {
            return []
        }
        let interestedLabel: String
        switch ref.baseName.text {
        case "Button", "NavigationLink", "Link":
            interestedLabel = "label"
        case "Label":
            interestedLabel = "icon"
        default:
            return []
        }

        var closures: [ClosureExprSyntax] = []

        // Named arguments (paren form, e.g. `Button(action: {}, label: { ... })`).
        for arg in node.arguments {
            if arg.label?.text == interestedLabel,
               let closure = arg.expression.as(ClosureExprSyntax.self) {
                closures.append(closure)
            }
        }

        // Multi-trailing-closure form (`Button { } label: { ... }` or
        // `Label { } icon: { ... }`).
        for additional in node.additionalTrailingClosures
        where additional.label.text == interestedLabel {
            closures.append(additional.closure)
        }

        // Single-trailing-closure form for NavigationLink / Link binds
        // to `label:`. Button's and Label's single trailing closures
        // bind to `action:` and `title:` respectively — NOT label
        // providers for Image, so we skip them.
        if (ref.baseName.text == "NavigationLink" || ref.baseName.text == "Link"),
           node.additionalTrailingClosures.isEmpty,
           let trailing = node.trailingClosure {
            closures.append(trailing)
        }

        return closures
    }

    private func isInsideSilentClosure(_ node: FunctionCallExprSyntax) -> Bool {
        var current: Syntax? = Syntax(node).parent
        while let n = current {
            if let closure = n.as(ClosureExprSyntax.self),
               silentClosureIDs.contains(closure.id) {
                return true
            }
            current = n.parent
        }
        return false
    }

    /// Walk syntactic parents and look for any modifier-call wrapping
    /// the Image (or an ancestor view the Image sits inside) whose
    /// modifier name is one of the accessibility silencers. This
    /// catches:
    ///   - `.accessibilityLabel(...)` / `.accessibilityHidden(true)` /
    ///     `.accessibilityElement(children: .combine)` directly on the
    ///     Image's own modifier chain.
    ///   - The same modifiers applied to an ancestor view (e.g.
    ///     `HStack { Image(...) }.accessibilityElement(children: .combine)
    ///     .accessibilityLabel("…")`) — the AppViews.swift:1152 shape.
    private func hasAccessibilitySilencerInChain(_ node: FunctionCallExprSyntax) -> Bool {
        var current: Syntax? = Syntax(node).parent
        while let n = current {
            if let call = n.as(FunctionCallExprSyntax.self),
               let member = call.calledExpression.as(MemberAccessExprSyntax.self) {
                if modifierIsAccessibilitySilencer(name: member.declName.baseName.text, call: call) {
                    return true
                }
            }
            current = n.parent
        }
        return false
    }

    private func modifierIsAccessibilitySilencer(name: String, call: FunctionCallExprSyntax) -> Bool {
        switch name {
        case "accessibilityLabel":
            return true
        case "accessibilityElement":
            // `.accessibilityElement(children: .combine)` merges
            // children under the parent's own label. Without the
            // `children:` arg it creates an opaque element, still
            // hiding child labels; treat as silencer for any form.
            return true
        case "accessibilityHidden":
            // `.accessibilityHidden(false)` is explicitly NOT a
            // silencer — author opted *in* to VoiceOver. Any other
            // argument (including `true`, vars, expressions) silences.
            if let firstArg = call.arguments.first,
               let bool = firstArg.expression.as(BooleanLiteralExprSyntax.self),
               bool.literal.text == "false" {
                return false
            }
            return true
        default:
            return false
        }
    }

    /// Silencer (d) — sibling `Text(...)` exemption — was removed in
    /// WI-loop30-4b per Iris's catalog §P5: sibling adjacency is NOT a
    /// labeling relation in SwiftUI's accessibility tree. The original
    /// `hasSiblingTextInSameBlock` / `codeBlockItemRootsAtTextCall`
    /// helpers were deleted with this change.
}
