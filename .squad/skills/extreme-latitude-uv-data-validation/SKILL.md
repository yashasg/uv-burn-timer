---
name: "extreme-latitude-uv-data-validation"
description: "How to handle a health-adjacent forecast vendor's data at sparse-validation regions (polar, high-altitude, remote ocean) where surface monitors and skill verification are thin or absent. Sibling rule to forecast-skill-vs-data-availability — that skill handles temporal uncertainty (lead time), this one handles spatial uncertainty (sparse-validation regions)."
domain: "photobiology, forecast-data-quality, citation-discipline"
confidence: "high"
source: "earned — 2026-05-21 polar-region UV science ratification (WI-7 dynamic-UI directive)"
---

## Context

Apply this skill whenever:

- A health-adjacent forecast feature (UVI, AQI, pollen, lightning, marine UV, snow-albedo dose, etc.) is served by a consumer-weather vendor (Apple WeatherKit, Google Weather, OpenWeather, AccuWeather, etc.).
- The vendor publishes a single global API surface but the validation network underwriting that data is *spatially sparse* — fewer ground monitors, fewer published skill studies, fewer assimilated near-real-time observations in some regions.
- A team-internal voice asks "should we hide / modify / disclaim the forecast at those sparse regions?"

Canonical regions for this skill: above ~66.5° N/S (Arctic / Antarctic circles), high-altitude plateaus, remote oceans, polar plateaus, deep desert, conflict-zone or sanctioned regions where met agencies do not feed the consumer blend.

## The rule

1. **Two-question test before any spatial conditioning of the UI.**
   - *Vendor data-quality signal:* Does the vendor publish a per-region skill score, confidence interval, or known-limitation note that we can cite by name?
   - *Independent literature:* Is there a peer-reviewed result that bounds the vendor's likely error in that region (e.g., a field campaign comparing the model the vendor uses against surface monitors)?
   - **If both answers are "no," we have no honest number to anchor a region-conditional disclaimer.**

2. **`no-good-source` is a label, not a license.** If neither the vendor nor literature gives us a number, do *not* invent one to feel responsible. Per the locked citation discipline, `no-good-source` means we say it explicitly or we don't say it at all — we never paper over the gap.

3. **Default behavior at sparse-validation regions is: SHIP the data with the standard hedges.** Vendor attribution + general-purpose forecast caveat + tier-appropriate display scalar (band vs integer per `forecast-skill-vs-data-availability`) together carry the honest hedge at *every* latitude. They do not need to be amplified just because the region is unfamiliar — that would be performative caution, not science.

4. **Region-suppression / latitude-gating is a heavier intervention than a footnote.** Hiding the forecast at a region where the vendor returns *any* data silently penalizes users who live there with no scientific basis. Do not gate visibility on latitude unless (a) we have a cited bound that the vendor's data is *unsafe to display* in that region, or (b) we have evidence the vendor is returning structurally invalid values (NaN, zeros where measurements exceed 10, etc.).

5. **Safety-asymmetry check is non-optional.** If the downstream formula has an asymmetric error direction (UVI under-prediction → time-to-burn over-estimate → user gets burned — the documented Antarctic-ozone-hole failure mode), audit whether the vendor's known limitations bias errors in the safety-bad direction. If yes, the response is *honest framing of the limitation*, not a confident region-disclaimer; the formula's already-locked `output as estimate` framing carries the load.

6. **About-page transparency is the right surface, not the live card.** A one-sentence, labeled-`approximation` note in About / Methodology — "at extreme polar latitudes our UV data source is model-based and may differ from on-site instruments" — provides traceability for users who go looking. It does not pollute the card-level reading flow for the 99%+ of users for whom it does not apply.

7. **Persona-fit gate.** Before adding any region-conditional UI surface, check the locked persona set. If none of the documented personas are users of the region in question, region-conditional UX is feature-bloat. Defer to a future feature added with its own persona, its own decision file, and its own About row.

## Why this matters

A vendor's silence on per-region quality is not evidence of *good* quality; it is evidence of *unmeasured* quality. The structural failure modes this skill prevents:

