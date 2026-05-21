# Decision: A11y phrasing for burn-time gauge (drop "burn window")

**Author:** Kwame (iOS Developer)  
**Date:** 2026-05-21T08:35:00Z  
**Branch:** `feature/main-screen-cleanup`  
**Commit:** `0d5dadc`

---

## Context

Yashas asked to remove the "Burn window" term from user-facing UI. The term appeared in:
- `BurnRiskGaugeCard` body headline ("Burn window")
- `BurnRiskGaugeUnavailableCard` body headline ("Burn window")
- A11y string at line 820: "No active burn window because the UV index is 0."
- `supportingText`: "X% of burn window elapsed"
- `gaugeAccessibilityWindowDescription`: "of estimated burn window"

The long-form regulatory disclaimer copy (`aboutEstimateApplicability`) also uses "burn window" but is **out of scope** per explicit instruction — Plunder owns that wording.

---

## Decisions made

### 1. "burn window" → "burn time" in all a11y / supporting strings

Rationale: "burn time" is the term already used everywhere else in the product copy (e.g., `burnTimeEstimateTitle = "Burn-time estimate"`). Using "burn time" is consistent, plain-language, and HIG-appropriate. "Burn window" implied a bounded interval (which is technically accurate) but was opaque to end users.

Specific replacements:
| Old | New |
|-----|-----|
| "No active burn window because the UV index is 0." | "No active burn time because the UV index is 0." |
| "\(pct) of burn window elapsed" | "\(pct) of estimated burn time elapsed" |
| "of estimated burn window" | "of estimated burn time" |
| Gauge a11y hint: "Secondary risk indicator. The hero timer card shows the full estimate." | "Progress arc shows burn time elapsed." |
| Gauge a11y label: "\(pct) \(windowDesc) elapsed." | "\(remaining) remaining. \(pct) \(timeDesc) elapsed." |

### 2. Gauge circle: show remaining time, not percent elapsed

The circle previously showed "42%" + "elapsed". Yashas confirmed the circle should show approximate time remaining. Changed to `remainingText` ("~13 min") + "remaining" label.

Remaining time is computed as `max(0, effectiveWindowMinutes * 60 - elapsed)`, formatted as:
- "Elapsed" when ≤ 0 min
- "~X min" when < 60 min  
- "~X hr" / "~X hr Y min" when ≥ 60 min

The `percentText` is still used in `supportingText` (for differentiateWithoutColor a11y path) and in the a11y label so VoiceOver can still announce the elapsed fraction.

### 3. Removed nested card container, NOT the outer HeroTimerCard

`BurnRiskGaugeCard` had its own `.thinMaterial` + `RoundedRectangle` card background. This created nested card chrome inside `HeroTimerCard`. Removed the inner card container so the gauge sits flush. `HeroTimerCard` (the "Burn-time estimate" card) is retained as-is — it holds the hero number, tier badge, context line, stale warnings, and safety cards. Only the duplicative inner card skin was removed.

### 4. `ProductCopy.burnTimeEstimateTitle` retained

Grep confirmed it is still referenced in `AppViews.swift` line 758 as `HeroTimerCard`'s header text (`forecastDateContext ?? ProductCopy.burnTimeEstimateTitle`). It also appears in `auditCopySurfaces`. Not deleted.
