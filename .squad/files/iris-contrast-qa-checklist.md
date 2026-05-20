# Iris — Contrast QA Checklist (manual launch-readiness gate)

- **Owner:** Iris (UI/UX Designer)
- **Reviewer:** Ma-Ti (Tester)
- **Type:** Manual accessibility QA gate (per WI-15, gaia-backlog-20260520T0430Z)
- **Cadence:** Run before every TestFlight build and before App Store submission
- **Related decisions:**
  - `.squad/decisions/inbox/iris-gauge-visibility.md` (gauge ring contrast)
  - `.squad/decisions/inbox/iris-gauge-target-ui.md` (severity colorset HC variants)
  - `.squad/files/iris-launch-readiness-checklist.md` (polarized-OLED gate, WI-16)

## Why this gate is manual, not automated

Severity colors (`SeverityShort/Moderate/Long`) and supporting surfaces
(yellow photosens banner, gauge ring track, SafetyStatusCard) use SwiftUI
opacity blending against a system-dynamic background (`Color.systemBackground`,
`Color.label`). The actual rendered contrast depends on:

1. The current `colorScheme` (`.light` vs `.dark`).
2. The current `colorSchemeContrast` (`.standard` vs `.increased`).
3. The blend of the color token's `opacity()` against the underlying
   surface, which itself can be `.thinMaterial`, `.regularMaterial`, or
   a system background — none of which expose a deterministic RGB value
   that a Swift unit test can read.

A unit test that parses `Assets.xcassets/Severity*.colorset/Contents.json`
can confirm that HC variants exist, but cannot verify the *rendered*
contrast a real user sees through a real display. WCAG conformance is
verified by direct measurement on device.

This checklist owns the *rendered* contrast gate for shipped UI
surfaces. Asset-token deletion is caught by the existing copy and
asset coverage in the audit test suite (`auditCopySurfaces` plus
the explicit `Color("Severity*")` look-ups in `AppViews.swift`); a
deleted asset becomes a render failure during the next checklist
pass and is flagged before TestFlight roll-out.

## Setup

- Device: physical iPhone (any model from iPhone 13 onward). Sample on
  both an OLED unit (iPhone 14 Pro / 15 Pro / 16 Pro / 17 Pro) and a
  Liquid Retina LCD unit if available. Simulator contrast measurement is
  unreliable because the simulator does not render through the device's
  True Tone, Auto-Brightness, or OLED gamma path.
- App build: TestFlight build of the candidate version, NOT a Debug
  build (the symbol shadows and material blurs differ).
- Measurement tool: any Apple-internal or third-party contrast checker
  that reports WCAG 2.1 ratios (Xcode Accessibility Inspector → Color
  Contrast Calculator, Apple Vision Accessibility audit, or a screen
  capture fed through `colour-contrast-analyser` desktop tool). Record
  the tool name and version in the sign-off line.

## Surfaces to measure (one row per `Surface × ColorScheme × ContrastMode`)

For each surface, sample with VoiceOver off, then with VoiceOver on, and
record the foreground vs blended-background contrast ratio. Pass
threshold is **≥ 4.5:1** in `.standard` and **≥ 7:1** in `.increased`
contrast mode. Failing rows must be filed as a follow-up WI before the
build can ship.

### Severity colorset tokens (hero card, TierBadge, BurnRiskGauge)

| Surface | Light · Std | Light · HC | Dark · Std | Dark · HC | Pass? | Notes |
|---|---|---|---|---|---|---|
| TierBadge Long (`SeverityLong`) text on capsule | __:1 | __:1 | __:1 | __:1 | ☐ | |
| TierBadge Moderate (`SeverityModerate`) text on capsule | __:1 | __:1 | __:1 | __:1 | ☐ | |
| TierBadge Short (`SeverityShort`) text on capsule | __:1 | __:1 | __:1 | __:1 | ☐ | |
| BurnRiskGauge progress arc (per-tier) vs ring track | __:1 | __:1 | __:1 | __:1 | ☐ | Tracks `Color.secondary.opacity(0.22)` (AppViews ~line 1553). |
| Hero number against card material | __:1 | __:1 | __:1 | __:1 | ☐ | `.contentTransition(.numericText())` |

### Banner + safety surfaces

