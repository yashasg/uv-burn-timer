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


