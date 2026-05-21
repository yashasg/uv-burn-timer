## Summary (Recent Focus — 2026-05-20 to 2026-05-21)

**Current role:** Legal & compliance reviewer; ensures health-adjacent features meet regulatory boundaries (MDCG, FDA, FTC, MDR, MHRA).

**Recent major decisions:**
1. **Location privacy rationale (2026-05-20):** Ratified that clearing saved location does NOT clear rationale ack; rationale ack persists across clears because it represents informed-consent state (static fact), not data point. Uninstall is the universal escape hatch.
2. **UVI forecast compliance audit (2026-05-21):** Apple Weather analogue is **invalid** — they display atmospheric scalar; we output personalized health (UVI × Fitzpatrick × SPF → burn time). Photosensitized cohort (D-2026-05-19-007) is foreseeable; silence on forecast surface is non-compliant regardless of Apple's posture.
3. **Minimum compliant surface (locked):** Reuse L3 chevron ("Is this estimate for me?") at forecast card foot, pointing to About anchor with photosensitizer enumeration (D-2026-05-19-011 locked string). Zero new copy. Satisfies MDCG 2019-11 §3.3, FDA foreseeable-misuse, FTC § 5, MDR Annex VIII Rule 11.

**Key patterns established:**
- Health-adjacent personalization (user data + formula output) crosses regulatory threshold that atmospheric-data-only products do not cross. Big-player precedent does not transfer.
- Foreseeable-misuse doctrine: if a cohort exists and will use your feature, regulatory silence on that surface is deceptive omission.
- Reusable pattern: L3 chevron "Is this estimate for me?" links to existing L4 About anchor, reducing new copy and new surface area while meeting disclosure requirement.

**Skills created:**
- `big-player-analogue-compliance-test/SKILL.md` — diagnostic for "if big-player-X doesn't have to, why should we?" claims. Checklist: same output type? same user cohort? same risk profile?

---

## Core Context

- **Project:** A UV exposure and sunburn timer app
- **Role:** Legal & Compliance Reviewer
- **Joined:** 2026-05-18
- **Requested by:** yashasgujjar

## Learnings

### 2026-05-19T00:30:00-07:00 — Citation framework, disclaimer wording, WeatherKit attribution, App Store claim review

Delivered: `.squad/decisions/inbox/plunder-citation-framework.md`. Summary below.

**Legal pack of sources (✅ for our $2.99 paid commercial app, with attribution):**

- **Fitzpatrick skin type** — Primary: Fitzpatrick TB (1988) *Arch Dermatol* 124(6):869–871, doi:10.1001/archderm.1988.01670060015008 (cite-only ✅). Secondary: NCBI Bookshelf NBK481857 / Codon 2017 (⚠️ — see below).
- **MED dose math** — Diffey BL (1991) *Phys Med Biol* 36(3):299–328 doi:10.1088/0031-9155/36/3/001 (cite-only ✅) + CIE S 007/E-1998 (cite by document number only — no table reproduction).
- **UVI scale** — Primary text anchor: NOAA / NWS / EPA documentation (✅ public domain). Secondary citation: WHO INTERSUN 2002 (⚠️ NC — cite, do not reproduce).
- **Photosensitizers** — FDA labeling guidance (✅ public domain) + Moore DE 2002 *Drug Saf* doi:10.2165/00002018-200225050-00004 (cite-only ✅) + NIH MedlinePlus (✅ public domain). Class names only, no brand names.
- **SPF math** — FDA OTC Sunscreen Monograph 21 CFR Part 352 (✅ public domain) + ISO 24444 (cite by document number only).
- McKinlay & Diffey (1987) *CIE Journal* 6(1):17–22 — cite-only ✅ for action-spectrum origin.
- Madronich et al. (1998) *J Photochem Photobiol B* — cite-only ✅ for atmospheric UV.

**Sources to AVOID (or use cite-only with strict limits) in our commercial paid app:**

- Wikipedia (CC BY-SA 4.0 ShareAlike contagion — never primary).
- DermNet NZ (CC BY-NC-ND — prefer FDA/MedlinePlus instead).
- StatPearls (CC BY-NC-ND — cite-only at best).
- AAD / Cleveland Clinic / Mayo / WebMD pages — all-rights-reserved — cite-only.
- Brand-named medications anywhere in our copy — class-by-name only.

**NCBI Bookshelf NBK481857 — critical finding:**

The user-picked source is *Cutaneous Melanoma: Etiology and Therapy* (Ward & Farma eds., Codon Publications, Brisbane, 2017), Chapter 6, Table 1. It is **NOT** a U.S. federal public-domain work and **NOT** StatPearls. The Codon Publications colophon contains a license discrepancy — the prose says "CC BY 4.0" but the link points to CC BY-NC 4.0 and the explanatory text describes the NC license. Controlling reading is **CC BY-NC 4.0**. Verdict for our paid app:

- ✅ **Cite freely** with the attribution string: "Ward WH, Farma JM, editors. *Cutaneous Melanoma: Etiology and Therapy*, Ch. 6 Table 1. Brisbane (AU): Codon Publications; 2017. doi:10.15586/codon.cutaneousmelanoma.2017.ch6"
- ⚠️ **Do NOT reproduce verbatim** in the picker UI without written permission from Codon — NC restricts commercial reproduction. Use Plunder's paraphrase (Path A in framework §2.3) instead. Paraphrase honors Suchi's symmetric-wording directive AND removes the NC question.

**WHO INTERSUN NC verdict:**

WHO's open-access default is CC BY-NC-SA 3.0 IGO. WHO's published policy explicitly says "Permission is required for commercial uses…in the context of a commercial activity." A $2.99 App Store app IS commercial activity.

- ✅ **CITATION is OK** — citing a work is not exercising a Licensed Right; NC scope applies to reproduction/adaptation, not to citation.
- 🚫 **REPRODUCTION is NOT OK** without WHO permission — no tables, figures, or running text from INTERSUN in our app.
- ✅ **Use NOAA / EPA as the primary text anchor** for the UVI conversion (0.025 W/m² per UVI). WHO is the international cross-reference, cited but never reproduced.

**WeatherKit attribution spec:**

