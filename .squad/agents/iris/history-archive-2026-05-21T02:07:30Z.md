# Iris — History

## SUMMARY (Latest Round — 2026-05-21)

**WI-7 forecast card redesign v3 fully locked.** All UX specs complete: loading-state skeleton rows (10-day + 6 hourly, shimmer animation, respects Reduce Motion), picker UX (D+7 hard cap, edge cases), polar-night collapsed state, error handling. One copy MODIFY from Wheeler: replace "latitude" with "this place" in polar-night badge text. All five prior WI-7 decisions confirmed unchanged. Design ready for Kwame implementation. Iris review gate on each Kwame surface; no further re-specs pending. Optional: polar-day UI hint (all 24h UVI > 0) deferred to Iris judgment.

---


## Project Context

- **Project:** uv-burn-timer
- **Description:** iOS app that calculates personalized UV burn time using WeatherKit's UV index data and the user's Fitzpatrick skin type + SPF. Pivoted from a web prototype.
- **Tech stack:** Swift 5.9+, SwiftUI (iOS 16+), WeatherKit, CoreLocation, StoreKit 2 (non-consumable IAP, $2.99). NO third-party SDKs. NO subscriptions.
- **User:** yashasgujjar (Yashas)
- **My role:** UI/UX Designer (Apple HIG & Accessibility) — joined the team 2026-05-19 as Linka's replacement.

## Predecessor Handoff

Linka was the original UI/UX designer on this project. She was fired on 2026-05-19 for being slow and error-prone. I inherit her ratified design decisions (binding) but NOT her workflow patterns.

