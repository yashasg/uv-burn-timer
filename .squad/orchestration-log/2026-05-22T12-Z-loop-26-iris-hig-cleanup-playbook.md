# Iris — Loop-26 HIG Cleanup Playbook

**Date:** 2026-05-22T12:00:00Z  
**Agent:** Iris (UI/UX Designer — HIG & Accessibility)  
**Phase:** HIG cleanup playbook generation  

## Execution Summary

Iris generated comprehensive 794-line HIG cleanup playbook specifying violation fixes for ForecastPickerView (13 violations) and AppViews (18 violations).

### Outputs Generated
- `.squad/decisions/inbox/iris-loop-26-hig-cleanup-playbook.md` — Detailed violation remediation spec (794 lines)

### Playbook Scope
- **ForecastPickerView Part A (FPV-1 through FPV-13):** 15 @ScaledMetric identifiers, frame/font literal replacements
- **AppViews Part B (AV-1 through AV-18):** 5 struct @ScaledMetric declarations, literal cleanup, .sheet → .fullScreenCover migration
- **Test guardrails (Group R):** 5 source-text contract tests (R1–R5) protecting @ScaledMetric declarations and absence of literal frames

### Key Decisions
- **@ScaledMetric backing:** All touch-target, padding, and font-size literals must be backed by named @ScaledMetric identifiers (not plain constants)
- **Identifier naming:** minTap (44), pillHeight/Width, chipWidth, cellHeight/Width, timeColWidth, hourDotSize, chevronSize, hourIconSize, skeletonRowHeight/DayLabelHeight/DayLabelWidth/BadgeWidth/BadgeHeight, numeralColWidth, warningIconSize
- **Disable policy:** Per-line swiftlint:disable justified only for multi-line Button closures exceeding 200-char regex lookahead (technical necessity, not HIG softening)

---

**Status:** Complete  
**Output location:** `.squad/decisions/inbox/iris-loop-26-hig-cleanup-playbook.md`
