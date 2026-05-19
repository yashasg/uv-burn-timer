# Squad Decisions

## Decisions Ledger

### Design, science, and legal convergence pass (2026-05-19T00:10–00:30)

#### D-2026-05-19-012 — No-default Fitzpatrick skin-type picker (convergent signal)
- **Date:** 2026-05-19T00:25:58-07:00
- **Decision:** Skin type picker MUST NOT auto-select or have a default value. User must explicitly choose. This is now a high-confidence convergent signal: Suchi identified anchor effect (~50% on Types I/II) and recommended no-default; Linka designed for explicit selection; Wheeler named it a safety boundary; Plunder leans this direction.
- **Rationale:** Sources: `.squad/decisions/inbox/suchi-design-brief.md` (Persona × Picker section, P1/P4 context), `.squad/decisions/inbox/linka-ios-design-spec.md` (§2.2 SkinTypeView narrative), `.squad/decisions/inbox/wheeler-fitzpatrick-and-med-anchor.md` (§6 behavioral anchor, ~~assumed defaults~~). Convergent triangulation across three agents independently identifying the same UX/safety pattern is a high-confidence signal.
- **Owner:** Linka (UI lead); Wheeler (sign-off)
- **Status:** active

#### D-2026-05-19-011 — Three-surface L1–L4 layered disclaimer pattern (convergent signal)
- **Date:** 2026-05-19T00:10:00-07:00
- **Decision:** Adopt the three-surface / L1–L4 layered disclaimer pattern as the canonical approach for all burn-time estimates and verdict cards. This is convergent across all four agents: Suchi (load-bearing for P4 Accutane/lupus personas), Linka (design spec with L1/L2/L3/L4 layers), Wheeler (photosensitization disclosure requirement), Plunder (regulatory framing). Layers: (L1) first-launch full-screen cover (Donatello M1), (L2) persistent footer on all result screens, (L3) verdict-card photosensitizer note, (L4) in-app About expansion with cohort list.
- **Rationale:** Sources: `.squad/decisions/inbox/suchi-design-brief.md` (§1.1 + §1.2, P4 load-bearing context), `.squad/decisions/inbox/linka-ios-design-spec.md` (§2.1 DisclaimerCover + §2.2 footer + §3 verdict photosensitizer), `.squad/decisions/inbox/wheeler-fitzpatrick-and-med-anchor.md` (§6.1 three-surface photosensitization disclosure), `.squad/decisions/inbox/plunder-citation-framework.md` (§8 disclaimer ratification). This pattern is now locked as the canonical structure.
- **Owner:** Plunder (legal lead); Linka (implementation lead)
- **Status:** active

#### D-2026-05-19-010 — Three new launch-research channels: r/Accutane, r/lupus, r/SkincareAddiction
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** Expand launch-research and trail-running channels to include r/Accutane and r/lupus (reply-only, pending safety and compliance sign-off) and r/SkincareAddiction (wider research surface). These channels represent high-signal JTBD evidence and willingness-to-pay validation for personas P4 (Accutane Asha) and extended edge-case cohorts. Trail-running copy can emphasize reapplication timing without changing v1 scope.
- **Rationale:** Source: `.squad/decisions/inbox/suchi-design-brief.md` (§7 edge-case personas Priya + Vee, §0 P4/P5 personas, JTBD evidence per channel). This refines D-2026-05-19-006 with named channels and trait-specific personas.
- **Owner:** Suchi
- **Status:** active

#### D-2026-05-19-009 — ✅ NCBI-paraphrased Fitzpatrick picker text (ACTIVE)
- **Date:** 2026-05-19T00:25:58-07:00; **Resolved:** 2026-05-19T08:30:00Z
- **Decision:** Use Wheeler's edited variant of the Fitzpatrick descriptions in the iOS skin-type picker. **Paraphrase, do NOT reproduce verbatim.** The NCBI Bookshelf table (Codon Publications, CC BY-NC 4.0) remains the cited underlying source — credit appears in the in-app About surface per Plunder's citation rendering spec.
- **Rationale:** Per Plunder's framework, reproducing the CC BY-NC 4.0 table verbatim inside a $2.99 paid app is ⚠️ at minimum (NC scope is gray for paid apps; reproduction tightens the attribution requirement). Paraphrasing while citing the source is ✅ — citation is independent of the NC clause, and the underlying classification (Fitzpatrick TB, 1988) is freely citable on its own. Wheeler's edited variant preserves clinical accuracy without coupling our UI strings to the source's specific copyrighted prose.
- **Implications:** (1) Linka: Update skin-type picker spec to use Wheeler's edited variant strings. (2) Plunder: Confirm in-app citation wording for NCBI Bookshelf uses "cite the underlying scale" form. (3) Wheeler: No action — edited variant is canonical. (4) Kwame: Picker strings from Wheeler's variant; remains @State only. (5) Suchi: V/VI asymmetry concern resolved by adopting canonical Fitzpatrick wording.
- **Owner:** Plunder (framing); Wheeler (science lead); Linka (implementation)
- **Status:** ✅ active