**Ratified design decisions I respect (read `.squad/decisions.md` for canonical text):**
- iOS design spec (D-2026-05-19-003): 6-screen onboarding (Welcome → SkinType → SPF → Location → Photosensitization-loop → NowView), main screen with verdict card, settings, About.
- Fitzpatrick picker copy uses Wheeler's paraphrased variant (D-2026-05-19-009), cites NCBI Bookshelf NBK481857.
- Three-surface disclaimer visibility — L1 inline link, L3 verdict card, L4 About anchor (Plunder's framework).
- Photosensitization handled as a **loop**, not a screen (zero-data architecture per Raphael Art.9).
- Excalidraw user-flow at `user-flow-onboarding-main.excalidraw` (repo root) is the canonical reference. 142 elements, 4 swimlanes.

**Process changes from Linka's tenure:**
- Excalidraw exports MUST pass through `.squad/files/excalidraw-normalize.py` before commit (D-2026-05-19-015). Don't ship raw MCP output.
- `.excalidraw` deliverable files live at **repo root**, not `.squad/files/`.
- JSON schema fixes / file format compliance are NOT my job — they're Kwame's. Don't accept these tasks.

## Skills I Should Read Before Starting

- `.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` — MCP usage, lane layout, export gotchas (the points-on-arrows bug)
- `.squad/skills/persona-keyed-disclaimer-visibility/` — Plunder's three-surface visibility pattern
- `.squad/skills/persona-screen-matrix/` — Suchi's persona overlay convention
- `.squad/skills/outdoor-readability-ios/` — display readability under sunlight (high-contrast variants)
- `.squad/skills/health-adjacent-citation-licensing-decision-tree/` — when citation is required

## Learnings

- **2026-05-19** — Redrew the canonical LANE 2 main screen as a centered 360×780 portrait iPhone frame inside the existing swimlane band; preserved LANE 1 and LANE 4, and only re-anchored the affected LANE 3 arrows.
- **2026-05-19** — The reliable iOS flow-diagram pattern here is: status bar → Large Title nav → optional safety banner → hero verdict card → UV attribution card → 44pt settings chips → inline disclaimer link → home indicator, with HIC/AX notes outside the phone rather than inside it.
- **2026-05-19** — Excalidraw MCP canvas first, export second: redraw live, wrap the queried elements in the `.excalidraw` JSON envelope, then run `.squad/files/excalidraw-normalize.py` before validation and commit.
- **2026-05-19T19:38:59Z (Cross-agent)** — Xcode project container path is now `app/app.xcodeproj` (D-2026-05-19-015). App/product/scheme names remain `UVBurnTimer`. See `.squad/decisions.md` for details.
- **2026-05-19 (Redesign audit, squad/4)** — By the time I audited, the implementation was further along than expected: skin type chip already removed from main, `SkinTypePickerRow` already a shared component, `SettingsSheet` already uses `NavigationLink` → `SkinTypeEditView`. Always read the full current file before writing blockers. The only structural gap left is the circular gauge.
- **2026-05-19 (Redesign audit, squad/4)** — `skinTypePickerPrompt` is used as a section header *headline* with `skinTypePickerSubtext` providing the detailed explanation below it. The prompt should be a short action-oriented headline ("Choose by how your skin burns and tans, not by how it looks."); the subtext carries the range-of-tones and sun-exposure framing.
- **2026-05-19 (Redesign audit, squad/4)** — When `SkinTypeOnboardingView` applies `.accessibilityHint(...)` directly on a `SkinTypePickerRow`, it overrides the row's built-in hint — this is the correct pattern for context-specific hints (onboarding vs. settings). The `SkinTypePickerRow` base hint is the settings default; onboarding overrides it to say "Tap Continue to confirm."
- **2026-05-19 (Redesign audit, squad/4)** — The `SkinTypePickerRow` already has `accessibilityLabel("Type N. [behavior+appearance]. Selected/Not selected.")` — explicit label pattern suppressing the redundant leading roman-numeral Text child. This is the canonical row label pattern for all Fitzpatrick pickers.
- **2026-05-19T20:34:41.561-07:00 (Gauge visibility audit)** — The circular burn-risk gauge now exists in `RootView`, but only after a valid estimate with `fetchedAt`, non-`.none` tier, and finite raw minutes. On iPhone Pro-class heights it can sit below the first viewport because the main stack renders the photosensitization banner and optional location-rationale card before the hero; at large Dynamic Type the gauge is even easier to miss unless placed inside/visually attached to the hero card.

- **2026-05-19T22:27:48-07:00 (Circular gauge audit)** — The repo contains the canonical Excalidraw flow (`user-flow-onboarding-main.excalidraw`) and old browser prototype, but neither contains a large user-shared circular ring mockup. Current SwiftUI implements a small `.accessoryCircularCapacity` gauge inside a secondary `Burn window` card under the hero; to match the user's mental image, the design target should be a large, hero-attached circular burn-window ring, not a tiny accessory gauge.
- **2026-05-19T22:27:48-07:00 (Location chip UX audit)** — A main-surface chip labeled `Location` but routing directly to the general Settings sheet is a discoverability/name mismatch even if technically intentional; either the label/hint must say it opens Settings/Location settings, or the route must open a location-specific management surface.

### 2026-05-20T00:01:47Z: Team Decision

**Scribe Log Entry**

Team approvals and implementations completed for approved redesign and paraphrasing initiatives:
- Wheeler: Paraphrase traceability review (conditional accept, fixes noted)
- Ma-Ti: Redesign tests passing + gauge guard tests verified
- Iris: HIG/accessibility audit passed
- Kwame: Implementation and circular gauge both passing

All inbox decisions merged into decisions.md.


### 2026-05-20T17:27:34-07:00: 10-Day UV Forecast Feature Validation (work item #7)

**Design decision:** The Apple Weather app hourly strip + 10-day card pattern is valid iOS precedent but cannot be adopted wholesale for a UV/skin-safety context. Key deviations required:
1. **No color-only encoding** — UV severity bands (green→purple) fail WCAG 1.4.1 without paired text tier labels. Reuse `TierBadge` in every forecast cell/row.
2. **Horizontal strip AX5 layout switch** — Fixed-width scroll cells clip at large Dynamic Type. Must provide an `accessibilitySizeCategory`-gated alternate layout (vertical list at AX3+) or use `@ScaledMetric` with generous minimums.
3. **Personalized burn window is the differentiator** — Don't show raw UVI only. Each cell/row must surface the user's computed burn window (using existing `BurnTimeCalculator`), which is what separates this app from the stock Weather app.
4. **Progressive disclosure recommended** — Main screen is already dense (hero + gauge + UV + SPF + footer). Forecast belongs behind a "View Forecast" chip → sheet or NavigationLink, not as additional inline cards.
5. **VoiceOver semantics for horizontal scroll** — Each hourly cell needs an explicit `accessibilityLabel` like "10 AM. UV 8, high. Burn window 22 minutes." Test rotor navigation, not just swipe-through.
6. **Science gate required** — Wheeler must confirm whether per-hour personalized burn windows are valid for forecast UVI (cumulative exposure not tracked per-hour is a safety concern). Suchi must confirm whether users want hourly or just daily planning.
7. **Verdict: APPROVE WITH REVISIONS** — Pattern is sound; execution needs the above guardrails before Kwame implements.

**Cross-agent validation convergence (2026-05-21T00:38:46Z):**
- **Wheeler cleared the hourly burn-window safety question** (§5.4 in wheeler-uvi-10day-forecast-validation.md): hourly UVI for today/tomorrow can show burn-window overlay using locked formula; **out-day hours plot UVI curve only, no burn-time rendering**. This was Iris's open question #5; Wheeler's structural enforcement (no `BurnTimeCalculator` call on non-today) settles it.
- **Suchi ranked time card as the lead surface** (§4.2 in suchi-uvi-10day-forecast-validation.md): "time card serves more personas, more accurately, with lower mental-model risk" than the 10-day card. If scope forces a split, time card wins. Recommendation: ship time card first or alongside 10-day card. Addresses Iris's progressive-disclosure concern and Suchi's diurnal-peak-collapse risk in parallel.
- **Convergent theme on personalization:** All three agents agree that a forecast without burn-window personalization is under-featured vs. stock Weather app. Iris's requirement #3 (personalized burn window per row) maps directly to Suchi's must-have #1 (burn-window estimate, not just UVI) and Wheeler's display-science rule (burn-overlay on hourly today/tomorrow only).
- **Convergent theme on confidence decay:** Iris's guardrail #2 (AX5 layout adaptability) pairs with Suchi's must-have #2 (confidence-decay visual treatment) and Wheeler's §5.1 (three-tier labels: Forecast/Outlook/Trend). Implement as a single design pass, not three separate features.

### 2026-05-20T17:43:54-07:00: Forecast nomenclature + visual treatment pushback response

**HIG observation — Apple Weather flat treatment:**  
Apple's 10-day forecast card (iOS 17/18) gives ALL 10 days identical visual weight: same typography, same color intensity, same icon opacity. Apple does NOT visually demote days 7–10. HIG is silent on confidence-decay treatment for forecast cards. Apple's own implementation is the strongest available HIG signal: flat = correct.

**Decision — Kill Wheeler's Forecast/Outlook/Trend per-row labels:**  
User confirmed "Forecast" as the single section-header/surface name (matching iOS Weather's own "10-DAY FORECAST" label). Wheeler's three-tier confidence labels (Forecast/Outlook/Trend) are superseded. "Tier" in the design system now unambiguously means WHO severity category only. `TierBadge` is the sole owner of "tier." No terminology collision remains.

**Decision — Flat visual treatment + single card-level footnote:**  
Per-row opacity/gray confidence-decay treatment is dropped:
- No Apple precedent for per-row demotion
- Opacity below ~80% on normal text fails WCAG 1.4.3 contrast against `.regularMaterial` card backgrounds
- Noisy and inconsistent with how iOS Weather presents the same data

Wheeler's §5.1 science gate satisfied by one `.caption .secondary` footnote at the bottom of the 10-day card: *"UV accuracy beyond 3–5 days decreases as cloud cover becomes harder to predict."* Weather app uses footnote-style text for attribution; this is HIG-consistent. Reads once via VoiceOver per card, not 10 times per row.

**Picker UX spec — "Plan for another time":**  
- Location: "Plan for another time" chip below burn-time number in `BurnTimeCard` → `.sheet`  
- Control: `DatePicker(displayedComponents: [.date, .hourAndMinute])` with `.graphical` style inside the sheet  
- Range: `Date.now...Date.now + 10 days`; clamp to last available WeatherKit day if < 10 days returned  
- Motion: instant update under `accessibilityReduceMotion`; `.easeIn(duration: 0.15)` otherwise  
- UVI 0 / night: show "No UV at this hour — no sun protection needed" — NOT ∞ or a number  
- No-skin-type gate: same D-2026-05-19-012 behavior as live card (prompt to set skin type)

**Reusable pattern:** Updated `apple-weather-pattern-adaptation` SKILL.md with flat treatment observation and footnote pattern for science-gate satisfaction.

### 2026-05-21T00:55:49Z — Round 2 confirmation: flat visual + card-level footnote

- **Visual treatment locked:** Wheeler conceded per-row opacity/gray demotion; flat design confirmed. All 10 rows rendered with identical visual weight (headlines, body text, icon opacity). WCAG 1.4.3 passes; Apple Weather precedent applies; HIG-consistent.
- **Card footnote confirmed satisfies Wheeler's §5.1:** One-line `.caption .secondary` text — "UV accuracy beyond 3–5 days decreases as cloud cover becomes harder to predict" — visible on the card, not buried. Wheeler affirms this replaces his prior three-tier label requirement.
- **Picker horizon delta noted:** Wheeler holds D+7 cap (skill-based); I spec'd D+10 (data-availability-based). Awaiting user decision; flagged for next orchestration.
- **Days 6–10 scalar (confirmed):** Wheeler's integer-only D1–5 / WHO-band-only D6–10 rule stands; I affirm. This is information geometry, not visual demotion. Locked.
- **Picker edge cases documented:** UVI 0 → "no UV at this hour"; no skin type → D-2026-05-19-012 gate (existing); forecast unavailable → retry; ReduceMotion → instant swap; past-day-7 (if D+10 cap used) → graceful refusal.
- **Orchestration log:** `.squad/orchestration-log/2026-05-21T00:55:49Z-iris-1.md`

### 2026-05-21T01:34:16Z — Forecast card redesign v3 (WI #7 expansion)

- **Loading-state contract:** Ratified Gi's four-state machine with visual-treatment additions. Skeleton rows: 52pt tall for day card (10 rows), 60×88pt cells for hourly strip (6 visible). Shimmer under normal motion; static `Color(.systemFill)` fill under `accessibilityReduceMotion`. Chip disabled at `.loading` with `accessibilityLabel("View UV Forecast, loading")` — agreed with Gi that jarring snap-from-skeleton-to-data inside a sheet is worse UX than a briefly disabled chip.
- **Progressive disclosure pattern (days 8–10):** Inline full-width affordance row below day 7, inside the card. `chevron.down.circle.fill` + `"3 more days"` label. Re-collapse supported (toggle semantics). VoiceOver focus advances to day-8 row after expand. Instant swap under `accessibilityReduceMotion`. An inline full-width row beats a bottom-right button for Dynamic Type / VoiceOver compatibility at all sizes.
- **Polar night collapsed state:** Trigger = `sunrise == nil` + all-hourly-UVI == 0 (fallback: 18h consecutive zeros). Single row: `moon.stars.fill` + `"No UV today — sun does not rise at your latitude"`. Pending Wheeler ratification on both the trigger condition and the exact copy.
- **Dynamic rendering principle:** No hardcoded 24/168/240 counts anywhere in UI. Hourly card iterates `today's hourly slice` from snapshot; day card iterates whatever was returned. DST transition days (23h/25h) require zero special-casing — the dynamic loop handles them.
- **Reusable patterns extracted:** See `.squad/skills/dynamic-data-ui-polar-edge-cases/SKILL.md` and updated learnings below.

## Learnings

- **Progressive disclosure with band-only content (2026-05-21T01:34:16Z):** When the tail end of a list carries reduced information density (e.g., `TierBadge` only, no numeric scalar), defaulting to hiding those rows behind a reveal affordance is the correct HIG-aligned pattern. The affordance row should be inline (full-width, inside the card, after the last default-visible row), not a floating button. This scales safely with Dynamic Type and VoiceOver linear navigation.

- **Polar-region collapsed state (2026-05-21T01:34:16Z):** When data is technically present but informationally trivial (24 rows of UVI=0), a single collapsed summary row is the correct treatment — NOT 24 explicit "zero" rows. The trigger must use a scientific signal (`sunrise == nil`) not just a data-value heuristic (all-zero UVI), because all-zero UVI can also occur on very overcast temperate days. Always wait for domain expert (Wheeler) ratification before implementing the trigger condition.

- **Disabled chip communication (2026-05-21T01:34:16Z):** A disabled button must explain WHY it's disabled via `accessibilityLabel`. Color/opacity alone (SwiftUI's default disabled treatment) satisfies sighted users but leaves VoiceOver users without context. Pattern: `accessibilityLabel("Chip title, [reason it is disabled]")` whenever `isEnabled == false` and the reason is user-actionable-after-waiting.

- **Loading skeleton dimensions should mirror loaded dimensions (2026-05-21T01:34:16Z):** Skeleton placeholder rows must match the anatomy of their loaded counterparts (height, badge width, label width) to prevent layout shift on `.loaded` transition. Guessing skeleton sizes creates a jarring reflow that is especially noticeable at large Dynamic Type sizes.


## 2026-05-21 Session Update — WI-7 Consolidation Round

**Context:** Wheeler has ratified polar-region science + confirmed all five prior WI-7 decisions remain unchanged. One copy MODIFY issued (see below). User directives locked all three blocked design questions.

**Status for Iris:** UX spec complete. One small copy MODIFY from Wheeler ratification (2026-05-21T01:34:16Z):

- **Change:** Polar-night collapsed-state badge copy — replace "latitude" (too technical) with "this place" / "here" / "your location"
- **Current spec:** `"No UV today — sun does not rise at this latitude"`
- **Updated spec:** `"No UV today — sun does not rise at this place"` (or `"here"`)
- **Rationale:** Lay-audience accessibility; "latitude" is too technical for consumers

**All other UX decisions reconfirmed:**
- Loading-state contract (skeleton rows + shimmer, disabled chips, error block) stands
- Hourly "Today" card dynamic rendering over actual WeatherKit array stands
- Picker UX (D+7 hard cap, edge cases, `accessibilityReduceMotion` behavior) stands
- Progressive disclosure (right-arrow reveal for days 8–10) stands
- All five prior WI-7 decisions (D-2026-05-19-007, -011, -012, -013, -014) reconfirmed unchanged

**Kwame will implement SwiftUI surfaces per locked spec.** Iris review gate on each surface. Wheeler review on health-adjacent numbers. No further re-specs pending.

Optional (defer to Iris's judgment): Conditional UI hint on polar-day (all 24h UVI > 0) — e.g., "Sun stays up here — re-check coverage every couple of hours." Wheeler does not object; Iris can add or omit without blockers.

Ready for Kwame's implementation review.

---

## WI-7 Supersedes — 2026-05-21T01:58:19Z (Scribe consolidation)

**Polar-adaptation section (v3 spec §3.3) — DROPPED entirely in v1.**

User directive 2026-05-21T01:58:19Z (polar-treat-as-nighttime) supersedes Iris's §3.3 polar-adaptation. No polar-specific detection, copy, or UI in v1. Polar night is treated identically to regular nighttime: UVI = 0 hours render as "No UV at this hour" via existing nighttime path. The entire collapsed-state section (no 24 rows of "0"), solar-noon trigger, and multi-day polar-night copy are not used.

Rationale: Apple treats polar night at the data layer identically to regular night (UVI = 0). Adding polar-specific UI is unnecessary complexity. All v1 personas are non-polar; feature is deferred to post-ship if a polar-region persona is added.

**Status:** Design ready for implementation. No re-spec needed.
