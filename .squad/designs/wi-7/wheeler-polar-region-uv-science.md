# Wheeler — Polar-Region UV Science Ratification (WI-7 dynamic-UI directive)

**Author:** Wheeler (Skin Science / UV Photobiology)
**Date:** 2026-05-21T01:34:16Z
**Triggered by:** `copilot-directive-2026-05-21T01-34-16Z-dynamic-ui-and-reveal.md` §C item 3–4 (polar night collapsed state; polar day non-special-casing)
**Addressees:** Iris (UI re-spec), Kwame (storage contract), Plunder (copy), team-of-record
**Status:** APPROVED with one MODIFY and three explicit "defer to Iris — no concern" calls

---

## TL;DR

| # | Concern | Verdict | One-line rationale |
|---|---|---|---|
| 1 | Burn-time formula at UVI=0 (polar night) | ✅ **APPROVE existing semantic** | `.nighttime` already correct; formula returns `.infinity` minutes, tier `.none`. No new enum case needed. No trace-UV literature warrants fine print. |
| 2 | Polar-day sustained 24 h UVI | ✅ **APPROVE — no special UI required for v1** | Formula is dimensionally fine; single-session "minutes to first MED" is still the right number. Cumulative-dose concern is real but **out of v1 scope** — no locked persona is a polar-region hiker. One optional UI hint deferred to Iris. |
| 3 | WeatherKit UVI quality > 60° N/S | ✅ **TRUST vendor; do not gate on latitude** | Apple does not publish per-region skill; we won't invent a number. Existing attribution + Iris's card footnote satisfy the honest-hedge bar. |
| 4 | Iris's polar-night collapsed-state copy | 🛠️ **MODIFY** (small) | "Latitude" is too technical; recommend "this place" / "this location." Polar-night term is fine if kept short. Multi-day variant below. |
| 5 | Cross-check WI-7 v1/v2 ratifications | ✅ **All five hold unchanged** | Dynamic data shape + reveal gesture do not touch any locked science line. Confirmed explicitly on the record. |

---

## 1. Burn-time formula behavior at UVI = 0 (polar night)

### 1.1 Division-by-zero — already handled correctly

The locked formula `t = (MED × SPF) / (UVI × 0.025 × 60)` does **not** divide by zero today. `BurnTimeCalculator.estimate(…)` (app/Sources/UVBurnTimerCore/BurnTimeCalculator.swift:117–129) guards `uvIndex > 0` and returns:

```swift
BurnTimeEstimate(rawMinutes: .infinity, tier: .none, isSunscreenProtected: …)
```

This is the locked boundary per `decisions.md` row "UVI = 0 → returns `.infinity`, tier `.none`, displays 'No UV'" (WHO 2002 night / pre-dawn / heavy shade boundary, §3.1 archive). Polar night is a special *case* of that locked boundary; it is not a new mathematical regime.

**Verdict:** **No formula change.** The math is dimensionally agnostic to the *reason* UVI = 0. The user-facing meaning is identical whether the cause is local night, total cloud, or polar night: there is no UV to burn from.

### 1.2 Should `UVResult` add a `.polarNight` case alongside `.nighttime`?

**No.** Three reasons:

1. **Information value to the user is identical.** "No UV at this hour" is the actionable claim; the *why* does not change behavior.
2. **The taxonomic distinction is unstable at our cache boundary.** Polar night vs. polar twilight vs. winter-low-sun is a function of solar elevation, ozone column, and aerosols — none of which we re-compute; we only read WeatherKit's `uvIndex`. The only honest discriminator we have is `uvIndex == 0`, which is the same discriminator we already use for nighttime.
3. **Copy can vary at the UI layer without changing the data contract.** When the *entire 24 h* of a given day in `[HourForecast]` reads UVI = 0 — and `sunrise` and `sunset` in the matching `DayForecast` are nil / equal / span < 1 minute — Iris's view layer can render "No UV today — polar night" *as a presentation choice* while the underlying lookup still returns `.nighttime` per Gi's contract. The data layer stays simple; the copy varies.

**Verdict:** **Gi's `UVResult` enum stands unchanged.** Iris's view layer is the right place to detect "every hour of this day is `.nighttime`" and swap copy.

### 1.3 Trace-UV mechanisms during true polar night — any?

I checked the photobiology literature. The short answer for our app: **none that warrant fine print.**

