# SKILL — iOS Info-Sheet Pattern for Legal / Safety Disclaimers

**Skill ID:** `ios-legal-disclaimer-info-sheet`
**Author:** Iris
**Created:** 2026-05-21T04:18:05Z
**Last updated:** 2026-05-21T04:30:00Z
**Origin:** Main screen noise-reduction spec (`iris-main-screen-cleanup.md`); revised after v2 simplification.

---

## Problem

Health-adjacent apps accumulate disclaimer text on the main screen (banners, footer paragraphs, hero-card links). Each individual item feels justified, but together they produce visual noise and crowd out the primary content. The challenge is maintaining legal/safety reach-back while clearing the main screen.

---

## Principle: Reuse Existing Surfaces Before Building New Ones

> **If a regulatory floor can be met by anchoring into an existing surface (e.g., `AboutView` with a `highlightEstimateApplicability` init parameter + `ScrollViewReader`), do NOT build a new sheet. The simpler path satisfies the floor with fewer code objects, fewer tests, and no sheet state management.**

**Test before speccing a new sheet:**
1. Does an existing destination view already contain (or can cheaply be extended to contain) the legally required content?
2. Does the destination already support scroll-to-anchor or highlight-on-arrival?
3. Is the existing view reachable via `NavigationLink` push (offline, ≤1 tap)?

If all three are yes → push to existing view. New sheet is not needed.

---

## Pattern A: ⓘ Toolbar Button → Existing View (Preferred when existing surface qualifies)

```
Toolbar (main screen)
  ├── .primaryAction: gearshape (Settings)
  └── .topBarTrailing: info.circle → NavigationLink → AboutView(highlightEstimateApplicability: true)

AboutView (existing)
  └── ScrollViewReader → scrollTo(notForMeAnchor)
       └── notForMeAnchor VStack:
            ├── Text(aboutSunSafetyActions)   ← safety clauses A+B, visible at landing
            ├── "When this estimate may not apply" heading
            ├── Text(aboutEstimateApplicability)
            └── photosensitizationAuthorityLine + link
```

**Why push over sheet:** No state variable, no sheet binding, no "Done" button, no `NavigationStack` wrapper. System back / swipe-back handles dismiss. VoiceOver navigation title is the existing view's title.

---

## Pattern B: ⓘ Toolbar Button → Focused Sheet (When existing surface doesn't qualify)

Use this pattern only when the existing surface is too long/general to anchor usefully, or when the destination requires content not in any existing view.

```
Toolbar (main screen)
  ├── .primaryAction: gearshape (Settings)
  └── .topBarTrailing: info.circle → EstimateInfoSheet (.sheet)

EstimateInfoSheet (.sheet)
  ├── NavigationStack (for title + Done button)
  ├── Scrollable content:
  │    ├── Safety clauses A+B (top)
  │    ├── Photosensitization caveat (callout-semibold, orange)
  │    ├── Authority/source line (footnote secondary)
  │    ├── How the model works (body)
  │    └── "see About" button → full AboutView (2-tap reach)
  └── ToolbarItem(.confirmationAction): "Done"
```

---

## Rules (both patterns)

1. **"0-tap" floor:** At least ONE disclaimer-class persistent link must remain on the main screen with zero taps required. Use `disclaimerLinkLabel` ("Informational only. Not medical advice.") NavigationLink in a `PersistentFooter`. This is Plunder's L2 surface.
2. **"≤1-tap" floor:** All C2+C3 content (safety clauses A+B + applicability enumeration) must be reachable within 1 tap of the main screen. The ⓘ button satisfies this in both patterns.
3. **Content at landing:** Check what the user sees at the scroll-to anchor position, not just what the destination view contains somewhere. Safety clauses must be visible WITHOUT additional scrolling after the push/sheet opens.
4. **Sheet is not a disclaimer gate:** Do NOT make the sheet modal/blocking. Informational, dismissable, optional. The real gate is `DisclaimerCover` (L1).
5. **AX spec for the ⓘ button:**
   - SF Symbol: `info.circle` (not `.fill`)
   - `.accessibilityLabel("About this estimate")`
   - `.accessibilityHint(...)` — names the category of content, not a full sentence
   - `.accessibilityIdentifier(...)` — stable for UI tests
6. **Never delete both** the main-screen `disclaimerLinkLabel` (C1) AND the ⓘ button (C2/C3). That combination is below Plunder's floor.

### What NOT to do

