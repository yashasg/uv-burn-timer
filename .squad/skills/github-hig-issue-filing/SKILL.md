---
name: "github-hig-issue-filing"
description: "Turn a SwiftUI HIG audit into actionable GitHub cleanup issues without misrouting squad ownership"
domain: "issue-triage"
confidence: "high"
source: "earned"
---

## Context
Use this skill when Iris (or another reviewer) has already finished a SwiftUI Apple-idiom audit and the next step is to open implementation issues on GitHub.

## Patterns
- If the audit is concentrated in a small number of concrete files, bundle the cleanup **per file** rather than per rule category.
- In every issue body, spell out the violated rules explicitly: relative layout, semantic padding, and Dynamic-Type-aware symbol sizing.
- List every offender as an exact repo-relative `path:line` reference.
- Cite the governing decision by date and heading, and point implementers at the reusable audit skill (`.squad/skills/swiftui-apple-layout-audit/SKILL.md`).
- If the repo lacks squad labels but workflows expect them, create `squad`, `squad:{owner}`, and any reviewer labels you need for future work.
- Apply only the implementation owner’s `squad:{owner}` label when current automation treats `squad:*` as pickup ownership. Keep the reviewer as an explicit gate in the issue body instead of dual-labeling owner + reviewer.
- Use an existing general label like `enhancement` alongside the owner label unless the work is clearly a bug.
- Call out lower-severity symbol-size or decorative-frame sites as “clean up while you are there,” not as separate issues, when they live in the same file as the primary offenders.

## Examples
- Iris’s 2026-05-22 layout audit for `ForecastPickerView.swift` and `AppViews.swift` became two GitHub issues (`#95` and `#96`), each labeled `enhancement` + `squad:kwame`, with Iris kept as a reviewer gate in the body.
- A disclaimer view with one huge `.padding(32)` offender plus a few nearby fixed symbol sizes belongs in one file-scoped cleanup issue, not a separate “padding” issue and “symbol size” issue.

## Anti-Patterns
- Creating category-based issues that force one implementer to touch several unrelated SwiftUI files in parallel.
- Applying both `squad:kwame` and `squad:iris` when automation would interpret both as pickup ownership.
- Filing a top-5-only issue without a tracker when the remaining long-tail offenders are already known and ready for implementation.
