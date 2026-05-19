# Skill: Outdoor Readability for iOS (Sun-Tolerant Visual Hierarchy)

**Author:** Linka (UI/UX, Apple HIG & Accessibility)
**First captured:** 2026-05-19 — UV Burn Timer iOS design spec
**When to use:** When an iOS app's primary use context is **outdoors in direct sunlight** — UV/sun safety apps, hiking/trail apps, ski/snow apps, sailing/water-sports apps, cycling, gardening, outdoor work safety. Any app where the user is staring at the screen with the sun behind them.

---

## The core insight

Outdoor readability is **not** primarily about brightness. It is about:
1. **Contrast** (above WCAG AA, ideally AAA for the safety-critical surface)
2. **Redundant encoding** of severity (color + shape + symbol — never color alone)
3. **Trusting the system** to handle ambient luminance (Auto-Brightness + True Tone)
4. **Avoiding gotchas** (polarized sunglasses, OLED rainbow patterns, glove use)

If you optimize for "make it brighter" without addressing 1–4, you'll ship something that still fails in the field and burns battery doing it.

---

## Rule 1 — Push safety-critical contrast to AAA, not AA

Apple's HIG and iOS system colors target WCAG AA (4.5:1 for normal text, 3:1 for large text and UI). That's fine for most UI. **Safety-critical visual signals** — the value the user makes a safety decision on, the severity badge that tells them whether to be alarmed — should target **AAA (7:1)** for outdoor surfaces.

| Surface | Inside-bright-mall | Outdoor in direct sun |
|---|---|---|
| Body text | AA OK | AA OK |
| Hero number (the value) | AA OK | **AAA preferred** |
| Severity badge ("Short / Moderate / Long" tier) | AA OK | **AAA required** |
| Disabled/tertiary text | A OK | AA preferred |
| Decorative gradient | None | None |

**Gotcha:** iOS `systemOrange` against white is **3.0:1** — fails WCAG AA for normal text. If you're using systemOrange as a "Moderate" badge background with white text, you've shipped an inaccessible badge. Fix: black text on systemOrange in Light mode (≥ 4.5:1), or push the orange darker in your asset catalog.

---

## Rule 2 — Encode severity with at least two independent channels

Color-blind safe + sunglasses-tolerant + screen-glare-tolerant = use:
- **Color** (red/orange/yellow/green scale)
- **Shape** (filled circle / triangle / square / no-shape)
- **SF Symbol** (exclamationmark.triangle.fill, sun.max.fill, etc.)
- **Position** (left/center/right on a severity axis)

Two channels is the minimum; three is good. **Color alone is unacceptable** for safety-critical signaling.

iOS implementation:
```swift
HStack(spacing: 6) {
    Image(systemName: tier.symbol)            // SF Symbol
        .symbolVariant(.fill)
    Text(tier.label)                          // Text label
}
.padding(.horizontal, 12).padding(.vertical, 6)
.background(
    Capsule().fill(tier.backgroundColor)      // Color
)
.overlay(
    Capsule().strokeBorder(tier.borderColor, lineWidth: 1.5)  // Shape via border
)
.accessibilityLabel(tier.accessibilityLabel)  // Voice
```

If a user removes their color perception (sunglasses with strong tint, color-blindness, glare), the shape + symbol + text still tell them which tier they're in.

---

## Rule 3 — Trust the iOS system for luminance; do NOT build an "outdoor mode" toggle

A common temptation: add an in-app "Outdoor Mode" toggle that bumps brightness, increases font weight, or switches to a high-contrast palette. **Don't.** Reasons:

- **iOS Auto-Brightness + True Tone already does this**, more responsively than your toggle can. The system ambient light sensor reads the actual lux at the device; your toggle is the user manually reading the lux.
- **Discoverability is bad.** Outdoor mode toggles are routinely missed by the personas who most need them.
- **It teaches users to expect they'll need to fight the app's defaults outdoors** — which means your defaults are wrong.
- **It doubles your QA matrix.** Every screen, every state, every dynamic type, every color scheme × (outdoor / indoor) = 2× test work.

**Instead:** make your default palette and contrast outdoor-tolerant from day one. The "outdoor mode" is just "the app" — well-designed.

The one exception: if a user-controlled accessibility setting (Increase Contrast, Reduce Transparency, Larger Text) needs to swap an asset (e.g., HC variant of `SeverityShort`), that swap happens automatically via Asset Catalog appearance qualifiers. The system, not your UI, is the toggle.

---

## Rule 4 — The polarized-sunglasses OLED rainbow test

OLED screens (iPhone X and later) produce a rainbow/oil-slick pattern when viewed through linear-polarized sunglasses at certain rotations. The effect is benign but distracting; on a safety-critical surface it can wash out the severity badge.

**Pre-launch test (manual):**
1. Get a pair of linear-polarized sunglasses (most ski/fishing/driving polarized sunglasses are linear).
2. View the safety-critical surfaces (hero number, severity badge, primary CTAs) on an OLED iPhone (XR onward) outdoors.
3. Rotate the device through 360°.
4. If any state produces a rainbow pattern severe enough to obscure the value or the tier badge, push back on the design — consider:
   - Less-saturated background tints (the rainbow is most visible against deep saturated solids).
   - Matte or noise-textured background instead of flat fill.
   - Pushing the affected element to a less-glossy region of the screen.