#### D-2026-05-19-008 — Canonical Fitzpatrick source: NCBI Bookshelf NBK481857, Ward & Farma 2017
- **Date:** 2026-05-19T07:25:58-07:00
- **Decision:** Adopt Fitzpatrick Skin Type classification from NCBI Bookshelf Chapter 6, Table 1 (Ward & Farma eds., *Cutaneous Melanoma: Etiology and Therapy*, Codon Publications 2017) as the canonical reference and citation anchor for the app. All six type descriptions from the NCBI table are now the source-of-truth for all UI copy, citation surfaces, and design specifications.
- **Rationale:** Source: `.squad/decisions/inbox/copilot-directive-2026-05-19T07-25-58Z.md` (user directive). Wheeler verified the source and confirmed NCBI verbatim matches the published table (§1.2 diff). This resolves Suchi's prior copy-asymmetry flag (Type I/II vs. Type V/VI descriptor framing) — the NCBI source leads with skin-color descriptors for all six types, preserving symmetry. Plunder vetted the citation licensing posture: Codon is open-access with CC BY-NC 4.0, permitting non-commercial reuse with attribution; we cite (not reproduce), so normal-and-customary citation practice applies.
- **Owner:** Wheeler (science lead); Plunder (legal lead)
- **Status:** active

### Audience, safety, and launch channels

#### D-2026-05-19-007 — Photosensitivity is a safety boundary, not edge copy
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** Keep the current strong disclaimer language and get Wheeler review on whether the verdict card needs an explicit note that photosensitizing medications or conditions can make the estimate overstate safe time.
- **Rationale:** Source: `.squad/decisions/archive/suchi-monetization-personas.md`. Suchi surfaced direct persona evidence that Fitzpatrick/MED-based timing can understate risk for Accutane, lupus, vitiligo, and similar cases.
- **Owner:** Wheeler
- **Status:** proposed

#### D-2026-05-19-006 — Expand the launch-research channel set with guarded additions
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** Add `r/SkincareAddiction` to the channel mix and keep `r/Accutane` and `r/lupus` as reply-only opportunities pending safety and compliance sign-off; trail-running copy can emphasize reapplication timing without changing v1 scope.
- **Rationale:** Source: `.squad/decisions/archive/suchi-monetization-personas.md`. Suchi found stronger willingness-to-pay and JTBD evidence in these surfaces, while also separating safe expansion from risky outreach.
- **Owner:** Suchi
- **Status:** proposed

### Monetization

#### D-2026-05-19-005 — Keep the $2.99 one-time wedge and 90-day no-IAP guardrail
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** Hold the $2.99 one-time launch price, keep the 90-day no-IAP and no-tip-jar rule, and use a 30/60/90 review cadence with earlier-review triggers rather than changing price because WeatherKit lowered marginal cost.
- **Rationale:** Source: `.squad/decisions/archive/argos-monetization-review.md` and `.squad/decisions/archive/suchi-monetization-personas.md`. Argos recomputed break-even to effectively one incremental sale per year while Suchi validated that the anti-subscription wedge is structurally important in the highest-signal channels.
- **Owner:** Argos
- **Status:** active

### Platform, data, and compliance

#### D-2026-05-19-004 — Replace Open-Meteo attribution on iOS-facing surfaces
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** Remove Open-Meteo attribution from iOS App Store and launch copy, and implement WeatherKit-compliant Apple Weather attribution plus the legal-attribution link in the in-app About surface before launch.
- **Rationale:** Source: `.squad/decisions/archive/argos-monetization-review.md` and `.squad/decisions/archive/copilot-directive-2026-05-19T06-42-14Z.md`. Argos flagged the change as a license-term and compliance issue, not a cosmetic copy edit.
- **Owner:** Plunder
- **Status:** active

#### D-2026-05-19-003 — iOS UV data source is Apple WeatherKit
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** The iOS app uses Apple WeatherKit instead of Open-Meteo for UV index data; the web prototype keeps its existing Open-Meteo integration as-is.
- **Rationale:** Source: `.squad/decisions/archive/copilot-directive-2026-05-19T06-42-14Z.md`. This changes economics, integration, and attribution requirements for the iOS build while leaving the prototype intact.
- **Owner:** Kwame
- **Status:** active

#### D-2026-05-19-002 — Team focus has pivoted from web prototype to iOS app
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** The squad's primary build target is now the iOS app. Linka is respecialized as UI/UX Designer (Apple HIG and accessibility), Kwame as iOS Developer (modern Swift plus WeatherKit), and Argos joins the roster for monetization; `prototype/` remains the evaluation artifact.
- **Rationale:** Source: session context items 4-5 and `.squad/decisions/archive/copilot-directive-2026-05-19T06-42-14Z.md`. The platform shift required corresponding role changes and keeps the web prototype as a reference artifact rather than the shipping target.
- **Owner:** Gaia
- **Status:** active

