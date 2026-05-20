# Wheeler — History

## Core Context

- **Project:** A UV exposure and sunburn timer app
- **Role:** Skin Science Expert (Dermatology & UV Photobiology Research)
- **Joined:** 2026-05-18
- **Requested by:** yashasgujjar

## Learnings

### 2026-05-19 — Fitzpatrick / MED / time-to-burn canonical adoption

- **Canonical Fitzpatrick citation string (locked):** Ward WH, Farma JM, editors. *Cutaneous Melanoma: Etiology and Therapy*. Brisbane (AU): Codon Publications; 2017 Dec 21. Table 1, Chapter 6. doi:10.15586/codon.cutaneousmelanoma.2017.ch6. Available from NCBI Bookshelf NBK481857. Underlying scale: Fitzpatrick TB. *Arch Dermatol*. 1988;124(6):869–871.
- **Verbatim confirmation:** I direct-fetched `/books/NBK481857/table/chapter6.t1/` on 2026-05-19. All six rows match the directive's text word-for-word. No diff. Adopt as-is.
- **MED anchor source set chosen:** Fitzpatrick 1988 + Sayre 1981 + Diffey 1991 + Harrison & Young 2002, weighted by CIE S 007/E:1998. Values: I=200, II=250, III=300, IV=450, V=600, VI=1000 J/m² erythemally weighted. Rejected: clinical-phototherapy mJ/cm² values (would 5–10× over-estimate safe time).
- **Time-to-burn formula reference:** WHO/WMO/UNEP/ICNIRP *Global Solar UV Index: A Practical Guide*, WHO 2002 (UVI ↔ irradiance, 0.025 W/m² per UVI, exact-by-definition) + Schalka & Reis 2011 (SPF as linear multiplier on MED) + Diffey 1991 (MED-over-irradiance accumulation form).
- **Photosensitization signal taxonomy:** classes worth naming generically — isotretinoin, tetracycline-class antibiotics, fluoroquinolones, thiazide diuretics, sulfonamides, amiodarone, voriconazole, phenothiazines, NSAIDs (piroxicam), St John's Wort, methotrexate. Conditions — cutaneous/systemic lupus, porphyrias (EPP), xeroderma pigmentosum, vitiligo (local), albinism, post-procedure skin (laser/peel/retinoid initiation), pregnancy melasma (cosmetic), infants (<6mo, sun avoidance regime). Headline-bound MED reductions: typical 2–4×, worst-case 5–10×, EPP near-instant.
- **Default-state safety rule:** no default Fitzpatrick selection on first launch. If a technical default is unavoidable, default to Type I (most conservative). Over-estimating safe time is a one-way safety error; under-estimating is harmless.
- **What we DO NOT claim (locked):** no "safe sun time", no vitamin D timing, no tanning duration, no SPF reapplication math, no cancer-risk claim, no UVI-as-categorical-label, no pediatric / pregnancy advice, no brand drug names — generic / class only.
- **Health-adjacent constant adoption protocol** (extracted as a reusable skill): source → verify (direct fetch / verbatim diff) → derive → cite per value → label as established / reasonable-approximation / out-of-scope → bound the claim surface → hand off in canonical drop-in form. Skill written to `.squad/skills/health-adjacent-constant-adoption/SKILL.md`.

### 2026-05-19T16:30 — Work item #4 kickoff: Fitzpatrick paraphrase traceability audit

