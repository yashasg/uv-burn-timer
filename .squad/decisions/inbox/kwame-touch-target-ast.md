# Kwame — missing_min_touch_target AST rollout

**Date:** 2026-05-22T21:10:27.757-07:00  
**Author:** Kwame (iOS Developer)

## Rule scope
- `missing_min_touch_target` now lives in SwiftSyntax and scans `Button`, `NavigationLink`, `Link`, and `.onTapGesture` sites.
- It flags controls with no declared 44pt floor, or with explicit width/height floors below 44pt.
- Accepted compliant shapes are: explicit two-axis floors (`minWidth` + `minHeight`, or `width` + `height`), full-width row floors (`maxWidth: .infinity` + `minHeight`), and textual controls with an explicit >=44pt height floor.
- `.contentShape(...)` does not silence the rule by itself; it only matters once size is already adequate.

## Exemptions
- Intentional exemptions stay explicit in source via `MISSING_MIN_TOUCH_TARGET_OK` on the same line or immediately preceding line.
- Use that marker for Form/List row chrome the OS already floors, inline body/footnote hyperlinks where the HIG touch-target floor is not the governing heuristic, and test-only probe surfaces.

## Regex retirement
- The `.swiftlint.yml` regex custom rule for `missing_min_touch_target` is retired.
- `tools/swiftlint-rules/Sources/SwiftLintASTRules/MissingMinTouchTargetRule.swift` plus the AST gate in `./build.sh` are now the sole enforcement path.
- Existing regex-era disable comments should not linger; SwiftLint now treats them as superfluous because the regex rule is gone.

## Disable-site playbook going forward
1. If the AST can prove the production code already satisfies the rule, delete the old disable comment.
2. If the code really is undersized or missing a declared floor, fix the SwiftUI surface first, then delete the disable.
3. Only keep a marker when the surface is intentionally exempt; convert it to `MISSING_MIN_TOUCH_TARGET_OK` with a one-line rationale.