- Do not remove the `PersistentFooter` `disclaimerLinkLabel` link. Even with the ⓘ button, the 0-tap persistent link is Plunder's L2 floor.
- Do not put the photosensitization banner back as an unconditional top-of-screen card.
- Do not assume a destination view contains required content at the scroll-landing position — verify visually.

---

## Reusability

This pattern applies to any screen where:
- Safety/legal copy accumulates across multiple surfaces
- The primary content (a number, a timer, a forecast) is being crowded out
- Regulatory floor requires "reachable in ≤ 1 tap" but NOT "always visible at 0 taps"
- The team has a dedicated legal reviewer (Plunder equivalent) who signs off on placement depth

## References

- `iris-main-screen-cleanup.md` §2A, §2B (v2 origin spec — no §2C, EstimateInfoSheet eliminated)
- `plunder-disclaimer-relocation-floor.md` §3 C1–C4
- Apple HIG: [Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars), [Navigation](https://developer.apple.com/design/human-interface-guidelines/navigation-bars)
- WCAG 2.2 SC 2.4.6 (Headings and Labels), SC 1.4.3 (Contrast Minimum)

---

## Problem

Health-adjacent apps accumulate disclaimer text on the main screen (banners, footer paragraphs, hero-card links). Each individual item feels justified, but together they produce visual noise and crowd out the primary content. The challenge is maintaining legal/safety reach-back while clearing the main screen.

## Solution Pattern: ⓘ Toolbar Button → Focused Sheet

### Structure

```
Toolbar (main screen)
  ├── .primaryAction: gearshape (Settings)
  └── .topBarTrailing: info.circle → EstimateInfoSheet

EstimateInfoSheet (.sheet)
  ├── NavigationStack (for title + Done button)
  ├── Scrollable content:
  │    ├── Reapplication / safety summary (top)
  │    ├── Photosensitization caveat (callout-semibold, orange)
  │    ├── Authority/source line (footnote secondary)
  │    ├── How the model works (body)
  │    ├── Sunscreen assumptions (body)
  │    └── "see About" button → full AboutView (2-tap reach)
  └── ToolbarItem(.confirmationAction): "Done"
```

### Rules

1. **"0-tap" floor:** At least ONE disclaimer-class persistent link must remain on the main screen with zero taps required. Use `disclaimerLinkLabel` ("Informational only. Not medical advice.") NavigationLink in a `PersistentFooter`. This is Plunder's L2 surface.
2. **"≤2-tap" floor:** All legally required content must be reachable within 2 taps of the main screen. The ⓘ button satisfies 1-tap, and "see About" inside the sheet satisfies 2-tap.
3. **Sheet content order:** Safety-critical text (reapplication cap, photosensitization) appears **before** model-explanation text. Users who open on a phone call, in sunlight, or with low attention see the safety content first.
4. **Sheet is not a disclaimer gate:** Do NOT make the sheet modal/blocking. It is informational, dismissable, and optional. The real gate is `DisclaimerCover` (L1).
5. **AX spec for the ⓘ button:**
   - SF Symbol: `info.circle` (not `.fill`)
   - `.accessibilityLabel("About this estimate")`
   - `.accessibilityHint(...)` — names the category of content, not a full sentence
   - `.accessibilityIdentifier(...)` — stable for UI tests
6. **Sheet a11y:**
   - Outer `NavigationStack` title announces to VoiceOver on sheet present
   - All text blocks at semantic text styles (Dynamic Type compatible at AX5)
   - "Done" button is `.confirmationAction` placement — reachable from Switch Control

### What NOT to do

- Do not use a `NavigationLink` to push a full `AboutView` directly from the ⓘ button. `AboutView` is long and general. The focused sheet is faster and sets correct user expectation.
- Do not remove the `PersistentFooter` `disclaimerLinkLabel` link. Even with the ⓘ button, the 0-tap persistent link is Plunder's L2 floor.
- Do not put the photosensitization banner back as an unconditional top-of-screen card. If a future cohort-targeted banner is needed (e.g., only shown when user has acknowledged a med-interaction setting), that is a different pattern; file a new spec.

## Reusability

This pattern applies to any screen where:
- Safety/legal copy accumulates across multiple surfaces
- The primary content (a number, a timer, a forecast) is being crowded out
- Regulatory floor requires "reachable in ≤ 2 taps" but NOT "always visible at 0 taps"
- The team has a dedicated legal reviewer (Plunder equivalent) who signs off on placement depth

## References

- `iris-main-screen-cleanup.md` §2A, §2B, §2C (origin spec)
- Apple HIG: [Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets), [Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars)
- WCAG 2.2 SC 2.4.6 (Headings and Labels), SC 1.4.3 (Contrast Minimum)
