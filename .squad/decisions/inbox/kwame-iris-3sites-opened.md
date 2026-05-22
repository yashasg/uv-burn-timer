# Kwame — Iris 3-sites a11y fix opened (PR #120)

- **Work item:** `WI-loop30-4a-iris-3sites`
- **PR:** https://github.com/yashasg/uv-burn-timer/pull/120
- **Branch:** `squad/wi-loop30-4a-iris-3sites` (off `github/main`)
- **Status:** opened, CI in flight
- **CI run IDs:** push `26312959589`, PR `26313088707`
- **Datetime:** 2026-05-22T20:55:00Z

## Why

Iris's image-a11y fixture catalog (`iris-image-accessibility-fixtures.md`)
classifies three `app/Sources/` sites as POSITIVE under the upcoming
`image_systemname_missing_accessibility_label` AST rule. Each is a P5-shape
violation — bare `Image(systemName:)` adjacent to a `Text`/`Label` sibling —
which leaks the SF Symbol name through VoiceOver, violating WCAG SC 1.1.1.
This PR is the hard prerequisite for PR #119's revised landing (per Gaia's
adjudication in `gaia-pr119-adjudication.md`).

## Sites — before / after

### Site 1: `app/Sources/UVBurnTimer/AppViews.swift:1152` (TierBadge accessory glyph)

**Before:**
```swift
if differentiateWithoutColor, let accessorySymbolName {
    Image(systemName: accessorySymbolName)
}
```

**After:**
```swift
if differentiateWithoutColor, let accessorySymbolName {
    Image(systemName: accessorySymbolName)
        .accessibilityHidden(true)
}
```

**HIG rationale:** the sibling `Label(title, systemImage:)` already speaks the
tier name, and the parent `HStack` carries `.accessibilityElement(children:
.combine) + .accessibilityLabel("… burn-time tier…")`. The accessory is a
*visual* differentiation cue for users with colour-vision considerations
(`@Environment(\.accessibilityDifferentiateWithoutColor)` slot) — it must
not generate a redundant VoiceOver utterance. `.accessibilityHidden(true)`
is the canonical "decorative" marker.

---

### Site 2: `app/Sources/UVBurnTimer/ForecastPickerView.swift:209` (stale-banner spinner)

**Before:**
```swift
HStack(spacing: 6) {
    Image(systemName: "arrow.clockwise")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .rotationEffect(.degrees(isRotatingRefreshIcon ? 360 : 0))
        .animation(…)
        .onAppear { isRotatingRefreshIcon = true }
        .onDisappear { isRotatingRefreshIcon = false }
    Text("Updating forecast…")
        .font(.footnote)
        .foregroundStyle(.secondary)
    Spacer()
}
.frame(maxWidth: .infinity, minHeight: staleBannerMinHeight, alignment: .leading)
.padding(.horizontal, 16)
.background(Color(.systemYellow).opacity(0.12))
```

**After:** unchanged HStack body; **three new modifiers on the HStack tail:**
```swift
.background(Color(.systemYellow).opacity(0.12))
.accessibilityElement(children: .combine)
.accessibilityLabel("Updating forecast")
```

