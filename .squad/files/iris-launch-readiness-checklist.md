# Iris — Launch-Readiness Checklist (polarized-OLED outdoor readability)

- **Owner:** Iris (UI/UX Designer)
- **Executor:** Launch-readiness reviewer (any squad member with a
  physical iPhone)
- **Type:** Manual cross-cutting accessibility gate
  (per WI-16, `gaia-backlog-20260520T0430Z`)
- **Cadence:** Run before every TestFlight build that touches
  any UI surface listed below, and before App Store submission
- **Related decisions / artifacts:**
  - `.squad/files/iris-contrast-qa-checklist.md` — programmatic
    indoor contrast gate (WI-15).
  - `.squad/files/user-flow-onboarding-main-spec.md` LANE 3 callout
    #8 — names the polarized-OLED test as a required gate but
    deliberately leaves the procedure to this file.
  - `.squad/skills/outdoor-readability-ios/SKILL.md` — the broader
    skill brief on outdoor readability for the squad.

## Why this gate exists

UV Burn Timer is a *sunny-day* app. Every load-bearing surface — the
hero number, the tier badge colour, the photosens banner, the footer
disclaimer link, the Apple Weather attribution — has to remain
legible through polarized sunglasses outdoors on an OLED display.
OLED panels emit polarized light; rotating polarized sunglasses
across the display can extinguish the image entirely at certain
angles. Apple's True Tone + system Auto-Brightness mitigates this for
the system status bar and SF Symbols, but our custom severity colour
tokens and material blurs are not on that automatic path. Without
this gate we ship a sunny-day app that becomes unreadable on the
exact use case it was designed for.

## Setup

- **Device:** physical iPhone with an OLED display. Sample on
  iPhone 13 Pro and at least one model from iPhone 15 Pro / 16 Pro /
  17 Pro to cover the panel generations Apple is currently shipping.
  LCD-equipped iPhones (SE 3rd gen, base iPhone 13/14) are out of
  scope — they do not exhibit the polarization-extinction failure
  mode this gate exists to catch.
- **App build:** TestFlight build of the candidate version (NOT a
  Debug build — material blurs and font weights differ).
- **Polarizing filter:** the linear-polarized lens of any
  off-the-shelf polarized sunglasses (Maui Jim, Costa, Ray-Ban with
  the "polarized" label, etc.) OR a polarizing photography filter
  (B+W F-Pro CPL, Hoya PRO1 Digital, etc.). Verify the filter is
  *linear* polarized — circular polarizers extinguish OLED at
  different angles and are not what users typically wear outdoors.
- **Environment:** outdoors at midday under direct sun, or under a
  full-spectrum bench light at ≥ 50,000 lux if outdoor access is not
  available. Note the actual measurement environment in the
  sign-off.

## Surfaces to verify

For each surface, hold the polarizing filter in front of the display
and rotate it through a full 360° in 30° increments. The surface
**passes** if the listed glyphs remain legible (visible enough to be
read at a normal arm-length viewing distance) at every rotation.
Mark **fail** if the glyph becomes invisible or unreadable at any
rotation angle.

### Hero verdict region

| Surface | Glyphs that must remain legible | Pass? | Notes |
|---|---|---|---|
| Hero number (e.g. `47 min`, `~1 hr 20 min`, `Up to 2 hr`, `4+ hr`) | All digits + unit suffix | ☐ | Test with each tier seeded via `-uiTestStaleEstimate`, `-uiTestCappedEstimate` |
| Hero `Burn-time estimate` label above the number | Full label | ☐ | |
| TierBadge capsule (Long/Moderate/Short) text on coloured fill | Tier word + numeric ratio | ☐ | Severity HC variants must contribute to legibility, not detract |
| BurnRiskGauge progress arc relative to ring track | Arc must remain distinct from track at every rotation | ☐ | Test with three tier states |
| Hero `Meds + conditions can shorten this. Learn more` caveat inline link | Full sentence + link affordance | ☐ | |

### Photosens banner + safety surfaces

| Surface | Glyphs that must remain legible | Pass? | Notes |
|---|---|---|---|
| Photosens banner copy `Meds or photosensitive conditions? Learn more` | Full label + chevron | ☐ | Yellow fill must remain distinct from background |
| SafetyStatusCard `Estimate window elapsed. Recalculate.` copy | Full sentence + `exclamationmark.shield.fill` icon | ☐ | Seed via `-uiTestStaleEstimate` |
| L1 disclaimer cover `How accurate is this for you?` title | Full title + body + photosensitizer line + `see About` link + `I understand` action | ☐ | Cold launch |
| L1 photosensitizer warning line with orange `.semibold` styling | Full line + icon | ☐ | |

