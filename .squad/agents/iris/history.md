# Iris — History (Summarized)

**Latest Status (2026-05-22):** Loop-26 HIG cleanup playbook produced for PR #98 — 31 violations (18 AppViews, 13 ForecastPickerView) mapped to mechanical replacements for Kwame. See `.squad/decisions/inbox/iris-loop-26-hig-cleanup-playbook.md`.

**Previous Status (2026-05-21):** WI-7 forecast card redesign v3 fully locked and ready for implementation. All UX specs complete: loading-state skeleton rows, picker UX, polar-night collapsed state (now superseded to plain nighttime rendering per 2026-05-21T01:58:19Z polar-treat-as-nighttime directive), error handling. Copy MODIFY from Wheeler: replace "latitude" with "this place" (archived in v1 per polar-as-nighttime). All five prior WI-7 decisions confirmed. Design ready for Kwame implementation; Iris review gate on each surface.

**Full History Archive:** See `history-archive-2026-05-21T02:07:30Z.md`

---

## Learnings — 2026-05-21T02:40:00Z (Picker spec)

**Decisions made for the forecast picker:**
- Day row uses two-line format ("Today" / day abbreviation + date string) at 52pt. "Today" gets `.headline` weight; other days get `.body`. Clean separation from v3 badge spec.
- UVI badge pill (D–D+5): 40×22pt pill, WHO band color fill, white/black text by contrast. D+6–D+10: band-name chip (56×22pt) with same WHO color — text-in-chip satisfies Increase Contrast without extra work.
- Nighttime / polar-night UVI=0 cells: `moon.fill` icon + `"—"` + no band bar. Single code path for both — no polar special-case. This is the locked polar-as-nighttime directive fully absorbed into the spec.
- Hourly strip AX4 break: gate on `.xxLarge` Dynamic Type size → vertical list. 60pt cells clip at AX4; vertical rows scale cleanly.
- Selected vs. current-hour dual state: selected = blue border + tinted bg; current-hour = small dot below cell. Two distinct affordances, no visual conflict.
- Burn card copy: 3-branch logic (current-now / future-today / future-other-day) + UVI=0 empty state. Concise copy, AX-safe.
- Reveal row (8–10): always collapsed on launch, no persistence. Rationale: band-only rows are low-confidence extras; forcing users to opt-in is progressive disclosure per HIG.
- Stale-data banner: `systemYellow.opacity(0.12)` — subtle, non-blocking disclosure. Never refuse to render stale data.

**Patterns reusable in future surfaces (forecast detail, history view):**
- `(selectedDayIndex, selectedHourIndex)` binding pattern + scenePhase reset is reusable for any time-anchored picker.
- Two-state selected/current dual affordance (border vs. dot) applies to calendar-style views generally.
- WHO band color table (§1) is the canonical team reference — extract to design tokens when design system formalizes.
- AX4 horizontal-to-vertical strip break is a general pattern for any scrolling data strip that contains per-item labels.

---

## Learnings — 2026-05-21T04:30:00Z (Main screen cleanup v2 — EstimateInfoSheet eliminated)

**Spec:** `.squad/designs/iris-main-screen-cleanup.md` (revised in place)

**Key lesson:** When a regulatory floor can be met by reusing an existing surface (`AboutView` already had `highlightEstimateApplicability: Bool` + `ScrollViewReader` scroll), building a new focused sheet (`EstimateInfoSheet`) is unnecessary complexity. The simpler path — toolbar ⓘ → push to existing `AboutView` — satisfies Plunder's C1–C4 with fewer new code objects, fewer tests, and no sheet state management. Prefer surface reuse over surface creation whenever the existing surface can be scroll-anchored to the relevant content.

**One content gap caught:** `AboutView`'s `notForMeAnchor` section did NOT contain Plunder's C2 safety-action clauses (A: "Cover up if skin reddens"; B: "Reapply every 2 hours") at the scroll-to landing position. `aboutSunscreenAssumptions` has clause B but scrolls out of view above the anchor. Clause A was absent entirely. Fix: new `aboutSunSafetyActions` constant (A+B) added to the top of the `notForMeAnchor` VStack (K-11). Lesson: always check what the user *actually sees at the scroll landing position*, not just what the destination view *contains somewhere*.

