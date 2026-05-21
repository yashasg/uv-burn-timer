# WeatherKit Polar Latitude API Research
**Author:** Kwame (iOS Developer)  
**Date:** 2026-05-21T01:52:54Z  
**Requested by:** yashasg (via Copilot directive 2026-05-21T01:52:54Z)  
**Status:** Research complete — trigger spec locked  

---

## Executive Summary

Apple's documentation is clear and sufficient. The canonical polar-night trigger is `dayForecast.sun.solarNoon == nil`. This is explicitly documented to be `nil` only when the sun never rises above the horizon — which is exactly polar night. Using `sunrise == nil` alone (Iris's v3 spec §3.3 primary trigger) is ambiguous: Apple documents and WWDC22 session 10035 confirm it fires for **both** polar night and polar day. The 18-hour consecutive-zero fallback in §3.3 is dropped per the directive. The storage layer and picker are unaffected.

**One structural correction required across team docs:** the type is `SunEvents`, not `Sun`. `DayWeather.sun` is `var sun: SunEvents` — a non-optional struct. The optional Date fields live inside that struct. Access path `dayWeather.sun.sunrise` is correct; the intermediate type name matters for Swift code.

---

## Question 1: `DayWeather.sun.sunrise` Behavior at Polar Latitudes

### 1.1 Actual Swift API type

The task prompt refers to `Sun.sunrise`. **Correction:** there is no `Sun` type in WeatherKit. The correct type is `SunEvents`.