### Secondary surfaces

| Surface | Glyphs that must remain legible | Pass? | Notes |
|---|---|---|---|
| UV Index secondary card `UV Index 6.2` + `Source: Apple Weather` | Full digit + attribution lockup | ☐ | Attribution is contractually required to stay visible |
| Compact Location chip (`📍 Approx. 37.77, -122.42 ›` or `Location`) | Full chip label + glyph | ☐ | Chip renders `UVCoordinate.privacyDisplayText` (rounded coordinate), not a city name |
| Compact SPF chip (`SPF 30`, etc.) | Full chip label + glyph | ☐ | |
| Persistent footer `Informational only. Not medical advice.` | Full link copy | ☐ | Required to stay legible — disclaimer link |
| Apple Weather attribution lockup OR `Apple Weather` text fallback | Lockup or fallback text | ☐ | Either form is acceptable per attribution audit |
| Onboarding skin-type picker rows (Fitzpatrick I–VI) | Numerals, descriptors, selection check | ☐ | Each row's headline + behaviour cue |
| Settings sheet rows + section headers | All visible labels | ☐ | |

## Procedure per row

1. Launch the app and navigate to (or seed) the surface in the row.
   Use the `-uiTest*` launch arguments where helpful to deterministic
   states (`-uiTestStaleEstimate`, `-uiTestCappedEstimate`,
   `-uiTestWeatherUnavailable`, `-uiTestLocationDenied`).
2. Hold the polarizing filter parallel to the display.
3. Rotate the filter through 30°, 60°, 90°, 120°, 150°, 180°, 210°,
   240°, 270°, 300°, 330°. At each angle, verify all listed glyphs
   remain legible at a normal viewing distance.
4. Mark **Pass** ☑ only if every angle is legible. Any single failing
   angle → **Fail** ☐ + note the angle and which glyph was lost.
5. Any failing row must be filed as a new WI before TestFlight
   roll-out. Common fixes: increase opacity of the failing tint
   token's HC variant; add a darker stroke around the failing glyph;
   switch the surface to a `.regularMaterial` background instead of
   `.thinMaterial`.

## Sign-off

```
Build version:    ____________
Build number:     ____________
Tested by:        ____________
Date (UTC):       ____________
Device models:    ____________
Polarizing tool:  ____________  (filter brand + model, OR sunglasses brand)
Environment:      ____________  (outdoor midday sun, bench light @ N lux, etc.)
Result:           ☐ All rows pass    ☐ Failing rows filed as WI(s) ____________
Signature:        ____________
```

### Automation status (WI-21)

This sign-off block **cannot be completed by an automated agent or by
CI**. The acceptance criteria require a physical OLED iPhone outdoors
under direct sun (or a ≥ 50,000 lux bench light) plus a linear-polarized
filter rotated through a full 360°. The simulator cannot reproduce
polarization extinction, OLED panel emission, True Tone, or
Auto-Brightness behaviour. No CI runner has access to a physical
display or polarizing optics. Faking this sign-off would defeat the
purpose of the gate — UV Burn Timer is a sunny-day app and the
polarized-OLED extinction failure mode is the exact failure this
checklist exists to catch.

**Owner for the first signed pass:** Iris (UI/UX Designer) or any
squad member with a physical iPhone executes the procedure; Argos
countersigns the per-row polarization-tilt results (per WI-16
acceptance).

**Triggering event:** the first TestFlight build, then every
TestFlight build that touches any surface listed in this checklist.

**Until the first signed pass exists,** `loop.md` §6 Goal 5 ("Code
tested and validated") is intentionally not green for the
launch-readiness gate — the automated portion (Swift Testing +
XCUITest + warnings-as-errors) is green per `./build.sh`, but the
polarized-OLED outdoor-readability portion owned by this file
remains open. The next build cycle whose owner can execute the
physical-device pass MUST fill in the sign-off block above and
commit the result; a blank block is treated as **fail** by Goal 5.

## Out of scope

- Indoor / normal-ambient contrast — owned by
  `.squad/files/iris-contrast-qa-checklist.md` (WI-15). Run both
  checklists before TestFlight.
- AppIcon legibility under polarization — App Store review and
  the device home-screen icon catalog handle this.
- Circular polarized filters — out of scope because users almost
  exclusively wear linear-polarized lenses outdoors.

## Loop integration

Per WI-16, `loop.md` Section 6 ("Goals Checklist") should treat
"Code tested and validated" as **NOT** satisfied unless both this
checklist and `iris-contrast-qa-checklist.md` have a green sign-off
within the last build cycle. Add a one-line pointer in `loop.md`
referencing both files so future loops know to run them before
declaring launch-ready.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
