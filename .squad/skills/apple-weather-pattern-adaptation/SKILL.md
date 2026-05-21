# Skill: Adapting Apple Weather App Patterns for Health-Adjacent iOS Features

**Category:** iOS Design Validation  
**Applies to:** Any feature that borrows from Apple's Weather app (hourly strip, daily forecast card) for a health or safety context  
**Last updated:** 2026-05-20T17:27:34-07:00

---

## When This Applies

You're validating or designing a feature that:
- Borrows the Weather app's horizontal hourly scroll strip and/or vertical N-day forecast card
- Operates on time-series data with a meaningful scale (UV, AQI, pollen, etc.)
- Has a personalization layer on top of raw sensor/forecast data (skin type, allergies, lung condition, etc.)

---

## The Pattern

### What Apple's Weather App Gets Right (Safe to Borrow)
- Horizontal ScrollView for hourly time-series — HIG-blessed, users know this affordance
- Vertical grouped list for N-day daily summary — clean, Dynamic Type–safe when using `List`
- Card-based grouping with `.regularMaterial` background — adapts to dark mode and Increase Contrast automatically
- `navigationTitle` with `.large` display mode on the forecast screen — correct for content-dominant screens

### What Breaks in a Health/Safety Context

| Weather App Behavior | Why It Breaks | Fix |
|---|---|---|
| Color bands for severity (green→purple for UV, temperature gradients) | Color-only encoding fails WCAG 1.4.1 | Pair with text tier labels at every instance |
| Raw numeric display (temperature, UV value) | Health app differentiator is personalization — raw numbers add no value over the stock app | Compute and display the personalized derivative (burn window, symptom risk, etc.) alongside or instead of the raw value |
| Fixed-width cells in horizontal strip | Clips at AX3+ Dynamic Type | `@ScaledMetric` or layout switch to vertical list at `isAccessibilityCategory` |
| Auto-scroll to current hour on appear | Fails Reduce Motion if animated | Guard with `accessibilityReduceMotion`; use instant scroll instead |
| Icons communicate condition visually | VoiceOver assembles from child views inconsistently | Always provide explicit `accessibilityLabel` on each cell container |

---

## Accessibility Checklist for Borrowed Weather Patterns

- [ ] **WCAG 1.4.1** — Every color used for severity has a paired text label or icon with non-color meaning
- [ ] **WCAG 1.4.3 / 1.4.11** — Verify contrast of severity colors against card background (≥4.5:1 for text, ≥3:1 for UI components); yellow and green commonly fail against white
- [ ] **VoiceOver per-cell label** — `accessibilityLabel` on each horizontal strip cell; format: `"[Time]. [Value], [severity tier]. [Personalized metric]."` 
- [ ] **Dynamic Type AX5** — Fixed-dimension cells must have a minimum width via `@ScaledMetric` OR switch to vertical list at `.isAccessibilityCategory`
- [ ] **Reduce Motion** — Any scroll-to-position animation guarded; loading shimmer guarded
- [ ] **Rotor navigation** — Test the horizontal strip with VoiceOver rotor (headings, links, custom actions) — swipe-through is tedious; consider a `.accessibilityCustomAction` "Summarize forecast" that reads peak value + personalized metric

---

## Apple's Flat 10-Day Treatment (HIG Evidence)

**Apple Weather does NOT visually demote days 7–10.** All 10 rows in the iOS Weather forecast card have identical visual weight: same typography, same color treatment, same icon opacity. HIG is silent on confidence-decay for forecast cards, and Apple's own implementation is the clearest available signal.

**Implication:** Per-row opacity or gray treatment for "lower confidence" far-out days has no HIG precedent and introduces WCAG 1.4.3 risk (text at <80% opacity on `.regularMaterial` backgrounds commonly fails 4.5:1 contrast minimum for normal text).

**Recommended pattern when science requires a confidence disclosure:** One `.caption .secondary` footnote at the bottom of the forecast card. Example:
> *"UV accuracy beyond 3–5 days decreases as cloud cover becomes harder to predict."*

This satisfies a science-gate requirement ("must be visible on the card"), is HIG-consistent with Weather app attribution footnotes, is WCAG-safe at full `.secondary` opacity, and VoiceOver reads it once per card — not once per row.

---

## Progressive Disclosure Rule

If the host screen already has a hero card plus ≥2 secondary cards, put the forecast behind a chip → sheet or NavigationLink. Do **not** add two more inline cards to a dense main screen. The hero use case must remain dominant.

---

## Science Gate Rule (Health-Adjacent Only)

Before shipping hourly personalized metrics derived from forecast data, confirm with the domain expert:
1. Is it valid to compute the metric independently per hour without cumulative-exposure tracking?
2. What uncertainty exists in the forecast input (clouds, ozone, model error)?
3. What framing prevents the user from misreading a per-hour estimate as a per-session safe duration?

If these questions aren't answered, block implementation.