- `DayWeather.sun` is declared as `var sun: SunEvents` — a **non-optional** `SunEvents` struct. You always get a `SunEvents` value; it is the inner Date fields that are optional.
- Source: [DayWeather.sun — Apple Developer Documentation](https://docs.developer.apple.com/documentation/WeatherKit/DayWeather/sun)

### 1.2 `SunEvents.sunrise: Date?`

**Apple-documented:**

> "This property is optional because it's possible for the sun to not rise on a given day, at extreme latitudes. That calendar noon is used as a reference point due to variations in frequency of solar events at extreme latitudes."

The optionality is **intentional and explicitly motivated by the polar case**.

Source: [SunEvents.sunrise — Apple Developer Documentation](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/sunrise)

### 1.3 `SunEvents.sunset: Date?`

**Apple-documented:**

> "This property is optional because it's possible for the sun to not set on a given day, at extreme latitudes."

Source: [SunEvents.sunset — Apple Developer Documentation](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/sunset)

### 1.4 `SunEvents.solarNoon: Date?`

**Apple-documented:**

> "It may or may not be above the horizon at this time due to variations of solar events at extreme latitudes. If the highest point isn't above the horizon, this property is `nil`."

**This is the canonical polar-night signal.** `solarNoon == nil` means the sun never reaches above the horizon — true polar night by definition. This is nil **only** during polar night, not polar day.

Source: [SunEvents.solarNoon — Apple Developer Documentation](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/solarNoon)

### 1.5 `SunEvents.solarMidnight: Date?`

**Apple-documented:**

> "It may or may not be above the horizon at this time due to variations of solar events at extreme latitudes. If the lowest point is not below the horizon, this property is `nil`."

**This is the canonical polar-day signal.** `solarMidnight == nil` means the sun never dips below the horizon — true midnight sun / polar day. This is nil **only** during polar day, not polar night.

Source: [SunEvents.solarMidnight — Apple Developer Documentation](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/solarMidnight)

### 1.6 Dawn/dusk fields

All six twilight fields (`astronomicalDawn`, `astronomicalDusk`, `civilDawn`, `civilDusk`, `nauticalDawn`, `nauticalDusk`) are also `Date?` with identical optionality rationale: "optional because it's possible for the sun to not rise on a given day, at extreme latitudes." These fire nil in a wider range of conditions (even at latitudes below the Arctic Circle, astronomical dawn/dusk can be absent in deep winter).

### 1.7 Polar night vs. polar day disambiguation — the critical insight

`sunrise == nil` fires for **both** polar night and polar day.

- **Polar night** (sun never above horizon): `sunrise == nil`, `sunset == nil`, `solarNoon == nil`, `solarMidnight != nil`
- **Polar day** (sun never below horizon): `sunrise == nil`, `sunset == nil`, `solarNoon != nil`, `solarMidnight == nil`
- **Normal day**: `sunrise != nil`, `sunset != nil`, `solarNoon != nil`, `solarMidnight != nil`

WWDC22 session 10035 ("Tap into Weather Data with WeatherKit") confirms: "If you're at a location or in a season where the sun never rises or sets, those values [sunrise/sunset] will be `nil` for that day." This confirms the ambiguity: nil during both conditions.

| Field | Polar Night | Polar Day | Normal Day |
|---|---|---|---|
| `sunrise` | `nil` | `nil` | `Date` |
| `sunset` | `nil` | `nil` | `Date` |
| `solarNoon` | **`nil`** | `Date` | `Date` |
| `solarMidnight` | `Date` | **`nil`** | `Date` |

**Consequence for Iris §3.3:** Using `sunrise == nil` as the primary polar-night trigger would also fire on polar-day dates — those days would incorrectly collapse to "No UV today" even when UVI is 8–14. This is a bug in the current spec.

### 1.8 Apple documentation citation status

- `sunrise` optionality at polar latitudes: **confirmed** — property-level doc + WWDC22 session 10035
- `solarNoon` nil = polar night: **confirmed** — property-level doc explicit
- `solarMidnight` nil = polar day: **confirmed** — property-level doc explicit
- Behavior at specific degree thresholds (>66.5° N/S): **not explicitly documented** — docs say "extreme latitudes" without a numeric threshold
- No dedicated Apple Knowledge Base article, sample project, or additional WWDC session covering polar behavior beyond session 10035

---

## Question 2: `HourWeather.uvIndex` at Polar Night

### 2.1 Swift API declaration

`HourWeather.uvIndex` is declared as `var uvIndex: UVIndex` — **non-optional**. It is always present in every hourly entry. There is no mechanism for a missing hourly entry; the hourly forecast array is an `[HourWeather]` with one element per hour returned.

Source: [HourWeather.uvIndex — Apple Developer Documentation](https://docs.developer.apple.com/documentation/WeatherKit/HourWeather/uvIndex)

### 2.2 Apple documentation on polar behavior: **I could not confirm**

Apple does not document the specific integer value `HourWeather.uvIndex.value` returns during polar night. The property-level documentation contains no polar-specific language.

### 2.3 Inference from established science (not an Apple claim)

Wheeler's memo (wheeler-polar-region-uv-science.md §1.1) establishes per cited peer-reviewed literature (WHO/WMO/UNEP/ICNIRP 2002 §3.1) that erythemally-weighted UVB during polar night rounds to UVI = 0 under the WHO integer convention. Apple's WeatherKit UVI field follows the WHO integer scale (Wheeler confirmed; D-2026-05-19 family). Therefore, during true polar night, every hourly `uvIndex.value` should be `0`.

**This is an inference from physics, not an Apple specification.** WeatherKit could conceivably return a non-zero value on a day where `solarNoon == nil` if their forecast model includes, e.g., extremely diffuse scattered radiation. We cannot rule this out from documentation alone.

### 2.4 Polar-day hourly UVI

During polar day, all 24 hours should return non-zero UVI values consistent with the modeled solar angle and atmosphere at that latitude. Apple does not document this either. The behavior is consistent with physics: the sun being above the horizon all 24 hours would produce non-zero UVI for all hours when skies are clear. Cloud cover can still produce `uvIndex.value == 0` for individual hours even during polar day (heavy overcast).

### 2.5 `HourWeather.isDaylight` — auxiliary signal

`HourWeather.isDaylight: Bool` is non-optional and documented as "The presence or absence of daylight at the requested location and hour." During polar night, all 24 entries would have `isDaylight == false`; during polar day, all 24 would have `isDaylight == true`. This is corroborated by the description but, like `uvIndex.value`, has no polar-specific documentation.

### 2.6 Recommended test plan for empirical confirmation

Since Apple does not document uvIndex behavior at polar latitudes:

> **Ma-Ti test plan request:** Write a unit test that constructs a mock `DayWeather` (or our `DailyForecastEntry` equivalent) with `sun.solarNoon == nil` (polar night) and verifies that (a) the polar-night trigger fires, and (b) the "No UV today" row renders — **regardless** of what the hourly uvIndex values are. The trigger must not depend on uvIndex values. Once shipped, empirical spot-checks at Tromsø (70°N, ~two months of polar night) or Svalbard (78°N) will confirm WeatherKit's actual UVI return for those hours.

---

## Question 3: Recommended Canonical Polar-Night Trigger

### 3.1 Evaluation of candidates

**(A) `dayForecast.sunrise == nil`**  
❌ **Not recommended.** Ambiguous — fires for both polar night and polar day. Polar-day false positive would collapse a day with UVI 8–14 to "No UV today." This is both scientifically wrong and potentially harmful.

**(B) `dayForecast.sunrise == nil && all hourly UVI for that day == 0`**  
⚠️ **Not recommended.** The UVI gate rescues the polar-day false positive (polar day has non-zero UVI). But it introduces a dependency on hourly data for a condition that the day-level API already expresses more cleanly. Also, the 18-hour consecutive threshold variant of this is exactly the kind of invented heuristic the directive prohibits.

**(C) `all hourly UVI for that day == 0`**  
❌ **Not recommended.** Fires on any heavily overcast day, not just polar night. False-positive rate at mid-latitudes is low but non-zero. Ignores the precise Apple-documented signal.

**(D) `dayForecast.sun.solarNoon == nil`**  
✅ **Recommended.** Apple explicitly documents that `solarNoon` is `nil` "If the highest point isn't above the horizon." This is the definition of polar night in astronomical terms. It is nil **only** during polar night, not polar day. Single-signal, no heuristics, trusts the vendor signal.

### 3.2 Recommendation: Option D

```
Polar-night trigger: dayForecast.sun.solarNoon == nil
```

**Rationale:**
- `solarNoon == nil` is Apple-documented to mean "the sun's highest point is not above the horizon" — the literal definition of polar night
- Unambiguous: will not fire during polar day (where `solarNoon != nil`)
- Will not fire on overcast mid-latitude days (where `solarNoon != nil`)
- Single WeatherKit field, no derived inference, no invented threshold
- Clean counterpart: `solarMidnight == nil` = polar day (if Iris ever needs that branch)
- Complies with Yashas's directive: no heuristics, trust the vendor signal

**Fallback if `solarNoon` is unexpectedly nil at non-polar latitudes (edge case):** This is not an invented heuristic — it is trusting Apple's documented contract. If Apple returns `solarNoon == nil` at a non-polar latitude, that is Apple's signal and we render accordingly. Per the directive: "If WeatherKit gives us ambiguous or contradictory polar-region data, we render whatever we got."

---

## Question 4: Replacement Text for Iris's Spec §3.3

### 4.1 What changes

- **Drop:** dual-condition trigger (`sunrise == nil` + all-hourly-UVI == 0)
- **Drop:** 18-hour consecutive-zero fallback (entirely — per directive)
- **Drop:** Wheeler-ratification pending note (Wheeler has ratified the collapsed state; trigger is now locked by Kwame's research)
- **Add:** `solarNoon == nil` as the single trigger
- **Clarify:** edge case behavior per directive ("render whatever we got")

### 4.2 Replacement text for Iris §3.3

---

### 3.3 Polar night — collapsed single-row treatment

**Definition of "polar night" for UI purposes:**

Trigger the collapsed state when `dayForecast.sun.solarNoon == nil`. Apple's WeatherKit documentation states that `SunEvents.solarNoon` is `nil` specifically "if the highest point [of the sun] isn't above the horizon" — the astronomically precise definition of polar night. This is the only condition under which `solarNoon` is nil; it does **not** fire on overcast mid-latitude days or during polar day (polar day uses `solarMidnight == nil` instead).

**No fallback heuristic.** The 18-consecutive-hour UVI threshold is removed. The `sunrise == nil` secondary check is removed. Trust what WeatherKit provides.

**When the trigger fires (polar night):**

Replace the full 24-hour hourly strip with a single collapsed row using Wheeler's §4.2 ratified copy:

```
[moon.stars.fill, 16pt, Color(.secondaryLabel)]   "No UV today"
                                                   "The sun does not rise here today. (Polar night)"
                                                   .subheadline .secondary
```

VoiceOver label: `"No UV today. The sun does not rise at this location today. This is called polar night."`

**When the trigger does NOT fire (normal or polar day):**

Render the full 24-hour hourly strip as specified in §3.2. Both normal-day and polar-day cases render the strip; polar day simply has UVI values across all 24 cells.

**Edge case — contradictory data (solarNoon non-nil but all hourly UVI == 0, or vice versa):**

Render whatever WeatherKit returned. Do not substitute our own inference. If `solarNoon != nil` but every hourly UVI is 0 (e.g., extreme cloud cover at high latitude), render the full strip showing 24 cells of UVI = 0. If `solarNoon == nil` but hourly UVI is non-zero (Apple model edge case), show the polar-night collapsed row — that is Apple's authoritative signal that the sun is not above the horizon, even if their forecast model produced a non-zero UVI value for that hour.

---

### 4.3 Impact table

| Component | Change required | Note |
|---|---|---|
| **Iris §3.3 trigger** | Replace with `solarNoon == nil` | Drops `sunrise == nil` primary + 18h fallback |
| **Iris §3.3 copy** | Use Wheeler §4.2 copy as-is | Already ratified; no change |
| **Iris §3.4 polar day** | Add explicit note: `solarMidnight == nil` = polar day | Clarifies the counterpart |
| **Storage layer** (`DailyForecastEntry`) | **No change** — `sunrise: Date?` and `sunset: Date?` fields are already nullable | The `solarNoon` signal is read from the live `DayWeather` at render time; add `solarNoon: Date?` to `DailyForecastEntry` to persist it if needed |
| **`ForecastSnapshot` schema** | Minor: add `solarNoon: Date?` to `DailyForecastEntry` if picker needs it; bump schema version | Low priority; can defer to v1.1 if picker doesn't need polar-night distinction |
| **Picker** | No change — polar night hits the existing `uvIndex == 0 → "No UV at this hour"` path | Confirmed by Wheeler memo |
| **Ma-Ti test plan** | New test: mock `solarNoon == nil` → trigger fires; `solarNoon != nil` → strip renders | See §2.6 above |
| **Type-name correction in docs** | Team documents using "Sun" as type name — correct to "SunEvents" | Access path `dayWeather.sun.sunrise` is correct; intermediate type is `SunEvents` |

---

## Citations

| Claim | Source |
|---|---|
| `SunEvents.sunrise: Date?` intentionally optional at polar latitudes | [Apple Developer Docs — SunEvents.sunrise](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/sunrise) |
| `SunEvents.sunset: Date?` intentionally optional at polar latitudes | [Apple Developer Docs — SunEvents.sunset](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/sunset) |
| `SunEvents.solarNoon: Date?` nil when highest point not above horizon | [Apple Developer Docs — SunEvents.solarNoon](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/solarNoon) |
| `SunEvents.solarMidnight: Date?` nil when lowest point not below horizon | [Apple Developer Docs — SunEvents.solarMidnight](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/solarMidnight) |
| `DayWeather.sun` is `var sun: SunEvents` (non-optional struct) | [Apple Developer Docs — DayWeather.sun](https://docs.developer.apple.com/documentation/WeatherKit/DayWeather/sun) |
| `HourWeather.uvIndex: UVIndex` always present, no polar docs | [Apple Developer Docs — HourWeather.uvIndex](https://docs.developer.apple.com/documentation/WeatherKit/HourWeather/uvIndex) |
| `sunrise == nil` fires for both polar night and polar day | WWDC22 session 10035 "Tap into Weather Data with WeatherKit" |
| UVI = 0 during polar night under WHO integer convention | Wheeler memo (wheeler-polar-region-uv-science.md) §1.1, citing WHO/WMO/UNEP/ICNIRP 2002 §3.1 |
| `sunrise == nil` confirmed optional at extreme latitudes | [Apple Developer Docs — SunEvents.astronomicalDawn](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/astronomicalDawn), [civilDawn](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/civilDawn) (same rationale pattern) |

## What I Could Not Confirm

- Apple does not document the specific `uvIndex.value` returned during polar night (whether it is guaranteed to be 0). This is inferred from physics + Wheeler's science memo; empirical production verification recommended (see §2.6 test plan).
- Apple does not specify a numeric latitude threshold for when `solarNoon` goes nil. Docs say "extreme latitudes" without a degree value.
- No Apple WWDC session or sample code was found that goes deeper than the property-level documentation on polar solar events. Session 10035 (WWDC22) confirms nil behavior but does not elaborate beyond that.
- Apple Weather app behavior at polar coordinates (Svalbard, Tromsø) has not been personally verified in a production build; behavior is inferred from published documentation and the WWDC22 statement.
