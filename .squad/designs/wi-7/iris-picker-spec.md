# Iris — Forecast Picker Spec
**Author:** Iris (UI/UX Designer)
**Date:** 2026-05-21T02:40:00Z
**Work item:** WI-7 — 10-day UV Forecast Picker
**Status:** Spec ready for Kwame implementation

Baseline: v3 spec locked. §3.3 polar-adaptation DROPPED — polar night = 24 cells of UVI=0 = standard nighttime rendering. No re-spec needed on polar.

---

## §1 — Day Row Layout (52pt tall)

**Date label format:**
- Current day: primary label `"Today"` in `.headline` weight; secondary `"May 21"` in `.caption` `.secondary` — right below, two-line layout.
- Other days: primary `"Wed"` in `.body`; secondary `"May 21"` in `.caption` `.secondary`.
- Two-line layout fits cleanly in 52pt (standard iOS cell height). Row height grows with Dynamic Type via `.fixedSize(horizontal: false, vertical: true)` — never clip.

**VoiceOver AX label:**
- Today: `"Today, May 21"` — include date so users know exact date after midnight.
- Other days: `"Wednesday, May 21"` — full day name + full date, no abbreviation.

**UVI: Days D through D+5 (numeric badge):**
- Pill-shaped badge: `40pt wide × 22pt tall`, `cornerRadius: 11pt`.
- Fill: WHO band semantic color (see band-color table below). Text: UVI integer, `.headline` `.bold`, `Color(.white)` on dark bands / `Color(.black)` on Low (green).
- Right-aligned in row. No secondary shape — just the pill.
- VoiceOver label: `"UV index 7, High"` (integer + band name).

**WHO band color table (semantic, not hex):**
| Band | Name | Fill |
|---|---|---|
| 0–2 | Low | `Color(.systemGreen)` |
| 3–5 | Moderate | `Color(.systemYellow)` |
| 6–7 | High | `Color(.systemOrange)` |
| 8–10 | Very High | `Color(.systemRed)` |
| 11+ | Extreme | `Color(.systemPurple)` |

**UVI: Days D+6 through D+10 (band chip, no numeric):**
- Pill chip: `56pt wide × 22pt tall`, `cornerRadius: 11pt`. Fill: WHO band color. Text: band name (`"High"`), `.caption` `.bold`, same contrast rule as above.
- Right-aligned. No numeric scalar (locked by Plunder/Wheeler).
- VoiceOver label: `"High UV"` — band name + "UV" suffix so context is clear.

**Selected state:**
- Full-row background: `Color.accentColor.opacity(0.12)`. No border.
- Day label text: `.headline` weight (vs `.body` unselected). Date label unchanged.
- Light/dark: `Color.accentColor` resolves correctly in both modes — no overrides needed.
- `accessibilityAddTraits(.isSelected)` on the row element.

**Tap target:** Full row is the hit target. Apply `.contentShape(Rectangle())` to the row HStack. 52pt tall ≥ HIG 44pt minimum — satisfied.

**AX5 layout:** Row height expands with Dynamic Type (no fixed cap). Badge pill stays right-aligned at fixed 40pt/56pt width. Day label wraps to two lines if needed. Nothing collapses — row grows. Set `alignment: .center` on the HStack so badge stays vertically centered next to the (potentially taller) date block.

---

## §2 — Hourly Strip Layout (60×88pt cells)

**Cell anatomy (top → bottom):**
1. Hour label: `"3 PM"` / `"12 AM"` — `.caption2`, `Color(.secondaryLabel)`, centered. Top 16pt.
2. Icon (24pt, centered): `sun.max.fill` tinted to WHO band color when UVI > 0. `moon.fill` in `Color(.tertiaryLabel)` when UVI = 0 (nighttime / polar night).
3. UVI integer: `.headline` `.bold`, `Color(.primary)` when UVI > 0; `"—"` in `Color(.tertiaryLabel)` when UVI = 0.
4. Band color bar: 4pt-tall rounded rect at cell bottom, full cell width, filled with WHO band color. `Color(.clear)` when UVI = 0.

Cell background: `Color(.secondarySystemGroupedBackground)`, `cornerRadius: 10pt`.

**UVI = 0 treatment (nighttime / polar night — same path):** `moon.fill` icon, `"—"` text, no band bar, slightly dimmer cell background `Color(.systemFill)`. This is the polar-as-nighttime locked behavior — no special copy, no special state. Just a quiet cell.