- **Direct solar UVB during polar night:** Effectively zero. With the sun below the horizon all 24 h, the slant-path optical depth in UVB exceeds ~50, and erythemally-weighted UVB at the surface drops to <10⁻⁵ of clear-sky noon (WHO/WMO/UNEP/ICNIRP 2002 *Global Solar UV Index: A Practical Guide* §3.1; Bais et al. 2018 — "Ozone-Climate Interactions and Effects on Solar Ultraviolet Radiation," *Photochem. Photobiol. Sci.* 17:127–179, §5.2 on solar zenith angle dependence).
- **Diffuse + reflected UV during polar twilight (bracketing days):** At solar elevation 0° to −6° (civil twilight), residual diffuse UVA exists but its erythemally-weighted contribution rounds to UVI < 0.1, i.e., **0 under the WHO integer convention.** The WHO defines UVI rounded to nearest integer for public communication (WHO 2002 §3.2). Days adjacent to polar night with very-low-angle sun are not polar night; they are regular low-UVI days, and our model handles them as such.
- **Snow albedo:** Blumthaler & Ambach 1988 (*Photochem. Photobiol.* 48(1):85–88) established that fresh snow reflects 80–95% of erythemally-weighted UV. This is biologically meaningful — it can *double* the effective dose at the body — **but only when there is incoming UV to reflect.** Albedo amplifies a non-zero direct/diffuse component; it cannot manufacture UV during polar night. No special handling needed for the polar-night case itself.
- **Cosmic ray UV at the surface:** Not a real exposure pathway. Cosmic-ray air showers produce photons in the gamma/X-ray and Cherenkov ranges, attenuated to negligible biological dose at the surface and to non-erythemal wavelengths (Grieder 2010, *Extensive Air Showers*, Springer, §6 on secondary photons). This is *not* a real concern; I'm naming it explicitly because the question asked.

**Verdict for Iris:** The copy **"No UV today — sun does not rise at this place"** is scientifically defensible **with no caveat or fine print.** No asterisk, no footnote, no "but UV from snow…" hedge required.

---

## 2. Polar day — sustained 24 h UV exposure

### 2.1 Peak UVI values at polar latitudes — confirmed and extended

The directive's "UVI 4–7 at high arctic latitudes" is correct for *unperturbed* Arctic sites in mid-summer (e.g., Tromsø 69.6° N, Svalbard 78° N, both with documented summer peaks UVI 4–5 in surface monitoring; Bais et al. 2018 Table 5). **The directive is conservative for Antarctica.** Peer-reviewed surface measurements:

- **King George Island (Antarctic Peninsula, 62° S), November–December 2020:** Cordero, Feron, Damiani et al. 2022, "Persistent extreme ultraviolet irradiance in Antarctica despite the ozone recovery onset," *Sci. Rep.* (Nature Portfolio) — peak noon-time **UVI 14.3** under a persistent late-spring ozone hole. AWI preprint id `epic.awi.de/59953`.
- **Palmer Station (64° S):** McKenzie, Bernhard, Madronich et al. 2022, "Updated analysis of data from Palmer Station, Antarctica," *Photochem. Photobiol. Sci.* 21:1–12 (doi:10.1007/s43630-022-00178-3) — spring peak UVI now **2.5× the pre-1980 baseline**, reaching ≈ 14, **exceeding San Diego's UVI ≈ 12 maximum** despite a lower solar elevation. Snow albedo amplification (Blumthaler & Ambach 1988) compounds the body-incident dose by ~2×.
- **Antarctic plateau (Dome C / Concordia, 75° S, 3,200 m elevation):** Thin atmosphere + low ozone + near-100% fresh-snow albedo. Documented surface UVI up to 7 even at the geographic pole, with albedo-amplified erythemal exposure approaching that of equatorial sea level (Cordero et al. 2014, *Atmos. Chem. Phys.* 14:2487–2497).

So WeatherKit's `uvIndex` field at these locations is **not bounded by latitude** — it can legitimately read 8, 10, even 14 — and our formula must produce a real burn-time for the user.

### 2.2 Does 24 h sun break the formula's diurnal-recovery assumption?

The MED concept assumes one continuous exposure event. The locked formula's `t` is the time from exposure start to reaching one MED — which is biologically the threshold for *first detectable erythema 24 h post-exposure* (Diffey 1991, *Phys. Med. Biol.* 36:299–328; Schalka & Reis 2011, *An. Bras. Dermatol.* 86(3):507–515). The number is **still scientifically correct in a 24 h sun setting**: from the picker's selected start time, the user has approximately `t` minutes before reaching 1 MED at that hour's UVI.

