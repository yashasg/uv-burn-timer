# Iris — Forecast Card Redesign v3: UX Spec

**Author:** Iris (UI/UX Designer)
**Date:** 2026-05-21T01:34:16Z
**Work item:** WI-7 — 10-day UV Forecast Feature
**Status:** Design spec — ready for Kwame implementation + Wheeler ratification on polar science

---

## §1. Loading-State Contract — Ratification of Gi's §6

**Verdict: RATIFY WITH TARGETED MODIFICATIONS**

Gi's four-state machine (`.idle → .loading → .loaded → .failed`) is sound and maps cleanly to iOS HIG's pattern for asynchronous content arrival. I ratify the state definitions and synchronous `.idle → .loading` transition. The modifications below are purely visual-treatment additions — they do not alter the state machine's structure or trigger logic.

---

### 1.1 State: `.idle`

No additional UX treatment needed. Per Gi §6 contract: chip hidden or disabled, picker inaccessible. In practice `.idle` is transient (synchronous transition to `.loading`) — users will never perceive this state at normal CPU speeds. **No visual spec required.**

---

### 1.2 State: `.loading`

**Skeleton rows — 10-day card**

- **Row count:** 10 skeleton rows (matching eventual loaded row count — prevents layout shift on load completion)
- **Row dimensions:**
  - Height: `52pt` (matches loaded row with `TierBadge` + date label)
  - Full card width minus `16pt` horizontal insets (card standard padding)
- **Skeleton element anatomy per row:**
  - Day label placeholder: `88pt × 14pt` rounded rect (`cornerRadius: 4pt`), left-aligned
  - Badge placeholder: `36pt × 20pt` rounded rect (`cornerRadius: 10pt`), right-aligned — mimics `TierBadge` pill shape
  - Numeric UVI placeholder (rows 1–5 only): `24pt × 14pt` rounded rect (`cornerRadius: 4pt`), between day label and badge — rows 6–10 omit this (consistent with TierBadge-only locked spec for those rows)
- **Inter-row spacing:** `8pt` (matches loaded card)
- **Shimmer:** YES — use a standard left-to-right gradient shimmer, `.ultraThinMaterial` → `.regularMaterial` color sweep, 1.5s looping animation
  - Under `accessibilityReduceMotion`: **static fill only**, no moving gradient. Use `Color(.systemFill)` for the placeholder blocks.
- **No card header skeleton** — the section title "10-Day Forecast" renders static at all states. Headers are not async content.

**Skeleton strip — hourly "Today" card**

- **Cell count:** 6 visible skeleton cells (horizontal scroll strip — show first 6, rest scroll-revealed)
- **Cell dimensions:** `60pt wide × 88pt tall` (matching loaded hourly cell)
- **Skeleton element anatomy per cell:**
  - Time label: `44pt × 12pt` rounded rect at top, centered
  - SF symbol placeholder: `28pt × 28pt` rounded rect, centered mid-cell
  - UVI integer placeholder: `20pt × 14pt` centered
  - Badge placeholder: `36pt × 18pt` pill at bottom, centered
- **Shimmer:** same as day card — respects `accessibilityReduceMotion`

**"View UV Forecast" chip — `.loading` state**