### Model governance

#### D-2026-05-19-001 — Advisory specialists use xhigh model overrides
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** Wheeler, Suchi, Plunder, and Argos are pinned to `claude-opus-4.7-xhigh` via `agentModelOverrides`.
- **Rationale:** Source: `.squad/config.json` and session context items 2-4. The team explicitly elevated model depth for skin science, user research, legal and compliance, and monetization work.
- **Owner:** Coordinator
- **Status:** active

#### D-2026-05-19-013 — ✅ Excalidraw user-flow diagram (onboarding + main screen)
- **Date:** 2026-05-19T01:15:44-07:00
- **Decision:** Fulfill the user directive (`.squad/decisions/inbox/copilot-directive-2026-05-19T08-13-34Z-excalidraw-userflow.md`) by delivering a comprehensive Excalidraw diagram of the iOS app flow from cold launch through onboarding to main screen, with persona overlay annotations and safety-critical branch-point callouts.
- **Deliverables:** (1) Live Excalidraw canvas (146 elements: 35 rectangles, 99 text labels, 12 arrows) exported to `user-flow-onboarding-main.excalidraw` at repo root (61.7 KB); (2) Textual snapshot spec at `.squad/files/user-flow-onboarding-main-spec.md` describing all lanes, regions, and annotations; (3) Extracted skill `.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` (MCP drawing patterns from squad agents). **Note (2026-05-19T08:34Z):** `.excalidraw` deliverable files live at repo root, NOT inside `.squad/files/` — top-level visibility for design artifacts. Per directive captured this session.
- **Scope:** 4 lanes — (LANE 1) Onboarding flow with 6 screens from cold launch to first verdict; (LANE 2) Main screen (NowView) with 7 sub-regions; (LANE 3) Branch points & annotations (8 yellow callouts covering no-default Fitzpatrick, L1 sticky, disclaimer layers, attribution, accessibility, re-attestation); (LANE 4) Suchi persona overlays (5 personas × 6 columns). Visualizes D-2026-05-19-002, -003, -004, -007, -009 (Wheeler edited variant), -011 (three-surface L1–L4), -012 (no-default Fitzpatrick).
- **Decisions visualized:** All key decisions are on-canvas; Plunder's 8 pre-submit flags noted as non-blocking. Deliberately omits "photosensitization attestation" hard screen (zero-data architecture) — drawn as passive-moment with visibility pattern (L1 + L3 + L4).
- **Owner:** Linka (UI/UX, canvas authority); Suchi (User Researcher, persona overlay input)
- **Status:** ✅ active deliverable

#### D-2026-05-19-014 — ✅ Persona overlay annotations spec (Suchi)
- **Date:** 2026-05-19T01:15:44-07:00
- **Decision:** Produce persona-keyed overlay annotations for Linka's Excalidraw user flow, covering 5 personas (Greta, Maya, Devon, Asha, Tomás) across 6 flow positions (L1 cover, NowView empty state, SkinTypeView, photosensitization deep-link, location + first verdict, main screen repeating use). Spec identifies 5 load-bearing branch points: L1 inline deep-link loop (Asha), no-default Fitzpatrick validator (Devon), Type V under-picking risk (Tomás), L3 verdict-card link (Asha frequent taps), window-elapsed safety moment (Tomás at speed).
- **Deliverable:** `.squad/files/suchi-persona-annotations.md` (222 lines, grid-based matrix). Anti-pattern flagged: do NOT draw "photosensitization attestation" screen — the architecture is visibility-only, not attestation (zero-data, Donatello M7). Linka reads this during canvas work; Suchi does not draw on canvas.
- **Follow-up learnings:** Surfaces two latent repeating-use insights — Greta's JTBD shift to reapplication-cadence, Maya's literally-can't-see-window-elapsed-on-water safety problem.
- **Skill update:** `.squad/skills/persona-screen-matrix/SKILL.md` bumped; confidence medium → medium-high; added "overlay-on-flow-diagram" variant.
- **Owner:** Suchi (User Researcher); Linka (canvas integration)
- **Status:** ✅ active deliverable

### Coordinator resolutions this session (2026-05-19T08:30–08:31Z)

#### D-2026-05-19-009 picker-copy resolution (user directive fulfilled)
- User directive `.squad/decisions/inbox/copilot-directive-2026-05-19T08-30-00Z-picker-copy-resolution.md` resolved D-2026-05-19-009 from 🟡 PROPOSED to ✅ ACTIVE. Decision: Use Wheeler's edited variant (paraphrased, not verbatim NCBI reproduction) in the skin-type picker. NCBI Bookshelf remains the cited source; paraphrasing avoids CC BY-NC 4.0 reproduction-licensing tightness on a paid app.