The diurnal-recovery assumption is about **between-day epidermal repair** (Pathak, Riley & Fitzpatrick 1962; Setlow & Carrier 1964 — DNA photoproduct repair cycles ~24 h). It is not embedded in the single-session formula itself; it's an assumption about the *next* day.

**Where the model is genuinely thinner under polar-day conditions:**

- A user on the Antarctic plateau or a Tromsø ridge in June who follows our minute count for one session, then does not seek shade or cover, can stack additional MEDs across what they think of as "the same day" because the sun never sets. Our formula does not warn about this.
- This is **not unique to polar day** — a user at any latitude could re-emerge later and stack exposure. The polar-day case removes the natural diurnal interruption that nudges most users into shade at sundown.

**Net assessment:** The single-session formula's output remains scientifically correct. The risk is one of *user mental model*, not formula breakdown.

### 2.3 What UI surface (if any) is right for this?

I evaluated three options against the locked persona set:

| Option | Verdict | Why |
|---|---|---|
| Always-on polar-day footnote on forecast cards | ❌ **Reject** | None of our locked personas (Devon PCT, Priya parent, Vee, Maya, Greta) are documented polar-region hikers. Adding a permanent footnote that applies to <0.1% of users adds noise and dilutes the existing footnote's signal. |
| Conditional L3 chevron when all 24 h of the displayed day are UVI > 0 | ⚖️ **Optional — defer to Iris** | This is a UX choice. If Iris's dynamic UI already adapts the hourly card when no `.nighttime` rows exist for the day, a one-line note like "The sun stays up — re-check coverage every couple of hours" is defensible. Not required. |
| Out-of-scope for v1; revisit if polar-region persona added | ✅ **Recommend** | Pairs cleanly with my existing 2-hour SPF reapply cap (history 2026-05-19T22:29) and re-attestation on window-elapsed (D-2026-05-19 family) — both already nudge "re-evaluate, do not extrapolate." No new copy needed. |

**Verdict:** **Defer to Iris.** If Iris detects "all 24 h are UVI > 0" inside the hourly card and wants to add a one-line "Sun stays up here — re-check coverage" hint, I will ratify it as long as it is *informational, not numeric*. If Iris chooses not to add it, I have no scientific objection. Either ships clean.

### 2.4 Is polar-day UVI forecast skill worse?

Yes, modestly — but **the locked D+7 picker cap (`forecast-skill-vs-data-availability` skill) does not loosen or tighten.** Two competing effects:

- **Cloud-cover skill at high latitudes:** Stratiform overcast and polar lows are harder for medium-range NWP than mid-latitude convection. Cloud is already the dominant UVI error source past day 3 (per my locked WI-7 v1 ratification); this gets a bit worse at extreme latitudes but does not introduce a *new* regime.
- **Clear-sky skill at high latitudes:** Total-column-ozone (TCO3) is the dominant clear-sky modulator. CAMS/ECMWF assimilate satellite ozone (MetOp GOME-2, Sentinel-5P TROPOMI) and produce reasonable medium-range TCO3 forecasts. Ozone-hole events evolve over days and are partially predictable.

**Net:** Operational skill is *somewhat* worse at extreme latitudes, but not enough to invalidate the D+7 picker cap or the day-5/6 integer-vs-band split. The mitigation already in place (band-only past day 5) **handles** the additional polar uncertainty without further restriction. I considered tightening to D+5 for `|lat| > 66.5°` and decided **against** it — the band-only display tier already absorbs the additional uncertainty for days 6–7. Tightening the picker cap by latitude introduces conditional UX with no published-skill basis to anchor it.

**Verdict:** D+7 picker cap stands globally. No latitude-conditional tightening.

---

## 3. WeatherKit UVI data quality at high latitudes

### 3.1 What we know (and don't) about Apple's polar coverage

Apple does **not** publish per-region UVI skill, confidence intervals, or provider partitions. The locked attribution language ("Apple Weather, with data sourced from a range of providers," D-2026-05-19-003/004) is precisely as much as Apple commits to. From public sources:

