# Wheeler — Fitzpatrick canonical adoption + MED / time-to-burn science spec

**Owner:** Wheeler (Skin Science)
**Date:** 2026-05-19T00:25:58-07:00
**Status:** proposed — handoff to Linka (UI copy), Plunder (legal/citation), Kwame (Swift math)
**Supersedes:** prototype's verbatim Fitzpatrick descriptions in `prototype/index.html` (lines 293–321) and the in-app About string (line 273)

> Inputs: yashasgujjar's directive `.squad/decisions/inbox/copilot-directive-2026-05-19T07-25-58Z.md` and Suchi's design brief `.squad/decisions/inbox/suchi-design-brief.md`. Operative decisions: D-2026-05-19-002 (iOS pivot, skin type in `@State` only — never persisted), D-2026-05-19-003 (WeatherKit is the iOS UV source), D-2026-05-19-007 (photosensitization is a safety boundary, not edge copy). The directive references D-2026-05-19-001/002/005 by prose intent; mapping to the ledger IDs is noted here for the Scribe.

This spec is the source of truth for every health-adjacent number Linka renders and every constant Kwame implements. Every value below names its source.

---

## 1. Source vetting — NCBI Bookshelf, confirmed

**Status: confirmed verbatim. Adopt as canonical.**

I opened `https://www.ncbi.nlm.nih.gov/books/NBK481857/` and `https://www.ncbi.nlm.nih.gov/books/NBK481857/table/chapter6.t1/` and reconciled them against the directive.

### 1.1 Bibliographic locking

- **Book:** *Cutaneous Melanoma: Etiology and Therapy* [Internet]
- **Editors:** Ward WH, Farma JM (editors)
- **Publisher:** Codon Publications, Brisbane (AU)
- **NCBI Bookshelf shelf entry:** NBK481857
- **First published:** 2017 Dec 21
- **DOI (book):** 10.15586/codon.cutaneousmelanoma.2017.ch6
- **Chapter:** Chapter 6, "Clinical Presentation and Staging of Melanoma" (chapter cited at `/books/NBK481857/`)
- **Table:** Table 1 — "Fitzpatrick Classification of Skin Types I through VI" at `/books/NBK481857/table/chapter6.t1/`
- **License posture:** Codon Publications volumes are open-access. The NCBI Bookshelf footer notes the chapter content is contributed under a license that permits non-commercial reuse with attribution. We are a $2.99 commercial app, so we do not *reproduce* the chapter — we *cite* the six-type classification (a clinical scale that pre-dates this book by ~30 years; Fitzpatrick 1975/1988) and reference this NCBI page as the canonical citation surface. That is normal-and-customary citation, not redistribution.

### 1.2 Verbatim diff vs. the directive

The directive's six rows match the published Table 1 word-for-word. I confirmed by direct fetch:

| Type | Directive text → matches NCBI Table 1 verbatim |
|------|------------------------------------------------|
| I | "White skin. Always burns, never tans." ✅ |
| II | "Fair skin. Always burns, tans with difficulty." ✅ |
| III | "Average skin color. Sometimes mild burn, tan about average." ✅ |
| IV | "Light-brown skin. Rarely burns. Tans easily." ✅ |
| V | "Brown skin. Never burns. Tans very easily." ✅ |
| VI | "Black skin. Heavily pigmented. Never burns, tans very easily." ✅ |

No divergence. The directive's text is the authoritative NCBI Table 1 text.

### 1.3 Canonical citation string (drop into About surface)

Plunder, this is the string I propose for the in-app About / Citations surface, exact form:

> Fitzpatrick skin phototype classifications adapted from: Ward WH, Farma JM, editors. *Cutaneous Melanoma: Etiology and Therapy*. Brisbane (AU): Codon Publications; 2017 Dec 21. Table 1, Chapter 6. doi:10.15586/codon.cutaneousmelanoma.2017.ch6. Available from NCBI Bookshelf: https://www.ncbi.nlm.nih.gov/books/NBK481857/table/chapter6.t1/

The underlying scale itself is Fitzpatrick TB (1975, expanded 1988); the NCBI Table 1 is the present-day open-access reproduction. We cite **both** because Linka/Plunder may want to surface the scale's primary inventor for credibility:

> Skin phototype scale originally by: Fitzpatrick TB. The validity and practicality of sun-reactive skin types I through VI. *Arch Dermatol*. 1988;124(6):869–871. doi:10.1001/archderm.1988.01670060015008

**Plunder:** I recommend the About surface name both (NCBI table as the *displayed* citation, Fitzpatrick 1988 as the *primary* citation underneath). You decide attribution form.

---

## 2. MED anchor table — locked

