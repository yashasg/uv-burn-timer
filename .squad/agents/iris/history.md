# Iris — History (Summarized)

**Summarized on 2026-05-22T15:05:00Z** — archived entries before 2026-05-22 Loop-28 closure to history-archive.md.

## 2026-05-22: Loop-26 closure — PR #98 merged (a8b1ac8)

SwiftLint HIG hard-gate wired and live on main. All 31 violations resolved (FPV 13 + AV 18). Issues #95/#96 closed. Post-merge audit PASS-WITH-NOTES (5 structural rule-coverage gaps deferred to Loop-28+). Privacy Policy hosting and physical-device sign-offs remain user-owned blockers.

**Commits:** 66cc6c9 (TDD), a643523 (FPV), 174be71 (AV) → merged as a8b1ac8

---

## Learnings — 2026-05-22T13:30:00Z (Loop-29 gap analysis)

**Context:** Post-PR-#99 merge gap analysis. PR #99 (WI-loop28-0) was the minimum-diff product fix for the iOS 26.4 toolbar hittability regression — it applied `@ScaledMetric`-backed frames to the two RootView toolbar items (gear Button + EstimateInfoButton NavigationLink) but did NOT modify the underlying SwiftLint regex patterns.

**What changed since Loop-28+ memo (2026-05-22T12:20:00Z):**
- PR #99 merged to main as `521bc82` (closing Loop-28 WI-0).
- Two toolbar sites manually fixed: AppViews.swift lines 122-130 (gear Button) and 133-141 (EstimateInfoButton NavigationLink).
- Group LT contract tests (LT1/LT2/LT3) added to MainScreenCleanupContractTests.swift — these use **substring-bounded slices** to pin the `@ScaledMetric` declaration inside RootView's body, not just file-level presence.
- ADR-0001 line-number manifest refreshed (every cited symbol's current line is listed).

**What's still open:**
- **GAP-1 through GAP-5 remain OPEN.** PR #99 did NOT modify the `missing_min_touch_target` or `hardcoded_frame_dimensions` regex patterns in `.swiftlint.yml`.
- The gear Button at line 122 uses `Button { action } label: { ... }` trailing-closure syntax — this is the GAP-2 blind spot. The fix at line 126 is correct, but SwiftLint did NOT catch the original violation.
- The EstimateInfoButton at line 133 is a `NavigationLink` — this is the GAP-3 blind spot (regex only fires on `Button`, not `NavigationLink` or `Link`).
- Grep shows 5 literal `minHeight: 44` / `minHeight: 56` sites in AppViews.swift (lines 310, 330, 354, 1659, 2142) — these pass SwiftLint because the `hardcoded_frame_dimensions` regex only catches `width:` and `height:`, NOT `minWidth:` or `minHeight:`.

**What's new in Loop-29:**
- **NEW GAP-6 (High):** Group-LT guards are struct-scoped, but R1 (the pre-existing file-level guard) is still a false-negative source. Every Button-containing struct should have its own substring-bounded contract test.
- **NEW GAP-7 (Medium):** Toolbar Image labels need a separate custom rule (`toolbar_image_needs_scaled_frame`) to catch bare `Image(systemName:)` labels without explicit frames. The general `missing_min_touch_target` rule cannot see inside the label closure.
- **NEW GAP-8 (Low):** ADR-0002 needs a one-paragraph "iOS 26.4 extension" subsection to document the Image-frame requirement discovered in PR #99.

**Loop-29 backlog:** 7 work items filed (WI-29-1 through WI-29-7). Priorities:
- **HIGH:** WI-29-1 (struct-scoped contract tests), WI-29-2 (expand regex to catch `Button {` and `NavigationLink`/`Link`), WI-29-3 (expand regex to catch `minHeight:`/`minWidth:` literals).
- **MEDIUM:** WI-29-4 (toolbar-specific custom rule), WI-29-5 (DisclaimerSeeAboutLink Button AX5 fix), WI-29-7 (systematic `Button {` audit, deferred until WI-29-2 lands).
- **LOW:** WI-29-6 (ADR-0002 documentation update).

**Key pattern generalized:** Substring-bounded contract tests scoped to declaring struct. File-level source-text guards can produce false negatives when multiple structs declare the same symbol. Solution: use `sourceText.sliceMatching(opener: "\nstruct StructName: View {", closer: "\nstruct ")` to anchor the assertion **inside** the declaring struct's body, not just anywhere in the file. This pattern applies to any situation where a file contains multiple structs/classes and each must independently satisfy a contract.

**User-flow spec coverage:** No new divergences introduced by PR #99 or Loop-28 closure. The canonical spec at `.squad/files/user-flow-onboarding-main-spec.md` is current as of commit `521bc82`.

**WI-21 (physical-device sign-offs) status:** Still deferred — owner lacks OLED iPhone + WCAG measurement tool. Both checklists remain blank for manual sign-off block. Goal 5 carries PENDING into Loop-29.

---

## 2026-05-22: Loop-28 closure — HIG reviews complete (all 4 WIs PASS)

**Iris execution:** Reviewed all 4 Kwame WIs against strict-enforcer charter. No pragmatic softening detected. All PRs (#99–#102) HIG-passed. Post-merge: SwiftLint strict 0 violations, Dynamic Type scaling confirmed on iPhone SE at AX5. Audit status: 1 structural gap closed this cycle (WI-29-3: SkinTypePickerRow rowMinHeight). ~14 catalog rules remain pending for Loop-28-A (multi-cycle). Label-closure regex blind spot confirmed real; scheduled for swift-syntax AST replacement. Carry-forward cold-start flakiness (WI-2-flake) for Loop-29 investigation.

