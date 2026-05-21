# Spec Memo — Main Screen Noise Reduction
**Author:** Iris (UI/UX Designer — Apple HIG & Accessibility)
**Date:** 2026-05-21T04:18:05Z
**Status:** Revised v2 — 2026-05-21T04:30:00Z — EstimateInfoSheet dropped; toolbar ⓘ opens AboutView directly (Yashas decision). Plunder C1–C4 confirmed satisfied.
**Requested by:** Yashas

---

## §1 Current State Audit

### 1A — Photosensitization Banner (`photosensitizationBannerLabel`)

| Surface | File:Line | Description | Always shown? |
|---|---|---|---|
| `photosensitizationBanner` in `RootView.navigationStackBase` | `AppViews.swift:88` | First item in the main VStack — yellow/orange `NavigationLink` card, `exclamationmark.triangle.fill`, callout-semibold text, `chevron.right` | **Yes — unconditional** |
| `Text(...)` rendering | `AppViews.swift:255` | Inner label of the banner | Yes |
| `.accessibilityLabel(...)` | `AppViews.swift:280` | VoiceOver label on the banner | Yes |

**Problem:** Rendered *above* everything else, including the hero card. On a 4.7″ (iPhone SE 3) at AX5 Dynamic Type, this banner can consume ~20 % of the screen, displacing the hero number that is the whole point of opening the app. It appears regardless of whether the user is in any photosensitization-relevant situation.

---

### 1B — Main Verdict Caveat (`reapplicationFooter` + `mainVerdictCaveatLinkLabel`)

| Surface | File:Line | Copy | Placement |
|---|---|---|---|
| `PersistentFooter` — `Text(...)` | `AppViews.swift:1943` | "Cover up if skin reddens. Reapply sunscreen at least every 2 hours regardless of timer. Informational only. Not medical advice. Skin response varies." | Sticky bottom-bar `safeAreaInset`, always visible |
| `HeroTimerCard` — `NavigationLink` | `AppViews.swift:835` | "Meds + conditions can shorten this. Learn more" | Inside the hero card, shown only when `estimate.rawMinutes.isFinite` |

**Problem:** Two disclaimer-style surfaces in the most valuable screen real estate (bottom bar + hero card). The `PersistentFooter` blocks bottom bar breathing room. `mainVerdictCaveatLinkLabel` repeats the "Learn more" intent that already exists via `disclaimerLinkLabel` in the same footer. Net effect: three "Not medical advice"-class touchpoints visible simultaneously when an estimate is live.

---

### 1C — Location Reminder Occurrences

| # | Surface | File:Line | Copy / Behaviour | Condition Visible |
|---|---|---|---|---|
| 1 | `LocationRationaleCard()` inline | `AppViews.swift:92–93` | "Location permission" headline + `locationRationale` + `locationPrivacyLine` | `!locationPromptGate.hasAcknowledgedRationale` — first launch only |
| 2 | `UVIndexPlaceholderCard` body | `AppViews.swift:1041` | "Use your location to fetch the current UV index." | Whenever `uvIndex == nil` (no UV yet) |
| 3 | `HeroTimerCard` status message (hero empty-state) | `AppViews.swift:933` via `displayedStatusMessage` → `emptyStateAwaitingLocation` | "Tap Use my location to compute your estimate." | `uvIndex == nil`, skin type set, no transient status |
| 4 | Transient `statusMessage` post-rationale | `AppViews.swift:425` | "Location rationale reviewed. Tap Use my location to continue." | After user dismisses `LocationRationaleCard`, before tapping the primary action button — brief |
| 5 | `locationChip` in `mainInputsRow` | `AppViews.swift:289–296` | `location` SF Symbol + "Location" label (or coordinate) | Always visible in main inputs row |
| 6 | `primaryAction` button label | `AppViews.swift:397` | "Continue to location request" / "Use my location" | In bottom-bar `safeAreaInset`, always visible |