- Required elements: (1) Apple Weather lockup visible wherever WeatherKit data appears; (2) tappable link to data-source attribution from any WeatherKit-data screen.
- **Canonical URL:** `https://developer.apple.com/weatherkit/data-source-attribution/` (per Apple's own WeatherKit Get Started page, verified 2026-05-19T00:30:00-07:00). The `weatherkit.apple.com/legal-attribution.html` URL also resolves but the developer.apple.com URL is the one Apple's docs direct to. Hard-code with a launch-readiness checklist item.
- **In-app About panel string:** "Weather and UV index data provided by Apple Weather, with data sourced from a range of providers." + tappable "Other data sources" Link.
- **App Store description line (replaces the prior Open-Meteo CC BY 4.0 line):** "Weather data: Apple Weather. Other data sources are listed in the in-app About screen."
- Trademark posture: use the supplied lockup, no recoloring or modification.

**Disclaimer wording — three-layer model (matches Linka §8.4 / Suchi §6 / D-2026-05-19-007):**

- **Layer 1 — First-launch full-screen cover.** Title: "How accurate is this for you?" Body: ~110-word paragraph including "Estimated burn time only. Not medical advice. Skin response varies. …If you take a photosensitizing medication or have a sun-sensitive condition, this estimate may overstate your safe time. See *Is this estimate for me?* in About. …For children, consult a pediatrician for sun-safety guidance." Single dismiss button: "I understand." Re-fires every cold launch (Donatello M1).
- **Layer 2 — Persistent footer.** Verbatim from prototype: "Model estimate only. Not medical advice. Reapply sunscreen every 2 hours regardless of timer." Always visible on burn-time screens.
- **Layer 3 — Verdict-card link.** "Is this estimate for me?" — deep-links to About → "When this estimate may not apply" anchor (the photosensitization caveat). This is the new persona-keyed surface for Suchi P4 (Asha) reachability.

**Rejected disclaimer variants (and why):**

- 🚫 "Safe sun time" — "safe" implies safety guarantee, App Store §1.4.1.
- 🚫 "Personalized for your skin" — "personalized" is regulated medical-app vocabulary.
- 🚫 "Time before sunburn" — "before" claims certainty; use "to skin reddening" or "to 1 MED."
- 🚫 "Don't worry, this is safe" — promotional false confidence.
- 🚫 Brand-named medications in disclaimer — use therapeutic classes only.

**App Store claim review — key rewrites:**

- "your skin can handle" → "**may cause skin reddening**" (advisory → informational).
- Drop "Weather data: Open-Meteo (CC BY 4.0)." → replace with WeatherKit line above (D-2026-05-19-004).
- "UV Burn Timer" name ✅; subtitle "Estimated burn time, no subscription." ✅ unchanged.
- App Store category Utilities ✅ (not Health & Fitness, not Medical) — hold this posture.

**Skill extracted:** `.squad/skills/health-adjacent-citation-licensing-decision-tree/SKILL.md` — generalizable protocol for tiering sources ✅/⚠️/🚫 by license + use-type for any health-adjacent paid commercial app.

**Open attorney escalations:** E1 NCBI verbatim, E2 WHO INTERSUN NC scope, E3 App Store category posture, E4 photosensitizer copy, E5 WeatherKit URL stability, E6 disclaimer wording, E7 Privacy/ToS health-clauses (Gaia ownership), E8 trademark sweep of "UV Burn Timer." None block design/build; all reviewed before App Store submit.

**Cross-check Wheeler (his brief landed 2026-05-19T00:25:58-07:00):**

- **NCBI / Codon source identification** — ✅ Wheeler nailed the bibliographic and license posture. Same as my §2.
- **Picker verbatim text** — ⚠️ → ✅ with conditions. Wheeler recommends shipping the NCBI verbatim. I ratify either his Option 1 (verbatim with "adapted from" attribution + attorney-review flag E1 retained) OR Option 2 (Wheeler's "edited variant" — "Very fair skin / Fair skin / Medium skin tone / Light-brown skin / Brown skin / Deeply pigmented skin"). Plunder leans Option 2 because it moots the NC question and aligns better with Suchi's symmetric behavior-first directive.
- **Clinical-accuracy ask:** Wheeler's V/VI rows keep "Never burns" — flag for Wheeler whether "Rarely burns" is more accurate population-wide given the photosensitization cohort.
- **MED anchor table** (Sayre 1981, Fitzpatrick 1988, Diffey 1991, Harrison & Young 2002, CIE S 007/E:1998) — ✅ all cite-only, all legally clean. Numerical values are facts and Wheeler's table presentation is our copyrighted work.
- **Time-to-burn formula** `t = (MED × SPF) / (UVI × 0.025 × 60)` — ✅ formula and constants are facts, citations to WHO 2002 + Diffey 1991 + Schalka & Reis 2011 all clean. Wheeler citing WHO as primary for the 0.025 constant is compatible with my framework (citation is outside NC scope; only reproduction is restricted).
- **Photosensitization disclaimer line** — Wheeler's L1 wording gets one Plunder edit: add "Your pharmacist or clinician can confirm whether your specific situation applies." to clear App Store §1.4.3 by pointing to the clinician resolution path rather than treating the list as the app's judgment.
- **No-default-picker recommendation** — ✅ supports our claim-surface bound (we don't implicitly recommend a "typical" type).
- **"What we DON'T claim"** — ✅ aligned with my §8.9. Team has converged.

Wheeler's brief is shippable. Convergence on legally-defensible science + citation posture achieved across Wheeler, Suchi, Linka, and Plunder. Argos's App Store rewrites are the remaining ✅ blocker for submit-readiness.

### 2026-05-20T17:43:54-07:00 — UVI 10-day forecast disclaimer call; "if Apple doesn't need it, we don't either" pushback

Delivered: `.squad/decisions/inbox/plunder-uvi-forecast-disclaimer-call.md`. Verdict: **⚠️ borderline → rewrite required.** The user's premise (Apple-as-analogue) is regulatorily wrong; the user's preference (don't add visual noise) is honorable and can be met without giving up the safety boundary. Summary:

**Apple Weather is not a valid analogue.** Apple shows raw atmospheric UVI in a general-weather product — no personalization layer, no health claim. Our app computes a body-keyed output: Fitzpatrick × SPF × UVI → personalized burn window today, personalized category band per day on the forecast. **The personalization layer that makes us valuable is the same layer that puts us inside the rule set Apple sits outside of.** Cite — the line that draws it: FDA 2019 *General Wellness Policy* §III.B (intended-use claim limited to general wellness; foreseeable cohort use creates a disclosure obligation); MDCG 2019-11 §3.3/§4.3 (software performing calculation on individual data is MDSW; lifestyle-and-well-being software is not, *provided intended use is unambiguously communicated to the user*). The L3 reach-back is the unambiguity mechanism. Drop it and we weaken our own MDSW-exclusion argument.

**Foreseeable-misuse doctrine attaches even with Wheeler's §5.4 hedge** (no burn-time minutes on out-days). The category band itself is read inside our app's "your skin" context. For an Asha-class user (isotretinoin, tetracyclines, fluoroquinolones, thiazides, sulfonamides, amiodarone, voriconazole, methotrexate, St John's Wort; post-laser / post-peel / post-retinoid-initiation per D-2026-05-19-007), a "low UVI Thursday" forecast cell is foreseeably read as "Thursday is safe to plan exposure" — and we know (Wheeler says so in writing) that UVI is not the controlling variable for that cohort. Foreseeable-misuse doctrine (FDA 2019 §III.B.2; FTC §5 deceptive-omission line; emerging health-app duty-of-care case law e.g. *Babylon Health* MHRA 2020, US period-tracker class actions 2021–2023) requires the warning to be reachable from the result surface, not buried in Settings.

**Prior decisions bind by their plain terms; cannot be implicitly satisfied.** D-2026-05-19-007 elevated photosensitization from "edge copy" to "safety boundary" — a safety boundary is a property of the product, not of a single screen. D-2026-05-19-013 explicitly required *visibility from the result surface*, not attestation, not Settings-buried. The forecast surface is a NEW result surface that produces personalized outputs. By the plain terms of both decisions, it requires its own re-surfacing of the L3 affordance. The L1 cover fires only at cold launch (won't survive into a forecast-only-tap user journey); L2 footer is reused and inert (gets us "not medical advice" but not the cohort reach-back); the verdict-card L3 doesn't render on the forecast tab. Therefore explicit re-surfacing is needed.

**Minimum compliant surface — the actual answer Iris implements:**

- One chevron-disclosure affordance at the foot of the forecast card. Label: *"Is this estimate for me?"* — the existing locked L3 string. **Zero new copy.** Deep-links to the existing About `notForMe` anchor where the D-2026-05-19-007 photosensitizer enumeration already lives.
- Wheeler's drafted §5.3 paragraph relocates from "on-card seed copy" → "About destination paragraph." Same wording, different surface. The drug-class enumeration stays at the destination, never on the forecast card.
- L2 footer is reused unchanged. No second footer line. No yellow box. No banner. No modal. No inline drug-class enumeration on-surface.
- One sentence Iris can ship from: *"Forecast surface gets the existing 'Is this estimate for me?' chevron, pointed at the existing About anchor. No new copy. No new surface. Same L3 pattern, ported."*

**Why this honors the user's underlying preference:** the user is right that Apple's clean visual rhythm is the design target. The L3 chevron is one secondary-color line — strictly smaller visual surface than Wheeler's full §5.3 paragraph proposal, strictly larger than zero. The Apple-restraint visual cadence is preserved; the safety-boundary obligation is preserved. Both honored.

**Skill extracted:** `.squad/skills/big-player-analogue-compliance-test/SKILL.md` — generalizable protocol for evaluating "regulator X doesn't make big-player Y do this, so we shouldn't have to either" arguments. The pattern is recurring: it surfaced once on WeatherKit attribution (D-2026-05-19-003/004 — same fallacy, Apple's own attribution scheme was the right answer there), and now on the forecast disclaimer. It will recur. Codifying.

**Open attorney escalations updated:** E9 (new) — confirm with outside counsel that the L3-chevron-only pattern on a numeric-suppressed (day-6+) burn-time-suppressed (all out-days) forecast surface holds general-wellness intended-use under FDA 2019 + MDCG 2019-11. Pre-counsel read: yes. Confirm-before-submit, not a build-blocker.

**Cross-check with Wheeler and Suchi:**
- Wheeler (WI-7 §5.3): wording preserved; relocation from on-card to About destination preserves scientific intent. Wheeler to confirm the relocation.
- Suchi ("non-negotiable" Asha-reachability): the chevron-on-result-surface pattern is precisely the architecture Suchi was protecting. Substance honored; form minimized. Asking Suchi to confirm.

**No code modifications by this proposal** — Scribe to merge; Kwame to wire the existing L3 NavigationLink into the forecast view; Iris owns chevron placement.

### 2026-05-21T00:55:49Z — Round 2 verdict: Apple analogue is not valid; L3 chevron pattern required

- **Apple Weather is not a valid analogue.** They display atmospheric scalar (UVIndex from NOAA / meteorological model). We personalize: UVI × Fitzpatrick × SPF → BurnTime (health-adjacent output). Personalization triggers regulatory scope (MDCG 2019-11 §3.3, FDA foreseeable-misuse, FTC § 5 deceptive-omission, MDR Annex VIII Rule 11, UK MHRA 2022).
- **Photosensitized cohort is foreseeable:** D-2026-05-19-007 enumerates them (isotretinoin, tetracyclines, fluoroquinolones, thiazides, sulfonamides, amiodarone, voriconazole, NSAIDs, phenothiazines, methotrexate, St John's Wort; conditions: lupus, porphyrias, XP, post-procedure). Silence on the forecast surface while they use the picker is non-compliant.
- **Minimum compliant surface:** Reuse existing L3 chevron ("Is this estimate for me?") at foot of forecast card, navigating to About anchor where photosensitizer enumeration already lives. Zero new copy required — reuses locked D-2026-05-19-011 string. This pattern satisfies both D-2026-05-19-013 and D-2026-05-19-007 by their plain terms on the forecast surface.
- **Reusable diagnostic created:** `.squad/agents/plunder/skills/big-player-analogue-compliance-test/SKILL.md` — for future "if big-player-X doesn't have to, why should we?" challenges. Checklist: (1) same output type? (2) same user cohort? (3) same risk profile? If any mismatch, analogue fails.
- **Handoffs:** Card footnote copy finalized (Iris); picker sheet body hedge ("Estimated; UV forecasts can be off by ±1–2 UVI beyond a few days"); day-8–10 picker refusal message; photosensitization re-disclosure on picker sheet (carry from D-2026-05-19-013 wording).
- **Orchestration log:** `.squad/orchestration-log/2026-05-21T00:55:49Z-plunder.md`