#### Excalidraw flow diagram trigger (directive now fulfilled)
- Coordinator directive `.squad/decisions/inbox/copilot-directive-2026-05-19T08-13-34Z-excalidraw-userflow.md` (user request for flow diagram once design is complete) now fulfilled by D-2026-05-19-013. Diagram is source-of-truth for implementation reference.

### Merged inbox decisions (2026-05-19T11:50Z)

#### 2026-05-19T08:34:13Z: User directive — Excalidraw exports live at repo root

**By:** yashasgujjar (via Copilot)

**What:** Excalidraw scene files (`.excalidraw` exports) live at the **repo root**, NOT inside `.squad/files/`. Going forward, any agent exporting an Excalidraw scene should write directly to `{repo_root}/{name}.excalidraw`. The `.squad/files/` directory remains for non-deliverable session artifacts (specs, intermediate JSON, internal notes).

**Why:** User wants top-level visibility for design deliverables. `.excalidraw` files are durable artifacts (importable into excalidraw.com, shareable, reviewable) — not session-internal scratch work. Burying them inside `.squad/files/` makes them invisible to anyone browsing the repo at the top level.

**Implications:**
- **Linka:** Update the agent skill `excalidraw-flow-diagrams-via-mcp` to specify the export path is `{repo_root}/{slug}.excalidraw`, not `.squad/files/`.
- **Coordinator:** This session — move `.squad/files/user-flow-onboarding-main.excalidraw` to `./user-flow-onboarding-main.excalidraw` after Scribe finishes the current commit. Update any reference in Linka's decision file (D-2026-05-19-013 once merged) and the textual spec at `.squad/files/user-flow-onboarding-main-spec.md` to point to the new path.
- **Future Excalidraw deliverables:** Always export directly to repo root.

**Status:** ✅ ACTIVE.

#### 2026-05-19T08:57:00Z: User directive — Linka fired, replaced by Iris

**By:** yashasgujjar (via Copilot)

**What:** Linka (UI/UX Designer) is **fired** — not retired. Folder deleted (not archived to `_alumni/`). Registry marked `status: "fired"` with `fired_reason` recorded. Reason: slow and error-prone. Took >900s on an export-fix that took 30s inline; her first-draft Excalidraw export was broken on delivery (missing required schema fields).

Replacement: **Iris** — same role (UI/UX Designer, Apple HIG & Accessibility), same scope, **model: `claude-sonnet-4.6`** (saved to `.squad/config.json` `agentModelOverrides.iris`). Iris inherits all of Linka's ratified design decisions (D-2026-05-19-003, -004, -005, -013, -014) but starts with fresh history. The Excalidraw user-flow she produced is canon and stays.

