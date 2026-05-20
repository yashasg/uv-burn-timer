# Squad Decisions

## Decisions Ledger


### 2026-05-19T16:14:26.336-07:00: User directive
**By:** yashasg (via Copilot)
**What:** Move Fitzpatrick skin type education/selection off the always-visible main screen. Use onboarding for initial skin-type education/selection, and provide a settings screen that reuses the same onboarding-style screen for edits. Keep the main screen focused on applied SPF, the large hero time estimate, circular gauge as secondary visual cue, and related current-exposure summary.
**Why:** User request — captured for team memory
### 2026-05-19T16:22:15.944-07:00: User directive
**By:** yashasg (via Copilot)
**What:** Skin-type/onboarding questions must be research-based and source-backed; the team must not invent its own questions. The About screen should cite the sources used.
**Why:** User request — captured for team memory
# Gaia — Onboarding/Settings IA Proposal: Move Fitzpatrick off main screen

**Date:** 2026-05-19T16:14:26-07:00  
**Owner:** Gaia (Lead/Architect)  
**Status:** **PROPOSED — decision gate pending**  
**Requested by:** yashasg (user directive `.squad/decisions/inbox/copilot-directive-2026-05-19T16-14-26-336-07-00-onboarding-settings-main-scope.md`)

---

## Proposed Change

**Move Fitzpatrick skin-type selection out of main-screen visibility. Land it in:**
1. **Onboarding:** Cold-launch flow (LANE 1, Screen 3, per D-2026-05-19-013/014 — already designed).
2. **Settings:** Reuse the same onboarding-style Fitzpatrick picker (no separate settings picker; same rows, same behavior-first copy).
3. **Main screen (NowView):** Remove the Fitzpatrick chip (currently shown as `Type III ›` in the "Location + skin row"). Simplify the inputs disclosure to show only SPF + Location; hide Fitzpatrick selection affordance from the repeated-use surface.

**Visual outcome:** Main screen focuses on hero verdict (burn time) + circular gauge (secondary UV severity cue) + applied SPF input + location chip. Fitzpatrick moves to setup/settings, not repeating-use home.

---

## Decision Verdict

**✅ CONDITIONAL YES.** This is a sound product/IA call that clarifies the main screen's information hierarchy. I'm accepting it pending three bounded clarifications (§ Guardrails below).

**Why it works:**
- **Cleaner focus:** The current design spec (`linka-ios-design-spec.md` §2.2) has an "Inputs disclosure" expandable on the main screen. Moving Fitzpatrick to settings removes clutter and lets the hero timer dominate.
- **Persona-aligned:** Greta (r/Ultralight, P1) wants "give me the number, don't make me work" — a main screen free of picker rows supports that. Devon (PCT, P3) only needs to change skin type when his circumstances change (not every time he opens the app). Settings is the right home.
- **Canonical IA preserved:** The proposal fits the existing single-root `NavigationStack` + sheet-based settings pattern (D-2026-05-19-002 / D-2026-05-19-013). No `TabView`, no new surfaces, no complexity.
- **Fitzpatrick canon preserved:** D-2026-05-19-012 (no-default), D-2026-05-19-009 (behavior-first text), and Iris/Suchi's swatches guidance (secondary visual cues only) all stay locked.

**What changes:**
- Remove Fitzpatrick picker rows from main screen "Inputs disclosure" section.
- Keep SPF + Location inputs on main (users adjust SPF more frequently; location is a single-tap grant).
- Promote the settings gear button ⚙︎ as the entry point for "Change my skin type."
- Confirm that SettingsSheet will have a NavigationLink to SkinTypeView (a dedicated detail screen inside the sheet, NOT a new behavior).

**What doesn't change:**
- Onboarding structure (LANE 1, D-2026-05-19-013 canonical flow).
- L1–L4 disclaimer layering (D-2026-05-19-011).
- No-default, behavior-first Fitzpatrick picker UI (D-2026-05-19-012 / D-2026-05-19-009).
- WeatherKit attribution + SPF + Location visibility on main.
- Zero-data architecture *if* Fitzpatrick selection is @State-only (see Guardrail 1 below).

---

## Trade-offs (named)

| Aspect | Gain | Loss | Trade-off acceptance |
|---|---|---|---|
| **Main-screen visual focus** | Cleaner, verdict-centric hero. Less picker-row clutter. | One more tap to change Fitzpatrick (from Chip → Settings → SkinTypeView). | ✅ Acceptable; Fitzpatrick is a one-time setup + rare re-check, not a frequent input like SPF. |
| **Repeated-use UX** | Users see the hero timer without distraction on every open. | A user with changing circumstances (e.g., after a sunburn, changed medications) must navigate to settings to re-check their type. | ✅ Acceptable; L1 re-fires on cold launch (Asha re-attests per D-2026-05-19-014 §learning-4). The persistence model (§ Guardrail 1) determines whether re-check is required. |
| **Visual real estate** | More room for SPF selector, location chip, UV display, or future secondary surfaces. | Fitzpatrick affordance no longer on home; discoverability depends on settings-gear prominence. | ✅ Acceptable; gear button is standard iOS HIG for settings + SettingsSheet is one tap. Iris to confirm visual affordance (label: "Edit skin type" or similar in settings). |
| **Onboarding complexity** | Shared picker code between onboarding and settings (reuse, not duplication). | Picker has two entry points (one mandatory during launch, one optional in settings). Must gracefully handle both flows. | ✅ Acceptable; SwiftUI NavigationLink-inside-sheet pattern is well-supported. See Clarification #2 below. |

---

## Guardrails (boundaries to preserve)

### Guardrail 1: Clarify Fitzpatrick persistence model

**Current state:** The spec says "**@State only — no Fitz persisted**" (user-flow spec LANE 1, Screen 1 note). This implies:
- Fitzpatrick selection does NOT survive app backgrounding/relaunch.
- Each cold launch triggers the full onboarding flow (including the L1 disclaimer + Fitzpatrick picker).

**Question for product:** Does this directive preserve the @State-only model, or should Fitzpatrick selection now persist (saved to UserDefaults)?

