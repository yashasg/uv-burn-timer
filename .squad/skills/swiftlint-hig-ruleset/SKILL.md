---
name: "swiftlint-hig-ruleset"
description: "Define SwiftLint custom_rules that harden Apple HIG, accessibility, and localization guardrails in SwiftUI"
domain: "ios-ui-accessibility"
confidence: "high"
source: "earned"
---

## Context
Use this skill when an iOS team wants SwiftLint `custom_rules` to catch Apple HIG regressions before code review, especially in SwiftUI surfaces that must survive Dynamic Type, dark mode, locale changes, and accessibility preferences.

## Rollout defaults
- Scope rules to `Sources/**/*.swift`; exclude `Tests/**`, previews, generated code, and vendor folders.
- Treat regex as smell detection, not proof. Legit exceptions should use `// swiftlint:disable:next rule_id` with a one-line justification.
- Do not promote every rule to CI-blocking on day one; use severity buckets.

## Rule families
- **Color:** `color_literal_rgb`, `no_hex_color_initializer`, `no_forced_color_scheme`
- **Typography + layout:** `unsafe_fixed_typography`, `no_fixed_text_frame_height`, `no_fixed_frame_both_axes`, `no_numeric_padding`, `geometry_reader_requires_justification`
- **Accessibility + localization:** `missing_min_touch_target`, `image_requires_accessibility_semantics`, `no_uppercased_in_code`, `no_lowercased_in_code`, `unsafe_user_string_assembly`
- **Motion + feedback:** `unsafe_motion_without_reduce_motion_guard`, `no_raw_feedback_generator`
- **Container safety:** `navigation_stack_in_sheet`, `no_navigation_bar_title_deprecated`, `explicit_ignores_safe_area_edges`, `no_plain_list_style_for_settings`, `scrollview_requires_keyboard_dismiss`

## Severity buckets
- **Always error:** color, locale, and deterministic API misuse (`navigation_stack_in_sheet`, `no_navigation_bar_title_deprecated`, `explicit_ignores_safe_area_edges`, `no_raw_feedback_generator`)
- **Grace period:** literal spacing/sizing cleanup (`missing_min_touch_target`, `no_numeric_padding`, `no_fixed_frame_both_axes`, `unsafe_fixed_typography`, `no_fixed_text_frame_height`)
- **Always warn:** regex-noisy heuristics (`geometry_reader_requires_justification`, `image_requires_accessibility_semantics`, `unsafe_motion_without_reduce_motion_guard`, `no_plain_list_style_for_settings`, `scrollview_requires_keyboard_dismiss`)

## Regex design rules
- Prefer small, explicit alternations over giant do-everything regexes.
- Use bounded multiline windows like `[\s\S]{0,140}` when a modifier must appear near a view declaration.
- Hard-block only deterministic smells such as `.uppercased()`, `.navigationBarTitle(`, `.preferredColorScheme(.light)`, or raw color constructors.
- If a rule cannot prove absence cleanly, bias toward visibility + documented disable path instead of pretending the regex is smarter than it is.

## Fast adoption pattern
1. Land the catalog with warn/error buckets.
2. Exclude tests, previews, and generated files first.
3. Flip deterministic locale/color rules to error immediately.
4. Give legacy spacing/touch-target debt a short grace window.
5. Revisit broad image/motion/container heuristics later with AST-based lint if the team wants stricter CI gates.
