# Kwame — History (Summarized)

**Latest Status (2026-05-22T03:32:09-07:00):** Loop-26 closure complete. PR #98 merged as a8b1ac8. SwiftLint HIG hard-gate live on main. Applied Iris playbook across 3 commits (66cc6c9 TDD, a643523 FPV, 174be71 AV). All 31 violations resolved (13 FPV + 18 AV). CI green. Post-merge audit PASS-WITH-NOTES.

**Previous Status (2026-05-21T04:40:00Z):** Main screen cleanup (K-1 through K-11) shipped. Removed photosensitization banner, added ⓘ toolbar button, flattened PersistentFooter, simplified status messages. Build: clean, 114 unit tests passing.

---

## Key Implementations

### Loop-26 HIG Cleanup (PR #98)

**Commits:**
- **66cc6c9** — TDD group R guards (MainScreenCleanupContractTests.swift) — 5 source-text contracts (R1–R5) pinning @ScaledMetric presence and literal absence
- **a643523** — ForecastPickerView.swift HIG cleanup (FPV-1 through FPV-13) — 15 @ScaledMetric identifiers, all 13 violations resolved
- **174be71** — AppViews.swift HIG cleanup (AV-1 through AV-18) — 5 struct @ScaledMetric declarations, all 18 violations + navigation_stack_in_sheet fixed

**Playbook fidelity:** All FPV/AV sections implemented faithfully. 4 additional swiftlint:disable comments added (AV-12, 13, 15, 16) — justified by 200-char regex lookahead constraint, not HIG softening. Pre-existing out-of-scope chip/footer literal minHeight:44 sites deferred as Loop-27 WI-1.

### Main Screen Cleanup (WI prior)

**K-1 through K-11 shipped:**
- K-1: Removed `photosensitizationBanner` (37-line computed property)
- K-2: Added ⓘ toolbar button with NavigationLink to AboutView
- K-6: Flattened `PersistentFooter` to pure NavigationLink
- K-7/K-8/K-9: Removed verdict caveats, simplified location rationale
- K-10/K-11: Added `aboutSunSafetyActions` constants to satisfy Plunder C2

**Test integration:** Groups N–Q (8 new tests) guard main screen cleanup contracts. Source-text guards (@filePath + grep) used for cross-target verification.

---

## Learnings

### SwiftLint Implementation (Loop-26)

- **User directive superseded Iris's softer policy:** hard-error day 1, no grace period, no literal exceptions. All HIG layout/touch/typography rules at `severity: error` from day 1.
- **@ScaledMetric backing required:** `missing_min_touch_target` no longer accepts literal minHeight:44/56. Regex heuristic checks for nearby `.frame(...minWidth|minHeight: someIdentifier)` — pragmatic proxy for @ScaledMetric, not proof.
- **200-char regex lookahead is a real constraint:** Multi-line Button bodies push `.frame()` past the window. Justified disable comments with prose explanation required.
- **Loop-28 follow-ups identified:** (1) Residual literal minHeight:44 at AppViews:295/315/337/2135 in Button/Menu/NavigationLink wrappers. (2) ForecastPickerView header minHeight:28. (3) Semantic-font vs. ScaledMetric choice needs annotation. (4) Schedule swift-syntax AST replacement for missing_min_touch_target. (5) Line-number-fragile tests need symbol anchors.

### Main Screen Cleanup (WI prior)

- **Avoid redeclaration errors:** grep for constant names before adding ProductCopy.swift entries.
- **Toolbar placement:** `.primaryAction` (far trailing) + `.topBarTrailing` coexist cleanly; ⓘ sits left of gear button.
- **LocationRationaleCard removal logic:** When app requests only approximate location (kCLLocationAccuracyReduced), OS dialog is self-explanatory. In-app rationale card adds UX friction with no privacy benefit.

---

## 2026-05-22: Loop-26 closure — PR #98 merged (a8b1ac8)

SwiftLint HIG hard-gate wired and live on main. All 31 violations resolved (FPV 13 + AV 18). Issues #95/#96 closed. Post-merge audit PASS-WITH-NOTES (5 structural rule-coverage gaps deferred to Loop-28+). Privacy Policy hosting and physical-device sign-offs remain user-owned blockers.

**Commits:** 66cc6c9 (TDD), a643523 (FPV), 174be71 (AV) → merged as a8b1ac8
