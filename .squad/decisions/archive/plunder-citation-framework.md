# Plunder — Citation Framework, Disclaimer Wording, Attribution Spec, App Store Claim Review

**Author:** Plunder (Legal & Compliance Reviewer)
**Date:** 2026-05-19T00:30:00-07:00
**Audience:** Wheeler (source selection — primary) · Linka (citation rendering — primary) · Kwame (implementation) · Suchi (disclaimer load) · Argos (App Store surfaces) · Gaia (scope)
**Status:** Handoff. Wheeler is running in parallel and had not landed `.squad/decisions/inbox/wheeler-fitzpatrick-and-med-anchor.md` at the time of this writing — §C below verdicts the *framework* he must satisfy. If his picks land in inbox, vet them against §3 and §C2.
**Verdict legend:** ✅ cite freely (with required attribution) · ⚠️ cite carefully (named limits) · 🚫 do not cite (find alternative)

> **Header note for the team.** I am Legal & Compliance, not your attorney. This document is review-level analysis with named-rule citations, not a legal opinion. The user should engage a licensed attorney for sign-off before App Store submission, particularly for items I flag in §10. That said, every verdict below is grounded in a specific license, statute, or App Store rule I'll name.

---

## §1. Citation Licensing Taxonomy

The categories of source the app is likely to touch, with the legal posture for each.

### 1.1 U.S. federal government works (NIH/NLM/NCBI Bookshelf, NOAA, EPA, FDA, NWS, CDC, NIST)

**Verdict: ✅ cite freely, with attribution — BUT NCBI Bookshelf carries a load-bearing carve-out.**

**Rule:** Works created by U.S. federal government employees in the course of their official duties are not subject to copyright in the United States (17 U.S.C. § 105). Citation and reproduction are unrestricted.

**Carve-outs:**

- **NCBI Bookshelf is a hosting service, not a federal-work garden.** Many books on Bookshelf are third-party publications hosted by NLM under permission from the original publisher. **The license of the hosted book governs — NOT § 105.** Each Bookshelf entry has a copyright notice in its front matter or chapter footer. Read it before citing.
- **StatPearls (a common Bookshelf occupant) is published by StatPearls Publishing LLC** and licensed CC BY-NC-ND 4.0. That's a separate, more restrictive posture from "U.S. federal public domain." Treat each StatPearls chapter accordingly. (See §2 for the specific source the user picked — *not* StatPearls, but a different third-party book with its own NC license.)
- **NLM web policy:** When displaying content sourced from NLM/NCBI, NLM's web policies request acknowledgment of the source (NLM/NCBI) plus the original author/publisher. This is courtesy/policy, not copyright; we honor it because non-compliance can cause Apple review reviewers to ding us under §5.2 for unclear data provenance.
- **FDA materials:** Public domain in the U.S. (§ 105). Some FDA-distributed material is republished from third parties — check the document footer.

**Attribution form:** Author/title/publisher/year/URL. No license shield needed for true federal works.

### 1.2 WHO / UN bodies / INTERSUN

**Verdict: ⚠️ cite carefully — NC restricts reproduction but not citation. See §4 for the load-bearing decision.**

**Rule:** WHO's open-access policy (https://www.who.int/about/policies/publishing/copyright) places **all** WHO publications under **Creative Commons Attribution-NonCommercial-ShareAlike 3.0 IGO (CC BY-NC-SA 3.0 IGO)** by default. WHO explicitly states: *"Permission is required for commercial uses and licensing of WHO materials, such as using the material in the context of a commercial activity."*

This applies to the canonical UV-index reference: WHO/WMO/UNEP/ICNIRP (2002) *Global Solar UV Index: A Practical Guide* — IRIS handle 10665/42459 — the source most textbooks cite for the 0.025 W/m² per UVI conversion.

**See §4 for the full NC-scope analysis and verdict for our $2.99 paid app.**

### 1.3 CIE (International Commission on Illumination) publications

**Verdict: ⚠️ cite carefully — reference only, no reproduction.**

**Rule:** CIE publications (e.g., **CIE S 007/E-1998** "Erythema Reference Action Spectrum and Standard Erythema Dose") are copyrighted standards documents published by CIE Central Bureau, Vienna. The CIE owns the copyright and does not release the documents under any open license. They are sold; access is licensed per copy.

**What we can do:**
- ✅ Cite by document number, title, year, ISBN (e.g., "CIE S 007/E-1998") in About / citations / methodology surfaces.
- ✅ Describe the erythemal action spectrum *as a scientific concept* in our own words. Scientific facts and natural laws are not copyrightable (Feist v. Rural Telephone, 499 U.S. 340).
- 🚫 Do **not** reproduce the action-spectrum table values (wavelength × weighting), curve images, or any text of the standard verbatim.
- ✅ The numerical values *as computed model outputs* (the MED math the app performs) are fine — we compute from the formula, we don't republish the standard.

**Attribution form when cited:** "Erythema reference action spectrum: CIE S 007/E-1998 (International Commission on Illumination, Vienna)."

### 1.4 Peer-reviewed journal articles

**Verdict: ✅ cite freely (author/year/DOI). Do NOT reproduce text, figures, or tables.**

**Rule:** Citation of a published work by author, year, journal, and DOI is the universal academic-citation norm and is not a copyright act. Reproduction of the published expression (figures, abstracts, body text, tables) IS a copyright act and requires the publisher's permission unless covered by fair use (a narrow exception, not reliable for a commercial app).

**Specific sources for our domain that are ✅ to cite by name/year/DOI:**
- Fitzpatrick TB. *The validity and practicality of sun-reactive skin types I through VI.* Arch Dermatol. 1988;124(6):869–871. doi:10.1001/archderm.1988.01670060015008
- Diffey BL. *Solar ultraviolet radiation effects on biological systems.* Phys Med Biol. 1991;36(3):299–328. doi:10.1088/0031-9155/36/3/001
- McKinlay AF, Diffey BL. *A reference action spectrum for ultraviolet induced erythema in human skin.* CIE Journal. 1987;6(1):17–22.
- Diffey BL. *Sources and measurement of ultraviolet radiation.* Methods. 2002;28(1):4–13. doi:10.1016/S1046-2023(02)00204-9
- Madronich S, McKenzie RL, Björn LO, Caldwell MM. *Changes in biologically active ultraviolet radiation reaching the Earth's surface.* J Photochem Photobiol B. 1998;46(1-3):5–19.

