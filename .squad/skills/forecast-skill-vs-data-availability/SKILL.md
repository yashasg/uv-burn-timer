# Skill: Forecast Skill vs. Data Availability — Separation Rule

> A reusable rule for any health-adjacent forecast feature: never let "the vendor serves N days" decide the display tier. Operational skill at N days is a separate question, must be answered independently, and the lower of the two governs how the data is shown.

## When to apply

Any feature where:
- A data vendor (WeatherKit, OpenWeather, NOAA, a sensor SDK, etc.) serves a quantity out to some horizon N.
- The product wants to show that quantity at lead times approaching N.
- The quantity is *forecast* (model output with growing uncertainty), not *measurement*.
- The display will inform user behavior (especially safety-adjacent behavior).

Specifically activated for: weather/UVI forecasts, AQI forecasts, pollen forecasts, lightning probability forecasts, marine/tide outlooks, allergy indices, and similar.

## The rule

1. **Ask two questions, never one.**
   - *Data availability:* "How many days/hours of this quantity does the vendor serve?"
   - *Operational skill:* "At what lead time does peer-reviewed verification show the model still produces actionable predictions?"
2. **Cite the skill answer.** If no published verification exists at the target horizon, *say so* and label the claim `no-good-source`. Do not silently extrapolate vendor availability into trust.
3. **The lower of the two horizons governs display.** If the vendor serves 10 days but verified skill caps at day 5, the display tier downgrades at day 5 — even though the data flows in.
4. **Demote, don't hide.** Past the skill horizon, switch from precise numerals to category bands, trend arrows, or "outlook" framings. Hiding the out-day data forfeits useful trend information; showing it as a precise number over-claims.
5. **Tier the disclaimer to match.** Use three tiers — "Forecast" (high skill), "Outlook" (moderate), "Trend" (low) — and place the tier label on the card itself, not just in About.
6. **Refuse to apply downstream formulas to out-day forecasts** if those formulas themselves have model uncertainty (e.g., time-to-burn, time-to-AQI-threshold, time-to-pollen-exposure). Stacking forecast error onto model error without doubling the hedge is the silent-guess failure mode.

## Why this matters

A vendor's published horizon is an engineering commitment, not a scientific one. The vendor commits to serving the response; it does not commit to a confidence interval. Treating "the API returns it" as evidence that "the value is trustworthy" is the structural error this skill exists to prevent.

The UVI 10-day forecast case (2026-05-20) is the canonical example: WeatherKit `forecastDaily` serves 10 days of daily-max UVI, but peer-reviewed operational skill caps at ~day 5 because cloud-cover forecast skill collapses there and UV transmission is exponentially sensitive to cloud optical depth. The data is real; the precision is not.

## How to execute (checklist)

For any new forecast-driven feature:

- [ ] Identify the vendor horizon (documentation-cited).
- [ ] Identify the published-skill horizon (peer-reviewed verification, official meteorological / agency validation, or labeled `no-good-source`).
- [ ] Set the display-tier breakpoint at the *lower* horizon.
- [ ] Choose a primary scalar that is robust to the dominant forecast error source at that horizon (often a category band, not a numeral).
- [ ] Choose a secondary scalar (the numeral) and *gate it* to the high-skill portion of the horizon.
- [ ] Tier the on-card disclaimer label across the horizon.
- [ ] Prohibit downstream-model formulas from running against out-day forecasts unless the formula's own uncertainty has been independently re-validated for forecast inputs.
- [ ] Cite per the locked citation discipline (author/journal/year for every numerical claim; label `established-science` / `approximation` / `no-good-source`).

## Anti-patterns (do not ship)

