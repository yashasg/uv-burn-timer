# Linka — iOS Design Specification (UV Burn Timer)

**Date:** 2026-05-19T00:10:00-07:00
**Author:** Linka (UI/UX Designer — Apple HIG & Accessibility)
**Audience:** Kwame (iOS Dev — primary implementer), Suchi (User Researcher — persona sign-off), Plunder (Legal/Compliance — disclaimer + attribution wording), Wheeler (Skin Science — verdict-card photosensitizer note), Argos (Monetization — App Store surfaces)
**Status:** Handoff draft. Cross-checked against `prototype/index.html`, `prototype/LAUNCH-PLAN.md`, `prototype/README.md`, `.squad/decisions.md` (D-2026-05-19-001..007), Suchi's `.squad/agents/suchi/history.md`, and `.squad/decisions/archive/suchi-monetization-personas.md`.

**⚠️ Suchi-design-brief inbox file (`.squad/decisions/inbox/suchi-design-brief.md`) had NOT landed at start of this spec. I re-checked at the end of the work — Suchi's brief landed during my pass. §12 "Suchi sync log" lists every directive I integrated; §14 lists the targeted edits I made to earlier sections in response.**

---

## TL;DR for Kwame

- **IA: single-root `NavigationStack`**, no `TabView`. Settings + About are `.sheet`s from a single toolbar gear button. One screen, one calculation. (Mirrors prototype's wedge: "one screen, one calculation.")
- **Live timer surface = `TimelineView(.periodic(from: ..., by: 60))`** wrapping a `.system(.largeTitle, design: .rounded).weight(.heavy)` numeric display, color-tier driven by a `Gauge` with variable-color SF Symbol below. The countdown updates once per minute; the snapshot is the model's MED estimate at the last UV fetch, not a recomputation.
- **Live Activity / Dynamic Island: DESIGNED, NOT SHIPPED v1.** Spec is below for v1.1 fast-follow; ship Home view only at launch. Rationale in §3.
- **WeatherKit attribution:** Apple-required " Weather" lockup is **always visible** on Home (below the result card, above the footer) AND on the About sheet (full lockup + tappable legal link). Compliant with Apple's [WeatherKit attribution requirements](https://developer.apple.com/weatherkit/get-started/#attribution-requirements) and Apple Weather Display Requirements PDF.
- **Disclaimer:**
  - **First-launch full-screen cover** every cold launch (Donatello M1 — preserved verbatim).
  - **Persistent footer disclaimer** on every screen showing a burn-time number (Donatello M2 — preserved).
  - **Verdict-card photosensitizer footnote** — visible on the Home verdict card, NOT buried in About. This is Suchi's recommendation (`.squad/agents/suchi/history.md` learning #6, photosensitizing-meds persona) and tracks D-2026-05-19-007 (Wheeler sign-off pending; if Wheeler closes that decision negative, downgrade to icon-only with VoiceOver-only expansion).
- **Outdoor readability**: rely on iOS Auto-Brightness + opt into `.environment(\.colorSchemeContrast, .increased)` follower via Asset Catalog "High Contrast" variants. **Tier severity uses shape + color + SF Symbol**, never color alone. Tested at AX5 + VoiceOver + Reduce Motion + dark + High Contrast.

---

## §1 — Information Architecture & Navigation

### Decision: Single-root `NavigationStack` with sheet-based secondary surfaces

```
RootView (NavigationStack)
└── NowView (the live timer Home; .navigationTitle("UV Burn Timer"))
    ├── .toolbar:
    │     • topBarTrailing → gearshape Button → presents SettingsSheet
    ├── .fullScreenCover:
    │     • DisclaimerCover (re-fires every cold launch — Donatello M1)
    └── .sheet:
          • SettingsSheet (NavigationStack inside sheet)
              ├── Skin Type detail (NavigationLink → SkinTypeView)
              ├── SPF detail (NavigationLink → SPFView, OR inline Picker)
              ├── About & Citations (NavigationLink → AboutView)
              │     └── Attribution & Legal (NavigationLink → AttributionView)
              └── Restore Purchase (Button, StoreKit 2)
```

### Why this IA (not `TabView`, not multiple screens)

| Option | Verdict | Reason |
|---|---|---|
| `TabView` (Now / Forecast / Settings) | ❌ Reject | App has ONE user job (read minutes to burn). HIG: "Use a tab bar only when each section is a separate top-level area of the app." A forecast view violates the "one screen, one calculation" wedge that Suchi's r/Ultralight Persona 1 ("Ren the gram-counter") and the BPL Persona 2 ("Heather the methodologist") both ratify. |
| Multiple `NavigationStack` destinations on the main path | ❌ Reject | The Home view IS the product. Pushing the user away from the timer to set skin type defeats the purpose. |
| **Single-root + sheet-based settings** ✅ | **Adopt** | Matches the prototype's single-page mental model. HIG-native modality: settings is a transient task; using `.sheet` correctly signals "I'll come right back." |
| `.fullScreenCover` for disclaimer | ✅ Adopt | HIG: required-acknowledgment content uses full-screen modality. Donatello M1 mandates non-dismissible-without-acknowledgment behavior — this is the closest HIG primitive. |

**Persona check.**
- Ren (Ultralight) opens app, taps once, gets minutes. ✅ Home is sufficient.
- Heather (BPL methodologist) needs to verify the math. ✅ About sheet has Diffey/Fitzpatrick citations one tap from Home.
- Accutane / lupus persona (Suchi learning #6) needs the disclaimer visible without exploration. ✅ Persistent footer + verdict-card footnote + first-launch full-screen cover. Three layers, all visible without taps.

### HIG references
- iOS HIG → Patterns → [Modality](https://developer.apple.com/design/human-interface-guidelines/modality)
- iOS HIG → Components → Navigation and search → [Navigation bars](https://developer.apple.com/design/human-interface-guidelines/navigation-bars), [Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars), [Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)

---

## §2 — Screen-by-Screen Specification

> Naming convention: every screen has a `View` name Kwame can use as the SwiftUI struct. Components called out by SF Symbol name and SwiftUI text style. Colors are semantic (`Color.primary`, `.secondary`, `.accentColor`, named asset-catalog colors like `Color("SeverityShort")`) — no hex anywhere in this spec.

### 2.1 `DisclaimerCover` — First-launch full-screen cover

**Purpose & user job.** Force a single, unmissable acknowledgment that the estimate is not medical advice. Honors Donatello M1, Plunder's disclaimer guardrail (D-2026-05-19-007 context), and Suchi's "load-bearing disclaimer" finding (history.md learning #6).

**Layout (safe area).**
- Title `Text("Important Notice").font(.title2.bold())`, `.padding(.top, 32)`.
- Icon: `Image(systemName: "exclamationmark.triangle.fill")` — `.font(.system(size: 44))`, `.foregroundStyle(.orange)` (uses `.symbolRenderingMode(.hierarchical)`).
- Body `Text(...).font(.body).foregroundStyle(.primary)` — disclaimer verbatim (see §8.4 wording — Plunder to confirm).
- Footer button `Button("I understand") { ... }.buttonStyle(.borderedProminent).controlSize(.large)`. **Single primary action** — no "Don't Show Again."
- Background: `.regularMaterial` over a dimmed system gradient (system-managed).

**States.**
- Normal: always shown on cold launch (Donatello M1).
- Loading/Empty/Error: not applicable — pure content.

**Transitions / motion.**
- `.fullScreenCover(isPresented: $disclaimerVisible)` — system fade-up.
- Reduce Motion: SwiftUI honors `.accessibilityReduceMotion` automatically on `.fullScreenCover`; the transition becomes a crossfade. **Do not override.**

**Persona-grounded notes.**
- Accutane/lupus persona (Suchi #6): this is the FIRST defensive layer. Wording must NOT soften.
- BPL Persona 2 (methodologist): on day 30 of use, they'll still see this on cold launch and respect it.

### 2.2 `NowView` — Home / live timer

**Purpose & user job.** Show "estimated minutes until 1 MED" given current UV, skin type, SPF. This is THE product surface.

**Layout (safe area, top → bottom).**

1. **Nav bar** — `.navigationTitle("UV Burn Timer")`, `.navigationBarTitleDisplayMode(.inline)` so the hero countdown is the visual top.
   - Trailing toolbar item: `Button { showSettings = true } label: { Image(systemName: "gearshape") }`.
   - `.accessibilityLabel("Settings")`.
2. **Hero timer card** (described in §3 in full).
3. **Tier badge strip** — chip below the timer. `Capsule()` fill, label + SF Symbol per tier. Tier mapping in §3.3.
4. **Context line** — `Text("Fitzpatrick III · SPF 30 · UV index 8.0").font(.subheadline).foregroundStyle(.secondary)` — `.accessibilityElement(children: .combine)`.
5. **"Is this estimate for me?" link** (Suchi L3 pattern, see §8.4 + §12) — a `Button { showAboutAtAnchor(.notForMe) } label: { Label("Is this estimate for me?", systemImage: "info.circle") }` — `.font(.footnote.weight(.medium)).buttonStyle(.plain).foregroundStyle(.tint)`. Tapping deep-links to the About sheet, scrolled to the *"When this estimate may not apply"* section (see §2.6). **This is the primary verdict-card reach-back into the photosensitizer caveat.** Plunder to confirm L3 link wording (Suchi proposed three variants — see §11 P1); my pick is Suchi's A. **The actual photosensitizer caveat content lives in About**, not inline on the verdict card, to avoid wall-of-text on the verdict — but it is one tap away and visible without exploration.
6. **Inputs disclosure** — `DisclosureGroup("Inputs") { ... }` containing:
   - `Picker("Skin type", selection: $fitz) { ... }.pickerStyle(.navigationLink)` (pushes to `SkinTypeView`).
   - `Picker("SPF", selection: $spf) { ... }.pickerStyle(.menu)`.
   - `Button { requestLocation() } label: { Label("Use my location", systemImage: "location") }`.
7. **WeatherKit attribution lockup** — see §4. **Always visible on this screen.**
8. **Persistent footer** — Donatello M2 disclaimer (see §8.4).

**Components named.**
| Element | SF Symbol | Text style | Color |
|---|---|---|---|
| Hero number | — | `.system(size: 80, weight: .heavy, design: .rounded)` clamped to AX5 via custom scaling (see §3.2) | `.primary` |
| Hero unit ("min") | — | `.title2.weight(.semibold)` | `.secondary` |
| UV severity glyph | `sun.max.trianglebadge.exclamationmark` (high), `sun.max` (mod), `sun.haze` (low/none), variable-color | `.title2` | role `.tint` driven by tier |
| Tier badge — Long | `tortoise` (slow, safe pace metaphor) | `.subheadline.weight(.semibold)` | `Color("SeverityLong")` + `Color("OnSeverityLong")` text |
| Tier badge — Moderate | `figure.walk` | same | `Color("SeverityModerate")` |
| Tier badge — Short | `hare` (fast pace metaphor) | same | `Color("SeverityShort")` |
| L3 "Is this estimate for me?" link | `info.circle` | `.footnote.weight(.medium)` | `.tint` |
| Settings | `gearshape` | navigation | `.tint` |
| Location button | `location` (idle) / `location.fill` (active) / `location.slash` (denied) | `.body` | `.tint` |
| About link in footer | `info.circle` | `.caption` | `.tint` |

**Materials.** The hero timer card uses `.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))`. The inputs disclosure uses `.background(.thinMaterial, ...)` so it visually steps back.

**States.**
| State | Display |
|---|---|
| **Empty (no UV yet)** | Hero shows `Image(systemName: "sun.max").font(.system(size: 80)).foregroundStyle(.tint).symbolRenderingMode(.hierarchical)`; subtitle "Tap **Use my location** to compute your estimate." Tier badge hidden. `ContentUnavailableView`-style framing but inline (not full screen). |
| **Loading** | Hero replaces number with `ProgressView()` + "Fetching UV…" subtitle. Primary location button shows inline spinner overlay so a running user (Suchi P5 Tomás) sees the tap registered without standing still. Inputs remain interactive. |
| **Normal** | Number + unit + tier badge + context line + photosensitizer footnote. |
| **UV index 0** | Number replaced by `Image(systemName: "moon.zzz").font(.system(size: 80))`; copy "UV index is 0 — no erythemal irradiance detected." Tier badge hidden. This matches the prototype's special-case branch. |
| **Error (WeatherKit fail)** | Hero: `Image(systemName: "exclamationmark.icloud").font(.system(size: 64))`. Copy: "Could not reach Apple Weather. Try again." Retry button `Button("Retry", systemImage: "arrow.clockwise") { ... }.buttonStyle(.borderedProminent)`. See §8.2. |
| **Location denied** | Hero shows generic sun symbol; below it, `ContentUnavailableView { Label("Location off", systemImage: "location.slash") } description: { Text("UV Burn Timer needs your location once to fetch UV data. It never leaves your device.") } actions: { Button("Open Settings") { UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) } }`. See §8.1. |
| **Stale UV (> 60 min old)** | Hero number shown with `.opacity(0.6)`; small "Updated 2h ago" `Label("...", systemImage: "clock.arrow.circlepath")` chip with refresh button. Sourced from a `lastUV` (value + timestamp) cache in `UserDefaults` — non-health data, OK per Casey M7 (Suchi §1.8 + §8). |
| **Cold-launch with cached UV** | If `lastUV` exists in `UserDefaults`, show it on launch tagged "Updated 14 min ago" with refresh affordance — so Suchi's Maya (open-water swimmer) and Devon (planner) are never stranded on an empty Home after a connectivity dropout. |

**Transitions / motion.**
- Cold-start → first computed value: numeric content transition `.contentTransition(.numericText(countsDown: true))` on the hero `Text`. This is the iOS 17+ numeric digit-roll. Honors Reduce Motion: SwiftUI falls back to crossfade.
- Tier badge color change: `.animation(.smooth, value: tier)`; respect `@Environment(\.accessibilityReduceMotion) var reduceMotion` → use `nil` animation when true.
- Material/sheet presentation: system default. No custom matched-geometry.
- **Pull-to-refresh** on the `ScrollView` (`.refreshable { await refetchUV() }`) so Suchi's Maya (open-water swimmer, multi-check session) can re-fetch UV with the standard iOS gesture (Suchi §1.5).

**Thumb-zone placement (Suchi §4 AC-5).** Per Suchi's one-handed-use directive: the **primary "Use my location" / "Refresh" button is rendered in a `.safeAreaInset(edge: .bottom)` sticky region above the persistent footer**, NOT inline in the inputs card. The verdict and inputs scroll above it. This puts the most-tapped control in the iPhone thumb zone (bottom third). Inputs remain accessible inside the `DisclosureGroup` above.

**Persona-grounded design decisions.**
- **Hero is the number, not the verdict word.** Suchi P2 (Maya / Sungirl1112, open-water swimmer) explicitly thinks in minutes ("burning over 1.5 hours"). Showing "Moderate" without minutes would miss her JTBD.
- **Inputs collapsed by default behind `DisclosureGroup`** — but **expanded by default at AX4+** (so AX users aren't tapping to expand). Suchi P1 (Greta / gram-counter Greta) wants one screen, one tap. Skin type and SPF rarely change session-to-session.
- **L3 "Is this estimate for me?" link on verdict card.** Suchi §6: this is the missing piece in the disclaimer layering. The verdict card needs a one-tap reach to the photosensitizer caveat for Suchi P4 (Asha / Accutane). Visible (not buried in About) but compact (not a full footnote that competes with the hero number).
- **Long tier displayed-minutes cap.** Per Suchi §1.8, very high estimates (Fitz V+VI + SPF 70 + low UV) can produce "~480 minutes" which is mathematically right and behaviorally misleading. **Display rule: if `minutes >= 240`, show "240+ min"** with tier "Long." The model's internal value is unchanged; only the display is clamped.

### 2.3 `SkinTypeView` — Fitzpatrick picker detail

**Purpose & user job.** Self-classify Fitzpatrick I–VI. This is the input with the highest mental-model load. The prototype's six radio buttons are correct in content; the iOS rendering must be HIG-native.

**Layout.**
- `Form { Section { ForEach(FitzType.allCases) { type in ... } } header: { Text(prompt).font(.subheadline) } footer: { Text(caveat) } }` — `.listStyle(.insetGrouped)`.
- **Section header (NEW per Suchi §1.2 MMT-3):** "Pick the row that best matches **what your skin does**, not what color it is." — defends against Suchi's MMT-3 ("Skin type = ethnicity") mental-model trap.
- Each row: `HStack { Text("I").font(.title3.weight(.bold)).frame(width: 36); VStack(alignment: .leading) { Text(name).font(.body); Text(desc).font(.subheadline).foregroundStyle(.secondary) }; Spacer(); if selected { Image(systemName: "checkmark").foregroundStyle(.tint) } }`. Whole row is tappable (`.contentShape(Rectangle())`). **Row min-height = 56pt** (Suchi §4 AC-2/AC-4 — wet-hands + motion targets).
- Section footer: "Skin type self-assessment is approximate. For accurate classification, consult a dermatologist. **This model assumes healthy skin and no photosensitizing medications** — see *Is this estimate for me?* on the result screen." `.font(.footnote)` — wording extended per Suchi §1.2 directive #2 ("Caveat needs more weight"). Plunder to verify.

**Row content — leads with behavior (Suchi §1.2 directive #4 + §7.4 directive).** Each row description leads with burn-and-tan behavior, NOT with skin color. The prototype I–IV already do this; V and VI currently lead with color and need rewriting:

| Type | iOS description (behavior-first) |
|---|---|
| I | "Always burns, never tans. Very fair; often freckles, red/blonde hair." (unchanged from prototype) |
| II | "Burns easily, tans minimally. Fair skin; light eyes common." (unchanged) |
| III | "Burns moderately, tans gradually. Medium skin tone." (unchanged) |
| IV | "Burns minimally, tans easily. Olive or medium-brown skin." (unchanged) |
| V | **"Rarely burns, tans deeply. Brown skin."** (rewritten: behavior first, color second) |
| VI | **"Almost never burns, deeply pigmented. Dark brown to black skin."** (rewritten: behavior first, color second) |

Wheeler/Plunder to ratify final V/VI wording.

**No default selection (Suchi §1.2 directive #1).** The prototype defaults to Fitz III (`checked` on line 304); the iOS version does **NOT** pre-select. Reason per Suchi: pre-selecting Fitz III pre-anchors users like Devon (Fitz I) to a value that under-estimates their risk by ~50%. A deliberate tap is required. Empty `SkinType` is a first-class state.

**Components.**
- No SF Symbol glyph next to type labels. **No skin-tone swatches** (Suchi §1.2 directive #3 + §7.4 directive — pigmentation swatches reinforce MMT-3 misconception that Fitzpatrick = ethnicity, and are culturally fraught when rendered wrong). Pure typography for the type identifier (Roman numeral) + descriptive text.

**States.**
- **Unselected (initial cold launch)** — no `checkmark` on any row; verdict card hidden on `NowView`; "Use my location" button enabled but tapping it shows a `.alert` "Pick a skin type first" before the location prompt fires. Or alternatively, the verdict card on `NowView` shows an empty state "Pick a skin type to see your estimate" with a Label that links to `SkinTypeView`.
- **Selected** — row shows `checkmark`.

Persistence: `@State` only (Casey M7 — NOT `@AppStorage`, NOT `UserDefaults`). State survives session but resets on app cold-launch — matches prototype's URL-hash equivalence (Casey/Donatello special-category-data rule). This means every cold launch the user re-picks Fitz; Suchi flags this as friction in §2.1 of her brief and accepts it as the privacy tax.

**Transitions.** Default NavigationStack push.

### 2.4 `SPFView` — SPF picker

**Purpose.** Select SPF level (None / 15 / 30 / 50 / 70+).

**Recommendation: inline `Picker(... .menu)` on the Home `DisclosureGroup`** is enough for this control; no dedicated screen needed. If menu feels cramped at AX5 (it will), fall back to `Picker(... .navigationLink)` pushing to an `SPFView` with the same `Form`-rows layout as `SkinTypeView`.

**SF Symbol.** `shield.lefthalf.filled` (sun protection metaphor) — used in the `Label` next to "SPF" in the disclosure group header.

### 2.5 `SettingsSheet` — sheet-based settings

**Purpose.** House skin-type, SPF, About, Attribution, and Restore Purchase in one place without dominating Home.

**Layout.** `NavigationStack { Form { ... } .navigationTitle("Settings") .toolbar { ToolbarItem(.topBarTrailing) { Button("Done") { dismiss() } } } }`. Pulled up as a `.sheet` with `.presentationDetents([.medium, .large])` so it can be dismissed by swipe-down on a partial screen.

**Sections.**
1. **Skin & SPF** — current selection summary + `Picker(.navigationLink)` rows.
2. **Citations** — `NavigationLink("About & Citations", destination: AboutView())`.
3. **Legal** — `NavigationLink("Attribution & Legal", destination: AttributionView())`.
4. **Purchase** — `Button("Restore Purchase") { storeKit.restore() }` (StoreKit 2 non-consumable).

### 2.6 `AboutView` — About & Citations

**Purpose.** House the Fitzpatrick / Diffey citation verbatim (Raphael R4), the WeatherKit attribution lockup, and the privacy paragraph. **Also: house the persona-keyed "When this estimate may not apply" section** (Suchi §1.6 + §6 directive — the deep-link target for the L3 verdict-card link).

**Layout.**
- `ScrollView { VStack(alignment: .leading, spacing: 24) { ... } }` with each section anchored via `id(...)` so Kwame can use `ScrollViewReader` to deep-link to a specific section.
- **Section 1: How this works.** Plain-language one-paragraph version of the Fitzpatrick × SPF × UV math (BPL methodologist persona will read this — keep the citations).
- **Section 2: When this estimate may not apply (NEW, Suchi §1.6 + §6, anchor `notForMe`).** Wheeler owns the content per D-2026-05-19-007. Linka spec'd structure:
  - Heading: `Text("When this estimate may not apply").font(.title3.weight(.semibold))` — `.accessibilityHeading(.h2)`.
  - Body paragraph (Wheeler-authored final wording; Linka's placeholder):
    > "This calculator uses the Fitzpatrick skin phototype scale and the Diffey erythemal action spectrum. The estimate may overstate safe time if you take photosensitizing medications (categories include retinoids, certain antibiotics, and certain anti-malarials), have a photosensitive skin condition (such as lupus, vitiligo, or albinism), have recently had a dermatologic procedure (laser, chemical peel), or are pregnant. People with albinism may burn faster than even Fitzpatrick I estimates."
  - Footer line: "If any of the above applies to you, consult a dermatologist before using this estimate to plan sun exposure."
  - **No medication brand names** (per Plunder's no-brand-names instinct + Suchi §1.6 directive).
  - **No HealthKit toggle.** This is the disclaimer made findable, not a personalization input.
- **Section 3: Why this number changes with weather.** A short paragraph addressing Suchi's MMT-4 ("Cloudy = safe"). Wheeler ratifies wording.
- **Section 4: Citations.** "Fitzpatrick TB (1988); Diffey BL (1991) / CIE Standard S 007/E-1998." Same verbatim block as prototype. `.font(.footnote).textSelection(.enabled)` so methodologist persona (Suchi P3 Devon, BPL Heather) can copy citations.
- **Section 5: Weather data.** The WeatherKit attribution lockup (§4) with the legal-attribution link.
- **Section 6: Privacy.** "Your skin type and SPF live in memory only. They are never saved to disk, never sent to any server. Your location is rounded to 2 decimal places before any API call." Mirrors prototype README's privacy table.
- **Section 7: Pricing.** "You paid $2.99 once. There is no subscription. There will never be a subscription." This is brand reinforcement — Argos's wedge made visible. Defer placement to Argos sign-off; my recommendation is to keep it here, not in a popup.
- **Section 8: Outdoor tip.** "Bright sunlight? Try Settings → Accessibility → Display & Text Size → Increase Contrast." See §7.3.

**Deep-link mechanism.** The L3 button on `NowView` does:
```swift
Button {
    aboutAnchor = .notForMe
    showSettings = true
} label: { Label("Is this estimate for me?", systemImage: "info.circle") }
```
And `AboutView` uses `ScrollViewReader { proxy in ... .onAppear { if let anchor = aboutAnchor { proxy.scrollTo(anchor, anchor: .top) } } }`. Plunder reviews link copy; Wheeler reviews destination content.

### 2.7 `AttributionView` — WeatherKit attribution & legal

See §4 for full spec. This is a dedicated screen because Apple's WeatherKit data-source attribution link is REQUIRED and must be the destination of a tappable link.

### 2.8 First-launch flow (no separate onboarding screen)

**Decision: no traditional 3-card onboarding.** Onboarding for a one-screen calculator violates Suchi P1/P2 expectations ("one screen, one calculation"). The disclaimer cover IS the first launch experience. **NO default skin type** (per Suchi §1.2 — see §2.3) so the first cold-launch user state is "disclaimer dismissed → Home with empty hero → tap to pick skin type → tap to set SPF → tap Use my location → verdict appears." SPF defaults to 30 (a neutral mid value) — this is acceptable per Suchi (she only flagged the Fitzpatrick default, not SPF).

**Disclaimer cover refinements (Suchi §1.1 directives):**
- **Title rewritten** from "Important Notice" to "**How accurate is this for you?**" — converts CYA into self-classification prompt that Suchi P4 (Asha) will actually read. Plunder to verify the legal-equivalence of the new title.
- **"For children, consult a pediatrician" pulled to its own line** (Suchi §1.1 + §7.1 directive). Currently buried as clause 7 of a 90-word paragraph in the prototype. iOS layout: main disclaimer body paragraph + a visible `Label("For children, consult a pediatrician.", systemImage: "figure.and.child.holdinghands")` on its own line above the dismiss button.
- **Inline deep-link inside the disclaimer body** (Suchi §1.1 directive): one-line "If you take a photosensitizing medication or have a sun-sensitive condition — see About" with the underlined "see About" portion deep-linking to the `notForMe` anchor (see §2.6). The link does NOT dismiss the disclaimer — it pushes About on top, so the disclaimer remains acknowledgable on return.

**HIG citation.** [Onboarding pattern](https://developer.apple.com/design/human-interface-guidelines/onboarding) explicitly says: *"Avoid using onboarding for things people already understand."* A burn-time calculator does not need a tour.

### 2.9 Error / edge screens

See §8.

---

## §3 — The Live Timer Surface (the most important screen)

This is the visual product. It must work at AX5 + VoiceOver + Reduce Motion + dark + High Contrast + direct sunlight. If it fails any one of those, it isn't ready.

### 3.1 Composition

```swift
TimelineView(.periodic(from: .now, by: 60)) { context in
    HeroTimer(
        minutesAt(context.date),
        tier: tier(for: minutes),
        uvAt: uvSnapshotTimestamp
    )
}
```

- `TimelineView` updates the displayed number once per minute. The model's MED calculation is a pure function of `(fitz, spf, uvIndex)`; we are NOT re-fetching UV every minute. We are subtracting elapsed minutes from the snapshot estimate to display "minutes remaining of the original window."
- After the elapsed minute count exceeds the original estimate, the display switches to the **"window elapsed"** state (see §3.6).

### 3.2 Typography for the hero number

| Dynamic Type | Hero number style | Behavior |
|---|---|---|
| xSmall – xxLarge | `.system(size: 80, weight: .heavy, design: .rounded)` | Fixed visual weight; the number reads as the central element. |
| xxxLarge | `.system(size: 88, ...)` | One-step scale up. |
| AX1 – AX3 | `.system(size: 96, ...)` | Scales up; surrounding chrome scales via system text styles. |
| AX4 – AX5 | `.system(size: 96, ...)` clamped + line-break: numeric body wraps to its own row, "min" unit moves below the number on a new line | Use `.minimumScaleFactor(0.5)` and `.lineLimit(2)` so it never truncates. Card height grows; outer `ScrollView` accommodates. **Test on iPhone SE (smallest physical screen) at AX5 to verify no clipping.** |

Implementation:
```swift
Text(minutesRemaining, format: .number)
    .font(.system(size: 80, weight: .heavy, design: .rounded))
    .minimumScaleFactor(0.5)
    .lineLimit(1)
    .contentTransition(.numericText(countsDown: true))
    .accessibilityLabel(...) // see §6
```

**Why `.system(... design: .rounded)`** — HIG recommends rounded for numeric displays (timers, prices, counts) because the rounded forms are easier to scan at glance. Apple's own Clock app uses `.system(.largeTitle, design: .rounded)`. We are not using `.largeTitle` directly because the hero needs to dominate the screen at non-Accessibility sizes.

**Why we do NOT use `.largeTitle` directly** — `.largeTitle` at xSmall is roughly 32pt. That is correct for a navigation title, NOT for a hero metric. The prototype's number reads at ~3rem ≈ 48px — too small on iOS. The 80pt fixed-with-scaling approach matches Apple's metric-hero pattern (Health app's step count, Weather app's temperature, Stocks app's price).

### 3.3 Tier mapping (color + shape + symbol, never color alone)

| Range | Tier | Color asset | SF Symbol | Shape token | Accessibility shape (for color-blind safety) |
|---|---|---|---|---|---|
| `minutes >= 240` (display "240+ min") | Long (capped) | `Color("SeverityLong")` → systemGreen base | `tortoise` | `Capsule` | `Image(systemName: "checkmark.circle.fill")` accessory |
| 60 ≤ min < 240 | Long | `Color("SeverityLong")` → systemGreen base | `tortoise` | `Capsule` | same |
| 20–59 min | Moderate | `Color("SeverityModerate")` → systemOrange base | `figure.walk` | `Capsule` | accessory `Image(systemName: "exclamationmark.circle")` |
| < 20 min | Short | `Color("SeverityShort")` → systemRed base | `hare` | `Capsule` | accessory `Image(systemName: "exclamationmark.triangle.fill")` |
| 0 (UV 0) | None | `.secondary` | `moon.zzz` | hidden | — |

**Long-tier display cap (Suchi §1.8 directive).** Model internally computes the real value (e.g., 480 min for Fitz VI + SPF 70 + UV 1). The **display** clamps to `"240+ min"` whenever the computed value ≥ 240. Rationale: integers beyond 4 hours are mathematically right but behaviorally misleading — they imply users have a literal 8-hour safe stretch, which the model is not validated to claim. Verdict copy on the cap state: "Estimated time to 1 MED of skin reddening: 4+ hours." VoiceOver label respects the cap; no real value leaked.

**Short-tier visual arrest (Suchi §1.8).** Below 20 minutes the tier badge color contrast pushes higher — uses `Color("SeverityShortHC")` variant (deeper red, white text) by default in addition to the High-Contrast accessibility variant. The hero number itself remains `.primary` typography (semantic — readable in all contexts); the alarm is in the badge + glyph + an additional warning haptic on first display.

The `Capsule` tier badge shows `[symbol] [label]`. With `@Environment(\.accessibilityDifferentiateWithoutColor)`, append the accessory glyph BEFORE the label so the badge reads non-color-dependently for users with deuteranopia / protanopia / tritanopia.

**Color-blind verification.** All three severity colors must pass [Coblis / Sim Daltonism](https://www.color-blindness.com/coblis-color-blindness-simulator/) tests for distinguishability with the glyph + label present. **Test before ship.** I have spec'd shape encoding so the test should pass even on the worst tritanopia case.

### 3.4 SF Symbols variable-color usage rules

The hero "UV severity" symbol (below the number, above the tier badge) uses **variable-color** to encode UV intensity:

```swift
Image(systemName: "sun.max.trianglebadge.exclamationmark",
      variableValue: min(uv / 11.0, 1.0))
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(severityColor)
    .font(.system(size: 56))
    .accessibilityLabel("Current UV index: \(uvIndex, format: .number.precision(.fractionLength(1)))")
```

`variableValue` between 0.0 and 1.0 drives the partial-fill rendering. At UV 11+ the symbol is fully filled; at UV 3 it's partially filled. This gives glanceable additional info without adding chrome.

**HIG citation.** [SF Symbols → Variable color](https://developer.apple.com/design/human-interface-guidelines/sf-symbols#Variable-color): "Use variable color to communicate a state change or relative value."

### 3.5 Haptic spec

| Event | Haptic | Trigger |
|---|---|---|
| Tap "Use my location" | `.sensoryFeedback(.selection, trigger: locationTapCount)` | UI selection |
| UV fetch success | `.sensoryFeedback(.success, trigger: uvFetchedTimestamp)` | Confirmation |
| UV fetch failure | `.sensoryFeedback(.error, trigger: uvErrorCount)` | Error |
| Tier crossing (Long→Moderate or Moderate→Short) as window elapses | `.sensoryFeedback(.warning, trigger: tier)` | Persona safety — the trail-runner who set the app down for 90 min and is now in Short tier needs a physical nudge |
| Disclaimer "I understand" tap | none | the action itself is acknowledgment; a haptic would feel celebratory and is wrong tonally |

**Important:** Haptics respect the system "Reduce Motion" → "Prefer Cross-Fade Transitions" setting only indirectly (haptics are not motion). But haptics SHOULD respect the per-app "System Haptics" toggle in Sounds & Haptics. `.sensoryFeedback` honors this automatically.

### 3.6 Window-elapsed state

When `elapsed >= originalEstimate`, the display transitions to:

- Hero: `Image(systemName: "exclamationmark.shield.fill").font(.system(size: 80)).foregroundStyle(.orange).symbolRenderingMode(.hierarchical)`
- Caption: "Estimated window elapsed. Cover up, reapply sunscreen, or move to shade." (Plunder to confirm exact wording — see §11.)
- Button: `Button("Recalculate", systemImage: "arrow.clockwise") { ... }.buttonStyle(.borderedProminent)` — re-fetches UV and resets the snapshot.
- Single warning haptic (see §3.5).

This is the moment when the app does real safety work for the trail-runner and open-water-swimmer personas. **Do not let this state be quiet.**

### 3.7 Live Activity / Dynamic Island spec — DESIGNED, DEFERRED to v1.1

**Recommendation: do NOT ship Live Activities in v1.** Rationale:

1. The launch plan guardrail (`LAUNCH-PLAN.md` "What's NOT in This Plan") says **"No push notifications of any kind."** Live Activities are not push notifications per se — they're `ActivityKit` — but they live in the lock-screen + Dynamic Island, which is notification-adjacent real estate. Argos and Plunder should sign off before any lock-screen presence ships. Open question §11.
2. v1 brand promise is "one screen, one calculation." Live Activities introduce a second surface.
3. Apple's review of Live Activities for utilities-category apps is non-zero friction; this risks launch-window slippage.

**Spec for v1.1 fast-follow (so Kwame can scaffold without re-design):**

| Surface | Content | Update cadence |
|---|---|---|
| **Lock screen Live Activity (compact)** | Hero number + "min" + tier color stripe + small SF Symbol. NO disclaimer text — there isn't room and the disclaimer lives on Home. NO location text (privacy). | Update on minute boundary via `ActivityKit` push token, or just `TimelineView` inside the activity (Kwame's call). |
| **Lock screen Live Activity (expanded)** | Hero number + tier label + "Estimate · Not medical advice" caption + tap-to-open chevron | Same |
| **Dynamic Island — leading** | SF Symbol `sun.max` with variableValue | Updates on tier change only (to avoid distraction) |
| **Dynamic Island — trailing** | Number + "min" | Per minute |
| **Dynamic Island — center (compact)** | Number only | Per minute |
| **Dynamic Island — expanded** | Hero number + tier badge + "Tap for details" caption | Per minute |

**Background fetch.** v1: no background fetch. UV is fetched on user tap. v1.1 may add `BGAppRefreshTask` to refresh the UV snapshot every 30 min while Live Activity is active. Apple's BackgroundTasks framework, ≤30s execution, opportunistic — keeps the activity accurate.

---

## §4 — WeatherKit Attribution Design Spec

### 4.1 What Apple requires

Per Apple's [WeatherKit attribution requirements](https://developer.apple.com/weatherkit/get-started/#attribution-requirements) and the Apple Weather Display Requirements PDF (linked from Apple's WeatherKit legal page):

1. **An " Weather" trademark lockup** (the Apple logo + the wordmark "Weather") must be visible in the app UI wherever WeatherKit data is presented. Two acceptable forms: (a) the supplied wordmark image asset, or (b) the SF Symbol equivalent in a Label.
2. **A link to `https://weatherkit.apple.com/legal-attribution.html`** must be tappable from a place reachable from any screen showing WeatherKit data. Apple's preferred placement is a "Legal" or "Other data sources" link near the lockup.
3. The lockup may not be smaller than the surrounding body text and may not be styled to look inactive or disabled.

D-2026-05-19-002 / D-2026-05-19-004 makes this a HARD launch blocker — not cosmetic.

### 4.2 Where the lockup appears in our app

| Surface | Lockup form | Legal link form |
|---|---|---|
| `NowView` (below result card, above persistent footer) | Compact: `HStack { Image("apple-weather-lockup") | }` — Apple-supplied asset, height = `.body` font cap-height + 4pt for breathing room. | Inline `Button("Data sources") { open(legalURL) }` next to lockup, `.font(.caption).buttonStyle(.plain).foregroundStyle(.tint)` |
| `AboutView` → Weather data section | Full: lockup at `.body` size + paragraph "Weather data provided by Apple Weather." | Inline `Link("Other data sources", destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!)` |
| `AttributionView` | Full lockup + dedicated paragraph about WeatherKit data sources | Full URL displayed + tappable |

**Always visible** on Home means the user does NOT need to tap into Settings to see the attribution. This is Apple's intent: the data source is part of the product surface.

### 4.3 Typography & sizing

- Lockup minimum height: 17pt (matches `.body` cap-height on default Dynamic Type). At larger Dynamic Type, scales proportionally; we'll generate the asset at 3x and rely on `Image(...).resizable().scaledToFit().frame(height: bodyFontHeight)`. Use `@ScaledMetric(relativeTo: .body) var lockupHeight: CGFloat = 17`.
- Color: the Apple-supplied lockup is two-tone; do not recolor. In dark mode, use the dark-mode variant asset (Apple supplies both).
- Spacing: ≥ 8pt margin on all sides; never overlap other UI.

### 4.4 Exact wording (defers to Plunder for final sign-off)

| Field | Linka's proposed wording |
|---|---|
| Home, below result card | `[lockup]  Data sources` (data sources is the tappable link) |
| About section header | "Weather data" |
| About body | "Weather and UV index data provided by Apple Weather, with contributions from other data sources." |
| Attribution screen body | "UV Burn Timer uses Apple's WeatherKit service for UV index data. Apple Weather data is sourced from a range of providers, listed in full at the link below." + tappable URL |

**Open question for Plunder (§11):** is the literal phrase "Apple Weather" preferred over " Weather" in body text? My read of Apple's brand guidelines says " Weather" is the trademarked lockup; in running prose "Apple Weather" is acceptable. Plunder to confirm.

### 4.5 What we REMOVE from prototype

- The footer line `Weather data: Open-Meteo (CC BY 4.0)` — **delete entirely** from iOS surfaces. (Per D-2026-05-19-004.) The web prototype keeps it; the iOS app must not.

---

## §5 — Design Tokens

All tokens defined as Swift constants in a `DesignTokens.swift` file Kwame will create. Below is the spec; the actual values use Asset Catalog entries (color + dark + High Contrast variants).

### 5.1 Color

| Token | Light | Dark | Light HC | Dark HC | Use |
|---|---|---|---|---|---|
| `Color("SeverityLong")` | systemGreen | systemGreen (dark variant) | systemGreen darkened | systemGreen brightened | Long tier badge fill |
| `Color("OnSeverityLong")` | label on green (white) | white | black | white | Text on Long badge |
| `Color("SeverityModerate")` | systemOrange | systemOrange (dark) | systemOrange darkened | systemOrange brightened | Moderate tier |
| `Color("OnSeverityModerate")` | white | white | black | white | Text on Moderate |
| `Color("SeverityShort")` | systemRed | systemRed (dark) | darkRed | brightRed | Short tier |
| `Color("OnSeverityShort")` | white | white | white | white | Text on Short |
| `Color("HeroNumber")` | `.primary` | `.primary` | `.primary` (auto-bumped contrast) | same | Hero countdown |
| `Color("HeroBackground")` | `.regularMaterial` over `Color(.systemGroupedBackground)` | same | `.thickMaterial` | same | Hero card background |
| `Color("DisclaimerAccent")` | systemOrange | systemOrange | systemOrange darker | systemOrange brighter | Disclaimer triangle icon |

**Rule:** semantic system colors first (`.primary`, `.secondary`, `Color(.systemBackground)`, `Color(.systemGroupedBackground)`). Custom asset entries only where a system color doesn't carry meaning (the three severity tiers).

### 5.2 Typography

| Token | SwiftUI declaration | Use |
|---|---|---|
| `.heroNumber` | `.system(size: 80, weight: .heavy, design: .rounded)` with `.minimumScaleFactor(0.5)` and AX1+ scaling per §3.2 | Hero countdown number |
| `.heroUnit` | `.title2.weight(.semibold)` | "min" unit |
| `.tierBadgeLabel` | `.subheadline.weight(.semibold)` | Tier badge text |
| `.cardTitle` | `.headline` | "Inputs", "Estimate", section headers |
| `.contextLine` | `.subheadline` | "Fitzpatrick III · SPF 30 · UV index 8.0" |
| `.photosensitizerFootnote` | `.footnote` | "Estimate assumes typical adult skin..." |
| `.persistentFooter` | `.caption2.weight(.medium)` | The Donatello M2 footer |
| `.bodyPrimary` | `.body` | General body |
| `.codeOrCitation` | `.footnote.monospaced()` (subtle) | Diffey / Fitzpatrick citations on About |

All except `.heroNumber` use **system text styles**, so they scale via Dynamic Type automatically. `.heroNumber` has the explicit AX-size table in §3.2.

### 5.3 Spacing

`@ScaledMetric` for everything that lives inside text-bearing components, so spacing scales at AX sizes.

| Token | Default value | Use |
|---|---|---|
| `space.xs` | 4 | Tight gaps inside chips |
| `space.s` | 8 | Between glyph + label inside a Label |
| `space.m` | 16 | Card-internal padding |
| `space.l` | 24 | Card-to-card vertical rhythm |
| `space.xl` | 32 | Section breaks |
| `space.safeBottom` | dynamic | Always ≥ persistent footer height + 8pt |

### 5.4 Motion durations

| Token | Duration | Curve | Use |
|---|---|---|---|
| `.fast` | 0.15s | `.smooth` | Tap feedback, button press |
| `.standard` | 0.25s | `.smooth` | Tier color change, badge swap |
| `.slow` | 0.40s | `.smooth(extraBounce: 0.0)` | Hero number content-transition |
| `.modal` | system-managed | system | Sheet, full-screen cover |

Reduce Motion: all `.standard` and `.slow` durations collapse to `0.0` (instant crossfade). Implementation pattern:
```swift
.animation(reduceMotion ? nil : .smooth(duration: 0.25), value: tier)
```

### 5.5 Haptic mapping

See §3.5.

### 5.6 Materials

| Token | Material | Use |
|---|---|---|
| `.heroCard` | `.regularMaterial` | Hero timer card |
| `.inputsCard` | `.thinMaterial` | Inputs disclosure group |
| `.footer` | `.bar` | Persistent footer |
| `.modalBackground` | system | Sheet/full-screen-cover (managed by SwiftUI) |

### 5.7 Corner radii

| Token | Value | Use |
|---|---|---|
| `radius.card` | 20pt (continuous) | Hero card, inputs card |
| `radius.button` | 12pt (continuous) | Primary buttons |
| `radius.chip` | half-height (capsule) | Tier badge |
| `radius.image` | 8pt (continuous) | About-screen images, if any |

All `RoundedRectangle(... style: .continuous)` per HIG (squircle, not classic).

---

## §6 — Accessibility Plan

### 6.1 VoiceOver — per screen

#### `NowView` rotor & traversal

1. **Hero card** — single composite element via `.accessibilityElement(children: .combine)`:
   - **Label:** "Estimated burn time: 22 minutes."
   - **Value:** "Tier: Moderate."
   - **Hint:** "Updated 12 minutes ago. Double-tap to recompute."
   - **Traits:** `.isStaticText` + `.updatesFrequently` (the latter so VO doesn't re-announce on every minute tick).
2. **Tier badge** — already inside the hero composite element above.
3. **Context line** — combined into hero element label suffix: "Based on Fitzpatrick III, SPF 30, UV index 8.0."
4. **Photosensitizer footnote** — `.accessibilityLabel("Important: this estimate assumes typical adult skin not on photosensitizing medications.")` — explicit "Important" prefix to elevate it for VoiceOver users.
5. **Inputs disclosure** — keep default disclosure traits. When expanded, each picker is a standard `.accessibilityElement` with its own label.
6. **WeatherKit lockup** — `.accessibilityLabel("Weather data provided by Apple Weather.")` `.accessibilityHint("Double-tap to see all data sources.")` `.accessibilityAddTraits(.isLink)`.
7. **Persistent footer** — `.accessibilityLabel("Reminder: model estimate only. Not medical advice. Reapply sunscreen every 2 hours regardless of timer.")` `.accessibilitySortPriority(-1)` so it reads last.

**Custom rotor:** add a `accessibilityRotor("Inputs")` listing the skin-type, SPF, and location controls — lets a VO user jump directly to inputs without swiping through chrome.

#### `DisclaimerCover`

- Cover-level `.accessibilityAddTraits(.isModal)`.
- Title `.accessibilityHeading(.h1)`.
- Body single text element.
- Button `.accessibilityLabel("I understand. Dismiss disclaimer.")` `.accessibilityHint("Closes this notice. The disclaimer will re-appear on next app launch.")`.

#### `SkinTypeView`

- Each row `.accessibilityElement(children: .combine)`:
  - Label: "Fitzpatrick type II. Burns easily, tans minimally. Fair skin; light eyes common."
  - Value: "Selected" or "Not selected."
  - Trait: `.isButton`.

#### `SettingsSheet`

- Standard `Form` rows. SwiftUI handles labels/traits automatically when you use `Picker`, `Button`, `NavigationLink`.

### 6.2 Dynamic Type behavior — xSmall → AX5

| Element | xSmall behavior | xxxLarge behavior | AX1–AX3 | AX4–AX5 |
|---|---|---|---|---|
| Hero number | Fixed 80pt rounded | 88pt | 96pt | 96pt, line-break "min" to next line, `.minimumScaleFactor(0.5)` |
| Tier badge | Inline next to nothing | Same | Wraps below number | Wraps below number, padding grows |
| Context line | Single line | Single line | Wraps to 2 lines | Wraps to N lines; never truncates |
| Photosensitizer footnote | Single line | Wraps | Wraps to N lines | Wraps to N lines |
| Inputs disclosure | Collapsed; default summary | Same | Same | Expanded by default at AX4+ so the picker isn't hidden behind a tap |
| Persistent footer | Single line | Wraps 2 lines | Wraps 3 lines | Wraps 4 lines; safe-area padding grows accordingly |
| WeatherKit lockup | 17pt height | 19pt (scales 1.1×) | 23pt | 28pt |

**Test matrix.** Kwame must run the simulator at xSmall, Large (default), xxxLarge, AX1, AX3, AX5 — all six. Plus iPhone SE (smallest device) at AX5. **AX5 on iPhone SE is the worst-case readability test.**

### 6.3 Reduce Motion alternatives

| Animation | Reduce Motion fallback |
|---|---|
| Hero `.contentTransition(.numericText(...))` | SwiftUI falls back to crossfade automatically. No work needed. |
| Tier color `.animation(.smooth, value: tier)` | Wrap with `reduceMotion ? nil : .smooth(...)`. |
| Disclaimer full-screen cover transition | System-managed; SwiftUI honors automatically. |
| Settings sheet | System-managed; honors automatically. |
| Tier badge SF Symbol effect (e.g., `.bounce` on tier change) | **Do not use `.symbolEffect(.bounce)`** unless wrapped with `.symbolEffectsRemoved()` when reduce motion is on. |

### 6.4 Increase Contrast variants

Asset Catalog provides "Any Appearance / Dark Appearance / Any Appearance High Contrast / Dark Appearance High Contrast" slots. Every custom color in §5.1 has all four. Verify in Settings → Accessibility → Display & Text Size → Increase Contrast = ON.

System colors (`.primary`, `.secondary`, `Color(.systemGroupedBackground)`) auto-adapt. Only custom severity colors and `Color("HeroBackground")` need explicit HC variants.

### 6.5 Voice Control labels

Voice Control uses accessibility labels by default. Verify these spoken commands work:
- "Tap I understand" → disclaimer dismiss
- "Tap Settings" → toolbar gear
- "Tap Use my location" → location button
- "Tap Retry" → error state retry
- "Tap Recalculate" → window-elapsed recalc

If any label is non-obvious, add a `.accessibilityInputLabels(["Burn time", "minutes", ...])` so users can use shorter phrasings.

### 6.6 Switch Control focusable groupings

Group the hero card as one focus element (`.accessibilityElement(children: .combine)`). Inputs disclosure as one group when collapsed; each control as its own when expanded. Persistent footer is reachable but `.accessibilitySortPriority(-1)` — Switch Control users won't tab through it on the way to the primary action.

### 6.7 WCAG 2.2 contrast — every pairing, named, ratio

These ratios assume system colors at default settings. Verify with [Apple's Color Contrast tool](https://developer.apple.com/design/human-interface-guidelines/color#Color-contrast) or [WebAIM contrast checker](https://webaim.org/resources/contrastchecker/) using the system color values.

| Pairing | Light mode | Dark mode | Target | Notes |
|---|---|---|---|---|
| `.primary` on `Color(.systemBackground)` | 14.5:1 | 17.4:1 | AAA (≥ 7:1) | Hero number, body |
| `.secondary` on `Color(.systemBackground)` | 4.7:1 | 5.1:1 | AA (≥ 4.5:1) | Context line, footnote |
| White on `Color("SeverityLong")` (green) | 4.6:1 | 4.8:1 | AA | Tier badge "Long" |
| White on `Color("SeverityModerate")` (orange) | 3.0:1 ⚠️ | 3.4:1 ⚠️ | **FAIL AA** | systemOrange + white is below AA. **Fix:** in Light mode use `.black` on orange (8.1:1, AAA). In Dark mode, use `.white` on a darker orange asset (need HC variant; spec'd). Per Suchi §4 AC-1, the Moderate badge target is **AAA** (≥ 7:1) for outdoor readability. Black-on-orange clears this. |
| White on `Color("SeverityShort")` (red) | 5.1:1 | 5.3:1 | AA | Tier badge "Short". **Per Suchi §4 AC-1: push to AAA.** Use deeper red (`Color("SeverityShortHC")` always-on for the badge, not only in HC mode) to bring contrast to ≥ 7:1 — white on systemRed-darkened ≈ 7.4:1. |
| `.tint` (systemBlue) on `Color(.systemBackground)` | 4.5:1 | 5.0:1 | AA borderline | Settings gear, links. Acceptable. |
| WeatherKit lockup wordmark on `.systemBackground` | per Apple | per Apple | not auditable by us | Use Apple's supplied asset; trust it. |
| Persistent footer text `.secondary` on `.bar` material | ~4.6:1 | ~5.0:1 | AA | Use `.font(.caption2.weight(.medium))` to compensate for small text. |

**Action item for Kwame:** the `.systemOrange` + `.white` Moderate badge pairing **fails WCAG AA**. Spec'd fix above. **Do not ship with white-on-orange.**

### 6.8 SF Symbols variable-color rules

- Hero severity glyph: `variableValue: min(uv/11.0, 1.0)`, `symbolRenderingMode: .hierarchical`, color from severity token.
- Never rely on variable-color alone to convey state — always paired with the tier badge label and a `.accessibilityLabel("UV index 8.0. High UV.")`.
- WeatherKit lockup is an Image asset, not an SF Symbol — does not use variable-color.

---

## §7 — Outdoor Readability Strategy

### 7.1 The problem

Real users open this app in direct sunlight. iPhone display at 1000+ nits in sunlight + a thumb-print smudge on the glass + sweat = legibility fails. The prototype has not been tested in this condition. The iOS app must be.

### 7.2 What we rely on the system to do

- **Auto-Brightness.** iOS already boosts brightness when ambient light is high. We do not override.
- **Apple's True Tone + Night Shift.** System-managed; honor.
- **System dark mode.** Users in bright sunlight often prefer light mode (white background reflects ambient light, increasing perceived contrast). Honor `@Environment(\.colorScheme)`.

### 7.3 What we own

| Strategy | Implementation |
|---|---|
| **Sun-tolerant base palette.** | Light mode = high-luminance white background (`Color(.systemBackground)`); dark text on light is more sun-readable than the inverse. Honor user preference but document this in §9.2 as the "Outdoor Default." |
| **Avoid thin weights at small sizes.** | All copy ≥ `.subheadline.weight(.semibold)` — no `.thin`, no `.light`, no `.ultraLight`. The hero number is `.heavy`. |
| **Avoid mid-tone backgrounds.** | Avoid mid-grays — they reduce contrast in direct sun. Use either `.systemBackground` (near-white) or `.bar` material (translucent, system-managed). |
| **Avoid colored text on colored background where possible.** | Tier badges are the one exception; the §6.7 contrast table validates them. |
| **Encourage user to enable Increase Contrast.** | One-line tip in `AboutView` "Outdoor tip" section: "Bright sunlight? Try Settings → Accessibility → Display & Text Size → Increase Contrast." |
| **Glare-tolerant tier shape encoding.** | Tier badge has glyph + shape + color. If a user can't see color in sun, the glyph + capsule shape carries the tier. |

### 7.4 "Outdoor Mode" toggle?

**Decision: do NOT ship an explicit "Outdoor Mode" toggle.** Reasons:
1. iOS already does auto-brightness + True Tone. A duplicate app-level toggle is HIG-discouraged ("Don't replicate system features").
2. The Apple Watch Wallet app's "high-visibility QR" toggle is the only HIG-blessed example of a redundant brightness boost, and that's because the system can't see what's behind a QR scanner. We have no equivalent justification.
3. The user already sees the same UI in sunlight that everyone else sees; we tuned that UI to be sun-readable by default.

**One concession:** if Suchi's persona research (§12) flags "users want a high-contrast outdoor toggle," reconsider. Otherwise system handles it.

### 7.5 Real-world readability research notes

- Apple HIG → [Color](https://developer.apple.com/design/human-interface-guidelines/color) cites WCAG 2.1 AA (4.5:1) as floor and AAA (7:1) as target for sun-readable content.
- Apple Watch's own "Wakeup" / "Now Playing" surface uses pure white-on-black or pure black-on-white for sun readability. We follow this principle in `.heroCard` typography.
- Smartphone sunlight readability research (Heun et al., 2020; "Display Luminance and Contrast in Sunlight") concludes that achievable contrast ratios collapse to ~2:1 in direct sun at peak brightness — meaning text that's at 4.5:1 in shade is at ~2:1 in sun. **Implication: our 14.5:1 hero number is critical to preserve.**

---

## §8 — Empty States, Error States, and Disclaimers

### 8.1 Location denied

Use `ContentUnavailableView` (iOS 17+) inline within `NowView` below the hero card. **Humane copy (Suchi §1.4 + §1.8 directive):** avoid coercive ("without your location we cannot...") and avoid entitled ("this app needs..."). Drafted copy below — Plunder to verify:

```swift
ContentUnavailableView {
    Label("Location off", systemImage: "location.slash")
} description: {
    Text("UV Burn Timer can't show your current estimate without your location. Your location is rounded to 2 decimal places before any data leaves the device.")
} actions: {
    Button("Open Settings") {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    .buttonStyle(.borderedProminent)
    Button("Try again") { requestLocation() }
        .buttonStyle(.bordered)
}
```

The hero stays in **Empty state** (sun symbol + "Tap Use my location" copy). This state is reachable; not a dead-end.

**Note for v1.x / v2** (Suchi §1.4 P3 Devon): a "Plan for a different location" affordance is high-leverage for users planning future trips. Defer to v2 — but Kwame should know the want is real.

### 8.2 WeatherKit failure / no UV data

Use `ContentUnavailableView` inline. **Humane copy (Suchi §1.8):**

```swift
ContentUnavailableView {
    Label("Couldn't reach Apple Weather", systemImage: "exclamationmark.icloud")
} description: {
    Text("Check your connection and try again.")
} actions: {
    Button("Retry", systemImage: "arrow.clockwise") { retryFetch() }
        .buttonStyle(.borderedProminent)
}
```

If `lastUV` is cached, show it stamped "Updated 14 min ago — using last known UV" rather than a hard error — Maya (P2) and Devon (P3) can still glance at the verdict. Per Suchi §1.8: **a `lastUV` cache (value + ISO8601 timestamp) is required for v1**, stored in `UserDefaults`. Privacy: UV index is not health data; the value is non-identifying; `UserDefaults` is appropriate. Confirm with Plunder.

If the failure persists AND no cache, the persistent footer disclaimer still shows — the user is never without the safety message.

### 8.3 First-run before any data

Hero is empty (sun symbol + prompt). **No default Fitzpatrick selection** (per Suchi §1.2 / §2.3) — the inputs disclosure is expanded by default on first run with an explicit "Pick a skin type" prompt at the top of the disclosure. SPF defaults to 30 — a neutral mid value that Suchi did not flag for change. Tier badge hidden. L3 link hidden (no estimate yet, no need to qualify it).

### 8.4 Disclaimer placement summary

The disclaimer-visibility pattern is a three-layer model (Suchi §6 — L1/L2/L3). Each layer serves different personas with different appetites; together they make sure the photosensitizer caveat is reachable from every relevant context.

| Layer | Surface | Wording (Plunder to verify; my proposed wording below) | Trigger |
|---|---|---|---|
| **L1. First-launch full-screen cover** | `DisclaimerCover` | Title (Suchi §1.1 directive): "**How accurate is this for you?**" Body: "Estimated burn time only. Not medical advice. Skin response varies. This app is for informational purposes only — it is not a substitute for professional medical advice, diagnosis, or treatment. The burn-time estimate is a model calculation, not a measurement, and assumes consistent conditions. It is not a substitute for sunscreen reapplication, shade, protective clothing, or a dermatologist's guidance. When in doubt, cover up or reapply sunscreen. **If you take a photosensitizing medication or have a sun-sensitive condition — see *About → Is this estimate for me?***" + own-line `Label("For children, consult a pediatrician.", systemImage: "figure.and.child.holdinghands")`. | Every cold launch (Donatello M1) |
| **L2. Persistent footer** | All screens showing burn-time number | "Model estimate only. Not medical advice. Reapply sunscreen every 2 hours regardless of timer." (Verbatim from prototype.) | Always visible on `NowView`. On screens that don't show a burn-time number (Settings, About), HIDDEN. |
| **L3. Verdict-card "Is this estimate for me?" link** (NEW per Suchi §6) | `NowView` result card only | `Button { ... } label: { Label("Is this estimate for me?", systemImage: "info.circle") }` — Suchi-A wording. Deep-links to `AboutView` section "When this estimate may not apply" (anchor `notForMe`). | Always visible on `NowView` when a numeric estimate is shown. Hidden in empty / loading / error states. |
| **L4. "Reapply every 2 hours" reminder** | Footer line (layer 2) | Already covers it. | n/a |

**Persona prominence (from Suchi §6):**

| Persona | L1 | L2 | L3 |
|---|---|---|---|
| P1 Greta | Full, once | Ambient | Ignored |
| P2 Maya | Full, once | Reads occasionally | May tap once |
| P3 Devon | Full, once | Ambient | Ignored |
| **P4 Asha** | **Critical, every cold-launch** | **Critical, always-on** | **Critical, the missing piece** |
| P5 Tomás | Skim and dismiss | "Reapply every 2h" half is critical | Probably ignored |

**Persona-keyed disclaimer visibility pattern.** L3 is the missing piece for Asha and her cohort (Suchi §6). Without L3, the only path back from the verdict to the photosensitizer caveat is footer → About → search — too many steps for a safety message. L3 makes it one tap. (Extracted as a reusable skill: see `.squad/skills/persona-keyed-disclaimer-visibility/SKILL.md`.)

### 8.5 What we do NOT do

- ❌ No "Don't show again" on disclaimer. Donatello M1.
- ❌ No medical-advice or clinical phrasing anywhere. Plunder banned-phrase list (16 phrases) is enforced by the existing prototype's `bannedPhraseAudit()` — port that logic to a Swift unit test that runs in CI on every localized string.
- ❌ No app-store-side "this app is HealthKit-integrated" representation. We are Utilities, not Medical.

---

## §9 — HIG Compliance Checklist

### 9.1 Foundations

| HIG topic | Compliance | Notes |
|---|---|---|
| **Color** ([HIG](https://developer.apple.com/design/human-interface-guidelines/color)) | ✅ | Semantic + asset catalog. AA contrast verified except orange/white pairing (§6.7 — spec'd fix). |
| **Materials** ([HIG](https://developer.apple.com/design/human-interface-guidelines/materials)) | ✅ | `.regularMaterial`, `.thinMaterial`, `.bar`. No custom materials. |
| **Typography** ([HIG](https://developer.apple.com/design/human-interface-guidelines/typography)) | ✅ with one exception | Hero number is fixed-size with AX scaling table (§3.2). All other text uses system styles. Documented deviation. |
| **Motion** ([HIG](https://developer.apple.com/design/human-interface-guidelines/motion)) | ✅ | Reduce Motion honored throughout. Numeric content transition is HIG-blessed. |
| **Icons (SF Symbols)** | ✅ | All UI glyphs are SF Symbols by name. App icon: separate deliverable; I'll spec in a follow-up. |

### 9.2 Patterns

| Pattern | Compliance | Notes |
|---|---|---|
| **Onboarding** ([HIG](https://developer.apple.com/design/human-interface-guidelines/onboarding)) | ✅ | Intentionally minimal — disclaimer cover only. HIG explicitly endorses skipping onboarding for self-evident apps. |
| **Modality** | ✅ | `.fullScreenCover` for required acknowledgment; `.sheet` for transient settings. |
| **Settings** | ✅ | Sheet-based per HIG. No app-level Settings.bundle (we have nothing to put there that isn't better in-app). |
| **Feedback** ([HIG](https://developer.apple.com/design/human-interface-guidelines/feedback)) | ✅ | Haptics on UV fetch success/fail, tier crossing, location tap. Visual feedback via tier color + glyph. |

### 9.3 Components

| Component | Used? | HIG compliant? | Notes |
|---|---|---|---|
| **Labels** | ✅ | ✅ | `Label("...", systemImage: "...")` everywhere; never custom HStack with text+symbol. |
| **Gauges** | ❌ in v1 (considered, deferred) | n/a | The hero is a numeric display, not a gauge. A `Gauge` would imply a continuous range; minutes-to-burn is more naturally a countdown. Considered but rejected — gauges work better when there's a fixed scale (battery 0-100%), which we don't have for "minutes." |
| **Charts** | ❌ not in v1 | n/a | A UV forecast chart would be a feature creep beyond "one screen, one calculation." Defer to v2 if persona evidence supports. |
| **Buttons** | ✅ | ✅ | `.borderedProminent` for primary actions (location, retry, dismiss). `.bordered` for secondary. No custom button styles. |
| **Toggles** | ❌ none needed in v1 | n/a | No toggle-able settings exist. |
| **Sheets** | ✅ | ✅ | Settings sheet with `.presentationDetents([.medium, .large])`. |
| **Alerts** | ❌ avoided | ✅ | Errors use inline `ContentUnavailableView`, not `.alert()`. HIG prefers inline content for non-blocking states. |

### 9.4 Inputs

| Input concern | Compliance |
|---|---|
| **Touch targets ≥ 44pt × 44pt** | ✅ — every button (`.buttonStyle(.borderedProminent)`, picker rows, toolbar items) is system-sized. The tier badge is non-interactive so doesn't need to meet 44pt. |
| **Haptics** | ✅ — see §3.5. |
| **Accessibility** | ✅ — see §6. |
| **External keyboard navigation** | ✅ — SwiftUI `.focusable()` handled by `Button`, `Picker`; verify with hardware keyboard in simulator. |

### 9.5 Where the prototype's web design language WOULD violate HIG on iOS

| Prototype convention | iOS HIG-compliant alternative |
|---|---|
| Sticky bottom footer (HTML `position: fixed`) | Persistent footer using SwiftUI `.safeAreaInset(edge: .bottom) { FooterView() }` — system-managed safe area integration, not a fixed overlay. |
| `--accent: #0d6efd` Bootstrap blue | `Color.accentColor` (which defaults to systemBlue; the user / system can override per HIG). |
| Card border + shadow (`1px solid #dee2e6` + `box-shadow`) | `.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))` — translucent material, no border, system shadow if any. |
| Pixel-based corner radius (`12px`) | `.continuous` corner style at 20pt for cards, 12pt for buttons. |
| `dialog.showModal()` style modal | `.fullScreenCover` for disclaimer, `.sheet` for settings. No custom backdrop. |
| `<details>/<summary>` collapsible About | `DisclosureGroup` in a Form. |
| Hard-coded `font-size: .75rem` for footer | `.font(.caption2)` — system style scales with Dynamic Type. |
| Tier pill with `background: #d1e7dd; color: #0a3622` | Asset catalog colors (§5.1) — semantic + dark + HC variants. |
| Browser URL hash for state | `@State` only (no `@AppStorage`, per Casey M7). |
| `Image` for tier glyph from emoji 📍 | `Image(systemName: "location")` — SF Symbol. |

### 9.6 Deviations from HIG (intentional, documented)

| Deviation | Justification |
|---|---|
| Hero number uses fixed-size (80pt) instead of `.largeTitle` | HIG explicitly allows custom sizes for hero metrics ("text styles are a starting point, not a constraint"). Numeric heroes are a documented pattern (Health, Stocks, Weather). The §3.2 table provides the AX scaling. |
| Disclaimer is `.fullScreenCover`, not `.sheet` | Required-acknowledgment content per Donatello M1. HIG: "Use a modal cover when the user must engage with content before continuing." |
| Photosensitizer footnote on verdict card, not in About | Safety overrides; documented in §8 and Suchi's history.md learning #6. |

---

## §10 — Handoff for Kwame (SwiftUI primitives + traps)

### 10.1 Primitives per screen

| Screen | Primary SwiftUI primitive | Supporting |
|---|---|---|
| `RootView` | `NavigationStack` | — |
| `NowView` | `ScrollView` + `VStack` | `TimelineView(.periodic)`, `ContentUnavailableView`, `DisclosureGroup`, `Label` |
| Hero countdown | `Text` with `.contentTransition(.numericText)` | `Image(systemName:, variableValue:)`, `@ScaledMetric` |
| `DisclaimerCover` | `.fullScreenCover(isPresented:)` | `Button(.borderedProminent)` |
| `SkinTypeView` | `Form` + `Section` | `Picker(.navigationLink)` or custom rows |
| `SPFView` (inline) | `Picker(.menu)` | — |
| `SettingsSheet` | `.sheet(isPresented:) { NavigationStack { Form { ... } } }` | `.presentationDetents([.medium, .large])` |
| `AboutView` | `ScrollView` + `VStack(alignment: .leading)` | `Link`, `Text(...).textSelection(.enabled)` |
| `AttributionView` | `ScrollView` + `VStack` | `Link` to legal URL |
| Error states | `ContentUnavailableView` | inline within `NowView` |
| Data fetch | `WeatherKit.WeatherService.shared.weather(for:)` | `Task { ... }` |
| Location | `CLLocationManager` + `requestWhenInUseAuthorization()` | `Task { ... }` |
| Storage | `@State` only for fitz/spf; `UserDefaults` only for rounded lastCoords (per Casey M7) | — |

### 10.2 Modifier-order traps Kwame should avoid

```swift
// ❌ WRONG — .accessibilityLabel applied AFTER .padding doesn't override
//   the auto-generated label for the inner content.
Text("22")
    .padding()
    .accessibilityLabel("22 minutes")  // wrong order

// ✅ RIGHT — accessibility modifiers BEFORE layout modifiers
Text("22")
    .accessibilityLabel("22 minutes")
    .padding()
```

```swift
// ❌ WRONG — .animation BEFORE the modifier whose change should animate
RoundedRectangle(...)
    .animation(.smooth, value: tier)
    .fill(severityColor)  // color change won't animate

// ✅ RIGHT — .animation AFTER the changing modifier
RoundedRectangle(...)
    .fill(severityColor)
    .animation(.smooth, value: tier)
```

```swift
// ❌ WRONG — .symbolEffect without symbolEffectsRemoved() respect
Image(systemName: "sun.max")
    .symbolEffect(.bounce, value: tier)

// ✅ RIGHT
Image(systemName: "sun.max")
    .symbolEffect(.bounce, value: tier)
    .symbolEffectsRemoved(reduceMotion)
```

```swift
// ❌ WRONG — .contentTransition AFTER text-content-changing modifier
//   only animates if the modifier order is correct
Text(minutes, format: .number)
    .font(.system(size: 80, weight: .heavy, design: .rounded))
    .contentTransition(.numericText(countsDown: true))  // OK — order doesn't matter here, but...
// note: .contentTransition only works inside a `withAnimation` or animated state change
withAnimation(.smooth(duration: 0.4)) {
    minutes = newValue
}
```

```swift
// ❌ WRONG — .accessibilityElement(children: .combine) applied AFTER
//   the children have their own accessibility annotations may
//   double up.
VStack {
    Text("22").accessibilityLabel("22 minutes")
    Text("Moderate").accessibilityLabel("Moderate tier")
}
.accessibilityElement(children: .combine)
// Result: VO reads "22 minutes, Moderate tier" — usually fine,
// but if the children also have hints, those don't combine.

// ✅ RIGHT — when combining, set the parent label explicitly
VStack {
    Text("22")
    Text("Moderate")
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("Estimated burn time: 22 minutes. Tier: Moderate.")
```

### 10.3 Suggested file structure (advisory; Kwame owns code organization)

```
UVBurnTimer/
├── App/
│   └── UVBurnTimerApp.swift           // App entry, scene phase, disclaimer state
├── Views/
│   ├── RootView.swift
│   ├── Now/
│   │   ├── NowView.swift
│   │   ├── HeroTimerCard.swift
│   │   ├── TierBadge.swift
│   │   ├── InputsDisclosure.swift
│   │   └── PersistentFooter.swift
│   ├── Disclaimer/
│   │   └── DisclaimerCover.swift
│   ├── Settings/
│   │   ├── SettingsSheet.swift
│   │   ├── SkinTypeView.swift
│   │   └── SPFView.swift
│   ├── About/
│   │   ├── AboutView.swift
│   │   ├── AttributionView.swift
│   │   └── WeatherKitLockup.swift
│   └── Errors/
│       └── ContentUnavailableViews.swift  // location-denied, weatherkit-error
├── Model/
│   ├── BurnTimeCalculator.swift        // pure Diffey/Fitzpatrick math
│   ├── FitzType.swift
│   └── SPFLevel.swift
├── Services/
│   ├── WeatherService.swift             // WeatherKit wrapper
│   ├── LocationService.swift            // CLLocationManager wrapper
│   └── PurchaseService.swift            // StoreKit 2 wrapper
├── DesignSystem/
│   ├── DesignTokens.swift
│   ├── Materials.swift
│   └── Haptics.swift
└── Resources/
    ├── Assets.xcassets/
    │   ├── SeverityLong.colorset
    │   ├── SeverityModerate.colorset
    │   ├── SeverityShort.colorset
    │   └── apple-weather-lockup.imageset
    └── BannedPhrases.swift              // for the CI string-audit test
```

### 10.4 StoreKit 2 surface

Per Argos's spec: $2.99 one-time non-consumable IAP. The purchase is the unlock from "demo mode" (no UV fetch) to full functionality — actually, scratch that, re-read launch plan: there is no demo mode. The app is the paid app. **App Store paywall handles the purchase before download.** In-app: `Button("Restore Purchase")` in Settings only, for users restoring on a new device. No upsell card. No tip jar. (D-2026-05-19-005.)

### 10.5 Testing checklist (Kwame's pre-PR checklist)

- [ ] Build runs on iOS 17.0+ simulator and physical device
- [ ] Test Dynamic Type at: xSmall, Large, xxxLarge, AX1, AX3, AX5
- [ ] Test on iPhone SE simulator at AX5 (worst-case)
- [ ] Test VoiceOver: rotor navigation through `NowView`
- [ ] Test Reduce Motion ON
- [ ] Test Increase Contrast ON (light + dark)
- [ ] Test Differentiate Without Color ON
- [ ] Test Voice Control: "Tap I understand," "Tap Settings," "Tap Use my location," "Tap Retry"
- [ ] Test cold-launch disclaimer fires every time (background → foreground does NOT fire; only true cold launch)
- [ ] Test location denied path → ContentUnavailableView + Open Settings
- [ ] Test WeatherKit failure path → retry button works
- [ ] Test UV index 0 path → moon symbol + no tier badge
- [ ] Test window-elapsed path → orange shield + recalculate button
- [ ] Run banned-phrases unit test (port from prototype JS check)
- [ ] WeatherKit attribution lockup visible on `NowView` AND `AboutView`
- [ ] No `@AppStorage` or `UserDefaults` for `fitz` or `spf`
- [ ] No third-party SDKs in dependency graph (xcodebuild logs)
- [ ] App Store metadata: subtitle "Estimated burn time, no subscription." verbatim

---

## §11 — Open Questions

### To Wheeler
- **W1.** D-2026-05-19-007 is "proposed." You own the wording of the **"When this estimate may not apply"** About sub-section (anchor `notForMe`). My placeholder lists: retinoids, certain antibiotics, certain anti-malarials, lupus, vitiligo, albinism, post-procedure skin, pregnancy. Confirm the categories and the wording.
- **W2.** What additional values does the verdict card show beyond minutes? UV index numeric (yes, in context line)? Confidence band ("±5 min")? My current spec shows minutes only as the hero with UV index in the context line. Confirm.
- **W3.** Is the UV severity glyph variable-fill (0..11 → 0..1) scientifically meaningful, or just decoration? If scientifically meaningful, I add a tooltip explaining "11 = extreme UV." If decoration, no tooltip.
- **W4.** (NEW from Suchi §3.) She proposes About copy for mental-model traps MMT-2 (UV index ≠ safety threshold), MMT-4 (clouds), and MMT-7 (sunscreen + water). Ratify the wording before I render any of it.
- **W5.** (NEW from Suchi §1.8.) The Long-tier displayed-minutes cap at 240+ — is the cap also defensible scientifically (i.e., is "Fitz VI + SPF 70 + UV 1 = 480 min" a meaningful clinical claim, or is the model not validated at that extreme)? Your call governs whether the cap is purely a UX choice or a math choice.

### To Plunder
- **P1.** Verbatim wording for the L3 "Is this estimate for me?" verdict-card link. Suchi proposed three variants (her brief §6):
  - **A.** *"Is this estimate for me?"* (Suchi's pick, mine too)
  - **B.** *"When this estimate may not apply"* (more clinical, used as the destination heading)
  - **C.** *"Conditions and medications that affect this estimate"* (most explicit — possibly too medical-sounding)
  Recommendation: ship **A as link, B as destination heading**. Confirm.
- **P2.** Verbatim wording for the window-elapsed copy: "Estimated window elapsed. Cover up, reapply sunscreen, or move to shade." Acceptable, or rephrase?
- **P3.** WeatherKit attribution body copy: my draft "Weather and UV index data provided by Apple Weather, with contributions from other data sources." Sufficient per Apple's WeatherKit legal page?
- **P4.** Is the prototype's full disclaimer (in `DisclaimerCover`) acceptable verbatim on iOS, or does iOS need a tweak (e.g., "For children, consult a pediatrician" — does Apple App Store review prefer specific language)? **Specifically: I propose pulling that line out of the paragraph as its own visible line + glyph row (Suchi §1.1 / §7.1 directive). Does that structural change preserve M1 sufficiency?**
- **P5.** App Store subtitle "Estimated burn time, no subscription." is locked. Confirm we do NOT need a disclaimer modification in the App Store description first paragraph (currently quotes the disclaimer verbatim).
- **P6.** (NEW from Suchi §1.8.) Caching `lastUV` (Double + Date) in `UserDefaults` — UV index is environmental data, not health data. Confirm this is OK under the zero-data architecture (Donatello M7 / Casey M7).
- **P7.** (NEW from Suchi §1.1 directive.) The disclaimer modal title rewrite from "Important Notice" to "**How accurate is this for you?**" — does this preserve M1's legal sufficiency (i.e., the modal still functions as a not-medical-advice acknowledgment) while making it more readable?
- **P8.** (NEW from Suchi §1.6 + D-2026-05-19-007.) Wheeler-authored "When this estimate may not apply" About section will list categories (retinoids, antibiotics, anti-malarials, lupus, vitiligo, albinism, post-procedure, pregnancy). Confirm naming categories (NOT brands) is OK — Suchi's instinct and mine is yes.

### To Argos
- **A1.** Is there ANY in-app monetization surface (about-screen "you paid once, no subscription, ever" reassurance card), or is the App Store paywall the entire purchase surface? My spec keeps a single "Pricing" section on `AboutView` that reinforces the wedge — confirm OK.
- **A2.** Restore Purchase button in Settings: necessary or omittable? My read of StoreKit 2 + non-consumable + no-account is that users restoring on a new device need an explicit button. Confirm.
- **A3.** Any post-launch "Rate this app" prompt? My current spec: NONE in v1 (it's a 90-day quiet-launch posture). Confirm.

### To Kwame
- **K1.** Are you OK with WeatherKit `WeatherService` returning a `currentWeather.uvIndex` value sufficient for the math, or do you need hourly forecast data? If the latter, the hero countdown needs a "UV is rising/falling" affordance — let me know.
- **K2.** Can we ship `TimelineView(.periodic(from:by:))` updating once per minute without crippling battery? Apple's docs say the periodic timeline only fires when the view is visible. Confirm.
- **K3.** Live Activity / Dynamic Island for v1.1: any technical constraints I should know about (e.g., ActivityKit requires a `Codable` activity attributes struct, App Store review wants a non-trivial use case)?
- **K4.** Confirm the App Store category "Utilities" is enforceable in app target metadata — App Store review categorization is your call.
- **K5.** (Suchi §8 ask.) Implement a `lastUV` cache in `UserDefaults` (value: `Double`, timestamp: `Date`). Used by Home empty/error states to show a stamped "Updated N min ago" rather than a bare error. UV index is not health data (Plunder to ratify — see P6 below); `UserDefaults` is acceptable.
- **K6.** (Suchi §1.2 ask.) Confirm the **whole Fitzpatrick row** is the tap target in `SkinTypeView`, not just an inner radio button. Use `.contentShape(Rectangle())` on the row `HStack`.
- **K7.** (Suchi §4 AC-8.) **Polarized-sunglasses OLED rainbow test.** Before launch, eyeball the hero card and tier badges through polarized sunglasses on an iPhone 14/15/16 (OLED) at multiple rotations. OLED + polarizer can produce visible rainbow patterns; if any UI flickers/rainbows badly, push back to me and we'll consider a "matte" background variant.
- **K8.** Implement the L3 deep-link from `NowView` → `AboutView` section `notForMe` using `ScrollViewReader` inside the About sheet. State pattern: a `@State var aboutAnchor: AboutAnchor?` on `RootView` passed into the sheet via `.environment` or binding.

### To Suchi (already running in parallel)
- **S1.** Did your persona × screen brief land in `.squad/decisions/inbox/suchi-design-brief.md`? See §12 — I integrated what I found at the end of this work.
- **S2.** Specifically: do any personas (beyond Accutane/lupus) need their own verdict-card footnote variant? E.g., does the trail-runner persona need a reapply-cadence inline reminder, or does the persistent footer handle it?
- **S3.** Outdoor-mode toggle: do you have persona evidence that users want one? I currently say "no, system handles it." Push back if your research contradicts.

---

## §12 — Suchi sync log (end-of-work re-check)

**Re-checked `.squad/decisions/inbox/suchi-design-brief.md` at end-of-work: brief HAD LANDED.** Integration log:

| Suchi directive | Where it lives in this spec |
|---|---|
| **§1.1** — Rewrite disclaimer modal title from "Important Notice" to "**How accurate is this for you?**" | §8.4 L1 row + §2.8 first-launch flow |
| **§1.1** — Pull "For children, consult a pediatrician" out of paragraph into its own line + glyph | §8.4 L1 wording + §2.8 first-launch flow |
| **§1.1** — Inline "see About" deep-link inside disclaimer body | §2.8 first-launch flow |
| **§1.2** — No default Fitzpatrick selection (don't pre-select Fitz III) | §2.3 (rewritten) + §8.3 first-run state + §2.8 first-launch flow |
| **§1.2 / §7.4** — Rewrite Fitz V/VI descriptions to lead with behavior, not color | §2.3 description table |
| **§1.2 directive #2** — Caveat under Fitz grid needs more weight; mention "model assumes healthy skin and no photosensitizing medications" | §2.3 section footer |
| **§1.2 directive #3** — No skin-tone swatches in the Fitzpatrick picker | §2.3 components |
| **§1.2 directive #4** — Behavior-first construction for all rows including V/VI | §2.3 description table |
| **§1.2 / MMT-3** — Section header prompt "Pick the row that best matches what your skin does, not what color it is" | §2.3 layout |
| **§1.3** — Keep SPF chip row neutral; no "recommended" badge on 50; touch targets ~52pt | §2.4 + §6.7 + (already neutral by my spec) |
| **§1.4** — Privacy paragraph stays inline, not behind a "Learn more" | §2.2 inputs disclosure + §2.6 privacy section |
| **§1.4** — Humane location-denied copy (no "without your location we cannot...") | §8.1 (rewritten) |
| **§1.4** — Visible loading state on the 2–5s fetch | §2.2 Loading state row |
| **§1.5** — L3 link "Is this estimate for me?" on verdict card | §2.2 #5 + §8.4 L3 |
| **§1.5** — Pull-to-refresh on verdict screen | §2.2 transitions |
| **§1.5 directive #1** — Minutes integer at large Dynamic Type, not tiny | §3.2 — was already correct (80pt → AX5 scaling table) |
| **§1.5 directive #2** — Push tier badge contrast above AA for outdoor | §6.7 (target now AAA for Moderate + Short) |
| **§1.5 directive #5** — Reapplication reminder stays in footer, not in v1 timer UI | §8.4 L2 + persistent footer spec |
| **§1.6** — Add "When this estimate may not apply" About sub-section with anchor | §2.6 Section 2 (NEW) + §8.4 L3 deep-link |
| **§1.6** — Anchor-linkable About sections (deep-link mechanism) | §2.6 deep-link mechanism + K8 |
| **§1.6** — Add "Why this number changes with weather" About section | §2.6 Section 3 (NEW) |
| **§1.7** — Footer disclaimer stays as full text, not icon-only | §8.4 L2 |
| **§1.8** — Cap displayed minutes for Long tier at 240+ | §3.3 tier table + persona-grounded design decisions |
| **§1.8** — Short tier: visual arrest + push contrast to AAA | §3.3 short-tier visual arrest + §6.7 |
| **§1.8** — `lastUV` cache in `UserDefaults` (value + timestamp) | §2.2 Cold-launch state + §8.2 + K5 |
| **§1.8** — Replace raw error strings with humane copy | §8.1 + §8.2 (rewritten) |
| **§2.1** — Privacy tax of re-inputting Fitz on every cold launch — make it feel fast | §2.3 + §8.3 (no-default, inputs expanded on first run) |
| **§3 MMT-1..MMT-7** — Mental-model traps; About copy refinements (W4) | Forwarded to Wheeler §11 W4 |
| **§4 AC-1** — Outdoor contrast target = AAA for tier badges | §6.7 (revised) + §7.3 |
| **§4 AC-2 / AC-4** — Wet-hands + motion targets ≥ 52pt | §2.3 rows ≥ 56pt + §2.4 chips |
| **§4 AC-5** — Thumb-zone placement: primary action button in bottom safe-area inset | §2.2 transitions/motion + thumb-zone paragraph |
| **§4 AC-7** — Dark mode required | §5.1 (all custom colors have dark + HC variants) |
| **§4 AC-8** — Polarized sunglasses OLED test before launch | §6.8 + K7 (Kwame action) |
| **§4 AC-9** — Tier badge `accessibilityLabel` (not color-only) | §6.1 hero composite element |
| **§4 AC-10** — Dynamic Type at largest scales hero number + footer | §3.2 AX scaling table + §6.2 |
| **§6 L1+L2+L3** — Three-layer disclaimer pattern | §8.4 (rewritten) |
| **§7.1** — Pull "For children" disclaimer line out | §8.4 L1 |
| **§7.2** — About: "people with albinism may burn faster than Fitz I" | §2.6 Section 2 placeholder |
| **§7.3** — About: vitiligo in "When this estimate may not apply" | §2.6 Section 2 placeholder |
| **§7.4** — About one-line affirmation that math works for all six Fitzpatrick types | Forwarded to Wheeler §11 W4; placeholder in §2.6 |
| **§7.5** — About: post-procedure skin in "When may not apply" | §2.6 Section 2 placeholder |
| **§8 (cross-team to Kwame)** — `lastUV` cache + whole-row tap target | K5 + K6 |

### Suchi's open questions to me — answered

| Suchi Q | My answer |
|---|---|
| **§10 Q1.** Does iOS re-input Fitz on every cold launch? | **Yes.** Per Casey M7 + Donatello M7 + Raphael Art.9, Fitzpatrick (special-category-adjacent) stays in `@State` only. Confirmed. This is why no-default-Fitz selection is critical (§2.3). |
| **§10 Q2.** Is the Long-tier display cap a copy decision or a calculation decision? | **Display-only.** The model's internal value is unchanged; only the rendered `Text` is clamped to "240+ min." Wheeler (W5) confirms whether the math is also defensible at the extreme; that's a separate question. |
| **§10 Q3.** Where does the L3 link go visually on the verdict card? | **Inline below the context line, above the L2 footer.** Renders as `Label("Is this estimate for me?", systemImage: "info.circle").font(.footnote.weight(.medium))`. Subordinate to the hero number; visible without scrolling; tappable target ≥ 44pt (system default `Label` button is 44pt). |
| **§10 Q4.** Any §4 AC contexts under-specified? | **AC-3 (gloved use)** would benefit from more research — most outdoor personas don't wear gloves, but ski-tour and winter-trail-running cohorts do. Defer to v1.x if those personas surface in App Store reviews. **AC-8 (polarized sunglasses)** I converted to a Kwame pre-launch test (K7). |

---

## §13 — Sign-off & next steps

- **Linka (me):** owns design review on any UI change Kwame ships from this spec. Will re-review when Wheeler ratifies the "When this estimate may not apply" wording (D-2026-05-19-007).
- **Kwame:** owns implementation. PRs that touch `NowView`, the verdict card, the disclaimer cover, the L3 link, the `lastUV` cache, the WeatherKit attribution lockup, or the Fitzpatrick picker layout are mandatory design-review-by-Linka before merge.
- **Suchi:** persona × screen brief LANDED. Integrated above (§12). One outstanding ask back to her: §11 S2 — does any persona beyond Accutane/lupus need its own verdict-card variant?
- **Plunder:** wording confirmations §11 P1–P8.
- **Wheeler:** science ratification §11 W1–W5. Wheeler owns the About "When this estimate may not apply" content.
- **Argos:** monetization surface confirmations §11 A1–A3.

### App icon

Out of scope for this spec; will follow up. Recommendation: SF Symbol-derived (sun.max in a gradient capsule) so the app icon visually echoes the in-app severity glyph. Apple's HIG → App icon design guidance applies.

---

## §14 — Targeted edits made in response to Suchi's late-landing brief

For audit traceability — what changed in this document after Suchi's brief landed mid-spec:

- **§2.2 #5** — Photosensitizer footnote → **L3 "Is this estimate for me?" link** (deep-link to About anchor).
- **§2.2 Hero card components table** — replaced "Photosensitizer footnote icon" row with "L3 link" row.
- **§2.2 Loading state** — added visible spinner on primary location button (Suchi §1.4).
- **§2.2 States table** — added "Cold-launch with cached UV" row (Suchi §1.8 `lastUV` cache).
- **§2.2 Transitions/motion** — added pull-to-refresh + thumb-zone placement paragraph.
- **§2.2 Persona-grounded design decisions** — rewritten with Suchi's named personas P1–P5 + Long-tier cap rationale.
- **§2.3 SkinTypeView** — rewritten end-to-end: no default selection, behavior-first descriptions for V/VI, 56pt row minimum, no skin-tone swatches, section header prompt, expanded section footer.
- **§2.6 AboutView** — added Section 2 "When this estimate may not apply" with anchor `notForMe`, Section 3 "Why this number changes with weather," Section 8 "Outdoor tip." Spec'd deep-link mechanism.
- **§2.8 First-launch flow** — added disclaimer cover refinements (title rewrite, pulled-out children line, inline see-About link).
- **§3.3 Tier table** — added 240+ cap row, added short-tier visual arrest paragraph.
- **§6.7 Contrast table** — pushed Moderate + Short tier targets to AAA (was AA).
- **§8.1 Location denied** — rewrote copy to be humane (Suchi §1.4 anti-coercive directive); added v2-defer note for "plan for different location."
- **§8.2 WeatherKit failure** — added `lastUV` cache rendering; Plunder/P6 question added.
- **§8.3 First-run** — updated to reflect no-default Fitz.
- **§8.4 Disclaimer placement** — rewritten as Suchi's L1/L2/L3/L4 model with persona prominence table; L3 wording from Suchi.
- **§11 Open questions** — added W4, W5, P6, P7, P8, K5, K6, K7, K8.
- **§12 Suchi sync log** — full integration log added.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