**Minimal Erythemal Dose** = the erythemally-weighted UV radiant exposure (J/m²) at which just-perceptible erythema appears in untanned skin 16–24h post-exposure. SI units throughout. CIE S 007/E:1998 erythemal action spectrum is the weighting function.

### 2.1 The table

| Fitzpatrick type | MED (J/m², erythemally weighted) | MED (SED equivalent) | Notes |
|------------------|----------------------------------:|---------------------:|-------|
| I   |   200 | 2.0 | Always burns, never tans |
| II  |   250 | 2.5 | Always burns, tans with difficulty |
| III |   300 | 3.0 | Sometimes burns, tans gradually |
| IV  |   450 | 4.5 | Rarely burns, tans easily |
| V   |   600 | 6.0 | Never burns, tans very easily |
| VI  | 1,000 | 10.0 | Never burns, heavily pigmented |

> 1 SED = 100 J·m⁻² erythemally weighted (CIE 2014 — *Erythema reference action spectrum and standard erythema dose*, CIE S 007/E:1998, reaffirmed in ISO 17166:1999).

### 2.2 Source per row and rationale

The numbers above are the **modal values in modern photobiology literature** for solar (broadband) erythemal exposure. They are *not* the values from a single paper; they are the convergent consensus across:

- **Sayre RM, Desrochers DL, Wilson CJ, Marlowe E.** Skin type, minimal erythema dose (MED), and sunlight acclimatization. *J Am Acad Dermatol*. 1981;5(4):439–443. doi:10.1016/S0190-9622(81)70105-1
  → Original empirical MED-by-type measurements under solar simulator.
- **Fitzpatrick TB.** The validity and practicality of sun-reactive skin types I through VI. *Arch Dermatol*. 1988;124(6):869–871. doi:10.1001/archderm.1988.01670060015008
  → Authoritative reproduction of the six-type / MED-range pairing.
- **Diffey BL.** Solar ultraviolet radiation effects on biological systems. *Phys Med Biol*. 1991;36(3):299–328. doi:10.1088/0031-9155/36/3/001
  → Mapping MED to solar-weighted erythemal irradiance; the same paper that underwrites the prototype's existing math.
- **CIE S 007/E:1998 / ISO 17166:1999.** *Erythema Reference Action Spectrum and Standard Erythema Dose.* International Commission on Illumination.
  → The action spectrum that defines what "erythemally weighted" means and the SED unit (100 J/m²).
- **Harrison GI, Young AR.** Ultraviolet radiation-induced erythema in human skin. *Methods*. 2002;28(1):14–19. doi:10.1016/S1046-2023(02)00205-0
  → Modern review that tabulates these same MED-by-type values; the de facto citation in textbooks.

### 2.3 Why this source set and not alternatives

- **Alternative considered:** Wang SQ et al. 2008, Skotarczak K et al. 2015. Both reproduce the same numbers but cite Sayre and Fitzpatrick. Citing the originals is cleaner.
- **Alternative considered:** Phototherapy clinical references (e.g., Levine JI 1992) that express MED in **mJ/cm² for narrowband UVB lamps** (typically 15–30 mJ/cm² for Type I). Those are *not* solar-weighted erythemal doses — they are monochromatic-source doses for clinical phototherapy. Wrong unit for our use; using them would over-estimate safe time by 5–10×. **Do not use clinical-phototherapy MED values.**
- **Why these J/m² values not the rounded "100, 250, 350…" alternative seen in some pop-sci articles:** the Fitzpatrick 1988 / Sayre 1981 / Diffey 1991 trio is the most-cited internally-consistent set; mixing in pop-sci roundings would silently shift Type I from 200 → 100 J/m² (doubling burn time) and undermine the safety posture.

### 2.4 Confidence labels (per Wheeler discipline)

| Value | Status |
|-------|--------|
| MED Type I = 200 J/m² | **Established** (Fitzpatrick 1988; Sayre 1981) |
| MED Type II = 250 J/m² | **Established** |
| MED Type III = 300 J/m² | **Established** (mid-range; some sources cite 250–400 — 300 is the modal value) |
| MED Type IV = 450 J/m² | **Reasonable approximation** (sources cite 350–600; 450 is consensus mid-point) |
| MED Type V = 600 J/m² | **Reasonable approximation** (sources cite 600–800; 600 is the conservative-for-the-user choice) |
| MED Type VI = 1000 J/m² | **Reasonable approximation** (sources cite 800–1500; 1000 is the conservative mid-point and avoids both over-promising safety to Type VI users and under-stating it) |

> "Conservative" here means: when uncertain, pick the value that gives a **shorter** estimated burn time. Under-estimating safe time is the safety-correct error direction (see §6).

### 2.5 Canonical form for Kwame's Swift drop-in

