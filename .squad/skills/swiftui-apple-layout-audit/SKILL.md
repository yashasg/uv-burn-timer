---
name: "swiftui-apple-layout-audit"
description: "Audit SwiftUI views for Apple-native relative layout, Dynamic Type support, and safe-area handling"
domain: "ios-ui-accessibility"
confidence: "high"
source: "earned"
---

## Context
Use this skill when reviewing SwiftUI surfaces for Apple HIG alignment, especially before design sign-off on iPhone-first screens that must survive AX sizes, VoiceOver, dark mode, and safe-area constraints.

## Patterns
- Red-flag grep set:
  - `\.frame\([^\n)]*(width|height)\s*:\s*\d` → hardcoded literal width/height
  - `\.padding\([^\n)]*\d` → numeric padding, including ternaries like `.padding(flag ? 12 : 0)`
  - `\.font\(\.system\(size\s*:\s*\d` → fixed literal font/symbol size
  - `\.dynamicTypeSize\(` → inspect for caps below `.accessibility5`
  - `GeometryReader` → require a true screen-relative reason
- Green-flag grep set:
  - `frame(maxWidth: .infinity)` / `frame(maxHeight: .infinity)`
  - `Spacer()`, `VStack`, `HStack`, `LazyHStack`, `LazyVStack`, `LazyVGrid`
  - `@ScaledMetric`
  - `.safeAreaInset(edge: .bottom)` for bottom actions
  - `@Environment(\.dynamicTypeSize)` branches that reflow layout at accessibility sizes
- Severity rule:
  - Literal sizing on readable text is high severity.
  - Literal sizing on SF Symbols is still a red flag, but lower severity than literal text sizing.
  - `@ScaledMetric`-backed custom sizes are acceptable when a semantic text style cannot express the UI.
- HIG exception rule:
  - `minHeight: 44` / `56` for tap targets is acceptable.
  - Fixed live-content cell/chip widths are not acceptable unless backed by `@ScaledMetric` or another accessibility-safe constraint.

## Examples
- Replace `.padding(.horizontal, 16)` with `.padding(.horizontal)` when the default system inset is sufficient.
- Replace `.padding(32)` on modal content with `.padding()` unless there is a proven spacing token reason.
- Replace `.frame(width: 60, height: 88)` on forecast cells with `@ScaledMetric`-backed dimensions or a layout that lets content and accessibility breakpoints drive size.
- Replace `.font(.system(size: 20))` on symbols with semantic sizing where possible (`.font(.title3)`, `.imageScale`) or an `@ScaledMetric` value if the icon must scale with type.
- If a horizontal strip uses fixed cells, pair it with an AX fallback branch (for example, switch to a vertical list at `.xxLarge` or accessibility sizes).

## Anti-Patterns
- Repeating `.padding(.horizontal, 16)` or `.padding(.vertical, 12)` across every section by habit.
- Locking live content to `40×22`, `56×22`, `60×88`, or similar raw sizes without Dynamic Type scaling.
- Capping Dynamic Type with `.dynamicTypeSize(... .xxxLarge)` and calling the screen accessible.
- Using `GeometryReader` for layouts that standard stacks, frames, and spacers can solve.
- Treating service files as UI audit targets when they do not actually render SwiftUI views.