| Surface | Light · Std | Light · HC | Dark · Std | Dark · HC | Pass? | Notes |
|---|---|---|---|---|---|---|
| Photosens banner text on yellow fill | __:1 | __:1 | __:1 | __:1 | ☐ | `Color.yellow.opacity(0.18/0.35)` + `Color.orange.opacity(0.55/0.85)` border |
| Photosens banner chevron + link text | __:1 | __:1 | __:1 | __:1 | ☐ | Inline NavigationLink to AboutView |
| SafetyStatusCard "Recalculate..." text on orange fill | __:1 | __:1 | __:1 | __:1 | ☐ | `Color.orange.opacity(0.14/0.28)` (AppViews ~line 829) |
| SafetyStatusCard `exclamationmark.shield.fill` icon vs fill | __:1 | __:1 | __:1 | __:1 | ☐ | |

### Footer + secondary controls

| Surface | Light · Std | Light · HC | Dark · Std | Dark · HC | Pass? | Notes |
|---|---|---|---|---|---|---|
| Persistent footer disclaimer link copy | __:1 | __:1 | __:1 | __:1 | ☐ | `Informational only. Not medical advice.` |
| Compact Location chip | __:1 | __:1 | __:1 | __:1 | ☐ | 44pt min hit target — `minHeight: 44` |
| Compact SPF chip | __:1 | __:1 | __:1 | __:1 | ☐ | Menu trigger, 44pt min |
| Weather attribution `Apple Weather` link | __:1 | __:1 | __:1 | __:1 | ☐ | Required to remain visible on every weather-derived surface |
| "I understand" prominent action on L1 cover | __:1 | __:1 | __:1 | __:1 | ☐ | `.buttonStyle(.borderedProminent)` |

## Procedure per row

1. Launch app to the surface in the row (use the `-uiTest*` launch
   arguments if needed to force a state like denied location or capped
   estimate).
2. With Settings → Accessibility → Display & Text Size → Increase
   Contrast OFF, capture a screenshot. Run the screenshot through the
   chosen contrast checker. Record the Standard ratio.
3. Toggle Increase Contrast ON. Capture again. Record the HC ratio.
4. Switch the system to the opposite appearance (Settings → Display &
   Brightness → Dark) and repeat steps 2–3.
5. If any cell is below the pass threshold, mark Pass = ☐ and add a row
   to `Notes` describing what was measured + recommend the asset/token
   change. File the follow-up WI before TestFlight roll-out.

## Sign-off

```
Build version: ____________
Build number:  ____________
Tested by:     ____________
Date (UTC):    ____________
Tool used:     ____________  (name + version)
Result:        ☐ All rows pass    ☐ Failing rows filed as WI(s) ____________
Signature:     ____________
```

### Automation status (WI-21)

This sign-off block **cannot be completed by an automated agent or by
CI**. The acceptance criteria explicitly require a physical iPhone
under controlled lighting plus a WCAG contrast-measurement tool (Xcode
Accessibility Inspector, Apple Vision audit, or `colour-contrast-analyser`
desktop). No simulator path, no CI runner, and no agentic loop has
access to a physical display + measurement instrument. Faking this
sign-off would violate the truthfulness contract that the rest of the
copy + ADR ledger upholds (see `D-2026-05-19-honest-privacy-copy`).

**Owner for the first signed pass:** Iris (UI/UX Designer) executes
the procedure; Ma-Ti countersigns the per-row ratios.

**Triggering event:** the first TestFlight build, then every TestFlight
build that touches any surface listed in this checklist (see the
`build.sh` SWIFT_TREAT_WARNINGS_AS_ERRORS gate output for the build
identity to pin in the sign-off block).

**Until the first signed pass exists,** `loop.md` §6 Goal 5 ("Code
tested and validated") is intentionally not green for the launch-readiness
gate — the automated portion (Swift Testing + XCUITest + warnings-as-
errors) is green per `./build.sh`, but the rendered-contrast portion
owned by this file remains open. The next build cycle whose owner can
execute the physical-device pass MUST fill in the sign-off block above
and commit the result; a blank block is treated as **fail** by Goal 5.

## Out of scope

- Programmatic WCAG ratio assertion (rendered measurement remains
  manual; the asset-deletion guardrail is the existing `Color("Severity*")`
  look-up coverage in the suite).
- Polarized-OLED outdoor readability — owned by
  `iris-launch-readiness-checklist.md` (WI-16).
- AppIcon contrast — App Store review covers this through the human
  reviewer pass.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
