---
name: "swiftlint-error-gate-install"
description: "Install SwiftLint as a build-tool-only HIG gate with CI hard failures and local fallback behavior"
domain: "ios-build-ci"
confidence: "high"
source: "earned"
---

## Context
Use this skill when you need Apple HIG or other shipped UX rules to block CI without linking SwiftLint into the runtime binary.

## Pattern
- Prefer `SimplyDanny/SwiftLintPlugins` as the SwiftPM dependency when you only need the plugins. It mirrors the official SwiftLint plugin releases but avoids pulling the full SwiftLint source tree and SwiftSyntax dependency graph into the consumer package.
- Keep the repo-root `.swiftlint.yml` scoped to source directories only, excluding generated output, tests, and squad metadata.
- Promote HIG rules through `custom_rules` with `severity: error`.
- Default HIG layout/touch/typography rules to strict day-1 errors — no grace period and no warning tier.
- For regex-only touch-target enforcement, fail literal `minHeight: 44` / `56` floors; require a nearby `.frame(...minWidth|minHeight: someIdentifier)` and document that the bare-identifier check is only a heuristic stand-in for true `@ScaledMetric` validation.
- If the repo already has unrelated SwiftLint debt, disable or defer those non-HIG rules so `--strict` stays focused on HIG regressions instead of historical style noise.
- In the canonical build script, run `swiftlint --strict --config .swiftlint.yml --reporter xcode` before build/test. If `swiftlint` is missing locally, emit a `warning:` and continue so local builds still work.
- Add a fast local hook such as `./build.sh lint` with the emoji reporter.
- In GitHub Actions, install `swiftlint` with Homebrew and run the strict lint step before the normal build script. Do not rely on the package plugin alone for CI visibility.
- Seed the config with already-known audit patterns now, then merge the larger rule catalog later.

## Example
- `app/Package.swift` exact-pins `SimplyDanny/SwiftLintPlugins`.
- `.swiftlint.yml` includes HIG custom rules for semantic colors, `NavigationStack` inside `.sheet`, touch-target checks that require identifier-backed `minWidth` / `minHeight` floors instead of literal `44` / `56`, user-facing `.uppercased()`, literal live-content frames, and literal `.font(.system(size:))`.
- `build.sh` provides two paths:
  - default mode: strict Xcode-reporter gate before `xcodebuild`
  - `lint` mode: emoji-reporter local feedback
- `.github/workflows/ci.yml` installs SwiftLint, runs the strict lint command, then calls `./build.sh`.

## Trade-offs
- Plugin + Homebrew is dual wiring, but it separates package/Xcode ergonomics from explicit CLI gating.
- `--strict` is valuable defense in depth only if unrelated legacy SwiftLint rules are muted first.
- Error severity is appropriate for HIG contracts such as Dynamic Type-safe layout, semantic colors, 44pt hit targets, and focused sheet navigation.