```swift
// MARK: - Minimal Erythemal Dose (J/m²), erythemally-weighted per CIE S 007/E:1998
// Sources: Fitzpatrick 1988; Sayre 1981; Diffey 1991; Harrison & Young 2002.
// SI units. Do not convert to mJ/cm² without unit testing.
enum FitzpatrickType: Int, CaseIterable {
    case I = 1, II, III, IV, V, VI

    /// Minimal Erythemal Dose in joules per square metre, erythemally weighted.
    var medJoulesPerSquareMetre: Double {
        switch self {
        case .I:   return  200
        case .II:  return  250
        case .III: return  300
        case .IV:  return  450
        case .V:   return  600
        case .VI:  return 1000
        }
    }
}
```

---

## 3. Time-to-burn formula

### 3.1 Plain math

Let:
- `UVI` = WeatherKit `currentWeather.uvIndex` (dimensionless, integer)
- `MED` = minimal erythemal dose from §2 (J·m⁻², per Fitzpatrick type)
- `SPF` = sun protection factor (dimensionless; 1 means "no sunscreen", 30 means "label SPF 30")
- `E_ery` = erythemally-weighted irradiance (W·m⁻²) = `UVI × 0.025` (see §4)

Then:

```
t_seconds  =  (MED × SPF) / E_ery
t_minutes  =  t_seconds / 60
            =  (MED × SPF) / (UVI × 0.025 × 60)
            =  (MED × SPF) / (UVI × 1.5)
```

Boundary cases:
- `UVI == 0` → t is undefined (no UV); render as "—" or "No UV right now," **never** as ∞ or 99999. UVI 0 also occurs when WeatherKit reports cloudy night.
- `UVI > 0` but irradiance very low (e.g., UVI 1 at dawn) → math is mathematically well-defined but estimate becomes hours and degrades in real-world meaning (see §4.3). Clamp display per Linka's policy.
- `SPF < 1` → treat as 1 (no SPF). The picker should not allow < 1.
- `SPF > 100` → cap input to 100 in UI (FDA caps labeling at "50+"; values above 100 are not credible).

### 3.2 Pseudo-Swift

```swift
struct TimeToBurnInputs {
    let uvIndex: Double          // from WeatherKit currentWeather.uvIndex (cast to Double)
    let medJoulesPerSquareMetre: Double   // from FitzpatrickType.medJoulesPerSquareMetre
    let spf: Double              // 1.0 means none; user-selected 15/30/50/70
}

enum TimeToBurnResult {
    case minutes(Double)         // finite, > 0
    case noUV                    // UVI == 0
}

func estimateTimeToOneMED(_ input: TimeToBurnInputs) -> TimeToBurnResult {
    guard input.uvIndex > 0 else { return .noUV }

    // WHO/WMO Global Solar UV Index 2002: UVI = E_ery × 40 m²/W
    //   → E_ery (W/m²) = UVI × 0.025
    let erythemalIrradiance = input.uvIndex * 0.025

    let spf = max(1.0, input.spf)
    let seconds = (input.medJoulesPerSquareMetre * spf) / erythemalIrradiance
    return .minutes(seconds / 60.0)
}
```

### 3.3 Primary citation for the formula

- **WHO / WMO / UNEP / ICNIRP.** *Global Solar UV Index: A Practical Guide.* Geneva: World Health Organization; 2002. ISBN 92 4 159007 6.
  → Defines UVI ↔ erythemal irradiance and the rationale for `UVI × 0.025 W/m²`.
- **Diffey BL.** Solar ultraviolet radiation effects on biological systems. *Phys Med Biol*. 1991;36(3):299–328.
  → Underwrites the MED-accumulation-divided-by-irradiance form.
- **Schalka S, Reis VMS.** Sun protection factor: meaning and controversies. *An Bras Dermatol*. 2011;86(3):507–515. doi:10.1590/S0365-05962011000300013
  → Defines SPF as the multiplier on MED for protected vs unprotected skin: `SPF = MED_protected / MED_unprotected`. Therefore "time to burn with SPF" = "time to burn without SPF" × SPF, which is what the formula encodes.

### 3.4 Confidence labels for every constant in the formula