**Problem:** On first launch (skin type set, rationale unacknowledged, no UV), **surfaces 1, 2, 3, 5, and 6 are all simultaneously visible**, giving the user five distinct location nudges on one screen. Surfaces 2 and 3 are structurally redundant — both say "you need to tap that button."

---

## §2 New Placements

### 2A — "Meds or photosensitive conditions? Learn more" (`photosensitizationBannerLabel`)

**Remove from:** `RootView.navigationStackBase` VStack top slot (AppViews.swift:88 + the `photosensitizationBanner` computed property, lines 247–283).

**New home: Trailing navigation-bar info button (ⓘ) → `AboutView` directly.**

**Yashas decision (2026-05-21T04:30:00Z):** The toolbar ⓘ opens `AboutView(highlightEstimateApplicability: true)` directly, skipping a custom sheet. `AboutView` already has `highlightEstimateApplicability: Bool` (AppViews.swift:1506) and a `ScrollViewReader` that scrolls to `notForMeAnchor` (the "When this estimate may not apply" section) on `.onAppear`. No new init parameter or scroll mechanism is required.

**Rationale:**
- The photosensitization concern is **discovery information**, not an alert that requires immediate action on every launch. It belongs one tap away, not zero taps.
- A `toolbar` trailing `Button` with SF Symbol `info.circle` is the canonical HIG pattern for "there's context about this screen you might want." It does not consume scroll content height.
- The existing `gearshape` Settings button occupies `.primaryAction` (trailing). The ⓘ button should be placed as a **second toolbar item** in `.topBarTrailing` grouping. HIG permits multiple trailing items when they are distinct in function.
- `AboutView` is already a `NavigationLink` push destination at line 249 (`AboutView(highlightEstimateApplicability: true)`) — no new surface needed. Reusing it satisfies Plunder's C2+C3+C4 constraints in one affordance (provided safety-actions content is rehomed into AboutView per §2B below).
- The banner's `exclamationmark.triangle.fill` icon and orange background create visual alarm for non-emergency content. An `info.circle` toolbar button is calmer and more appropriate to the "this may not apply to you" framing.

**HIG / a11y spec:**
- **SF Symbol:** `info.circle` (weight: `.regular`; do not use `.fill` — that reads as "active state")
- **Color:** `.tint` (adapts to light/dark/high-contrast automatically)
- **Placement:** `ToolbarItem(placement: .topBarTrailing)` — second item after `.primaryAction` gear
- **Action:** `NavigationLink(destination: AboutView(highlightEstimateApplicability: true))` wrapping the button label — push navigation, not sheet
- **accessibilityLabel:** `"About this estimate"`
- **accessibilityHint:** `"Opens photosensitization, medication, and sunscreen assumption caveats."`
- **accessibilityIdentifier:** `"EstimateInfoButton"`
- **Presentation:** standard NavigationLink push — system back button / swipe-back dismisses. No custom animation; Reduce Motion has no special case needed.

**What stays on main screen after removal:**
- `mainVerdictCaveatLinkLabel` ("Meds + conditions can shorten this. Learn more") **also removed** — see §2B.
- The ⓘ button replaces *both* the top banner and the in-card link as the single entry point to photosensitization and safety-actions content.

---

### 2B — "Cover up if skin reddens…" (`reapplicationFooter`) + "Meds + conditions can shorten this." (`mainVerdictCaveatLinkLabel`)

These two items travel together because they are co-located in the legal disclaimer tier.

**Current surfaces to change:**
- `PersistentFooter` (AppViews.swift:1940–1957): remove `Text(ProductCopy.reapplicationFooter)` entirely.
- `HeroTimerCard` (AppViews.swift:831–842): remove the `mainVerdictCaveatLinkLabel` `NavigationLink`.
- The existing `disclaimerLinkLabel` ("Informational only. Not medical advice.") + `NavigationLink` in `PersistentFooter` (AppViews.swift:1947–1955) **stays** — it is the required reach-back from main screen. This is the single survivor.

