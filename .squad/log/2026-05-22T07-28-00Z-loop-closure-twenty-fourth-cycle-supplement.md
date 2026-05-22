# Session Log: Loop Closure — Twenty-Fourth Cycle Supplement (2026-05-22T07:28Z)

**Date:** 2026-05-22T07:28Z
**Driver:** Coordinator (Squad work loop)
**Cycle scope:** Supplement to the Loop-24 closure log at `.squad/log/2026-05-22T07-08-00Z-loop-closure-twenty-fourth-cycle.md`. Documents the post-closure-log merge of **PR #90 (Bundle EE / Group PP — SPFLevel policy invariants, 6 WIs)** that was opened during Loop-24 by the Squad coordinator but landed AFTER the closure-log PR (#91) merged, so it is not reflected in the §"Shipped this cycle" or §"Test contract growth" tables of the primary Loop-24 closure log. This supplement amends those facts for the historical record without rewriting the merged primary log.
**Entering state:** main at `0750e88` (PR #91 Loop-24 primary closure-log merge). PR #90 still open with CI in flight.
**Exiting state:** main at `97308af` (PR #90 Bundle EE Group PP SPFLevel policy invariants merge) + this supplement-log PR pending merge.

## Why a supplement and not an edit-in-place

The primary Loop-24 closure log was written and merged (PR #91 → `0750e88`) before PR #90's CI completed. Rewriting a merged closure log in place would break the append-only historical-record convention every prior loop closure has honored. Instead — matching the precedent of the Loop-13 "duplicate closure log" cleanup (commit `d564a04`) — this supplement files alongside the primary log with a new timestamp and explicitly documents the missed bundle, the corrected metrics, and the updated backlog state. Future loops should treat the **union** of the primary log + this supplement as the canonical Loop-24 closure record.

## What was missed in the primary Loop-24 closure log

PR #90 (`squad/wi-bundleEE-loop24-spflevel-policy-pins`, head `16229fd`, merged to main at `97308af`) is a Loop-24 work item — explicitly tagged `WI-bundleEE: Loop-24 SPFLevel policy invariants (Group PP, 6 WIs)` — that landed AFTER the primary closure log was written. It is not a Loop-25 work item; the PR title, body, branch name, and test prefix all bind it to Loop-24. The primary closure log §"Shipped this cycle" table therefore undercounts by 1 PR and §"Test contract growth" undercounts by 6 Swift Testing functions.

## Corrected facts (apply alongside the primary Loop-24 closure log)

### Shipped this cycle (corrected — 2 bundle PRs + primary closure log + this supplement)

| # | Bundle | PR | Status | Group | Tests |
|---|---|---|---|---|---|
| 1 | **EE-OO** Kwame L13-2 + L13-4 densified partial closure for `snapToNearest` (second picker leaf) | #89 | **merged** `dfb2189` | OO | +2 |
| 2 | **EE-PP** SPFLevel public-surface policy invariants (`displayName` / `modelMultiplier` / `rawValue` closure / `Identifiable.id` / `Codable` round-trip + on-disk JSON shape / `allCases` ordering) | #90 | **merged** `97308af` | PP | +6 |

The two PRs share the umbrella "Bundle EE" name because they were both prepared in the same cycle against the same Loop-24 directive, but they exercise distinct surfaces (`ForecastPickerLogic.snapToNearest` vs. `SPFLevel`'s entire public API) and consumed two distinct doubled-letter test prefixes (OO + PP — both predicted as free in the Loop-23 closure log §"Local-environment notes" line 110).

### Convergent HIGH findings closed this loop (corrected)

| Finding | Reviewer | Disposition |
|---|---|---|
| Cold-start race leaf contract for `snapToNearest` densified — 5 probe-date × 2 empty-equivalent-snapshot matrix (10 cells) at `ForecastPickerLogic.swift` lines 67–70 | Kwame L13-2 (extended — second leaf, denser sampling) | **Bundle EE-OO** (OO1) |
| Picker leaf referential-transparency contract for `snapToNearest` densified — sampled across clamp-low + in-window pass-through + clamp-high branches (3 outcome cells), asserted across a `clearStoredPreferences` invocation against isolated `UserDefaults(suiteName:)`, plus post-clear erasure invariants on `selectedSkinTypeKey` + `lastRoundedCoordinateKey` | Kwame L13-4 (extended — second leaf, three-branch sampling) | **Bundle EE-OO** (OO2) |
| `SPFLevel.displayName` pinned per-case against README §3 option list + "Unprotected reference" disclosure-copy capitalization | Kwame L13 (SPFLevel surface pin — NEW for Loop-24) | **Bundle EE-PP** (PP1) |
| `SPFLevel.modelMultiplier` pinned for all five cases — closes the `default`-branch coverage gap where only `spf70Plus → 50` was previously pinned, protects the Schalka & Reis (2011) SPF-as-multiplier policy + the SPF-70+ → SPF-50 regulatory-conservatism cap | Kwame L13 / Wheeler indirect | **Bundle EE-PP** (PP2) |
| `SPFLevel(rawValue:)` closed-set pin over {1, 15, 30, 50, 70} with explicit nil pins for {0, 2, 25, 45, 60, 100, -1} — protects the `UserPreferenceStorage.restoredSPF` coercion fallback against silent option-set expansion | Kwame L13 / Gi indirect (storage coercion) | **Bundle EE-PP** (PP3) |
| `SPFLevel.id == rawValue` Identifiable conformance pinned across all five cases — protects `ForEach(SPFLevel.allCases)` picker diffing stability against silent SwiftUI churn | Kwame L13 / Iris indirect | **Bundle EE-PP** (PP4) |
| `SPFLevel` Codable round-trip identity pinned for all five cases AND on-disk JSON shape pinned to literal Int rawValue (not string, not keyed object) — protects `ForecastStore` cache + `UserDefaults` archive compatibility | Kwame L13 / Plunder indirect (GDPR Art.17 erasure round-trip shape compatibility) | **Bundle EE-PP** (PP5) |
| `SPFLevel.allCases` ordering tied to README §3 user-facing option list verbatim + explicit exclusion of `.unprotectedReference` + index-1 = `.spf30` default-selection slot linkage | Kwame L13 / Suchi indirect (Greta P1 default-of-SPF-30 invariant) | **Bundle EE-PP** (PP6) |

### Test contract growth (corrected)

Pre-Loop-24 Swift Testing count: **290** (post-Loop-23 baseline, unchanged from the primary closure log).

This loop (corrected):
- Group OO (Bundle EE-OO, 2 WIs): **+2** (already documented in primary log)
- Group PP (Bundle EE-PP, 6 WIs): **+6** — NEW in this supplement (PP1 `displayName` per-case; PP2 `modelMultiplier` all-five; PP3 `rawValue` closed-set with negative pins; PP4 `Identifiable.id == rawValue` all-five; PP5 Codable round-trip + on-disk JSON shape; PP6 `allCases` README linkage + exclusion + default-index)

Loop net merged (corrected): **+8** Swift Testing functions. Post-merge total on main: **298 @Test functions** (verified locally via `./build.sh` on `16229fd`: `Test run with 298 tests in 0 suites passed after 0.480 seconds with 2 known issues`). The 2 pre-existing known issues remain unchanged.

XCUI smoke unchanged at **9**.

### Files added/modified (corrected — Bundle EE-PP addition)

#### Bundle EE-PP (#90) — SPFLevel public-surface policy invariants

- `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift` — **+163 lines** (Group PP MARK header documenting the OO → PP one-step extension of the doubled-letter cascade + 6 `@Test` functions PP1–PP6). No source files touched. ADR-0001 line citations unaffected — `test_S5_adr0001CitationsMatchLiveSourceLineNumbers` stays green. The bundle is pure test-coverage growth against the existing `SPFLevel.swift` surface (lines 1–46 of the public type definition + its `displayName` / `modelMultiplier` switches + `allCases` override). Because no source files were touched, the **tenth consecutive cycle** (after Bundle W in Loop-16 through Bundle EE-OO in Loop-24) of zero ADR-0001 citation refresh need is preserved.

### Group name convention note (corrected)

The primary closure log §"Group name convention note" documents OO as the Group OO consumption. This supplement adds Group PP consumption. After Loop-24:

| Doubled letter | Status at end of Loop-24 |
|---|---|
| BB | taken (MainScreenCleanupContractTests.swift) |
| CC | taken (BurnTimeCalculatorTests.swift, CC1–CC9) |
| DD | taken (BurnTimeCalculatorTests.swift — Loop-20 Bundle AA) |
| EE | taken (EE1–EE6) |
| FF | taken (FF1–FF6) |
| GG | taken (GG1–GG3) |
| HH | taken (HH1–HH3) |
| II | taken (II1–II3) |
| JJ | taken (JJ1–JJ6) |
| KK | taken (BurnTimeCalculatorTests.swift — Loop-21 Bundle BB) |
| LL | taken (BurnTimeCalculatorTests.swift, LL1–LL9) |
| MM | taken (BurnTimeCalculatorTests.swift — Loop-22 Bundle CC) |
| NN | taken (BurnTimeCalculatorTests.swift — Loop-23 Bundle DD) |
| OO | taken (BurnTimeCalculatorTests.swift — Loop-24 Bundle EE-OO) |
| **PP** | taken (BurnTimeCalculatorTests.swift — Loop-24 Bundle EE-PP, NEW this supplement) |
| **UU** | **free** ✅ — natural Loop-25 first-pick (QQ/RR/SS/TT all reserved for the post-`UU` cascade; verified via `grep -cE 'test_(UU|VV|WW|XX|YY)[0-9]' app/Tests/UVBurnTimerCoreTests/*.swift` → 0) |

**Next free doubled letter at Loop-25 cycle-start (post Loop-24 OO + PP consumption) is UU** (QQ/RR/SS/TT remain reserved per the prior cascade convention to keep the doubled-vowel + doubled-consonant separation; UU/VV/WW/XX/YY all verified free).

### Goals checklist state (corrected — end of cycle)

- ✅ **Working app** — main green throughout; PR #89 + PR #90 + PR #91 all merged. `./build.sh` Debug + tests + Release green locally with warnings-as-errors against `16229fd`; **298 Swift Testing functions** + 2 pre-existing known issues (unchanged). UI tests `testToolbarRendersBothSettingsAndEstimateInfoButtons` and the other 8 XCUI smoke tests all passed.
- ✅ **UI/UX approved** — Iris L01–L04 closed. No outstanding HIGH Iris findings. Loop-24 made no UI changes.
- ✅ **User scenarios captured** — README §1-11 unchanged. PP6 explicitly ties `SPFLevel.allCases` ordering to the README §3 source-of-truth verbatim ("SPF defaults to 30 and can be changed to 15, 30, 50, or 70+"), formalizing the README↔code linkage that was previously implicit. PP3 + PP6 + PP2 collectively make the Greta P1 default-of-SPF-30 invariant **quadruply pinned** (storage coercion line 1303, picker default `allCases[1]`, displayName `"30"`, modelMultiplier `30`).
- ✅ **Expert approved** — All prior expert sign-offs preserved. Bundle EE-PP additionally hardens: (a) Wheeler's SPF-70+ → SPF-50 conservatism cap (PP2 pins `spf70Plus.modelMultiplier == 50` directly on the `SPFLevel` surface rather than only indirectly via the `ProductCopy.aboutHowThisWorks` parity guard at line 6498), (b) Plunder's GDPR Art.17 erasure-flow round-trip data-shape compatibility (PP5 pins the on-disk JSON shape to the literal Int `30` so a future `Codable` synthesis change cannot break the persistence-erase round-trip), and (c) Suchi's Greta P1 default-of-SPF-30 invariant (PP6's index-1 = `.spf30` pin + PP1's displayName `"30"` pin).
- ❌ **Code tested and validated** — automated portion green throughout. **Hardware-gated sign-off blocks remain UNFILLED** per WI-21 — neither `iris-contrast-qa-checklist.md` nor `iris-launch-readiness-checklist.md` polarized-OLED sign-offs can be signed by an automated agent or CI runner. Goal 5 remains ❌ until a hardware-equipped owner signs off. Per WI-21 hard constraint the coordinator made **no edits** to either checklist's sign-off block this cycle (or to `plunder-eu-counsel-checklist.md` or `privacy-policy.md` §15).

### Cycle metrics (corrected)

- **Open PRs at cycle start:** 0
- **PRs merged this cycle (corrected):** 3 — PR #89 Bundle EE-OO (`dfb2189`), PR #91 primary closure log (`0750e88`), PR #90 Bundle EE-PP (`97308af`) — plus this supplement-log PR pending
- **Loop-24 PRs in CI queue at cycle close:** 0 (this supplement-log PR is the only new opening)
- **Tests added (merged, corrected):** **+8** Swift Testing fns (Group OO ×2 + Group PP ×6)
- **Reviewers spawned:** 0 (coordinator-driven, per the primary closure log §"Model selection" note)
- **Convergent HIGH findings closed (merged, corrected):** 0 NEW findings beyond the existing Kwame L13-2/L13-4 densification — PP1–PP6 are public-surface POLICY pins on `SPFLevel`, which is a new coverage CHANNEL (not previously pinned by KK/MM/NN/OO whose focus is `ForecastPickerLogic` leaves) but does not close a previously-open HIGH finding from the Loop-13 enumeration. PP1–PP6 are best classified as **proactive policy-surface densification** of a load-bearing public type, in the same spirit as the leaf-purity densifications but on a different layer (domain-type policy vs. picker-logic leaf-purity).
- **Cycle duration (corrected):** ~1h 25m from cycle-open to the end of this supplement-log writeup (the primary closure log captured only the first ~50m through PR #91 merge).
- **Compile retries:** 0 (zero compile-fix iterations across either bundle)

### Backlog state (entering Loop-25, corrected)

| Status | Items |
|---|---|
| ✅ Done & merged this cycle (corrected) | Bundle EE-OO (#89) — Kwame L13-2 (densified — second leaf 5×2 matrix) cold-start race + Kwame L13-4 (densified — second leaf 3-branch sampling) picker state on clear; **Bundle EE-PP (#90) — SPFLevel public-surface policy invariants × 6 (displayName / modelMultiplier / rawValue closed-set / Identifiable.id / Codable round-trip + JSON shape / allCases README linkage)** |
| ⏸ Deferred to Loop-25 | Plunder L05 additional hero-card-region link (convergent Iris+Plunder ratification needed for the WHERE design decision); Suchi L02/L03 (Maya stale-hero + Maya pull-to-refresh persona-coverage updates — reviewer-input-blocked beyond source-text guards); Kwame L13-2 / L13-4 multi-file refactors (call-site state-machine re-shape in `ForecastPickerView.swift` + `UVBurnTimerSession.swift` and the post-clear `@State` refresh path — leaf-level contracts now FULLY pinned with matrix-density + three-branch coverage on ALL THREE picker leaves AND the `SPFLevel` domain-type now FULLY pinned with public-surface policy coverage); natural next densification target if the cadence continues is one of the ancillary helpers (`clamp` / `roundedDownToHour` / `sameHourOnDay` / `hours(for:in:)`) OR one of the remaining domain types (`FitzpatrickSkinType` matching the SPFLevel PP-pattern, or `ForecastSnapshot` shape invariants) |
| 🚫 Hardware-blocked | Unchanged from primary closure log: Iris contrast-QA sign-off + launch-readiness sign-off (WI-21 — physical OLED iPhone + WCAG meter + polarized filter); EU counsel sign-off rows in `.squad/files/plunder-eu-counsel-checklist.md` E1–E10; Bundle T's L1 cover photosens row (Loop-14 T2); Bundle U's EU representative TBD (Plunder L02 — `{EU_REPRESENTATIVE_TBD}` in `.squad/files/privacy-policy.md` §15, requires repo owner + EU counsel); Bundle V's hero VoiceOver double-bind close (Loop-15 V3); Bundle X's X2 Retry button 44pt floor (Loop-17 — physical sun verification); Bundle Y's five-element `clearStoredSkinTypeAndRequireReattestation()` flow (Loop-18 — manual override → L1 re-fire flow); Bundle Z's per-row MED qualifier discipline (Loop-19 ZZ1 — pure source-text, no hardware needed but inherited from Bundle Z's listing for completeness). Bundle EE-PP does not add new hardware-gated companion rows — all 6 PP tests are pure-function tests with no rendering surface that requires physical-device verification. |

### Sequence of cycle commits on main (chronological — corrected)

1. `dfb2189` (PR #89, **Bundle EE-OO**) — Loop-24 Kwame L13-2 + L13-4 densified partial closure for `snapToNearest`
2. `0750e88` (PR #91, **primary closure log**) — Loop-24 closure log (written before PR #90 merged)
3. `97308af` (PR #90, **Bundle EE-PP**) — Loop-24 SPFLevel policy invariants (Group PP, 6 WIs) — merged AFTER primary closure log

### What did not ship and why (no changes from primary closure log)

All "What did not ship" items from the primary Loop-24 closure log §"What did not ship and why" remain accurate — Bundle EE-PP did not unblock any of them and the coordinator made zero edits to any hardware-gated sign-off blocks, the EU representative placeholder, or the source files outside the test file.

### End-of-loop parallel review pass (supplement)

The primary closure log's §"End-of-loop parallel review pass" remains substantively accurate at the persona-by-persona level. The corrections below reflect Bundle EE-PP's additional persona impact:

- **Gaia (architecture):** Bundle EE-PP's policy pins on `SPFLevel` are architecturally consistent with the existing domain-type / pure-enum convention; PP4 (`Identifiable.id == rawValue`) and PP5 (Codable Int-rawValue JSON shape) explicitly reinforce the Swift Forecast Codable cache + UserDefaults archive shape contracts that the architecture assumes implicitly elsewhere.
- **Kwame (iOS / Swift):** OO1/OO2 already documented in primary log. **PP1–PP6 are the FIRST cycle to pin the SPFLevel surface as a unified policy block** — prior coverage was scattered across 5–8 individual `displayName` / `contextLabel` / `rawValue` checks that did not collectively close the README §3 promise as a single contract. PP1–PP6 establish the cadence for future per-domain-type policy bundles (FitzpatrickSkinType is the natural next candidate for a parallel QQ/RR/SS-prefixed bundle if Loop-25 pursues domain-type densification).
- **Iris (UI/UX + a11y):** PP4's `Identifiable.id == rawValue` pin protects picker `ForEach` diffing stability — a regression here would manifest as silent SwiftUI cell churn (perf + a11y-focus disturbance), which no other test would catch. PP1's `displayName` pin protects the `"SPF \(displayName)"` accessibility label string already pinned at line 3543 (JJ1).
- **Wheeler (photobiology):** PP2's `spf70Plus.modelMultiplier == 50` direct pin on the `SPFLevel` surface (rather than only indirectly via the `ProductCopy.aboutHowThisWorks` parity guard at line 6498) materially strengthens the regulatory-conservatism cap: the contract is now pinned on BOTH the data-side (SPFLevel) and the copy-side (ProductCopy parity guard), so a future refactor cannot pass the parity guard while silently changing the cap value.
- **Gi (regulatory adjacency):** PP3's closed-set pin over `SPFLevel(rawValue:)` protects the `UserPreferenceStorage.restoredSPF` coercion fallback (line 1301–1308) against silent option-set expansion — a regulatory invariant for the SPF-defaults-to-30 promise that GDPR Art.5 (purpose limitation) implicitly requires.
- **Ma-Ti (testing + QA):** Total test count corrected from primary log's 292 to **298** (8 added this cycle, not 2). XCUI smoke unchanged at 9. The PP-prefix introduces the FIRST policy-surface-bundle convention into the test suite — future loops can use this PP-bundle shape as the template for per-domain-type policy densification on `FitzpatrickSkinType`, `ForecastSnapshot`, etc.
- **Suchi (personas):** PP6's index-1 = `.spf30` pin + PP1's `displayName == "30"` pin make the Greta P1 default-of-SPF-30 invariant **quadruply pinned** (storage line 1303, picker default `allCases[1]`, displayName `"30"`, modelMultiplier `30`). PP1's `"Unprotected reference"` capital-U pin protects the disclosure-copy capitalization that flows into Asha P4's photosensitizer-cohort disclosure scenarios.
- **Plunder (regulatory):** PP5's on-disk JSON-shape pin (literal Int rawValue) protects the GDPR Art.17 erasure-round-trip data-shape compatibility — a Codable shape change could break the persistence-erase round-trip, which would prevent the erasure flow from being verifiable post-erasure (e.g., re-reading a previously-stored `.spf30` archive after a clear would fail decoding and silently fall back to the coercion default, masking incomplete erasure). PP5 makes this shape contract explicit and machine-checkable.
- **Argos (release / ops):** No release-engineering work. PR #90's CI runs completed in ~6 minutes each (faster than the typical 9–10m envelope of recent cycles, consistent with the runner queue having drained between cycles). Local-vs-CI parity held (298 tests + 2 known issues identical local and CI).

**Review consensus (corrected):** Loop-24 actually shipped **TWO bundles** (EE-OO + EE-PP) totaling **+8 Swift Testing functions**, not the +2 the primary closure log records. The notable achievement is therefore TWO-fold: (a) **completing matrix-density + three-branch coverage on the entire picker-leaf-function set** (Bundle EE-OO, as documented in the primary log), AND (b) **establishing the first unified domain-type public-surface policy bundle** (Bundle EE-PP on SPFLevel), creating the template for future domain-type densification. The Loop-25 backlog is updated accordingly — the natural Loop-25 target is either (1) call-site refactor work (now doubly safely guarded by complete leaf contracts + SPFLevel policy contracts), (2) ancillary helper densification, or (3) a parallel PP-pattern domain-type policy bundle on `FitzpatrickSkinType`.

## Process learning recorded

The Loop-24 coordinator opened PR #90 during the cycle but pre-declared the cycle complete in the primary closure log before #90's CI completed and merged. Future cycles should adopt the rule: **the closure-log PR is opened only AFTER all in-flight cycle PRs have either merged or been explicitly deferred to the next loop with a note in §"What did not ship".** If a PR is in CI at closure-log writeup time, either (a) wait for CI before writing the closure log, or (b) write the closure log against the realistic-projected-end-state and amend with a supplement (this cycle's approach) if reality diverges. The supplement approach has the advantage of preserving the primary log unchanged and creating an explicit second commit that future tooling/archeology can detect, so it is acceptable as a fallback — but the wait-for-CI-first approach is the preferred default for Loop-25 onward.

## Co-authored-by

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