- **Over-claim by silence:** treating "the API returned a number" as evidence that the number is locally validated.
- **Over-disclaim by invention:** adding "data may be unreliable at this latitude" as a UI element when we have no number to support it — this lands as Wheeler asserting a claim that fails the citation-discipline `no-good-source` test.
- **Performative suppression:** hiding the surface to look responsible, while actually penalizing users in sparse regions who have no better source than the consumer app they already opened.

The honest middle path is **ship with existing hedges, hold an About-page note in reserve for completeness, and require persona-fit evidence before adding region-conditional UX.**

## How to execute (checklist)

For any forecast-driven feature that may be requested at sparse-validation regions:

- [ ] Identify the documented vendor scope (which regions are explicitly covered, which are implicit-via-model-fallback, which are documented gaps).
- [ ] Search for peer-reviewed comparisons of the underlying model (CAMS / ECMWF / GFS / regional NWP) against surface monitors in the sparse region. Label findings `established-science` / `approximation` / `no-good-source` per locked discipline.
- [ ] Check the downstream formula for safety-asymmetric error propagation. Document the direction.
- [ ] Audit the locked persona set. Is the sparse region a documented persona need?
- [ ] If no persona match: do not add region-conditional UX. Defer to future feature.
- [ ] If persona match exists: propose an About-page line + (if the safety asymmetry is severe and cited) a card-level footnote with the literature-anchored bound.
- [ ] Never propose latitude-gated suppression of the forecast surface without an explicit "data is unsafe to display" finding.

## Anti-patterns (do not ship)

- ❌ "Just to be safe" latitude-conditional disclaimers with no cited bound — this fails the citation-discipline `no-good-source` test.
- ❌ Suppressing the forecast above 60° N/S because "polar regions are weird" — silently penalizes Anchorage, Reykjavik, Tromsø users who have a legitimate forecast need.
- ❌ Asserting a confidence interval the vendor does not publish (e.g., "±2 UVI at this latitude") — fabrication.
- ❌ Adding a polar-only footnote to *every* forecast row globally so that polar users see the same hedge as everyone else "for consistency" — adds noise for the 99%+ for whom it does not apply.
- ❌ Conflating *vendor data quality* with *operational forecast skill horizon* — they are independent. The latter is governed by `forecast-skill-vs-data-availability`; this skill handles only the former.
- ❌ Letting a region's lack of published validation drive a *formula* change. The formula is dimensionally agnostic to input provenance; it processes whatever UVI the vendor returns. The hedge belongs in framing, not in math.

## Canonical example

**WI-7 dynamic-UI directive (2026-05-21):** Yashas asked whether the burn-timer's UI should adapt for polar regions where the sun never sets or never rises. Concern 3 of `wheeler-polar-region-uv-science.md` asked specifically about WeatherKit data quality at >60° N/S. Net answer: trust the vendor, do not gate by latitude, hold an optional About-page line in reserve. The existing card footnote + WeatherKit attribution + band-only-past-day-5 treatment carry the honest hedge at every latitude. The single documented safety-asymmetric failure (Antarctic ozone-hole under-prediction → over-estimate of safe time, McKenzie 2022 / Cordero 2022) does not warrant a region-conditional UI surface because no v1 persona is an Antarctic researcher; that use case ships with its own future decision file.

## Owners

- **Wheeler:** owns the science side — vendor scope audit, literature search, safety-asymmetry direction, `no-good-source` labeling.
- **Plunder:** owns wording of any About-page line if one is required.
- **Iris:** owns the visual decision (almost always: nothing changes at the card level).
- **Kwame:** owns confirming the data layer can serve sparse regions without crashing (NaN guards, empty-array guards).
- **Suchi:** owns the persona-fit gate — does any locked persona need this region?

## Sibling skills

- **`forecast-skill-vs-data-availability`** — handles *temporal* uncertainty (lead time → vendor-served days vs published-skill horizon). Same family of citation-discipline reasoning, different uncertainty axis.
- **`health-adjacent-constant-adoption`** — governs static constants (MED, SPF math, citation-link discipline). This skill is the dynamic counterpart for region-conditional uncertainty.

## Origin

Extracted 2026-05-21T01:34:16Z from `.squad/decisions/inbox/wheeler-polar-region-uv-science.md` Concern 3. Earned during the dynamic-UI directive that asked whether the burn-timer should suppress / modify forecasts based on latitude. The reasoning generalizes to any consumer-weather forecast surface where validation networks are spatially uneven.