**New home for `reapplicationFooter` content:** Inside `AboutView`, rendered within the `notForMeAnchor` VStack (AppViews.swift:1551–1570) so it is visible when the view scrolls to that anchor via `highlightEstimateApplicability: true`.

**Why AboutView's existing content is NOT sufficient without this change:**
`AboutView` currently has a "Sunscreen assumptions" section (AppViews.swift:1546–1549) with `aboutSunscreenAssumptions` = "The estimate assumes sunscreen remains correctly applied. Reapply at least every 2 hours…" — this covers Plunder's Clause B (reapplication cadence). However:
1. Clause A ("Cover up if skin reddens" — biological-feedback override) is **absent** from AboutView entirely.
2. The "Sunscreen assumptions" section appears **above** `notForMeAnchor` in the scroll order. When `scrollTo(notForMeAnchor)` fires, that section scrolls out of view. Clauses A and B are therefore NOT visible at the landing position.

**Rehome spec:** A new `aboutSunSafetyActions` constant in `ProductCopy.swift` carrying clauses A+B from `reapplicationFooter`:
> `"Cover up if skin reddens. Reapply sunscreen at least every 2 hours regardless of timer."`

This constant is placed as a `Text` paragraph **at the top of the `notForMeAnchor` VStack**, before the "When this estimate may not apply" heading. Style: `.body`. This satisfies Plunder C2 at 1 tap from the ⓘ toolbar button. No new factual claims — this is a UI move of the existing string.

**New home for `mainVerdictCaveatLinkLabel`:** Absorbed into the ⓘ toolbar button entry point. No content moves — the ⓘ destination (AboutView at applicability anchor) covers the same "learn more" reach. The label itself is no longer rendered anywhere.

**Rationale:**
- `PersistentFooter` currently contains two items: the reapplication footer text and the "Informational only" link. Removing the text (into AboutView) recovers 2–3 lines of bottom-bar height and reduces clutter.
- The `mainVerdictCaveatLinkLabel` ("Meds + conditions can shorten this. Learn more") is redundant with the ⓘ button that now sits permanently in the nav bar.
- **What remains in `PersistentFooter`:** Only the `disclaimerLinkLabel` NavigationLink ("Informational only. Not medical advice.") — Plunder's canonical L2 persistent surface (C1). Single-line, visually quiet footer.

**HIG / a11y spec for PersistentFooter after change:**
- Single `NavigationLink` with SF Symbol `info.circle`, `.caption.weight(.semibold)`, `.tint` color — unchanged from current implementation
- `accessibilityHint:` "Opens About and applicability details." — unchanged
- VStack wrapper collapsed to a single HStack

---

## §3 Location Reminder Consolidation Plan

### 3A — Retained (single source of truth)

**Keep: `LocationRationaleCard` (AppViews.swift:92–93)**

This is the **only** pre-action location explanation that should survive. It:
- Appears only once per install (gate: `!locationPromptGate.hasAcknowledgedRationale`)
- Explains the "why" before the OS permission prompt fires
- Contains `locationRationale` and `locationPrivacyLine` — necessary for D-2026-05-19-011 privacy transparency floor
- Disappears permanently once rationale is acknowledged

No change to `LocationRationaleCard` itself. It already auto-dismisses correctly.

### 3B — Remove (redundant)

| Surface | File:Line | Action | Reason |
|---|---|---|---|
| `UVIndexPlaceholderCard` body copy "Use your location to fetch the current UV index." | `AppViews.swift:1041` | **Remove this sentence from the card** | Duplicates hero empty-state message; the card should say *what it will show* ("UV index"), not tell the user what to do — the CTA button does that |
| `UVIndexPlaceholderCard` `.accessibilityHint("UV index is unavailable until location is used.")` | `AppViews.swift:1052` | **Rephrase to** `"Fetch UV index using the Use my location button."` — removes imperative repetition, keeps actionable hint | Minor — keeps VoiceOver users informed |
| Hero empty-state `emptyStateAwaitingLocation` copy | `ProductCopy.swift:16` / `AppViews.swift:933` | **Keep** — this is the *hero* empty-state, not a reminder. But confirm the copy is directional rather than nagging: "Tap Use my location to compute your estimate." — this is already correct and non-redundant in context. | Keep because it's inside the hero, not an additional card |
| Transient `statusMessage` "Location rationale reviewed. Tap Use my location to continue." | `AppViews.swift:425` | **Simplify to** `"Ready — tap Use my location."` | Shorter; less repetition of button label; clearer state change |