**Selected hour treatment:**
- `Color.accentColor.opacity(0.15)` cell background + `2pt` rounded border `Color.accentColor`, `cornerRadius: 10pt`.

**Current hour treatment (Today, clock-time NOW, when different from selected):**
- Small filled dot (`circle.fill`, 5pt, `Color(.label)`) centered below the band bar, outside cell bottom edge.
- No ring/border — distinct from selected. Dot is subtle; VoiceOver label: `"3 PM, current hour"`.

**Scrolling:** `.scrollTargetBehavior(.viewAligned)` — snap-to-cell. Auto-scroll to selected hour on day change: `ScrollViewReader.scrollTo(selectedHourID, anchor: .center)`.

**AX5 break:** At AX4 (XXXLarge Dynamic Type), the horizontal scroll strip switches to a **vertical list** of `HStack` rows (`time — UVI integer — band chip`). Each row is 44pt tall. This prevents illegible truncated cells in the horizontal layout. Kwame: gate on `@Environment(\.dynamicTypeSize) >= .xxLarge` (maps to AX3+; tune if needed after testing at AX4).

---

## §3 — Reveal Interaction (Days 8–10)

**Copy (confirm v3):**
- Collapsed: `"3 more days"` — concise, scannable.
- Expanded: `"Show fewer days"` — mirrors the action, matches v3.

**Chevron:** `chevron.down.circle.fill` collapsed → `chevron.up.circle.fill` expanded. 20pt, `Color(.secondaryLabel)`. Rotation animation: `.easeInOut(duration: 0.15)`. Under Reduce Motion: instant symbol swap, no rotation.

**Row expand animation:** `.easeInOut(duration: 0.25)` for rows 8–10. Under Reduce Motion: instant appearance (`.transition(.identity)` — no opacity/move).

**VoiceOver:**
- Collapsed: `.accessibilityLabel("Show 3 more forecast days")`, `.accessibilityHint("Double-tap to reveal days 8 through 10.")`, `.accessibilityTraits(.button)`.
- Expanded: `.accessibilityLabel("Show fewer forecast days")`, `.accessibilityHint("Double-tap to collapse days 8 through 10.")`.
- After expand: post `UIAccessibility.screenChanged` with day 8 row element as argument — focus jumps to day 8.

**Persistence:** Always start collapsed on fresh app launch. Do NOT persist expanded state to disk. Rationale: band-only days (8–10) carry lower forecast confidence; collapsing by default reduces noise for the dominant use case (plan for this week). Users who want D+8–10 can expand.

---

## §4 — Default Selection State

**On open:** Current calendar day selected; current clock hour selected (rounded to nearest whole hour in the hourly array).

**If current hour is past midnight / app reopened next day:** Selection resets to current day + current hour on every `scenePhase → .active`. Do not persist day/hour selection across sessions — forecast data is time-relative and a stale selection from yesterday is meaningless.

**Wiring requirement for Kwame:**
- Picker exposes two bindings: `selectedDayIndex: Int` (index into `forecastDays`) and `selectedHourIndex: Int` (index into `forecastDays[selectedDayIndex].hours`).
- Burn timer card below consumes `forecastDays[selectedDayIndex].hours[selectedHourIndex]` directly — not a copy, a live binding.
- Initialize both indices in the view model using `Date.now` — find first `day.date` matching today, then first `hour.timestamp` ≥ `Date.now`.

---

## §5 — Integration with Burn Timer Card

**Copy variants:**
| Context | Burn card primary text |
|---|---|
| Current hour, today | `"23 min"` — no prefix. Feels live. |
| Future hour, today | `"Burn time at 6 PM: 23 min"` |
| Future day | `"Burn time on Wed at 6 PM: 23 min"` |
| UVI = 0 (any hour) | `"No UV at this hour"` — `.subheadline`, `Color(.secondaryLabel)`, `moon.fill` 16pt leading icon |

**"on Wed" format:** Use abbreviated day name (`E` date format token). Never spell out full day name in the card — too long at AX4+.

**UVI = 0 state:** Replace the timer entirely with the `"No UV at this hour"` row. Do not show `"0 min"` or an empty timer. The moon icon signals nighttime without further explanation.

**VoiceOver label for UVI = 0 card:** `"No UV at this hour. No burn risk."` — reassuring, not alarming.

---

## §6 — Empty/Error States

**Cold start (no snapshot):** v3 skeleton — 10 shimmer rows + 6 shimmer cells. Chip disabled. Confirmed.

