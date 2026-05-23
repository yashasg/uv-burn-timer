---
name: "ast-rule-supersedes-regex"
description: "Replace a brittle SwiftLint regex rule with a SwiftSyntax rule and clean up legacy disable sites"
domain: "ios-ui-accessibility"
confidence: "low"
source: "earned"
---

## Context
Use this skill when a SwiftLint regex has reached its structural limit (lookahead windows, false positives, blind spots) and the repo already has a SwiftSyntax AST lint package wired into local/CI builds.

## Patterns
- Keep the same rule id when the AST rule is the semantic successor; this preserves historical context and makes migration from old diagnostics obvious.
- Retire the regex from `.swiftlint.yml` entirely once the AST parity tests are green. A comment block documenting the retirement is enough.
- Wire the new rule into the `swiftlint-ast` CLI and keep rule-local XCTest coverage in `tools/swiftlint-rules/Tests/SwiftLintASTRulesTests/`.
- Mirror the WI-L32 AST batch style: inline positive/negative fixtures, rule-id/line metadata tests, and an `app/Sources` parity gate.
- Audit every legacy disable marker. Remove it when code is already compliant, fix the underlying SwiftUI surface when it is not, and migrate true exemptions to an AST-only marker so SwiftLint no longer warns about superfluous disable commands.

## Examples
- `missing_min_touch_target` superseded a regex lookahead rule by moving enforcement into `MissingMinTouchTargetRule.swift`, retiring the YAML rule, and migrating intentional exemptions to `MISSING_MIN_TOUCH_TARGET_OK`.
- `toolbar_image_needs_scaled_frame` established the earlier retirement pattern: regex out, AST file stays canonical, build gate remains `swiftlint-ast` in `./build.sh`.

## Anti-Patterns
- Leaving the old regex active after the AST rule lands; that creates duplicate diagnostics and forces duplicate disable mechanisms.
- Keeping `swiftlint:disable` comments for AST-only rules after the regex is gone; SwiftLint will surface `superfluous_disable_command` noise.
- Treating `.contentShape(...)` as proof of compliance without an actual width/height floor.