**HIG rationale:** the banner is a single status surface — VoiceOver should
read one cohesive announcement, not "Arrow, clockwise, image. Updating
forecast…". Iris fixture P5 §HIG-note clause (b) explicitly endorses
`.accessibilityElement(children: .combine) + .accessibilityLabel(…)` on the
parent for this exact pattern. Chose (b) over (a) (`Label`) because the
spinner needs `rotationEffect` + `onAppear/onDisappear` lifecycle hooks
that `Label`'s `icon:` builder fights with; chose (b) over (c)
(`.accessibilityHidden` on Image alone) because the parent label string
is shorter than the visible Text ("Updating forecast" vs "Updating
forecast…") — VoiceOver doesn't need the ellipsis.

---

### Site 3: `app/Sources/UVBurnTimer/ForecastPickerView.swift:230` (refresh-error banner)

**Before:**
```swift
HStack(spacing: 6) {
    Image(systemName: "exclamationmark.icloud")
        .font(.footnote)
        .foregroundStyle(.secondary)
    Text("Could not update")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .accessibilityLabel("Could not update forecast")
    Spacer()
    Button("Retry") { onRetry() }
        .font(.footnote)
        .foregroundStyle(.tint)
        .frame(minHeight: minTap)
}
.frame(maxWidth: .infinity, minHeight: staleBannerMinHeight, alignment: .leading)
.padding(.horizontal, 16)
.background(Color(.systemRed).opacity(0.08))
```

**After:** unchanged HStack body; **two new modifiers on the HStack tail:**
```swift
.background(Color(.systemRed).opacity(0.08))
.accessibilityElement(children: .combine)
.accessibilityLabel("Could not update forecast")
```

**HIG rationale:** identical shape to site 2. The pre-existing inner
`.accessibilityLabel("Could not update forecast")` on the Text now combines
into the parent label. The Retry `Button` is an interactive control and
`.combine` respects controls — it remains its own focusable element with
its own implicit label.

---

## Test approach

New file: `app/Tests/UVBurnTimerCoreTests/ImageSystemNameAccessibilityContractTests.swift`
— **three `@Test` cases**, one per site (`test_A11Y_1`, `test_A11Y_2`,
`test_A11Y_3`). Each test loads the relevant source file via a small
repo-root locator (`A11yContractSource.load`), slices around the
target `Image(systemName:)` expression, and asserts the expected
modifier(s) appear in the slice.

This is a **brittle source-scan contract** by Kwame's choice — explicitly
called out in the WI brief as the minimum acceptable TDD gate. A robust
view-tree probe (`UIHostingController` + accessibility-element traversal)
can land in a follow-up PR once Linka or Gaia greenlight the test pattern
for the broader fixture catalogue.

**Wired into `app/app.xcodeproj/project.pbxproj`** so both SPM `swift test`
and xcodebuild `test` discover it (`scripts/check-test-membership.sh`
gate clean).

### TDD evidence

- **RED phase (pre-edit, AppViews.swift + ForecastPickerView.swift on
  `github/main`):** all three contract assertions fail. Verified by
  source-scan dry-run (`.accessibilityHidden(true)` slice = False,
  `.accessibilityElement(children: .combine)` slice = False for both
  banner sites).
- **GREEN phase (post-edit):** all three pass under `./build.sh`
  (xcresult: `Test-UVBurnTimer-2026.05.22_14-26-16--0700.xcresult`).

## Side-effect: ADR-0001 line-citation refresh

`.accessibilityHidden(true)` inside TierBadge added one line at 1153,
shifting all anchors below by +1. `test_S5_adr0001CitationsMatchLive
SourceLineNumbers` caught the drift on the PersistentFooter `AboutView`
push citation. Bumped:

- `line **2170**` → `line **2171**`
- `2169–2171` → `2170–2172`

All other ADR-0001 anchors (HeroTimerCard struct, heroTimerCardView,
NavigationStack, sheets, EstimateInfoButton, chips) are above line 1152
and unaffected. Falls under "bugs directly caused by your changes" per
agent rules — corrected in the same commit.

## CI run IDs

- **push leg:** `26312959589` — https://github.com/yashasg/uv-burn-timer/actions/runs/26312959589
- **PR leg:** `26313088707` — https://github.com/yashasg/uv-burn-timer/actions/runs/26313088707

(Captured at PR open time, 2026-05-22T20:55:00Z.)

## Local build verdict

- `./build.sh` (Debug + Release + tests) — **PASS** for all `UVBurnTimerCoreTests`
  including the three new `test_A11Y_*` and the refreshed `test_S5`.
- One pre-existing UI-test flake (`testEstimateInfoButtonOpensAboutWith
  HighlightedApplicabilityAnchor`) also fails on `github/main` baseline
  (verified via prior xcresult `Test-UVBurnTimer-2026.05.22_14-13-33`);
  unrelated to this change.
- SwiftLint HIG gate: 0 violations (`./build.sh lint` clean).
- AST gate: 0 violations.

## Scope guardrails honoured

- ❌ `tools/swiftlint-rules/` untouched (Gaia's territory).
- ❌ `.swiftlint.yml` untouched.
- ❌ PR #119 not modified.
- ✅ 3 sites + 1 contract-test file + 1 ADR line-number refresh + 1 pbxproj wiring.