**Stale data + refresh in flight:** Render stale data immediately (never blank). Show a slim `Color(.systemYellow).opacity(0.12)` banner below the card section header: `"Updating forecast…"` — `.caption`, `Color(.secondaryLabel)`. No spinner — the data is visible, this is just a disclosure. Banner auto-hides when refresh completes.

**Refresh failed (network error):** Stale data stays visible. Banner changes to: `exclamationmark.icloud` (16pt) `"Could not update"` + tappable `"Retry"` in `Color(.tintColor)`. Auto-dismiss: no — stays until user taps Retry or forecast refreshes on next `scenePhase` change.

**Coord >50km (user moved):** Treat as stale. Snapshot invalidated, skeleton while refresh in flight. If refresh succeeds: new data. If refresh fails: error state from above. Do not show a special "location changed" message — the user understands they moved.

---

## §7 — Accessibility & Dynamic Type

**VoiceOver tree order:** Card heading (`"UV Forecast"`) → day rows (today first) → reveal row (if count > 7) → hourly strip → burn timer card. Confirmed — matches reading order. Kwame: use `.accessibilitySortPriority` or ensure SwiftUI stacking order matches.

**AX level breaks:**
- AX1–AX3 (default through xLarge): standard layout — horizontal scroll strip.
- AX4–AX5 (XXXLarge and above): hourly strip → vertical list of `HStack` rows (time + UVI + band chip). Cells no longer scroll horizontally.

**Reduce Motion:**
- Reveal rows 8–10: instant appear/disappear.
- Hourly strip auto-scroll: `animated: false` in `ScrollViewReader.scrollTo`.
- Shimmer: static fill `Color(.systemFill)` — no moving gradient.
- Day row selection tap: instant background swap (no fade).

**Increase Contrast:**
- Badge pills (numeric + band): add `1pt` border `Color(.label)`.
- Band chip (D+6–D+10): add `1pt` border + ensure text label always visible (already required by spec — band name text in chip satisfies this).
- Selected row background opacity: 0.25 (up from 0.12).
- Band color bar in hourly cells: increase height to 6pt.

**Switch Control:** Tab order mirrors VoiceOver order (confirmed by layout stack order). No custom tab sequences needed.

---

## §8 — Hand-off Checklist for Kwame

Priority order (highest → lowest):

1. **Day row anatomy:** `.body` for unselected day, `.headline` for selected and for "Today" label. Badge pill `40×22pt`, `cornerRadius: 11pt`, WHO band fill. Full-row `ContentShape` for 44pt+ tap target.
2. **Selected day state:** `Color.accentColor.opacity(0.12)` full-row background. `.headline` weight on day text. Add `.accessibilityAddTraits(.isSelected)`.
3. **Hourly cell anatomy:** `sun.max.fill` (UVI > 0, band-tinted) or `moon.fill` (`Color(.tertiaryLabel)`, UVI = 0). 4pt band bar at bottom. Selected = `Color.accentColor.opacity(0.15)` + `2pt accentColor` border. Current-hour dot = `circle.fill` 5pt `Color(.label)` below cell.
4. **Horizontal scroll strip:** `.scrollTargetBehavior(.viewAligned)`, `ScrollViewReader.scrollTo(selectedHourID, anchor: .center)` on day selection change.
5. **Default selection init:** Find `forecastDays.first { Calendar.current.isDateInToday($0.date) }` → index. Find `hours.first { $0.timestamp >= Date.now }` → index. Reset on `scenePhase → .active`.
6. **Burn card copy wiring:** Branch on `(isToday, isCurrentHour, uvIndex == 0)`. Copy variants per §5 table. UVI = 0 replaces timer with `moon.fill` + `"No UV at this hour"`.
7. **Reveal row:** v3 spec confirmed — `chevron.down.circle.fill`/`.up`, `"3 more days"` / `"Show fewer days"`. Always collapsed on launch (no persistence). VoiceOver focus → day 8 on expand.
8. **AX4 hourly strip layout:** `@Environment(\.dynamicTypeSize) >= .xxLarge` → switch to vertical `List`-style layout. Each row: `HStack { hourLabel; uvIntegerOrDash; bandChip }`.
9. **Stale-data banner:** `Color(.systemYellow).opacity(0.12)` slim row below card header during refresh. Error variant: `exclamationmark.icloud` + `"Could not update"` + Retry button (44pt target).
10. **Increase Contrast:** `1pt Color(.label)` border on badge pills and band chips. Selected background opacity → 0.25. Band bar height → 6pt.
