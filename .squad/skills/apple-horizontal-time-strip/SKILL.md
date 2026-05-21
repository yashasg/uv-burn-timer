# Skill: Apple-Native Horizontal Time Strip (Selected + Current Dual State)

**Author:** Iris
**Extracted from:** WI-7 forecast picker spec (2026-05-21T02:40:00Z)
**Applicability:** Any iOS surface that displays a scrollable time series with per-item color encoding and dual selection states (selected vs. "now").

---

## Pattern Summary

A horizontally scrolling strip of fixed-size cells representing time intervals (hours, days). Each cell independently encodes: time label, icon, scalar value, and band/tier color. Two simultaneous highlight states: **selected** (user-chosen) and **current** (clock-time now). Degrades to a vertical list at AX4+ Dynamic Type.

---

## Cell Anatomy

```
┌─────────────┐
│   3 PM      │  ← .caption2, .secondaryLabel, centered
│  [icon 24pt]│  ← sun.max.fill (value > 0, band-tinted) or moon.fill (.tertiaryLabel, value = 0)
│     7       │  ← .headline .bold .primary (or "—" .tertiaryLabel if value = 0)
│ ████████    │  ← 4pt band color bar, full width (Color(.clear) if value = 0)
└─────────────┘
```

- Cell size: `60pt wide × 88pt tall` (adjust for your data density)
- `cornerRadius: 10pt`, `Color(.secondarySystemGroupedBackground)` background

---

## Dual-State Affordance

| State | Treatment |
|---|---|
| **Selected** (user tapped) | `Color.accentColor.opacity(0.15)` background + `2pt accentColor` rounded border |
| **Current** (clock "now", different from selected) | `circle.fill` 5pt dot in `Color(.label)` centered below cell, outside cell boundary |
| Neither | Default cell background, no decoration |

Do not conflate the two states. Selected is explicit user intent; current is passive system time. Separate affordances prevent confusion when user scrubs away from the current hour.

---

## Scrolling

```swift
ScrollView(.horizontal, showsIndicators: false) {
    LazyHStack(spacing: 8) {
        ForEach(hours) { hour in
            HourCell(hour: hour, isSelected: ..., isCurrent: ...)
                .id(hour.id)
        }
    }
    .scrollTargetLayout()
}
.scrollTargetBehavior(.viewAligned)
.onChange(of: selectedDayIndex) {
    withAnimation(reduceMotion ? .none : .easeInOut) {
        proxy.scrollTo(selectedHourID, anchor: .center)
    }
}
```

---

## Accessibility

- VoiceOver label per cell: `"3 PM, UV index 7, High"` (time + scalar + band name)
- For value = 0 cells: `"3 AM, no UV"` — drop scalar/band, keep time
- Current-hour dot is decorative; add `.accessibilityLabel("3 PM, current hour")` to the cell when `isCurrent == true`
- Selected cell: `.accessibilityAddTraits(.isSelected)`

---

## AX4+ Dynamic Type Break

Gate on `@Environment(\.dynamicTypeSize) >= .xxLarge`:

```swift
if dynamicTypeSize >= .xxLarge {
    // Vertical list: HStack { timeLabel; valueOrDash; bandChip }
} else {
    // Horizontal strip
}
```

Vertical rows: `44pt tall`, `HStack` with time label (.body), value (.headline), band chip (56×22pt pill).

---

## Zero-Value Treatment (Nighttime / No Data)

`moon.fill` icon in `Color(.tertiaryLabel)`, `"—"` scalar text in `Color(.tertiaryLabel)`, `Color(.systemFill)` cell background, no band bar. Single code path — no separate "nighttime mode". Any hour where the relevant scalar is 0 renders identically. This covers polar night transparently.

---

## Reuse Context

- **Forecast detail screen:** Same strip, different scalar (temperature, humidity).
- **UV history view:** Reverse-chronological, same dual-state not applicable (no "now"), but cell anatomy + AX4 break reuse directly.
- **Sleep/medication tracker (future):** Hourly strip with dose timing — same pattern.