- ❌ Showing a precise integer at a lead time where no published verification supports it.
- ❌ Applying a derived-metric formula (e.g., time-to-burn, time-to-irritation) to a forecast value where forecast-error has not been propagated through the formula.
- ❌ Using the vendor's silence on confidence intervals as license to assume tight confidence intervals.
- ❌ "All-or-nothing" — either showing the full horizon as if days 1 and 10 are equivalent, or refusing to show any of it. Tiered display is the right answer.
- ❌ Burying the confidence-decay label in About; it belongs on the card.
- ❌ Confusing **refresh frequency** with **lead time.** Daily (or hourly) refresh of the forecast cache fixes staleness; it does NOT shorten the lead time of a forward-looking cell. The cell at D+5, viewed today, is a +5-lead forecast regardless of when the cache was last pulled. The skill problem lives in the cell, not in the cache age.
- ❌ Allowing user-initiated derived-metric compute past the published-skill horizon just because the surface is opt-in. Opt-in framing carries *part* of the safety load (the user consented to a what-if); it does not substitute for a hard structural cap at the horizon where no verification exists.

## Extension: User-initiated forecast-conditioned compute

Added 2026-05-20 from the work item #7 pushback re-evaluation. Codifies how to handle the "user picks a future (date, time) and gets a derived-metric answer" pattern (e.g., burn-time picker, AQI-exposure picker, pollen-window picker):

1. **Opt-in changes the safety calculus but does not erase forecast error.** Joslyn & Savelli 2010 (*Meteorological Applications* 17:180–195) and adjacent forecast-comprehension literature show that lay users systematically under-estimate uncertainty growth with lead time even when given an explicit forecast label. "I picked it so I trust it" is the cognitive default.
2. **Stack two mitigations, do not substitute:**
   - *Consent mitigation:* the surface is user-initiated (picker, sheet, what-if affordance) — the user is actively asking a counterfactual. Frame the output as an *estimate*, not a precision claim. Carry a copy-level uncertainty hedge inside the sheet.
   - *Structural mitigation:* the picker MUST refuse to compute past the published-skill horizon. The vendor's data availability is not the cap; the published-skill horizon is. (For UVI: D+7 per WHO/WMO operational publication horizon; for other quantities, look up the corresponding agency horizon and cite it.)
3. **Asymmetry check:** if the derived-metric formula has the form `output ∝ 1/input` (convex), input under-forecast yields output over-claim, which is often the safety-bad direction. Specifically check: does the formula bias errors toward harm? If yes, the structural cap should be *tighter* than the symmetric-skill horizon.
4. **Default to safe in defaults:** the picker default value should be "now" (the lowest-lead-time, highest-skill point). Past values should not be selectable. Future values should clamp at the structural cap.
5. **Re-disclosure on the picker surface:** any safety disclaimer that lives on the live surface (photosensitization, medication classes, post-procedure skin) must also appear on the picker — first-open of the sheet per session, or a one-tap "Is this for me?" affordance. The picker is a new safety surface; treat it like one.
6. **Refusal copy beyond the cap is information, not a feature failure.** A graceful refusal ("Forecasts past N days aren't reliable enough to plan around — check back closer to the day") preserves the underlying data on the parent surface (the category band on the 10-day card) while withholding the false-precision derived number.

## Canonical examples to study

- **UVI 10-day forecast (2026-05-20):** the live example. Days 1–5 numeric + band; days 6–10 band only; user-initiated burn-time picker capped at D+7 with photosensitization re-disclosure. See `.squad/decisions/inbox/wheeler-uvi-10day-forecast-validation.md` and `.squad/decisions/inbox/wheeler-uvi-forecast-pushback-response.md`.

## Owners

- **Wheeler:** owns the science side — identifying the skill horizon, citing it, labeling.
- **Plunder:** owns the user-facing wording of the tier labels and hedge copy.
- **Iris:** owns the visual demotion (band-only past breakpoint, tier label styling).
- **Kwame:** owns the structural enforcement (no out-day formula application).
- **Ma-Ti:** owns the tests that lock the tier breakpoint and disclaimer presence.

## Origin

Extracted 2026-05-20T17:27:34.099-07:00 from the UVI 10-day forecast validation (work item #7). Sibling to `.squad/skills/health-adjacent-constant-adoption/` — that skill governs static constants (MED, SPF math); this skill governs time-varying forecast values.