**Process change captured in Iris's charter:**
- JSON schema fixes / file-format compliance are **not the designer's job** — route to Kwame.
- Excalidraw exports MUST pass through `.squad/files/excalidraw-normalize.py` before commit (this codifies the lesson from Linka's broken export).
- `.excalidraw` deliverables live at repo root, not `.squad/files/`.

**Status:** ✅ ACTIVE.

#### Gaia — Squad Work Loop Cycle 1: Discovery & Prioritization

**Date:** 2026-05-19T10:56:40Z  
**Role:** Gaia (Lead/Architect)  
**Scope:** Cycle 1 discovery only — compare implemented behavior against approved design/user flows, identify work items, and recommend the next single feature/fix with acceptance criteria.

---

##### Executive Summary

**Build status:** ✅ PASSING (tests + Swift warnings as errors)  
**Architecture status:** ✅ SOUND (single NavigationStack, sheet-based settings, proper disclaimer layering)  
**Work items discovered:** 6 (1 P0 critical, 3 P1 important, 2 P2 polish)  
**Recommended next feature:** Fix Fitzpatrick description ordering from color-first to behavior-first (P0, safety-critical per Suchi + Wheeler)

---

##### Discovered Work Items

###### P0 — Fitzpatrick Descriptions Ordering (Safety-Critical)

**Status:** `pending`  
**Severity:** 🔴 **Critical**  
**Evidence:** 
- Design spec (§2.3, linka-ios-design-spec.md, lines 165–175) mandates behavior-first ordering: "Always burns, never tans. Very fair; often freckles, red/blonde hair."
- Suchi's persona annotations (§1.2, suchi-persona-annotations.md, line 67–70) flags this as load-bearing for trust with user Tomás (under-picking risk on Type V)
- D-2026-05-19-009 directs: use Wheeler's edited variant, paraphrased (not verbatim NCBI)
- Current implementation has color-first for ALL types; Type V/VI missing detail descriptors

**Current:**
```
Type I:  "Very fair; always burns, never tans."
Type II: "Fair; burns easily, tans minimally."
Type III: "Medium tone; burns moderately, tans gradually."
Type IV: "Light-brown; burns minimally, tans easily."
Type V:  "Brown; rarely burns, tans deeply."
Type VI: "Deeply pigmented; almost never burns."
```

**Approved (from design spec §2.3):**
```
Type I:  "Always burns, never tans. Very fair; often freckles, red/blonde hair."
Type II: "Burns easily, tans minimally. Fair skin; light eyes common."
Type III: "Burns moderately, tans gradually. Medium skin tone."
Type IV: "Burns minimally, tans easily. Olive or medium-brown skin."
Type V:  "Rarely burns, tans deeply. Brown skin."
Type VI: "Almost never burns, deeply pigmented. Dark brown to black skin."
```

**Why it matters:**
- Behavior leads → users self-classify based on lived burn/tan experience (not skin color framing)
- Suchi P3 Devon (Fitz I): validates no-default by self-selecting Type I via behavior cue ("I got sunburned in February")
- Suchi P5 Tomás: risks under-picking Type V/VI if copy leads with "Brown skin" — he sees "Brown" and stops reading, missing "Rarely burns"
- Reordering is a small, high-trust copy win

**Test impact:** Test `fitzpatrickPickerCopyMatchesApprovedSafetyLanguage()` currently enforces the color-first version; will need update.

---

###### P1 — WeatherKit Attribution Compliance

**Status:** `pending`  
**Severity:** 🟡 **Important (legal/compliance)**  
**Evidence:**
- D-2026-05-19-004 mandates: "Remove Open-Meteo attribution from iOS App Store and launch copy; implement WeatherKit-compliant Apple Weather attribution + legal-attribution link in About"
- Design spec §2.2 (line 111) and §2.6 (lines 214–228) require WeatherKit attribution "always visible on Home" + About sheet legal link
- Current implementation has `WeatherAttributionView()` on Home and About, but need to verify:
  1. Display format matches Apple's required lockup
  2. Legal attribution link is tappable and leads to correct URL
  3. Copy matches "Apple Weather" (not "Apple WeatherKit" or "Open-Meteo")

**Deliverables to verify:**
- `WeatherAttributionView` uses correct `WeatherAttribution` API (if available) or hard-coded Apple Weather lockup
- AttributionView has tappable link to Apple's legal page (`https://weatherkit.apple.com/legal-attribution.html`)
- ProductCopy.uvSourceLine = "Source: Apple WeatherKit" (correct) but UI copy may need "Apple Weather" on attribution badge

**Risk/blocker:** None identified; low lift to verify.

---

###### P1 — LocationRationaleCard Display Refinement

**Status:** `pending`  
**Severity:** 🟡 **Important (UX polish)**  
**Evidence:**
- Design spec §2.2 notes: "Privacy rationale BEFORE iOS prompt; CTA in `.safeAreaInset(.bottom)`"
- Current code shows LocationRationaleCard inline (§AppViews.swift, line 44)
- Unclear if layout matches spec or if card is gated by first-time only (should be)

**Acceptance criteria:**
- LocationRationaleCard appears once on cold launch (before system prompt fires)
- Card includes privacy line: "UV Burn Timer needs your location once to fetch UV data. It never leaves your device."
- Card is swipe-dismissible and marked non-blocking (per LocationPromptGate logic, which IS implemented correctly)

---

###### P1 — Stale UV Warning Copy & Styling

**Status:** `pending`  
**Severity:** 🟡 **Important (UX clarity)**  
**Evidence:**
- Design spec §2.2: "Stale UV (> 60 min old)" shows hero number with `.opacity(0.6)` + "Updated 2h ago" label
- Current implementation (HeroTimerCard, line 295–301) shows SafetyStatusCard with orange icon + "Estimate window elapsed" copy
- Implementation uses calculated window (min of burn time or 2h), NOT fixed 60 min — actually better, but wording may differ

**Acceptance criteria:**
- When estimate is stale: hero number shows dimmed (`.opacity(0.6)` or similar)
- SafetyStatusCard displays: "Estimate window elapsed" + icon + "Recalculate" affordance
- Copy must match approved (check ProductCopy.estimateElapsedWarning)

---

###### P2 — Copy Refinements (Fitzpatrick Footer & Disclaimer Details)

**Status:** `pending`  
**Severity:** 🟢 **Minor (polish)**  
**Evidence:**
- SettingsSheet Fitzpatrick footer (line 628): "This model assumes healthy skin and no photosensitizing medications."
- Design spec §2.3 (line 163) extends this: "...consult a dermatologist. **This model assumes healthy skin and no photosensitizing medications** — see *Is this estimate for me?* on the result screen."
- Missing end: "consult dermatologist" + cross-reference to verdict card link

**Acceptance criteria:**
- Fitzpatrick picker footer includes: "...consult a dermatologist before using this estimate to plan sun exposure. See *Is this estimate for me?* on the result screen for details."

---

###### P2 — SkinTypeOnboardingView vs. SettingsSheet Styling Consistency

**Status:** `pending`  
**Severity:** 🟢 **Minor (UX consistency)**  
**Evidence:**
- SkinTypeOnboardingView (line 545–586): uses `List` + `Form`-like section styling
- SettingsSheet Fitzpatrick picker (line 596–629): also renders all types, but within a Form section
- Both are correct but could have minor visual divergence (List vs. Form styling)

**Acceptance criteria:**
- Both surfaces render Fitzpatrick rows identically (56pt+ row height, behavior-first copy, no default selection)
- No visual/functional regression between onboarding flow and settings view

---

##### Not Work Items (By Decision)

✅ **No-default Fitzpatrick picker** — Implemented and tested; no changes needed  
✅ **Disclaimer cover full-screen modal** — Implemented with "How accurate is this for you?" title and photosensitizer inline link  
✅ **L1–L4 layered disclaimer pattern** — Implemented: L1 cover + L2 footer + L3 verdict-card link + L4 About section  
✅ **240+ min display cap** — Implemented (`estimate.displayText` returns "240+ min")  
✅ **Pull-to-refresh** — Implemented (`.refreshable { await refetchUV() }`)  
✅ **Location permission rationale + privacy line** — Implemented with LocationPromptGate  
✅ **Persistent footer disclaimer** — Implemented (Donatello M2 footer)  
✅ **Tier badge (severity display)** — Implemented with tortoise/walk/hare SF Symbols + color tier  
✅ **WeatherKit as UV source** — Implemented (WeatherKitUVDataProvider)  
✅ **L3 verdict-card reach-back to About** — Implemented (NavigationLink to AboutView with `highlightEstimateApplicability: true`)  
✅ **Stale UV detection** — Implemented (min of burn time or 2 hours)  
✅ **Cold-launch cached UV** — Implemented (restoreCachedUVSnapshot)

---

##### Recommended Next Feature (Cycle 1 → Cycle 2 Hand-off)

###### Feature: Fix Fitzpatrick Description Ordering to Behavior-First

**Work ID:** `fitzpatrick-descriptions-reorder`  
**Priority:** 🔴 **P0 Critical**  
**Effort:** ~15 min code change + 5 min test update  

**Rationale:**
1. **Safety-critical per user research:** Suchi's personas (Devon: validates no-default; Tomás: under-picking risk) both depend on behavior-first copy for trust
2. **Design-approved:** Linka (UI), Wheeler (skin science), Suchi (UX research) all converged on this in D-2026-05-19-009 + linka-ios-design-spec.md
3. **High-signal change:** One small copy reorder addresses the entire "behavior-first" principle that Suchi flagged in three separate documents
4. **Low risk:** Pure copy change, no logic/state/API changes

**Acceptance Criteria:**

- [ ] All six Fitzpatrick descriptions use behavior-first ordering:
  - Type I: "Always burns, never tans. Very fair; often freckles, red/blonde hair."
  - Type II: "Burns easily, tans minimally. Fair skin; light eyes common."
  - Type III: "Burns moderately, tans gradually. Medium skin tone."
  - Type IV: "Burns minimally, tans easily. Olive or medium-brown skin."
  - Type V: "Rarely burns, tans deeply. Brown skin."
  - Type VI: "Almost never burns, deeply pigmented. Dark brown to black skin."
- [ ] Appear consistently in both `SkinTypeOnboardingView` and `SettingsSheet` (same source: FitzpatrickSkinType.pickerDescription)
- [ ] Test `fitzpatrickPickerCopyMatchesApprovedSafetyLanguage()` updated to expect new behavior-first strings
- [ ] Build passes with no Swift warnings
- [ ] No functional regression: no-default validation still works, picker still shows all six types, still selectable

**Implementation Plan:**
1. Update `FitzpatrickSkinType.pickerDescription` computed property in FitzpatrickSkinType.swift (lines 24–39)
2. Update test expectations in BurnTimeCalculatorTests.swift (lines ~173–178)
3. Run `./build.sh` to verify no regressions
4. Commit with message: "Reorder Fitzpatrick descriptions to behavior-first per Suchi + Wheeler design approval (D-2026-05-19-009)"

**Risks/Blockers:**
- None identified; pure copy change with existing test gate

---

##### Risks & Architectural Notes

###### No Architectural Debt Identified

The implementation follows the approved design precisely:
- ✅ Single NavigationStack (not TabView) — correct per design
- ✅ Sheet-based settings — correct per HIG and design
- ✅ Disclaimer cover as fullScreenCover — correct per Donatello M1
- ✅ No-default Fitzpatrick — correct and tested
- ✅ Stale UV using burn-time window (not fixed 60 min) — actually better than spec

###### Compliance & Safety Boundaries

- **Photosensitization:** L1–L4 layering is correct; no attestation screen (zero-data architecture per Donatello M7)
- **Location privacy:** Coordinates rounded to 2 decimal places; rationale shown before system prompt; compliant
- **Attribution:** WeatherKit + NCBI Fitzpatrick citations need final verification (see P1 item above)

---

##### Decision Proposals (For Team Sync)

###### D-CYCLE-1-001 — Fitzpatrick Description Ordering (PROPOSED → ACTIVE next sprint)

Implement behavior-first ordering as specified in D-2026-05-19-009 + linka-ios-design-spec.md. This is a convergent signal from Suchi, Linka, Wheeler, and the Excalidraw user-flow annotations. **Status: Ready for Kwame's sprint backlog.**

---

##### Summary for Team

✅ **Build:** Passing (0 warnings, 16/16 tests)  
✅ **Architecture:** Sound; no refactoring needed  
✅ **Design compliance:** ~95% match; 6 minor gap items identified  
🔴 **Next blocker:** Fitzpatrick description ordering (P0, safety-critical per user research)  
🟡 **Follow-up:** WeatherKit attribution verification (P1, legal/compliance)  

**Cycle 1 recommendation:** Fix Fitzpatrick descriptions → ship → iterate on P1/P2 items in Cycle 2.

#### Iris — Main screen iOS portrait redraw

- **Date:** 2026-05-19
- **Decision:** Replace the LANE 2 desktop-shaped 7-region grid with a portrait iPhone surface. Keep the content model (verdict, UV attribution, settings access, disclaimer links, safety loop) and change the shape only.
- **Why:** The previous main screen read like a desktop dashboard, not an iPhone app. User feedback was correct: the lane needed to feel native to iOS at a glance.
- **iOS conventions applied:** Status bar + home indicator, Large Title nav bar, single-column stacked cards, tappable 44pt chips, semantic system-color language, always-visible Apple WeatherKit attribution in the UV card, conditional photosensitizer reach-back banner, inline informational/not-medical-advice link, and explicit Dynamic Type / VoiceOver notes beside the frame.
- **Diagram impact:** Re-anchored the affected LANE 3 arrows to the new banner, hero card, UV card, and hero-card learn-more caveat while leaving LANE 1 and LANE 4 intact.

#### Kwame — Excalidraw export schema baseline fix

The only missing fields in the 146-element Excalidraw file were `baseline` (required on `text` elements, approximated as `fontSize * 0.8`) — all other required ExcalidrawElement fields (`seed`, `versionNonce`, `groupIds`, `boundElements`, `points` for arrows, etc.) were already present and correctly typed from Linka's export. Fixed file is at `user-flow-onboarding-main.kwame-fix.excalidraw`; Linka's run was still in progress at time of fix so the rename/commit is held pending coordinator decision.

#### Linka — Excalidraw export schema-normalisation fix

**Date:** 2026-05-19T01:40:19-07:00
**Author:** Linka (UI/UX, Apple HIG & Accessibility)
**Status:** ✅ resolved — file now imports cleanly into excalidraw.com
**Artifact touched:** `user-flow-onboarding-main.excalidraw` (D-2026-05-19-013 deliverable)
**Companion script:** `.squad/files/excalidraw-normalize.py`

---

##### Problem

The Excalidraw export `user-flow-onboarding-main.excalidraw` at the repo root **would not import into excalidraw.com** — the loader surfaced the generic error `Error: invalid file`. The file (61.7 KB, 146 elements) had been produced by serialising the Excalidraw MCP server's `query_elements` output inside the canonical `{type:"excalidraw", version:2, elements, appState, files}` wrapper. The wrapper was correct; the individual elements were not.

##### Root cause

`excalidraw-query_elements` returns a **minimal element shape** — only the fields the MCP server tracks, not the full `ExcalidrawElement` schema that excalidraw.com's loader requires. Each text element shipped with only `id, type, x, y, text, fontSize, strokeColor, createdAt, updatedAt, version`; arrows shipped without `points` at all.

Tracing the failure through Excalidraw 0.18.1 source (`packages/excalidraw/data/blob.ts`, `data/restore.ts`, `element/types.ts`) and verifying with a Node + jsdom + esbuild harness around the real `loadFromBlob` reproduced the exact error path:

1. `loadSceneOrLibraryFromBlob` parses the JSON and calls `isValidExcalidrawData` — passes.
2. It then calls `restoreElements(data.elements, ...)`.
3. `restoreElements` first reduces over the raw element list calling `isInvisiblySmallElement(raw)` on each element **before** `restoreElement` fills in defaults.
4. For arrow/line elements, `isInvisiblySmallElement` is implemented as `e.points.length < 2`. The MCP arrows have no `points` field → `undefined.length` → `TypeError: Cannot read properties of undefined (reading 'length')`.
5. The outer `try { ... } catch { throw new Error("Error: invalid file") }` in `loadSceneOrLibraryFromBlob` swallows the real error and surfaces the unhelpful "invalid file" the user reported.

A second cascading failure waits behind `points` if you only fix that: text elements without `fontFamily`/`lineHeight`/`height` route through `getLineHeight(undefined)` → font-registration → `FontFace` API path → various downstream NaN propagation.

##### Fix

Wrote `.squad/files/excalidraw-normalize.py` — a single-pass element walker that fills in every required field from the canonical schema (`packages/element/src/types.ts`) with the defaults from `packages/common` + `packages/excalidraw/data/restore.ts`. **Visual layout is preserved exactly** — only schema fields were added, no coordinates, sizes, colors, or text were touched.

###### Defaults applied

| Scope | Field | Default |
|---|---|---|
| **All** | `seed`, `versionNonce` | random positive 31-bit int |
| | `version` | preserve, else `1` |
| | `index` | `null` (loader assigns) |
| | `isDeleted`, `locked` | `false` |
| | `groupIds`, `boundElements` | `[]`, `null` |
| | `frameId`, `link` | `null` |
| | `roundness` | `null` (sharp corners — flow diagram intent) |
| | `angle` | `0` |
| | `fillStyle`, `strokeStyle` | `"solid"`, `"solid"` |
| | `strokeWidth`, `roughness`, `opacity` | `2`, `1`, `100` |
| | `backgroundColor`, `strokeColor` | `"transparent"`, `"#1e1e1e"` |
| | `updated` | parsed from `updatedAt` if present, else `now()` |
| **text** | `fontFamily` | `5` (Excalifont) |
| | `textAlign`, `verticalAlign` | `"left"`, `"top"` |
| | `containerId` | `null` |
| | `originalText` | mirror of `text` |
| | `lineHeight`, `autoResize` | `1.25`, `true` |
| | `width`, `height` | computed from `text` + `fontSize` if missing |
| **arrow** | `points` | `[[0,0],[width,height]]` ← **the load-bearing fix** |
| | `lastCommittedPoint` | `null` |
| | `startBinding`, `endBinding` | `null`, `null` |
| | `startArrowhead`, `endArrowhead` | `null`, `"arrow"` |
| | `elbowed` | `false` |
| **`appState`** | `gridSize` | `20` (was `null`) |

###### Verification

Validated the fixed file through Excalidraw 0.18.1's actual `loadFromBlob` function — the same code path excalidraw.com runs on import — wired up under Node 25 with jsdom + esbuild + FontFace polyfill. Result: `SUCCESS — loaded 146 elements. Type counts after restore: { text: 99, rectangle: 35, arrow: 12 }`. Type counts match the pre-fix file exactly (D-2026-05-19-013 inventory: 35 rect, 99 text, 12 arrows).

Backup of the broken file kept on disk as `user-flow-onboarding-main.excalidraw.bak` for one cycle.

##### Lesson — captured as skill update

`.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` gained a new **"⚠️ Export gotcha — MCP `query_elements` returns a MINIMAL element shape"** section in the schema-gotchas list. It includes:

- The canonical element-base + per-type fields table (reproduced above).
- The explicit `points: [[0,0],[width,height]]` requirement on arrows that the loader's pre-restore `isInvisiblySmallElement` check requires.
- The reference to `.squad/files/excalidraw-normalize.py` as the canonical fix.
- The verification recipe (Node + jsdom + esbuild + `loadFromBlob`).

This is a load-bearing learning — **any future Excalidraw export via MCP must run through `excalidraw-normalize.py` before being committed to the repo**. Adding it as a pre-commit step is a fast-follow if Excalidraw ever ships from this team again.

##### Files modified

1. `user-flow-onboarding-main.excalidraw` — re-serialised in place (61.7 KB → 165.7 KB; size delta is purely the added schema fields). Backup: `user-flow-onboarding-main.excalidraw.bak`.
2. `.squad/files/excalidraw-normalize.py` — *new*, the canonical normaliser.
3. `.squad/files/user-flow-onboarding-main-spec.md` — added an "Export history" section documenting the fix and explicitly noting that the visual layout is unchanged.
4. `.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` — added the "Export gotcha" section + defaults table + verification recipe.
5. `.squad/decisions/inbox/linka-excalidraw-export-fix.md` — *this file*.

##### Decision implications

- **No design changes.** The diagram content is identical pre- and post-fix.
- **No downstream agent re-work.** Kwame, Suchi, Wheeler, and Plunder do not need to re-read the diagram — it is the same diagram, now portable.
- **Process change:** Future Excalidraw deliverables from MCP must pass through `excalidraw-normalize.py` before being committed. Captured in the skill; this decision file is the audit trail.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