### 3C — OS-Level Location Denied State

When `LocationError.denied` is thrown:
- `locationFailureMessage = ProductCopy.locationDeniedEmptyState` already fires (AppViews.swift:471)
- `locationDeniedEmptyState` = "Location access is off. You can adjust SPF and skin type now; enable When In Use access in Settings, then tap Use my location again."
- This is shown inside `HeroTimerCard.heroContent` at AppViews.swift:904–926 with an "Open Settings" button — **correct and complete**.
- No change needed to denied-state handling. The `LocationRationaleCard` does not show in this state (rationale was already acknowledged when denial fired).

### 3D — Net first-launch experience after consolidation

Before (5 simultaneous location messages):
1. LocationRationaleCard ← keep
2. ~~UVIndexPlaceholderCard "Use your location..."~~ ← remove sentence
3. Hero status "Tap Use my location to compute your estimate." ← keep (hero, non-redundant)
4. ~~Transient "Location rationale reviewed. Tap Use my location to continue."~~ ← simplify
5. locationChip "Location" in mainInputsRow ← keep (it's a control, not a reminder)
6. primaryAction "Continue to location request" ← keep (it's the CTA)

After: 1 explanatory card + 1 hero nudge + 1 CTA button. Clean, intentional.

---

## §4 Hand-off Checklist for Kwame

All items are **spec-only until Plunder's verdict is in**. Once Plunder confirms content floor, implement in order.

| # | File | What changes | Notes |
|---|---|---|---|
| K-1 | `AppViews.swift` | Remove `photosensitizationBanner` computed property (lines 247–283) and its call site (line 88) | This is the yellow top banner |
| K-2 | `AppViews.swift` | Add second `ToolbarItem(placement: .topBarTrailing)` with a `NavigationLink(destination: AboutView(highlightEstimateApplicability: true))` wrapping an `info.circle` Image. Set `.accessibilityLabel("About this estimate")`, `.accessibilityHint("Opens photosensitization, medication, and sunscreen assumption caveats.")`, `.accessibilityIdentifier("EstimateInfoButton")` | Push navigation (not a sheet). Goes in same toolbar block as existing `gearshape` button. `AboutView(highlightEstimateApplicability:)` already exists — no new view needed. |
| K-3 | `AppViews.swift` | **DELETE** — no `@State var showEstimateInfo` needed (no sheet) | — |
| K-4 | `AppViews.swift` | **DELETE** — no `.sheet(isPresented:)` binding needed | — |
| K-5 | `AppViews.swift` | **DELETE** — no `EstimateInfoSheet` struct needed | — |
| K-6 | `AppViews.swift` | In `PersistentFooter` (lines 1940–1957): remove `Text(ProductCopy.reapplicationFooter)` (line 1943) and flatten the `VStack` → single `NavigationLink` | `disclaimerLinkLabel` NavigationLink stays unchanged |
| K-7 | `AppViews.swift` | In `HeroTimerCard` (lines 831–842): remove the `mainVerdictCaveatLinkLabel` `NavigationLink` block entirely | The ⓘ toolbar button replaces this reach-back |
| K-8 | `AppViews.swift` | In `UVIndexPlaceholderCard` (lines 1034–1054): remove `Text("Use your location to fetch the current UV index.")` (line 1041). Rephrase `.accessibilityHint` on line 1052 to `"Fetch UV index using the Use my location button."` | Card retains title, source attribution, WeatherKit attribution |
| K-9 | `AppViews.swift` | In `refreshUV()` at line 425: change `statusMessage = "Location rationale reviewed. Tap Use my location to continue."` to `statusMessage = "Ready — tap Use my location."` | Simpler, less repetitive |
| K-10 | `ProductCopy.swift` | Add new constant: `public static let aboutSunSafetyActions = "Cover up if skin reddens. Reapply sunscreen at least every 2 hours regardless of timer."` | Clauses A+B from `reapplicationFooter`, factored out for placement in AboutView. `reapplicationFooter` constant can be kept for now (other references) or deprecated — Kwame's call. |
| K-11 | `AppViews.swift` | In `AboutView`, inside the `notForMeAnchor` VStack (lines 1551–1570): add `Text(ProductCopy.aboutSunSafetyActions).font(.body)` as the **first item in the VStack**, immediately before the `"When this estimate may not apply"` heading. This ensures Plunder C2 clauses A+B are visible on first paint when scrolled to anchor. | Renders in orange-highlighted box alongside the applicability text when `highlightEstimateApplicability: true` — no separate highlight needed. |

**Do not change:**
- `LocationRationaleCard` (keep as-is)
- `disclaimerLinkLabel` NavigationLink in `PersistentFooter` (Plunder's L2 surface — C1)
- `DisclaimerCover` (L1 surface — out of scope)
- `AboutView` structure beyond K-11 addition above
- `locationChip` in `mainInputsRow` (input control, not a reminder)
- `primaryAction` button (CTA — not a reminder)

---

## §5 Plunder Constraint Verification (v2)

Plunder's C1–C10 constraints are satisfied as follows. No new open gates remain — the EstimateInfoSheet is gone and the single remaining gate is K-11 AboutView content.

| Constraint | Satisfied by | Status |
|---|---|---|
| **C1** — Main screen visible affordance carrying "Not medical advice" / SaMD anchor | `disclaimerLinkLabel` NavigationLink in `PersistentFooter` — unchanged | ✅ Unchanged |
| **C2** — One-tap destination with both (i) "cover up if skin reddens" AND (ii) "reapply every 2 hours" | Toolbar ⓘ → `AboutView(highlightEstimateApplicability: true)` → `notForMeAnchor` VStack, which after K-11 contains `aboutSunSafetyActions` (clauses A+B) | ✅ Satisfied after K-11 |
| **C3** — One-tap to `aboutEstimateApplicability` anchor | Toolbar ⓘ → `AboutView(highlightEstimateApplicability: true)` → `scrollTo(notForMeAnchor)` — already works | ✅ Already works |
| **C4** — C1+C2+C3 merged into one affordance | Toolbar ⓘ is the single merged affordance; its destination (`AboutView` at `notForMeAnchor`) contains all three | ✅ Confirmed |
| **C5** — Destination dismissable, screen-reader-accessible, no network call | `AboutView` is a push nav; dismiss via swipe-back or back button. No network call. VoiceOver-accessible. | N/A for sheet; ✅ push nav satisfies equivalent |
| **C6** — `DisclaimerCover` (L1) unchanged | Out of scope; not touched | ✅ Unchanged |
| **C7** — Re-attestation cadence unchanged | Out of scope | ✅ Unchanged |
| **C8** — Location rationale: single in-session presentation | See §3 — unchanged | ✅ Unchanged |
| **C9** — Apple Weather attribution adjacency | Out of scope for this change | ✅ Unchanged |
| **C10** — Relocated strings preserve substance | `aboutSunSafetyActions` = same text as `reapplicationFooter` clauses A+B; no rewrite | ✅ Confirmed |

**Remaining Plunder open item (carry-forward, not a build blocker):**
- P-1 (formerly): confirm with outside counsel that `AboutView` push-nav satisfies "≤1 tap, no network" equivalently to a sheet (E10 from Plunder §5). Pre-counsel read: ✅ safe — push nav is offline and ≤1 tap. Confirm before App Store submit.

---

*End of spec v2.*
*Revised 2026-05-21T04:30:00Z. EstimateInfoSheet eliminated; all Plunder C1–C10 satisfied by toolbar ⓘ → existing AboutView.*