- **Label:** `"Forecast loading…"` (Gi's proposed text — ratified)
- **Color:** `Color(.systemGray)` fill, `Color(.systemGray2)` label — system semantic colors, not custom
- **`isEnabled`:** `false` — SwiftUI's disabled modifier. This automatically:
  - Reduces opacity to ~60% (system default)
  - Removes tap gesture recognition
  - Reports `accessibilityTraits: .notEnabled` to VoiceOver
- **Accessibility label:** `"View UV Forecast, loading"` — VoiceOver reads the full label + state together. Do NOT rely on the chip text alone; add an explicit `.accessibilityLabel("View UV Forecast, loading")` when in `.loading` state so users know WHY it's disabled.
- **No spinner icon inside the chip** — HIG pattern for disabled buttons is opacity reduction; an inline spinner implies the button itself is loading rather than the underlying data. Keep it text-only. The skeleton rows below are the loading signal.

**Picker accessibility in `.loading`**

- The "Plan for another time" chip that opens the picker sheet must also be disabled. Same treatment: `Color(.systemGray)`, `.accessibilityLabel("Plan for another time, forecast loading")`, `.isEnabled(false)`.

---

### 1.3 State: `.loaded`

No change from existing locked spec. Full render; chip enabled; picker accessible. Standard chip appearance: `Color(.tintColor)` (resolved to system blue or app tint), `accessibilityLabel("View UV Forecast")`.

---

### 1.4 State: `.failed`

**Cards — error state**

- Replace skeleton rows (or empty card area) with a **centered error block** inside the card boundary:
  - SF Symbol: `exclamationmark.triangle` (24pt, `.secondary` rendering mode)
  - Primary text: `"Unable to load forecast"` — `.subheadline` `.primary`
  - Secondary text: `"Check your internet connection."` — `.footnote` `.secondary`
  - **Retry button:** text-only `"Try again"` tappable region, `.callout .tint` color, minimum 44×44pt tap target (pad with `.contentShape(Rectangle())` if needed)
- Same layout on both hourly card and day card

**"View UV Forecast" chip — `.failed` state**

- **Enabled** per Gi §6 — chip opens the sheet which shows the error state with retry
- **Label:** `"View UV Forecast"` (no change — the sheet itself surfaces the error)
- **No special chip appearance** in `.failed` — chip looks normal; error is inside the sheet. This avoids a confusing "the button looks broken" mental model.

**Picker — `.failed`**

- "Plan for another time" chip: **enabled** — opens picker sheet
- Inside picker sheet: `"Forecast unavailable"` label where the result would normally appear, Done button **disabled** (`isEnabled(false)`), Retry button visible
- `.accessibilityLabel` on Done: `"Done, unavailable — forecast data required"`

---

### 1.5 HIG/Apple Weather analogues

Apple Weather's loading treatment (iOS 16/17/18) uses skeleton shimmer placeholders for both the hourly and the 10-day cards before data arrives. The shimmer direction (left→right) and `ultraThinMaterial` palette are Apple Weather's own pattern. My spec follows this directly.

HIG reference: *Loading States* — always prefer content-shaped placeholders (skeleton) over spinners alone when the ultimate layout is predictable (it is here — 10 rows, fixed anatomy).

---

## §2. Progressive Disclosure — Days 8–10 Reveal

### 2.1 Default collapsed state (days 1–7 visible)

The 10-day card renders days 1–7 as standard `LazyVStack` rows. Day 8 is not rendered. A **reveal affordance** sits immediately below row 7 — it IS part of the card, not below the card.

**Reveal affordance — visual treatment (collapsed state):**

- A full-width row (matching the `16pt` inset of the card) reading:
  - SF Symbol: `chevron.down.circle.fill` at `20pt`, `Color(.secondaryLabel)` rendering
  - Label text: `"3 more days"` — `.subheadline` `.secondary`
  - Trailing hint: implicit (the chevron's direction communicates "expand below")
  - Background: `Color(.clear)` — the row does not have its own card background; it sits inside the existing card
- Minimum tap target: `44pt tall` (enforced with `.frame(minHeight: 44)` + `.contentShape(Rectangle())`)
- No badge, no UVI data shown in collapsed affordance row

**Rationale for inline "3 more days" row over bottom-right button:**

A bottom-right corner button fails Dynamic Type — at AX4/AX5 the label clips against the card edge and the tap target becomes asymmetric. An inline full-width row scales with text size, maintains the 44pt minimum at all sizes, and is traversal-consistent with VoiceOver linear navigation.

---

### 2.2 Revealed state (days 1–10 visible)

- Days 8, 9, 10 animate into view below day 7
- The reveal affordance **transforms in place** (same row position): `chevron.down.circle.fill` → `chevron.up.circle.fill`, label changes to `"Show fewer days"`
- The three new rows use the locked day 6–10 treatment: `TierBadge` only, no numeric UVI integer

**Re-collapse:** YES — the user can re-collapse via the same affordance row. Rationale: accessibility (VoiceOver users should be able to dismiss redundant low-confidence rows once reviewed), and consistent toggle semantics (an expand/collapse control that only works in one direction is a non-standard interaction pattern per HIG).

---

### 2.3 Animation

| Condition | Animation |
|---|---|
| `accessibilityReduceMotion == false` | `.easeInOut(duration: 0.25)` for the three rows sliding in/out; affordance chevron rotation `.easeInOut(duration: 0.15)` |
| `accessibilityReduceMotion == true` | Instant swap — no animation. Rows appear/disappear immediately. Consistent with existing locked Reduce Motion behavior across the app. |

SwiftUI implementation: wrap rows 8–10 in `if isExpanded { ... }` block. Use `.transition(.opacity)` for the Reduce Motion path (or simply no `.animation` wrapper). Under normal motion: `.transition(.move(edge: .top).combined(with: .opacity))` applied to the group.

---

### 2.4 A11y

**VoiceOver label — affordance row:**

- Collapsed: `accessibilityLabel("Show 3 more forecast days")`, `accessibilityHint("Double-tap to reveal days 8 through 10.")`
- Expanded: `accessibilityLabel("Show fewer forecast days")`, `accessibilityHint("Double-tap to collapse days 8 through 10.")`
- `accessibilityTraits(.button)` on the affordance row

**VoiceOver focus after expand:**

After the user double-taps to expand, VoiceOver focus should move to the **first newly revealed row** (day 8). Use `accessibilityFocused` binding or `UIAccessibility.post(notification: .screenChanged, argument: day8RowAccessibilityElement)` in Kwame's implementation. This confirms to the user that content appeared.

**Dynamic Type behavior:**

- The affordance row label `"3 more days"` / `"Show fewer days"` scales with Dynamic Type. At AX5, the chevron symbol may stack above/beside the label — use `HStack(alignment: .center)` with `.minimumScaleFactor(0.8)` on the label. The row height should grow with content — `.fixedSize(horizontal: false, vertical: true)`.
- Do NOT clip the row at a fixed 44pt when Dynamic Type is large — allow the row to grow in height while maintaining 44pt minimum.

**A11y Rotor:**

No special rotor entry required for the affordance row — it is a standard button, discoverable via standard linear swipe navigation and Actions rotor. If Kwame implements a custom container, ensure the affordance row is not accidentally `accessibilityHidden`.

---

## §3. Dynamic-Data Adaptation Including Polar Regions

### 3.1 Core principle

**No layer of the UI may hardcode 24, 168, 240, or any other fixed count.** The rendering loop for both the hourly card and the day card iterates over whatever WeatherKit returned, passed through the `ForecastSnapshot` arrays as specified by Kwame's storage contract.

---

### 3.2 Hourly "Today" card rendering loop

Render over `today's hourly slice`: the subset of `ForecastSnapshot.hours` where `timestamp` falls within `[startOfToday, endOfToday]` in the user's local timezone.

- WeatherKit may return 23 hours (DST spring-forward), 24 hours (standard), or 25 hours (DST fall-back). Render whatever is in the array.
- If the returned slice is empty (edge case: WeatherKit returned no hourly data for today), render the "Unable to load forecast" error state rather than an empty horizontal strip.
- The dynamic loop handles DST transitions with zero special-casing — the timestamps are absolute (UTC) and the filter is timezone-aware. No `count == 24` assertion anywhere.

---

### 3.3 Polar night — collapsed single-row treatment

**Definition of "polar night" for UI purposes:**

Trigger the collapsed state when **every hourly entry for a given day has `uvIndex == 0.0`** AND `today.sunrise == nil` (WeatherKit's `DayWeather.sun.sunrise` is `nil` when the sun does not rise). The two conditions together avoid a false positive from a cloudy mid-latitude day where WeatherKit happens to return all-zero UVI (possible but rare).

- Primary trigger: `DayForecast.sunrise == nil`
- Confirmation: all hourly UVI values for that day are 0.0

**If WeatherKit does not provide per-day sunrise/sunset** (unlikely but defensive): fall back to the all-zero-UVI-only trigger with a consecutive-hour threshold of **18 or more consecutive hours with UVI = 0.0 within a single calendar day**. This is well above any reasonable night duration at temperate latitudes (max night at 60°N ≈ 18–19h at winter solstice) and catches true polar night without false-triggering on overcast days.

⚠️ **Wheeler ratification required** — I am proposing the `sunrise == nil` + all-zero confirmation as the trigger. Wheeler must confirm: (1) does WeatherKit reliably return `sunrise: nil` at polar coordinates in winter? (2) is there a photobiological nuance that makes even UVI=0 days worth explicit row rendering rather than collapsing? My design stance is collapse-on-true-polar-night; if Wheeler says "show the rows," I will adjust.

**Single-row collapsed rendering:**

Replace the full 24-hour strip with a single row:

```
[moon.stars.fill symbol, 16pt, Color(.secondaryLabel)]  "No UV today — sun does not rise"
                                                          .subheadline .secondary
```

- Proposed copy (⚠️ Wheeler to ratify exact wording, Plunder to confirm no legal risk):
  `"No UV today — sun does not rise at your latitude"`
- Row height: standard 44pt minimum; uses same row inset as normal hourly cells
- No `TierBadge` in polar night row (UVI = 0 → no tier to badge)
- VoiceOver label: `"No UV today. Sun does not rise at this latitude."` (sentence-case for natural speech)

**Single-day vs. multi-day polar-night stretch:**

The collapsed treatment applies **per day independently**. Each `DayForecast` that meets the polar-night trigger renders its own collapsed row. A 14-day polar night would show 7 collapsed rows (visible) + 3 more behind the reveal affordance — but days 8–10 still use `TierBadge` only (per locked spec), which is moot if they're also polar night (badge would not render). In practice, if the user is in polar night, the 10-day card rows 1–7 would each show the single-row polar-night treatment. This is correct — it tells the user clearly that there is no UV across the forecast window.

---

### 3.4 Polar day — normal rendering

If the sun never sets and UVI is non-zero across all 24 hours, render the full hourly strip normally. No special handling. The existing design holds — 24 cells of varying UVI with burn-time overlays per Wheeler's already-locked rule (burn-overlay on today/tomorrow only). There is no maximum-cell-count guard that would truncate this.

---

### 3.5 DST transition days

Render whatever WeatherKit returned. A 23-hour day renders 23 cells; a 25-hour day renders 25 cells. The `.horizontal` scroll strip accommodates any count. No special-case UI needed. The dynamic loop handles this transparently.

---

### 3.6 Edge case: WeatherKit returns fewer than 7 days at low latitudes

Per locked WI-7 spec: **clamp to last available WeatherKit `DayWeather` entry if fewer than 7 days returned.** Display the available rows (e.g., 5 rows) without the reveal affordance if the total count ≤ 7. The reveal affordance only appears when actual day-count > 7.

Implementation note for Kwame: `isRevealAvailable = forecastDays.count > 7`. If `forecastDays.count == 0`, show the error state, not an empty card.

---

## §4. Open Question — Chip Entry Point During Loading State

**Recommendation: AGREE with Gi — chip disabled at `.loading`.**

The argument to keep the chip always-tappable (with loading state shown inside the sheet) is architecturally cleaner but creates a jarring interaction: the user opens a sheet expecting forecast content and sees a skeleton for an indeterminate period before real data appears. This violates HIG's **progressive disclosure** principle — a sheet should open to meaningful content, not to a placeholder.

**The counter-argument** (always-tappable, loading inside sheet) has one real merit: if the user is in a hurry and wants to check if data is "almost there," they can't tap the chip at all under the disabled model. This is a minor convenience loss.

**My call:** Disabled chip during `.loading` wins for three reasons:
1. The `.loading` state is **fast** for most launches (synchronous foreground refresh, WeatherKit responds in <2s on most connections). The chip being briefly disabled is a flicker, not a wall.
2. Showing skeletons inside a `.sheet` is a second-order animation cost — the sheet itself animates in, then the skeletons shimmer, then the real data snaps in. That's three visual state changes within the sheet's lifespan, which is jarring at any Dynamic Type size.
3. The `accessibilityLabel("View UV Forecast, loading")` disabled chip informs VoiceOver users **why** it's disabled — which is better UX than landing in a sheet with an announcement of loading content.

**Exception:** If WeatherKit returns data from cache (snapshot is `.loaded` before `scenePhase == .active` refresh completes), the chip MUST be enabled immediately — do not wait for the refresh to complete if the cached snapshot is fresh. The disabled state is specifically for the case where no snapshot exists yet (cold-start / post-eviction).

---

## §5. Summary — Implementation Checklist for Kwame

All items below are spec-locked. Items marked ⚠️ are pending Wheeler ratification.

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | 10 skeleton rows at `.loading`, shimmer under normal motion, static fill under `accessibilityReduceMotion` | Kwame | Spec locked |
| 2 | 6 skeleton cells in hourly strip at `.loading` | Kwame | Spec locked |
| 3 | Chip disabled with `accessibilityLabel("View UV Forecast, loading")` at `.loading` | Kwame | Spec locked |
| 4 | Chip enabled (no visual change) at `.failed`, error rendered inside sheet | Kwame | Spec locked |
| 5 | Retry button (`44pt` tap target) in error state of both cards | Kwame | Spec locked |
| 6 | Inline "3 more days" reveal affordance at bottom of day card (inside card, below row 7) | Kwame | Spec locked |
| 7 | `chevron.down.circle.fill` / `chevron.up.circle.fill` toggle, `"3 more days"` / `"Show fewer days"` label | Kwame | Spec locked |
| 8 | Expand/collapse toggle (re-collapse supported) | Kwame | Spec locked |
| 9 | VoiceOver focus moves to day 8 row after expand | Kwame | Spec locked |
| 10 | `.easeInOut(0.25)` expand animation; instant swap under `accessibilityReduceMotion` | Kwame | Spec locked |
| 11 | Hourly card iterates over `today's hourly slice` dynamically (no count assertion) | Kwame | Spec locked |
| 12 | Polar night trigger: `sunrise == nil` + all-hourly-UVI == 0; fallback 18h consecutive zeros | Kwame | ⚠️ Wheeler ratify trigger |
| 13 | Polar night collapsed row: moon symbol + `"No UV today — sun does not rise at your latitude"` | Kwame | ⚠️ Wheeler/Plunder ratify copy |
| 14 | Polar day: render normally, no special case | Kwame | Spec locked |
| 15 | Reveal affordance hidden when `forecastDays.count <= 7` | Kwame | Spec locked |
| 16 | Chip disabled at `.loading` only when no valid cached snapshot; enabled immediately if cache is fresh | Kwame | Spec locked |

---

## §6. Pending Wheeler Ratification

Items that **must not be implemented** until Wheeler returns:

1. **Polar night trigger conditions** (§3.3 above) — does WeatherKit reliably return `sunrise: nil` at polar latitudes? Are there photobiological reasons to keep showing UVI=0 rows rather than collapsing? Is 18h consecutive zeros the right fallback threshold?

2. **Polar night copy** — proposed `"No UV today — sun does not rise at your latitude"`. Wheeler to confirm this is scientifically accurate (technically: the sun may be above the geometric horizon but below the photobiological UV-generation threshold at extreme grazing angles). If more precision is needed, Wheeler should supply the preferred phrasing. Plunder to confirm no legal issue with the copy.

3. **Polar-day cumulative-dose concern** — Yashas's directive noted Wheeler is examining whether sustained 24h polar-day UV exposure introduces cumulative-dose concerns our single-session model misses. If Wheeler raises a concern, the polar-day rendering may need a disclosure row or modified burn-window overlay. Currently: **spec assumes render-normally until Wheeler flags otherwise.**

Once Wheeler's ratification arrives, Kwame implements items 12 and 13. All other §5 items are unblocked.