- **What I did:** Audited the six picker rows in `FitzpatrickSkinType.pickerDescription` (HEAD on `squad/4-approved-redesign-paraphrasing`) against NBK481857 Table 1 verbatim and the locked source set in my archive file. Audited `ProductCopy.fitzpatrickCitations` + `ProductCopy.citationLinks` against `wheeler-source-backed-skin-type-questions.md` §4 and `plunder-about-citation-policy.md` §1–§4. Wrote `.squad/decisions/inbox/wheeler-paraphrase-traceability-review.md` as the work-item-#4 acceptance-criterion-#3 deliverable (source concept → app wording → rationale → reviewer sign-offs).
- **Findings:** (1) All six rows are paraphrased — no verbatim NCBI reproduction. ✅ (2) Three rows soften "Always"/"Never" claims (II less conservative, V/VI more conservative); safety-direction acceptable but undocumented on About. (3) Row III over-claims relative to source ("burns moderately" vs "sometimes mild burn"); one-word fix. (4) Three rows (I, II, IV) include sub-descriptors (hair, eyes, "olive") not in NBK481857; trace to Fitzpatrick 1988 instead — re-anchor in About is cheapest fix. (5) The Schalka link in `citationLinks` points to Schalka 2009, but the locked source is Schalka & Reis 2011; URL mismatch is a citation-discipline failure. (6) Sayre 1981 and Harrison & Young 2002 are referenced in About text but have no clickable link entries.
- **What I did NOT change:** No app code touched. MED values unchanged. No-default behavior unchanged. L1–L4 architecture unchanged. WeatherKit attribution unchanged. Wheeler edited-variant softenings for I and VI (already D-2026-05-19-009) unchanged.
- **What's blocked on others:** Plunder must rule on §4.1 (re-anchor vs remove vs inline-cite) and §5 (About completeness gaps in rows 2, 3, 7, 8, 9 of their §2.2 layout). Suchi must pick Option A vs B for the picker question header (§3.3). Iris must re-validate accessibility after any string changes. Kwame implements only after all three sign off.
- **Reusable learning (for any future paraphrase audit):** The traceability format that works is **per-row table with separate columns for safety-direction drift and per-reviewer sign-off**, not narrative prose. Reviewer columns force each agent to claim their slice without overlap. Safety-direction column makes it explicit whether a softening makes us safer or less safe — a softening of "Always burns" is a real, sometimes-warranted loss of urgency that must be defended, not assumed harmless.
- **Citation-discipline rule reinforced:** When a footnote names a source by author + year, the corresponding clickable link MUST resolve to the same paper. Schalka 2009 ≠ Schalka & Reis 2011 — both exist, both are real, but they cite different things. The locked source list in `archive/wheeler-fitzpatrick-and-med-anchor.md` §4 is the canonical anchor for which Schalka. Future Wheeler audits should diff `citationLinks` URLs against the archive locked list as a routine check.
- **Out-of-scope reaffirmation:** Roberts 2009 (skin-of-color extension), Lancer pigmentation scale, Baumann 64-question cosmetic scale — explicitly OUT of scope for work item #4. Any future feature requiring them ships with its own decision file + its own About citation row, per `wheeler-source-backed-skin-type-questions.md` §3.4.


### 2026-05-20T00:01:47Z: Team Decision

**Scribe Log Entry**

Team approvals and implementations completed for approved redesign and paraphrasing initiatives:
- Wheeler: Paraphrase traceability review (conditional accept, fixes noted)
- Ma-Ti: Redesign tests passing + gauge guard tests verified
- Iris: HIG/accessibility audit passed
- Kwame: Implementation and circular gauge both passing

All inbox decisions merged into decisions.md.

### 2026-05-19T22:29:07.093-07:00 — Sunscreen two-hour cap science/product check

- **Finding:** "Reapply sunscreen every 2 hours" is an upper-bound cadence, not a permission to rely on SPF-modeled burn protection beyond two hours. CDC/FDA/AAD-style guidance treats reapplication as at least every 2 hours and sooner after swimming, sweating, or toweling.
- **Implementation handoff:** For any estimate where SPF is not `.none`, the user-facing burn/safe-window should be capped at `ProductTiming.sunscreenReapplicationIntervalSeconds` (120 minutes). If the raw SPF-adjusted burn model exceeds 120 minutes, display a 2-hour/reapply-capped result and copy that explains the model exceeded the sunscreen reapplication window rather than implying sunscreen protects longer.
- **Nuance:** Keep unprotected (`SPF none`) estimates governed by the burn model; the 2-hour cap is a sunscreen-use claim bound, not a universal erythema threshold.