**Attribution form:** Standard journal-style citation. URL/DOI optional but preferred. License declaration NOT needed (it's citation, not reproduction).

### 1.5 ICNIRP guidelines

**Verdict: ✅ cite by document name/year. ⚠️ do not reproduce figures or tables verbatim.**

**Rule:** ICNIRP (International Commission on Non-Ionizing Radiation Protection) publishes guidelines in Health Physics journal (LWW). ICNIRP retains copyright. Their guidelines are widely available in PDF form on the ICNIRP site under a "free download for personal/professional reference" implied-permission posture, but they are not CC-licensed.

**What we can do:**
- ✅ Cite "ICNIRP Guidelines on Limits of Exposure to Ultraviolet Radiation of Wavelengths between 180 nm and 400 nm" (Health Physics, 2004, with subsequent revisions).
- 🚫 Do not paste tables of exposure limits into the app.
- ✅ Use the limits as model inputs in our computation (fact ≠ expression).

### 1.6 Apple WeatherKit Display Requirements

**Verdict: ✅ this is contract, not copyright — comply with the contract.**

**Rule:** This is a Developer Program license/contract obligation, not an intellectual-property license. Source of truth: https://developer.apple.com/weatherkit/get-started/#attribution-requirements and the linked data-source attribution URL (see §7).

**The contract requires:**
1. The Apple Weather trademark lockup ("Weather" with Apple logo wordmark) displayed wherever WeatherKit data is presented.
2. A tappable link to the data-source attribution page from a screen reachable from any WeatherKit-data screen.

**Trademark posture:** "Apple Weather" and the Weather wordmark are trademarks of Apple Inc. We use them under the WeatherKit Developer Program license; we do **not** modify them, recolor them, or use them outside the WeatherKit context.

**Penalty for non-compliance:** Apple can revoke WeatherKit entitlement and reject the App Store submission under §5.2(a) Intellectual Property. This is not theoretical — Apple does enforce.

**Full attribution spec in §7.**

### 1.7 App Store Review Guidelines (Apple)

**Verdict: ✅ comply with the named clauses for our Utilities category.**

**Rules that apply to us, in order of weight:**

- **§1.4.1 Safety / Physical Harm.** Apps should not encourage physical harm. Health/medical apps must "provide medical information [that is] not factually inaccurate." Our posture: we are **not** a medical app (we ship under Utilities, not Medical / Health & Fitness — D-2026-05-19-002), so §1.4.1's medical-info language is not the primary frame. We still meet the "no encouragement of harm" bar by keeping copy informational and reachable disclaimers visible.
- **§1.4.3 Drugs/Medical Topics.** Apps "providing inaccurate data or information…that may be used to diagnose or treat patients" may be reviewed under §1.4.1 and §5.1. We must not provide diagnostic or treatment guidance. Burn-time **estimate** is informational; burn-time **prescription** would be advisory and is the line we cannot cross.
- **§5.1.1(ix) Health-related human-subject data.** N/A — we don't collect health data (D-2026-05-19-002, Donatello M7).
- **§5.2 Intellectual Property.** Use of third-party content (Apple Weather attribution, citations) must be properly licensed and attributed. This is the rule the WeatherKit and citation framework primarily lives under.
- **§5.4 VPN apps, §5.5 Mobile Device Management** — N/A.

**Category-specific note (Utilities, not Health & Fitness):** Choosing Utilities deliberately lowers the medical-review surface. We must hold this position with copy that does not claim health benefits. Anything in our copy that *reads* as health-benefit claim invites a reviewer to recategorize us, which is a 🚫 outcome.

---

## §2. NCBI Bookshelf — Specific Vetting of the User's Selected Source

**The user picked:** https://www.ncbi.nlm.nih.gov/books/NBK481857/table/chapter6.t1/

**What it actually is:**
- **Book title:** *Cutaneous Melanoma: Etiology and Therapy*
- **Editors:** Ward WH, Farma JM (Department of Surgical Oncology, Fox Chase Cancer Center)
- **Publisher:** **Codon Publications**, Brisbane, QLD, Australia
- **Published:** 2017 Dec 21 (first published November 2017)
- **ISBN:** 978-0-9944381-4-0
- **Chapter:** Chapter 6 (the chapter is on melanoma diagnosis & staging; the Fitzpatrick table appears within it)
- **Specific resource:** Chapter 6, Table 1 — "Fitzpatrick Classification of Skin Types I through VI"
- **Chapter DOI:** 10.15586/codon.cutaneousmelanoma.2017.ch6
- **Book DOI:** 10.15586/codon.cutaneousmelanoma.2017
- **NCBI Bookshelf ID:** NBK481857

**Critical correction to the team's assumption:** This is **NOT** a U.S. federal-work, not StatPearls, and not a public-domain document. It is hosted on NCBI Bookshelf but the copyright is held by Codon Publications.

### 2.1 License posture (the issue)

Codon Publications' colophon for this book (verified at https://www.ncbi.nlm.nih.gov/books/n/cutmel/ on 2026-05-19T00:30:00-07:00) contains a **license discrepancy**:

> "This open access book is published under Creative Commons Attribution 4.0 International (CC BY 4.0). https://creativecommons.org/licenses/by-nc/4.0/"

The **prose** says CC BY 4.0 (which would be ✅ commercial-use OK with attribution). The **link** points to **CC BY-NC 4.0** (which would be ⚠️ commercial use prohibited without permission). The explanatory paragraph that follows resolves the conflict — it reads "Users are allowed to share…and adapt…for any **non-commercial** purpose" — which is the **CC BY-NC** wording, not the CC BY wording. The CC BY license has no NC clause.

**Plunder's reading of the conflict:** The explanatory paragraph is the controlling text — it describes CC BY-NC 4.0. The "CC BY 4.0" wording in the headline appears to be a copyediting error in the colophon. The **link** is the controlling artifact. Conservative posture: **treat this book as CC BY-NC 4.0**.

### 2.2 What CC BY-NC 4.0 means for a $2.99 paid app

CC BY-NC 4.0 § 2.b.1 prohibits "exercise of the Licensed Rights for commercial advantage or monetary compensation." A paid app downloaded for money from the App Store is commercial use under any reasonable reading.

**But — and this is the relevant nuance — § 2.b applies to *reproducing* or *adapting* the licensed work. Citation (referring to the work, attributing it, providing a URL) is OUTSIDE the scope of the license.** Citation falls under either fair use (17 U.S.C. § 107), the implicit "you can talk about a book without a license" doctrine, or the basic distinction between an idea and its expression.

**Verdict:**
- ✅ **We CAN cite the source** in the in-app About panel and App Store description with full attribution (chapter, editors, publisher, year, DOI, URL). This is not a CC-license act.
- ⚠️ **Reproducing the Table 1 content VERBATIM in the iOS picker UI is a closer question.** The six rows of Table 1 are short factual descriptions; an originality-threshold defense (Feist v. Rural Telephone) is plausible because each row is one to two sentences of fact-like prose. But the safer posture for a paid commercial app is: **do not reproduce verbatim. Paraphrase clearly while preserving meaning, OR seek permission from Codon Publications.**

### 2.3 Recommendation to Wheeler & Linka

**Two paths, ranked:**

**Path A (recommended — minimal-paraphrase, commercial-safe):** Use the Fitzpatrick scale (a scientific classification, not subject to copyright) with paraphrased descriptions for the picker UI. Cite the NCBI Bookshelf chapter as one of the canonical sources for the scale in About. Example reframings:

| Type | NCBI Table 1 wording (DO NOT use verbatim) | Plunder paraphrase (✅ commercial-safe) |
|---|---|---|
| I | White skin. Always burns, never tans. | Light, very fair skin — always burns, never tans. |
| II | Fair skin. Always burns, tans with difficulty. | Fair skin — always burns, tans poorly. |
| III | Average skin color. Sometimes mild burn, tan about average. | Medium skin — sometimes burns mildly, tans gradually. |
| IV | Light-brown skin. Rarely burns. Tans easily. | Light-brown skin — rarely burns, tans easily. |
| V | Brown skin. Never burns. Tans very easily. | Brown skin — rarely burns, tans deeply. |
| VI | Black skin. Heavily pigmented. Never burns, tans very easily. | Deeply pigmented skin — rarely burns, tans deeply. |

Note on Suchi's symmetry directive: Suchi's brief §1.2 directive #4 asks for "burn behavior first, color second" framing for symmetry across all six rows. The paraphrase above honors this and gives Linka the room to format each row consistently. Wheeler should ratify the science of "rarely burns" vs. NCBI's "never burns" for V/VI — Wheeler may prefer to retain "Rarely burns" for V/VI as a clinical accuracy point regardless of the source wording, since "never burns" is clinically wrong (Fitz V/VI users DO burn — the photosensitization cohort is partly in this group).

**Path B (verbatim with permission):** Email Codon Publications (info@codonpublications.com — verify) requesting permission to reproduce Table 1 verbatim in a commercial mobile app, citing the chapter. If granted in writing, Path B is ✅. Without written permission, Path B is ⚠️.

**Plunder verdict:** Go Path A. It removes the NC question entirely (it's our text, not Codon's), preserves Suchi's symmetry directive, and lets Wheeler optimize wording for scientific accuracy.

### 2.4 Required attribution wording for the NCBI Bookshelf citation

If we cite this source (recommended — Wheeler is using it as one anchor for the scale), the attribution must include:

**In-app About surface (full form):**

> Fitzpatrick skin phototype scale. Adapted from: Ward WH, Farma JM, editors. *Cutaneous Melanoma: Etiology and Therapy* (Chapter 6, Table 1). Brisbane (AU): Codon Publications; 2017. doi:10.15586/codon.cutaneousmelanoma.2017.ch6. Available from NCBI Bookshelf: https://www.ncbi.nlm.nih.gov/books/NBK481857/

**App Store description (compact form):**

> Skin-type descriptions adapted from Ward & Farma (eds.), *Cutaneous Melanoma: Etiology and Therapy* (Codon Publications, 2017), via NCBI Bookshelf.

The word "Adapted from" is doing legal work. It signals to a reviewer/auditor that we paraphrased rather than reproduced — which is the Path A posture above.

If Path B (verbatim) is ever taken, change "Adapted from" to "Reproduced with permission from" and add the permission letter to a `LICENSES/` directory in the repo. Cannot ship Path B without that letter.

---

## §3. Recommended "Legal Pack" of Sources for Wheeler

For each scientific domain Wheeler is anchoring, here are pre-vetted sources. ✅/⚠️/🚫 verdict per source with the precise reason.

### 3.1 Fitzpatrick skin type definitions

| # | Source | Verdict | Reason |
|---|---|---|---|
| 1 | **Ward WH & Farma JM (eds), *Cutaneous Melanoma: Etiology and Therapy*, Ch. 6 Table 1, Codon Publications 2017, via NCBI Bookshelf NBK481857** | ⚠️ cite-only; paraphrase rather than reproduce | License conflict (§2.1). Citation ✅; verbatim reproduction in commercial app ⚠️ without written permission. Path A in §2.3. |
| 2 | **Fitzpatrick TB. *Arch Dermatol* 124(6):869–871, 1988** | ✅ cite-only by author/year/DOI | Peer-reviewed; standard academic citation; no reproduction. This is the originating paper and the most authoritative anchor. |
| 3 | **AAD (American Academy of Dermatology) patient-information pages on skin type** | ⚠️ cite-only with URL + access date | AAD pages are copyrighted by AAD; citation is OK, reproduction is not. AAD does not publish under CC. Some AAD content has a "for patient use, not for redistribution" footer — read each page. |

**Wheeler should anchor to source #2 (Fitzpatrick 1988) as the primary scientific citation and use source #1 (NCBI/Codon) as a secondary modern reference. Use Plunder's paraphrase in §2.3 for the picker UI. Do not cite source #3 in the app — it is a tertiary anchor at best, and the licensing is fuzzier than the alternatives.**

### 3.2 MED values per Fitzpatrick type

| # | Source | Verdict | Reason |
|---|---|---|---|
| 1 | **CIE S 007/E-1998 — Erythema Reference Action Spectrum and Standard Erythema Dose** | ⚠️ cite by document number only, no table reproduction | Copyrighted CIE standard, no open license. We can cite it as the methodology anchor and compute against it; we cannot republish the action-spectrum table. (§1.3.) |
| 2 | **Diffey BL. *Phys Med Biol* 36(3):299–328, 1991** | ✅ cite-only by author/year/DOI | Peer-reviewed; canonical source for the practical implementation of the action spectrum. Standard academic citation. |
| 3 | **McKinlay AF & Diffey BL. *CIE Journal* 6(1):17–22, 1987 — A reference action spectrum for ultraviolet induced erythema in human skin** | ✅ cite-only by author/year | Peer-reviewed; the originating action-spectrum reference. Standard citation. (Note: CIE Journal is published by CIE — the article itself is older but the citation form is OK.) |
| 4 | **Sayre RM et al. — various MED-by-Fitzpatrick papers in JAAD / Photochem Photobiol** | ✅ cite-only | Peer-reviewed; cite whichever Wheeler prefers. |

**Wheeler's MED-per-Fitzpatrick table values:** The numerical MED values per skin type are facts (J/m²); facts are not copyrightable. Wheeler may publish his locked table in our About / methodology page with citations to the papers from which he derived the values. The presentation (his table, his typography, his caveats) is our copyrighted work; the underlying numbers are not Codon's, not CIE's, not anyone's.

### 3.3 UV index → erythemal irradiance conversion (0.025 W/m² per UVI)

| # | Source | Verdict | Reason |
|---|---|---|---|
| 1 | **WHO/WMO/UNEP/ICNIRP. *Global Solar UV Index: A Practical Guide.* WHO, 2002. IRIS handle 10665/42459.** | ⚠️ cite-only — see §4 for the full NC analysis | CC BY-NC-SA 3.0 IGO. Citation is OK; reproduction (figures, tables, full text) is not without permission for our commercial use. Primary source for the UVI scale definition but the NC restriction calls for caution. |
| 2 | **NOAA. *UV Index: Information.* National Weather Service / EPA.** (e.g., https://www.weather.gov/safety/uv-index and https://www.epa.gov/sunsafety/calculating-uv-index-0) | ✅ cite freely; U.S. federal public domain (17 U.S.C. § 105) | NOAA/EPA documentation parallels the WHO scale and is fully unrestricted. **This is Plunder's recommended primary citation for the UVI conversion** for any quantitative claims, with WHO as a courtesy secondary reference. |
| 3 | **McKinlay & Diffey 1987 (above)** | ✅ cite-only | The action spectrum behind the UVI is from this paper. Citation is the academic norm. |

**Wheeler — use NOAA as the primary anchor for the 0.025 W/m² per UVI conversion in our About page; cite WHO INTERSUN as the international counterpart but do not reproduce its tables.**

### 3.4 Time-to-burn / SED accumulation model

| # | Source | Verdict | Reason |
|---|---|---|---|
| 1 | **Diffey BL — multiple papers on UV dosimetry and SED** (e.g., 1991, 2002, others) | ✅ cite-only by author/year/DOI | Peer-reviewed academic citation. |
| 2 | **ICNIRP. Guidelines on Limits of Exposure to Ultraviolet Radiation 180–400 nm. *Health Physics*, 2004 (and revisions).** | ✅ cite-only by document name/year | Standard practice; ICNIRP guidelines are widely cited in commercial products without licensing issue. Reproduction of figures/tables requires permission. |
| 3 | **Madronich S et al. *J Photochem Photobiol B* 46:5–19, 1998** | ✅ cite-only by author/year/DOI | Peer-reviewed. |

### 3.5 Photosensitizing medications list (for the "When this estimate may not apply" About section)

**Critical posture: do not list specific brand names. Cite by therapeutic class only.** This is both a licensing concern (FDA prescribing-information sheets are public-domain but brand-name use can trigger trademark-adjacent app-review concerns) AND a copy-tone concern (brand names read as medical advice).

| # | Source | Verdict | Reason |
|---|---|---|---|
| 1 | **FDA. *Photosensitizing Drugs.* (Various FDA-published labeling guidance and MedWatch communications.)** | ✅ cite freely; U.S. federal public domain | Source for "drugs known to cause photosensitivity" lists. FDA's tabulations are in the public domain. |
| 2 | **AAD patient-information pages on photosensitivity** | ⚠️ cite-only with URL + access date | Copyrighted by AAD; cite, don't reproduce. |
| 3 | **DermNet NZ (https://dermnetnz.org)** | 🚫 do not anchor to as a primary source | DermNet NZ images and articles are mostly CC BY-NC-ND. The NC clause and ND clause (no derivatives) make it ⚠️ for any in-app use beyond simple citation. Even citation is OK, but it shouldn't be our primary anchor when FDA suffices. |
| 4 | **Moore DE. *Drug-induced cutaneous photosensitivity.* Drug Saf. 2002;25(5):345–372. doi:10.2165/00002018-200225050-00004** | ✅ cite-only by author/year/DOI | Peer-reviewed review article — canonical academic citation for the photosensitizer classes. |
| 5 | **NIH MedlinePlus, "Drug-induced photosensitivity"** | ✅ cite freely; U.S. federal public domain | NLM/NIH; public-domain federal work. Good consumer-facing language. |

**Plunder's recommended copy for the "When this estimate may not apply" subsection (Wheeler must ratify clinical accuracy):**

> This estimate is based on a model of healthy adult skin without photosensitization. The model may overstate safe time for people who:
>
> - Are taking medications known to increase sun sensitivity (some acne treatments, some antibiotics, some autoimmune-disease medications, some diuretics, some heart-rhythm medications, certain antifungals — your prescribing pharmacist can confirm).
> - Have a sun-sensitive medical condition (such as lupus, vitiligo, albinism, or porphyria).
> - Have had recent skin treatments (laser, chemical peel, microneedling, retinoid therapy).
> - Are pregnant (hormone-related photosensitivity such as melasma).
> - Are infants or very young children.
>
> If any of these apply, treat this estimate as a ceiling, not a target — and consult a clinician for sun-safety guidance specific to you.

**Sources behind the prose:** FDA labeling guidance (drug categories), Moore 2002 (canonical academic review), AAD patient pages (categorization). **No brand names. No diagnosis. No prescription.**

### 3.6 Sunscreen / SPF math

| # | Source | Verdict | Reason |
|---|---|---|---|
| 1 | **FDA OTC Sunscreen Monograph (21 CFR Part 352)** | ✅ cite freely; U.S. federal public domain | Federal regulation; fully unrestricted citation and reproduction. |
| 2 | **FDA. *Labeling and Effectiveness Testing; Sunscreen Drug Products for OTC Human Use.* Final Rule, 2011 (and subsequent proposed updates).** | ✅ cite freely; U.S. federal public domain | Same. |
| 3 | **ISO 24444:2019 — Cosmetics — Sun protection test methods — In vivo determination of the sun protection factor (SPF)** | ⚠️ cite by document number only, no reproduction | ISO standards are copyrighted by ISO and sold by national standards bodies. Cite as methodology, do not reproduce. |
| 4 | **Diffey BL papers on SPF effective dose** | ✅ cite-only by author/year/DOI | Peer-reviewed. |

**Note on "SPF math":** Wheeler's calculation is `MED × SPF` — that's the standard model. We cite the FDA monograph for the SPF definition (a regulatory-defined quantity) and Diffey for the dose math. Both fully ✅.

---

## §4. WHO INTERSUN — the NC License Question

**Source under review:** WHO/WMO/UNEP/ICNIRP (2002) *Global Solar UV Index: A Practical Guide*, https://iris.who.int/handle/10665/42459

**License:** CC BY-NC-SA 3.0 IGO (default WHO open-access posture, confirmed at https://www.who.int/about/policies/publishing/copyright).

**Our app:** $2.99 one-time paid (D-2026-05-19-005). Sold via the Apple App Store. Commercial activity.

### 4.1 The three views

**Conservative view: paid app = commercial = violates NC.**

WHO's published copyright policy contains the explicit sentence: *"Permission is required for commercial uses and licensing of WHO materials, such as using the material in the context of a commercial activity."* (Verified at https://www.who.int/about/policies/publishing/copyright, accessed 2026-05-19T00:30:00-07:00.) A paid app sold on the App Store is unambiguously a commercial activity. **Under the conservative reading, reproducing any substantive WHO content in our app requires written permission from WHO.**

**Pragmatic view: citation ≠ reproduction; NC scope applies to reproduction/adaptation.**

CC BY-NC-SA's NC clause restricts the "exercise of the Licensed Rights" (CC BY-NC-SA 3.0 § 4) for commercial purposes. The "Licensed Rights" are reproduction, distribution, public performance, adaptation, and so on (§ 1). **Citation — referring to the work by author/title/year and providing a URL — is not exercising a Licensed Right.** It's referring to the existence of a work, which is a public-fact activity outside the license entirely.

This is the same reason a paid commercial textbook can cite (without licensing) any paper or any book it discusses.

**Specific WHO IRIS / WHO Press terms:**

WHO's policy page (cited above) acknowledges the citation case implicitly by providing a "suggested citation" format that authors may use — i.e., WHO contemplates citation as the unrestricted norm and reserves the NC restriction for use of "the material" (reproduction, translation, derivative works).

### 4.2 Plunder's verdict

**For our $2.99 paid app:**

- ✅ **CITE** WHO INTERSUN as the international authority for the UVI scale by full citation (author/title/year/IRIS handle). The citation in About should read:
  > Global Solar UV Index reference: World Health Organization, World Meteorological Organization, United Nations Environment Programme & International Commission on Non-Ionizing Radiation Protection. *Global Solar UV Index: A Practical Guide.* Geneva: World Health Organization; 2002. Licence: CC BY-NC-SA 3.0 IGO. https://iris.who.int/handle/10665/42459
- 🚫 **DO NOT** reproduce WHO INTERSUN tables, figures, sun-safety messages, or running text in the app UI, screenshots, or App Store description. The NC restriction applies to reproduction in our commercial app.
- ✅ **OK to compute against** the scale conversion (0.025 W/m² per UVI). The scale itself is a numerical convention — a fact — not copyrightable expression. The descriptive prose around the scale in the WHO document IS copyrightable.
- ✅ **Use NOAA documentation as the primary quantitative anchor** (§3.3) for any text we render. NOAA's parallel documentation is public-domain U.S. federal work. WHO is then the international cross-reference, cited but not quoted.

**Why this is the right verdict and not just legal hedging:** WHO's INTERSUN guide *is* the canonical international source. Saying "we don't cite WHO" because of NC would be a credibility loss for the methodologist-persona cohort (Greta, Devon — Suchi P1, P3). Saying "we cite WHO but use NOAA's text where we need to render anything" is the precise, conservative-but-not-cowardly path.

**If anyone on the team wants to render WHO text verbatim:** That's an attorney-review escalation (§10), and I would not bless it without written permission from WHO. The WHO permissions form is the path: https://www.who.int/about/policies/publishing/permissions.

---

## §5. Citation Rendering Spec for the iOS About Surface

This is the spec Linka renders and Kwame implements. Every ✅ source Wheeler ends up using must follow the form below. **No factual claim in About may exist without a citation.**

### 5.1 General rules

1. **Every citation has:** author/editor, title, publisher (if relevant), year, identifier (DOI, IRIS handle, ISBN, or URL), and — for NC-licensed sources — the license tag.
2. **Every URL is tappable** (`Link("Display text", destination: URL(...))`).
3. **For CC-licensed sources, the license tag is part of the citation string** ("Licence: CC BY-NC-SA 3.0 IGO"). For all-rights-reserved sources, no license tag is needed.
4. **"Last accessed" dates are required for any URL that is not a stable identifier (DOI, IRIS handle, NCBI Bookshelf ID, PubMed ID).** For stable IDs, the ID itself is the identifier and no access date is needed. For arbitrary URLs (e.g., AAD pages), include "Accessed YYYY-MM-DD."
5. **Citations appear in two places at minimum:** the in-app About panel AND the App Store description. The in-app panel is the canonical full-form rendering. The App Store description is the compact form.

### 5.2 Required attribution strings

| # | Source | Full form (in-app About) | Compact form (App Store) | URL target |
|---|---|---|---|---|
| **WeatherKit** | Apple Weather data | "Weather data provided by Apple Weather, sourced from a range of providers — see Other data sources." + Apple Weather lockup | "Weather data: Apple Weather." | https://developer.apple.com/weatherkit/data-source-attribution/ |
| **NCBI Bookshelf (Codon)** | Fitzpatrick scale anchor (if Wheeler uses it) | "Fitzpatrick skin phototype scale. Adapted from: Ward WH, Farma JM, editors. *Cutaneous Melanoma: Etiology and Therapy*, Ch. 6, Table 1. Brisbane (AU): Codon Publications; 2017. doi:10.15586/codon.cutaneousmelanoma.2017.ch6" | "Skin-type descriptions adapted from Ward & Farma (eds.), *Cutaneous Melanoma: Etiology and Therapy* (Codon Publications, 2017)." | https://www.ncbi.nlm.nih.gov/books/NBK481857/ |
| **Fitzpatrick 1988** | Originating Fitzpatrick paper | "Fitzpatrick TB. The validity and practicality of sun-reactive skin types I through VI. *Arch Dermatol.* 1988;124(6):869–871. doi:10.1001/archderm.1988.01670060015008" | "Fitzpatrick TB (1988)." | DOI link |
| **Diffey 1991** | Erythemal action spectrum / dose math | "Diffey BL. Solar ultraviolet radiation effects on biological systems. *Phys Med Biol.* 1991;36(3):299–328. doi:10.1088/0031-9155/36/3/001" | "Diffey BL (1991)." | DOI link |
| **CIE S 007/E-1998** | Erythemal action spectrum standard | "Erythema reference action spectrum: CIE S 007/E-1998. Vienna: International Commission on Illumination; 1998." | "CIE S 007/E-1998." | (no URL — CIE standards are not free-access; do not link to paywalled vendor pages) |
| **McKinlay & Diffey 1987** | Originating action-spectrum paper | "McKinlay AF, Diffey BL. A reference action spectrum for ultraviolet induced erythema in human skin. *CIE Journal.* 1987;6(1):17–22." | "McKinlay & Diffey (1987)." | (no URL; cite by reference only) |
| **WHO INTERSUN** | International UVI reference | "World Health Organization, World Meteorological Organization, United Nations Environment Programme & International Commission on Non-Ionizing Radiation Protection. *Global Solar UV Index: A Practical Guide.* Geneva: World Health Organization; 2002. Licence: CC BY-NC-SA 3.0 IGO. https://iris.who.int/handle/10665/42459" | "WHO Global Solar UV Index (2002)." | IRIS handle |
| **NOAA UV Index** | Primary public-domain UVI documentation | "U.S. National Weather Service. *UV Index Information.* National Oceanic and Atmospheric Administration." + URL + Accessed date | "NOAA / NWS UV Index documentation." | https://www.weather.gov/safety/uv-index — accessed 2026-05-19 |
| **EPA SunWise / UV Index calculation** | Public-domain UVI calculation reference | "U.S. Environmental Protection Agency. *Calculating the UV Index.*" + URL + Accessed date | "U.S. EPA UV Index documentation." | https://www.epa.gov/sunsafety/calculating-uv-index-0 — accessed 2026-05-19 |
| **FDA Sunscreen Monograph** | SPF regulatory definition | "U.S. Food and Drug Administration. *Sunscreen Drug Products for Over-the-Counter Human Use.* 21 CFR Part 352 (Final Rule, 2011, as amended)." | "FDA OTC Sunscreen Monograph." | (FDA URL or Federal Register cite) |
| **Moore 2002 photosensitivity review** | Photosensitizer-class reference | "Moore DE. Drug-induced cutaneous photosensitivity. *Drug Saf.* 2002;25(5):345–372. doi:10.2165/00002018-200225050-00004" | "Moore DE (2002)." | DOI link |

### 5.3 Where each citation appears

- **In-app About panel** — ALL ✅ sources Wheeler uses, full form. This is the canonical surface. Organize by domain (Skin type / UV dose math / UVI scale / Sunscreen math / Photosensitizers).
- **App Store description** — compact form, only the 3–5 most important. Required at minimum: WeatherKit (Apple Weather), Fitzpatrick scale anchor, Diffey/CIE for dose math. Do not pad the App Store description with the full citation list — it dilutes the marketing copy and the methodologist personas tap through to the About panel for the full list.
- **Verdict card or Home screen** — never. Citations live in About. The Home screen has the WeatherKit lockup (per §7) but no scientific citations.
- **Onboarding / first-launch disclaimer** — never. The disclaimer cover is for safety messaging, not citations.

### 5.4 Linking and "last accessed" requirements per source type

| Source type | URL required? | Title linkable? | Last-accessed date required? |
|---|---|---|---|
| Peer-reviewed paper (Fitzpatrick 1988, Diffey 1991, McKinlay & Diffey 1987, Moore 2002, Madronich 1998) | DOI link preferred (✅ stable) | Yes — wrap title in `Link` to DOI | No (DOI is stable) |
| NCBI Bookshelf chapter | Yes (NCBI Bookshelf URL) | Yes | No (NBKID is stable) |
| WHO IRIS publication | Yes (IRIS handle) | Yes | No (IRIS handle is stable) |
| NOAA / EPA web pages | Yes | Yes | **Yes — accessed YYYY-MM-DD** |
| AAD or DermNet NZ pages | If cited, yes | Yes | **Yes — accessed YYYY-MM-DD** |
| CIE standard | No URL (paywalled) | No | No |
| FDA monograph / CFR | URL to Federal Register or eCFR | Yes | No (CFR cite is stable) |
| WeatherKit data-source attribution | Yes — see §7 | Yes (tappable Link) | No (Apple's URL is contractually stable) |

---

## §6. Disclaimer Wording — Final Form

The disclaimer is doing real safety work for the photosensitization cohort (Suchi P4 "Accutane Asha," D-2026-05-19-007). It must satisfy:

- **Suchi's safety load** (the photosensitization cohort needs the disclaimer visible enough that an Accutane / lupus / doxycycline user notices it).
- **Apple App Store §1.4.1 Safety** (no encouragement of harm).
- **Apple App Store §1.4.3 Drugs/Medical Topics** (no diagnostic/treatment guidance).
- **The "informational, not advisory" line** (no claim that the app diagnoses, treats, or prevents anything).
- **Persona-keyed visibility** per Suchi (load-bearing for first-time and high-risk users; less prominent for repeat power-users — but never absent).

### 6.1 Three layers of disclaimer

Linka's spec §8.4 establishes a three-layer model — I am ratifying that pattern and supplying the final wording.

#### Layer 1 — First-launch full-screen cover (`DisclaimerCover`)

Fires every cold launch (Donatello M1).

**Title (Suchi proposed; Plunder approves with one tweak):** "**How accurate is this for you?**"

This converts the disclaimer from a CYA wall into a self-classification prompt the high-risk personas will actually read. It is **not** a medical claim — it is asking the user to assess their own context.

**Body (Plunder canonical wording — Wheeler to ratify clinical-accuracy phrasing):**

> Estimated burn time only. **Not medical advice. Skin response varies.**
>
> UV Burn Timer is for informational use only. It is not a substitute for professional medical advice, diagnosis, or treatment. The burn-time estimate is a model calculation, not a measurement, and assumes consistent conditions and healthy adult skin.
>
> **If you take a photosensitizing medication or have a sun-sensitive condition,** this estimate may overstate your safe time. See *Is this estimate for me?* in About.
>
> When in doubt: cover up, reapply sunscreen, or move into shade.
>
> *For children, consult a pediatrician for sun-safety guidance.*

**Then a single button: "I understand."**

Length: ~110 words, intentionally under the ~4-second-read line for Tomás (Suchi §1.1) while load-bearing for Asha. The bold-weight phrases land for Asha; the closing line lands for Greta and Tomás.

#### Layer 2 — Persistent footer (always-on under verdict number)

Donatello M2. Visible on every screen that shows a numeric estimate.

**Wording (verbatim from prototype, ratified — do not soften):**

> *Model estimate only. Not medical advice. Reapply sunscreen every 2 hours regardless of timer.*

**Plunder verdict:** ✅. This sentence is doing three jobs (informational hedge, medical-claim disavowal, behavioral floor) and each is correctly informational not advisory. The "reapply every 2 hours" line is universally-recommended sun-safety practice and is the floor, not a personalized prescription — it does not violate §1.4.3.

#### Layer 3 — Verdict-card "Is this estimate for me?" link (the new persona-keyed surface)

Per Linka §8.4 / Suchi §1.5 / D-2026-05-19-007. One tap from the verdict number to the photosensitization caveat in About.

**Wording for the link itself (Plunder choice from Suchi's three variants — recommend Suchi-A):**

> Is this estimate for me?

This is a question, not a claim. It invites the user into a self-classification activity. **It does not promise a diagnosis** (which would be 🚫 under §1.4.3) and **it does not promise personalization** (which would be 🚫 under §5.1.1). It says: "We made a model; here's how to think about whether it fits you." That is exactly informational.

**Destination wording (in About → "When this estimate may not apply" section):** Use the prose drafted in §3.5 above. Wheeler ratifies the categorical list.

### 6.2 Alternative variants (rejected with reason)

| Variant | Verdict | Reason rejected |
|---|---|---|
| "This calculator helps you avoid sunburn." | 🚫 advisory | Implies prevention claim. App Store §1.4.3. |
| "Estimated time before your skin will burn." | 🚫 prescription-adjacent | "Will burn" is a definite future claim; the model can be wrong. Use "to skin reddening" or "to 1 MED." |
| "Safe sun time:" / "How long you can stay out:" | 🚫 advisory | "Safe" implies safety guarantee; "can stay out" is a permission claim. Both invite §1.4.1 review. |
| "Personalized for your skin." | 🚫 medical-claim-adjacent | "Personalized" is a regulated word in the medical-app context. Avoid. |
| "Time to sunburn:" | ⚠️ borderline | "Sunburn" is a clinical outcome; "skin reddening" (current prototype) or "1 MED" is the informational framing. Use the current prototype framing. |
| "Don't worry, this model is safe." | 🚫 promotional, false confidence | The disclaimer's job is to acknowledge uncertainty, not reassure. |

### 6.3 The "informational vs advisory" test

Every line of disclaimer copy, About copy, App Store copy, and verdict copy must pass this test:

- **Does it state a fact OR provide a model output?** → ✅ informational.
- **Does it tell the user what to do as if it knew their case?** → 🚫 advisory.
- **Does it acknowledge uncertainty / "varies" / "estimate" / "model"?** → ✅ informational.
- **Does it suggest a treatment, prevention, or diagnosis?** → 🚫 advisory.

This is the test Linka should apply to any new copy before submitting it for my review.

---

## §7. WeatherKit Attribution — Final Form

Per Apple Developer Program WeatherKit attribution requirements, verified at https://developer.apple.com/weatherkit/get-started/ on 2026-05-19T00:30:00-07:00.

### 7.1 The two required elements

**Element 1:** The Apple Weather trademark lockup ("Weather" with the Apple logo wordmark) visible on any screen displaying WeatherKit data.

**Element 2:** A tappable link to Apple's data-source attribution page from a screen reachable from any WeatherKit-data screen.

### 7.2 The exact link target

**Official URL (current canonical):** **https://developer.apple.com/weatherkit/data-source-attribution/**

This is the link Apple's own WeatherKit Get Started page directs developers to use ("see the legal link to other data sources" → links to /weatherkit/data-source-attribution/).

**Linka's spec referenced https://weatherkit.apple.com/legal-attribution.html** — this URL **does also resolve to the same content** (verified 2026-05-19T00:30:00-07:00). It appears to be an alternate Apple-hosted mirror. **Plunder recommendation: use the developer.apple.com URL** as the contractually canonical one. If Apple updates the canonical URL post-launch, our About page must update too — note this for Kwame as a hard-coded-URL maintenance item.

### 7.3 Attribution strings — by surface

| Surface | Attribution text | Lockup placement | Link |
|---|---|---|---|
| **In-app Home (verdict screen)** | Lockup only — no body text. The lockup is the required visible trademark; users tap to reach About for the full attribution paragraph. | Below the verdict card, above the persistent footer disclaimer. Per Linka §4. | Tap target on the lockup opens AboutView → Attribution section. |
| **In-app About panel → "Weather data" section** | Body: "Weather and UV index data provided by Apple Weather, with data sourced from a range of providers." | Full lockup at `.body` size at the top of the section. | Inline `Link("Other data sources", destination: URL(string: "https://developer.apple.com/weatherkit/data-source-attribution/")!)` |
| **In-app Attribution dedicated screen (`AttributionView`)** | Full lockup + body: "UV Burn Timer uses Apple's WeatherKit service for UV index data. Apple Weather data is sourced from a range of providers, listed in full at the link below." + tappable URL displayed in full. | Full lockup at `.title3` size. | Tappable URL shown in full (Apple's contract preference is that the URL be visible, not just a tap target). |
| **App Store description** | "Weather data: Apple Weather." (single line) | N/A — App Store description is text-only. | The App Store listing cannot include arbitrary URLs in the description body, but the trademark name "Apple Weather" must appear. |

### 7.4 App Store description replacement (replaces the prior Open-Meteo line)

**Current (in LAUNCH-PLAN.md, to be replaced — per D-2026-05-19-004 / D-2026-05-19-007):**

> Weather data: Open-Meteo (CC BY 4.0).

**Plunder replacement (final — adopt verbatim):**

> Weather data: Apple Weather. Other data sources are listed in the in-app About screen.

That's it. Compact, attribution-compliant, points the user at the in-app full surface (which is contractually required to render the lockup + tappable link). The phrase "Apple Weather" is the trademarked name Apple requires; the in-app surface carries the full lockup.

**Do not** include the URL in the App Store description. App Store descriptions are not the contractually-required attribution surface — the in-app screen is. Adding the URL to the description text reads as marketing noise and Apple's review tools sometimes flag external URLs in app metadata.

### 7.5 Where the attribution can live

**Contract requirement:** the lockup must be visible *wherever WeatherKit data is presented*. The link must be reachable from any WeatherKit-data screen.

**Interpretation:** The lockup must be on the primary surface (Home / verdict screen) — it cannot be hidden in a sub-screen. The link target (data-source page) can be in a sub-screen (About / Attribution) as long as it's reachable in one tap from the lockup.

**Linka's spec §4 already implements this correctly** — lockup on Home + lockup on About + tappable link from both. Plunder ratifies.

### 7.6 Trademark posture

- ✅ Use the supplied lockup asset (preferred) OR an SF Symbol Label that includes the Apple logo glyph + "Weather" wordmark.
- 🚫 Do not recolor the lockup beyond the contractually permitted variants.
- 🚫 Do not modify the lockup typography.
- 🚫 Do not use the lockup in marketing materials outside the context of the WeatherKit data presentation (e.g., do not put "Powered by Apple Weather" on a billboard).
- ✅ In running prose (App Store description body), "Apple Weather" as plain text is acceptable. The trademarked lockup is for in-app UI.

---

## §8. App Store Listing — Claim Review

Reviewing the LAUNCH-PLAN.md draft.

### 8.1 App name candidates

| Candidate | Verdict | Reason |
|---|---|---|
| **UV Burn Timer** | ✅ | "Burn Timer" is functional/utility framing. "UV" is a measurement reference, not a health claim. Approved. |
| "UV Safe Time" | 🚫 | "Safe" implies safety guarantee. Reject. |
| "Sun Burn Calculator" | ⚠️ | "Sunburn" is the clinical outcome; "calculator" is fine. Borderline; "burn timer" is better because "timer" is functional and "burn" can be read as the model's output category (1 MED reddening). |
| "Sun Time" | ⚠️ | Vague. Possibly acceptable but loses the methodology framing. |

**Recommend: stick with "UV Burn Timer."**

### 8.2 Subtitle (locked per D-2026-05-19-005)

> **Estimated burn time, no subscription.**

**Verdict: ✅.** "Estimated" carries the informational hedge required by §1.4.3. "Burn time" is the model output (1 MED reddening), not a prescription. "No subscription" is a true monetization fact. Approved unchanged.

### 8.3 App Store description — line-by-line review

**Opening disclaimer paragraph:**

> Estimated burn time only. Not medical advice. Skin response varies.

✅. This is Plunder canonical phrasing.

> UV Burn Timer estimates how many minutes of sun exposure your skin can handle before reddening, based on three inputs: your Fitzpatrick skin type, your SPF level, and the current UV index at your location.

⚠️ → ✅ with one tweak. The phrase "your skin can handle" reads slightly advisory ("we know what your skin can take"). **Rewrite:**

> UV Burn Timer estimates how many minutes of sun exposure may cause skin reddening, based on three inputs: your Fitzpatrick skin type, your SPF level, and the current UV index at your location.

The substitution "may cause skin reddening" for "your skin can handle" preserves the meaning but moves from advisory framing ("we know your tolerance") to informational framing ("model says this is when reddening tends to occur").

> Most outdoor apps show you "UV index: 8" and leave you to guess what that means for your skin. This app gives you the number you actually need — an estimated time to 1 MED (minimal erythemal dose) — in a single tap.

✅. "Estimated time to 1 MED" is the technical informational framing. Methodology-curious personas will appreciate the explicit MED reference. Approved.

> $2.99 once. No subscription. No account. No ads. No tracking.

✅. Monetization facts, all true. Approved.

> Calculation is based on the Fitzpatrick skin phototype scale (Fitzpatrick 1988) and the Diffey erythemal action spectrum (Diffey 1991; CIE S 007). Not affiliated with any dermatology organization.

✅. Citation form is correct. "Not affiliated" is an important disclaimer that prevents implied endorsement by AAD or any dermatology body. Approved.

> Weather data: Open-Meteo (CC BY 4.0).

🚫 — **MUST REMOVE per D-2026-05-19-004 / D-2026-05-19-007.** Replace with the Plunder Weather attribution line from §7.4:

> Weather data: Apple Weather. Other data sources are listed in the in-app About screen.

> *Model estimate only. Reapply sunscreen every 2 hours regardless of timer.*

✅. Closing-line footer-equivalent. Approved.

### 8.4 Feature-bullet phrases (from r/Ultralight launch copy)

> Enter your Fitzpatrick skin type (I–VI)

✅ Informational input description. Approved.

> Set your SPF level (none / 15 / 30 / 50 / 70+)

✅ Approved.

> Tap "Use my location"

✅ Approved.

> Get: "Estimated time to 1 MED of skin reddening: ~22 minutes (Fitzpatrick III, SPF 30, UV index 8.0)"

✅ This is the model output rendered as text. Methodologists will be reassured by the parenthetical inputs.

### 8.5 r/Ultralight body copy

> I got tired of pulling up QSun (which locks the only useful feature behind a $2.99/month subscription) every time I wanted to know how long I could be in the sun without reapplying.

⚠️ — "how long I could be in the sun" reads marginally advisory. The current verdict-card framing ("time to 1 MED") is fine; this body-copy paraphrase is a Reddit-native register and is **probably OK** because (a) it's the launch-post narrative, not the App Store metadata; (b) it's a first-person account of why the author built the app, not an app-makes-this-claim statement. **Acceptable as launch-post copy. Do not migrate this phrasing into the App Store description.**

> Calculation based on the Fitzpatrick skin phototype scale and the Diffey erythemal action spectrum (standard UV science, not magic).

✅. "Standard UV science, not magic" is funny and accurate. Methodologist-bait. Approved.

### 8.6 Subtitles / taglines elsewhere

> *Model estimate only — not medical advice. Skin response varies. Reapply sunscreen every 2 hours regardless of timer.*

✅. Plunder canonical disclaimer. Approved everywhere.

### 8.7 "Burn time" / "time to burn" — final review of the term

**Verdict: ✅ informational, with the framing we use.** "Burn time" in our context means "estimated time to 1 MED of skin reddening" — a measured biological endpoint, not a prescription. The phrase consistently appears with "estimated" modifier or paired with "1 MED" technical anchor. This is informational science-communication, not medical advice.

**🚫 lines we do not say:**
- "Safe sun time" — implies safety guarantee.
- "How long you can stay out" — implies permission.
- "Time before sunburn" — implies certainty.
- "Sunscreen protection time" — implies SPF math is exact (it's not — see Suchi MMT-6).
- "Personal burn time" — implies personalization to a level we don't deliver.

### 8.8 "Sunscreen reminder" / "Reapplication reminder" — review

**Current behavior (LAUNCH-PLAN.md):** No reapplication timer / push notification in v1. The footer line *"Reapply sunscreen every 2 hours regardless of timer"* is the only reapplication touchpoint.

**Verdict on the footer line: ✅.** "Every 2 hours regardless of timer" is universal sun-safety guidance — it's not a personalized prescription, it's a floor. This is exactly the informational/advisory line drawn correctly.

**For any future v2 reapplication reminder feature:** If we add this, the implementation matters. ✅ informational form: "Has it been 2 hours since you last applied? Sunscreen wears off." 🚫 advisory form: "You should apply sunscreen now." The difference is who is making the recommendation. The first frames the universal sun-safety rule and reminds the user; the second tells the user what to do based on the app's reading of their situation.

### 8.9 Vitamin-D guidance, tanning duration, "safe sun" — sweep

| Term | Where it might appear | Verdict |
|---|---|---|
| "Vitamin D" | About copy, marketing | 🚫 — do not mention. Vitamin-D guidance is a clinical-advice surface; we are not equipped to navigate the literature and the App Store medical-claim review around it. |
| "Tanning" / "tan in X minutes" | Anywhere | 🚫 — do not mention. "Tan time" frames the app as a tanning aid, which both fails §1.4.1 (encouraging UV exposure) and shifts our category. |
| "Safe sun" | Anywhere | 🚫 — "safe" implies safety guarantee. Use "estimated burn time" or "informational." |
| "Healthy sun exposure" | Anywhere | 🚫 — health-benefit claim. |
| "Sun protection" | App Store description, About | ⚠️ — borderline. Acceptable in the context "SPF provides sun protection" (a regulatory fact). Not acceptable as "This app provides sun protection" (it doesn't — it provides an estimate). |
| "Sunburn risk" | App Store description, About | ⚠️ — "risk" is a probabilistic framing OK in measured copy ("UV exposure correlates with sunburn risk") but is too clinical for our consumer-facing tone. Prefer "estimated time to skin reddening." |
| "Skin cancer prevention" | Anywhere | 🚫 — prevention claim. App Store §1.4.3. Do not say. |
| "Sun-safety education" | Marketing, About | ⚠️ — borderline acceptable as a soft tagline. Better: "Informational sun-exposure calculator." |

### 8.10 The launch post about "every time I wanted to know how long I could be in the sun without reapplying"

This is launch-post copy, not App Store metadata. It is the author voice and falls outside Apple's review purview. ✅ for the launch post; do not export into App Store text.

---

## §9. Things Wheeler Must NOT Cite

The inverse of the legal pack. Wheeler is anchoring science; these are the sources he should NOT lean on.

| # | Source / category | Why not |
|---|---|---|
| 1 | **Paid-only journal PDFs reproduced inline in the app** | Reproduction beyond fair use. Cite the DOI; do not embed PDFs. |
| 2 | **CIE standard tables reproduced verbatim** | CIE retains copyright; we may cite by document number but not republish. |
| 3 | **WHO INTERSUN figures, tables, or running text** | CC BY-NC-SA 3.0 IGO; commercial reproduction prohibited. (§4.) |
| 4 | **NCBI Bookshelf table content reproduced verbatim from third-party-published books** | Per-book license governs. The book the user picked is Codon CC BY-NC 4.0 — reproduction prohibited in commercial app. (§2.) |
| 5 | **StatPearls chapter content reproduced verbatim** | StatPearls is CC BY-NC-ND 4.0 (ND = no derivatives, NC = no commercial). Both clauses kick in for a paid app. Cite-only. |
| 6 | **AAD page content reproduced verbatim** | All-rights-reserved by AAD. Cite-only. |
| 7 | **DermNet NZ images or text** | CC BY-NC-ND. Cite-only at best; better to use a public-domain alternative (FDA, MedlinePlus). |
| 8 | **Wikipedia screenshots or paragraphs** | Wikipedia is CC BY-SA 4.0, which has a ShareAlike clause that would require our app's content to be similarly licensed — an unworkable demand for a paid commercial app. **Do not reproduce Wikipedia text. Citation is OK as a starting research breadcrumb, but Wikipedia is NEVER a primary citation in our About panel.** |
| 9 | **Cleveland Clinic / Mayo Clinic / WebMD article content** | All copyrighted, no open license. Cite-only at most; better to anchor to primary literature. |
| 10 | **Predatory journals (Beall's list and successors)** | Citing a predatory journal as scientific authority damages credibility with the methodologist personas and creates an attribution that won't survive review by a knowledgeable user. **Wheeler — if you find a useful-looking source published in a journal you don't recognize, run it past me before anchoring to it.** |
| 11 | **Non-peer-reviewed blog posts as scientific anchors** | Bloggers' posts can be cited as evidence of user sentiment or product reviews — never as the scientific basis for the model. |
| 12 | **Brand-named medications** (e.g., "Accutane," "Plaquenil," "doxycycline") in our About / disclaimer copy | Trademark-adjacent. Use therapeutic classes ("retinoid acne treatments," "antimalarial medications used in autoimmune disease," "tetracycline antibiotics"). The information is the same; the brand-name use invites attention we don't want. |
| 13 | **HealthKit-derived data of any kind** | Out of scope per D-2026-05-19-002. Not a citation issue but a data-handling rule. |

---

## §10. Open Questions / Escalations for Attorney Review

Items I am flagging as gray-area enough to warrant an actual attorney's sign-off before launch. None of these block the design/build work — they are documented escalations.

| # | Item | Why it's gray | Suggested resolution |
|---|---|---|---|
| **E1** | **NCBI Bookshelf NBK481857 verbatim reproduction in commercial app** | License is CC BY-NC 4.0 (per controlling explanatory text) but the colophon headline is misprinted as CC BY 4.0. We are taking the conservative reading; an attorney could review whether the prose or the link controls. Path A (paraphrase) avoids the question. | Confirm Path A (Plunder recommended) or seek written permission from Codon Publications if Path B (verbatim) is desired. |
| **E2** | **WHO INTERSUN citation in a paid app — NC scope** | Plunder's view (§4.2) is that citation ≠ reproduction and citation is outside NC scope. An attorney could ratify or refine. | Attorney sign-off on the citation form in §5.2. If attorney says NC reaches citation in the commercial context, drop WHO from the citation list and rely on NOAA. (Unlikely but flagged.) |
| **E3** | **App Store category posture (Utilities vs Health & Fitness)** | D-2026-05-19-002 selected Utilities. An attorney review of our copy could confirm we are not over the line into Health & Fitness territory. (Plunder's read: we're comfortably in Utilities; methodology is calculator-like, not health-tracking.) | One-pass attorney review of App Store metadata + first-screen copy. |
| **E4** | **Photosensitization list — class-by-name vs. brand-by-name** | Plunder recommends class-by-name only (§3.5). An attorney could confirm whether the FDA-published photosensitizing-drugs lists can be paraphrased into our consumer language without further sign-off. | Attorney pass on the §3.5 prose. |
| **E5** | **WeatherKit attribution URL stability** | We hard-code https://developer.apple.com/weatherkit/data-source-attribution/ in the app. If Apple changes it, we need an app update. | Add to launch-readiness checklist: verify the URL resolves at submit time and at every minor-version update. |
| **E6** | **Disclaimer wording — final medical-claim sweep** | The Plunder canonical wording in §6 is conservative and passes my own informational/advisory test. An attorney could ratify before submit. | Attorney pass on §6.1 wording. |
| **E7** | **ToS / Privacy clauses that touch health** | We don't collect health data (D-2026-05-19-002) but our Privacy Policy and ToS still need clauses that explicitly disclaim medical advice and inform users that the app is informational. **Not yet drafted.** Gaia owns the broader Privacy policy; Plunder owns the health-clauses inside it. | Draft Privacy Policy + ToS health-clauses in a separate deliverable before submit. Attorney review before publish. |
| **E8** | **Trademark sweep of the app name** | "UV Burn Timer" is a descriptive name and likely registrable. An attorney would do the USPTO + state + common-law sweep before any marketing spend. | Standard trademark clearance before launch marketing. |

---

## §C. Cross-Check Wheeler

**UPDATE: Wheeler's brief landed at `.squad/decisions/inbox/wheeler-fitzpatrick-and-med-anchor.md` at 2026-05-19T00:25:58-07:00, during my writing.** This section now verdicts his specific picks against the framework.

### C1. Bibliographic locking (Wheeler §1) — ✅

Wheeler verified the NCBI Bookshelf entry: Ward WH & Farma JM (eds), *Cutaneous Melanoma: Etiology and Therapy*, Codon Publications 2017, NBK481857, Ch. 6 Table 1, doi:10.15586/codon.cutaneousmelanoma.2017.ch6. **My fetch (§2.1) confirms.** Wheeler also identifies the Codon license posture as non-commercial-reuse-with-attribution — matches my §2.2 reading. ✅.

### C2. Picker copy — the verbatim vs paraphrase decision (Wheeler §5) — ⚠️ → ✅ with conditions

**Wheeler's recommendation: ship the NCBI verbatim text** (§5.4: "Ship the verbatim NCBI text. If you decide to edit, the proposed variant above is internally consistent and still cites the same source — the About surface would then read '*adapted from* Ward & Farma 2017 / Fitzpatrick 1988.'").

**My framework's default (§2.3): Path A — paraphrase to remove the NC question entirely.**

**Reconciliation.** Wheeler's argument has weight: (a) the six descriptions are short factual phrases describing a 50-year-old clinical classification; (b) the U.S. originality-threshold doctrine (Feist v. Rural Telephone) plausibly puts them below copyright; (c) "citation of a verbatim short clinical descriptor" is normal-and-customary practice in textbooks and clinical apps; (d) the attribution string already names the source clearly.

**However:** Codon Publications is an Australian publisher; Australian copyright doctrine may treat short phrases differently than U.S. doctrine. And the CC BY-NC license is explicit ("share and adapt for non-commercial purpose") — even if a U.S. court might find originality lacking, the license terms themselves do not contain an "originality-threshold escape hatch."

**Plunder verdict: ⚠️ → ✅ with explicit conditions. I will ratify either path on these terms:**

**Option 1 — Ship Wheeler's verbatim (acceptable with conditions):**
- ✅ Acceptable IF the attribution string in About uses the word "**adapted from**" (Wheeler's §5.4 wording is correct on this) — never "reproduced from" or "from."
- ✅ Acceptable IF a "When this estimate may not apply" anchor exists in About that addresses the V/VI-burning question (Suchi's MMT and clinical accuracy concern — see §C3 below).
- ⚠️ Flag for attorney review (§10 E1 remains live). If Codon Publications or any reviewer raises the NC question post-launch, fall back to Option 2 immediately.
- ⚠️ Add an internal note that the picker text is licensed-content-adjacent; do not let a future iteration paraphrase it in localization without re-doing this analysis (mixed verbatim/paraphrase is the worst posture).

**Option 2 — Ship Wheeler's "edited variant" (Plunder preferred):**
- ✅ "Very fair skin / Fair skin / Medium skin tone / Light-brown skin / Brown skin / Deeply pigmented skin" with the burn-and-tan behavioral phrasing preserved.
- ✅ Attribution string says "adapted from" — accurately reflects the minor presentation adaptation.
- ✅ Removes the NC question (the picker text is now ours).
- ✅ Honors Suchi's directive #4 (§1.2 of her brief) about behavior-first symmetric framing — particularly for V/VI rows where "Brown skin / Deeply pigmented skin" leads gentler than NCBI's "Brown skin / Black skin. Heavily pigmented."

**Decision (Plunder):** I lean toward **Option 2 (edited variant)** because it makes the NC question moot AND lands closer to Suchi's symmetric phrasing. But I will ratify Option 1 if Wheeler holds the line on verbatim fidelity. Linka has final say on which renders.

### C3. Wheeler's "Never burns" for Type V and VI — clinical-accuracy flag

Wheeler's verbatim and edited variants both keep "**Never burns**" for Type V and VI (matching NCBI Table 1). The photosensitization-cohort literature (Wheeler's own §7.1) shows that Type V and VI users **can** burn, especially under photosensitizer load. The "never burns" wording — even with our disclaimer doing the load-bearing — creates a verdict-card / About mismatch for an Asha-cohort Type-V user.

**Plunder ask of Wheeler:** Consider whether the V/VI wording should read "**Rarely burns. Tans very easily.**" / "**Rarely burns. Deeply pigmented; tans very easily.**" — a one-word clinical-accuracy improvement that:

- Aligns V and VI rows with IV's "Rarely burns" framing (Suchi's symmetric-construction directive #4).
- Honors the photosensitization caveat without contradicting the picker copy.
- Is defensible as "adapted from" — minor clinical-precision edit.

This is Wheeler's call on the science. If "Never burns" is clinically what the literature supports for V and VI **in the absence of photosensitization**, then keep it and let the disclaimer carry the photosensitization caveat. If Wheeler accepts that "Rarely burns" is more accurate for the *whole* population (photosensitized + not), prefer that.

### C4. MED anchor table (Wheeler §2) — ✅

| Wheeler pick | Plunder verdict | Note |
|---|---|---|
| Sayre 1981 (J Am Acad Dermatol, doi:10.1016/S0190-9622(81)70105-1) | ✅ cite-only by author/year/DOI | Peer-reviewed; standard. |
| Fitzpatrick 1988 (Arch Dermatol, doi:10.1001/archderm.1988.01670060015008) | ✅ cite-only | Already in my §3.1 legal pack. |
| Diffey 1991 (Phys Med Biol, doi:10.1088/0031-9155/36/3/001) | ✅ cite-only | Already in my §3.2 legal pack. |
| CIE S 007/E:1998 + ISO 17166:1999 | ✅ cite by document number, no table reproduction | Wheeler is using these as definitional anchors — citing by document number is exactly the §1.3 / §3.6 posture. |
| Harrison & Young 2002 (Methods, doi:10.1016/S1046-2023(02)00205-0) | ✅ cite-only | Peer-reviewed. New to my pack — good catch by Wheeler. |

**Wheeler's numerical MED-per-type table** (200, 250, 300, 450, 600, 1000 J/m²) is a synthesis of facts from the cited sources. Numerical facts are not copyrightable (Feist). Wheeler's presentation in his §2.1 table IS our copyrighted work, citing the sources. ✅ ship as-is. The "Established / Reasonable approximation" confidence column is excellent science-communication practice and I recommend Linka render it in About.

### C5. Time-to-burn formula (Wheeler §3) — ✅

Formula: `t_seconds = (MED × SPF) / (UVI × 0.025)`.

- The formula is a textbook scientific equation — facts/mathematics, not copyrightable.
- The constant `0.025 W/m² per UVI` is definitional (WHO 2002) — fact.
- Wheeler's citations: WHO 2002 ✅ as citation (NC doesn't reach citation per §4.2), Diffey 1991 ✅, Schalka & Reis 2011 ✅ (peer-reviewed, doi:10.1590/S0365-05962011000300013, on the linear-SPF assumption).

**One clarification for the team:** my framework §3.3 recommended "use NOAA as primary anchor for the UVI conversion in our About page; cite WHO INTERSUN as the international counterpart but do not reproduce its tables." Wheeler cites WHO as primary in his §4.2. **These are compatible — they were addressing different things.** Specifically:

- ✅ **For the academic CITATION** of the 0.025 constant: WHO 2002 IS the canonical primary citation. Wheeler is right.
- ⚠️ **For any RENDERED TEXT** in the app describing the UVI scale (e.g., "The UV Index measures the intensity of ultraviolet radiation at the Earth's surface…"): use NOAA / EPA wording, not WHO wording, because the NC restriction applies to text reproduction.
- ✅ **For the numerical constant 0.025 itself** in Swift code: facts, not copyrightable, cite WHO in code comments. No NC issue.

Both Wheeler and I are correct in different scopes. No conflict.

### C6. Picker default-state recommendation (Wheeler §6) — ✅

Wheeler argues for **no default Fitzpatrick selection** on safety grounds (asymmetric safety cost: over-estimating safe time is harmful; under-estimating is harmless). This is a **product / UX decision** with safety implications, not a legal one — but I note it ratifies Suchi's design directive (her §1.2 directive #1).

**Plunder verdict on the legal/compliance implications:** ✅ the "no default" posture also reduces our claim surface — we are not implicitly recommending a "typical" Fitzpatrick type, which would be advisory. Linka and Kwame implement.

### C7. Photosensitization spec (Wheeler §7) — ✅ with named-generic-medication caveats

Wheeler's §7 is the most safety-load-bearing section of his brief and the one with the highest claim-surface risk. Detailed verdict:

**§7.1 Drug class table** — ✅ for in-app About surface (under the "When this estimate may not apply" anchor). Specifically:

| Wheeler item | Plunder verdict |
|---|---|
| Naming drugs by **generic** name (isotretinoin, doxycycline, hydroxychloroquine, etc.) | ✅ acceptable — generic names are standard regulatory language, not trademark-encumbered. |
| Naming "Accutane" in **parenthetical only** in the §7.1 reference table | ⚠️ → ✅ acceptable in Wheeler's internal reference table because that table is internal context for the team. **STRIP "Accutane" from anything that ships to the user-facing UI.** In-app About copy uses "isotretinoin" only. |
| Quantitative MED-reduction ranges ("2–5× lower MED") | ✅ in About if rendered with Wheeler's "Established / Reasonable approximation" confidence labels. Without the confidence labels, these read as more definitive than the literature supports. |
| Citations (Moore 2002, Drucker & Rosen 2011, Stein & Scheinfeld 2007, Sanders 2003, Lecha 2009, Felsten 2011, Goldman 2005, Pottegård 2017, etc.) | ✅ all cite-only by author/year/DOI. Already in or compatible with my §3.5 legal pack. |

**§7.3 Recommended L1 disclaimer copy** — Wheeler proposes:

> *If you take a medication or have a condition that makes you sun-sensitive — including isotretinoin, tetracycline-class antibiotics, doxycycline, hydroxychloroquine, lupus, or porphyria — this estimate may overstate your safe time. See "When this estimate may not apply" in About.*

**Plunder verdict on this wording:** ⚠️ → ✅ with two edits.

1. The phrase "**including** […]" already signals non-exhaustive list — ✅ keep.
2. "doxycycline" is redundant with "tetracycline-class antibiotics" — doxycycline IS a tetracycline. Suggest removing "doxycycline" to clean up the list, OR keeping it as the specific example most non-clinician users will recognize. Plunder mild preference: keep the redundancy for user-recognition. Wheeler's call.
3. **Add a closing "your prescribing pharmacist can confirm" or "ask your clinician" line** at the end. This converts the line from "we are listing categorical risk factors" (potentially advisory) to "we are informing you to seek confirmation" (clearly informational). Suggested revision:

> *If you take a medication or have a condition that makes you sun-sensitive — including isotretinoin, tetracycline-class antibiotics (such as doxycycline), hydroxychloroquine, lupus, or porphyria — this estimate may overstate your safe time. Your pharmacist or clinician can confirm whether your specific situation applies. See "When this estimate may not apply" in About.*

This is the Plunder canonical wording for the L1 photosensitization line. It clears App Store §1.4.3 (no diagnosis/treatment guidance — the line points to "ask your clinician" as the resolution path, not "the app says yes/no").

**§7.3 point 4 ("We do NOT add a photosensitized toggle")** — ✅ ratified. Adding such a toggle would create special-category-data collection (D-2026-05-19-002 Donatello M7 violation) and shift our App Store category posture.

**§7.3 point 5 ("We do NOT name specific brand drug names")** — ✅ ratified. Wheeler and I are aligned.

### C8. "What we DON'T claim" (Wheeler §8) — ✅

Wheeler's §8 is a near-perfect overlap with my §8.9. Forbidden phrases match. ✅. The team has converged on the same boundary copy.

### C9. Summary verdict on Wheeler's brief

**Overall: ✅ — Wheeler's brief is shippable as the science spec.** Specific items:

- ✅ NCBI / Codon source identified and licensed correctly.
- ⚠️ → ✅ Picker verbatim text: ratifiable with conditions OR swap to Wheeler's edited variant (Plunder leans edited).
- ⚠️ Clinical-accuracy ask on V/VI "Never burns" — Wheeler's call.
- ✅ MED anchor table — sources legally clean, numerical values are facts.
- ✅ Time-to-burn formula — citations clean, formula and constants are facts.
- ✅ Default-state "no default" recommendation supports our claim-surface bound.
- ✅ Photosensitization spec — Plunder edited disclaimer wording above for §7.3.
- ✅ "What we DON'T claim" — aligned with my §8.9.

**Net effect:** Wheeler's brief and Plunder's framework converge on a single legally-defensible science + citation posture. Linka has all the inputs she needs to render. Kwame has all the inputs to implement.

---

## §11. Action Items by Owner

**Wheeler:**
- ✅ Ratify §C2 picker decision (Option 1 verbatim vs Option 2 edited) — Plunder leans Option 2.
- ✅ Ratify §C3 V/VI "Never burns" vs "Rarely burns" clinical-accuracy question.
- ✅ Ratify §C7 edited L1 disclaimer wording (Plunder canonical for the photosensitization line).
- ✅ Adopt Plunder paraphrase set in §2.3 if going Option 2 (or use Wheeler's edited variant from his §5.1 — Plunder accepts either).

**Linka:**
- ✅ Render the citation list in About per §5.2 / §5.3 / §5.4.
- ✅ Render the WeatherKit attribution per §7.3.
- ✅ Wire the three-layer disclaimer per §6.1 with Wheeler-edited L1 photosensitization line.
- ✅ Wire the L3 "Is this estimate for me?" link to the About → "When this estimate may not apply" anchor.
- ✅ Pick Option 1 or 2 from §C2 — final call on picker copy.

**Kwame:**
- ✅ Implement the WeatherKit lockup + URL per §7.2 / §7.3 — canonical URL is `https://developer.apple.com/weatherkit/data-source-attribution/`.
- ✅ Add a launch-readiness checklist item: verify the URL resolves at submit time AND at every minor-version update.
- ✅ Render the citation strings as `Link` views with proper accessibility traits.
- ✅ Implement Wheeler's MED table + formula as in his §2.5 / §3.2 Swift drop-in.

**Argos:**
- ✅ Drop the Open-Meteo line from the App Store description; replace with §7.4 Plunder line.
- ✅ Hold subtitle (§8.2) unchanged.
- ✅ Adopt §8.3 rewrite of "your skin can handle" → "may cause skin reddening."

**Suchi:**
- ✅ Persona-keyed disclaimer pattern is preserved via the three-layer model (L1/L2/L3). L3 specifically addresses your P4 (Asha) reachability need.
- ✅ Your §1.2 directive #4 (behavior-first symmetric framing) is honored by Option 2 (Wheeler's edited variant); preserved through-Plunder if Option 1 is chosen plus the V/VI clinical-accuracy fix.

**Gaia (FYI):**
- E7 (Privacy Policy + ToS health clauses) is on the launch-readiness path and not yet drafted. Flag for ownership.

**Yashasgujjar / engaging attorney:**
- §10 escalations E1–E8. None block design/build work; all should be reviewed by a licensed attorney before App Store submit.

---

*Plunder out. Naming the rule, not blocking the ship.*

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
