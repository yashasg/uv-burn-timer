## Summary (Recent Focus — 2026-05-20 to 2026-05-21)

**Current role:** Dermatology & UV photobiology expert; validator of UVI forecast feature (WI-7) and burn-time picker safety gates.

**Recent major decisions:**
1. **UVI forecast validation (Round 1, locked):** 10-day forecast OK pending 6 conditions: integer UVI D1–5 only (WHO band D6–10); daily refresh OK but doesn't shorten lead-time skill; labeled confidence tiers (Forecast/Outlook/Trend); visual demotion D6–10; picker D+7 cap; photosensitization re-disclosure.
2. **UVI forecast pushback response (Round 2, 2026-05-21):** Conceded three items (dropped label tiers, dropped visual decay, picker user-initiated OK with D+7 cap); held three items (integer vs band scalar, D+7 picker cap, photosensitization disclosure). Confirmed Iris's `.caption` footnote satisfies confidence-visibility requirement.
3. **Cross-agent alignment:** Iris audit confirmed per-row opacity fails WCAG 1.4.3; flat treatment is HIG-aligned. Iris specified D+10 picker range (user hasn't decided between D+7 vs D+10 yet). Plunder confirmed L3 chevron pattern satisfies compliance surface requirement.

**Key patterns established:**
- User-initiated forecast-conditioned output (opt-in, with re-disclosure + horizon cap) is structurally different from passive display and carries different safety gates.
- Forecast skill horizon (D+7 = last published-verification point) is non-negotiable for burn-time compute; data horizon (D+10 = WeatherKit native) does not extend skill.
- Flat visual design (no opacity decay) can carry precision signal via scalar choice (integer vs band) at threshold points (day 5), not per-row visual treatment.

**Open items awaiting user decision:**
- Picker range: D+7 (Wheeler, skill-based) vs D+10 (Iris, data-bounded)

---

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

### 2026-05-20T17:27:34.099-07:00 — UVI 10-day forecast (work item #7) scientific validation

- **Verdict:** APPROVE WITH CONDITIONS. The forecast feature is scientifically defensible *only* if the display tier downgrades past the day-5 line. Full write-up: `.squad/decisions/inbox/wheeler-uvi-10day-forecast-validation.md`.
- **Forecast-skill horizon (locked for this app):**
  - Day 1: high skill. NOAA NWS / CPC operational validation: 26 % exact, 65 % within ±1 UVI, 84 % within ±2 UVI. **Established science.**
  - Day 2–3: high → moderate. ECMWF medium-range skill remains operationally useful.
  - Day 4–5: moderate; cloud-cover forecast error becomes the dominant UVI error source. **Established science** (cloud-dominance qualitative); **approximation** for exact skill scores per lead time.
  - Day 6–7: low; "outlook" tier — category band only.
  - Day 8–10: very low; "trend" tier only. **No peer-reviewed operational UVI skill numbers exist at this horizon.** Label as no-good-source for precise integer UVI; defensible only as a categorical trend.
- **Why day 5 is the break:** UV transmission is exponentially sensitive to cloud optical depth; medium-range NWP cloud-cover skill degrades faster than temperature/wind/humidity skill. WMO / WHO operational UVI publishing stops at ~5–7 days for this exact reason. WHO/WMO/UNEP/ICNIRP 2002 *Global Solar UV Index: A Practical Guide* (already in our locked source set) underwrites the category-band approach.
- **WeatherKit horizon (empirical, vendor-documented):** `WeatherService.dailyForecast(for:)` returns up to **10 days** of `DayWeather`, each with daily-max `uvIndex`. `hourlyForecast` covers ~240 hours. Data layer is not the limit; the science is. Apple does not publish per-lead-time UVI skill or CI; do not infer one.
- **Display-science rule for forecast cards (locked recommendation, awaiting team sign-off):**
  - Primary scalar = **peak daily UVI** (WHO 2002 §3 prescribes this for public communication). Show the numeral days 1–5; **demote to category-band-only for days 6–10.**
  - **WHO category band** (0–2 Low / 3–5 Mod / 6–7 High / 8–10 Very High / 11+ Extreme) renders on all 10 days; this scalar is robust to ±1 UVI forecast error and maps cleanly to user behavior.
  - **Reject SED accumulation** for v1 display: unintuitive AND more cloud-sensitive than peak UVI.
  - **Reject time-to-burn on out-days, full stop.** It violates D-2026-05-19-012 (no default Fitz) for users without a selected type, and where a type is selected, doubling forecast error onto MED math without doubling the disclaimer is the silent-guess failure mode Wheeler exists to prevent. Time-to-burn is a *now* number, not a *forecast* number.
- **Hourly card science:** the diurnal shape is solar-geometry-deterministic (cos SZA from lat/lon/date is exact); forecast error lives in the cloud modifier. Display = hourly UVI curve colored by WHO category, with peak hour labeled. **Burn-window overlay** (shaded contiguous hours where unprotected MED < 120 min) is permitted today and optionally tomorrow only, using the locked formula `t = (MED × SPF) / (UVI × 0.025 × 60)` and the existing 2-hour SPF reapply cap.
- **Required hedges (Plunder owns wording; Wheeler owns the science):**
  - Three-tier confidence-decay labels on the card: "Forecast" (D1–3) / "Outlook" (D4–7) / "Trend" (D8–10).
  - Cloud-cover caveat adjacent or in About: actual UV may differ if cloud cover differs from forecast.
  - Medical-planning prohibition that explicitly enumerates the locked photosensitizer drug classes and post-procedure conditions (carries D-2026-05-19-007 forward onto the forecast surface).
  - Structural rule (not a copy hedge): no burn-time renders for non-today.
  - WeatherKit attribution adjacent to the forecast card per D-2026-05-19-003/004.
- **Reusable scientific pattern:** *Forecast skill is not the same as data availability.* A vendor may serve N days of a quantity without certifying skill at N days. Wheeler's standing rule for any future "the vendor serves X days, can we display X days?" question: separate the data-availability question from the operational-skill question, and let the lower of the two govern the display tier.
- **Citations newly added to my bibliography (extension of locked set):** NOAA NWS CPC validation page (day-1 skill); ECMWF cloud-cover medium-range skill technical literature; Bais et al. UV-forecasting verification family; WMO GAW UV monitoring reports. Apple WeatherKit `DayWeather` / `DayWeatherConditions` / `forecastDaily` REST documentation as the vendor anchor for the 10-day horizon claim.

**Cross-agent validation convergence (2026-05-21T00:38:46Z):**
- **Iris's HIG audit adds structural constraints to Wheeler's day-5/6 science line** (iris-uvi-10day-forecast-validation.md): her requirement #2 (horizontal strip must adapt at AX3+ Dynamic Type) pairs with Wheeler's display-science recommendation (demote numeric UVI past day 5, show category band only). Fewer visual elements per cell for days 6–10 naturally helps accessibility at large Dynamic Type. The "Forecast" / "Outlook" / "Trend" label tier becomes the lead semantic indicator instead of numeric UVI values.
- **Suchi's persona re-stratification on the forecast surface** (suchi-uvi-10day-forecast-validation.md §2): on the forecast, Vee (vitiligo/albinism) and Priya (parent) become primary personas, and Greta (gram-counter) drops to low-match. This re-stratification is **independent of the science**, but it reinforces Wheeler's day-5/6 break: the personas who most value the forecast (Vee, Priya, Devon for planning) care about confidence-decay transparency past day 3, which is exactly what Wheeler's "Outlook" tier provides. A persona whose primary JTBD is "quick daily verdict" (Greta) is better served by the time card than by a forecast that has visible confidence degradation.
- **Convergent theme on time card as the higher-utility half:** Suchi rates time card as higher-value than the 10-day card (§5 of her validation); Wheeler's scientific constraints make the hourly card fully approved and the daily card only approved through day 5 with category-band-only for days 6–10. The hourly card is therefore the "lower-risk, higher-information" surface, supporting Suchi's product recommendation.
- **Convergent theme on personalization constraints:** Iris wanted personalized burn windows on every forecast row; Wheeler's constraint limits burn overlays to today and optionally tomorrow. Suchi's user research confirms this is the right trade-off (her must-have #4: "ship time card first or alongside 10-day card"). All three converge independently on the same product shape.

### 2026-05-20T17:43:54.869-07:00 — UVI 10-day forecast pushback response (work item #7 follow-up)

- **What changed:** Yashas pushed back on three of the five conditions in my "APPROVE WITH CONDITIONS" verdict (daily-refresh framing, "Forecast" single label vs my three tiers, selectable date/time burn-time picker, drop visual demotion). I moved on three; held three. Full revised verdict: `.squad/decisions/inbox/wheeler-uvi-forecast-pushback-response.md`.
- **Refresh-frequency vs lead-time distinction (locked):** Daily refresh fixes staleness; it does NOT shorten lead times for forward-looking cells. When a user opens the app on day D and looks at the "D+5" cell, the cell's UVI is a +5-lead forecast regardless of when the cache was last refreshed. Skill problem lives in the cell, not in the cache age. NOAA day-1 numbers (26%/65%/84% within 0/±1/±2 UVI) and ECMWF cloud-cover growth past day 3 are properties of lead time, not refresh frequency. Practical concession: the worst forecasts (D+10) are typically only consumed for far-out planning, so visual demotion of the cell as a stand-alone signal is less load-bearing than I claimed in the prior verdict. The structural signal (integer vs WHO category band at day 5) carries the precision claim instead.
- **Single "Forecast" label is defensible.** Meteorologically, "forecast" is the correct noun for any model-produced future quantity (ECMWF runs forecasts to D+15). Operational publication horizons vary by quantity — WHO/WMO stop publishing UVI at ~5–7 d not because they re-label it past that, but because they don't publish at all. The precision claim should travel via the displayed scalar, not the label tier. Concession granted: drop my "Forecast / Outlook / Trend" tier; use Apple's "Forecast" / "10-Day Forecast" wording.
- **User-initiated burn-time picker science** — the substantive concession. Walk-through I locked in:
  - Formula `t = (MED × SPF) / (UVI × 0.025 × 60)` is dimensionally agnostic about input provenance (forecast vs measured). The locked WHO/Schalka/Diffey citations do not restrict the input class.
  - Sensitivity: `dt/t = −dUVI/UVI`. Convex in UVI, so absolute UVI error matters more at low UVI than at high UVI. **Asymmetric in the safety-bad direction**: UVI under-forecast → t over-forecast → user gets burned. Permanent property of the formula.
  - Worked numbers (Type II, MED 250 J/m²): at peak UVI 8, ±1 UVI ≈ ±10–15% t (comparable to MED intra-band variability — acceptable). At low UVI 3, ±1 UVI ≈ +50% over-claim of safe time in the safety-bad direction. Acceptable for opt-in, with copy hedge.
  - Lead-time tolerance for picker: day 1 ≈ comparable to "now" UVI we already ship; day 5 ≈ ±25–30% in t at peak, ±100% at low UVI; day 7 ≈ edge of WHO/WMO operational publication horizon; day 8–10 ≈ NO published skill, formula input is noise.
  - **Cutoff: day 7.** Picker must structurally refuse to compute burn-time past D+7. Days 8–10 still show WHO category band on the 10-day card (data preserved); the picker just won't translate the band into a fake-precision minute count. This is a delta on Iris's spec (she ranged picker to D+10).
  - **User-initiated opt-in changes the safety calculus but does not erase it.** Joslyn & Savelli 2010 (*Meteorological Applications* 17:180–195) — lay users systematically under-estimate uncertainty growth with lead time even when given a forecast label. Opt-in carries part of the load (consent); structural cap carries the rest (no published-skill basis past D+7).
- **Photosensitization re-disclosure on picker (locked, non-negotiable):** D-2026-05-19-013 extends onto the picker surface. Drug-class enumeration (isotretinoin, tetracyclines, fluoroquinolones, thiazides, sulfonamides, amiodarone, voriconazole, NSAIDs, phenothiazines, methotrexate, St John's Wort; conditions: lupus, porphyrias, XP, post-procedure skin) carries from locked taxonomy. If absent from the picker sheet, picker doesn't ship.
- **What I conceded on the visual side (and why):** Per-row gray/opacity for days 6–10 dropped. Two reasons: (1) Iris's WCAG 1.4.3 objection — `.secondary` at <80% opacity on `.regularMaterial` fails 4.5:1 contrast in light mode; visual demotion as I proposed was an a11y failure to solve a science problem that has a structurally cleaner solution; (2) the integer-vs-band distinction at day 5 is the load-bearing precision signal — adding opacity on top is redundant. **Flat treatment ships.**
- **What I held visually:** integer UVI on days 1–5 only; WHO category band only on days 6–10. NOT visual decoration — different scalar. WHO 2002 §3 prescribes the category band as the lay-comms scalar; the integer is the precision instrument and is gated to where skill supports it.
- **Cross-agent convergence confirmed:** Iris's `.caption .secondary` card-level footnote ("UV accuracy beyond 3–5 days decreases as cloud cover becomes harder to predict") satisfies my §5.1 ("confidence visible on the card, not only in About"). Minor wording tweak noted for Plunder (would prefer "beyond ~5 days" since day 3 is still high-skill per ECMWF / Bais et al., but either passes science review). Iris's terminology audit ratifies my drop of the three-tier label.
- **Reusable scientific pattern (new):** *User-initiated forecast-conditioned compute is morally and safety-different from passive display, but does not erase forecast-error propagation.* Opt-in framing carries part of the safety load (user consents to a what-if); a structural cutoff at the published-skill horizon carries the rest (no honest claim possible past where verification exists). The two mitigations stack, they do not substitute. Captured as an extension to `.squad/skills/forecast-skill-vs-data-availability/SKILL.md`.
- **What I did NOT change:** Hourly card scope (today + optionally tomorrow with burn overlay), WeatherKit attribution (D-2026-05-19-003/004), no SED accumulation, no medical-advice claim, no default Fitzpatrick (D-2026-05-19-012), 2-hour SPF reapply cap, About/L4 update with forecast paragraph and extended refs. Bibliography extended with Joslyn & Savelli 2010.
- **What pushed back is not always wrong:** I held three lines and moved three. The right answer to user pushback is honest line-by-line re-evaluation, not blanket defense. Recording this as a self-correction: my prior "NO time-to-burn on any out-day" was over-broad — it conflated *passive display* (correctly forbidden) with *user-initiated opt-in compute* (defensible with a horizon cap and re-disclosure). The science doesn't change; the surface-coverage rule does.

### 2026-05-21T00:55:49Z — Round 2 cross-agent alignment confirmed

- **From Iris (WCAG audit):** Per-row opacity/gray demotion for days 6–10 fails WCAG 1.4.3 contrast unless opacity ≥80% — but at that threshold the visual signal vanishes anyway. Flat treatment is HIG-consistent (Apple Weather sets no precedent for decay) and accessibility-sound. Confirmed that the integer-vs-band scalar difference at day 5 carries the precision signal without needing visual demotion support.
- **Picker horizon delta:** I held D+7 cap (skill-based; no published-verification past this horizon). Iris spec'd D+10 (WeatherKit's native horizon). This delta remains open for user decision; both have merit (D+7 = conservative, D+10 = data-bounded).
- **Confirmed reusable pattern:** User-initiated forecast-conditioned output differs from passive display, but doesn't erase forecast-error propagation. Opt-in consent + structural horizon cap are stacked mitigations, not substitutes. Extended `.squad/skills/forecast-skill-vs-data-availability/SKILL.md` with this pattern.
- **Orchestration log:** `.squad/orchestration-log/2026-05-21T00:55:49Z-wheeler-1.md`


---

## WI-7 Supersedes — 2026-05-21T01:58:19Z (Scribe consolidation)

**Polar-region copy recommendations (memo §4.2 single-day, §4.3 multi-day) — ARCHIVED, not used in v1.**

User directive 2026-05-21T01:58:19Z (polar-treat-as-nighttime) supersedes Wheeler's polar-night copy variants. Polar night is treated identically to regular nighttime at the UI layer; no new polar-specific copy is needed in v1. Wheeler's underlying science research (polar UV trace mechanisms analyzed, polar-day cumulative-dose flagged for v1.1) remains on record and stands unchanged.

Rationale: Apple treats polar night at the data layer as UVI = 0 (same as midnight). Adding polar-specific UI/copy is unnecessary noise for v1. Feature is deferred to post-ship if a polar-region persona is added.

**Status:** Science research locked. Copy archived. No re-spec needed.