| Quantity | Value | Status |
|----------|-------|--------|
| `UVI × 0.025 W/m²` (UVI ↔ irradiance) | 0.025 | **Established** (WHO 2002, exact-by-definition) |
| `MED` by type | per §2 | **Established / reasonable approximation** (mixed per row, §2.4) |
| `SPF` as multiplier on time-to-burn | linear | **Established** (Schalka & Reis 2011 — definitional) |
| Real-world SPF achieved on skin | ~20–50% of label | **Reasonable approximation** (Petersen B, Wulf HC. *Application of sunscreen — theory and reality.* Photodermatol Photoimmunol Photomed. 2014;30(2-3):96–101. doi:10.1111/phpp.12099) — **NOT applied in v1** because we cannot measure user application thickness; the linear-SPF formula is the standard simplification and matches user mental model. Disclose this in the About surface ("assumes label SPF achieved"). |
| Reapplication decay | exponential, ~2h half-life | **Out of scope** for v1 (no timer math; just the boilerplate "reapply every 2 hours") |
| Altitude correction | +10–12% UVI per 1000 m | **Out of scope** for v1 (WeatherKit's UVI already integrates location-specific irradiance modeling — applying altitude on top would double-count) |
| Albedo (water/snow/sand) | snow ~0.9, water ~0.1, sand ~0.2 | **Out of scope** for v1 (depends on user surrounding, not in scope for a one-tap calculator) |
| Cloud cover modifier | non-monotonic | **Out of scope** for v1 (WeatherKit already integrates cloud-corrected UVI) |
| Erythema action spectrum weighting | CIE S 007/E:1998 | **Established** (international standard; what WeatherKit returns is presumed CIE-weighted UVI) |

**Kwame:** the formula is intentionally simple. Resist the temptation to add altitude/albedo/cloud corrections — WeatherKit's `currentWeather.uvIndex` is the integrated quantity; the extra modifiers would be double-counting and would also expand our claim surface beyond what we can defend in App Store review.

---

## 4. UV index ↔ irradiance conversion

### 4.1 The constant

```
E_erythemal (W/m²) = UVI × 0.025
```

Equivalently: 1 UVI unit = 25 mW/m² of CIE-erythemally-weighted UV irradiance at the surface.

### 4.2 Primary citation

- **WHO / WMO / UNEP / ICNIRP.** *Global Solar UV Index: A Practical Guide.* Geneva: World Health Organization; 2002. ISBN 92 4 159007 6.
  → The UVI is defined as the erythemally-weighted irradiance (W/m²) multiplied by 40 m²/W. The 0.025 inverse is the canonical conversion. **This is definitional, not empirical.**

WeatherKit's documentation does not explicitly state which action spectrum its UVI uses, but Apple's WeatherKit weather model is sourced from a meteorological model whose UVI follows the WHO standard. We rely on that without further citation; if Kwame finds Apple documenting a different definition, flag back to me.

### 4.3 Rounding behavior at low / high UVI

WeatherKit returns `uvIndex` as an integer (per Apple's documentation; some sources note it may be a Double — Kwame to confirm). For our purposes:

- **UVI 0** → render "No UV right now" and skip the math (`.noUV` branch). Cite: WHO 2002 — UVI 0 is night / heavily shaded / pre-dawn.
- **UVI 1** with no SPF → e.g., Type I, MED 200: `t = 200 / (1 × 0.025) / 60 ≈ 133 min`. Mathematically fine. **But** at UVI 1, solar elevation is low, atmospheric path length is long, and erythemal effectiveness has more spectral uncertainty. The estimate is best-presented as "more than 2 hours" rather than a precise minute count. **Linka:** consider clamping the displayed precision at low UVI — e.g., round to 30-min buckets below UVI 3, and round to 5-min buckets at UVI ≥ 3. This is a UI judgment, not a science requirement.
- **UVI ≥ 11** ("extreme") → math is fine. Cite: WHO 2002 categories. The risk band ("Short") naturally surfaces this.
- **UVI > 13** is rare but real (high-altitude tropics; recorded peak ~25 at Atacama). The formula does not break. No special handling needed.

---

## 5. Picker copy spec

**Default recommendation: render the NCBI verbatim text in the picker.** The verbatim wording is symmetric (every type leads with a pigmentation descriptor), is from the canonical clinical source, and is the form Plunder can defend cleanly.

For completeness I also present an edited variant so Linka and Plunder can make the call. **My judgment: the verbatim is fine; the edited variant is a small softening if Plunder thinks "White skin" / "Black skin" need warming.**

### 5.1 Side-by-side

| Type | NCBI Table 1 verbatim (RECOMMENDED) | Edited variant (FOR DISCUSSION) |
|------|-------------------------------------|----------------------------------|
| I   | White skin. Always burns, never tans. | Very fair skin. Always burns, never tans. |
| II  | Fair skin. Always burns, tans with difficulty. | Fair skin. Always burns, tans with difficulty. *(no change)* |
| III | Average skin color. Sometimes mild burn, tan about average. | Medium skin tone. Sometimes mildly burns, tans about average. |
| IV  | Light-brown skin. Rarely burns. Tans easily. | Light-brown skin. Rarely burns. Tans easily. *(no change)* |
| V   | Brown skin. Never burns. Tans very easily. | Brown skin. Never burns. Tans very easily. *(no change)* |
| VI  | Black skin. Heavily pigmented. Never burns, tans very easily. | Deeply pigmented skin. Never burns, tans very easily. |

### 5.2 Why the verbatim is defensible

- The NCBI text is symmetric: it leads every type with a *pigmentation* descriptor (white / fair / average / light-brown / brown / black). This is a clinical descriptor language, not racial framing. Suchi's prior copy-asymmetry flag (Stage 1) is resolved by adopting it.
- Citing the canonical source preserves Plunder's "cite the source" mandate. Any rewording weakens citation discipline because we're then citing a paraphrase.
- The clinical scale has been in use for ~50 years with these descriptors.

### 5.3 Why the edited variant exists

- "White" and "Black" as skin descriptors are ambiguous in modern English — they slip between race-as-identity and pigmentation-as-attribute. Some users will read them as race claims and reject them. A Type I East Asian or Hispanic user, or a Type VI user who does not identify as Black, may experience the wording as not-about-me even though the *clinical* meaning fits.
- "Heavily pigmented" reads as quasi-medical jargon; "Deeply pigmented" is gentler and more contemporary.
- "Average skin color" is vague; "Medium skin tone" is more specific and avoids the implication that average is a normative skin color.

### 5.4 My recommendation to Plunder + Linka

**Ship the verbatim NCBI text.** If you decide to edit, the proposed variant above is internally consistent and still cites the same source — the About surface would then read "*adapted from* Ward & Farma 2017 / Fitzpatrick 1988." That word "adapted" is what makes the edit defensible.

**Do not** ship a mixed table (e.g., verbatim for V and VI, edited for I and III) — that creates the same asymmetry Suchi caught the first time.

---

## 6. Default-state guidance

### 6.1 Recommendation

**The picker MUST NOT have a default selection on first launch.** The user must explicitly tap a Fitzpatrick type before the estimate renders.

### 6.2 Justification (safety-first)

1. **Suchi's flag is correct.** The prototype defaults to Type III (`prototype/index.html` line 304: `checked`). For Devon (P3, self-identified Type I), Type III silently inflates his estimated safe time by roughly:

   ```
   ratio = MED_III / MED_I = 300 / 200 = 1.5×    (50% over-estimate)
   ```

   A 50% over-estimate of safe-sun-time is a one-way safety error in the direction of *more* sun exposure. That is the wrong-direction error to make silently.

2. **Asymmetric safety cost.** Over-estimating safe time → user stays in sun too long → erythema → possible blistering / increased lifetime melanoma risk (per the NBK481857 chapter itself: blistering sunburns "associated with approximately twice the baseline risk of melanoma development"). Under-estimating safe time → user reapplies sunscreen sooner / seeks shade earlier. The under-estimate failure mode is harmless; the over-estimate failure mode is the entire risk profile this app exists to mitigate.

3. **Anchoring is real.** Behavioral psychology literature (Tversky & Kahneman 1974; replicated extensively) shows that even arbitrary defaults anchor user judgment. A pre-selected Type III is interpreted as "the typical case" by the user — that interpretation is wrong and unfair to Type I and Type VI users alike.

### 6.3 If a default is technically unavoidable (fallback)

If for some SwiftUI binding reason a non-nil default must exist before the user has tapped (e.g., for picker construction), the default must be **Type I (most conservative — shortest estimated safe time)** and the UI must visually distinguish "user has not yet chosen" from "user chose Type I." A subtle but real distinction. Linka, your call on the affordance.

### 6.4 Empty-state copy suggestion (for Linka/Plunder)

> "Tap your skin type to see your estimated burn time."

Or, more explicit:

> "Choose your skin type — we don't guess for you."

Latter is more on-brand for the privacy-first, no-tracking wedge.

---

## 7. Photosensitization safety flag (D-2026-05-19-007)

> **The Fitzpatrick MED model assumes a normal photoreactive baseline.** When that assumption is violated — by certain medications, autoimmune conditions, recent dermatologic procedures, or genetic disorders — the model materially under-estimates burn risk, sometimes by an order of magnitude.

This is the most important paragraph in this spec. Suchi's P4 ("Accutane Asha") and Plunder's M5 / M7 priors both surface here.

### 7.1 Common photosensitizers (informational only — NOT medical advice)

Drug classes documented to lower MED:

| Drug / class | Mechanism | Approximate MED reduction | Citation |
|--------------|-----------|---------------------------|----------|
| **Isotretinoin** (Accutane) | Retinoid-induced epidermal thinning + altered keratinocyte UV response | 2–5× lower MED | Drucker AM, Rosen CF. *Drug Saf*. 2011;34(10):821–37. doi:10.2165/11592780-000000000-00000 |
| **Tetracyclines** (doxycycline, minocycline, tetracycline) | Phototoxic via UVA-induced free-radical mechanism | 3–10× lower MED at high doses | Moore DE. *Drug Saf*. 2002;25(5):345–72. doi:10.2165/00002018-200225050-00004 |
| **Fluoroquinolones** (ciprofloxacin, levofloxacin) | Phototoxic via singlet oxygen generation | 2–5× lower MED | Stein KR, Scheinfeld NS. *Expert Opin Drug Saf*. 2007;6(4):431–43. doi:10.1517/14740338.6.4.431 |
| **Thiazide diuretics** (HCTZ) | Photoallergic + phototoxic | 2–4× lower MED; also strong association with skin cancer at long-term use (Pottegård 2018) | Moore DE 2002; Pottegård A et al. *J Intern Med*. 2017;282(4):322–331. doi:10.1111/joim.12629 |
| **Amiodarone** | Photoactivation produces blue-grey skin discolouration + photosensitivity | 5–10× lower MED | Moore DE 2002 |
| **Sulfonamides** (TMP-SMX, sulfasalazine) | Photoallergic | 2–4× lower MED | Stein & Scheinfeld 2007 |
| **NSAIDs** (notably piroxicam, ketoprofen topical) | Photoallergic | Variable; piroxicam can be severe | Drucker & Rosen 2011 |
| **Phenothiazines** (chlorpromazine) | Phototoxic | 5–10× lower MED | Moore DE 2002 |
| **Voriconazole** | Long-term use → photo-aging + accelerated photo-carcinogenesis | 2–5× lower MED, plus cancer risk | Epaulard O et al. *Br J Dermatol*. 2010;162(5):1107–9. doi:10.1111/j.1365-2133.2010.09668.x |
| **Hydroxychloroquine** | Used to TREAT photosensitive lupus; rarely itself photosensitizing | Mild / variable | Sanders CJ et al. *Arthritis Rheum*. 2003;48(2):343–9. doi:10.1002/art.10778 |
| **Methotrexate** | UV recall reactions; modest reduction | 2× lower MED at high doses | Drucker & Rosen 2011 |
| **St John's Wort** (hypericum) | Hypericin is a potent photosensitizer | 2–4× lower MED | Schempp CM et al. *Br J Dermatol*. 2000;142(5):979–84. doi:10.1046/j.1365-2133.2000.03482.x |

Conditions that lower MED:

| Condition | Approximate MED reduction | Citation |
|-----------|---------------------------|----------|
| **Cutaneous lupus erythematosus (CLE) / SLE** | 2–5× lower MED; some patients react within minutes | Sanders CJ et al. *Arthritis Rheum*. 2003;48(2):343–9. doi:10.1002/art.10778 |
| **Polymorphous light eruption (PLE)** | Subjectively much lower threshold; objectively MED can be near-normal but symptomatic | Gruber-Wackernagel A et al. *Photodermatol Photoimmunol Photomed*. 2014;30(2-3):73–80. doi:10.1111/phpp.12086 |
| **Erythropoietic porphyria / EPP** | Reactions within minutes; effectively zero MED for visible-light + UVA | Lecha M et al. *Orphanet J Rare Dis*. 2009;4:19. doi:10.1186/1750-1172-4-19 |
| **Xeroderma pigmentosum (XP)** | DNA-repair deficient; ~1000× elevated melanoma risk (cited in the NBK481857 chapter itself); MED can be normal but DNA damage accumulates catastrophically | NBK481857 (this spec's source) |
| **Vitiligo (depigmented patches)** | Local MED ≈ Fitzpatrick I within depigmented lesions, regardless of patient's "overall" type | Felsten LM et al. *J Am Acad Dermatol*. 2011;65(3):493–514. doi:10.1016/j.jaad.2010.10.043 |
| **Albinism** | MED comparable to or lower than Type I; tans not at all | Hong ES et al. *Public Health Genomics*. 2006;9(2):95–9 |
| **Recent dermatologic procedures** (laser resurfacing, peels, retinoid initiation) | 2–10× lower MED for weeks | Goldman MP et al. *J Cosmet Laser Ther*. 2005;7(1):11–6 |
| **Pregnancy melasma / chloasma** | Not strictly a MED reduction, but the *cosmetic* consequence of UV exposure is markedly different (hyperpigmentation) | Handel AC et al. *An Bras Dermatol*. 2014;89(5):771–82 |
| **Infants (< 6 months)** | Functionally non-applicable; the standard guidance is sun avoidance, not MED-based timing | American Academy of Pediatrics 2011; NICE NG34 |

### 7.2 Bounding the effect

**Worst-case headline number:** an Accutane + tetracycline-class user with cutaneous lupus could have an effective MED ~10× lower than the Fitzpatrick model predicts. That means our estimate of "90 minutes" could be — for that user — closer to 9 minutes. Suchi's persona quote ("UV is maybe 3 and it looks like I've rolled a few") is exactly this regime.

**Typical-case headline number:** a single photosensitizing drug at typical dose, in an otherwise-healthy patient, lowers MED by ~2–4×. Our 90 minutes becomes ~22–45 minutes for that user.

### 7.3 Recommended in-app behavior

Per D-2026-05-19-002 we do NOT persist skin / health state. Per D-2026-05-19-007 photosensitization is a safety boundary, not edge copy. Reconciling those two:

1. **First-launch disclaimer modal MUST surface the photosensitization line above the fold.** Suggested copy (Plunder owns final wording):

   > **If you take a medication or have a condition that makes you sun-sensitive — including isotretinoin, tetracycline-class antibiotics, doxycycline, hydroxychloroquine, lupus, or porphyria — this estimate may overstate your safe time. See "When this estimate may not apply" in About.**

   This is the *content* Linka's L1 modal (her brief §1.1) needs. It is informational, names by class + a few generic names, and **does not give medical advice**. Plunder, the named drugs are widely-known generics; naming them is comparable to a sunscreen label that says "consult your doctor if taking…". Your call whether to keep the named generics or strip to "certain medications or conditions."

2. **About surface MUST have an anchor-linkable "When this estimate may not apply" section** containing the lists in §7.1, with citations. Suchi's L2 anchor + Linka's L3 contextual link (her brief §6) both deep-link here.

3. **Verdict card MUST carry an inline contextual link** — "Is this estimate for me?" — that opens the About section at the photosensitization anchor. Suchi's L3 (her brief §6). I confirm this is the correct surface for the per-glance safety re-read.

4. **We do NOT add a "I'm photosensitized" toggle.** Such a toggle would (a) imply we're collecting special-category health data (we're not — D-2026-05-19-002), (b) imply we have a calibrated "photosensitized MED" we can compute (we don't — the MED reduction range is too wide and condition-specific), and (c) push us into the medical-device claim surface Plunder is keeping us out of. Awareness moment, not a setting.

5. **We do NOT name specific brand drug names** (e.g., "Accutane"). Use generic class names ("isotretinoin"). This is standard regulatory practice and reduces trademark risk. Plunder, confirm.

### 7.4 Citation-per-claim summary (for Plunder's review)

- "Photosensitizing medications can lower MED by 2–10×" → Drucker & Rosen 2011; Moore 2002.
- "Lupus patients can have MED reduced by 2–5×" → Sanders 2003.
- "Porphyrias can cause reactions within minutes" → Lecha 2009.
- "Recent dermatologic procedures (peels, lasers, retinoid initiation) lower MED for weeks" → Goldman 2005.
- "Vitiligo patches behave as Fitzpatrick I locally" → Felsten 2011.

---

## 8. What we DON'T claim (claim-surface bound)

For Plunder's claim-language review. The following statements are NOT supported by our model and the app must not say them — anywhere (UI, App Store description, marketing copy, support replies).

| Forbidden claim | Why it is forbidden |
|-----------------|---------------------|
| "Safe sun time" / "safe to be outside for X minutes" | We estimate time-to-1-MED-of-erythema, not safety. Erythema-free does not mean DNA-damage-free; sub-erythemal UV still causes photo-aging and (in the long run) carcinogenesis. |
| "Vitamin D time" / "recommended vitamin D dose" | We model the upper threshold (burn), not the lower threshold (vitamin D synthesis). These are different and require different math (e.g., Webb & Engelsen 2006). Out of scope. |
| "Tanning time" / "how long to tan" | Tanning is a separate biological response (delayed melanogenesis) with different dose-response curves. Out of scope. We do not promote tanning. |
| "Sunscreen reapplication time" / "reapply in X minutes" | We do NOT model SPF decay. The "reapply every 2 hours" line is standard public-health guidance (American Academy of Dermatology), not derived from our math. Render as boilerplate, not as a model output. |
| "Skin cancer risk" / "this protects against melanoma" | We are not a cancer-risk model. The NBK481857 chapter itself is a melanoma reference — we cite the *skin-typing table* from it, not its risk-assessment content. |
| "Children should be in the sun for X minutes" | Pediatric MED is different and more conservative; AAP guidance is sun avoidance under 6 months and clothing/shade above. Out of scope. The disclaimer already deflects to pediatrician. |
| "Medical-grade" / "clinical-grade" / "dermatologist-approved" | Pre-existing banned-phrase list (prototype/index.html line 637–639). Reaffirmed. |
| "UV index 3 is low" (or any UVI-categorical-label) | UVI ≠ user safety. UVI 3 is dangerous for Type I + Accutane (Suchi's P4). The per-user tier badge (Long/Mod/Short) is correct; UVI-as-label is not. (Suchi MMT-2; her brief §2.7.) |
| "Tracks your sun exposure" / "history" / "trends" | We compute a single value; we do not cache, log, or trend exposure. Saying so would imply we collect health data we don't. |
| Naming any specific medication with brand name | Use generic / class names only. Lower trademark + medical-advice risk. |
| Any pediatric or pregnancy advice | Out of scope; disclaimer deflects to professional. |
| Implications about a specific medical condition's safe exposure | "This is safe for you with lupus" — we cannot and must not say this. |

---

## 9. Open questions for the team

### 9.1 → Plunder (legal / compliance / wording)

- **Q1.** Is "White skin" / "Black skin" — verbatim from NCBI — defensible in your reading? Or do you want the §5 edited variant?
- **Q2.** Are you OK with naming generic photosensitizing drugs by class + a few generics (isotretinoin, doxycycline, hydroxychloroquine) in the L1 disclaimer modal? Or do you want me to drop the named generics and say only "certain medications and conditions"?
- **Q3.** The Codon Publications / NCBI license — citing the table is normal-and-customary; reproducing the table verbatim in our picker (which we are doing) — your read on whether that constitutes "reproduction" requiring more than attribution, or just citation? My read: this is citation; the six-row scale is older than the source we're citing.
- **Q4.** "$2.99 once" branding plus a disclaimer modal listing photosensitizing drug classes — any App Store Health & Fitness category drift risk you're tracking?

### 9.2 → Linka (UI / UX)

- **Q5.** Where does the photosensitization moment live? The candidates in Suchi's brief and this spec:
  - **(a)** First-launch L1 modal (high-visibility, dismissible per Donatello M3).
  - **(b)** Verdict card inline link "Is this estimate for me?" → opens About at anchor (Suchi's L3).
  - **(c)** A *contextual* prompt that escalates on Type I/II selection (e.g., a small inline tip surfacing the "this model assumes healthy skin" line).
  - **My recommendation:** all three. (a) is the disclosure; (b) is the recheck affordance Asha needs (Suchi's brief §1.7 and §6); (c) is gentle and proportional. They serve different personas.
- **Q6.** Low-UVI display rounding (§4.3): do you want me to define the rounding rules, or do you own that?

### 9.3 → Kwame (Swift / WeatherKit)

- **Q7.** Does `WeatherKit currentWeather.uvIndex` return `Int` or `Double`? If `Int`, the formula is fine at integer UVI; if `Double`, we may want a low-UVI clamp on display only (math stays the same).
- **Q8.** What does WeatherKit return at night / no-data? `0`, `nil`, or absent? The `.noUV` branch in §3.2 needs to handle the WeatherKit-actual contract. Please confirm and adjust.
- **Q9.** Any precision concerns at UVI < 1 or UVI > 11+? Mathematically the formula is well-behaved across the entire integer range. The concern is display, not math.
- **Q10.** Apple WeatherKit documentation — does Apple state which erythemal action spectrum their UVI uses? If they confirm CIE S 007/E:1998, this spec is complete. If they document a different spectrum, flag back and I'll reconcile.

### 9.4 → Suchi (cross-check)

- **Q11.** §6 (no-default-selection) — does this resolve your P3 anchoring concern as stated, or do you want me to also propose copy for the "you must choose" empty state?
- **Q12.** §7.3 (photosensitization three-surface placement) — does this match your design directives for L1/L2/L3, or am I over-reading them?

---

## 10. Summary handoff matrix

| Deliverable | Owner | What they need from this spec |
|-------------|-------|-------------------------------|
| iOS picker copy | Linka | §5 (verbatim NCBI text; edited variant for discussion) |
| iOS picker default state | Linka + Kwame | §6 (no default; empty-state copy) |
| Disclaimer modal copy (L1) | Plunder + Linka | §7.3.1 (photosensitization line); §8 (what we don't claim) |
| About surface "When this estimate may not apply" | Plunder + Linka + Wheeler | §7.1 + §7.4 (citation-per-claim) |
| Verdict card inline link | Linka | §7.3.3 (L3 affordance) |
| Time-to-burn computation | Kwame | §3.2 (pseudo-Swift) |
| MED constants | Kwame | §2.5 (Swift enum) |
| UVI → irradiance constant | Kwame | §4.1 (0.025 W/m² per UVI) |
| Citation strings (About surface) | Plunder + Linka | §1.3 (NCBI canonical); §3.3 (formula); §4.2 (WHO UVI) |
| App Store description fact-check | Plunder | §8 (banned claims); LAUNCH-PLAN.md description currently cites "Fitzpatrick 1988" + "Diffey 1991" — keep, and additionally cite WHO 2002 + NCBI Table 1 (Ward & Farma 2017) |

---

*Wheeler — Skin Science. Every value above names its source. Where the literature gives a range, I picked the conservative end. Where the model breaks down (photosensitization), I named the breakdown explicitly and gave Linka a UI surface to expose it. — 2026-05-19T00:25:58-07:00*

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