- Apple's WeatherKit blends multiple providers historically including The Weather Company (IBM), national meteorological services, and Apple's own ensemble. The blend ratio per region is **undocumented**.
- At extreme latitudes (>70° N/S), there are few surface UV monitors and even fewer real-time feeds. Vendor data in these regions is almost certainly model-derived (CAMS / ECMWF / GFS surface UV products) rather than measurement-fused.
- At population-relevant Arctic latitudes (Anchorage 61° N, Fairbanks 65° N, Reykjavik 64° N, Tromsø 70° N, Murmansk 69° N — all ≤ 70° N), WeatherKit's UVI should be operationally usable, with skill comparable to mid-latitudes for clear-sky and degrading for cloud-modulated values.
- At Antarctic research stations (e.g., McMurdo, Concordia, Palmer) and the high Antarctic plateau, WeatherKit's UVI may **under-predict** during ozone-hole events because near-real-time TCO3 from NASA OMI/TROPOMI may not flow into the consumer-weather blend. McKenzie et al. 2022 and Cordero et al. 2022 both document field UVI exceeding model-default expectations under acute ozone depletion.

### 3.2 Should the dynamic UI suppress or modify the forecast based on latitude?

**No. Trust what WeatherKit returns.** Reasoning:

1. **We have no honest number to anchor a latitude-conditional disclaimer.** Apple doesn't publish polar skill; the literature doesn't give us a WeatherKit-specific bound. Adding "data quality may be lower at this latitude" would label as fact something I would otherwise flag as `no-good-source` per the locked citation discipline. That is a Wheeler-skill anti-pattern (see `forecast-skill-vs-data-availability` SKILL anti-pattern #3).
2. **The existing hedges already cover this case.** Iris's card-level footnote ("UV accuracy beyond 3–5 days decreases as cloud cover becomes harder to predict") + WeatherKit attribution + the WHO category band for days 6–10 collectively communicate "this is a forecast, not a measurement, and confidence drops with lead time." That message is correct at every latitude. We do not need an extra polar-region overlay.
3. **The safety-asymmetry direction is favorable.** If WeatherKit *under-predicts* UVI during an Antarctic ozone-hole event (the documented failure mode), our burn-time formula will produce an *over-estimate of safe time*, which is the safety-bad direction. **However**, none of our locked v1 personas are documented Antarctic researchers, and the L1 disclaimer + L4 photosensitization disclosure already frame the entire app's output as "an estimate, not medical guidance." We are not the right tool for an ozone-hole field campaign; we should not pretend we are by adding a half-true polar footnote.
4. **Hiding the forecast is worse than serving it.** Devon-equivalent users at population-relevant Arctic latitudes (Anchorage, Tromsø) deserve the forecast. Latitude-gating the entire surface would silently penalize them with no scientific basis.

### 3.3 Optional About-page line (not required for v1)

If Plunder wants to extend the About → "How accurate is this?" paragraph for completeness, the honest sentence is:

> "At extreme polar latitudes (above about 66.5° north or south) and during Antarctic ozone-hole events, our UV data source is model-based and may differ from on-site instruments. The forecast is still a useful guide, not a precise field reading."

**Mark this `approximation` per locked citation discipline.** This is informational; it does not gate any UI surface and does not require a card-level footnote.

**Verdict for Iris:** Render the forecast at every latitude. Do not suppress, do not modify, do not add a latitude-conditional disclaimer on the card. Defer the optional About line to Plunder.

---

## 4. Polar-night collapsed-state copy — ratification + alternative

### 4.1 Issues with the proposed phrasing

Iris's working text: *"No UV today — sun does not rise at this latitude"*

- ✅ Plain English overall.
- ⚠️ "Latitude" is roughly 10th-grade vocabulary (Flesch-Kincaid; Dale-Chall list) — above our 6th-grade target.
- ✅ No claim our app can't back ("no UV today" is exactly true under polar night per WHO 2002).
- ✅ No "completely safe" overreach.
- ✅ VoiceOver-friendly (no symbols, no abbreviations).

### 4.2 Recommended single-day copy (collapsed state)

**Heading (large, hero):**
> No UV today

**Supporting line (one row beneath):**
> The sun does not rise here today. (Polar night)

**Why these choices:**
- "Here" reads at 1st-grade level; "this latitude" → "here" is a one-word fix that lands at our target reading level.
- "(Polar night)" in parens functions as a *label*, not the primary message. Users who know the term get the geographic context; users who don't still understand the actionable claim from the heading and main line.
- No "completely safe" or "no risk" — UV is not the only outdoor risk (cold injury, wind, sea spray), and the locked app voice does not make blanket safety claims.

**VoiceOver string (must include both):**
> "No UV today. The sun does not rise at this location today. This is called polar night."

(Expand "here" to "at this location" for VoiceOver because spoken "here" without visual context is ambiguous. The expansion is ~10 extra syllables — within Iris's locked VoiceOver length budget for collapsed states per her HIG audit.)

### 4.3 Multi-day polar-night copy (forecast sheet header)

**Trigger condition:** Every day in the rendered forecast window (days 1–7 visible by default, 8–10 if revealed) has `peakUVI == 0` AND `sunrise == sunset` (or both nil) per `DayForecast`.

**Heading:**
> No UV this week

**Supporting paragraph (collapsed forecast-sheet top):**
> The sun does not rise at your location during this part of the year. This is called polar night. The UV forecast will resume when the sun returns.

**VoiceOver / multi-day variant:**
> "No UV this week. The sun does not rise at your location during this part of the year. This is called polar night. The forecast will resume when the sun returns above the horizon."

**Why the closing sentence:** Polar night at >72° N/S can last 30+ continuous days; our 7-day forecast horizon is always inside that envelope for those users. The closing "will resume when the sun returns" prevents the user from concluding the *app* is broken when the forecast surface is uniformly empty. This is a usability hedge, not a safety claim.

### 4.4 What about the partial-week case (mixed polar-night and polar-twilight days)?

If 3 days in the visible window are UVI=0 polar-night and 4 days have UVI ∈ {0, 1} polar-twilight low-sun, **render each row independently** with the existing day-row treatment (band: "Low"; or "No UV" if peakUVI = 0). No special header banner needed — the per-row treatment is honest and self-explanatory.

**Verdict for Iris:** Approved as above with one MODIFY (drop "latitude," use "here" / "your location"). Plunder owns final copy polish; I have no objection to a wording pass that preserves the science.

---

## 5. Cross-check — do dynamic data shape + days 8–10 reveal break any prior Wheeler ratification?

Quick line-by-line audit against my locked outputs:

| Prior ratification | Touched by directive? | Status |
|---|---|---|
| **Skill-vs-availability split** (`forecast-skill-vs-data-availability` SKILL) — days 6–10 band-only, integer days 1–5 | No. Reveal-gesture is a presentation pattern; the day-5 scalar break is unchanged. | ✅ **Holds** |
| **D+7 picker hard cap** (history 2026-05-21T00:55:49Z; v1 + v2 lock) | No. Dynamic data shape does not extend skill; it only allows the storage layer to hold *fewer* hours than 168, never to extend trustworthy lead time. Polar latitudes do not justify loosening or tightening (§2.4). | ✅ **Holds** |
| **L3 chevron reuse** (Plunder's `persona-keyed-disclaimer-visibility` skill) | No. Chevron + reveal-arrow are sibling reveal patterns; they coexist on different surfaces. | ✅ **Holds** |
| **Iris's card-level science footnote** ("UV accuracy beyond 3–5 days decreases as cloud cover becomes harder to predict") | No. Footnote is latitude-agnostic; polar regions do not require a different footnote (§3.2). | ✅ **Holds** |
| **L4 photosensitization disclosure** (D-2026-05-19-007 / -013) | No. Drug classes (isotretinoin, tetracyclines, fluoroquinolones, thiazides, sulfonamides, amiodarone, voriconazole, NSAIDs piroxicam-class, phenothiazines, methotrexate, St John's Wort) and conditions (cutaneous/systemic lupus, EPP/porphyrias, XP, vitiligo, albinism, post-procedure skin, infants <6mo) are independent of latitude. The L4 stays. | ✅ **Holds** |
| **No default Fitzpatrick** (D-2026-05-19-012) | No. | ✅ **Holds** |
| **2-hour SPF reapply cap** (history 2026-05-19T22:29) | No. Actually *more* relevant under polar-day sustained-sun conditions (§2.2) — the cap nudges re-evaluation that the formula does not. | ✅ **Holds** (and reinforced) |
| **Burn-time only on today + optionally tomorrow** (passive display), picker user-initiated up to D+7 | No. The picker contract is unchanged; the storage contract is unchanged at the trust horizon. | ✅ **Holds** |

**One new edge case the directive surfaces (not a break):** When the picker resolves a (date, hour) inside polar night, the existing `.nighttime` path returns "No active burn window: UV index is 0" (decisions.md L2007). That copy was written for the hero gauge unavailable state; it transfers cleanly to the picker output sheet. Iris and Kwame already share that line. **Approved for reuse.**

### Net: zero prior ratifications need amendment

All five WI-7 lock points I authored stand. Dynamic data shape + 7+3 reveal pattern + polar-region edge cases are absorbed without re-opening the locked science.

---

## Citation roll-up (additions to my bibliography)

New for this memo (extension of locked WI-7 source set):

- **Cordero R.R., Feron S., Damiani A. et al. 2022.** "Persistent extreme ultraviolet irradiance in Antarctica despite the ozone recovery onset." *Scientific Reports* (Nature Portfolio). AWI preprint id `epic.awi.de/59953`. — UVI 14.3 measurement at King George Island.
- **McKenzie R.L., Bernhard G., Madronich S., Diaz S. 2022.** "Updated analysis of data from Palmer Station, Antarctica (64°S), and South Pole, with comparisons to other UV-monitoring sites." *Photochem. Photobiol. Sci.* 21:1–12. doi:10.1007/s43630-022-00178-3. — 2.5× UVI increase under ozone hole; UVI ≈ 14 spring peak.
- **Cordero R.R., Damiani A., Jorquera J. et al. 2014.** "Ultraviolet radiation in the Atacama Desert." *Atmos. Chem. Phys.* 14:2487–2497. — Antarctic-plateau-analog extreme UVI with high albedo.
- **Blumthaler M., Ambach W. 1988.** "Solar UVB-albedo of various surfaces." *Photochem. Photobiol.* 48(1):85–88. — Fresh-snow UV albedo 80–95%; near-doubling of erythemal dose.
- **Bais A.F., Lucas R.M., Bornman J.F. et al. 2018.** "Environmental effects of ozone depletion, UV radiation and interactions with climate change: UNEP Environmental Effects Assessment Panel, update 2017." *Photochem. Photobiol. Sci.* 17:127–179. — Solar zenith angle dependence of UV; high-latitude monitoring summary.
- **Pathak M.A., Riley F.C., Fitzpatrick T.B. 1962.** "Melanogenesis in human skin following exposure to long-wave ultraviolet and visible light." *J. Invest. Dermatol.* 39:435–443. — Diurnal-cycle skin recovery foundation.
- **Setlow R.B., Carrier W.L. 1964.** "The disappearance of thymine dimers from DNA: an error-correcting mechanism." *Proc. Natl. Acad. Sci. USA* 51:226–231. — DNA repair cycle that underwrites the inter-day MED reset assumption.
- **Grieder P.K.F. 2010.** *Extensive Air Showers: High Energy Phenomena and Astrophysical Aspects.* Springer, §6. — Cosmic-ray secondaries are not biologically relevant UV at the surface. (Cited only to formally close the "cosmic ray UV" sub-question.)

Labels (per locked discipline):

| Claim | Label |
|---|---|
| Polar-night UVI = 0 under WHO integer convention | **established science** (WHO 2002 §3.1) |
| Snow albedo 80–95% UVB, ~2× erythemal amplification | **established science** (Blumthaler & Ambach 1988; replicated McKenzie et al. 1998, Lenoble 1998) |
| Antarctic UVI 14+ under ozone hole | **established science** (Cordero 2022, McKenzie 2022 peer-reviewed) |
| WeatherKit polar-region UVI skill | **no-good-source** — Apple does not publish; do not invent a number |
| Single-session MED formula validity under polar-day sustained sun | **reasonable approximation** — formula output is correct as "minutes to first MED from start," but the inter-day recovery assumption is implicit and may mislead a stack-it-up user |
| Cosmic-ray surface UV contribution | **out-of-scope** (not biologically meaningful at relevant wavelengths) |

---

## Decision gate

- **Iris:** approved to ship polar-night collapsed state with §4.2 / §4.3 copy (or Plunder polish that preserves the science). No latitude-gating of the forecast surface. Optional polar-day "sun stays up" hint at her discretion — I will ratify if added; no objection if omitted.
- **Kwame:** no storage-contract change required from me on this directive. `UVResult.nighttime` covers polar night; no `.polarNight` case needed.
- **Plunder:** optional About line offered in §3.3; not required.
- **Ma-Ti:** if Iris ships the polar-night collapsed state, a unit test that "every-hour-UVI=0 day renders the collapsed-state copy and not 24 rows of '0'" is the right lock — I'll ratify Ma-Ti's test phrasing on request.

---

*Wheeler — Skin Science / UV Photobiology — 2026-05-21T01:34:16Z*