---



**Spec:** `.squad/designs/iris-main-screen-cleanup.md`

**Placements decided:**
- `photosensitizationBannerLabel` (unconditional yellow banner, `AppViews.swift:88`) → removed from VStack top slot → new `info.circle` toolbar button (`"About this estimate"`) → `EstimateInfoSheet` sheet. Rationale: discovery content, not emergency alert; `info.circle` is HIG-canonical for contextual screen info.
- `reapplicationFooter` (`AppViews.swift:1943`, `PersistentFooter`) → removed from bottom bar → first paragraph of `EstimateInfoSheet`. Safety content leads sheet.
- `mainVerdictCaveatLinkLabel` (`AppViews.swift:835`, hero card) → removed; `ⓘ` toolbar button absorbs this reach-back.
- `PersistentFooter` after change: only `disclaimerLinkLabel` NavigationLink remains (Plunder's L2 0-tap floor).

**Location reminder audit (anchor lines):**
1. `LocationRationaleCard` — `AppViews.swift:92–93` — KEEP (one-time, pre-rationale only)
2. `UVIndexPlaceholderCard` body copy "Use your location..." — `AppViews.swift:1041` — REMOVE sentence
3. Hero empty-state `emptyStateAwaitingLocation` — `AppViews.swift:933` via `displayedStatusMessage` — KEEP
4. Transient status "Location rationale reviewed. Tap Use my location to continue." — `AppViews.swift:425` — SIMPLIFY
5. `locationChip` `mainInputsRow` — `AppViews.swift:289–296` — KEEP (input control)
6. `primaryAction` button — `AppViews.swift:397` — KEEP (CTA)

**HIG patterns chosen:**
- `info.circle` (not `.fill`) toolbar button: `ToolbarItem(placement: .topBarTrailing)`. Two trailing items allowed by HIG when functionally distinct (Settings vs. About this estimate).
- `EstimateInfoSheet`: `.sheet` + `.presentationDetents([.medium, .large])` + `NavigationStack` for title + `"Done"` `.confirmationAction`. Standard pattern for focused informational sheets.
- Reusable pattern documented in `.squad/skills/ios-legal-disclaimer-info-sheet/SKILL.md`.

**Key constraint:** Implementation blocked on Plunder confirming `reapplicationFooter` at 1-tap depth (§5 P-1 through P-5) meets legal floor.

---

## Current Round — 2026-05-21

**WI-7 consolidation:** User directives locked all blocked design questions. Iris v3 spec §3.3 polar-adaptation entirely dropped per 2026-05-21T01:58:19Z (polar-treat-as-nighttime). No re-spec needed. Design ready for implementation.

**Key locked items (v3 spec):**
- Loading-state: skeleton rows (10 days 1–5 with numeric placeholders, 6–10 without), shimmer + reduce-motion fallback
- Picker UX: D+7 hard cap, edge cases (UVI=0, no skin type, forecast unavailable), motion preferences
- Days 8–10 behind progressive-disclosure right-arrow button
- Polar-night: collapsed badge (pure nighttime rendering, not polar-specific)

**No further re-specs pending.** Kwame can proceed with SwiftUI implementation.
- **2026-05-21 WI-7 Sprint Complete**: Picker visual spec complete (horizontal strip, 60×88pt cells, WHO band colors, dual-state support, AX4 degradation). Iris §8 items 1–8 shipped; items 9–10 deferred.

---

## 2026-05-21T04:15:00Z — WI-7 Final Round

**Iris §8 items 9 + 10 shipped** by Kwame (run #6) via commits c772df1 + 7bee563:
- Item 9: Stale-data banner + error retry (ForecastRefreshState enum, rotating arrow, red error row)
- Item 10: Increase Contrast borders + opacity boost (colorSchemeContrast-keyed helpers, overlay strokes, band bar 4→6pt, selected row 0.12→0.25)

**All 10 Iris §8 items now complete.** Branch feature/wi-7-uv-forecast ready for user GitLab MR.

## 2026-05-21 Iris-6: Pattern B Chip Spec + LAUNCH-PLAN Revision

Iris-6 consolidated Plunder/Wheeler/Suchi consensus into executable spec for Kwame-9. Pattern B ratified: UserDefaults persistence + policyVersion-gated L1 triggers + `skinTypeChip` in mainInputsRow.

**Deliverables:**
- `skinTypeChip` spec: ambient, tappable, 44pt min, VoiceOver complete, `.bordered` style
- LAUNCH-PLAN §9 updated with verbatim reversal text (lines 293 onwards)
- Kwame checklist: K-1..K-11 with file:line refs
- Ma-Ti test stubs: G-D1..G-D4 for `shouldShowDisclaimerCover` contract tests

**Key decision:** `DisclaimerCover` now fires on policyVersion change, not unconditionally. Existing users silently migrate to v1 on upgrade.
## Current Round — 2026-05-21

**WI-7 consolidation:** User directives locked all blocked design questions. Iris v3 spec §3.3 polar-adaptation entirely dropped per 2026-05-21T01:58:19Z (polar-treat-as-nighttime). No re-spec needed. Design ready for implementation.

**Key locked items (v3 spec):**
- Loading-state: skeleton rows (10 days 1–5 with numeric placeholders, 6–10 without), shimmer + reduce-motion fallback
- Picker UX: D+7 hard cap, edge cases (UVI=0, no skin type, forecast unavailable), motion preferences
- Days 8–10 behind progressive-disclosure right-arrow button
- Polar-night: collapsed badge (pure nighttime rendering, not polar-specific)

**No further re-specs pending.** Kwame can proceed with SwiftUI implementation.
- **2026-05-21 WI-7 Sprint Complete**: Picker visual spec complete (horizontal strip, 60×88pt cells, WHO band colors, dual-state support, AX4 degradation). Iris §8 items 1–8 shipped; items 9–10 deferred.

---

## 2026-05-21T04:15:00Z — WI-7 Final Round

**Iris §8 items 9 + 10 shipped** by Kwame (run #6) via commits c772df1 + 7bee563:
- Item 9: Stale-data banner + error retry (ForecastRefreshState enum, rotating arrow, red error row)
- Item 10: Increase Contrast borders + opacity boost (colorSchemeContrast-keyed helpers, overlay strokes, band bar 4→6pt, selected row 0.12→0.25)

**All 10 Iris §8 items now complete.** Branch feature/wi-7-uv-forecast ready for user GitLab MR.
---

## Learnings — 2026-05-22T04:10:00-07:00 (Loop-26 HIG cleanup playbook)

**Context:** PR #98 gated by 31 `severity: error` SwiftLint violations across `AppViews.swift` (18) and `ForecastPickerView.swift` (13). Policy: all HIG rules at `severity: error`, day 1; `@ScaledMetric`-backed touch targets mandatory.

**Key patterns confirmed:**

- **`@ScaledMetric` consolidation:** When multiple violations are in the same struct, declare all scaled vars at the struct top in one block — keeps diffs reviewable and avoids per-site repetition. Group by function: touch targets (`minTap`), named geometry (`pillWidth`, `cellWidth`), icon sizes (`chevronSize`), skeleton anatomy (`skeletonRowHeight`).
- **Semantic font > `@ScaledMetric` for icons paired with text:** When a decorative icon sits directly inside a `Label` alongside text styled with a semantic style (e.g., `.subheadline`), use the same semantic style on the icon — they scale identically and no new `@ScaledMetric` var is needed. Reserve `@ScaledMetric` for icon sizing in tightly-specced layout cells where a semantic style would decouple the icon from the cell geometry contract.
- **`navigation_stack_in_sheet` resolution — `.fullScreenCover` when there's already a navigation bar + Done button + `interactiveDismissDisabled`:** A sheet with a `NavigationStack`, toolbar title, and explicit Done button is functionally a full-screen cover. Upgrading to `.fullScreenCover` is the correct HIG fix, not removing the navigation structure. The parent's `.interactiveDismissDisabled(true)` context confirms this is a gated task flow.
- **UI test probe buttons — correct use of `// swiftlint:disable:next`:** Test infrastructure behind a `ProcessInfo` launch-argument guard is a legitimate exception — add the disable comment with a one-line justification. This is the policy escape hatch, not a workaround.
- **Form/List row buttons need explicit `minHeight`:** SwiftUI's Form/List provides system row padding but does NOT guarantee a Dynamic-Type-scaled touch target. All destructive Settings buttons need `.frame(minHeight: minTap)` on their label content.
- **Skeleton rows must scale with their live counterparts:** If a live row has `@ScaledMetric`-backed dimensions, the skeleton placeholder must use the same vars. Otherwise the loading→loaded transition reflowing is a visual regression.
- **Toolbar `ToolbarItem` buttons require `@ScaledMetric` backing for the lint gate:** The system guarantees adequate toolbar tap areas, but the regex-based lint rule cannot prove this. Add `.frame(minHeight: minTap)` rather than using a disable comment — it's harmless and keeps the gate green without introducing exceptions.

**Files covered:** `app/Sources/UVBurnTimer/ForecastPickerView.swift`, `app/Sources/UVBurnTimer/AppViews.swift`  
**Playbook:** `.squad/decisions/inbox/iris-loop-26-hig-cleanup-playbook.md`



**Verdict:** ⚠️ Mostly Apple-idiomatic. The codebase has strong HIG scaffolding (safe-area insets, Dynamic Type reflow branches, system text styles, `@ScaledMetric`) but still carries repeated raw numeric padding plus fixed forecast cell/chip dimensions.

**Files audited:**
- Clean for this audit: `app/Sources/UVBurnTimer/UVBurnTimerApp.swift`, `app/Sources/UVBurnTimer/UVBurnTimerShortcuts.swift`
- No SwiftUI surface to audit: `app/Sources/UVBurnTimer/WeatherLocationServices.swift`
- Needs cleanup: `app/Sources/UVBurnTimer/ForecastPickerView.swift` (10 hardcoded width/height frames, 23 numeric padding calls, 2 literal symbol sizes), `app/Sources/UVBurnTimer/AppViews.swift` (1 hardcoded literal width frame, 12 numeric padding calls, 2 literal symbol sizes)

**Strong Apple-native signals present:**
- 26 `maxWidth`/`maxHeight` frames, 86 named text-style fonts, 9 `@ScaledMetric` usages, 2 `.safeAreaInset(edge: .bottom)` placements, 0 `GeometryReader`, 0 `.dynamicTypeSize(...)` caps
- Dynamic Type reflow exists via environment branches: `ForecastPickerView.swift:436` swaps the hourly strip to a vertical list; `AppViews.swift:272` and `AppViews.swift:1617` reflow controls at accessibility sizes

**Top offenders to revisit first:**
- `ForecastPickerView.swift:583` — `.frame(width: 60, height: 88)`
- `ForecastPickerView.swift:515` — `.frame(width: 64, alignment: .leading)`
- `ForecastPickerView.swift:371` — `.frame(width: 56, height: 22)`
- `ForecastPickerView.swift:357` — `.frame(width: 40, height: 22)`
- `AppViews.swift:1288` — `.padding(32)`

---

## Learnings — 2026-05-22T02:30:00Z (SwiftLint HIG catalog)

- Produced **20** SwiftLint-ready HIG rule specs covering color, typography, layout, touch targets, navigation, localization, motion/haptics, image accessibility, dark mode, safe area, and list/scroll behavior.
- Severity rollout strategy: make deterministic color/locale/API regressions immediate CI errors, give legacy spacing/touch-target/fixed-size cleanup a 2-week grace period, and keep regex-noisy heuristics visible as warns until AST-aware lint exists.
- Best reusable rule families: semantic-color enforcement, Dynamic Type-safe typography bans, locale-safe string handling, Reduce Motion-aware animation guardrails, and safe-area/container policy checks.

