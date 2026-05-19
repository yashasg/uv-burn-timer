# Plunder — History

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