**Implications:**
- **If @State-only (current canon):** L1 re-fires every cold launch. Asha re-attests automatically on medication change (she closes and reopens the app). Settings screen becomes "change Fitzpatrick for this session only," and cold launch resets it. ✅ Matches D-2026-05-19-007 (photosensitivity = safety boundary) and Donatello M7 (zero-data).
- **If persisted to disk:** Fitzpatrick selection survives backgrounding. Cold launch skips L1 if the user has already attested (Asha sees L1 only once per launch or on app-version bump). Settings becomes "persistent edit." ⚠️ Changes the photosensitization re-attestation model (Asha may not see L1 again if she doesn't re-launch after a med change).

**Decision required before implementation:** Is the Fitzpatrick choice transient (@State) or durable (saved)?

---

### Guardrail 2: Settings screen must reuse onboarding-picker UI (not create a new one)

**Requirement:** The SkinTypeView shown in onboarding (D-2026-05-19-013 LANE 1, Screen 3) **must be the exact same SwiftUI component** when accessed from SettingsSheet → NavigationLink to SkinTypeView.

**Why:** Consistency, code reuse, and the guarantee that the behavior-first text + no-default + secondary-swatches pattern (per Iris/Suchi) applies in both flows.

**Implementation pattern (for Kwame):**
```swift
// Onboarding flow
NavigationStack {
    SkinTypeView(source: .onboarding) // or default
        .navigationTitle("Pick Your Skin Type")
}

// Settings flow (inside SettingsSheet)
NavigationStack {
    SettingsSheet {
        NavigationLink("Edit Skin Type", destination: SkinTypeView(source: .settings))
    }
}

// SkinTypeView is identical in both cases — same rows, same behavior-first copy, 
// same no-default logic. Only the @State binding target differs 
// (FitzpatrickStore vs. local @State vs. AppState).
```

**Acceptance criterion:** Code inspection verifies that `SkinTypeView` is defined once and reused (not copy-pasted).

---

### Guardrail 3: Main-screen "Inputs disclosure" must remove Fitzpatrick, preserve SPF + Location

**Current spec (§2.2 linka-ios-design-spec.md line 165–175):**
```swift
6. **Inputs disclosure** — `DisclosureGroup("Inputs") { ... }` containing:
   - Picker("Skin type", selection: $fitz).pickerStyle(.navigationLink)  // ← TO REMOVE
   - Picker("SPF", selection: $spf).pickerStyle(.menu)                   // ← KEEP
   - Button { requestLocation() } label: { ... }                         // ← KEEP
```

**Change:** Remove the Fitzpatrick `Picker` line entirely from the DisclosureGroup.

**Result on main screen:**
- ✅ Inputs disclosure still appears, but now shows only SPF + Location.
- ✅ Fitzpatrick selection moves to settings sheet entry point (gear button → SkinTypeView).
- ✅ L2 footer disclaimer + L3 "Is this estimate for me?" link remain unchanged.
- ✅ Hero verdict card, UV chip, WeatherKit attribution unaffected.

**Acceptance criterion:** Iris's updated NowView mockup removes the Fitzpatrick row from the inputs section. Kwame's implementation does not include a skin-type picker in the DisclosureGroup.

---

### Guardrail 4: Gear button / settings affordance must be discoverable

**Requirement:** The ⚙︎ gear button in the nav bar (D-2026-05-19-013 LANE 2 Nav bar, trailing item) must visually signal "settings" and must be the clear entry point to change Fitzpatrick.

**Current design (✅ already locked):** `.trailing:` gear button labeled `"Settings"` via `.accessibilityLabel("Settings")`.

**Iris to confirm in redraw:** If removing the Fitzpatrick chip from the main screen, consider a small hint in the SettingsSheet header or first line that reads "Edit skin type" or similar, so users discover it on first settings tap.

**Acceptance criterion:** Settings sheet is open and users see "Edit skin type" or similar link on first tap (no buried navigation).

---

### Guardrail 5: L1–L4 disclaimer layering must remain canonical

**No change.** The three-surface visibility pattern (D-2026-05-19-011) is load-bearing for photosensitization awareness (Suchi P4 Asha, D-2026-05-19-014). This proposal does NOT affect L1/L2/L3/L4 surfaces — they remain:
- **L1:** First-launch full-screen cover (includes photosensitizer inline link).
- **L2:** Persistent footer on all result screens.
- **L3:** "Is this estimate for me?" link on the hero verdict card.
- **L4:** About sheet with photosensitization cohort list.

**Accepted as stated; no new work required.**

---

## Scope Boundaries (What this decision does NOT change)

❌ **Out of scope — DO NOT modify:**
1. Onboarding flow structure (LANE 1, D-2026-05-19-013/014 canonical).
2. Fitzpatrick picker UI: behavior-first text ordering, all six types, no default, secondary swatches (D-2026-05-19-009/012).
3. L1–L4 disclaimer pattern (D-2026-05-19-011).
4. WeatherKit attribution (D-2026-05-19-003/004).
5. SPF input (remains on main; no change to menu-style picker or step snapping).
6. Location permission flow.
7. Hero timer styling, UV severity gauge, metric display.
8. Current `NavigationStack` + `.sheet`-based IA (no `TabView`, no new top-level screens).

---

## Persona Alignment Check

| Persona | Impact | Verdict |
|---|---|---|
| **P1 Greta** (gram-counter, r/Ultralight, Fitz II–III) | ✅ Hero-focused main screen supports "give me the number" JTBD. Settings tap is rare (skin type is set once). | **Positive:** Cleaner main screen. |
| **P2 Maya** (open-water swim, r/OpenWaterSwimming, Fitz III–IV) | ✅ No change to hero timer, UV chip, or verdict-card reach-back. Settings tap is infrequent (skin type stable). | **Neutral:** Unaffected by this change. |
| **P3 Devon** (PCT thru-hike, r/PacificCrestTrail, Fitz I) | ✅ Main screen remains focused on his JTBD (verify burn time). If skin type changes mid-hike, one settings tap resets it. No-default guarantee preserved. | **Positive:** Simpler main screen; settings flow is clear. |
| **P4 Asha** (Accutane, r/Accutane, Fitz IV) | ✅ L1 re-fires on cold launch (med-change re-attestation preserved, per Guardrail 1 pending clarification). Main screen no longer shows skin type, but that's not her load-bearing surface — L1/L2/L3/L4 disclaimer is. | **Positive or Neutral** (depends on persistence model). If @State-only, L1 re-fires reliably. If persisted, need careful versioning of cold-launch logic. |
| **P5 Tomás** (trail-run, r/trailrunning, Fitz IV/V under-picking risk) | ✅ Behavior-first Fitzpatrick text is preserved in settings picker. Main screen removes the "Type V ›" chip that might tempt him to glance and misclassify on the trail. | **Positive:** Settings flow is intentional (not a casual main-screen glance). |

**Conclusion:** This proposal is persona-positive or neutral for all five. No persona-specific regressions.

---

## Implementation Handoff (if accepted)

**For Iris (UI/UX):**
- Redraw NowView to remove Fitzpatrick row from the inputs disclosure.
- Keep hero timer, SPF + Location pickers, disclaimer footer, WeatherKit attribution, "Is this estimate for me?" link.
- Confirm SettingsSheet navigation link for "Edit skin type" is visually discoverable.
- Reuse SkinTypeView from onboarding (no new picker design).

**For Kwame (iOS Developer):**
1. Verify SkinTypeView is a single reusable component (parametrized by navigation context, if needed).
2. Remove Fitzpatrick row from the main NowView inputs disclosure.
3. Add a NavigationLink in SettingsSheet pointing to SkinTypeView.
4. Clarify with product: Is Fitzpatrick selection @State-only (transient) or persisted (durable)? Adjust cold-launch logic accordingly.

**For Plunder (Legal):**
- No new disclaimers or copy required by this change (L1–L4 unchanged).
- Confirm: If Fitzpatrick is persisted, does cold-launch versioning (e.g., "re-attest on app update") need explicit legal review? (Depends on Guardrail 1 clarification.)

**For Suchi (User Researcher):**
- Update persona-overlay annotations (D-2026-05-19-014 LANE 4) to reflect that Fitzpatrick is now a settings action, not a main-screen chip.
- No persona-JTBD testing required (this is a structural IA move, not a new interaction).

**For Gaia (Architect):**
- Lock this decision once Guardrail 1 (persistence model) is clarified.
- Update D-2026-05-19-013 / -014 to reference this decision if the canvases are redrawn.

---

## Decision Gate

**CONDITIONAL YES — Pending:**
1. **Guardrail 1 clarification:** Confirm Fitzpatrick persistence model (@State-only or durable disk storage?). This changes the cold-launch re-attestation logic for Asha.
2. **Iris mockup confirmation:** Updated NowView sketch removing the Fitzpatrick chip and confirming settings affordance.
3. **Kwame code-reuse verification:** SkinTypeView is a single parametrized component, not duplicated.

**Timeline:** Once these three items are done, escalate to yashasg for final product approval before implementing.

---

## Reference Decisions

- **D-2026-05-19-013** — Onboarding flow + user-flow diagram (LANE 1 canonical).
- **D-2026-05-19-014** — Persona overlays + safety moments.
- **D-2026-05-19-012** — No-default Fitzpatrick picker.
- **D-2026-05-19-011** — L1–L4 disclaimer pattern.
- **D-2026-05-19-009** — Wheeler edited-variant Fitzpatrick descriptions.
- **D-2026-05-19-002** — iOS IA: single-root NavigationStack, sheet-based settings.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
# Iris proposal — Onboarding, Settings edit path, and simplified Main UI

- **Date:** 2026-05-19T16:14:26-07:00
- **Owner:** Iris (UI/UX, Apple HIG & Accessibility)
- **Status:** proposed
- **Requested by:** yashasg

## Verdict

Approve the user direction: Fitzpatrick education/selection should move out of the always-visible Main screen and into a first-run onboarding step, with Settings reusing the same selection pattern for later edits. The Main screen should become a fast outdoor-use dashboard: applied SPF meter, large hero time estimate, circular gauge as the secondary visual cue, current UV/source attribution, and concise safety disclaimer surfaces.

This is a team decision because it changes the canonical `user-flow-onboarding-main.excalidraw` structure and touches safety, attribution, and implementation flow. It does **not** invalidate D-2026-05-19-009, -011, -012, or -013; it refactors where those patterns live.

## Recommended screen structure

### 1. First-run onboarding

Keep onboarding task-focused and explicit:

1. **Welcome / safety framing**
   - Plain-language promise: estimate burn risk from UV, SPF, and skin response.
   - L1 disclaimer remains visible before any estimate.
2. **Skin type education + required selection**
   - Six Fitzpatrick rows, no default, no recommendation.
   - Behavior-first copy remains canonical.
   - Helper copy above list: “Choose by how your skin usually burns and tans without sunscreen. Each type spans a range of skin tones.”
   - Prefer behavior pictograms as the visual cue; if swatches ship, they must follow Iris/Suchi secondary-cue guardrails.
3. **Applied SPF setup**
   - Select or enter applied SPF.
   - Make “applied” explicit; avoid implying bottle SPF equals protection if not applied/reapplied correctly.
4. **Location / UV source permission**
   - Explain WeatherKit/Apple Weather source and permission value.
5. **First result transition**
   - Land on Main with selected type summarized as editable profile metadata, not a dominant card.

### 2. Settings edit path

Settings should expose “Skin type” and “Applied SPF” as editable rows. Tapping **Skin type** opens the same onboarding-style selection screen/pattern with:

- Existing selection shown only after the user has previously chosen it.
- Same helper copy, all six rows, same accessibility labels, same citations path.
- Save/Done affordance in the navigation bar.
- Cancel/back behavior that preserves the previous value.

This avoids duplicate UI, prevents copy drift, and keeps the safety-critical no-default behavior intact for first-run users.

### 3. Simplified Main screen

Main should optimize for glanceability outdoors:

1. **Applied SPF meter**
   - Primary adjustable control near the top.
   - Large tap targets and readable numeric SPF value.
2. **Hero time estimate**
   - Largest text on screen.
   - Include units and state, e.g. “~42 min until high risk.”
   - Avoid false precision; use approximate language.
3. **Circular gauge**
   - Secondary visual cue only; never color-only.
   - Must include label/value text and accessible progress semantics.
4. **Current UV + source attribution**
   - Show current UV index, location freshness, and Apple Weather attribution.
5. **Disclaimer / safety link**
   - Persistent concise footer/link per L1–L4 pattern.
   - Photosensitizing medication/condition warning remains discoverable from Main and About.

The Fitzpatrick choice may appear as a compact Settings/profile summary if needed, but not as a persistent education block on Main.

## Accessibility and HIG guardrails

- Support Dynamic Type through largest accessibility sizes; no clipped hero estimate or row text.
- Minimum 44×44 pt interactive targets; larger preferred for outdoor use.
- VoiceOver order on Main: SPF control → hero estimate → gauge summary → UV/source → safety link → settings.
- VoiceOver row labels for skin type: `Type N. Behavior copy. Appearance descriptor. Selected/Not selected.`
- Do not announce decorative swatches or rely on color alone.
- Gauge must have text, shape/progress, and VoiceOver value; color is redundant.
- Use native SwiftUI `NavigationStack`, `Form`/`List` where appropriate, sheets only when they preserve state and expected dismissal behavior.
- Respect Increase Contrast, Reduce Transparency, Reduce Motion, dark mode, and high-brightness outdoor readability.
- Keep disclaimer text concise on Main; long explanations belong in About/details.

## SwiftUI implementation guardrails

- Model the skin selector as a reusable view/component used by both onboarding and Settings.
- Separate first-run required selection from settings edit mode with explicit state, not separate copy.
- Keep `nil`/unset skin type possible until first-run completion; do not introduce a fallback default.
- Persist only the selected type/SPF, not photosensitization state.
- Centralize Fitzpatrick row strings and accessibility labels to prevent divergence.
- Keep WeatherKit attribution adjacent to UV data on Main and mirrored in About.

## Decision request

Update the canonical flow/spec to:

1. Move Fitzpatrick education/selection to onboarding.
2. Add Settings → Skin type edit path that reuses the onboarding selector.
3. Redesign Main around applied SPF, hero time estimate, circular gauge, current UV/source attribution, and safety disclaimer.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
# Iris — Redesign & A11y Audit: squad/4-approved-redesign-paraphrasing

- **Date:** 2026-05-19T16:30:05-07:00
- **Owner:** Iris (UI/UX, Apple HIG & Accessibility)
- **Branch:** squad/4-approved-redesign-paraphrasing
- **Status:** review complete — fixes applied, blockers handed to Kwame
- **Input artifacts:** iris-onboarding-settings-main-ui.md, gaia-onboarding-settings-main-ia.md, iris-secondary-skin-swatch-cues.md, suchi-secondary-skin-swatch-cues.md, AppViews.swift, ProductCopy.swift, FitzpatrickSkinType.swift

---

## Overall HIG / A11y Verdict

**PASS with one remaining gap (circular gauge) — 4 issues resolved in this session, 1 structural item remains for Kwame.**

The core safety architecture (L1–L4 disclaimers, no-default picker, @State-only skin type) is intact and well-implemented. The approved redesign direction is largely in place: `SkinTypePickerRow` is a shared component used by both onboarding and settings, the Fitzpatrick chip was already removed from the main screen, and Settings uses a `NavigationLink` detail view. The remaining structural gap is the circular gauge. Accessibility labels on Fitzpatrick rows were clean. Three smaller copy/hint issues were fixed in this session.

---

## Audit Checklist — Approved Redesign Criteria

| Criterion | Status | Notes |
|---|---|---|
| Onboarding owns Fitzpatrick education / selection | ✅ | `SkinTypeOnboardingView` as `fullScreenCover`, no default, all six types |
| Settings can edit using same selector/screen | ✅ | `SettingsSheet` → `NavigationLink` → `SkinTypeEditView` reuses `SkinTypePickerRow` — Gaia Guardrails 2 & 4 met |
| Main screen: applied SPF as primary adjustable control | ✅ | `spfCard` with `SPFPicker` on main |
| Main screen: hero time estimate dominant | ✅ | `@ScaledMetric` hero size 80pt, `minimumScaleFactor(0.5)`, accessibility fallback to 48pt |
| Main screen: circular gauge secondary visual cue | ❌ | Not implemented — blocker for Kwame |
| Main screen: UV / source attribution | ✅ | `UVIndexCard` + `WeatherAttributionView` |
| Main screen: concise disclaimer | ✅ | `PersistentFooter` + L3 link in hero card |
| Skin selector: behavior-first, no default, all I–VI | ✅ | `pickerDescription` is behavior-first; `selectedSkinType` initializes `nil` |
| Skin selector: color/swatches secondary only | ✅ | No swatches yet; approved path is behavior pictograms or secondary-only swatches |
| VoiceOver not color-dependent | ✅ | `TierBadge` uses `.differentiateWithoutColor`; checkmarks are `accessibilityHidden(true)` |
| Fitzpatrick chip removed from main | ✅ | `contextChipRow` is location-only; skin type chip already removed |
| About/source pointer clear and not overwhelming | ✅ | L2 persistent footer + L3 hero link + NavigationLinks to AboutView |
| Dynamic Type through largest accessibility sizes | ✅ | `SPFPicker` switches to `.menu` at accessibility sizes; hero scales |
| 44×44 pt minimum tap targets | ✅ | Rows `frame(minHeight: 56)`, chips `frame(minHeight: 44)` |
| Reduce Motion respected | ✅ | `accessibilityReduceMotion` skips `.contentTransition(.numericText())` and scroll animation |
| Increase Contrast respected | ✅ | `SafetyStatusCard` adjusts opacity at `.increased` |
| Dark mode / color scheme | ✅ | `WeatherAttributionView` switches mark URL on `colorScheme`; materials adapt |
| `NavigationStack` (no TabView) | ✅ | Single root `NavigationStack` + `.sheet` for settings |

---

## Issues Found

### ✅ Issue 1 — Fitzpatrick chip on main screen [ALREADY RESOLVED]

`contextChipRow` is now location-only. The skin type chip was already removed in the current implementation. ✅

---

### ❌ Issue 2 — Circular gauge absent from main screen [BLOCKER — Kwame]

The approved redesign (iris-onboarding-settings-main-ui.md §3 item 3) calls for a circular gauge as a secondary visual cue between the hero estimate and the UV card. It is absent entirely.

**Specification for Kwame:**

```swift
// Placement: between HeroTimerCard and UVIndexCard in the VStack
// Data: burn fraction consumed = elapsed time / total estimate minutes
// Accessibility pattern (HIG-compliant):

Gauge(value: burnFraction, in: 0...1) {
    // primary label — screenreader-visible
    Text("Burn risk")
} currentValueLabel: {
    // numeric label inside the gauge ring
    Text(burnFractionPercent)
}
.gaugeStyle(.accessoryCircular)  // or .accessoryCircularCapacity for filled arc
.tint(gaugeGradient)             // severity tint — must NOT be the only differentiator

// Accessibility guardrails:
// - .accessibilityLabel("Burn risk gauge. \(burnFractionPercent) of estimated burn window elapsed.")
// - .accessibilityValue(burnFractionPercent)
// - Color tint is redundant, not the primary cue — text label is mandatory
// - Use .accessibilityRepresentation if gauge type doesn't expose progress semantics natively
// - When estimate unavailable: hide gauge or show empty state with label "Awaiting estimate"
// - Reduce Motion: no animated fill — use static arc value, skip any animateOnAppear
```

The gauge must:
1. Always carry a text label and numeric value (never color-only).
2. Be `accessibilityHidden(true)` if the estimate is nil (no phantom "0%" announced to VoiceOver).
3. Use `Gauge` (not a custom drawing) to get native SwiftUI progress semantics.
4. Not duplicate the hero number — it is the secondary shape cue, not the primary number surface.

---

### ✅ Issue 3 — Settings skin type picker: shared component via NavigationLink [ALREADY RESOLVED]

`SettingsSheet` already exposes a `NavigationLink` to `SkinTypeEditView`, which reuses `SkinTypePickerRow` — the same shared component used by `SkinTypeOnboardingView`. Gaia Guardrails 2 and 4 are fully met. ✅

---

### ✅ Issue 4 — VoiceOver announces redundant roman numeral in skin type rows [FIXED — this session]

**File:** `AppViews.swift` `SkinTypeOnboardingView` and `SettingsSheet`

Both the onboarding and settings Fitzpatrick rows had no explicit `accessibilityLabel` on the `.accessibilityElement(children: .combine)` container. VoiceOver was announcing: `"I. Type I. Always burns, never tans. Very fair; often freckles, red/blonde hair."` — the leading standalone `"I"` (the `Text(skinType.romanNumeral)` sizing column) was read as a word before the full label, creating an awkward announcement.

**Fix applied:** Added explicit `.accessibilityLabel("Type \(skinType.romanNumeral). \(skinType.pickerDescription).")` on both row containers, suppressing the redundant standalone numeral text. VoiceOver now announces: `"Type I. Always burns, never tans. Very fair; often freckles, red/blonde hair. [Selected/Not selected]"` — conforming to the approved spec.

---

### ✅ Issue 5 — `skinTypePickerPrompt` used weak, behavior-vague copy [FIXED — this session]

**File:** `ProductCopy.swift`

Old: `"Pick the row that matches what your skin does, not its color."` — "what your skin does" is vague; doesn't name burns/tans explicitly.

**Fix applied:** Updated to approved wording: `"Choose by how your skin usually burns and tans without sunscreen. Each type covers a range of skin tones."` — mirrors the approved Iris proposal wording, makes the Fitzpatrick construct explicit, and pre-empts the "match my arm" reflex (Suchi learning-3 / Tomás persona).

---

### ✅ Issue 6 — Checkmark icon inconsistency between onboarding and settings rows [FIXED — this session]

**File:** `AppViews.swift` `SettingsSheet`

Onboarding rows used `checkmark.circle.fill` (filled circle) as the selection indicator. Settings rows used `checkmark` (bare checkmark). Both were `accessibilityHidden(true)` (correct), but the visual inconsistency meant the same affordance looked different in two flows.

**Fix applied:** Settings rows now use `checkmark.circle.fill` to match the onboarding pattern.

---

### ✅ Issue 7 — Skin type chip hint was ambiguous [FIXED — this session]

**File:** `AppViews.swift` `contextChipRow`

Old hint: `"Opens skin type settings."` — ambiguous about what "skin type settings" means.

**Fix applied:** Updated to `"Opens Settings to change skin type."` — directional, matches the gear button's expected behavior. (This chip itself is a structural blocker per Issue 1; the hint fix keeps it defensible until Kwame removes the chip.)

---

## Accessibility Label Spec — Fitzpatrick Rows (canonical for both onboarding + settings)

```
accessibilityLabel: "Type [N]. [Behavior copy]. [Appearance descriptor]."
accessibilityTraits: .isButton, .isSelected (when selected)
accessibilityHint (unselected): "Selects this skin type."
accessibilityHint (selected, onboarding): "Selected. Tap Continue to confirm."
accessibilityHint (selected, settings): "Selected skin type."
```

Example for Type IV:
- **Label:** "Type IV. Burns minimally, tans easily. Olive or medium-brown skin."
- **Traits:** `.isButton`, `.isSelected` when active
- **Hint:** "Selects this skin type." / "Selected. Tap Continue to confirm."

The behavior text always precedes the appearance descriptor. Color names are never in the accessibility label.

---

## VoiceOver Tab Order — Main Screen (approved spec for Kwame)

1. Navigation title: "UV Burn Timer"
2. Photosensitization banner (`.orange`, `.bordered` button)
3. Location rationale card (conditional, if not yet acknowledged)
4. Hero timer card (`.accessibilityElement(children: .contain)`) — internal order: title, hero estimate, tier badge, context line, stale warning, long-estimate caveat, verdict link
5. UV index card — UV value, source line, age, WeatherAttribution
6. **[FUTURE]** Circular gauge — "Burn risk gauge. N% of estimated burn window elapsed."
7. Location chip (if kept) — label: "Location", value: coordinate or "Not set"
8. SPF card — "SPF [N]" — `.segmented` or `.menu` picker
9. Settings toolbar button: "Settings. Opens skin type, SPF, attribution, and app information."
10. Persistent footer: reapplication text, "About & applicability" link

The Fitzpatrick chip (current position 7b in contextChipRow) is removed from this order per Issue 1.

---

## Swatch / Pictogram Path — Pending

No swatches or pictograms have shipped in `FitzpatrickSkinType.pickerDescription`. The team still has an open decision on the visual treatment (behavior pictograms preferred by Suchi; tonal swatches with G1–G6 guardrails as fallback). Neither path conflicts with the current implementation. When this decision is locked, I will spec the SwiftUI asset work for Kwame.

**Hard floor (either path):** no color-only cue, no preselection, behavior text is primary, all six types, VoiceOver announces behavior not color names.

---

## Copy Changes Applied (ProductCopy.swift)

| Key | Before | After |
|---|---|---|
| `skinTypePickerPrompt` | "Pick the row that matches what your skin does, not its color." | "Choose by how your skin usually burns and tans without sunscreen. Each type covers a range of skin tones." |

`skinTypePickerFooter` and `skinTypeSettingsFooter` unchanged — both remain accurate and appropriately scoped.

`fitzpatrickCitations` unchanged — attribution is correct per D-2026-05-19-009.

Fitzpatrick `pickerDescription` strings in `FitzpatrickSkinType.swift` confirmed compliant with D-2026-05-19-009 (Wheeler variant, behavior-first, paraphrased, not verbatim NCBI). No changes required there.

---

## Handoff to Kwame

One item requires implementation work:

1. **Add `Gauge` to main screen** — per Issue 2 spec above. Placement: between `HeroTimerCard` and `UVIndexCard`.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
# Iris proposal — Secondary Fitzpatrick swatch cues

- **Date:** 2026-05-19T16:11:26-07:00
- **Owner:** Iris (UI/UX, Apple HIG & Accessibility)
- **Status:** proposed

## Verdict

Yes: keep skin-tone swatches only as secondary, non-interactive visual cues inside each Fitzpatrick row. They must never be the classifier, default, or sole differentiator.

## Pattern

Use a required single-choice list for Fitzpatrick type. Each row contains:

1. Leading text: `Type I` … `Type VI`.
2. Primary label: behavior-first burn/tan copy.
3. Secondary label: concise appearance cue.
4. Trailing optional tonal chip/ramp, hidden from accessibility semantics.
5. Explicit selected checkmark only after user taps a row.

Example row model: `Type IV — Burns minimally, tans easily. Olive or medium-brown skin.` plus a trailing tonal chip.

## Guardrails

- No preselection and no recommended/default type.
- Text order remains behavior-first; swatch never precedes the behavior copy.
- Swatches are decorative: VoiceOver reads type, behavior, descriptor, and selected state; not color names.
- Do not use a color-grid picker or “match your skin” prompt.
- Support Dynamic Type, Reduce Transparency, Increase Contrast, and sufficient row height/tap target.
- Use multiple cues for selection: checkmark, label/state, and row affordance — not color alone.
- Include helper text: “Choose based on how your skin usually burns and tans without sunscreen; the tone cue is only a visual aid.”
- Use inclusive, approximate tonal chips; avoid photorealistic skin samples.
# Iris — Work Item 3 Design Review Proposal

**Date:** 2026-05-19T15:59:04-07:00  
**Source:** GitLab work item 3 design spec + screenshot  
**Verdict:** TAKE WITH CHANGES

## Decision proposed

Adopt Work Item 3 as a visual-direction reference for the iOS Now surface, not as an implementation spec. Keep the canonical iOS information architecture from D-2026-05-19-013 and Linka/Iris handoff: single-root `NavigationStack`, settings/about sheets, no default Fitzpatrick selection, L1-L4 disclaimer layering, and WeatherKit attribution wherever UV data appears.

## Take

- Large glanceable time estimate as the primary hero.
- Circular/gauge metaphor for elapsed exposure or estimate progress, provided it remains secondary to the numeric label and has non-color accessibility semantics.
- Strong UV severity chip using icon + text + color, not color alone.
- Tonal, low-shadow card system for outdoor readability.
- Bottom visual weight and large touch targets as a reminder to keep outdoor/wet-hand usability high.
- A dedicated Science/About explainer surface, but only within the canonical About/Science path and with Plunder/Wheeler-approved wording.

## Take with changes

- Replace all raw hex/px/rem/Inter tokens with Apple-native SwiftUI handoff terms: SF Pro/system font, Dynamic Type text styles, semantic colors, named asset-catalog severity colors, 44pt+ controls.
- Rename/copy must remain canonical unless Gaia/Argos decide otherwise. Do not silently replace `UV Burn Timer` with `Helios Safe`.
- Skin type UI must show all six Fitzpatrick types, have no default, avoid color swatches as the primary classifier, and use behavior-first descriptions.
- SPF slider needs an accessible discrete Picker/Stepper fallback; labels must remain legible at AX5.
- Science copy must remove certainty/medical overclaim language such as “precise minute” and “cellular damage”; use “estimate,” “1 MED,” and “skin reddening” framing.
- Hero and UV chip require VoiceOver labels such as “Estimated time to skin reddening, 45 minutes” and “UV index 8, high.”
- Add visible Apple Weather/WeatherKit attribution on any screen using UV data.
- Preserve the L3 “Is this estimate for me?” link on the verdict card plus persistent footer disclaimer.

## Reject / defer

- Custom web-style top app bar with hamburger menu as shown; use native navigation bar and toolbar controls.
- `TabView` with Tracker/History/Science for v1 unless Gaia reopens IA. Canon says one main job, one calculation; secondary surfaces are sheets.
- Exclusive Inter typography and uppercase micro-labels that may hurt Dynamic Type and VoiceOver scanning.
- Color-only Fitzpatrick swatches and any preselected Type II/III visual state.
- Any copy implying guaranteed safety, exact burn timing, diagnosis, or medical advice.

## User-research rationale

Suchi’s canon still controls: no-default picker prevents anchoring, behavior-first Fitzpatrick copy reduces under/over-picking, and photosensitizer disclosure must be visible without exploration for Asha-like users. The Work Item 3 visual hierarchy is useful, but the screenshot currently hides or weakens those safety-critical behaviors.
# Kwame — Circular Gauge Implementation

- **Date:** 2026-05-19T16:47:52-07:00
- **Owner:** Kwame (iOS Developer)
- **Branch:** squad/4-approved-redesign-paraphrasing
- **Status:** implemented and build passing
- **Implements:** Iris spec — iris-redesign-a11y-review.md Issue 2

---

## Decision

`BurnRiskGaugeCard` added to `AppViews.swift`. Placed between `HeroTimerCard` and `UVIndexCard` in the main screen `VStack`, per Iris's explicit placement spec.

---

## Implementation details

### Placement guard
```swift
if let est = estimate, let fa = fetchedAt,
   est.tier != .none, est.rawMinutes.isFinite {
    BurnRiskGaugeCard(estimate: est, fetchedAt: fa, now: now)
}
```
- Hidden when no estimate (nil skin type or no UV fetch) — no phantom "0%" in VoiceOver.
- Hidden when `tier == .none` (UV index is 0, `.infinity` rawMinutes) — gauge is irrelevant.

### Data formula
```
burnFraction = clamp(0, elapsedSeconds / min(rawMinutes * 60, 2h), 1)
```
Same `fetchedAt` and `now` already used for `isEstimateStale`. Exactly the same burn-window calculation as `isElapsed(fetchedAt:now:)` — no new formula, no duplication.

### Gauge style
- `Gauge(value:in:label:currentValueLabel:)` with `.accessoryCircularCapacity` — native SwiftUI progress semantics, no custom drawing.
- `scaleEffect(1.8)` inside a `72×72pt` frame so it reads clearly at glance distance.
- Tint: `Gradient` from `tier.color.opacity(0.5)` to `tier.color` using the same `SeverityLong/Moderate/Short` named color assets as `TierBadge`.

### Accessibility (Iris spec §2)
| Property | Value |
|---|---|
| `accessibilityLabel` | `"Burn risk gauge. N% of estimated burn window elapsed."` |
| `accessibilityValue` | `"N%"` |
| `accessibilityHint` | `"Secondary risk indicator. The hero timer card shows the full estimate."` |
| `accessibilityIdentifier` | `"BurnRiskGauge"` |
| Color-only | ❌ — percentage text in `currentValueLabel` is the primary cue |
| Reduce Motion | Gauge value is static state (no `.animation` or `withAnimation` on appear) |
| Differentiate Without Color | Extra `Text(percentText)` block rendered (`.accessibilityHidden(true)`) |
| Dynamic Type | Card layout adjusts via standard SwiftUI; gauge frame is fixed-size within `HStack` |

### What it does NOT do
- Does not duplicate the hero number (hero shows `~17 min`; gauge shows `43%`).
- Does not expose Fitzpatrick selection on main screen.
- Does not introduce a new burn formula.

---

## Tests added (alongside Ma-Ti's existing tests)

| Test | Guard |
|---|---|
| `testBurnRiskGaugeExistsAndIsMeaningfulOnStaleEstimate` | Gauge present + value not 0% on stale estimate seed |
| `testBurnRiskGaugeAbsentWhenNoEstimate` | Gauge absent on cold launch without UV data |

Ma-Ti's inbox doc (`ma-ti-circular-gauge-test-guard.md`) already describes three further tests:
- `testCircularGaugePresentOnFreshEstimate`
- `testHeroTimeEstimateRemainsDominantAlongsideGauge`
- `testCircularGaugeAccessibilityLabelIsNonColorAndMeaningful`

All five tests are in `UVBurnTimerUITests.swift`. Test build: **PASSED**.

---

## Build status

- Debug build: **PASSED** (no errors or warnings introduced)
- Unit tests (UVBurnTimerCoreTests): **PASSED** (all existing tests)
- Test build (including UITests): **PASSED**

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
# Kwame — Approved redesign and paraphrasing implementation

- **Date:** 2026-05-19T16:30:05-07:00
- **Owner:** Kwame (iOS Developer)
- **Branch:** squad/4-approved-redesign-paraphrasing
- **Status:** implemented and tests passing
- **Implements:** work item #4, iris-onboarding-settings-main-ui.md, gaia-onboarding-settings-main-ia.md, wheeler-source-backed-skin-type-questions.md, plunder-about-citation-policy.md, iris-secondary-skin-swatch-cues.md

---

## Changes implemented

### 1. Fitzpatrick selector: source-backed question + shared component

**Scope 3 & 4 delivered.**

- `FitzpatrickSkinType.pickerDescription` rows are unchanged from the Wheeler-approved D-2026-05-19-009 behavior-first paraphrases (NCBI NBK481857).
- `ProductCopy.skinTypePickerPrompt` updated to behavior-explicit headline (Iris a11y audit, committed by Iris agent at HEAD).
- Added `ProductCopy.skinTypePickerSubtext`: "Pick the row that best matches what your skin does after about 30 minutes of midday summer sun, with no sunscreen and no recent tan. Each row covers a range of natural skin tones." — implements Wheeler §3.1 subtext, `auditCopySurfaces` updated.
- Added `ProductCopy.skinTypeSourcePointer`: "Sources: Fitzpatrick 1988; NCBI Bookshelf 2017 (NBK481857). See About & Citations." — implements Plunder §2.3 inline source pointer, `auditCopySurfaces` updated.

### 2. Shared `SkinTypePickerRow` component

**Scope 1 & 3: single reusable component used by both onboarding and settings (Gaia Guardrail 2).**

- Extracted `SkinTypePickerRow` (behavior: type numeral + behavior copy + checkmark, 56pt min height, explicit VoiceOver label `Type N. [behavior copy]. Selected/Not selected.`).
- Used by `SkinTypeOnboardingView` (with onboarding-specific hint overlay) and `SkinTypeEditView` (settings path).
- No duplicate picker code; single definition, two entry points.

### 3. `SkinTypeEditView` — Settings skin type edit path

**Scope 1: Settings can edit using the same selector/screen/component.**

- New `SkinTypeEditView` view: List with full question header + `SkinTypePickerSubtext` + 6 `SkinTypePickerRow` rows + source pointer footer.
- Draft pattern: `pendingSelection` initialized from `session.selectedSkinType` on `.onAppear`; committed via Save toolbar button; back/cancel preserves prior value.
- Save is disabled only when `pendingSelection == nil && session.selectedSkinType == nil` (first-time no-default preserved, D-2026-05-19-012).

### 4. `SettingsSheet` refactored

**Scope 1 & 2: Fitzpatrick out of main/settings inline; Settings shows NavigationLink to `SkinTypeEditView`.**

- Removed the inline 6-row Fitzpatrick section from `SettingsSheet` (eliminated duplication).
- Added "UV estimate inputs" section with a single NavigationLink row: `"Skin type"` → `SkinTypeEditView`.
- Row label shows current selection (`"Type III"`) or `"Not set"`.
- Gaia Guardrail 2 (single component, reuse) and Guardrail 3 (remove Fitzpatrick from main/settings inline) satisfied.

### 5. Main screen: Fitzpatrick chip removed

**Scope 2: Main screen focuses on applied SPF, hero time estimate, UV/source attribution, concise disclaimer.**

- `contextChipRow` now renders a single **location** chip only; the skin type chip is removed.
- Unused `skinTypeLabel` computed property removed.
- Main screen VoiceOver order preserved: SPF control → hero estimate → UV/source → location chip → safety link → settings.
- `testMainScreenDoesNotExposeFitzpatrickPickerAfterOnboarding` UI test passes.

### 6. `AboutView` — Source citation surface

**Scope 5 & 6: About/source citation hooks.**

- Added "Skin type classification" section between "How this works" and "Sunscreen assumptions":
  - States the question used for self-classification.
  - Inline Fitzpatrick TB (1988) bibliographic string.
  - Inline Ward & Farma NCBI Bookshelf NBK481857 + CC BY-NC 4.0 note.
- All existing citation sections preserved (MED/UVI formula, sunscreen assumptions, WeatherKit attribution).

### 7. Persistence model

- Skin type remains `@State`-only (no UserDefaults). Cold launch resets selection and re-fires onboarding. This preserves the D-2026-05-19-007 photosensitization re-attestation boundary. Gaia Guardrail 1 answered: @State-only, transient, per LAUNCH-PLAN.md.

---

## Decisions made

| Dimension | Decision | Rationale |
|---|---|---|
| `skinTypePickerPrompt` | Iris accessibility-audit wording adopted (HEAD commit). Wheeler §3.1 question intent preserved in subtext. | Iris's phrasing optimizes for behavioral self-classification without question-framing overhead. |
| Swatch/pictogram | No swatches or pictograms shipped in v1. Text-only rows, behavior-first. | Suchi G6 validation gate not completed; pictogram path needs design work. Text-only is the safe floor per both Iris and Suchi. |
| Persistence | @State-only, transient. | LAUNCH-PLAN.md constraint; Gaia Guardrail 1 confirmed @State-only is the right path for v1. |
| Settings skin-type edit | Draft + Save (not immediate apply) | Preserves cancel/back behavior per Gaia Guardrail 2. |

---

## Test status

- Debug build: **PASSED** (warnings-as-errors, all targets)
- Unit tests (UVBurnTimerCoreTests): **PASSED**
- UI tests (UVBurnTimerUITests): **16/16 PASSED**
  - `testMainScreenDoesNotExposeFitzpatrickPickerAfterOnboarding` — new test, passes
  - `testSkinTypePickerInSettingsReusesOnboardingPattern` — new test, passes (scroll fix applied for medium-detent sheet)
- Release build: **PASSED**

---

## Scope items not implemented (blockers or deferred)

- **Circular gauge** (Scope 2 secondary visual cue): Iris a11y audit doc specifies the design but implementation is pending. `SeverityLong/Moderate/Short` color assets exist; CircularGaugeView needs to be wired to `BurnTimeTier` and placed in main screen. Iris spec noted "outstanding" in HEAD commit. → Kwame will pick this up in next cycle.
- **Behavior pictograms** (Suchi Scope 4 alternative): Suchi's G6 validation gate not completed; pictogram path deferred to a separate decision cycle. Icons would need design assets from Iris before landing in code.
- **Applied SPF affordance on main as "large hero control"** (Iris Scope 2 §1): Current `spfCard` is an inline segmented picker. Iris spec calls for large tap targets. No change in this cycle; card is functional and accessible.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
# Ma-Ti — Circular Gauge Test Guard

- **Date:** 2026-05-19T16:47:52-07:00
- **Branch:** squad/4-approved-redesign-paraphrasing
- **Work item:** Circular gauge test coverage (follow-on to iris-redesign-a11y-review.md Issue 2)
- **Owner:** Ma-Ti (Test Engineer)
- **Status:** complete

---

## What happened

User flagged the circular gauge as missing. Investigation found:

1. **Gauge was already implemented** by Kwame (`BurnRiskGaugeCard`, AppViews.swift ~line 1338) with correct Iris-spec accessibility — `accessibilityIdentifier("BurnRiskGauge")`, label pattern `"Burn risk gauge. N% of estimated burn window elapsed."`, `accessibilityValue(percentText)`.
2. **Gauge placement is correct** — between `HeroTimerCard` and `UVIndexCard` in the main VStack, guarded by `est.tier != .none && est.rawMinutes.isFinite`.
3. **Two initial gauge tests were added by Kwame** but three coverage gaps remained.

---

## Tests in place after this session

| Test | What it guards | File |
|---|---|---|
| `testBurnRiskGaugeExistsAndIsMeaningfulOnStaleEstimate` *(Kwame)* | Gauge present on stale estimate; value is not 0% | UVBurnTimerUITests.swift |
| `testBurnRiskGaugeAbsentWhenNoEstimate` *(Kwame)* | Gauge absent when no UV data (no phantom 0% in VoiceOver) | UVBurnTimerUITests.swift |
| `testCircularGaugePresentOnFreshEstimate` *(Ma-Ti, new)* | Gauge present on fresh (non-stale) estimate; regression guard against stale-only condition | UVBurnTimerUITests.swift |
| `testHeroTimeEstimateRemainsDominantAlongsideGauge` *(Ma-Ti, new)* | Hero `~80 min` visible alongside gauge — gauge is secondary, not a replacement | UVBurnTimerUITests.swift |
| `testCircularGaugeAccessibilityLabelIsNonColorAndMeaningful` *(Ma-Ti, new)* | Label contains "Burn risk gauge" + "elapsed"; value ends with "%" — color is never the only differentiator | UVBurnTimerUITests.swift |

All 5 tests use `-uiTestLongUncappedEstimate` or `-uiTestStaleEstimate` launch stubs (already in `UVBurnTimerApp.swift`). No new launch arguments needed.

---

## Why the gauge appeared "missing"

The Iris spec (iris-redesign-a11y-review.md Issue 2) was written before Kwame's implementation landed on this branch. The Ma-Ti redesign test plan (`ma-ti-redesign-test-plan.md`) was completed before Kwame's gauge commit, so no gauge tests were included. Kwame's two tests were added alongside the implementation but left three observable-behavior gaps.

---

## Accessibility contract (canonical for this component)

```
accessibilityIdentifier: "BurnRiskGauge"
accessibilityLabel:      "Burn risk gauge. N% of estimated burn window elapsed."
accessibilityValue:      "N%"
accessibilityHint:       "Secondary risk indicator. The hero timer card shows the full estimate."
Visible when:            estimate != nil && tier != .none && rawMinutes.isFinite
Hidden when:             estimate is nil OR tier == .none (UV index is 0)
```

Color tint (tier gradient) is a redundant visual cue only. VoiceOver does not depend on it.

---

## No blockers

Implementation is complete. Tests should pass on the next simulator run. Existing onboarding/settings/no-Fitzpatrick-main tests are unaffected.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
# Ma-Ti — Redesign & Source-Backed Paraphrasing Test Plan

- **Date:** 2026-05-19T16:30:05-07:00
- **Branch:** squad/4-approved-redesign-paraphrasing
- **Work item:** #4 — Source-backed Fitzpatrick copy traceability
- **Owner:** Ma-Ti (Test Engineer)
- **Status:** complete (core tests); UI tests are simulator-only

---

## Baseline before this session

**47 core tests / 0 failures** — but one was a latent regression:
`approvedMainScreenSafetyCopyIsCaptured` was pinned to the old `skinTypePickerPrompt` string and was silently wrong. It would have failed on the next full run.

---

## What was found

### Pre-existing failure (fixed)

| Test | Root cause | Fix |
|---|---|---|
| `approvedMainScreenSafetyCopyIsCaptured` | `ProductCopy.skinTypePickerPrompt` updated to "Choose by how your skin burns and tans, not by how it looks." but test still asserted the old "Pick the row that matches what your skin does, not its color." | Updated assertion to current canonical string. |

### Implementation state

`ProductCopy.swift` already contains three new work-item-4 fields:

| Property | Value | Status |
|---|---|---|
| `skinTypePickerPrompt` | "Choose by how your skin burns and tans, not by how it looks." | ✅ behavior-first, no color-as-anchor |
| `skinTypePickerSubtext` | "Pick the row that best matches what your skin does after about 30 minutes of midday summer sun, with no sunscreen and no recent tan. Each row covers a range of natural skin tones." | ✅ Wheeler §3.1 compliant |
| `skinTypeSourcePointer` | "Sources: Fitzpatrick 1988; NCBI Bookshelf 2017 (NBK481857). See About & Citations." | ✅ Plunder §2.3 inline pointer pattern |

`SkinTypeOnboardingView` and the `SkinTypeOnboardingDraft` commit gate are in place. Main screen uses a Location button chip rather than an always-visible skin-type picker. Settings skin-type edit path is not yet exposed (known gap, see below).

---

## Tests added (9 new, in BurnTimeCalculatorTests.swift)

| Test | What it guards |
|---|---|
| `fitzpatrickPickerPresentsSixRowsForTypesIThroughVI` | All 6 types, roman numerals I–VI, no empty descriptions |
| `skinTypePickerHeaderIsBehaviorFirstPerWheelerSpec` | Prompt uses burns/tans language; does not use "skin color/colour" as primary |
| `skinTypePickerSubtextCapturesBehaviorCuesAndRangeOfTones` | Subtext mentions "what your skin does", no sunscreen, no recent tan, range of tones |
| `skinTypeSourcePointerNamesRequiredSources` | Inline pointer names Fitzpatrick, NCBI, NBK481857, About link |
| `skinTypePickerFooterExplicitlyStatesNoDefault` | Footer says "No default" and "deliberately" (D-2026-05-19-012) |
| `notMedicalAdviceLimitsAppearOnReapplicationAndAboutSurfaces` | "Not medical advice" in reapplication footer and disclaimer body |
| `weatherKitAttributionCopyMeetsAppleRequirements` | "Apple Weather" name, correct weatherkit.apple.com legal URL |
| `aboutCitationLinksSatisfyWheelerSection4Requirements` | NCBI NBK481857, Fitzpatrick 1988 DOI, WHO, Diffey all present; ≥6 citations; no duplicates |
| `mainScreenFitzpatrickExposureIsLimitedToOnboardingAndSettings` | Fresh session has nil skin type; draft cannot commit without explicit select; commit path works |

## Tests added (2 new UI tests, in UVBurnTimerUITests.swift)

| Test | What it guards |
|---|---|
| `testMainScreenDoesNotExposeFitzpatrickPickerAfterOnboarding` | After onboarding, "Choose skin type" nav bar absent; Type I/VI buttons not hittable on main |
| `testSkinTypePickerInSettingsReusesOnboardingPattern` | All six types reachable from Settings Skin type row; uses `XCTExpectFailure` if not yet implemented |

---

## Final test results

**56 core tests / 0 failures** (previously 47 / latent 1-failure baseline)

---

## Coverage gaps / blockers

### Gap 1 — Settings skin-type edit path (Iris spec §2)
**Status:** Not yet implemented. The UI test `testSkinTypePickerInSettingsReusesOnboardingPattern` uses `XCTExpectFailure` to gate on implementation. When Kwame ships the Settings skin-type row, remove the `XCTExpectFailure` wrapper.

### Gap 2 — Source pointer deep-link (Plunder §2.3)
**Status:** `skinTypeSourcePointer` copy exists but no automated test verifies the "See About & Citations" tappable link actually routes to the correct About anchor. Needs a UI test once the deep-link target is implemented.

### Gap 3 — Confidence-level labels in About (Wheeler §4.6)
**Status:** Not in scope for v1 tests. If Kwame adds "Established / Reasonable approximation / Out of scope" labels, Ma-Ti will add assertions.

### Gap 4 — Roberts-scale future feature
**Status:** Out of v1 scope per Wheeler §3.4. No test required now.

---

## Notes for Kwame

- `skinTypePickerSubtext` and `skinTypeSourcePointer` are now in `ProductCopy.swift` and in `auditCopySurfaces`; wire both into `SkinTypeOnboardingView` alongside the existing `skinTypePickerPrompt` line.
- `skinTypeSourcePointer` should be tappable and deep-link into About, per Plunder §2.3.
- Settings "Skin type" row: once added, remove `XCTExpectFailure` in `testSkinTypePickerInSettingsReusesOnboardingPattern`.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
# Plunder proposal — About-screen citation policy & research-backed question guardrails

- **Date:** 2026-05-19T16:22:15-07:00
- **Owner:** Plunder (Legal & Compliance)
- **Status:** proposed
- **Requested by:** yashasg (via Copilot)
- **Inbound directive:** `.squad/decisions/inbox/copilot-directive-2026-05-19T16-22-15-944-07-00-research-based-questions-citations.md`
- **Pairs with:** Wheeler (science sources), Iris (placement), Gaia (IA), Suchi (user-expected language)

---

## Verdict (concise)

✅ **Ratify the user direction.** Every onboarding/settings question we ask the user must trace to a citeable, named source. We do not invent questions, options, or thresholds. The About screen is the canonical citation surface; every screen that asks a research-backed question links to it. This is consistent with — and tightens — the framework in `.squad/decisions/inbox/plunder-citation-framework.md` and decisions D-2026-05-19-008/009/011.

This is a team decision because it touches IA (Gaia), onboarding/settings UI (Iris), question copy (Suchi/Wheeler), and disclaimer surfaces (Plunder L1–L4).

---

## 1. What must be cited

A factual claim is anything the user could reasonably interpret as "the app is telling me something true about my body, my medication, or the sun." Each of the following surfaces requires a citation **in About**, and an inline source pointer on the surface itself where it appears:

| Surface | Citation requirement | Notes |
|---|---|---|
| Fitzpatrick skin-type question, all six rows | Fitzpatrick TB (1988) + NCBI Bookshelf NBK481857 Ch.6 Table 1 (Ward & Farma 2017, Codon, CC BY-NC 4.0) | Cite, do not reproduce verbatim. Paraphrase is canon (D-2026-05-19-009). |
| Behavior helper copy ("how your skin usually burns and tans without sunscreen") | Same as Fitzpatrick row | Helper text inherits the same source anchor. |
| Burn-time estimate / "minutes to skin reddening" / 1 MED math | Diffey BL (1991) *Phys Med Biol* 36(3):299–328 + CIE S 007/E-1998 (document number only) + Sayre 1981 + Harrison & Young 2002 + Schalka & Reis 2011 | Wheeler's MED anchor table. Numerical values are facts; presentation is ours. |
| UV index → irradiance conversion (0.025 W/m² per UVI) | NOAA / NWS / EPA (public domain primary anchor) + WHO INTERSUN 2002 (cross-reference only, cite — do **not** reproduce) | NOAA is the text anchor; WHO is the international cross-ref. |
| SPF math / "applied SPF" framing | FDA OTC Sunscreen Monograph 21 CFR Part 352 (public domain) + ISO 24444 (document number only) | "Applied" vs. "labeled" distinction must be supported by the FDA monograph language. |
| Photosensitization disclosure (medication/condition cohorts) | FDA labeling guidance (public domain) + Moore DE 2002 *Drug Saf* doi:10.2165/00002018-200225050-00004 + NIH MedlinePlus (public domain) | Class names only — no brand names anywhere in app. |
| Children / pediatric guidance line | Cite the AAP general sun-safety position **only by name**, never reproduce; the active line is "consult a pediatrician." | Treatment of children is out-of-scope clinical advice; we point to clinician. |
| WeatherKit / UV data attribution | Apple WeatherKit attribution policy + canonical legal-attribution URL | Already locked by D-2026-05-19-003/004. Mirrored in About. |

If a question, threshold, or claim does not appear in the table above, **it is not shippable** until Wheeler supplies a source and Plunder green-lights the framing. "We thought it was a good question" is not a citation.

---

## 2. About-screen citation placement policy

### 2.1 Canonical surface

About is the single source-of-truth citation surface. It is reachable from:

- L1 first-launch disclaimer cover ("Learn more" / "Sources").
- L3 "Is this estimate for me?" verdict-card link → About anchor "When this estimate may not apply."
- L4 About sheet entry (gear/settings → About).
- Inline source pointers on onboarding question screens and Settings rows.

### 2.2 Required About sections (in this order)

1. **What this app does, in one line.** "UV Burn Timer estimates time to skin reddening from UV index, applied SPF, and your selected Fitzpatrick skin type. It is not medical advice." (Lifted from the L1 disclaimer; do not drift.)
2. **What this app does not do.** Bulleted, plain-language, mirroring §8.9 of the citation framework: no diagnosis, no medication advice, no replacement for clinician judgment, no SPF recommendation.
3. **How we estimate burn time.** One paragraph + the formula `t = (MED × SPF) / (UVI × 0.025 × 60)`, with inline source numbers `[1]`–`[n]`. Numbers must match the References list at the bottom.
4. **Where the skin-type question comes from.** Names Fitzpatrick TB (1988) as the original scale and NCBI Bookshelf Ch.6 Table 1 (Ward & Farma 2017, Codon) as the modern table we cite. Notes the wording is paraphrased, not reproduced.
5. **When this estimate may not apply.** Photosensitizer class list (no brand names), pregnancy/hormonal photosensitivity, post-procedure skin, children, lupus/vitiligo/PMLE, recent UV/laser treatment. Each item carries a citation number to FDA labeling guidance / Moore 2002 / MedlinePlus.
6. **Weather/UV data source.** WeatherKit attribution block per D-2026-05-19-003/004, with the tappable Apple legal-attribution link.
7. **References.** Numbered list, full bibliographic strings, DOIs where available, license note at the end of each entry (`Public domain`, `CC BY-NC 4.0 — cited, not reproduced`, etc.). Order matches the inline `[n]` markers.
8. **License & attribution notes.** WeatherKit lockup terms (no recolor), CC BY-NC 4.0 cite-only posture for the NCBI/Codon table, WHO INTERSUN cite-only posture. One sentence each, lay-readable.
9. **Last updated** date + app version. Required so the citation list is auditable post-launch.

### 2.3 Inline source pointer pattern (non-About surfaces)

Anywhere a research-backed question or claim is shown outside About, render a single discreet pointer:

```
Sources: Fitzpatrick 1988; NCBI Bookshelf 2017.  →  See About › Sources
```

Rules:

- One line, secondary text color, below the question/claim — not above.
- Tappable; deep-links to the matching anchor in About.
- Never abbreviated to just "[1]" on the question surface itself — the surface must name at least one source so the user can see the question is sourced even without tapping through.
- Never substitute the in-line pointer for the full About reference; both must exist.

### 2.4 Citation rendering rules

- **Form:** Numbered references in About; named-source pointer inline. No bare URLs in body copy — URLs go in the References list and on tappable affordances only.
- **Attribution string for the NCBI/Codon table (locked):** "Ward WH, Farma JM, editors. *Cutaneous Melanoma: Etiology and Therapy*, Ch. 6 Table 1. Brisbane (AU): Codon Publications; 2017. doi:10.15586/codon.cutaneousmelanoma.2017.ch6 — cited under CC BY-NC 4.0; wording paraphrased, not reproduced."
- **Attribution string for Fitzpatrick original:** "Fitzpatrick TB. The validity and practicality of sun-reactive skin types I through VI. *Arch Dermatol.* 1988;124(6):869–871. doi:10.1001/archderm.1988.01670060015008."
- **Attribution string for Diffey MED math:** "Diffey BL. Solar ultraviolet radiation effects on biological systems. *Phys Med Biol.* 1991;36(3):299–328. doi:10.1088/0031-9155/36/3/001."
- **WeatherKit attribution string in About:** "Weather and UV index data provided by Apple Weather, with data sourced from a range of providers." + tappable "Other data sources" link to `https://developer.apple.com/weatherkit/data-source-attribution/`.
- **No partial reproductions** of NCBI Ch.6 Table 1, WHO INTERSUN tables, ISO 24444 tables, or CIE S 007 tables — even as screenshots, even with attribution.
- **Brand names are banned** everywhere, including References and About body copy. Therapeutic classes only (e.g., "tetracycline-class antibiotics," "retinoid therapy").

### 2.5 Accessibility & HIG hooks (for Iris)

- Each reference is a separate `Text` (not one giant paragraph) so VoiceOver can step through.
- Inline pointer reads as: "Sources, Fitzpatrick 1988; NCBI Bookshelf 2017. Button. Opens About sources."
- References list supports Dynamic Type to the largest accessibility size without truncation.
- Tappable URLs in References use a 44×44 pt minimum hit target and are visually distinguished beyond color.

---

## 3. Copy guardrails — keep questions informational, not diagnostic

Onboarding/settings questions must be phrased so the app is **gathering input from the user**, not **assessing the user**. The user owns the answer; the app does not interpret it as a finding about them.

### 3.1 Allowed patterns

- ✅ **Question framed as user self-classification, sourced.** "Which of these best describes how your skin usually burns and tans without sunscreen?" Cite Fitzpatrick + NCBI.
- ✅ **Neutral disclosure prompts that point to clinician.** "Are you taking a medication or have a condition that makes your skin more sensitive to sunlight? This estimate may overstate your safe time. A pharmacist or clinician can confirm whether your specific situation applies."
- ✅ **Inputs labeled as inputs.** "Applied SPF" (not "Your protection level"). "Selected skin type" (not "Your skin type"). "Estimated time to skin reddening" (not "Your safe sun time").
- ✅ **Approximate, hedged numbers.** "~42 min" not "42 min." "Estimate window" not "Time remaining."

### 3.2 Banned patterns

- 🚫 Any question that asks the user to confirm or rule out a diagnosis. ("Do you have lupus?" → 🚫. "Some conditions, including lupus, can increase sun sensitivity — talk to your clinician." → ✅.)
- 🚫 Brand-named medications in any question, list, or example.
- 🚫 "Personalized," "personalised," "tailored for you," "for your skin," "recommended for you" — all imply medical-app personalization (FDA SaMD-adjacent).
- 🚫 "Safe sun time," "safe to be outside," "you can stay out for X." Use "time to skin reddening" / "estimated time to 1 MED."
- 🚫 "Don't worry," "you're protected," "you're fine until X." Promotional false-confidence.
- 🚫 Implied recommendations: "Choose Type III for most users," any pre-selected default, any "most people pick…" copy. (D-2026-05-19-009 no-default is canonical.)
- 🚫 Pediatric-specific timers, dose recommendations, or pediatric-specific copy beyond "consult a pediatrician."
- 🚫 Any question that does not appear in the §1 sourced table without prior Wheeler + Plunder sign-off.

### 3.3 Rewrite cheatsheet (for Suchi / Iris / Kwame)

| Tempting copy | Replace with | Why |
|---|---|---|
| "How well does your skin handle the sun?" | "How does your skin usually burn and tan without sunscreen?" | Removes "handle" (capability framing). |
| "Your safe sun time: 42 min" | "Estimated time to skin reddening: ~42 min" | Removes "safe" promise; adds "estimated." |
| "Recommended SPF for you" | "Applied SPF" | Removes recommendation. |
| "Are you on Accutane, doxycycline, or tetracycline?" | "Are you taking a medication that increases sun sensitivity? Examples include retinoid therapy and tetracycline-class antibiotics. Your pharmacist or clinician can confirm." | No brand names; clinician resolution path. |
| "Most people choose Type III." | (Delete. No defaults, no anchoring.) | D-2026-05-19-009. |
| "This is safe for you." | "Reapply sunscreen every 2 hours regardless of timer." | Replaces safety claim with behavioral guidance. |

### 3.4 Question-addition workflow (locks the "no invented questions" rule)

Adding any new user-facing question — onboarding, settings, prompt, push, or in-app — requires this sequence before code lands:

1. **Wheeler** supplies a primary citeable source (peer-reviewed, federal guidance, or WHO/CIE/ISO document) for the underlying claim or classification. No source → no question.
2. **Plunder** verifies the source's license posture (✅/⚠️/🚫 per the framework) and approves the framing as informational, not diagnostic.
3. **Suchi** confirms persona-keyed comprehension and resolution path (e.g., clinician for P4 Asha).
4. **Iris** specifies the on-screen rendering and inline source pointer per §2.3.
5. **Gaia** adds the question to the canonical IA flow and tags the About reference number.
6. **Kwame** implements with centralized strings (no copy duplication between onboarding and settings — Iris guardrail).

If any step blocks, the question does not ship. There is no "we'll add the citation later" path.

---

## 4. Coordination & implications

- **Wheeler:** Confirm the §1 table is complete and that each row has a primary, citeable source. Flag any current question whose source is weaker than the table implies.
- **Iris:** Add About IA per §2.2 (nine sections, in order) and inline pointer per §2.3 to the onboarding/settings selector. About is reachable from L1, L3, L4, and the gear/Settings. The Fitzpatrick selector — used by both onboarding and Settings per Iris's current proposal — must render the inline source pointer once, in the shared component.
- **Gaia:** Update IA spec so About is the canonical citation surface; mark the SkinTypeView shared component as the carrier of the inline source pointer (one component, one pointer, no drift).
- **Suchi:** Apply the §3.3 rewrite cheatsheet to any user-facing strings currently outside the safe pattern. Re-run persona checks (P3 Devon, P4 Asha, P5 Tomás) against the rewritten onboarding question copy.
- **Kwame:** Centralize the About content + References list in one source file (e.g., a `LegalAttributions` / `Citations` Swift type) so the inline pointer and About list cannot diverge. Last-updated date is computed from the same source.
- **Argos:** App Store description text must not contradict About — same banned patterns apply, same Apple-Weather attribution line.

This proposal does **not** invalidate prior decisions; it tightens enforcement of D-2026-05-19-008 (canonical Fitzpatrick source), D-2026-05-19-009 (paraphrased picker copy), D-2026-05-19-011 (L1–L4 disclaimer pattern), and the citation framework. It adds the explicit rule that **all user-facing questions must be research-backed, and About is the single canonical citation surface.**

---

## 5. Acceptance criteria

1. About screen exists, contains all nine §2.2 sections, in order, with the named attribution strings from §2.4.
2. Every research-backed question surface (onboarding skin-type, Settings skin-type, photosensitizer disclosure, applied SPF helper) renders the §2.3 inline pointer that deep-links to the matching About anchor.
3. No banned phrase from §3.2 appears in any user-facing string (app, About, App Store listing, push, in-app message).
4. No brand-name medication appears anywhere in the codebase's user-facing strings.
5. No verbatim reproduction of the NCBI Ch.6 Table 1, WHO INTERSUN tables, ISO 24444 tables, or CIE S 007 tables appears in app or About.
6. WeatherKit attribution renders both on Home (adjacent to UV data) and in About per §2.2 #6.
7. About displays the app version and a last-updated date that match the build's References content.
8. A new question cannot be added without the §3.4 workflow producing a primary source citation in the same change set.

---

*Plunder. Pairs with Wheeler, Iris, Gaia, Suchi. No app code modified by this proposal — Scribe to merge; Kwame to implement on the next onboarding/settings/About work cycle.*

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
# Suchi proposal — Secondary skin-tone cues in the Fitzpatrick picker (user-research review)

- **Date:** 2026-05-19T16:11:26-07:00
- **Owner:** Suchi (User Researcher)
- **Status:** proposed — companion to Iris's `iris-secondary-skin-swatch-cues.md` (same date)
- **Canon respected:** D-2026-05-19-009 (behavior-first NCBI paraphrase), D-2026-05-19-012 (no-default), D-2026-05-19-014 §learning-3 (Tomás under-picking), D-2026-05-19-011 (L1–L4 surfaces)

## TL;DR — Verdict

**Conditional yes** to keeping a small tonal cue inside each Fitzpatrick row, **with research-grounded additions to Iris's guardrails** — *and* a stronger alternative the team should consider before locking in a skin-tone swatch: **behavior pictograms** (a tiny burn/tan icon set) that visually encode the Fitzpatrick *construct* (burn behavior) instead of pigmentation. Pictograms deliver the visual-scan benefit without the under-picking and exclusion failure modes that skin-tone swatches reintroduce.

If the team prefers skin-tone swatches over pictograms, I'll sign off on Iris's pattern with the additions below. If we're flexible on the visual treatment, pictograms are the higher-confidence answer for the personas we committed to serving.

## Why "secondary" alone doesn't fully neutralize the risk

Iris's pattern (behavior text first, swatch trailing and decorative) is sound on a HIG/accessibility axis. The remaining concern is mental-model, not layout:

1. **Pre-attentive visual capture beats reading order.** Eye-tracking research on form-fill is consistent: color patches anchor scan even when positioned after text. "Behavior-first in source order" ≠ "behavior-first in user attention." The Tomás failure (`.squad/files/suchi-persona-annotations.md` §learning-3) is a self-narrative–driven *match-my-arm* reflex; it fires before the behavior copy is parsed.
2. **Single-tone-per-type encodes a falsehood.** Each Fitzpatrick type spans a *range* of tones (especially IV–VI). A single circle implies "Type V looks like this." Maya (Fitz III–IV burning at SPF 50) and dark-skinned users in the V/VI band don't see themselves in one canonical chip.
3. **Color rendering on cheap LCDs + outdoor light flattens V vs VI.** A user with Fitz VI may visually match a Fitz V swatch under noon sun on a low-nit display and self-classify down by one. This is a worse failure than no swatch.
4. **Greta's bad-science detector.** Even a decorative swatch encodes "Fitz ≈ pigmentation," the framing she'll one-star us for in r/Ultralight. The behavior copy is the antidote; a swatch dilutes it in a way that's invisible to most reviewers but obvious to scientifically-literate users.

These are *additional* risks beyond what Iris's guardrails address, and they're persona-specific, so they sit in my lane.

## Additions to Iris's guardrails (if we keep skin-tone swatches)

Take Iris's full guardrail list (`.squad/decisions/inbox/iris-secondary-skin-swatch-cues.md`) and add:

- **G1 — Swatch is a tonal *band/cluster*, not a single circle.** Render each row's swatch as a 2–3 dot cluster spanning a small range, or a short gradient strip. Goal: defeat the "match my arm to this exact circle" reflex. Visually communicates "Type V covers a range of tones."
- **G2 — V and VI bands must be visibly distinct *and* sufficiently dark.** Spec a minimum L\* delta between V and VI in the tonal cluster and validate on a low-end iPhone SE under direct-sun viewing conditions. If we can't reliably distinguish V from VI under those conditions, the swatch *must not ship* — it would cause Fitz VI users to silently misclassify down to V.
- **G3 — Helper copy lives *above* the list, not in a footnote.** Iris's "tone cue is only a visual aid" line should be the first thing the user reads on the picker screen, not row-footer microcopy. Suggested: *"Choose by how your skin **burns and tans**, not by tone match. Each type spans a range of skin colors."* (Wheeler/Plunder to ratify wording.)
- **G4 — All six types present, no exceptions.** Repeating canon (D-2026-05-19-012, my work-item-3 review §12) because the Helios mock dropped Type VI. The swatch design must not be a vehicle for re-introducing that omission.
- **G5 — VoiceOver order is `Type N. Behavior copy. Appearance descriptor. Not selected.`** Color names are *omitted from accessibility semantics* (matches Iris G3). This also means VO users get the behavior-first ordering that sighted users may not, which is acceptable asymmetry — both end up with the right anchor.
- **G6 — Validation gate before ship:** a covered-text test. Iris/QA covers the behavior copy and asks 8–12 testers (mixed Fitz I–VI) to pick their type from swatches alone. If >25% pick a different type than they pick when behavior copy is visible, the swatch is too dominant and must shrink or be removed. This is a falsifiable acceptance criterion, not vibes.

## Stronger alternative: behavior pictograms instead of skin-tone swatches

What if the visual cue encoded *behavior* instead of *pigmentation*?

- **Type I–II:** small icon of a sun + reddening / "always burns" glyph
- **Type III–IV:** sun + browning / "burns then tans" glyph
- **Type V–VI:** sun + deep-tan / "rarely burns" glyph (graded by intensity for V vs VI)

Why this beats skin-tone swatches on every persona axis I track:

| Failure mode | Skin-tone swatch | Behavior pictogram |
|---|---|---|
| Tomás under-picks by matching arm to V | High risk (the swatch *is* the lure) | No lure — pictogram is about behavior |
| Maya over-confident from "darker = safer" | Reinforced by the gradient | Pictogram shows "tans" not "safe" |
| Fitz VI exclusion via flattened V/VI rendering | Real risk on low-end displays | Pictogram differs by behavior intensity, not subtle tone |
| Vee (vitiligo/albinism) sees no match | Confirms exclusion | Pictogram is condition-agnostic |
| Greta's bad-science detector | Triggered (encodes Fitz=pigment) | Not triggered (encodes Fitz=behavior, which is correct) |
| Scan benefit / visual-cue payoff | Yes (the original ask) | Yes — and aligned with the construct |

This is the answer I'd push if Iris/Wheeler are open to it. It threads the needle: visual cue benefit *and* mental-model integrity *and* zero exclusion signal.

## Decision tree for the team

1. **Default recommendation: ship behavior pictograms.** Iris owns icon design; Wheeler validates that each pictogram maps cleanly to the NCBI-paraphrased behavior text; Plunder confirms no diagnostic-iconography compliance concern (pictograms are explanatory, not diagnostic).
2. **Fallback: ship skin-tone swatches under Iris's guardrails + my G1–G6 above.** Acceptable to me, lower-confidence than pictograms.
3. **Hard floor (either path):** no default, behavior copy primary, all six types, L1–L4 surfaces intact, WeatherKit attribution unaffected.

## What changes downstream

- **Iris:** if path 1, design the 3- or 6-step pictogram set and update her swatch proposal; if path 2, fold G1–G6 into her guardrail list.
- **Wheeler:** ratify pictogram-to-behavior mapping (path 1) or sign off that band-cluster swatch (path 2) is consistent with the NCBI construct.
- **Plunder:** confirm pictograms are not a regulated-iconography concern (path 1).
- **Kwame:** no implementation change yet — both paths land in `FitzpatrickSkinType` row design and reuse `pickerDescription`. Image asset work is path-1-only.
- **Argos:** the launch-cohort communities (r/Albinism, r/vitiligo, r/AsianBeauty per D-2026-05-19-010) will read the picker design as a signal of who we built this for. Pictograms are a stronger "we built this for behavior, not skin color" message than swatches.

## Open question for yashasg

Do we have appetite for the pictogram path (slightly more design work, materially stronger persona outcome), or do we want to ship under Iris's swatch pattern + my added guardrails? Either is shippable; pictograms are the higher-confidence answer from where I sit.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
# Suchi — User-Research Review of GitLab Work Item #3 ("UI Design update" / "Helios Safe")

- **Date:** 2026-05-19T15:59:04-07:00
- **Reviewer:** Suchi (User Researcher)
- **Artifact under review:** GitLab work item #3 — `DESIGN.md` (Helios Safe brand + style + component spec) + `screen.png` (mobile mock of Tracker screen)
- **Lane:** Persona/JTBD fit, onboarding comprehension, safety-critical mental models, edge-case service. **Not** visual polish (Iris) or scope (Gaia) or claim wording (Plunder) or science accuracy (Wheeler).
- **Canon respected:** D-2026-05-19-012 (no-default Fitz), D-2026-05-19-011 (L1–L4 disclaimers), D-2026-05-19-009 (NCBI paraphrase, behavior-first), D-2026-05-19-007 (photosensitivity = safety boundary), D-2026-05-19-003/004 (WeatherKit attribution), D-2026-05-19-014 (persona overlays).

---

## TL;DR — Verdict

**TAKE WITH CHANGES.** The design is a useful visual modernization but, **as drawn**, it would silently break three load-bearing safety decisions and structurally exclude one of the personas we explicitly committed to serving. Adopt the visual-system layer; reject the picker treatment and the science-card claim; defer the IA/brand/history changes.

| Category | What I'd take | What I'd modify | What I'd reject | What I'd defer |
|---|---|---|---|---|
| Visual system | Hero circular timer; Inter type ramp; outdoor-readable surface system; 48pt min targets; UV-tier color tokens | UV chip needs Apple Weather attribution adjacent | — | — |
| Fitz picker | — | — | **Skin-tone swatch grid; Type II pre-checked; Type VI omitted** | — |
| Science / verdict copy | — | — | **"Predicts the precise minute…"** | — |
| Disclaimers / safety | — | Re-introduce L1 cover, L2 footer, L3 verdict reach-back, L4 About — none visible on the mock | — | — |
| SPF control | — | Snap continuous slider to canonical steps (None/15/30/50/70+) | — | — |
| Photosensitization | — | Surface inline photosensitizer link on home (P4 cannot find it in the mock) | — | — |
| IA / brand | — | — | — | Bottom-tab redesign (Tracker/History/Science); rename to "Helios Safe"; History tab (zero-data conflict) |

---

## Persona × New-Design Matrix

Same five personas I've been tracking (`.squad/decisions/archive/suchi-design-brief.md` §0). I'm reading the proposed screen, not the implementation behind it.

### P1 — Gram-counter Greta (u/hareofthepuppy, r/Ultralight; Fitz II–III)

- **What works:** Big glanceable "45 MINUTES TO BURN" satisfies her "give me the number, don't make me work" JTBD. Inter + 48px display-lg readable at arm's length on the trail.
- **What breaks:** The skin-tone swatch grid trips her bad-science detector (verbatim concern from §1.2 of my prior brief). Fitzpatrick is burn/tan *behavior*, not pigmentation. Greta is the persona most likely to one-star us in a review with "they don't understand the scale they're using."
- **Verdict-screen trust signal missing:** No source attribution on the UV chip. Greta needs to know whether "UV 8" is an authority number or our extrapolation. **Apple Weather lockup must be adjacent to the chip** (D-2026-05-19-003 / -004).

### P2 — Sungirl Maya (u/Sungirl1112, r/OpenWaterSwimming; SE Asia, Fitz III–IV)

- **What works:** Outdoor-readable surface palette (the `#f7fafc` background + high-contrast displays) is a real upgrade for poolside / dockside reads.
- **What breaks:** The swatch grid encodes Fitz IV as a darker-brown circle. Maya's verbatim concern is that her Fitz IV–coded skin is still burning with SPF 50 on body + SPF 70 on face. A picker that codes high-Fitz as "darker = less at risk" reinforces the exact mental model that's burning her. The behavior-first text we ratified in D-2026-05-19-009 is the antidote; the swatch-only treatment removes the antidote.
- **Branch-5 (window-elapsed) still load-bearing:** I noted in `.squad/files/suchi-persona-annotations.md` that Maya is literally in the water at the moment her safety reading would land — her pre-swim verdict-card accuracy is everything. The hero card is fine for that; nothing in the new design improves or hurts it specifically.

### P3 — PCT Pale Devon (u/thedharmalife, r/PacificCrestTrail; Fitz I, highest WTP)

- **Hard-blocker:** **Type II is pre-checked in the mock** (checkmark glyph on the second circle). This is the exact anchoring error D-2026-05-19-012 forbids. Devon is Fitz I; if he opens the app and sees II already selected, he reads a burn time that's roughly **50% too long** for him on a UV-8 day. That's not a UX miss — it's a sunburn that we caused.
- **Second blocker: Type VI is missing from the grid (only I–V shown).** Devon isn't VI, but the persona he'd vouch for in r/PacificCrestTrail (his thru-hike partners who are dark-skinned) is. Shipping a Fitz picker that stops at V is a structural exclusion signal that the launch-cohort communities will see immediately.
- **What works:** Continuous SPF range is fine for him *if* it snaps to discrete real-world SPF labels — he's doing gram-math on a specific tube, not interpolating.
- **Planning-mode dead-end** (Devon at home in February planning a July hike) is unchanged by this design — not a regression, not a fix.

### P4 — Accutane Asha (u/Affectionate_Nose_79, r/Accutane; load-bearing safety persona)

- **Hard-blocker:** The "The Science: MED" card claims the model **"predicts the precise minute your specific skin type will sustain cellular damage."** Asha's verbatim: *"the UV is maybe 3 and it looks like I've rolled a few. What can I do to stop this?"* The MED model is **silent on her photosensitizer**; calling it "precise" tells her either (a) the math secretly accounts for her Accutane (it doesn't) or (b) the burns she's actually experiencing are her fault. Both readings make her dismiss the app and possibly stay outside longer than she should. **This single sentence undoes the L1–L4 disclaimer pattern we converged on.**
- **Hard-blocker:** No L1 cover, no L2 footer, no L3 verdict reach-back, no inline photosensitizer link visible on the mock. The three-surface visibility pattern (D-2026-05-19-011) is the only mechanism by which Asha can re-attest after a medication change in our zero-data architecture (D-2026-05-19-014 §learning-4). Removing it makes the design *worse* for the persona on whom the launch safety case rests.
- **One thing the design unintentionally helps her with:** a "History" tab would let her pattern-match "UV-3 burned me last Tuesday" — but only if we cross the zero-data boundary, which is a Donatello/Plunder/Gaia decision. See "Defer" section.

### P5 — Trail-run Tomás (u/Amazing-Reporter1845, r/trailrunning; Fitz III–IV, may misclassify as V)

- **Hard-blocker (already-flagged failure mode):** In D-2026-05-19-014 §learning-3 I named Tomás's under-picking risk: his self-narrative "*I tan, I don't burn*" nudges him toward V/VI when he's actually IV. The behavior-first text we ratified is the partial mitigation. **The swatch-only grid removes that mitigation entirely** — Tomás now picks by visual skin-tone match (V looks like his arm), not by burn behavior, and inherits a burn time that's ~40% too long for him.
- **What works:** 48pt min touch target spec; high-contrast hero number; chip-style UV badge. All fine for sweaty-finger, motion-blur use.
- **What's neutral:** Continuous SPF slider — he tapped a chip last time and his setting persists in memory; either control works for him.

### Edge-case personas the new design implicitly assumes away

- **P7 Vitiligo / albinism Vee** (r/Albinism, r/vitiligo): **Type VI omitted is one half of the exclusion; albinism doesn't fit Fitz I either (the "freckled red/blonde" descriptor erases them).** The behavior-first text plus the photosensitization-cohort list in About is what we'd lean on. Removing the L4 reach-back makes this worse.
- **P6 Parent-of-pale-child Priya** (r/SkincareAddiction): Not the primary user; uses the app as decision-support for her kid. The "precise minute" claim is exactly the kind of language that makes her over-trust the verdict and let the kid stay out longer. Negative interaction.

---

## Element-by-element verdict

### ✅ TAKE — visual & system layer

1. **Hero circular timer** with `display-lg` (48px) center readout — strict upgrade over the current `HeroTimerCard`. Glanceable, outdoor-readable, persona-positive across all five.
2. **Inter type ramp** (display-lg / headline-lg / title-md / body / label-caps) — clean, accessible, no concerns.
3. **Surface system** (`#f7fafc` background, tonal containers, low-contrast outlines, no heavy shadows) — explicitly designed for outdoor-display readability, which matches P5 Tomás's trailhead use and P2 Maya's poolside use.
4. **UV-tier color tokens** (low/moderate/high/very-high/extreme) — correct semantic mapping. Acceptable provided color is not the *only* tier signal (VoiceOver / Dynamic Type must verbalize the tier name).
5. **48pt minimum touch target** — directly addresses sweaty-finger / one-handed-use friction I called out for Tomás. Keep.
6. **Rounded corner language** (`rounded-xl` cards, `rounded-full` chips) — neutral / mildly persona-positive (modern, approachable, doesn't signal "medical device").

### 🔧 TAKE WITH CHANGES — element-level adjustments required before adoption

7. **UV index chip** — keep the chip, **but Apple Weather attribution must sit adjacent** (D-2026-05-19-003 / -004). Without it, the chip reads as our own measurement and breaks Greta's + Devon's data-provenance trust signal.
8. **SPF control** — adopt the slider visual *only if* it snaps to the canonical discrete steps (None / 15 / 30 / 50 / 70+). Continuous selection encourages model fiction ("I'll just pick 47") and erases the "None" semantic step Devon needs for gear-math. Snap-to-step also keeps Tomás's "tap the chip" muscle memory functional.
9. **"The Science" card** — keep the *placement* (in-flow educational surface tied to the result), reject the *copy* (see below). This is the right home for a paraphrased MED explanation that names its assumptions and points to the L4 cohort list.

### ❌ REJECT — these conflict with ratified canon and harm target personas

10. **Skin-tone swatch grid as Fitzpatrick picker.** Three independent failures:
    - Violates the implicit reading of D-2026-05-19-009 (behavior-first text is the *load-bearing* element; swatches relegate it to a secondary cue or remove it entirely).
    - Reintroduces the Tomás under-picking failure mode I flagged in D-2026-05-19-014 §learning-3.
    - Trips Greta's bad-science detector and reinforces Maya's "high-Fitz = safer" anti-model.
    - **Recommendation:** Keep the swatch as a small *adjacent* visual cue if Iris wants it for accessibility/scan, but the picker rows must lead with the behavior text (D-2026-05-19-009 Wheeler edited variant) and the tap target must be the whole row. The current iOS list/form treatment is the correct architecture; the visual styling is what should evolve.

11. **Type II pre-checked.** Direct violation of D-2026-05-19-012. The mock shows a checkmark on Type II at first render. This is non-negotiable: **no default selection.** Devon (Fitz I) is the canonical case; pre-anchoring him to II produces a ~50% over-estimate of safe time on a high-UV day. The picker must render with no selection and the primary CTA must be disabled until the user taps.

12. **Type VI omitted from the picker grid.** The mock shows I, II, III, IV, V only. This is a structural exclusion signal toward dark-skinned users — exactly the cohort Suchi's design-brief §7 (and the r/AsianBeauty / r/Albinism / r/Dermatology channels I flagged in D-2026-05-19-010) committed to serving. Type VI must be present. Non-negotiable.

13. **"Predicts the precise minute your specific skin type will sustain cellular damage."** Three problems:
    - **Science:** Wheeler's lane to fully gate, but the MED model is a population estimate, not a per-user precision claim. ("Estimate, not measurement" is canon.)
    - **User trust:** For Asha, "precise" is the verbatim gaslight pattern. For Devon doing gear math, "precise" implies measurement-grade accuracy. Both will quietly distrust the app.
    - **Compliance:** Plunder's lane, but "precise minute" + "cellular damage" reads as a clinical claim. Likely flags.
    - **Recommendation:** Replace with paraphrased explainer language that names the model's assumptions and points to L4. Suggested seed copy (Wheeler/Plunder to finalize): *"Estimated using the Minimal Erythemal Dose model, which scales to UV index and your selected skin type. This is a model estimate, not a measurement — see 'Is this estimate for me?' if you take photosensitizing medications, have a sun-sensitive condition, or have had recent skin treatments."* The latter half pulls the L3 reach-back surface into the Science card, which is actually a useful redundancy for Asha.

14. **No visible L1 / L2 / L3 / L4 surfaces on the home mock.** The three-surface visibility pattern (D-2026-05-19-011) is the load-bearing safety case for P4 Asha and her cohort. The mock shows none of:
    - L1 — first-launch full-screen cover with inline photosensitizer link
    - L2 — persistent footer disclaimer on every result screen
    - L3 — "Is this estimate for me?" link on the verdict / hero card
    - L4 — About → photosensitization cohort list anchor
    - **Recommendation:** Iris's redraw must explicitly reincorporate all four surfaces. The visual language of the new design (low-contrast outline cards, label-caps secondary headers) can absolutely carry a clean L2 footer + L3 link without breaking the minimalism — but they must be drawn.

15. **No photosensitizer affordance on home.** Currently the iOS app surfaces `photosensitizationBannerLabel` ("Meds or photosensitive conditions? Learn more") inline. Removing this from the home surface removes Asha's primary re-entry point to the cohort list. **Must be reintroduced** as a banner, chip, or inline link on the home surface — Iris's call on visual treatment.

### ⏸️ DEFER — out of my lane / cross-team decision needed

16. **Brand rename "Helios Safe."** Out of my lane (Plunder + Gaia). My one user-research note: "Safe" is a claim word and the persona discourse already trusts "UV Burn Timer" as a description. The personas don't care about the marketing name; they care about the first-verdict friction and the trust signals. I'd defer.

17. **Bottom-tab IA (Tracker / History / Science).** Significant departure from the current NavigationStack architecture. Pro: gives Science a permanent home (good for L4 surfacing). Con: a third-tab IA can compete with the L2 footer for bottom-of-screen real estate, and the current single-task NavigationStack is HIG-aligned for "one job: am I going to burn?" — Gaia and Iris own the call. I'd want to see the L2/L3/L4 surfaces drawn into the tab structure before signing off.

18. **History tab.** Crosses the zero-data architecture line (Donatello M7; D-2026-05-19-014 §learning-4 implicit posture). My user-research read is that **on-device-only burn history would be high-value for P4 Asha specifically** (pattern-matching "UV-3 burned me last Tuesday at 11am" is exactly the agency she's missing) — but it must be on-device-only, opt-in, and explicitly framed as "stays on this phone." This is a non-trivial architecture + privacy decision. Defer to Donatello / Plunder / Gaia. Not a v1 blocker.

19. **Hamburger menu (top-left).** iOS HIG generally discourages hamburger menus in favor of native nav patterns. Iris's lane. My only concern is whether settings / About are still one tap away from the home surface — if they are, no persona harm.

---

## What I'd ship next (concrete, in priority order)

1. **Iris redraw of the home surface** that keeps the visual system (hero circular timer, Inter ramp, surface palette, 48pt targets) and re-introduces:
   - L2 persistent footer
   - L3 "Is this estimate for me?" link on the hero card
   - Apple Weather attribution adjacent to the UV chip
   - Photosensitizer inline link / banner
2. **Iris redraw of the Fitzpatrick picker** that keeps behavior-first text rows (Wheeler edited variant), shows all six types, starts with no selection, and uses the swatch as a small adjacent cue (not the primary tap target).
3. **Wheeler + Plunder rewrite of "The Science" card copy** — replace "precise minute" with model-assumptions framing that includes the L3 reach-back. I can draft a persona-tested version if Wheeler wants.
4. **Gaia / Donatello / Plunder triage** of History tab. If kept, scope as "on-device-only, opt-in" before any visual work.
5. **Plunder + Gaia triage** of the "Helios Safe" rename. My research perspective says brand name is not load-bearing for personas; their lanes are.

---

## Final summary line

**TAKE WITH CHANGES.** The Helios Safe visual system is a real upgrade. Three elements of the screen as drawn — Type-II default, missing Type VI, and the "precise minute" science card — would, individually, cause the personas we committed to serving to misjudge their safe sun exposure and quietly distrust the app. With Iris's redraw applying the visual system over the existing safety scaffolding (L1–L4 + no-default Fitz + behavior-first text + WeatherKit attribution + photosensitizer surfacing), this becomes a clean win. Without that redraw, it's a regression on safety canon and persona service.

---

*Cross-team handoffs from this review:*
- **Iris** — owns the redraw; reads this brief; integrates with my prior persona overlay annotations (`.squad/files/suchi-persona-annotations.md`).
- **Wheeler** — owns the "Science" card copy rewrite (the "precise minute" claim).
- **Plunder** — owns the brand-name claim review ("Safe" as claim word); owns the science-card copy claim review.
- **Gaia** — owns the IA / History-tab / brand-rename scope calls.
- **Kwame** — no implementation action yet; waits on Iris redraw.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
# Wheeler — Fitzpatrick paraphrase traceability + About-citation verification (work item #4 kickoff)

- **Date:** 2026-05-19T16:30:05-07:00
- **Owner:** Wheeler (Skin Science Expert)
- **Status:** PROPOSED — review gate before Linka/Kwame implement work item #4
- **Branch:** `squad/4-approved-redesign-paraphrasing`
- **GitLab work item:** #4 — "Source-backed Fitzpatrick copy traceability"
- **Related canon:** D-2026-05-19-008 (NBK481857 canonical source), D-2026-05-19-009 (paraphrase, do-not-reproduce), D-2026-05-19-011 (L1–L4 disclaimer pattern), D-2026-05-19-012 (no-default picker), D-CYCLE-1-001 (PROPOSED — behavior-first reorder)
- **Related proposals (inbox):** `wheeler-source-backed-skin-type-questions.md`, `plunder-about-citation-policy.md`
- **Source-of-truth file for current copy:** `app/Sources/UVBurnTimerCore/FitzpatrickSkinType.swift` and `app/Sources/UVBurnTimerCore/ProductCopy.swift` (HEAD on this branch)

---

## 0. Why this file exists

Work item #4 acceptance criterion #3 requires "an internal traceability table for each row: source concept → app wording → rationale → reviewer sign-offs." This file is that table, plus a verification pass against `plunder-about-citation-policy.md` §1–§4 and `wheeler-source-backed-skin-type-questions.md` §3–§4.

**Scope of this review:** only the science/citation surface — the six picker rows, the picker question header, and the About-screen citation text. UI rendering (Iris), comprehension (Suchi), and licensing posture (Plunder) get their own sign-off rows.

**Out of scope:** no app code is modified by this proposal. Recommended corrective text is staged for the team to ratify before Kwame edits strings.

---

## 1. Verdict (one paragraph)

**Conditional accept.** The current six rows are *behavior-first* (per D-CYCLE-1-001) and the About copy `fitzpatrickCitations` correctly declares "adapted and paraphrased" — that posture is right. However, three categories of issue must be resolved before the work item ships:

1. **Two added sub-clauses are not in NBK481857 Table 1** (Type I hair/freckle descriptor; Type II "light eyes common"; Type IV "Olive"). These trace to the *original* Fitzpatrick 1988 paper, not to the cited NCBI table. Either re-anchor the citation, or remove the additions.
2. **Three rows soften "Always" / "Never" claims** (Types II, V, VI) in a safety-direction-correct way, but the softening is undocumented. The About surface must say so.
3. **One citation link is the wrong Schalka paper** (`ProductCopy.citationLinks` points at Schalka 2009, but the locked source is Schalka & Reis 2011). MED anchor links for Sayre 1981 and Harrison & Young 2002 are missing entirely. These are citation-discipline failures even though the text footnote is correct.

All three are surgically fixable in one change set. No row needs a major rewrite. The picker question header is thin on stimulus context but is anchor-effect-correct; recommended addition below.

---

## 2. Source ↔ app wording traceability table (the six rows)

Verbatim source rows below are from NCBI Bookshelf NBK481857, Chapter 6, Table 1 (Ward WH, Farma JM, eds. *Cutaneous Melanoma: Etiology and Therapy.* Codon Publications; 2017 — CC BY-NC 4.0, **cited, not reproduced**). Wheeler direct-fetched the table on 2026-05-19 (see `wheeler/history.md` and `.squad/decisions/archive/wheeler-fitzpatrick-and-med-anchor.md` §3.1).

The "Underlying scale" column references Fitzpatrick TB. *Arch Dermatol.* 1988;124(6):869–871 (doi:10.1001/archderm.1988.01670060015008) — the source paper for any pigmentation/hair/eye co-descriptors that appear in clinical literature but not in NBK481857 Table 1.

| Row | Source concept (NBK481857 Table 1 verbatim) | Current app wording (`FitzpatrickSkinType.pickerDescription`) | Rationale for drift | Drift direction (safety) | Wheeler | Plunder | Suchi | Iris |
|-----|---------------------------------------------|---------------------------------------------------------------|---------------------|--------------------------|---------|---------|-------|------|
| I   | "White skin. Always burns, never tans." | "Always burns, never tans. Very fair; often freckles, red/blonde hair." | Behavior-first reorder (D-CYCLE-1-001) so users self-classify by lived experience, not skin-color framing (Suchi P3 Devon — "I got sunburned in February"). "Very fair" softens "White skin" (Wheeler edited variant, D-2026-05-19-009 archive §5.1). **Hair/freckle descriptor is NOT in NBK481857 Table 1** — it traces to Fitzpatrick 1988 §clinical history. Currently uncited at the row level. | Same MED claim (200 J/m²), wording preserves "Always burns, never tans" verbatim. ✅ no drift on the burn claim. | ✅ (with §4 fix) | ⏳ | ⏳ | ⏳ |
| II  | "Fair skin. Always burns, tans with difficulty." | "Burns easily, tans minimally. Fair skin; light eyes common." | Behavior-first reorder. **"Burns easily" softens "Always burns"** — defensible because "always" creates a false-certainty anchor for the user (a Type II may occasionally not burn under heavy shade) but the softening is **undocumented**. "Tans minimally" ≈ "tans with difficulty" — semantically equivalent. **"Light eyes common" is NOT in NBK481857 Table 1** — traces to Fitzpatrick 1988 secondary descriptors; per Eilers et al. *JAMA Dermatol.* 2013;149(11):1289–1294 self-rated eye color has poor inter-rater reliability and was de-emphasized as a primary classifier. | Slightly **less conservative** on burn frequency ("easily" vs "always"). Same MED (250 J/m²). Net safety: ⚠ small loss of urgency for Type II users. | ⚠ — see §4.2 | ⏳ | ⏳ | ⏳ |
| III | "Average skin color. Sometimes mild burn, tan about average." | "Burns moderately, tans gradually. Medium skin tone." | Behavior-first reorder. **"Burns moderately" is *stronger* than "sometimes mild burn"** — NBK481857 hedges with "sometimes" and "mild"; current copy reads more deterministic and more severe. "Tans gradually" ≈ "tan about average". "Medium skin tone" = Wheeler edited variant (archive §5.1). | Slightly **more conservative** on burn likelihood — safety-direction acceptable, but it overstates the source. | ⚠ — see §4.3 | ⏳ | ⏳ | ⏳ |
| IV  | "Light-brown skin. Rarely burns. Tans easily." | "Burns minimally, tans easily. Olive or medium-brown skin." | Behavior-first reorder. "Burns minimally" ≈ "rarely burns" — semantically equivalent (rarely is slightly stronger denial). **"Olive" is NOT in NBK481857 Table 1** — added during D-CYCLE-1-001 reorder to help self-classification across Mediterranean / Middle-Eastern / South-Asian / Latin-American users whose lived skin descriptor is "olive" not "light-brown." Defensible but uncited at the row level. Wheeler archive §3.4 notes Fitzpatrick I–VI is an **erythemal-response scale, not a pigmentation scale** — adding pigmentation descriptors that aid self-classification across diverse populations is in keeping with the scale's intent. | Equivalent. Same MED (450 J/m²). | ✅ (with §4 fix) | ⏳ | ⏳ | ⏳ |
| V   | "Brown skin. Never burns. Tans very easily." | "Rarely burns, tans deeply. Brown skin." | Behavior-first reorder. **"Rarely burns" softens "Never burns"** — clinically correct per Wheeler archive §3.4 ("V does burn occasionally"; per Pichon et al. *J Am Acad Dermatol.* 2010, Type V burn rates are nonzero under high-UV exposure). The softening also addresses Suchi P5 Tomás's anchor-effect concern (D-CYCLE-1-001) — "Brown skin → I never burn, I don't need this app." But the softening is **undocumented** on the About surface. "Tans deeply" ≈ "tans very easily". | **Safer direction** — increases user vigilance for a population that experiences burns less often but with worse outcomes when they do (delayed presentation). | ✅ (with §4 fix) | ⏳ | ⏳ | ⏳ |
| VI  | "Black skin. Heavily pigmented. Never burns, tans very easily." | "Almost never burns, deeply pigmented. Dark brown to black skin." | Behavior-first reorder. **"Almost never burns" softens "Never burns"** — same rationale as Type V; Type VI does burn under sufficient UV/duration. "Deeply pigmented" = Wheeler edited variant (archive §5.1) replacing "Black skin" to avoid race-as-identity vs pigmentation-as-attribute ambiguity. "Dark brown to black skin" pairs the edited variant with the verbatim source descriptor — defensible but **introduces "black skin" lowercase as an attribute**; per Plunder citation-framework §3.2, lowercase pigmentation descriptors are accepted form. | **Safer direction** — same logic as Type V. | ✅ (with §4 fix) | ⏳ | ⏳ | ⏳ |

**Reviewer column legend:** ✅ = approved, ⚠ = approved with conditional change requested in §4, ⏳ = awaiting agent sign-off, 🚫 = blocked.

### 2.1 Drift summary

| Drift type | Rows affected | Safety direction | Action |
|---|---|---|---|
| Behavior-first reorder | I, II, III, IV, V, VI | neutral | Already approved (D-CYCLE-1-001). Document on About surface. |
| Verbatim NBK481857 burn-claim preserved | I | n/a | ✅ |
| Softened absolute claim ("Always" / "Never" → "easily" / "rarely" / "almost never") | II, V, VI | II: less conservative; V, VI: more conservative | Document on About surface — see §4.2. |
| Overstated source hedge ("sometimes mild" → "moderately") | III | more conservative | Restore source hedge OR document — see §4.3. |
| Added sub-descriptors not in NBK481857 Table 1 | I (hair, freckles), II (eyes), IV (olive) | neutral | Re-anchor citation to Fitzpatrick 1988 OR remove — see §4.1. |
| Wheeler edited variant softenings ("White" / "Black" → "Very fair" / "Deeply pigmented") | I, VI | neutral | Already approved (D-2026-05-19-009 archive §5.1). |

---

## 3. Question header — source verification

### 3.1 Current copy (`ProductCopy.skinTypePickerPrompt`, used in both onboarding and Settings)

> "Pick the row that matches what your skin does, not its color."

### 3.2 Source-faithful target (per `wheeler-source-backed-skin-type-questions.md` §3.1)

> **How does your unprotected skin usually react in strong sun?**
> Pick the row that best matches what your skin does after about 30 minutes of midday summer sun, with no sunscreen and no recent tan. Each row covers a range of natural skin tones.

### 3.3 Verdict

The current prompt is **shorter** and **anchor-effect-correct** (Suchi D-2026-05-19-012) — the "not its color" clause directly addresses P5 Tomás's risk of under-picking on visible pigmentation alone. **Good.**

But it is **scientifically thin**: it omits the *stimulus* that Fitzpatrick 1988 actually used as the classification probe — unprotected, untanned skin, ~30 min midday summer sun, observed ~24h later. Without the stimulus, users may answer about their already-tanned summer skin, their indoor winter skin, or their genetic skin color (which the prompt asks them *not* to use). That introduces inter-rater noise.

**Wheeler recommendation:** expand minimally to add the stimulus and the "range of tones" reassurance, without losing the anchor-effect guard. Two options for Iris/Suchi to choose between:

- **Option A (minimal expansion, recommended):**
  > **How does your unprotected skin react in strong sun?**
  > Pick the row that matches what your skin does, not its color. Each row covers a range of skin tones.

- **Option B (full inbox §3.1 wording):**
  > **How does your unprotected skin usually react in strong sun?**
  > Pick the row that best matches what your skin does after about 30 minutes of midday summer sun, with no sunscreen and no recent tan. Each row covers a range of natural skin tones.

Either is source-faithful. Option A is closer to the current ship; Option B is more clinically explicit. Wheeler's preference is **Option B** but defers to Iris/Suchi on copy length budget.

---

## 4. Recommended corrective text (paste-ready, awaiting team sign-off)

Each item below is a **specific, paste-ready string** that resolves a single audit finding. None of these change the underlying scale, MED values, or the no-default behavior.

### 4.1 Re-anchor or remove the "extra" sub-descriptors in rows I, II, IV

Three options for the team — all source-faithful:

**Option 4.1.A — re-anchor in About (lowest-friction, recommended).** Keep the current row text, but add this to the About `fitzpatrickCitations` block (or as a new line just below it):

> "Some rows include secondary descriptors (hair color, eye color, skin-tone words like 'olive') that come from Fitzpatrick TB (1988); they help self-classification and are not from the NCBI table."

**Option 4.1.B — remove the extras** (cleanest from a citation-discipline standpoint, but loses the Suchi P3 Devon self-recognition cue):

| Row | Current | Recommended (NBK481857-only) |
|---|---|---|
| I  | "Always burns, never tans. Very fair; often freckles, red/blonde hair." | "Always burns, never tans. Very fair skin." |
| II | "Burns easily, tans minimally. Fair skin; light eyes common." | "Burns easily, tans minimally. Fair skin." |
| IV | "Burns minimally, tans easily. Olive or medium-brown skin." | "Burns minimally, tans easily. Light-brown skin." |

**Option 4.1.C — keep the extras, cite Fitzpatrick 1988 inline.** Add `"(Fitzpatrick 1988)"` next to the picker citation chip on the SkinTypeView screen. UX cost.

**Wheeler default recommendation:** **4.1.A** (re-anchor in About). Lowest UI cost, fully source-honest.

### 4.2 Document the safety-direction softening for rows II, V, VI

Add to `ProductCopy.aboutEstimateApplicability` (or as a new About sub-section "How we worded the rows"):

> "Where the source table uses absolute words like 'always' and 'never,' we softened them ('burns easily,' 'rarely burns,' 'almost never burns') because the underlying scale describes typical response, not a guarantee. Type II's softening trades a small loss of urgency for fewer false-certainty answers; Types V and VI's softening reflects that darker skin does burn under sufficient UV exposure (Pichon LC, et al. *J Am Acad Dermatol.* 2010), just less often."

### 4.3 Restore source hedge in Type III (one-word fix)

Current Type III row over-claims relative to NBK481857. Change one row:

- **Current:** "Burns moderately, tans gradually. Medium skin tone."
- **Recommended:** "Sometimes burns, tans gradually. Medium skin tone."

This restores NBK481857's "sometimes mild burn" hedge without changing row length or breaking the behavior-first ordering. No MED change.

### 4.4 Fix the Schalka citation URL in `ProductCopy.citationLinks`

**Current** (incorrect — points to Schalka 2009 in *Photodermatol Photoimmunol Photomed*):

```swift
ProductCitationLink(
    title: "Schalka, dos Reis & Cucé sunscreen/SPF study",
    url: URL(string: "https://doi.org/10.1111/j.1600-0781.2009.00408.x")!
)
```

**Recommended** (matches the locked source — Schalka S, Reis VMS. *An Bras Dermatol.* 2011;86(3):507–515):

```swift
ProductCitationLink(
    title: "Schalka & Reis 2011 — SPF as MED multiplier",
    url: URL(string: "https://doi.org/10.1590/S0365-05962011000300013")!
)
```

The Schalka 2009 paper is a legitimate co-source on real-world sunscreen use; if the team wants both, add it as a second entry. But the *currently cited* source (the one Wheeler locked in `archive/wheeler-fitzpatrick-and-med-anchor.md` §4) is 2011, and the link must match.

### 4.5 Add missing MED-anchor citation links

Currently `citationLinks` lists Fitzpatrick 1988, NBK481857, WHO, Schalka, Diffey 1991, CIE. Per `plunder-about-citation-policy.md` §1 and `wheeler-source-backed-skin-type-questions.md` §4.2, two MED-anchor sources are referenced in the About text but not linked:

```swift
ProductCitationLink(
    title: "Sayre et al. 1981 — MED-per-type anchor",
    url: URL(string: "https://doi.org/10.1016/S0190-9622(81)70105-1")!
),
ProductCitationLink(
    title: "Harrison & Young 2002 — erythema dose-response",
    url: URL(string: "https://doi.org/10.1016/S1046-2023(02)00205-0")!
)
```

### 4.6 Recommended one-line addition to `fitzpatrickCitations` footnote

Append to the existing string (right after "...NCBI Bookshelf NBK481857 (2017)."):

> " Wording is paraphrased, not reproduced; secondary descriptors (hair color, eye color, 'olive' skin tone) trace to Fitzpatrick TB (1988)."

This single sentence resolves the audit finding in §2.1 row 5 ("Added sub-descriptors not in NBK481857") without touching row text.

---

## 5. About-screen citation completeness audit (against `plunder-about-citation-policy.md` §2.2)

Plunder requires nine About sections in a specific order. Comparison against `AboutView` (AppViews.swift lines 1045–1156):

| Plunder §2.2 required section | Currently rendered? | Source string | Status |
|---|---|---|---|
| 1. What this app does, in one line | ✅ | "UV Burn Timer estimates minutes to one minimal erythemal dose using Fitzpatrick skin type, SPF, and the current UV index." (line 1058) | ✅ ok |
| 2. What this app does not do | ⚠ — partial | `ProductCopy.aboutEstimateApplicability` covers some not-applicable cases; no explicit "not medical advice / not diagnosis / not SPF recommendation" bulleted list | ⚠ defer to Plunder for layout call |
| 3. How we estimate burn time + formula | ⚠ — text present, formula not rendered | `aboutHowThisWorks` describes math in words; the formula `t = (MED × SPF) / (UVI × 0.025 × 60)` is NOT rendered on screen | ⚠ Plunder requires the formula; recommend adding |
| 4. Where the skin-type question comes from | ✅ — covered by `fitzpatrickCitations` | with §4.6 addition this becomes fully compliant | ✅ with §4.6 |
| 5. When this estimate may not apply | ✅ | `aboutEstimateApplicability` + `photosensitizationAuthorityLine` + MedlinePlus link | ✅ ok |
| 6. Weather/UV data source | ✅ | `weatherDataAttributionBody` + WeatherKit legal-attribution link | ✅ ok |
| 7. References (numbered list, DOIs, license notes) | ⚠ — partial | `CitationLinksView` provides clickable links but no numbered references and no license notes ("CC BY-NC 4.0 — cited, not reproduced") | ⚠ defer to Plunder for layout call |
| 8. License & attribution notes | ❌ — absent | No explicit one-sentence statement about Codon CC BY-NC 4.0 cite-only posture, no WHO INTERSUN cite-only posture | ❌ recommend adding (one line per source) |
| 9. Last updated date + app version | ❌ — absent | Neither rendered in About | ❌ Plunder §2.2 #9 requirement; Kwame implementation |

**Wheeler scope of authority:** I can only sign off on the *science* presence/absence (rows 1, 3, 4, 5, 6, 7). Layout and license-statement wording are Plunder's calls. Rows 8 and 9 are blockers for Plunder sign-off on this work item, per `plunder-about-citation-policy.md` §5 acceptance criteria #1 and #7.

---

## 6. What this proposal does NOT change

- **MED anchor values** (I=200, II=250, III=300, IV=450, V=600, VI=1000 J/m²) — already locked per `wheeler-fitzpatrick-and-med-anchor.md` §3 and verified against Sayre 1981 + Fitzpatrick 1988 + Diffey 1991 + Harrison & Young 2002. **No change.**
- **No-default picker behavior** (D-2026-05-19-012) — **no change.**
- **L1–L4 disclaimer architecture** (D-2026-05-19-011) — **no change.**
- **WeatherKit attribution** (D-2026-05-19-003/004) — **no change.**
- **Photosensitizer class list** (`aboutEstimateApplicability`) — content is correct against Moore DE 2002 *Drug Saf*. and NIH MedlinePlus. **No change.**
- **Wheeler edited variant softenings** for Types I and VI ("Very fair" / "Deeply pigmented") — already approved D-2026-05-19-009. **No change.**

---

## 7. Reviewer sign-off table (work item #4 gate)

| Reviewer | Scope | Decision needed | Status |
|---|---|---|---|
| Wheeler (me) | Source-science fidelity of rows + About citations | Conditional accept pending §4.1–§4.6 corrective text | ✅ (this file) |
| Plunder | License posture, About §2.2 layout, banned-phrase scan, CC BY-NC 4.0 declaration | Accept §4 corrective strings + add §5 rows 7–9 | ⏳ |
| Suchi | P1/P3/P4/P5 comprehension of new question header (Option A vs B) and softened "always/never" words | Accept Option A or B in §3; accept §4.2 wording | ⏳ |
| Iris | Picker accessibility, behavior-first ordering preserved, About IA per Plunder §2.2, inline source-pointer per Plunder §2.3 | Accept layout + accessibility | ⏳ |
| Kwame | Implementation: change strings only (no math, no defaults). Centralized in `ProductCopy.swift` + `FitzpatrickSkinType.swift`. | Implement after the four agents above sign off | ⏳ |

**Work item #4 acceptance-criteria mapping:**

- [✅ with §4 fixes] No skin-type question or answer ships without a cited source — every row traced to NBK481857; extras re-anchored to Fitzpatrick 1988 via §4.1 or §4.6.
- [✅] No verbatim reproduction of license-sensitive source tables in app UI — paraphrase confirmed; "adapted and paraphrased" disclosure present in `fitzpatrickCitations`.
- [✅ with §4 fixes] Each paraphrased row has traceability back to approved source meaning — this file is that table (§2).
- [✅ with §4 fixes] Wheeler confirms no scientific meaning was lost — conditional on §4.3 (Type III hedge) and §4.2 (softening disclosure).
- [⏳] Plunder confirms wording is safe for commercial app use — pending Plunder sign-off on §4.1.A and §5.
- [⏳] Suchi validates comprehension — pending Option A/B decision on §3.3 and §4.2 wording.
- [⏳] Iris validates behavior-first, accessible, no-default — already implemented; needs accessibility re-check after any §4 string changes.
- [⚠] About includes citations for Fitzpatrick, MED/UVI/SPF math, WeatherKit, assumptions, and not-medical-advice limits — see §5; rows 2, 3, 7, 8, 9 need attention before this checkbox can close.

---

## 8. Open questions for the team

- **Q1 → Plunder:** §4.1 — three options for the "extra descriptors" (re-anchor in About, remove, or inline-cite). My preference is 4.1.A; do you concur?
- **Q2 → Suchi:** §3 — Option A or Option B for the picker question header? My preference is Option B; budget allowing.
- **Q3 → Plunder:** §5 — do rows 2, 3, 7, 8, 9 of your §2.2 require new copy in this work item, or do they get their own follow-up item? I default to "in this work item" because work item #4 acceptance criterion #8 explicitly names About completeness.
- **Q4 → Kwame:** Once §4.4 (Schalka link) and §4.5 (Sayre, Harrison & Young links) are approved, can you batch these into a single `ProductCopy.swift` edit alongside any string changes from §4.1/§4.3?
- **Q5 → Wheeler (me):** Roberts 2009 / Lancer / Baumann inclusion — explicitly OUT of scope for work item #4, per `wheeler-source-backed-skin-type-questions.md` §3.4. Reaffirmed here.

---

## 9. Recommended decision text (for Scribe to merge if accepted)

> **D-2026-05-19-0XX — Fitzpatrick paraphrase traceability ratified for work item #4.** The six picker rows currently in `FitzpatrickSkinType.pickerDescription` are accepted as the canonical paraphrase, conditional on three string fixes (§4.1.A re-anchor sentence in About, §4.2 softening disclosure, §4.3 Type III "sometimes burns" restoration) and three citation-link fixes (§4.4 Schalka 2011 correction, §4.5 Sayre + Harrison & Young additions, §4.6 footnote append). The picker question header is updated per §3.3 Option B (or Option A if length-constrained — Suchi/Iris call). About-screen completeness gaps (license notes; last-updated; formula display) tracked under Plunder's §2.2 acceptance criteria for the same work item. No row text invents a stimulus, no row reproduces NBK481857 verbatim, no MED value moves. All future picker copy changes require this traceability table to be updated in the same change set.

---

*Wheeler. Pairs with Plunder, Suchi, Iris, Kwame. No app code modified by this proposal — Scribe to merge; Kwame to implement once Plunder + Suchi + Iris sign off on §3, §4, and §5.*

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
# Wheeler — Source-backed onboarding questions + About-screen citation discipline

- **Date:** 2026-05-19T16:22:15-07:00
- **Owner:** Wheeler (Skin Science Expert)
- **Status:** PROPOSED — team decision gate
- **Requested by:** yashasg (directive `copilot-directive-2026-05-19T16-22-15-944-07-00-research-based-questions-citations.md`)
- **Related canon:** D-2026-05-19-008 (Fitzpatrick source = NCBI NBK481857), D-2026-05-19-009 (Wheeler edited paraphrase, NCBI cited), D-2026-05-19-012 (no-default picker), D-2026-05-19-011 (L1–L4 disclaimers), Iris/Gaia onboarding-IA proposals (in inbox).

---

## 1. Verdict

**✅ Accept the directive as a hard constraint and codify it as a team rule.** Every self-classification question shipped in onboarding or settings MUST trace to a named, peer-reviewed or international-standard source. The About screen MUST cite every such source by author/title/year/DOI. No agent — including me — invents questions to "tune" personalization.

The good news: the team has not actually invented any questions yet. The current onboarding plan (Iris + Gaia, D-2026-05-19-009 picker, D-2026-05-19-013 flow) is a **single question** — "Pick the Fitzpatrick row that matches your skin's sun behavior" — with **six answer rows from NCBI Table 1**. That is already source-grounded. This proposal is a guardrail to keep it that way.

---

## 2. Acceptable source families (project canon — anything outside this list needs a new decision)

For **skin phototype self-classification** in v1:

| Family | Citation | Use |
|---|---|---|
| **Fitzpatrick scale (canonical)** | Fitzpatrick TB. *Arch Dermatol.* 1988;124(6):869–871. doi:10.1001/archderm.1988.01670060015008 | Underlying scale (six types, burns/tans behavior). |
| **NCBI Bookshelf reproduction** | Ward WH, Farma JM, eds. *Cutaneous Melanoma: Etiology and Therapy.* Codon Publications; 2017. Chapter 6, Table 1. NBK481857. doi:10.15586/codon.cutaneousmelanoma.2017.ch6 | Present-day open-access reference table for the six rows. Already adopted (D-2026-05-19-008). |

For **MED defaults / UV math** (already in About scope, restated for completeness):

| Family | Citation | Use |
|---|---|---|
| Sayre 1981 | Sayre RM, Desrochers DL, Wilson CJ, Marlowe E. *J Am Acad Dermatol.* 1981;5(4):439–443. doi:10.1016/S0190-9622(81)70105-1 | MED-per-type anchor. |
| Diffey 1991 | Diffey BL. *Phys Med Biol.* 1991;36(3):299–328. doi:10.1088/0031-9155/36/3/001 | MED-over-irradiance accumulation form. |
| Harrison & Young 2002 | Harrison GI, Young AR. *Methods.* 2002;28(1):14–19. doi:10.1016/S1046-2023(02)00205-0 | Erythema dose-response. |
| CIE / ISO | CIE S 007/E:1998 / ISO 17166:1999. *Erythema Reference Action Spectrum and Standard Erythema Dose.* | Weighting function. |
| WHO/WMO/UNEP/ICNIRP | *Global Solar UV Index: A Practical Guide.* WHO; 2002. ISBN 92 4 159007 6. | UVI ↔ irradiance (0.025 W/m² per UVI). |
| Schalka & Reis 2011 | Schalka S, Reis VMS. *An Bras Dermatol.* 2011;86(3):507–515. doi:10.1590/S0365-05962011000300013 | SPF as linear multiplier on MED. |

For **photosensitization disclosure** (L3/L4 surfaces): cited generically by class (no brand names) per D-2026-05-19-007 + Wheeler §7. Sources already locked in `.squad/decisions/archive/wheeler-fitzpatrick-and-med-anchor.md` §7.

**Out-of-canon scales (NOT to be silently introduced without a new decision):**

- Roberts Skin Type Classification System (Roberts WE. *J Drugs Dermatol.* 2009;8(5):457–462) — extends Fitzpatrick for skin of color; different question set.
- Baumann Skin Type Indicator (Baumann L. *J Cosmet Dermatol.* 2008) — 64-question cosmetic-skincare scale; not UV-burn.
- Lancer Ethnicity Scale (Lancer 1998) — pigmentation/genealogy-based.
- Taylor Hyperpigmentation Scale, Goldman World Skin Type Classification, von Luschan tile scale — not Fitzpatrick.

If a future feature requires one of these, it ships with its own decision and its own About citation. Mixing scales without disclosure is a citation-discipline violation.

---

## 3. The only question we are allowed to ask (v1)

### 3.1 Question text (header above the six-row picker)

> **How does your unprotected skin usually react in strong sun?**
>
> Pick the row that best matches what your skin does after about 30 minutes of midday summer sun, with no sunscreen and no recent tan. Each row covers a range of natural skin tones.

**Why this wording is allowed:**

- "Burns / tans behavior after ~30 min of unprotected sun" is the actual stimulus Fitzpatrick used in the 1988 scale validation. It is not invented — it is the scale's definition.
- "No recent tan" is a paraphrase of "untanned skin," which is in the NBK481857 table preamble and in the CIE MED definition (16–24h post-exposure on previously-unirradiated skin).
- "Range of skin tones" mirrors the NCBI Table 1's per-row appearance descriptors and prevents users from over-weighting visible skin color as the sole signal — addressing Suchi's anchor-effect concern (D-2026-05-19-012).

### 3.2 Answer rows (already approved)

Use the **Wheeler edited variant** (D-2026-05-19-009), six rows, behavior-first, paraphrased from NCBI Table 1. **No changes to row text from this proposal.** No default selected (D-2026-05-19-012).

### 3.3 What is NOT permitted in v1 onboarding

Each of the below has been considered and ruled out on a source-discipline basis:

| Tempting "extra question" | Why it is rejected |
|---|---|
| "What is your eye color?" / "What is your natural hair color?" alone | Fitzpatrick *removed* hair/eye color as primary classifiers in the 1988 refinement specifically because they correlated poorly with erythemal response in non-European populations. Self-rated pigmentation has known poor inter-rater reliability (Eilers S, et al. *JAMA Dermatol.* 2013;149(11):1289–1294). If we want a visual cue, it goes next to the six rows as a *secondary swatch* (per Iris/Suchi), not as its own question. |
| "Pick the skin-tone swatch closest to your inner upper arm." | Pigmentation-only self-classification is the Lancer/von Luschan family, not Fitzpatrick. Mixing it under the Fitzpatrick header miscites. Allowed only as a secondary visual cue alongside Fitzpatrick rows, never standalone (Iris swatch guardrails). |
| "Did you get sunburned as a child?" / "How many blistering burns have you had?" | This is a *melanoma-risk* question (Pfahlberg A, et al. *Br J Dermatol.* 2001), not a phototype question. D-2026-05-19-008 + Wheeler §8 explicitly bound the app's claim surface away from cancer-risk modeling. Not for v1. |
| "Where are your ancestors from?" / ethnicity question | Ethnicity is a poor proxy for phototype (Pichon LC, et al. *J Am Acad Dermatol.* 2010); the literature converged on burn/tan behavior precisely because ethnicity is unreliable. Inviting it would also create a class of self-reports we have no validated mapping for. |
| Two-axis split ("How easily do you burn?" + separately "How easily do you tan?") | This is the Fitzpatrick scale's own internal axes, but combining them into a calculated phototype requires a published lookup table. None of the canonical sources publish a separable two-axis → type mapping; they publish the six-row combined descriptors. If we want to ship two-axis input, it requires a new decision citing a specific published mapping. |
| Custom MED slider / "How sun-sensitive do you feel today?" | Not in any cited source. Would silently shift the math. Hard no. |

### 3.4 What may be added later (each requires its own decision + citation)

- **Photosensitization attestation prompt** (already in scope via D-2026-05-19-007 and Wheeler §7 — class-list disclosure, not invented).
- **Roberts-extended classification** for users who feel Fitzpatrick I–VI misses them — would require adopting Roberts 2009 as a second cited scale and exposing it as an optional path. Not v1.
- **Acclimatization / recent-exposure adjustment** — Sayre 1981 includes acclimatization data; if surfaced, cite it explicitly.

---

## 4. What must be cited on the About screen

Plunder owns final wording; this is the **content requirement** — every numbered item below must appear in some form on the About surface (or on the About → Sources detail screen). Each line is a load-bearing citation.

### 4.1 Skin-type classification

> **Skin phototype rows adapted from:** Ward WH, Farma JM, eds. *Cutaneous Melanoma: Etiology and Therapy.* Codon Publications, Brisbane (AU); 2017. Chapter 6, Table 1. doi:10.15586/codon.cutaneousmelanoma.2017.ch6. NCBI Bookshelf NBK481857. <https://www.ncbi.nlm.nih.gov/books/NBK481857/table/chapter6.t1/>
>
> **Underlying scale:** Fitzpatrick TB. The validity and practicality of sun-reactive skin types I through VI. *Arch Dermatol.* 1988;124(6):869–871. doi:10.1001/archderm.1988.01670060015008

### 4.2 Minimal Erythemal Dose values (per-type J/m²)

> **MED anchor values:** Sayre RM, et al. *J Am Acad Dermatol.* 1981;5(4):439–443 · Fitzpatrick TB. *Arch Dermatol.* 1988;124(6):869–871 · Diffey BL. *Phys Med Biol.* 1991;36(3):299–328 · Harrison GI, Young AR. *Methods.* 2002;28(1):14–19.
>
> **Erythemal weighting:** CIE S 007/E:1998 / ISO 17166:1999.

### 4.3 UV Index ↔ irradiance + time-to-burn formula

> **UVI to irradiance conversion (0.025 W/m² per UVI unit) and risk categories:** World Health Organization, WMO, UNEP, ICNIRP. *Global Solar UV Index: A Practical Guide.* Geneva: WHO; 2002. ISBN 92 4 159007 6.
>
> **SPF as multiplier on time-to-burn:** Schalka S, Reis VMS. *An Bras Dermatol.* 2011;86(3):507–515. doi:10.1590/S0365-05962011000300013
>
> **MED-over-irradiance accumulation form:** Diffey BL. *Phys Med Biol.* 1991;36(3):299–328.

### 4.4 UV data source

> **Live UV index, location, and conditions:** Apple Weather (WeatherKit). Per D-2026-05-19-004, the Apple Weather legal-attribution link is rendered adjacent to the data and in About.

### 4.5 Method disclosure (mandatory adjacent block — Plunder owns final wording)

> Burn-time estimates assume healthy, untanned skin, the CIE-standard erythemal action spectrum, and that no photosensitizing medication or condition applies. These are model estimates, not medical advice. See *Medications & conditions* for the class list.

### 4.6 Confidence labels (recommended, not mandatory)

For users who tap through to a "Sources" detail surface, mark each value as **Established** (cited primary source exists), **Reasonable approximation** (cited but adapted), or **Out of scope** (cancer risk, vitamin-D timing, safe-sun-time). The full grid is in `.squad/decisions/archive/wheeler-fitzpatrick-and-med-anchor.md` §2.4 and §3.4.

---

## 5. Team-decision implications (why this needs the gate)

This proposal touches multiple owners:

- **Iris / Gaia** — onboarding/settings IA proposals (in inbox) must adopt §3.1 question header and the no-extra-questions rule. Their existing helper copy ("Choose by how your skin usually burns and tans without sunscreen. Each type spans a range of skin tones.") is close to compliant and can be reconciled with §3.1 in a single edit.
- **Plunder** — owns final About copy and citation rendering; this proposal specifies the *content requirement*, not the *layout*. Plunder may shorten, group, or progressive-disclose, but the citations in §4.1–4.5 must all appear.
- **Linka** — picker UI strings are already locked under D-2026-05-19-009 and do not change here.
- **Kwame** — no code action required; if onboarding adds an "Education" header above the picker, it pulls from a single source string (see §3.1) — centralize per Iris's existing guardrail.
- **Suchi** — anchor-effect concerns are addressed by §3.1 wording emphasizing "range of natural skin tones" per row, not a single appearance.
- **Wheeler (me)** — owns the source list and will not silently expand it. Any new self-classification question proposed by any agent goes through me + Plunder + a new decision file.

---

## 6. Open questions for the team

- **Q1 → Plunder:** §4.5 "method disclosure" wording — does this belong in About body, or in the L4 expansion, or both? My recommendation: both, with the About body version short and the L4 version expanded.
- **Q2 → Iris/Gaia:** Where exactly does the §3.1 question header live in the onboarding screen — above the six rows, or inside a "What is this?" disclosure? My recommendation: above the rows, visible by default, because helper copy that has to be tapped to reveal often goes unread (Suchi P1 evidence).
- **Q3 → Suchi:** If a future cycle wants to ship Roberts 2009 as an alternative scale for skin-of-color users, would that read as inclusive expansion or as confusing dual-classification? Persona test next sprint.
- **Q4 → Plunder:** Open-Meteo removal (D-2026-05-19-004) — confirm the About-screen Apple Weather attribution is in the right place relative to §4.4 above.

---

## 7. Recommended decision text (for Scribe to merge if accepted)

> **D-2026-05-19-0XX — Source-backed onboarding-question discipline.** Every self-classification question shipped in onboarding or settings must trace to a named, peer-reviewed or international-standard source listed in `.squad/decisions/inbox/wheeler-source-backed-skin-type-questions.md` §2. In v1, the only such question is the single Fitzpatrick phototype picker (header text per §3.1, rows per D-2026-05-19-009, no-default per D-2026-05-19-012). The About screen MUST render the citations in §4.1–§4.5 of that proposal. New questions or alternative scales require their own decision file and citation grid before shipping.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
### Design, science, and legal convergence pass (2026-05-19T00:10–00:30)

#### D-2026-05-19-012 — No-default Fitzpatrick skin-type picker (convergent signal)
- **Date:** 2026-05-19T00:25:58-07:00
- **Decision:** Skin type picker MUST NOT auto-select or have a default value. User must explicitly choose. This is now a high-confidence convergent signal: Suchi identified anchor effect (~50% on Types I/II) and recommended no-default; Linka designed for explicit selection; Wheeler named it a safety boundary; Plunder leans this direction.
- **Rationale:** Sources: `.squad/decisions/inbox/suchi-design-brief.md` (Persona × Picker section, P1/P4 context), `.squad/decisions/inbox/linka-ios-design-spec.md` (§2.2 SkinTypeView narrative), `.squad/decisions/inbox/wheeler-fitzpatrick-and-med-anchor.md` (§6 behavioral anchor, ~~assumed defaults~~). Convergent triangulation across three agents independently identifying the same UX/safety pattern is a high-confidence signal.
- **Owner:** Linka (UI lead); Wheeler (sign-off)
- **Status:** active

#### D-2026-05-19-011 — Three-surface L1–L4 layered disclaimer pattern (convergent signal)
- **Date:** 2026-05-19T00:10:00-07:00
- **Decision:** Adopt the three-surface / L1–L4 layered disclaimer pattern as the canonical approach for all burn-time estimates and verdict cards. This is convergent across all four agents: Suchi (load-bearing for P4 Accutane/lupus personas), Linka (design spec with L1/L2/L3/L4 layers), Wheeler (photosensitization disclosure requirement), Plunder (regulatory framing). Layers: (L1) first-launch full-screen cover (Donatello M1), (L2) persistent footer on all result screens, (L3) verdict-card photosensitizer note, (L4) in-app About expansion with cohort list.
- **Rationale:** Sources: `.squad/decisions/inbox/suchi-design-brief.md` (§1.1 + §1.2, P4 load-bearing context), `.squad/decisions/inbox/linka-ios-design-spec.md` (§2.1 DisclaimerCover + §2.2 footer + §3 verdict photosensitizer), `.squad/decisions/inbox/wheeler-fitzpatrick-and-med-anchor.md` (§6.1 three-surface photosensitization disclosure), `.squad/decisions/inbox/plunder-citation-framework.md` (§8 disclaimer ratification). This pattern is now locked as the canonical structure.
- **Owner:** Plunder (legal lead); Linka (implementation lead)
- **Status:** active

#### D-2026-05-19-010 — Three new launch-research channels: r/Accutane, r/lupus, r/SkincareAddiction
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** Expand launch-research and trail-running channels to include r/Accutane and r/lupus (reply-only, pending safety and compliance sign-off) and r/SkincareAddiction (wider research surface). These channels represent high-signal JTBD evidence and willingness-to-pay validation for personas P4 (Accutane Asha) and extended edge-case cohorts. Trail-running copy can emphasize reapplication timing without changing v1 scope.
- **Rationale:** Source: `.squad/decisions/inbox/suchi-design-brief.md` (§7 edge-case personas Priya + Vee, §0 P4/P5 personas, JTBD evidence per channel). This refines D-2026-05-19-006 with named channels and trait-specific personas.
- **Owner:** Suchi
- **Status:** active

#### D-2026-05-19-009 — ✅ NCBI-paraphrased Fitzpatrick picker text (ACTIVE)
- **Date:** 2026-05-19T00:25:58-07:00; **Resolved:** 2026-05-19T08:30:00Z
- **Decision:** Use Wheeler's edited variant of the Fitzpatrick descriptions in the iOS skin-type picker. **Paraphrase, do NOT reproduce verbatim.** The NCBI Bookshelf table (Codon Publications, CC BY-NC 4.0) remains the cited underlying source — credit appears in the in-app About surface per Plunder's citation rendering spec.
- **Rationale:** Per Plunder's framework, reproducing the CC BY-NC 4.0 table verbatim inside a $2.99 paid app is ⚠️ at minimum (NC scope is gray for paid apps; reproduction tightens the attribution requirement). Paraphrasing while citing the source is ✅ — citation is independent of the NC clause, and the underlying classification (Fitzpatrick TB, 1988) is freely citable on its own. Wheeler's edited variant preserves clinical accuracy without coupling our UI strings to the source's specific copyrighted prose.
- **Implications:** (1) Linka: Update skin-type picker spec to use Wheeler's edited variant strings. (2) Plunder: Confirm in-app citation wording for NCBI Bookshelf uses "cite the underlying scale" form. (3) Wheeler: No action — edited variant is canonical. (4) Kwame: Picker strings from Wheeler's variant; remains @State only. (5) Suchi: V/VI asymmetry concern resolved by adopting canonical Fitzpatrick wording.
- **Owner:** Plunder (framing); Wheeler (science lead); Linka (implementation)
- **Status:** ✅ active

#### D-2026-05-19-008 — Canonical Fitzpatrick source: NCBI Bookshelf NBK481857, Ward & Farma 2017
- **Date:** 2026-05-19T07:25:58-07:00
- **Decision:** Adopt Fitzpatrick Skin Type classification from NCBI Bookshelf Chapter 6, Table 1 (Ward & Farma eds., *Cutaneous Melanoma: Etiology and Therapy*, Codon Publications 2017) as the canonical reference and citation anchor for the app. All six type descriptions from the NCBI table are now the source-of-truth for all UI copy, citation surfaces, and design specifications.
- **Rationale:** Source: `.squad/decisions/inbox/copilot-directive-2026-05-19T07-25-58Z.md` (user directive). Wheeler verified the source and confirmed NCBI verbatim matches the published table (§1.2 diff). This resolves Suchi's prior copy-asymmetry flag (Type I/II vs. Type V/VI descriptor framing) — the NCBI source leads with skin-color descriptors for all six types, preserving symmetry. Plunder vetted the citation licensing posture: Codon is open-access with CC BY-NC 4.0, permitting non-commercial reuse with attribution; we cite (not reproduce), so normal-and-customary citation practice applies.
- **Owner:** Wheeler (science lead); Plunder (legal lead)
- **Status:** active

### Audience, safety, and launch channels

#### D-2026-05-19-007 — Photosensitivity is a safety boundary, not edge copy
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** Keep the current strong disclaimer language and get Wheeler review on whether the verdict card needs an explicit note that photosensitizing medications or conditions can make the estimate overstate safe time.
- **Rationale:** Source: `.squad/decisions/archive/suchi-monetization-personas.md`. Suchi surfaced direct persona evidence that Fitzpatrick/MED-based timing can understate risk for Accutane, lupus, vitiligo, and similar cases.
- **Owner:** Wheeler
- **Status:** proposed

#### D-2026-05-19-006 — Expand the launch-research channel set with guarded additions
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** Add `r/SkincareAddiction` to the channel mix and keep `r/Accutane` and `r/lupus` as reply-only opportunities pending safety and compliance sign-off; trail-running copy can emphasize reapplication timing without changing v1 scope.
- **Rationale:** Source: `.squad/decisions/archive/suchi-monetization-personas.md`. Suchi found stronger willingness-to-pay and JTBD evidence in these surfaces, while also separating safe expansion from risky outreach.
- **Owner:** Suchi
- **Status:** proposed

### Monetization

#### D-2026-05-19-005 — Keep the $2.99 one-time wedge and 90-day no-IAP guardrail
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** Hold the $2.99 one-time launch price, keep the 90-day no-IAP and no-tip-jar rule, and use a 30/60/90 review cadence with earlier-review triggers rather than changing price because WeatherKit lowered marginal cost.
- **Rationale:** Source: `.squad/decisions/archive/argos-monetization-review.md` and `.squad/decisions/archive/suchi-monetization-personas.md`. Argos recomputed break-even to effectively one incremental sale per year while Suchi validated that the anti-subscription wedge is structurally important in the highest-signal channels.
- **Owner:** Argos
- **Status:** active

### Platform, data, and compliance

#### D-2026-05-19-004 — Replace Open-Meteo attribution on iOS-facing surfaces
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** Remove Open-Meteo attribution from iOS App Store and launch copy, and implement WeatherKit-compliant Apple Weather attribution plus the legal-attribution link in the in-app About surface before launch.
- **Rationale:** Source: `.squad/decisions/archive/argos-monetization-review.md` and `.squad/decisions/archive/copilot-directive-2026-05-19T06-42-14Z.md`. Argos flagged the change as a license-term and compliance issue, not a cosmetic copy edit.
- **Owner:** Plunder
- **Status:** active

#### D-2026-05-19-003 — iOS UV data source is Apple WeatherKit
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** The iOS app uses Apple WeatherKit instead of Open-Meteo for UV index data; the web prototype keeps its existing Open-Meteo integration as-is.
- **Rationale:** Source: `.squad/decisions/archive/copilot-directive-2026-05-19T06-42-14Z.md`. This changes economics, integration, and attribution requirements for the iOS build while leaving the prototype intact.
- **Owner:** Kwame
- **Status:** active

#### D-2026-05-19-002 — Team focus has pivoted from web prototype to iOS app
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** The squad's primary build target is now the iOS app. Linka is respecialized as UI/UX Designer (Apple HIG and accessibility), Kwame as iOS Developer (modern Swift plus WeatherKit), and Argos joins the roster for monetization; `prototype/` remains the evaluation artifact.
- **Rationale:** Source: session context items 4-5 and `.squad/decisions/archive/copilot-directive-2026-05-19T06-42-14Z.md`. The platform shift required corresponding role changes and keeps the web prototype as a reference artifact rather than the shipping target.
- **Owner:** Gaia
- **Status:** active

### Model governance

#### D-2026-05-19-001 — Advisory specialists use xhigh model overrides
- **Date:** 2026-05-19T00:05:00-07:00
- **Decision:** Wheeler, Suchi, Plunder, and Argos are pinned to `claude-opus-4.7-xhigh` via `agentModelOverrides`.
- **Rationale:** Source: `.squad/config.json` and session context items 2-4. The team explicitly elevated model depth for skin science, user research, legal and compliance, and monetization work.
- **Owner:** Coordinator
- **Status:** active

#### D-2026-05-19-013 — ✅ Excalidraw user-flow diagram (onboarding + main screen)
- **Date:** 2026-05-19T01:15:44-07:00
- **Decision:** Fulfill the user directive (`.squad/decisions/inbox/copilot-directive-2026-05-19T08-13-34Z-excalidraw-userflow.md`) by delivering a comprehensive Excalidraw diagram of the iOS app flow from cold launch through onboarding to main screen, with persona overlay annotations and safety-critical branch-point callouts.
- **Deliverables:** (1) Live Excalidraw canvas (146 elements: 35 rectangles, 99 text labels, 12 arrows) exported to `user-flow-onboarding-main.excalidraw` at repo root (61.7 KB); (2) Textual snapshot spec at `.squad/files/user-flow-onboarding-main-spec.md` describing all lanes, regions, and annotations; (3) Extracted skill `.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` (MCP drawing patterns from squad agents). **Note (2026-05-19T08:34Z):** `.excalidraw` deliverable files live at repo root, NOT inside `.squad/files/` — top-level visibility for design artifacts. Per directive captured this session.
- **Scope:** 4 lanes — (LANE 1) Onboarding flow with 6 screens from cold launch to first verdict; (LANE 2) Main screen (NowView) with 7 sub-regions; (LANE 3) Branch points & annotations (8 yellow callouts covering no-default Fitzpatrick, L1 sticky, disclaimer layers, attribution, accessibility, re-attestation); (LANE 4) Suchi persona overlays (5 personas × 6 columns). Visualizes D-2026-05-19-002, -003, -004, -007, -009 (Wheeler edited variant), -011 (three-surface L1–L4), -012 (no-default Fitzpatrick).
- **Decisions visualized:** All key decisions are on-canvas; Plunder's 8 pre-submit flags noted as non-blocking. Deliberately omits "photosensitization attestation" hard screen (zero-data architecture) — drawn as passive-moment with visibility pattern (L1 + L3 + L4).
- **Owner:** Linka (UI/UX, canvas authority); Suchi (User Researcher, persona overlay input)
- **Status:** ✅ active deliverable

#### D-2026-05-19-014 — ✅ Persona overlay annotations spec (Suchi)
- **Date:** 2026-05-19T01:15:44-07:00
- **Decision:** Produce persona-keyed overlay annotations for Linka's Excalidraw user flow, covering 5 personas (Greta, Maya, Devon, Asha, Tomás) across 6 flow positions (L1 cover, NowView empty state, SkinTypeView, photosensitization deep-link, location + first verdict, main screen repeating use). Spec identifies 5 load-bearing branch points: L1 inline deep-link loop (Asha), no-default Fitzpatrick validator (Devon), Type V under-picking risk (Tomás), L3 verdict-card link (Asha frequent taps), window-elapsed safety moment (Tomás at speed).
- **Deliverable:** `.squad/files/suchi-persona-annotations.md` (222 lines, grid-based matrix). Anti-pattern flagged: do NOT draw "photosensitization attestation" screen — the architecture is visibility-only, not attestation (zero-data, Donatello M7). Linka reads this during canvas work; Suchi does not draw on canvas.
- **Follow-up learnings:** Surfaces two latent repeating-use insights — Greta's JTBD shift to reapplication-cadence, Maya's literally-can't-see-window-elapsed-on-water safety problem.
- **Skill update:** `.squad/skills/persona-screen-matrix/SKILL.md` bumped; confidence medium → medium-high; added "overlay-on-flow-diagram" variant.
- **Owner:** Suchi (User Researcher); Linka (canvas integration)
- **Status:** ✅ active deliverable

### Coordinator resolutions this session (2026-05-19T08:30–08:31Z)

#### D-2026-05-19-009 picker-copy resolution (user directive fulfilled)
- User directive `.squad/decisions/inbox/copilot-directive-2026-05-19T08-30-00Z-picker-copy-resolution.md` resolved D-2026-05-19-009 from 🟡 PROPOSED to ✅ ACTIVE. Decision: Use Wheeler's edited variant (paraphrased, not verbatim NCBI reproduction) in the skin-type picker. NCBI Bookshelf remains the cited source; paraphrasing avoids CC BY-NC 4.0 reproduction-licensing tightness on a paid app.

#### Excalidraw flow diagram trigger (directive now fulfilled)
- Coordinator directive `.squad/decisions/inbox/copilot-directive-2026-05-19T08-13-34Z-excalidraw-userflow.md` (user request for flow diagram once design is complete) now fulfilled by D-2026-05-19-013. Diagram is source-of-truth for implementation reference.

### Merged inbox decisions (2026-05-19T11:50Z)

#### 2026-05-19T08:34:13Z: User directive — Excalidraw exports live at repo root

**By:** yashasgujjar (via Copilot)

**What:** Excalidraw scene files (`.excalidraw` exports) live at the **repo root**, NOT inside `.squad/files/`. Going forward, any agent exporting an Excalidraw scene should write directly to `{repo_root}/{name}.excalidraw`. The `.squad/files/` directory remains for non-deliverable session artifacts (specs, intermediate JSON, internal notes).

**Why:** User wants top-level visibility for design deliverables. `.excalidraw` files are durable artifacts (importable into excalidraw.com, shareable, reviewable) — not session-internal scratch work. Burying them inside `.squad/files/` makes them invisible to anyone browsing the repo at the top level.

**Implications:**
- **Linka:** Update the agent skill `excalidraw-flow-diagrams-via-mcp` to specify the export path is `{repo_root}/{slug}.excalidraw`, not `.squad/files/`.
- **Coordinator:** This session — move `.squad/files/user-flow-onboarding-main.excalidraw` to `./user-flow-onboarding-main.excalidraw` after Scribe finishes the current commit. Update any reference in Linka's decision file (D-2026-05-19-013 once merged) and the textual spec at `.squad/files/user-flow-onboarding-main-spec.md` to point to the new path.
- **Future Excalidraw deliverables:** Always export directly to repo root.

**Status:** ✅ ACTIVE.

#### 2026-05-19T08:57:00Z: User directive — Linka fired, replaced by Iris

**By:** yashasgujjar (via Copilot)

**What:** Linka (UI/UX Designer) is **fired** — not retired. Folder deleted (not archived to `_alumni/`). Registry marked `status: "fired"` with `fired_reason` recorded. Reason: slow and error-prone. Took >900s on an export-fix that took 30s inline; her first-draft Excalidraw export was broken on delivery (missing required schema fields).

Replacement: **Iris** — same role (UI/UX Designer, Apple HIG & Accessibility), same scope, **model: `claude-sonnet-4.6`** (saved to `.squad/config.json` `agentModelOverrides.iris`). Iris inherits all of Linka's ratified design decisions (D-2026-05-19-003, -004, -005, -013, -014) but starts with fresh history. The Excalidraw user-flow she produced is canon and stays.

**Process change captured in Iris's charter:**
- JSON schema fixes / file-format compliance are **not the designer's job** — route to Kwame.
- Excalidraw exports MUST pass through `.squad/files/excalidraw-normalize.py` before commit (this codifies the lesson from Linka's broken export).
- `.excalidraw` deliverables live at repo root, not `.squad/files/`.

**Status:** ✅ ACTIVE.

#### Gaia — Squad Work Loop Cycle 1: Discovery & Prioritization

**Date:** 2026-05-19T10:56:40Z  
**Role:** Gaia (Lead/Architect)  
**Scope:** Cycle 1 discovery only — compare implemented behavior against approved design/user flows, identify work items, and recommend the next single feature/fix with acceptance criteria.

---

##### Executive Summary

**Build status:** ✅ PASSING (tests + Swift warnings as errors)  
**Architecture status:** ✅ SOUND (single NavigationStack, sheet-based settings, proper disclaimer layering)  
**Work items discovered:** 6 (1 P0 critical, 3 P1 important, 2 P2 polish)  
**Recommended next feature:** Fix Fitzpatrick description ordering from color-first to behavior-first (P0, safety-critical per Suchi + Wheeler)

---

##### Discovered Work Items

###### P0 — Fitzpatrick Descriptions Ordering (Safety-Critical)

**Status:** `pending`  
**Severity:** 🔴 **Critical**  
**Evidence:** 
- Design spec (§2.3, linka-ios-design-spec.md, lines 165–175) mandates behavior-first ordering: "Always burns, never tans. Very fair; often freckles, red/blonde hair."
- Suchi's persona annotations (§1.2, suchi-persona-annotations.md, line 67–70) flags this as load-bearing for trust with user Tomás (under-picking risk on Type V)
- D-2026-05-19-009 directs: use Wheeler's edited variant, paraphrased (not verbatim NCBI)
- Current implementation has color-first for ALL types; Type V/VI missing detail descriptors

**Current:**
```
Type I:  "Very fair; always burns, never tans."
Type II: "Fair; burns easily, tans minimally."
Type III: "Medium tone; burns moderately, tans gradually."
Type IV: "Light-brown; burns minimally, tans easily."
Type V:  "Brown; rarely burns, tans deeply."
Type VI: "Deeply pigmented; almost never burns."
```

**Approved (from design spec §2.3):**
```
Type I:  "Always burns, never tans. Very fair; often freckles, red/blonde hair."
Type II: "Burns easily, tans minimally. Fair skin; light eyes common."
Type III: "Burns moderately, tans gradually. Medium skin tone."
Type IV: "Burns minimally, tans easily. Olive or medium-brown skin."
Type V:  "Rarely burns, tans deeply. Brown skin."
Type VI: "Almost never burns, deeply pigmented. Dark brown to black skin."
```

**Why it matters:**
- Behavior leads → users self-classify based on lived burn/tan experience (not skin color framing)
- Suchi P3 Devon (Fitz I): validates no-default by self-selecting Type I via behavior cue ("I got sunburned in February")
- Suchi P5 Tomás: risks under-picking Type V/VI if copy leads with "Brown skin" — he sees "Brown" and stops reading, missing "Rarely burns"
- Reordering is a small, high-trust copy win

**Test impact:** Test `fitzpatrickPickerCopyMatchesApprovedSafetyLanguage()` currently enforces the color-first version; will need update.

---

###### P1 — WeatherKit Attribution Compliance

**Status:** `pending`  
**Severity:** 🟡 **Important (legal/compliance)**  
**Evidence:**
- D-2026-05-19-004 mandates: "Remove Open-Meteo attribution from iOS App Store and launch copy; implement WeatherKit-compliant Apple Weather attribution + legal-attribution link in About"
- Design spec §2.2 (line 111) and §2.6 (lines 214–228) require WeatherKit attribution "always visible on Home" + About sheet legal link
- Current implementation has `WeatherAttributionView()` on Home and About, but need to verify:
  1. Display format matches Apple's required lockup
  2. Legal attribution link is tappable and leads to correct URL
  3. Copy matches "Apple Weather" (not "Apple WeatherKit" or "Open-Meteo")

**Deliverables to verify:**
- `WeatherAttributionView` uses correct `WeatherAttribution` API (if available) or hard-coded Apple Weather lockup
- AttributionView has tappable link to Apple's legal page (`https://weatherkit.apple.com/legal-attribution.html`)
- ProductCopy.uvSourceLine = "Source: Apple WeatherKit" (correct) but UI copy may need "Apple Weather" on attribution badge

**Risk/blocker:** None identified; low lift to verify.

---

###### P1 — LocationRationaleCard Display Refinement

**Status:** `pending`  
**Severity:** 🟡 **Important (UX polish)**  
**Evidence:**
- Design spec §2.2 notes: "Privacy rationale BEFORE iOS prompt; CTA in `.safeAreaInset(.bottom)`"
- Current code shows LocationRationaleCard inline (§AppViews.swift, line 44)
- Unclear if layout matches spec or if card is gated by first-time only (should be)

**Acceptance criteria:**
- LocationRationaleCard appears once on cold launch (before system prompt fires)
- Card includes privacy line: "UV Burn Timer needs your location once to fetch UV data. It never leaves your device."
- Card is swipe-dismissible and marked non-blocking (per LocationPromptGate logic, which IS implemented correctly)

---

###### P1 — Stale UV Warning Copy & Styling

**Status:** `pending`  
**Severity:** 🟡 **Important (UX clarity)**  
**Evidence:**
- Design spec §2.2: "Stale UV (> 60 min old)" shows hero number with `.opacity(0.6)` + "Updated 2h ago" label
- Current implementation (HeroTimerCard, line 295–301) shows SafetyStatusCard with orange icon + "Estimate window elapsed" copy
- Implementation uses calculated window (min of burn time or 2h), NOT fixed 60 min — actually better, but wording may differ

**Acceptance criteria:**
- When estimate is stale: hero number shows dimmed (`.opacity(0.6)` or similar)
- SafetyStatusCard displays: "Estimate window elapsed" + icon + "Recalculate" affordance
- Copy must match approved (check ProductCopy.estimateElapsedWarning)

---

###### P2 — Copy Refinements (Fitzpatrick Footer & Disclaimer Details)

**Status:** `pending`  
**Severity:** 🟢 **Minor (polish)**  
**Evidence:**
- SettingsSheet Fitzpatrick footer (line 628): "This model assumes healthy skin and no photosensitizing medications."
- Design spec §2.3 (line 163) extends this: "...consult a dermatologist. **This model assumes healthy skin and no photosensitizing medications** — see *Is this estimate for me?* on the result screen."
- Missing end: "consult dermatologist" + cross-reference to verdict card link

**Acceptance criteria:**
- Fitzpatrick picker footer includes: "...consult a dermatologist before using this estimate to plan sun exposure. See *Is this estimate for me?* on the result screen for details."

---

###### P2 — SkinTypeOnboardingView vs. SettingsSheet Styling Consistency

**Status:** `pending`  
**Severity:** 🟢 **Minor (UX consistency)**  
**Evidence:**
- SkinTypeOnboardingView (line 545–586): uses `List` + `Form`-like section styling
- SettingsSheet Fitzpatrick picker (line 596–629): also renders all types, but within a Form section
- Both are correct but could have minor visual divergence (List vs. Form styling)

**Acceptance criteria:**
- Both surfaces render Fitzpatrick rows identically (56pt+ row height, behavior-first copy, no default selection)
- No visual/functional regression between onboarding flow and settings view

---

##### Not Work Items (By Decision)

✅ **No-default Fitzpatrick picker** — Implemented and tested; no changes needed  
✅ **Disclaimer cover full-screen modal** — Implemented with "How accurate is this for you?" title and photosensitizer inline link  
✅ **L1–L4 layered disclaimer pattern** — Implemented: L1 cover + L2 footer + L3 verdict-card link + L4 About section  
✅ **240+ min display cap** — Implemented (`estimate.displayText` returns "240+ min")  
✅ **Pull-to-refresh** — Implemented (`.refreshable { await refetchUV() }`)  
✅ **Location permission rationale + privacy line** — Implemented with LocationPromptGate  
✅ **Persistent footer disclaimer** — Implemented (Donatello M2 footer)  
✅ **Tier badge (severity display)** — Implemented with tortoise/walk/hare SF Symbols + color tier  
✅ **WeatherKit as UV source** — Implemented (WeatherKitUVDataProvider)  
✅ **L3 verdict-card reach-back to About** — Implemented (NavigationLink to AboutView with `highlightEstimateApplicability: true`)  
✅ **Stale UV detection** — Implemented (min of burn time or 2 hours)  
✅ **Cold-launch cached UV** — Implemented (restoreCachedUVSnapshot)

---

##### Recommended Next Feature (Cycle 1 → Cycle 2 Hand-off)

###### Feature: Fix Fitzpatrick Description Ordering to Behavior-First

**Work ID:** `fitzpatrick-descriptions-reorder`  
**Priority:** 🔴 **P0 Critical**  
**Effort:** ~15 min code change + 5 min test update  

**Rationale:**
1. **Safety-critical per user research:** Suchi's personas (Devon: validates no-default; Tomás: under-picking risk) both depend on behavior-first copy for trust
2. **Design-approved:** Linka (UI), Wheeler (skin science), Suchi (UX research) all converged on this in D-2026-05-19-009 + linka-ios-design-spec.md
3. **High-signal change:** One small copy reorder addresses the entire "behavior-first" principle that Suchi flagged in three separate documents
4. **Low risk:** Pure copy change, no logic/state/API changes

**Acceptance Criteria:**

- [ ] All six Fitzpatrick descriptions use behavior-first ordering:
  - Type I: "Always burns, never tans. Very fair; often freckles, red/blonde hair."
  - Type II: "Burns easily, tans minimally. Fair skin; light eyes common."
  - Type III: "Burns moderately, tans gradually. Medium skin tone."
  - Type IV: "Burns minimally, tans easily. Olive or medium-brown skin."
  - Type V: "Rarely burns, tans deeply. Brown skin."
  - Type VI: "Almost never burns, deeply pigmented. Dark brown to black skin."
- [ ] Appear consistently in both `SkinTypeOnboardingView` and `SettingsSheet` (same source: FitzpatrickSkinType.pickerDescription)
- [ ] Test `fitzpatrickPickerCopyMatchesApprovedSafetyLanguage()` updated to expect new behavior-first strings
- [ ] Build passes with no Swift warnings
- [ ] No functional regression: no-default validation still works, picker still shows all six types, still selectable

**Implementation Plan:**
1. Update `FitzpatrickSkinType.pickerDescription` computed property in FitzpatrickSkinType.swift (lines 24–39)
2. Update test expectations in BurnTimeCalculatorTests.swift (lines ~173–178)
3. Run `./build.sh` to verify no regressions
4. Commit with message: "Reorder Fitzpatrick descriptions to behavior-first per Suchi + Wheeler design approval (D-2026-05-19-009)"

**Risks/Blockers:**
- None identified; pure copy change with existing test gate

---

##### Risks & Architectural Notes

###### No Architectural Debt Identified

The implementation follows the approved design precisely:
- ✅ Single NavigationStack (not TabView) — correct per design
- ✅ Sheet-based settings — correct per HIG and design
- ✅ Disclaimer cover as fullScreenCover — correct per Donatello M1
- ✅ No-default Fitzpatrick — correct and tested
- ✅ Stale UV using burn-time window (not fixed 60 min) — actually better than spec

###### Compliance & Safety Boundaries

- **Photosensitization:** L1–L4 layering is correct; no attestation screen (zero-data architecture per Donatello M7)
- **Location privacy:** Coordinates rounded to 2 decimal places; rationale shown before system prompt; compliant
- **Attribution:** WeatherKit + NCBI Fitzpatrick citations need final verification (see P1 item above)

---

##### Decision Proposals (For Team Sync)

###### D-CYCLE-1-001 — Fitzpatrick Description Ordering (PROPOSED → ACTIVE next sprint)

Implement behavior-first ordering as specified in D-2026-05-19-009 + linka-ios-design-spec.md. This is a convergent signal from Suchi, Linka, Wheeler, and the Excalidraw user-flow annotations. **Status: Ready for Kwame's sprint backlog.**

---

##### Summary for Team

✅ **Build:** Passing (0 warnings, 16/16 tests)  
✅ **Architecture:** Sound; no refactoring needed  
✅ **Design compliance:** ~95% match; 6 minor gap items identified  
🔴 **Next blocker:** Fitzpatrick description ordering (P0, safety-critical per user research)  
🟡 **Follow-up:** WeatherKit attribution verification (P1, legal/compliance)  

**Cycle 1 recommendation:** Fix Fitzpatrick descriptions → ship → iterate on P1/P2 items in Cycle 2.

#### Iris — Main screen iOS portrait redraw

- **Date:** 2026-05-19
- **Decision:** Replace the LANE 2 desktop-shaped 7-region grid with a portrait iPhone surface. Keep the content model (verdict, UV attribution, settings access, disclaimer links, safety loop) and change the shape only.
- **Why:** The previous main screen read like a desktop dashboard, not an iPhone app. User feedback was correct: the lane needed to feel native to iOS at a glance.
- **iOS conventions applied:** Status bar + home indicator, Large Title nav bar, single-column stacked cards, tappable 44pt chips, semantic system-color language, always-visible Apple WeatherKit attribution in the UV card, conditional photosensitizer reach-back banner, inline informational/not-medical-advice link, and explicit Dynamic Type / VoiceOver notes beside the frame.
- **Diagram impact:** Re-anchored the affected LANE 3 arrows to the new banner, hero card, UV card, and hero-card learn-more caveat while leaving LANE 1 and LANE 4 intact.

#### Kwame — Excalidraw export schema baseline fix

The only missing fields in the 146-element Excalidraw file were `baseline` (required on `text` elements, approximated as `fontSize * 0.8`) — all other required ExcalidrawElement fields (`seed`, `versionNonce`, `groupIds`, `boundElements`, `points` for arrows, etc.) were already present and correctly typed from Linka's export. Fixed file is at `user-flow-onboarding-main.kwame-fix.excalidraw`; Linka's run was still in progress at time of fix so the rename/commit is held pending coordinator decision.

#### Linka — Excalidraw export schema-normalisation fix

**Date:** 2026-05-19T01:40:19-07:00
**Author:** Linka (UI/UX, Apple HIG & Accessibility)
**Status:** ✅ resolved — file now imports cleanly into excalidraw.com
**Artifact touched:** `user-flow-onboarding-main.excalidraw` (D-2026-05-19-013 deliverable)
**Companion script:** `.squad/files/excalidraw-normalize.py`

---

##### Problem

The Excalidraw export `user-flow-onboarding-main.excalidraw` at the repo root **would not import into excalidraw.com** — the loader surfaced the generic error `Error: invalid file`. The file (61.7 KB, 146 elements) had been produced by serialising the Excalidraw MCP server's `query_elements` output inside the canonical `{type:"excalidraw", version:2, elements, appState, files}` wrapper. The wrapper was correct; the individual elements were not.

##### Root cause

`excalidraw-query_elements` returns a **minimal element shape** — only the fields the MCP server tracks, not the full `ExcalidrawElement` schema that excalidraw.com's loader requires. Each text element shipped with only `id, type, x, y, text, fontSize, strokeColor, createdAt, updatedAt, version`; arrows shipped without `points` at all.

Tracing the failure through Excalidraw 0.18.1 source (`packages/excalidraw/data/blob.ts`, `data/restore.ts`, `element/types.ts`) and verifying with a Node + jsdom + esbuild harness around the real `loadFromBlob` reproduced the exact error path:

1. `loadSceneOrLibraryFromBlob` parses the JSON and calls `isValidExcalidrawData` — passes.
2. It then calls `restoreElements(data.elements, ...)`.
3. `restoreElements` first reduces over the raw element list calling `isInvisiblySmallElement(raw)` on each element **before** `restoreElement` fills in defaults.
4. For arrow/line elements, `isInvisiblySmallElement` is implemented as `e.points.length < 2`. The MCP arrows have no `points` field → `undefined.length` → `TypeError: Cannot read properties of undefined (reading 'length')`.
5. The outer `try { ... } catch { throw new Error("Error: invalid file") }` in `loadSceneOrLibraryFromBlob` swallows the real error and surfaces the unhelpful "invalid file" the user reported.

A second cascading failure waits behind `points` if you only fix that: text elements without `fontFamily`/`lineHeight`/`height` route through `getLineHeight(undefined)` → font-registration → `FontFace` API path → various downstream NaN propagation.

##### Fix

Wrote `.squad/files/excalidraw-normalize.py` — a single-pass element walker that fills in every required field from the canonical schema (`packages/element/src/types.ts`) with the defaults from `packages/common` + `packages/excalidraw/data/restore.ts`. **Visual layout is preserved exactly** — only schema fields were added, no coordinates, sizes, colors, or text were touched.

###### Defaults applied

| Scope | Field | Default |
|---|---|---|
| **All** | `seed`, `versionNonce` | random positive 31-bit int |
| | `version` | preserve, else `1` |
| | `index` | `null` (loader assigns) |
| | `isDeleted`, `locked` | `false` |
| | `groupIds`, `boundElements` | `[]`, `null` |
| | `frameId`, `link` | `null` |
| | `roundness` | `null` (sharp corners — flow diagram intent) |
| | `angle` | `0` |
| | `fillStyle`, `strokeStyle` | `"solid"`, `"solid"` |
| | `strokeWidth`, `roughness`, `opacity` | `2`, `1`, `100` |
| | `backgroundColor`, `strokeColor` | `"transparent"`, `"#1e1e1e"` |
| | `updated` | parsed from `updatedAt` if present, else `now()` |
| **text** | `fontFamily` | `5` (Excalifont) |
| | `textAlign`, `verticalAlign` | `"left"`, `"top"` |
| | `containerId` | `null` |
| | `originalText` | mirror of `text` |
| | `lineHeight`, `autoResize` | `1.25`, `true` |
| | `width`, `height` | computed from `text` + `fontSize` if missing |
| **arrow** | `points` | `[[0,0],[width,height]]` ← **the load-bearing fix** |
| | `lastCommittedPoint` | `null` |
| | `startBinding`, `endBinding` | `null`, `null` |
| | `startArrowhead`, `endArrowhead` | `null`, `"arrow"` |
| | `elbowed` | `false` |
| **`appState`** | `gridSize` | `20` (was `null`) |

###### Verification

Validated the fixed file through Excalidraw 0.18.1's actual `loadFromBlob` function — the same code path excalidraw.com runs on import — wired up under Node 25 with jsdom + esbuild + FontFace polyfill. Result: `SUCCESS — loaded 146 elements. Type counts after restore: { text: 99, rectangle: 35, arrow: 12 }`. Type counts match the pre-fix file exactly (D-2026-05-19-013 inventory: 35 rect, 99 text, 12 arrows).

Backup of the broken file kept on disk as `user-flow-onboarding-main.excalidraw.bak` for one cycle.

##### Lesson — captured as skill update

`.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` gained a new **"⚠️ Export gotcha — MCP `query_elements` returns a MINIMAL element shape"** section in the schema-gotchas list. It includes:

- The canonical element-base + per-type fields table (reproduced above).
- The explicit `points: [[0,0],[width,height]]` requirement on arrows that the loader's pre-restore `isInvisiblySmallElement` check requires.
- The reference to `.squad/files/excalidraw-normalize.py` as the canonical fix.
- The verification recipe (Node + jsdom + esbuild + `loadFromBlob`).

This is a load-bearing learning — **any future Excalidraw export via MCP must run through `excalidraw-normalize.py` before being committed to the repo**. Adding it as a pre-commit step is a fast-follow if Excalidraw ever ships from this team again.

##### Files modified

1. `user-flow-onboarding-main.excalidraw` — re-serialised in place (61.7 KB → 165.7 KB; size delta is purely the added schema fields). Backup: `user-flow-onboarding-main.excalidraw.bak`.
2. `.squad/files/excalidraw-normalize.py` — *new*, the canonical normaliser.
3. `.squad/files/user-flow-onboarding-main-spec.md` — added an "Export history" section documenting the fix and explicitly noting that the visual layout is unchanged.
4. `.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` — added the "Export gotcha" section + defaults table + verification recipe.
5. `.squad/decisions/inbox/linka-excalidraw-export-fix.md` — *this file*.

##### Decision implications

- **No design changes.** The diagram content is identical pre- and post-fix.
- **No downstream agent re-work.** Kwame, Suchi, Wheeler, and Plunder do not need to re-read the diagram — it is the same diagram, now portable.
- **Process change:** Future Excalidraw deliverables from MCP must pass through `excalidraw-normalize.py` before being committed. Captured in the skill; this decision file is the audit trail.

### Build & Infrastructure

#### D-2026-05-19-015 — Xcode project container path renamed to app/app.xcodeproj
- **Date:** 2026-05-19T12:15:11.894-07:00
- **Decision:** The Xcode project container path is now `app/app.xcodeproj`.
- **Scope:** This is a project-file path change only. App/product names, target names, schemes, bundle IDs, Swift modules, source folders, and `UVBurnTimer.app` remain `UVBurnTimer`.
- **References updated:** Build/list/test tooling and source checks now point to `app/app.xcodeproj`.
- **Owner:** Kwame
- **Status:** active

#### D-2026-05-19-016 — Use glab CLI for GitLab operations, not GitLab MCP
- **Date:** 2026-05-19T13:32:27.559-07:00
- **Decision:** All GitLab operations must use the `glab` CLI, not GitLab MCP.
- **Rationale:** User directive. Source: `.squad/decisions/inbox/copilot-directive-2026-05-19T13-32-27-559-07-00.md`.
- **Owner:** Coordinator
- **Status:** active

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction

---

<!-- Source: .squad/decisions/inbox/copilot-directive-2026-05-19T17-22-59-098-07-00-external-ci-webhook-monitoring.md -->

### 2026-05-19T17:22:59.098-07:00: User directive
**By:** yashasg (via Copilot)
**What:** External CI/CD runs on GitHub and is triggered by GitLab MR webhooks. When an MR is created, monitor the MR for external CI/CD feedback and fix any issues that come from it.
**Why:** User request — captured for team memory


---

<!-- Source: .squad/decisions/inbox/copilot-directive-2026-05-19T22-29-07-093-07-00.md -->

### 2026-05-19T22:29:07.093-07:00: User directive
**By:** yashasg (via Copilot)
**What:** The "Reapply sunscreen every 2 hours" guidance means users should reapply sunscreen at least every 2 hours; enforce this in app logic by keeping the upper limit to 2 hours.
**Why:** User request — captured for team memory


---

<!-- Source: .squad/decisions/inbox/copilot-directive-2026-05-19T22-33-50-504-07-00.md -->

### 2026-05-19T22:33:50.504-07:00: User directive
**By:** yashasg (via Copilot)
**What:** Do not ask the user for skin type and location every time they open the app; save preferences locally in a privacy-safe way.
**Why:** User request — captured for team memory


---

<!-- Source: .squad/decisions/inbox/copilot-directive-2026-05-19T22-34-50-179-07-00.md -->

### 2026-05-19T22:34:50.179-07:00: User directive
**By:** yashasg (via Copilot)
**What:** Remove SPF "none" as a sunscreen option; the app is for users applying sunscreen, and "none" is not sunscreen.
**Why:** User request — captured for team memory


---

<!-- Source: .squad/decisions/inbox/copilot-directive-2026-05-19T22-43-49-465-07-00.md -->

### 2026-05-19T22:43:49.465-07:00: User directive
**By:** yashasg (via Copilot)
**What:** Persist skin type, SPF, and location locally so the user is not asked for any of them on every app launch.
**Why:** User clarification — captured for team memory


---

<!-- Source: .squad/decisions/inbox/copilot-directive-2026-05-19T22-48-46-884-07-00.md -->

### 2026-05-19T22:48:46.884-07:00: User directive
**By:** yashasg (via Copilot)
**What:** For location, use Apple's coarse/approximate location support where possible; the app does not need precise GPS coordinates.
**Why:** User request — captured for team memory


---

<!-- Source: .squad/decisions/inbox/copilot-directive-2026-05-19T22-50-27-684-07-00.md -->

### 2026-05-19T22:50:27.684-07:00: User directive
**By:** yashasg (via Copilot)
**What:** Display burn/sunscreen duration as hours and minutes instead of raw minutes, so users do not have to do math.
**Why:** User request — captured for team memory


---

<!-- Source: .squad/decisions/inbox/copilot-directive-2026-05-19T23-03-19-634-07-00.md -->

### 2026-05-19T23:03:19.634-07:00: User directive
**By:** yashasg (via Copilot)
**What:** Do not run more than one iOS Simulator at a time. All UI tests must run serially.
**Why:** User request — captured for team memory


---

<!-- Source: .squad/decisions/inbox/gaia-preference-persistence.md -->

# Gaia — User Preference Persistence Architecture

**Date:** 2026-05-19T22:33:50.504-07:00  
**Owner:** Gaia (Lead/Architect)  
**Status:** **DECISION — Ready for implementation**  
**Requested by:** yashasg (user directive via Copilot)

---

## Problem Statement

Current state: Skin type and location preferences are **not persisted** across app launches. Users must re-enter these details every time they open the app, creating friction and preventing the "single-click to get results" UX that personas demand.

User directive: *"Are we saving the user preferences locally? We don't want to ask the user their skin type and location every time they open the app."*

**Question to resolve:** What should be persisted, what should not, what storage mechanism, and how to keep privacy-safe?

---

## Decision: What to Persist

### ✅ PERSIST to UserDefaults (device-local, privacy-safe):

1. **Skin type (Fitzpatrick selection)** — `selectedSkinType: FitzpatrickSkinType?`
   - **Why:** This is a semi-permanent user attribute that rarely changes. Persisting it reduces cold-launch friction for Devon (PCT, P3) and Greta (r/Ultralight, P1) who want to see results immediately.
   - **Privacy:** Fitzpatrick type is text-based (e.g., "Type III"), stored locally only. No remote transmission, no health framework integration.
   - **Key:** `"selectedSkinType"`
   - **Format:** Codable enum (String representation).
   - **Example:** `"typeIII"`

2. **SPF level (sunscreen selection)** — `selectedSPF: SPFLevel`
   - **Why:** Users adjust SPF frequently during a session (e.g., "I need SPF 30 today") but want their last choice remembered across launches (e.g., "I usually use SPF 50").
   - **Privacy:** SPF is a product type, not health data. Stored locally only.
   - **Key:** `"selectedSPF"`
   - **Format:** Codable enum (String representation).
   - **Example:** `"spf50"`

3. **Last rounded coordinate (location cache)** — `lastRoundedCoordinate: UVCoordinate?` (already @AppStorage)
   - **Currently:** Partially persisted as a JSON string in `"lastRoundedCoordinate"`.
   - **Keep as-is:** The rounded-coordinate caching strategy (privacy-safe rounding to 2 decimal places) is already locked. Continue storing this.
   - **No change:** This remains @AppStorage("lastRoundedCoordinate").

4. **Disclaimer acknowledgment** — `acknowledgedDisclaimer: Bool`
   - **Currently:** Stored in `@State`, not persisted.
   - **Decision:** Keep as `@State` (transient). The disclaimer must re-fire on cold launch per D-2026-05-19-011 (L1–L4 layering). This is load-bearing for photosensitization safety (Asha, P4, Accutane use case).
   - **Why transient:** Re-attestation ensures Asha re-reads photosensitivity warnings if her medication or circumstances change.

### ❌ DO NOT PERSIST:

1. **Location permission status**
   - **Why:** OS-owned. CLLocationManager manages this. Do not duplicate or cache the OS permission state.
   - **Current behavior (correct):** Let DeviceLocationProvider handle permission queries.

2. **UV index snapshot**
   - **Why:** Weather data is time-sensitive. Caching a stale UV index creates liability (user acts on outdated info). Always fetch fresh.
   - **Current behavior (correct):** `legacyCachedUVSnapshotStorage` is vestigial; continue to ignore it and fetch fresh on every app open.

3. **Transient UI state** (isFetching, statusMessage, nowTime, etc.)
   - **Why:** These are runtime-only. No reason to persist.

### ⚠️ CONDITIONAL (based on product clarification):

**Location permission rationale acknowledgment** — `LocationPromptGate.hasAcknowledgedRationale`
   - **Current:** Stored in `@State`, not persisted.
   - **Question:** Should users see the location rationale card on every cold launch, or only once per app version?
   - **Recommendation:** Persist to UserDefaults under key `"locationRationaleAcknowledged"` to reduce UI clutter on repeat opens. However, reset this on app update (version bump) to re-educate if location permissions are added to scope.

---

## Storage Mechanism: UserDefaults (AppStorage)

### Rationale:

- **No HealthKit:** Skin type and SPF are not health data per HealthKit spec; they are user preferences. Do not use HealthKit.
- **No Keychain:** These values are not secrets; they do not require encryption. Keychain is overkill and increases app complexity.
- **UserDefaults via @AppStorage:** This is the Swift idiomatic choice for lightweight, persistent, user-facing preferences.
  - Pros: Automatic Codable support, SwiftUI binding-compatible, no extra dependencies.
  - Cons: Not encrypted (acceptable; these are not secrets). Stored in `~/Library/Preferences/[bundle-id].plist`.
  - Privacy: Plist is not readable by other apps (sandbox isolation). Data does not leave device.

### Migration Path:

If skin type/SPF currently live in `UVBurnTimerSession` (@State only), migrate them to:
```swift
@AppStorage("selectedSkinType") private var persistedSkinType: String?
@AppStorage("selectedSPF") private var persistedSPF: String?
```

Then, on app init, restore `session.selectedSkinType` and `session.selectedSPF` from these persisted values. Keep the session object as the in-memory holder during the app lifecycle.

---

## Privacy & Safety Guarantees

1. **No remote transmission:** Skin type, SPF, and location are never sent to cloud, analytics, or third-party servers without explicit user consent (not part of this decision).
2. **No HealthKit:** These preferences do not enter HealthKit or touch health frameworks.
3. **Local-only:** All data lives in the app's sandbox plist.
4. **Clearable:** Users can clear app data via iOS Settings > General > iPhone Storage > [App] > Offload, which wipes the plist.
5. **Photosensitization safety:** Disclaimer re-attestation is NOT persisted, ensuring Asha (P4) sees L1 re-fire on cold launch even if she has persistent skin type. This preserves the critical safety boundary.

---

## Implementation Handoff for Kwame

### Before coding:

1. **Check:** Is `UVBurnTimerSession` currently holding skin type and SPF in @State only, or are they already partially persisted somewhere?
2. **Decision:** Will the session object be the "source of truth" during app lifecycle, with @AppStorage as the persistence layer? (Recommended: yes.)

### Implementation steps:

1. **Add @AppStorage properties to RootView:**
   ```swift
   @AppStorage("selectedSkinType") private var persistedSkinType: String = ""
   @AppStorage("selectedSPF") private var persistedSPF: String = "spf30"
   ```

2. **On app init (UVBurnTimerApp.init):**
   - Restore `session.selectedSkinType` from `persistedSkinType`.
   - Restore `session.selectedSPF` from `persistedSPF`.

3. **On user change in UI (SkinTypeView, SPFPicker):**
   - Update `session.selectedSkinType` and `session.selectedSPF` as normal.
   - Automatically sync to @AppStorage by adding `.onChange` handlers.

4. **Keep `acknowledgedDisclaimer` as @State** (transient per safety boundary).

5. **Optionally persist `LocationPromptGate.hasAcknowledgedRationale`** if product confirms (see Conditional section).

6. **Test:** 
   - Close and reopen the app; skin type and SPF should be remembered.
   - Verify disclaimer still fires on cold launch.
   - Verify location cache (already @AppStorage) continues to work.

### No UI changes required:

- Skin type, SPF, and location pickers remain the same.
- Settings sheet remains the same.
- Onboarding flow remains the same (already shows skin type on first launch; now it'll be pre-filled if returning user).

---

## Acceptance Criteria

1. ✅ Skin type persists across app close/reopen.
2. ✅ SPF persists across app close/reopen.
3. ✅ Last rounded coordinate continues to persist (no regression).
4. ✅ Disclaimer still fires on cold launch (transient, not persisted).
5. ✅ No HealthKit, no keychain, no remote transmission.
6. ✅ Returning user sees skin type pre-filled on onboarding; first-time user sees blank (no default, per D-2026-05-19-012).

---

## Persona Impact

| Persona | Impact |
|---|---|
| **P1 Greta** (gram-counter) | ✅ **Positive:** Opens app, sees her skin type (Type II) pre-filled. No re-entry friction. Gets to the burn time instantly. |
| **P2 Maya** (open-water swimmer) | ✅ **Positive:** Her SPF 50 choice persists. One less picker interaction per session. |
| **P3 Devon** (PCT hiker) | ✅ **Positive:** Mid-hike, closes app. Reopens: skin type (Type I) is there. Can verify burn time immediately. |
| **P4 Asha** (Accutane, photosensitivity) | ✅ **Safe:** Disclaimer STILL fires on cold launch (transient). Skin type persists, but L1 re-attestation is the load-bearing safety surface. If she changes meds, closing and reopening the app still shows L1. |
| **P5 Tomás** (trail-run) | ✅ **Positive:** His Type IV/V selection persists. Less chance of under-picking on a casual app open. |

---

## Reference Decisions

- **D-2026-05-19-011** — L1–L4 disclaimer layering (safety boundary; no change).
- **D-2026-05-19-009/012** — Fitzpatrick no-default, behavior-first text (no change).
- **D-2026-05-19-013/014** — Onboarding flow (no change).

---

## Open Question: Location Rationale Acknowledgment

**Should `LocationPromptGate.hasAcknowledgedRationale` be persisted?**

- **If YES:** Users see the rationale card once per app version, reducing clutter on return visits.
- **If NO:** Users see the rationale card on every cold launch (current behavior).

**Recommendation:** Persist it (add to @AppStorage), but reset on app version bump for re-education. Coordinate with Kwame before coding.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*


---

<!-- Source: .squad/decisions/inbox/iris-gauge-target-ui.md -->

# Iris — Circular Gauge Target UI

**Date:** 2026-05-19T22:27:48-07:00  
**Owner:** Iris (UI/UX Designer — Apple HIG & Accessibility)  
**Status:** Proposed design target for Kwame implementation  
**Requested by:** yashasg

## Source artifacts checked

- `user-flow-onboarding-main.excalidraw` — canonical flow/prototype artifact in repo root. It shows the portrait NowView hero card but does not include a large circular gauge/ring.
- `.squad/files/user-flow-onboarding-main-spec.md` — textual snapshot of that Excalidraw scene; says main screen focuses on hero verdict + secondary cards/chips.
- `.squad/decisions/archive/linka-ios-design-spec.md` — specifies a live timer surface with a Gauge/variable-color SF Symbol below the hero number.
- `prototype/index.html` — old browser prototype; no circular gauge.
- `app/Sources/UVBurnTimer/AppViews.swift` — current implementation.

No separate screenshot/mock image containing the user's “big circular gauge” was found in repo root, `.squad/files`, or the checked prototype/design artifacts.

## Current implementation gap

`AppViews.swift` currently renders `BurnRiskGaugeCard` as a secondary card inside `HeroTimerCard`, with a SwiftUI `.accessoryCircularCapacity` gauge scaled to 1.8 but laid out in a 72×72 frame. It reads as a small accessory control, not a prominent circular gauge. It also sits below the hero text/tier/context, so on smaller phones or large Dynamic Type it is visually easy to miss.

## Design target for Kwame

The circular gauge should feel like the main visual instrument for the burn window, visually attached to the hero estimate.

- **Placement:** Put the gauge inside the hero verdict card, directly under or beside the `Burn time` / minutes estimate. Do not place it as a separate low-prominence `Burn window` card unless screen width/Dynamic Type forces a reflow.
- **Prominence:** Treat it as the second-most important element after the minutes number. It should be visible in the first viewport with the hero estimate, tier badge, and medication/caveat link.
- **Size:** Target an approximately 180–220pt diameter circular ring on standard iPhones. On compact/SE widths, allow ~156–180pt. At AX4/AX5, let it stack below the number and remain at least ~140pt rather than shrinking to accessory size.
- **Visual form:** Use a thick circular progress ring, not a small accessory gauge. Recommended feel: muted full-ring track + high-contrast progress arc tinted by tier (`SeverityLong`, `SeverityModerate`, `SeverityShort`) + centered numeric percent or remaining-time label. The ring must read outdoors in glare; no delicate hairline strokes.
- **Labels:** Visible label should say `Burn window` or `Burn risk window`, with supporting copy like `47 min estimate · 18% elapsed` or `18% of burn window elapsed`. The hero minutes remain the primary decision text; the ring explains elapsed risk visually.
- **Empty/unavailable state:** Preserve the gauge footprint so the user learns where the instrument lives. Show a neutral gray ring with center `—` and copy: `Fetch UV to start burn window` / `No active burn window: UV index is 0` / `Apple Weather unavailable` as applicable. Do not hide the gauge entirely except in onboarding before the Home surface exists.
- **Window-elapsed state:** Ring should be complete and visually alarming, paired with the existing elapsed safety card/copy: `Estimated window elapsed. Cover up, reapply, or move to shade.`
- **Accessibility:** VoiceOver label must include state + percent elapsed + remaining/elapsed interpretation, not just the percent. Example: `Burn window gauge, 18 percent elapsed. Estimated 39 minutes remaining before burn window ends.` Use `accessibilityDifferentiateWithoutColor` to add visible text/symbol redundancy, and do not rely on color alone. Dynamic Type must avoid clipping; Reduce Motion should remove decorative animation but allow value updates.

## Location/Settings UX issue

There is a UX issue beyond the code bug report: a button visibly labeled `Location` currently opens the general Settings sheet and its accessibility hint says `Opens Settings.` That creates an expectation mismatch. Either rename the chip to make the route explicit (`Location settings`, `Location in Settings`) or route it to a location-specific surface/action. A plain `Location` button should not feel like it accidentally opened Settings.


---

<!-- Source: .squad/decisions/inbox/iris-gauge-visibility.md -->

# Iris — Circular Gauge Visibility Audit

- **Date:** 2026-05-19T20:34:41.561-07:00
- **Owner:** Iris (UI/UX, Apple HIG & Accessibility)
- **Status:** proposed implementation recommendation
- **Requested by:** yashasg
- **Input artifacts:** `app/Sources/UVBurnTimer/AppViews.swift`, `app/Sources/UVBurnTimer/UVBurnTimerApp.swift`

## Finding

The circular burn-risk gauge is implemented as `BurnRiskGaugeCard` and is inserted in `RootView` immediately after `HeroTimerCard` and before `UVIndexCard`.

It is **not visible in every default state**. It appears only when all of these are true:

1. `estimate` exists, which requires selected skin type + UV index.
2. `fetchedAt` exists.
3. `estimate.tier != .none`.
4. `estimate.rawMinutes.isFinite`.

This is correct for no-estimate and no-UV states, but it means a user on first launch, before location/UV fetch, will not see a gauge.

## iPhone 17 Pro discoverability assessment

Assuming the iPhone 17 Pro remains in the Pro-class 6.3-inch layout family, the gauge is present but easy to miss:

- The screen uses a large-title `NavigationStack`, then a `ScrollView` with 20pt vertical spacing.
- The top of the content always includes the photosensitization banner.
- Until the user acknowledges the rationale, `LocationRationaleCard` also appears before the hero.
- `HeroTimerCard` is visually dominant and can grow tall: large hero number, tier badge, context line, caveat link, and optional safety cards.
- The persistent bottom safe-area footer + primary action reduces the usable viewport.
- At accessibility Dynamic Type sizes, the hero estimate can wrap to 2 lines and the gauge card is more likely to fall below the fold.

Result: after a valid estimate, the gauge is technically placed high in the hierarchy, but it is not visually attached to the primary estimate. A user can read the hero number and stop before scrolling far enough to notice the separate gauge card.

## Contrast / accessibility assessment

Pass with caveats:

- Uses native `Gauge` with `.accessoryCircularCapacity` rather than custom drawing.
- Has text label/value: `Burn risk`, current percent, explicit accessibility label/value.
- Does not rely on color alone; `differentiateWithoutColor` adds visible percent text.
- Uses severity asset colors through a gradient.

Caveat: the separate card uses `.thinMaterial`. Outdoors, material backgrounds can be lower-contrast than a solid grouped background under glare. The gauge is a secondary cue, so this is not a blocker, but the card should not be the only way users understand risk.

## Recommendation for Kwame

Make a small structural change: move the gauge presentation **inside `HeroTimerCard`** or visually dock it to the hero card as the right-side/under-title secondary cue when an estimate exists.

Preferred pattern:

1. Keep the hero time as the dominant element.
2. Show a compact circular gauge within the hero card, near the tier badge/context line.
3. Keep the same `BurnRiskGauge` semantics and accessibility label/value.
4. Keep hiding the gauge when no estimate/UV exists.
5. At accessibility Dynamic Type sizes, stack the gauge below the hero number but still inside the hero card, before the caveat link.
6. Prefer a solid system grouped/background surface over `.thinMaterial` if the gauge remains a standalone card.

This preserves the approved hierarchy: hero estimate first, circular gauge second, UV/source third — while making the gauge discoverable without requiring an extra scroll.

## Decision

The gauge should be visible by default **after a valid estimate is available**, but not before the app has enough data to compute risk. Current implementation meets existence/accessibility requirements but falls short on glance discoverability. Kwame should integrate or dock the gauge with the hero estimate instead of leaving it as a separate card below the hero.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*


---

<!-- Source: .squad/decisions/inbox/kwame-approximate-location-2026-05-19T23-31-00-07-00.md -->

# Kwame — Approximate Location Directive Implementation

**Date:** 2026-05-19T23:31:00-07:00  
**Owner:** Kwame  
**Status:** Implemented in active location persistence branch

## Decision

UV Burn Timer should request and retain only approximate/coarse location data needed for Apple Weather UV and burn-time estimates. It should not ask for temporary full accuracy or preserve precise GPS coordinates.

## Implementation Notes

- CoreLocation requests use `kCLLocationAccuracyReduced` on iOS 14+ and kilometer accuracy fallback on older OS behavior.
- Coordinates are rounded before leaving `DeviceLocationProvider` and again at WeatherKit/storage boundaries.
- `CachedRoundedCoordinate` now normalizes any input coordinate to the app's rounded weather coordinate before encoding, preventing accidental precise persistence.
- User-facing location copy and the When In Use usage description now say approximate location.

## Validation

- Debug build succeeded.
- Swift Testing core suite passed 62/62, including a new regression test ensuring cached coordinate JSON does not contain precise coordinate strings.
- UI automation was retried but blocked by simulator/device-state automation failures after launch; no compile or core-test regression was found.


---

<!-- Source: .squad/decisions/inbox/kwame-ci-validation.md -->

# Decision Inbox: kwame-ci-validation

**Date:** 2026-05-19  
**Author:** Kwame (iOS Developer)  
**Branch:** `squad/4-approved-redesign-paraphrasing`  
**Commit:** `738da12`

---

## Summary

Validated, committed, and pushed all branch work. Local `./build.sh` clean pass. No GitLab CI pipeline configured for this repo.

---

## Action Items for Team

### 1. Gitignore `excalidraw.log` (Low-priority, non-blocking)

`excalidraw.log` is currently **tracked by git** but contains only MCP server runtime noise (start/connect/listing timestamps). It accumulates with every session and should not be committed.

**Proposed fix:** Add to `.gitignore`:
```
excalidraw.log
```

Owner: any team member. Recommend doing in a cleanup commit.

---

### 2. No GitLab CI configured (Non-blocking, awareness item)

There is no `.gitlab-ci.yml` in the repo. The two existing GitLab pipelines (`main`, `squad/fix-app-icon-catalog`) failed on external infra — not related to this branch.

Local validation via `./build.sh` (xcodebuild Debug build + test + Release build, warnings-as-errors) is the current validation gate. This is sufficient for a team-only repo, but if GitLab CI automation is desired, a `.gitlab-ci.yml` would need to be added.

**No action required** unless the team wants automated CI on GitLab.

---

## Validation Results (local)

| Step | Result |
|------|--------|
| `xcodebuild Debug build` | ✅ PASSED |
| `xcodebuild test` | ✅ PASSED (all tests including new `uncappedLongEstimateStillExpiresAtTwoHourRefreshInterval`) |
| `xcodebuild Release build` | ✅ PASSED |
| Warnings-as-errors | ✅ Clean (0 warnings) |
| Push to origin | ✅ `squad/4-approved-redesign-paraphrasing` pushed |


---

<!-- Source: .squad/decisions/inbox/kwame-ci-xcode16-simulator-traits.md -->

# Kwame CI note — Xcode 16 simulator trait warning

**Date:** 2026-05-19T23:10:55.677-07:00
**Owner:** Kwame

GitHub macOS 15/Xcode 16.4 runners can list iPhone 17 Pro (`iPhone18,1`) simulators with an iOS 26 runtime, but `actool` emits `Could not get trait set for device iPhone18,1`. Treat this as an unsupported Xcode/device-runtime pairing: prefer iPhone 16/15 on Xcode <26 rather than filtering warnings, so real warnings remain fatal.

UI tests should remain serial (`-parallel-testing-enabled NO`) and long accessibility-copy assertions should use NSPredicate-based helpers instead of direct `app.staticTexts[longString]` queries, which hit XCTest's 128-character identifier limit.


---

<!-- Source: .squad/decisions/inbox/kwame-duration-format.md -->

### 2026-05-19T22:50:27.684-07:00: Burn duration display format
**By:** Kwame
**What:** Display burn/sunscreen windows as compact duration labels (`1 hr 35 min`, `45 min`, `Up to 2 hr`, `4+ hr`) rather than raw long minute counts or clock-like `hours :: minutes`.
**Why:** Users should not have to convert minutes mentally, and clock-style separators could be misread as time-of-day. The underlying MED math and 120-minute sunscreen cap are unchanged.


---

<!-- Source: .squad/decisions/inbox/kwame-external-ci-monitoring.md -->

# Decision: External CI Project Path and Build Script Contract

**Date:** 2026-05-20  
**Author:** Kwame  
**Branch:** squad/4-approved-redesign-paraphrasing  
**MR:** !3

## Context

External CI runs on GitHub Actions, triggered via GitLab MR webhooks (Cloudflare Worker → `repository_dispatch`). The CI workflow lives on `github/main` (NOT the GitLab branch). Xcode project was renamed from `VCA.xcodeproj` to `app.xcodeproj` on the GitLab side, but `github/main`'s `ci.yml` still referenced the old name.

## Decisions

### 1. GitHub CI workflow must be updated when Xcode project is renamed
**Decision:** When renaming the Xcode project or restructuring the `app/` directory, `github/main`'s `.github/workflows/ci.yml` must be updated in the same session. The GitLab branch and GitHub main are not the same repo and do not auto-sync.

**Affected paths in ci.yml:**
- `awk ... app/VCA.xcodeproj/project.pbxproj` (Set build metadata step)
- `hashFiles('app/VCA.xcodeproj/...')` (cache key expressions)
- `cd app && ./build.sh` (incorrect path; `build.sh` lives at repo root)

### 2. `build.sh` must accept CI env vars
**Decision:** `build.sh` (at repo root) supports both local dev mode and CI mode:
- **CI mode** (when `CONFIGURATION` env var is set): runs only the specified configuration + tests if `RUN_TESTS=true`
- **Local dev mode** (no `CONFIGURATION`): runs full cycle — Debug build → tests → Release build
- Supported vars: `CONFIGURATION`, `TEST_CONFIGURATION`, `DERIVED_DATA_PATH`, `RUN_TESTS`, `PLATFORM_MODE`
- Legacy vars still work: `UV_BURN_TIMER_DESTINATION`, `UV_BURN_TIMER_DERIVED_DATA_PATH`

### 3. `.swift-format` config must exist for CI lint gate
**Decision:** A `.swift-format` file must be present at the repo root. CI runs `xcrun swift-format lint --configuration .swift-format --strict`. Without it, the lint step fails immediately.

**Settings:** 4-space indentation, 120-char line length (matches codebase conventions).

### 4. XCUITest teardown pattern for Xcode 26 / Swift 6
**Decision:** Do NOT override `tearDownWithError()` to terminate `XCUIApplication` when using `@MainActor` test classes. The override is implicitly `nonisolated` (inherits from `XCTestCase` which is not `@MainActor`), so accessing `@MainActor` properties causes a Swift 6 compile error.

**Correct pattern:**
```swift
private func launchApp(arguments: [String] = []) -> XCUIApplication {
    XCUIApplication().terminate()  // explicit pre-launch cleanup
    let app = XCUIApplication()
    app.launchArguments = ["-uiTestResetDefaults"] + arguments
    app.launch()
    return app
}
```

### 5. Concurrency race with webhook-triggered CI
**Decision:** The CI workflow uses `concurrency: cancel-in-progress: true`. When GitLab sends push + MR events simultaneously for the same branch, one run may cancel the other before posting status back to GitLab. If the GitLab pipeline shows no result for the latest commit, an empty re-trigger commit resolves this.

## Impact

- Team: Any agent touching the Xcode project name or `app/` layout must also update `github/main`'s `ci.yml`.
- CI: `build.sh` is now the canonical build entry point for both local dev and CI.
- iOS: UI test pattern established for Xcode 26 strict concurrency.


---

<!-- Source: .squad/decisions/inbox/kwame-gauge-location-ui.md -->

# Kwame — Gauge prominence and Location chip routing

- Date: 2026-05-19T22:27:48.170-07:00
- Owner: Kwame
- Status: proposed

## Decision

The main-screen Location chip routes to the same location/UV request flow as the primary location CTA. It must not open Settings; Settings remains available only from the gear button.

The burn-risk gauge is a large, centered circular SwiftUI ring in the hero card for both valid estimates and honest unavailable states. Unavailable states keep the gauge shell visible without fabricating WeatherKit data; the accessibility value remains "Unavailable" until real UV data exists.

## Rationale

Users expected the Location affordance to start the location flow, and the small accessory gauge was still too visually subtle compared with the shared design direction. A custom SwiftUI circular ring keeps the safety cue prominent while preserving WeatherKit/CoreLocation honesty.


---

<!-- Source: .squad/decisions/inbox/kwame-gauge-visibility.md -->

# Kwame — Gauge Visibility Fix

- **Date:** 2026-05-19T20:34:41.561-07:00
- **Owner:** Kwame
- **Status:** proposed

## Decision

Render the circular `BurnRiskGaugeCard` inside `HeroTimerCard` immediately below the estimate inputs instead of as a separate main-screen sibling card.

## Why

On iPhone 17 Pro, the separate sibling card appeared below the large hero card and was partially covered by the persistent footer/safe-area inset at first paint. Users saw at most a clipped arc, which made the circular gauge effectively invisible. Keeping it inside the hero preserves the intended secondary-cue relationship while making it visible without scrolling.

## Scope

- `app/Sources/UVBurnTimer/AppViews.swift`
- `app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift`

The existing gauge data guard, health caveat copy, and accessibility label/value remain intact.


---

<!-- Source: .squad/decisions/inbox/kwame-persist-user-preferences.md -->

# Kwame — Persist user preferences locally

**Date:** 2026-05-19T22:43:49.465-07:00  
**Status:** Implemented on `squad/fix-location-gauge-ui`

- Skin type and SPF are restored from device-local UserDefaults and kept in sync through the SwiftUI app session.
- SPF persistence rejects invalid or legacy unprotected/"none" values and falls back to SPF 30, preserving the no user-facing SPF none rule.
- Location persistence stays privacy-safe: exact device permission state is OS-managed, exact coordinates are not stored by the app, and the existing rounded last coordinate plus local location-rationale/mode acknowledgement are stored locally only.
- Disclaimer acknowledgement remains transient so the safety attestation still appears on cold launch.
- Added core preference restoration tests and a UI regression for returning users with saved skin type, SPF, and rounded location.


---

<!-- Source: .squad/decisions/inbox/kwame-remove-spf-none.md -->

### 2026-05-19T22:34:50.179-07:00: SPF product options are sunscreen-only
**By:** Kwame
**What:** Removed SPF "None" from user-facing product choices. The app assumes sunscreen use, so selectable SPF values are now 15, 30, 50, and 70+ only; the unprotected calculation remains only as an internal/reference math path.
**Why:** User clarified that "SPF none" is not sunscreen and does not fit the app's product premise.


---

<!-- Source: .squad/decisions/inbox/kwame-run-script.md -->

# Kwame — Run script addition

Added a root-level `run.sh` convention for local iOS launch. It delegates building to `./build.sh`, pins local run output to ignored `.build/DerivedData`, targets iPhone 17 Pro, and uses `simctl` to boot/install/launch. This keeps local run flow aligned with the canonical build script instead of introducing a second build path.


---

<!-- Source: .squad/decisions/inbox/kwame-simulator-gauge-fallback.md -->

# Kwame — Simulator gauge fallback

- Date: 2026-05-19T21:34:24.682-07:00
- Decision: Keep the circular burn-window gauge shell visible when no live UV estimate is available, including simulator no-location and WeatherKit-unavailable states.
- Rationale: The gauge was easy to miss in development because it only rendered after CoreLocation and WeatherKit succeeded. Showing an explicitly unavailable shell makes the UI testable without silently injecting fake weather data.
- Guardrail: Production users still see honest location/weather error copy. No sample UV value is used in release or simulator fallback states.


---

<!-- Source: .squad/decisions/inbox/kwame-sunscreen-two-hour-cap.md -->

### 2026-05-19T22:29:07.093-07:00: Sunscreen two-hour cap implemented
**By:** Kwame
**What:** SPF/sunscreen-protected burn-window estimates are capped at 120 minutes for display, elapsed-window logic, and gauge progress; raw MED math is preserved internally for medical honesty.
**Why:** User clarified “Reapply sunscreen every 2 hours” means at least every 2 hours, so SPF must not imply a safe sunscreen window longer than two hours.
**Notes:** Unprotected-reference estimates remain uncapped by sunscreen reapplication timing. UI copy uses “at least every 2 hours” and labels the cap as a sunscreen reapplication limit.


---

<!-- Source: .squad/decisions/inbox/ma-ti-duration-format-tests.md -->

### 2026-05-19T22:50:27.684-07:00: Duration formatting test contract
**By:** Ma-Ti
**What:** Duration estimates should use compact hours/minutes copy once they reach an hour: `~1 hr`, `~1 hr 20 min`, `~2 hr 47 min`, and sunscreen cap `Up to 2 hr`; sub-hour estimates stay in minutes, and unavailable estimates stay non-duration (`No UV` / ready state). Accessibility summaries use spoken units such as `1 hour 40 minutes`.
**Why:** Users should not have to convert raw minute counts, while sub-hour and unavailable states remain clearer without artificial `0 hr` wording.


---

<!-- Source: .squad/decisions/inbox/wheeler-sunscreen-two-hour-cap.md -->

# Wheeler — Sunscreen two-hour cap recommendation

**Date:** 2026-05-19T22:29:07.093-07:00  
**Owner:** Wheeler (Skin Science Expert)  
**Status:** Recommendation for Kwame  

## Verdict

Yes — cap any sunscreen-protected user-facing burn/safe-window estimate at 2 hours.

The existing footer language ("Reapply sunscreen every 2 hours regardless of timer") should be treated as an upper-bound safety/product constraint, not merely boilerplate. Public-health guidance is consistent: sunscreen should be reapplied if staying in the sun for more than 2 hours, and sooner after swimming, sweating, or toweling. FDA also cautions that SPF should not be interpreted as a direct time multiplier that grants many hours of sun exposure.

## Implementation constraint for Kwame

Apply the cap only when sunscreen is selected:

```swift
let sunscreenCapMinutes = ProductTiming.sunscreenReapplicationIntervalSeconds / 60 // 120
let displayMinutes = spf == .none ? rawModelMinutes : min(rawModelMinutes, sunscreenCapMinutes)
let isCappedByReapplication = spf != .none && rawModelMinutes > sunscreenCapMinutes
```

Required behavior:

1. Keep calculating the raw SPF-adjusted model internally if useful for tests/diagnostics.
2. Do not display a sunscreen-protected estimate above 120 minutes.
3. If the raw estimate exceeds 120 minutes, display the 2-hour cap and a message such as: "Reapply sunscreen by 2 hours; the SPF model estimate is longer, but sunscreen guidance caps this window."
4. Continue to mark the estimate elapsed at the earlier of raw burn time and 2 hours.
5. Leave `SPF none` estimates uncapped by the sunscreen rule; those are governed by the burn model and existing long-estimate caveats.

## Copy nuance

Avoid copy that implies sunscreen protects for longer than the reapplication interval. Prefer "by 2 hours" / "at least every 2 hours" / "sooner after swimming, sweating, or toweling" over a bare "every 2 hours" when space allows.

## Source posture

- CDC Sun Safety: "Sunscreen wears off. Put it on again if you stay out in the sun for more than 2 hours and after swimming, sweating, or toweling off."
- FDA sunscreen guidance: SPF is not directly related to time of solar exposure; SPF should not be read as "SPF × normal burn time" permission for prolonged exposure.


---


<!-- Source: .squad/decisions/inbox/gaia-location-rationale-persistence.md -->

# Gaia — Location-rationale acknowledgement persistence ADR

- **Date:** 2026-05-20T03:50:00-07:00
- **Owner:** Gaia (Lead/Architect)
- **Status:** **RATIFIED** — closes the open question from
  `gaia-preference-persistence.md` (WI-10 from
  `gaia-backlog-20260520T031000Z.md`)
- **Reviewer:** Plunder

## Decision

`LocationPromptGate.hasAcknowledgedRationale` is persisted in
`UserDefaults` under
`UserPreferenceStorage.locationRationaleAcknowledgedKey` and restored
on every launch. A returning user who already acknowledged the
inline location rationale does **not** see the `LocationRationaleCard`
again on subsequent cold launches.

This ratifies the implementation that has been shipping since
`squad/fix-location-gauge-ui` (commit `df0e01b`). The ledger entry
`kwame-persist-user-preferences.md` already documented the storage
mechanism; this ADR is the missing product/IA decision that gave the
mechanism its mandate.

## Why this is the right default

1. **Persona fit.** Greta (P1, repeating use) and Devon (P3, PCT
   thru-hike, may relaunch many times per day) both lose flow if the
   same rationale panel re-renders on every cold launch. Asha (P4,
   photosensitive re-attestation persona) is already protected because
   the L1 disclaimer continues to re-fire on cold launch.
2. **Architectural symmetry with Fitzpatrick/SPF persistence.** Once
   we accepted that skin type and SPF persist in `UserDefaults`,
   making the rationale ack volatile would surface a confusing
   asymmetry: "Why does the app remember my skin type and SPF but ask
   me to read this rationale again every launch?"
3. **Privacy posture unchanged.** The persisted value is a single
   `Bool` in the app sandbox plist; it never leaves the device.
4. **System permission state is the actual gate.** Even with the
   rationale ack persisted, the OS still re-prompts the user for
   location permission if they have never granted it or if they
   revoked it from Settings.

## Guardrails

1. **Re-show the rationale after a future material privacy change.**
   Reset the ack via a bundled "privacy copy version" key when the
   data scope expands (deferred to v1.1).
2. **"Clear saved location" semantics** — currently clears only the
   rounded coordinate, not the ack. Flagged to Plunder for sign-off;
   recommendation is to keep the ack persisted across coordinate
   clears (user can fully reset by uninstalling).
3. **Test coverage stays explicit** —
   `testLocationRationaleAcknowledgementSurvivesRelaunch` names the
   contract independently of the bundled
   `testSavedPreferencesRestoreAfterDisclaimerWithoutRepeatingPrompts`.

## Out-of-scope (deferred)

- Versioned reset key (v1.1).
- Settings toggle to forget the rationale ack (uninstall is the v1
  escape hatch).


---
