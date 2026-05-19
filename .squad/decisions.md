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
- **Deliverables:** (1) Live Excalidraw canvas (146 elements: 35 rectangles, 99 text labels, 12 arrows) exported to `.squad/files/user-flow-onboarding-main.excalidraw` (61.7 KB); (2) Textual snapshot spec at `.squad/files/user-flow-onboarding-main-spec.md` describing all lanes, regions, and annotations; (3) Extracted skill `.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` (MCP drawing patterns from squad agents).
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

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