This is a real-device test only; it cannot be simulated in Xcode Previews. Schedule it in the launch checklist.

---

## Rule 5 — Glove tolerance and wet-hand tolerance

- **Touch targets ≥ 44pt** is HIG minimum. For outdoor apps with the wet-hand / gloved-hand persona, **≥ 56pt** is the working target.
- **Primary action buttons in bottom safe-area inset (thumb zone).** Use `.safeAreaInset(edge: .bottom)` for the primary CTA. Top-of-screen primary CTAs require a hand-shift the wet-hand persona will reject.
- **No micro-gestures** (3-finger swipe, force-touch) for primary flows outdoors. Gloves and wet skin defeat them.

Specifically for capacitive touch with thin gloves: the row, not the inner control, is the tap target. Use `.contentShape(Rectangle())` on the whole row `HStack` so the row registers a tap even if the finger lands on margin pixels.

---

## Rule 6 — Defer the watch / Live Activity / Dynamic Island until v1.x

Outdoor personas often suggest "shouldn't this be on the watch?" The answer is usually "yes, eventually" but:

- **WatchKit + WeatherKit on watch** is a separate target with separate review and separate accessibility QA.
- **Live Activities / Dynamic Island** are technically "ambient" but App Store review treats them as notification-adjacent — if your launch plan bans push notifications (as ours does for v1), you should also defer Live Activities.

Ship v1 phone-only. Add watch/island in v1.x once the core surface is proven and the safety copy is settled.

---

## Applicability checklist — at least 4 of 6 must be true

Use this skill (vs. a generic mobile UI brief) when:

- [ ] **1. Primary use context is outdoors in direct sunlight** (not "could be used outdoors" — actually outdoors as the modal use case).
- [ ] **2. The product surfaces a safety-critical value or status** — burn time, UV index, avalanche risk, lightning distance, water depth, freeze warning.
- [ ] **3. The persona is wearing sunglasses, gloves, or has wet hands** in normal use.
- [ ] **4. Persona retention depends on glance-readability** — they're not going to sit and read; they're stealing a 2-second glance from another task.
- [ ] **5. The competing apps' App Store reviews complain about outdoor readability** (signal that the category under-serves this).
- [ ] **6. Color-blindness or vision-low accessibility cohort is meaningfully represented** in your persona list.

Four+ true → apply this skill. Less → standard HIG + WCAG AA is enough.

---

## Anti-patterns to avoid

- **"Outdoor Mode" toggle.** (Rule 3.) The system already does this.
- **Color-only severity.** (Rule 2.) Always pair with shape + symbol.
- **systemOrange + white text.** (Rule 1.) Fails AA. Use black-on-orange in Light mode.
- **Pure-black backgrounds in Dark mode for content surfaces.** OLED true-black is great for power but produces sharper rainbow on polarized sunglasses. Prefer `Color(.systemBackground)` which renders as a near-black, not true 0,0,0.
- **Tappable footer disclaimer.** Trains users to tap it to make it go away — and outdoors they'll tap accidentally with damp fingers. Footer is inert text.
- **Custom font for hero values.** Use SF Pro Rounded at heavy weight. It's optical-sized for outdoor glance-readability; custom fonts almost always lose to it.
- **Animated severity transitions outdoors.** When the user is in motion or in sun-glare, animations are noise. Use `withAnimation(.easeOut(duration: 0.25))` for the value change but no decorative motion on the badge.
- **Confirming auto-dimming overrides.** Don't force `.statusBarStyle(.lightContent)` or set custom brightness — let iOS handle it.

---

## Worked example (UV Burn Timer, 2026-05-19)

| Rule | How we applied it |
|---|---|
| 1 — AAA contrast | Moderate + Short tier badges both target ≥ 7:1; hero number on `Background` 21:1; secondary text on `Background` ≥ 7:1 |
| 2 — Redundant encoding | Tier = color (red/orange/green) + SF Symbol (exclamationmark.triangle.fill / sun.max.fill / leaf.fill) + text label ("Short" / "Moderate" / "Long") + position (red always on the alarming side) |
| 3 — No outdoor toggle | None. System Auto-Brightness + True Tone owns luminance. HC asset variants ship via Asset Catalog appearance qualifiers, triggered by Increase Contrast accessibility setting. |
| 4 — Polarized OLED test | Pre-launch checklist (K7 in design spec); Kwame to perform on iPhone 14/15/16. |
| 5 — Glove/wet-hand | Fitzpatrick picker rows ≥ 56pt; SPF chips ≥ 52pt; primary location action button in `.safeAreaInset(.bottom)`; row-level `.contentShape(Rectangle())`. |
| 6 — Defer watch/Live Activity | v1.1 deferral noted in Kwame handoff. v1 ships phone-only. |

All six applied. Outdoor-readable by default, no in-app mode toggle, accessibility cohort served via Asset Catalog HC variants.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
