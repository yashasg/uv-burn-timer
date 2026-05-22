# Gaia — History

## Core Context

- **Project:** A UV exposure and sunburn timer app
- **Role:** Lead
- **Joined:** 2026-05-19T06:26:01.545Z

## Learnings

### 2026-05-19T22:33:50.504-07:00: Preference Persistence Architecture Decision

**Context:** User raised that app does not persist skin type and location preferences, forcing re-entry on every cold launch. Gaia reconciled product requirements with prior decisions (D-2026-05-19-011 L1–L4 disclaimer safety boundary, D-2026-05-19-012 no-default Fitzpatrick).

**Key findings:**
- **Current state:** Skin type + SPF held in @State only (session object). Location (lastRoundedCoordinate) partially persisted via @AppStorage. Disclaimer in @State (transient, correct for re-attestation).
- **Conflict identified:** Prior guidance said "keep Fitzpatrick in @State, zero-data architecture" but user feedback requires persistence to avoid re-entry friction.
- **Resolution:** Persist skin type + SPF to UserDefaults (@AppStorage). Keep disclaimer @State (safety boundary). Do NOT persist permission status (OS-owned) or UV snapshots (time-sensitive).

**Decision locked:** Skin type + SPF → UserDefaults; disclaimer remains transient. (See `.squad/decisions/inbox/gaia-preference-persistence.md` for full spec.)

**Handoff:** Kwame to migrate session properties to @AppStorage layer, restore on init, sync on change. No UI changes.

### 2026-05-20: Commit-split decision for squad/fix-location-gauge-ui working tree

Split uncommitted work into two commits: (1) `docs: fold decision inbox into ledger` (decisions.md + 7 inbox deletions; pure decision hygiene, no code) and (2) `fix: move Fitzpatrick off main; unify onboarding/settings picker; expand About` (app + tests + spec + excalidraw + tool log). The app/spec/diagram diffs are one cohesive scope — the branch-name feature — because every change serves the same IA goal (Fitzpatrick lives in onboarding/Settings, not main; Settings → About cross-link; About becomes the authoritative caveats destination). One drive-by test (`longUnprotectedEstimateAtFourHoursShowsApprovedDisplayCap`) was folded in rather than split into a third commit — splitting a single test into its own commit is bookkeeping overhead, not signal.

### 2026-05-20: Onboarding cover-chain flake decision

Tests `testLocationButtonStartsLocationFlowInsteadOfSettings`, `testBurnRiskGaugeShellExistsWhenNoEstimate`, and `testScenario10SavedLocationRestoresAndCanBeCleared` were intermittently failing on the iPhone 17 Pro / iOS 26.4 simulator with `Computed hit point {-1, -1}` for the disclaimer "I understand" button and the toolbar gear. Root cause: (a) XCUITest taps fired before the just-presented `fullScreenCover` had a hittable frame and (b) chaining two `.fullScreenCover` modifiers (disclaimer → skin-type onboarding) inside the same window sometimes had the second presentation swallowed because it was assigned while the first cover's dismissal animation was still tearing down its presentation slot. **Decision:** keep the dual-cover structure (it cleanly separates disclaimer re-attestation from skin-type onboarding) and instead (1) defer `showSkinTypeOnboarding = true` past the disclaimer cover's transition with a 500 ms `Task.sleep`, and (2) add a `tapWithRetry` test helper that waits for `isHittable` and a non-empty frame before tapping. This is the smallest-surface-area fix and avoids a state-machine refactor of the App scene.

### 2026-05-22T02:26:49.194-07:00: HIG issue bundling and filing

Chose **per-file** bundling for Iris’s Apple-idiom audit rather than per-category or top-5-only slicing. `ForecastPickerView.swift` and `AppViews.swift` are self-contained SwiftUI cleanup surfaces; category slicing would create cross-file merge collisions, and top-5-only would hide the long tail that is already concrete.

Created repo routing labels `squad`, `squad:kwame`, and `squad:iris` because the workflows already expect them, but applied only `squad:kwame` on the implementation issues. Reviewer ownership stays in the body because the current `squad:*` automation treats every member label as pickup ownership, so dual-labeling Kwame + Iris would misroute the work.

Filed:
- `#95` — `[HIG] Apple-idiom layout cleanup in ForecastPickerView.swift`
- `#96` — `[HIG] Apple-idiom layout cleanup in AppViews.swift`

Both issues carry `enhancement` + `squad:kwame`, list every offender by exact `path:line`, cite `.squad/decisions.md` → `2026-05-22 / Apple-idiom SwiftUI layout policy`, point at `.squad/skills/swiftui-apple-layout-audit/SKILL.md`, and include the gate: **Iris must HIG-pass before merge.**

Kwame nuance: the worst offenders remain the forecast cell/chip sizing and disclaimer `.padding(32)`. Literal SF Symbol sizes plus tiny dot/tap-target-adjacent frame sites are lower severity, but they should still be cleaned opportunistically inside the same file pass rather than spun into separate issues.

No GitHub assignee was set because the repo currently exposes only `yashasg` as an assignable user; squad routing here is label-driven, not GitHub-user-driven.

## 2026-05-22T02:58:03-07:00 — SwiftLint HIG gate landed

Kwame completed SwiftLint 0.63.2 install and pushed branch `squad/swiftlint-hig-error-gate` with 4 starter HIG rules (error severity) integrated into CI; 16 baseline violations confirmed. Iris produced 20-rule HIG SwiftLint catalog. Likely next: orchestrate branch merge after Iris HIG-pass and integrate all 20 rules (10 immediate error, 5 grace-period warn→error).
