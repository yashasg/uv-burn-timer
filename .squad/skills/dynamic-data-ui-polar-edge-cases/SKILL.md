---
name: "dynamic-data-ui-polar-edge-cases"
description: "How to design and implement UI rendering loops that handle variable-length data including polar-region edge cases (polar night, polar day, DST transitions) without hardcoded counts."
domain: "ui-design, data-rendering, accessibility, edge-cases"
confidence: "high"
source: "earned — WI-7 10-day UVI forecast feature, 2026-05-21T01:34:16Z"
---

## Context

Applies whenever:
- A UI renders a list or strip driven by time-series data (hourly, daily, or similar) from an external API.
- The data source (e.g., WeatherKit) may return a variable number of entries per "day" or "period" due to DST transitions, polar geography, or sparse API responses.
- The product requirement states "X hours per day" or "Y days" as a planning figure, but the actual data array may deviate.

Specific triggers:
- Hourly forecast cards at high latitudes (polar night / polar day)
- Any "daily" data rendered as a flat hourly loop
- DST spring-forward (23h day) and fall-back (25h day)
- API responses that return fewer days/hours than the nominal maximum (e.g., WeatherKit returning 6 of 10 days near the forecast window edge)

## Patterns

### 1. No hardcoded counts — ever

```swift
// ❌ WRONG
let hourlySlice = snapshot.hours.prefix(24)  // assumes exactly 24 per day

// ✅ CORRECT
let hourlySlice = snapshot.hours.filter { Calendar.current.isDateInToday($0.timestamp) }
// Count is whatever WeatherKit returned — 23, 24, or 25 on DST days
```

The UI iterates over the filtered slice. No `precondition(count == 24)`. No clipping.

### 2. Polar night collapsed state

When data is technically present but informationally trivial (e.g., 24 rows of UVI=0 at polar night), render a **single collapsed summary row** instead of the full list.

**Trigger condition (double-gate):**
1. Scientific signal: `DayForecast.sunrise == nil` (WeatherKit's native indicator — sun did not rise)
2. Data confirmation: all hourly UVI values for that day are `0.0`

Using both gates avoids false positives from heavily overcast temperate days where UVI happens to be zero across all hours.

**Fallback (if sunrise/sunset not available from the API):**
≥18 consecutive hours of UVI = 0.0 within a single calendar day (well above any temperate night duration).

**Collapsed row anatomy (iOS):**
```
[moon.stars.fill, 16pt, Color(.secondaryLabel)]  "No UV today — sun does not rise at your latitude"
                                                  .subheadline .secondary
```
- No `TierBadge` (UVI = 0 → no tier)
- Standard 44pt minimum row height
- VoiceOver label: sentence-case for natural TTS ("No UV today. Sun does not rise at this latitude.")

⚠️ Always seek domain-expert ratification of the trigger condition before implementing. The scientific signal (`sunrise == nil`) is correct but the domain expert must confirm the API behavior at target latitudes.

### 3. Polar day — no special case

If the sun never sets and UVI is non-zero across all hours, render the full list normally. The dynamic loop handles this without special-casing.

### 4. DST transitions — no special case

Render whatever the API returned. A 23-hour day renders 23 cells; a 25-hour day renders 25 cells. Horizontal scroll strips accommodate any count. No special-case UI needed.

### 5. Sparse API response (fewer days/hours than nominal)

Clamp to the last available data point. Surface a reveal affordance only when `actualCount > defaultVisibleCount`. If `actualCount == 0`, show the error state.

```swift
// Show progressive-disclosure affordance only when data exists beyond default visible rows
var isRevealAvailable: Bool { forecastDays.count > 7 }
```

### 6. Polar night in multi-day sequences

Apply the collapsed treatment per-day independently. A 14-day polar night shows N collapsed rows (one per day). Each day that meets the trigger shows its own collapsed row — no special multi-day batching UI needed for v1.

## Examples

**WI-7 UVI Forecast (2026-05-21):**
- Hourly "Today" card filters `snapshot.hours` by today's calendar date in device locale
- 10-day card iterates `snapshot.days` (up to 10 entries, whatever WeatherKit returned)
- Polar night row: `moon.stars.fill` + `"No UV today — sun does not rise at your latitude"`
- DST: renders 23 or 25 cells without any branch logic
- Reveal affordance: hidden when `forecastDays.count <= 7`, visible when `count > 7`

## Anti-Patterns

- ❌ `snapshot.hours.prefix(24)` — hardcodes assumption that exactly 24 hours are present per day
- ❌ `ForEach(0..<24)` with index-based lookup — breaks on DST days and polar edge cases
- ❌ Showing N rows of UVI=0 at polar night — this is noise, not signal. Collapse it.
- ❌ Triggering polar night collapsed state on all-zero UVI alone — heavy overcast at temperate latitudes can produce all-zero UVI. The `sunrise == nil` gate is required.
- ❌ Batching multi-day polar night into a single "X days of polar night" row for v1 — per-day independent treatment is simpler to implement and sufficient for the use case.
- ❌ Hiding the reveal affordance when count > 7 simply because the tail-end data is lower confidence — the affordance communicates that more data exists and lets the user opt in. Hiding it entirely would conceal the existence of days 8–10.

## Owners

- **Iris** — visual treatment of collapsed state, reveal affordance interaction design, a11y spec
- **Wheeler** — ratify the scientific trigger condition (sunrise == nil as the polar-night gate)
- **Kwame** — implementation of dynamic loop, trigger condition check, collapsed row rendering
- **Ma-Ti** — test cases: DST day (23h slice), DST night (25h slice), polar night trigger (sunrise nil + all-zero), polar day (24h non-zero), sparse API response (<7 days), reveal affordance hidden/shown

## Origin

Extracted 2026-05-21T01:34:16Z from work item #7 (10-day UVI forecast feature). Triggered by Yashas's directive: *"there are places in the world where the sun doesn't set and places in the world where the sun doesn't rise — our UI should be dynamic."*
