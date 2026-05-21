# Skill: WeatherKit Optional Sun Fields at Polar Latitudes

**Domain:** iOS / Swift / WeatherKit  
**Pattern name:** `weatherkit-optional-sun-fields-polar-latitudes`  
**Applicable when:** You need to detect polar night, polar day, or any "sun doesn't cross horizon" condition using WeatherKit's `DayWeather` struct.

---

## The Type: `SunEvents` (not `Sun`)

`DayWeather.sun` is declared as `var sun: SunEvents` — a **non-optional** struct. You always receive a `SunEvents` value. The optional `Date?` fields are properties inside it.

```swift
let dayWeather: DayWeather = ...
let solarNoon: Date? = dayWeather.sun.solarNoon   // nil during polar night
```

**Do not write:** `dayWeather.sun?.solarNoon` — `sun` is not optional.

---

## The Key Signal Mapping

| `SunEvents` field | `Date?` | nil during… | Documented behavior |
|---|---|---|---|
| `sunrise` | `Date?` | Polar night AND polar day | "optional because it's possible for the sun to not rise on a given day" |
| `sunset` | `Date?` | Polar night AND polar day | "optional because it's possible for the sun to not set on a given day" |
| `solarNoon` | `Date?` | **Polar night only** | "If the highest point isn't above the horizon, this property is `nil`" |
| `solarMidnight` | `Date?` | **Polar day only** | "If the lowest point is not below the horizon, this property is `nil`" |
| `civilDawn` / `nauticalDawn` / `astronomicalDawn` | `Date?` | Polar night (and near-polar winter) | Same optionality rationale as sunrise |

---

## Critical Insight: `sunrise == nil` Is Ambiguous

`sunrise == nil` fires for **both** polar night and polar day. During polar day (midnight sun), the sun never dips below the horizon, so there is no sunrise event — `sunrise` is nil even though UVI may be 8–14.

- **Do NOT use `sunrise == nil` as a polar-night-only trigger.** It will false-positive on polar-day dates.

---

## Canonical Triggers

### Polar Night
```swift
// Apple-documented: solarNoon is nil "if the highest point isn't above the horizon"
let isPolarNight = dayWeather.sun.solarNoon == nil
```

### Polar Day  
```swift
// Apple-documented: solarMidnight is nil "if the lowest point is not below the horizon"
let isPolarDay = dayWeather.sun.solarMidnight == nil
```

### Normal Day
```swift
let isNormalDay = dayWeather.sun.solarNoon != nil && dayWeather.sun.solarMidnight != nil
```

---

## Disambiguation Table

| Condition | `sunrise` | `sunset` | `solarNoon` | `solarMidnight` |
|---|---|---|---|---|
| Normal day | `Date` | `Date` | `Date` | `Date` |
| Polar night | `nil` | `nil` | **`nil`** | `Date` |
| Polar day | `nil` | `nil` | `Date` | **`nil`** |

---

## `HourWeather.uvIndex` at Polar Latitudes

**Apple does not document this.** `HourWeather.uvIndex: UVIndex` is non-optional (always present). By physics inference (WHO 2002 §3.1) and consistent with Apple Weather's display, `uvIndex.value == 0` during polar night. However, this is not specified in the WeatherKit API docs and should be treated as empirically-confirmed-but-not-contractual.

**Do not gate polar-night detection on uvIndex values** — use `solarNoon == nil` as the trigger and accept uvIndex as whatever the vendor returns.

---

## WWDC Reference

- **WWDC22 session 10035** — "Tap into Weather Data with WeatherKit": confirms `sunrise`/`sunset` are nil when the sun "never rises or sets." The session does not go deeper on polar disambiguation; `solarNoon`/`solarMidnight` are the resolution.

---

## Documentation URLs

- [SunEvents.sunrise](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/sunrise)
- [SunEvents.sunset](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/sunset)
- [SunEvents.solarNoon](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/solarNoon)
- [SunEvents.solarMidnight](https://docs.developer.apple.com/documentation/WeatherKit/SunEvents/solarMidnight)
- [DayWeather.sun](https://docs.developer.apple.com/documentation/WeatherKit/DayWeather/sun)

---

## Anti-patterns

1. ❌ `dayWeather.sun?.sunrise` — `sun` is non-optional; this won't compile
2. ❌ `sunrise == nil` as polar-night detector — ambiguous; also fires on polar day
3. ❌ Counting consecutive zero-UVI hours to infer polar night — invented heuristic; use `solarNoon == nil` instead
4. ❌ Referring to the type as "Sun" — the actual type is `SunEvents`

---

## Project context

First applied: UV Burn Timer, WI-7 polar-night trigger research, 2026-05-21T01:52:54Z.  
Reference memo: `.squad/decisions/inbox/kwame-weatherkit-polar-api-research.md`  
Directive that motivated this: `.squad/decisions/inbox/copilot-directive-2026-05-21T01-52-54Z-trust-weatherkit-no-fallbacks.md`
