# Skill: Regulatory Floor Testing via ProductCopy Constants

**Context:** When view introspection is unavailable (SwiftUI app target not importable from SPM unit test target), regulatory compliance contracts can still be partially guarded at the `ProductCopy` constant level.

## Pattern

### 1. Constant Content Guards (always possible)

```swift
@Test func test_constantCarriesRequiredClause() {
    let copy = ProductCopy.someConstant.lowercased()
    #expect(copy.contains("required phrase"), "Reason this phrase is required")
}
```

Use for: verifying Plunder/regulatory required phrases exist in the copy constant that will carry them to the UI.

### 2. Source-Level Reference Guard (K-11 pattern)

When a view wires a constant into its body (e.g., `Text(ProductCopy.aboutSunSafetyActions)`), use a source-file read to guard the wiring:

```swift
@Test func test_viewSourceReferencesConstant() throws {
    let testFileURL = URL(fileURLWithPath: #filePath)
    let viewSourceURL = testFileURL
        .deletingLastPathComponent()  // TestTarget/
        .deletingLastPathComponent()  // Tests/
        .deletingLastPathComponent()  // Package root/
        .appendingPathComponent("Sources/AppTarget/TargetView.swift")
    let sourceText = try String(contentsOf: viewSourceURL, encoding: .utf8)
    #expect(sourceText.contains("constantName"), "View must wire the constant")
}
```

**Fragility:** Breaks if the file is renamed or moved. Worth the cost for regulatory-critical wiring.

### 3. Known-Issue Flags for Manual Surfaces

For UI surfaces that cannot be automated, use `withKnownIssue` so the gap is visible in CI output:

```swift
@Test func test_manualSurface_verification() {
    withKnownIssue("Manual: verify [specific thing] in simulator. Not automatable without [what's needed].") {
        #expect(Bool(false), "Manual check required")
    }
}
```

**Important:** `withKnownIssue` requires a **string literal** — not a concatenated string. Use a single long string.

### 4. Regulatory Load Assignment

When a constant is redesigned (e.g., `reapplicationFooter` split into `aboutSunSafetyActions` + remaining footer), write separate tests for each carrier:
- Test that C2-carrying constant contains C2 clauses
- Test that C1-carrying constant (often `disclaimerLinkLabel`) still contains C1 anchor
- Never assume a single constant carries all regulatory loads

## When This Pattern Is Sufficient

- Content is the regulatory floor (what the string says, not where it renders)
- The constant is `public static let` in a `public enum` — immutable, source-of-truth
- UI placement is guarded by source-level reference test (pattern 2)

## When This Pattern Is NOT Sufficient

- Compliance depends on VISIBILITY (is it above the fold? always shown?)
- Compliance depends on INTERACTION (is it tappable? does it navigate correctly?)
- Compliance depends on ACCESSIBILITY (is the label correct for VoiceOver?)

For those cases, escalate to: UITest host app tests, ViewInspector, or extracted ViewModel types.

## See Also

- `.squad/skills/forecast-store-test-patterns/SKILL.md` — mock/protocol patterns for untestable types
- `.squad/decisions/inbox/ma-ti-ux-cleanup-gaps.md` — specific gaps from the main screen cleanup
