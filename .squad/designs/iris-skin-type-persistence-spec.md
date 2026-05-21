# Pattern B — Skin-Type Persistence UX Spec

**Author:** Iris (UI/UX Designer — Apple HIG & Accessibility)
**Date:** 2026-05-21T07:00:00Z
**Status:** Ratified — all three agents + Yashas converged on Pattern B. Spec-only. No Swift code.
**Addressees:** Kwame (implementation), Ma-Ti (test contracts), Plunder (copy approval), Wheeler (chip copy review)

---

## §1 — Design Intent + Decision Summary

### What Pattern B is

Persist Fitzpatrick skin type and applied SPF to `UserDefaults` (on-device, local-only). On every result surface interaction the user sees their stored type as an ambient chip — ambient meaning the hero number renders immediately using the stored value; the chip confirms what the model is conditioned on and offers a one-tap edit path.

### Three ratified changes (Yashas, 2026-05-21)

| # | Change | Surface impact |
|---|--------|---------------|
| 1 | Reverse LAUNCH-PLAN §9 `@State`-only rule — allow `UserDefaults` for skin type + SPF | `UserPreferenceStorage` (already implemented), `LAUNCH-PLAN.md` line 293 + 296 |
| 2 | Drop per-cold-launch `DisclaimerCover` re-fire; trigger on first install + policy version change only | `UVBurnTimerApp.init`, new `disclaimerPolicyVersionKey` in `UserPreferenceStorage` |
| 3 | Decouple Fitzpatrick chip from photosensitizer attestation — different surfaces, different cadences | New `skinTypeChip` in `mainInputsRow`; L1 `DisclaimerCover` retains full photosensitizer content independently |

### What is NOT changing

- G27 / G28 in `ForecastProviderTests.swift` test that `ForecastSnapshot` JSON never leaks skin type or SPF to the server/network. These guards are **independent of** and **unaffected by** UserDefaults persistence. They remain exactly as-is.
- L1 `DisclaimerCover` content is unchanged (Plunder's existing surfaces stand).
- No-default Fitzpatrick picker (D-2026-05-19-012) is unchanged.
- `SkinTypeEditView` and `SkinTypePickerRow` anatomy are unchanged.
- HealthKit: still off the table (Donatello M7, Plunder §2.7).
- iCloud sync: not adopted (Plunder §2.6, weakens "no account" posture).

---

## §2 — Tap-to-Change Chip Spec

### 2.1 Placement rationale

**Location:** `mainInputsRow` in `RootView`, alongside the existing `locationChip` and `spfChip`.

**Why not the hero card?** The hero card already surfaces skin type via `activeEstimateContextLine` (e.g., "For Type III · SPF 30 · UV 7"). Duplicating an edit affordance inside the hero card creates two competing tap targets for the same action. The inputs row is the established HIG-canonical zone for "the inputs the user controls."

**Why not a new row below inputs?** A separate row adds visual weight for no information gain. The chip is a peer of location and SPF — it belongs in the same row.

**Result at standard size:** 3-chip horizontal row — `[Skin type] [SPF 30] [Location]`.
**At AX sizes (`.isAccessibilitySize == true`):** Vertical stack of 3 buttons, full-width. Matches existing `mainInputsRow` stacking logic.

### 2.2 Chip anatomy

#### State A — skin type already set (returning user)

```
┌─────────────────────────┐
│  figure.person.crop.square  Type III  │
└─────────────────────────┘
```

- **SF Symbol:** `figure.person.crop.square` (14pt regular, `.foregroundStyle(.secondary)`)
- **Label text:** `"Type III"` — uses `skinType.romanNumeral` property, prefixed with `"Type "`.
- **Text style:** `.caption` weight `.medium` — matches `locationChip` label style.
- **Button style:** `.bordered`
- **Min tap target:** `.frame(maxWidth: .infinity, minHeight: 44)` — matches `locationChip` and `spfChip`.
- **No trailing chevron or checkmark** — the bordered button affordance is sufficient; a trailing chevron implies navigation rather than a contextual edit, which is the wrong mental model here.

#### State B — no skin type set (first install / cleared)

```
┌─────────────────────────────┐
│  figure.person.crop.square  Set skin type  │
└─────────────────────────────┘
```

- **Label text:** `"Set skin type"`
- **Text style:** `.caption` weight `.medium` with `.foregroundStyle(.secondary)` — same as unset location chip pattern; communicates "optional input not yet provided."
- **No `.disabled`** — the chip must always be tappable.

#### State C — AX5 (`.accessibilityExtraExtraExtraLarge` Dynamic Type)

The label text scales with Dynamic Type. At AX5, `.caption` resolves to a large body-equivalent. The chip row stacks vertically (existing `mainInputsRow` VStack branch handles this). No truncation should occur at AX5 for `"Type III"` or `"Set skin type"` — both fit comfortably in a full-width button. Test with Accessibility Inspector → font size slider at maximum.

### 2.3 Tap behavior

**When skin type is set:** Tap opens `SkinTypeEditView` as a `.sheet` (`.presentationDetents([.medium, .large])`). Uses the **existing** `SkinTypeEditView` — no redesign needed. The user changes their type; on `session.selectedSkinType` change, `RootView.onChange` immediately recomputes `activeEstimate`.

**When no skin type is set:** Tap triggers the existing `presentSkinTypeOnboardingIfNeeded()` flow, which presents `SkinTypeOnboardingView` as a `fullScreenCover`. This is the same onboarding flow used on first install — reuse it.

**Implementation note for Kwame:** The chip's tap action should call a small closure that branches on `session.selectedSkinType == nil`. Do not add a new presentation state variable if the existing `showSkinTypeOnboarding` bool can be set directly. Keep presentation logic in `UVBurnTimerApp` / `RootView`, not in the chip view.

### 2.4 Should there be a parallel SPF chip?

**No new SPF chip is needed.** The `spfChip` already exists in `mainInputsRow` as a `Menu` button with `"SPF \(session.selectedSPF.displayName)"` label — it already IS a tap-to-change chip. It's already persisted via `@AppStorage(UserPreferenceStorage.selectedSPFKey)` in `RootView`. Nothing changes for SPF.

### 2.5 Accessibility spec

| Property | State A (type set) | State B (no type) |
|----------|--------------------|-------------------|
| `accessibilityLabel` | `"Skin type, Type \(skinType.romanNumeral)"` | `"Skin type, not set"` |
| `accessibilityHint` | `"Opens skin type settings to change your Fitzpatrick classification."` | `"Opens skin type selector to set your Fitzpatrick classification."` |
| `accessibilityIdentifier` | `"SkinTypeChip"` | `"SkinTypeChip"` |
| `accessibilityValue` | omit (value is in label) | omit |
| trait | `.isButton` (default for Button) | `.isButton` |

**VoiceOver order in `mainInputsRow`:** Follows SwiftUI default leading-to-trailing order. With 3 chips: SkinTypeChip → SPFChip → LocationChip. This matches the "who am I → what am I wearing → where am I" reading order, which is the natural scan for an outdoor user.

**Reduce Motion:** No animation on the chip itself. If a sheet transition is used to open `SkinTypeEditView`, it respects `@Environment(\.accessibilityReduceMotion)` automatically via UIKit sheet presentation. No custom animation is added.

**Increase Contrast:** Bordered button style automatically uses a heavier border under Increase Contrast without code changes (UIKit semantic color). No additional spec needed.

**Dark Mode:** `.bordered` button style uses system-resolved materials. No additional spec.

---

## §3 — Picker / Settings Flow Changes

### 3.1 Tap-to-change destination

**Existing picker: keep as-is.** `SkinTypeEditView` (`AppViews.swift:1268`) is the destination for the chip tap when a skin type is already stored. It already shows all six Fitzpatrick types, behavior-first copy, no default selection UI, and a "Save" / back navigation. No redesign needed — it satisfies the spec.

**First-install tap (no type set):** Routes to `SkinTypeOnboardingView` (existing `fullScreenCover`). No redesign.

**No new condensed sheet or bottom drawer.** The existing surfaces cover both cases. Adding a third surface (new condensed sheet) would fragment the picker pattern and confuse VoiceOver users who have learned the existing sheet.

### 3.2 Immediate recompute on Fitzpatrick change

When the user changes their Fitzpatrick type via the chip → `SkinTypeEditView` path:
- `session.selectedSkinType` updates via `@Binding`.
- `RootView.activeEstimate` is a computed property derived from `session.selectedSkinType` and `activeUVIndex` — it recomputes automatically with no explicit trigger needed.
- The hero card updates on the next SwiftUI render pass (immediate from user perspective).
- `RootView.onChange(of: session.selectedSkinType)` calls `persist(skinType:)` which writes to `@AppStorage` — this happens automatically on any change.

No additional wiring is needed for immediate recompute. The existing reactive chain handles it.

### 3.3 Settings entry point — no changes to layout

`SettingsSheet` (`AppViews.swift:1191`) already has:
- **"UV estimate inputs" section** → NavigationLink "Skin type" → `SkinTypeEditView`
- **"SPF" section** → `SPFPicker`
- **"Privacy" section** → destructive "Clear saved location" button

**One addition required for Pattern B:** Add a "Clear stored skin type" destructive button in the Privacy section of `SettingsSheet`. This satisfies Plunder §4.1(b) (Art.17 erasure right) and Plunder §4.4 ("Reset affordance in About"). Placing it in Privacy alongside the existing location-clear button is the correct grouping — it's a data management action, not an input-editing action.

Button spec:
- Title: `"Clear stored skin type"` (Plunder to approve exact wording)
- Role: `.destructive`
- Disabled state: disabled when `session.selectedSkinType == nil` (nothing to clear)
- Accessibility hint: `"Removes your stored Fitzpatrick skin type. You will be asked to set it again on next use."`
- Action: calls `UserPreferenceStorage.persist(skinType: nil, to: .standard)` and sets `session.selectedSkinType = nil`

**"Remember my skin type" toggle (Plunder §4.4 recommendation):** Plunder recommended this as best practice for GDPR Art.9 explicit-consent signaling. However, implementing it requires a third `UserDefaults` key, a three-way state machine (nil / on / off), and non-trivial edge cases. For v1 Pattern B, I recommend **deferring the toggle** in favor of:
1. Auto-persist on selection (already implemented via `@AppStorage`).
2. The L1 cover copy (Plunder E13 gate) explicitly stating storage.
3. The Settings "Clear stored skin type" button as the visible off-ramp.
The toggle can be added in v1.1 if EU counsel flags it at E13 review.

---

## §4 — L1 `DisclaimerCover` Trigger Redesign

### 4.1 New trigger rule

**L1 fires on:**
1. **First install** — `disclaimerPolicyVersionKey` absent in `UserDefaults` AND no existing-user signal.
2. **Material policy/methodology change** — `disclaimerPolicyVersionKey` stored value < current shipped value.
3. **Never** on a cold launch where neither condition applies.

### 4.2 `policyVersion` mechanism

**New key:** `UserPreferenceStorage.disclaimerPolicyVersionKey = "disclaimerPolicyVersion"` (static String constant).

**New constant:** `UserPreferenceStorage.currentDisclaimerPolicyVersion: Int = 1` (static Int constant). Increment this in source code when shipping a material policy change.

**"Material policy change" definition:** Any change to: the Diffey formula inputs or coefficients, the intended-purpose statement, the photosensitizer enumeration, or the SPF modeling assumptions. Minor copy tweaks and UI polish are not material. The responsible party for deciding whether a change is material is Plunder; increment `currentDisclaimerPolicyVersion` only on Plunder sign-off.

**Detection logic (pseudo-Swift, for Kwame to implement):**

```
let storedVersion = defaults.integer(forKey: disclaimerPolicyVersionKey)
// storedVersion == 0 means the key was never written

let isExistingUser = defaults.object(forKey: selectedSkinTypeKey) != nil
    || defaults.bool(forKey: locationRationaleAcknowledgedKey)

if storedVersion == 0 && isExistingUser {
    // Migration path: existing user upgrading from @State-only era.
    // Silently mark as seen v1. Do NOT show L1.
    defaults.set(currentDisclaimerPolicyVersion, forKey: disclaimerPolicyVersionKey)
    initialShowDisclaimer = false
} else if storedVersion < currentDisclaimerPolicyVersion {
    // First install (storedVersion == 0, isExistingUser == false)
    // OR policy bumped (storedVersion > 0 but < current).
    initialShowDisclaimer = true
    // Write the new version AFTER the user acknowledges (see §4.3).
} else {
    initialShowDisclaimer = false
}
```

### 4.3 Writing `policyVersion` after acknowledgment

In `UVBurnTimerApp.body`, the `DisclaimerCover` `onAcknowledge` closure currently sets:
```swift
session.acknowledgedDisclaimer = true
showDisclaimer = false
```

Add one line:
```swift
UserDefaults.standard.set(
    UserPreferenceStorage.currentDisclaimerPolicyVersion,
    forKey: UserPreferenceStorage.disclaimerPolicyVersionKey
)
```

This must fire in the `onAcknowledge` closure, not in `onDismiss`, to ensure the version is written synchronously before the disclaimer state changes.

### 4.4 Migration: existing users at upgrade time

**Decision: treat existing users as "seen v1" — do NOT re-fire L1 on upgrade.**

Rationale: The `@State`-only era already showed L1 on every cold launch. Existing users have seen it many times. Re-firing once for a "policy-version handshake" is friction without safety dividend — they already attested. The migration detection uses the presence of `selectedSkinTypeKey` or `locationRationaleAcknowledgedKey` as the existing-user signal (these are written on first meaningful interaction). If neither key is present AND `disclaimerPolicyVersionKey` is absent, the user is a true first installer and L1 fires.

**Edge case:** A user who installed the app, never picked a skin type, and never set location. For them, neither existing-user signal is set, so they'll see L1 again on upgrade. This is acceptable — they haven't provided any meaningful input, so re-presenting the disclaimer is correct.

---

## §5 — LAUNCH-PLAN Update Text

**Verbatim replacement for `prototype/LAUNCH-PLAN.md`, Persistence section (lines 292–297). Paste exactly.**

Replace the existing two bullets:

> - **Skin type + SPF:** `@State` SwiftUI properties only — **NOT `@AppStorage`, NOT `UserDefaults`**. This is the iOS-side enforcement of Donatello M7 + Raphael Art.9 special-category-data mitigation. Skin type and SPF must live in app memory only — equivalent to URL-hash in the web prototype.

> - **First-launch disclaimer modal:** `.sheet(isPresented:)` that re-fires on every cold launch. Implement via a `@State` flag reset on `scenePhase` becoming `.active` after a previous `.background`. No "Don't Show Again" option.

With:

> - **Skin type + SPF:** `UserDefaults` (on-device, local-only). Persist using `UserPreferenceStorage.persist(skinType:)` and `UserPreferenceStorage.persist(spf:)`. Never `HealthKit` (Donatello M7 — unchanged). Never `iCloud` / `NSUbiquitousKeyValueStore` (weakens "no account" marketing posture — Plunder §2.6). Never transmitted to any server or third party. Privacy nutrition label must declare: "Other Health & Fitness Data — stored on device — not linked to user." This is a product-design reversal of the prior `@State`-only rule; the regulatory floor (Plunder memo 2026-05-21T06:35:00Z) permits local `UserDefaults` storage with explicit user selection as consent basis (GDPR Art.9(2)(a)). Ratified by Yashas 2026-05-21.

> - **`DisclaimerCover` (L1) trigger:** Fires on first install and on material policy/methodology changes only. Controlled by `UserPreferenceStorage.disclaimerPolicyVersionKey` (integer) compared against `UserPreferenceStorage.currentDisclaimerPolicyVersion`. Do NOT fire on every cold launch — per-cold-launch re-fire is no longer required (Plunder C6 revised, 2026-05-21). Increment `currentDisclaimerPolicyVersion` only with Plunder sign-off. The photosensitizer disclosure content in `DisclaimerCover` is unchanged. `ForecastSnapshot` (server-visible data) must never contain skin type or SPF fields — G27/G28 guard this.

---

## §6 — Test Contract Changes

### 6.1 G27 / G28 — NO CHANGE

**Clarification:** G27 (`test_skinType_is_never_in_snapshot`) and G28 (`test_spf_is_never_in_snapshot`) in `ForecastProviderTests.swift` test that `ForecastSnapshot` **JSON never leaks skin type or SPF** — they guard against server-side transmission of these values. These tests are **fully independent of UserDefaults persistence** and remain correct and required under Pattern B. Do not modify them. Their test comments reference "personalization stays `@State`-only" — Ma-Ti should update the inline doc comment to clarify the actual guard ("ForecastSnapshot must not transmit skin type/SPF") but the assertion logic is unchanged.

### 6.2 New tests for UserDefaults persistence

**File:** `app/Tests/UVBurnTimerCoreTests/UVWorkflowTests.swift` (existing file — add alongside existing persistence tests starting at line ~131)

**New test G-P1:** `test_skinType_persists_to_UserDefaults_on_selection`
- Call `UserPreferenceStorage.persist(skinType: .typeIV, to: defaults)`
- Assert `defaults.object(forKey: UserPreferenceStorage.selectedSkinTypeKey) != nil`
- Assert `UserPreferenceStorage.restoredSkinType(from: defaults) == .typeIV`

**New test G-P2:** `test_spf_persists_to_UserDefaults_on_selection`
- Call `UserPreferenceStorage.persist(spf: .spf50, to: defaults)`
- Assert `defaults.object(forKey: UserPreferenceStorage.selectedSPFKey) != nil`
- Assert `UserPreferenceStorage.restoredSPF(from: defaults) == .spf50`

**New test G-P3:** `test_skinType_and_spf_never_written_to_HealthKit`
- Verify the app has no HealthKit entitlement: `HKHealthStore.isHealthDataAvailable()` need not be true; assert that `UserPreferenceStorage` writes only to the passed-in `UserDefaults` instance and never calls any `HKHealthStore` method. Implement as a static code-level assertion (confirm `HKHealthStore` is not imported in `UVBurnTimerCore` by checking for absence of `import HealthKit` in the Sources directory — can be a build-phase script test or a grep-based test).

### 6.3 New tests for L1 `DisclaimerCover` trigger

**File:** `app/Tests/UVBurnTimerCoreTests/BurnTimeCalculatorTests.swift` or a new `DisclaimerPolicyTests.swift` file (Ma-Ti's choice — colocate with existing persistence tests).

**New test G-D1:** `test_L1_fires_on_first_install`
- Fresh `UserDefaults` (no keys set)
- Simulate `UVBurnTimerApp.init` policy evaluation logic (extract to a testable free function `shouldShowDisclaimerCover(defaults:currentVersion:)`)
- Assert result is `true`

**New test G-D2:** `test_L1_does_not_fire_on_subsequent_launch_after_acknowledgment`
- Set `disclaimerPolicyVersionKey = currentDisclaimerPolicyVersion` in `UserDefaults`
- Assert `shouldShowDisclaimerCover(defaults:currentVersion:)` returns `false`

**New test G-D3:** `test_L1_fires_on_policy_version_bump`
- Set `disclaimerPolicyVersionKey = 1` in defaults
- Call with `currentVersion = 2`
- Assert result is `true`

**New test G-D4:** `test_existing_user_migration_does_not_re_fire_L1`
- Set `selectedSkinTypeKey` in defaults (existing user signal)
- Leave `disclaimerPolicyVersionKey` absent (0)
- Assert result is `false` AND assert `disclaimerPolicyVersionKey` is written to `currentVersion` (migration write happened)

**Implementation note:** Extract the policy evaluation logic into a testable free function or `static func` in `UserPreferenceStorage`:
```
public static func shouldShowDisclaimerCover(
    defaults: UserDefaults,
    currentVersion: Int
) -> Bool
```
This is a spec requirement, not optional — the logic must be unit-testable outside of `UVBurnTimerApp`.

---

## §7 — Kwame Hand-off Checklist

All items are spec-only. Kwame implements. No new Swift code in this document.

### K-1 — Add `disclaimerPolicyVersionKey` + `currentDisclaimerPolicyVersion` to `UserPreferenceStorage`

**File:** `app/Sources/UVBurnTimerCore/UVBurnTimerSession.swift`
**Where:** After line 52 (`public static let locationRationaleAcknowledgedKey`)
**What:** Add two new static constants:
```
public static let disclaimerPolicyVersionKey = "disclaimerPolicyVersion"
public static let currentDisclaimerPolicyVersion = 1
```

### K-2 — Add `shouldShowDisclaimerCover(defaults:currentVersion:)` to `UserPreferenceStorage`

**File:** `app/Sources/UVBurnTimerCore/UVBurnTimerSession.swift`
**Where:** After `clearStoredPreferences(from:)` (after line ~101)
**What:** New `public static func` implementing the logic in §4.2. Must handle the migration path (existing user, no policy version key).

### K-3 — Replace `initialShowDisclaimer = true` in `UVBurnTimerApp.init`

**File:** `app/Sources/UVBurnTimer/UVBurnTimerApp.swift`
**Where:** Line 13 (`var initialShowDisclaimer = true`)
**What:** Replace with call to `UserPreferenceStorage.shouldShowDisclaimerCover(defaults: defaults, currentVersion: UserPreferenceStorage.currentDisclaimerPolicyVersion)`. The migration write (K-2) happens inside this function. The version write after acknowledgment happens in K-4.

### K-4 — Write `currentDisclaimerPolicyVersion` in `DisclaimerCover`'s `onAcknowledge` closure

**File:** `app/Sources/UVBurnTimer/UVBurnTimerApp.swift`
**Where:** Lines 78–82 (the `DisclaimerCover { ... }` closure)
**What:** Add `UserDefaults.standard.set(UserPreferenceStorage.currentDisclaimerPolicyVersion, forKey: UserPreferenceStorage.disclaimerPolicyVersionKey)` before `showDisclaimer = false`.

### K-5 — Add `skinTypeChip` computed property to `RootView`

**File:** `app/Sources/UVBurnTimer/AppViews.swift`
**Where:** After `spfChip` property (~line 297)
**What:** New `private var skinTypeChip: some View` — a `Button` that:
- Labels with `"Type \(skinType.romanNumeral)"` when `session.selectedSkinType != nil`, else `"Set skin type"`.
- Uses `figure.person.crop.square` SF Symbol as leading icon.
- `.buttonStyle(.bordered)`, `.frame(maxWidth: .infinity, minHeight: 44)`.
- `accessibilityLabel`, `accessibilityHint`, `accessibilityIdentifier("SkinTypeChip")` per §2.5.
- On tap: if `session.selectedSkinType != nil` → set a new `@State private var showSkinTypeEdit = false` to `true` (opens `SkinTypeEditView` as a sheet). If nil → call `presentSkinTypeOnboardingIfNeeded()` (existing function).

### K-6 — Add `skinTypeChip` to `mainInputsRow`

**File:** `app/Sources/UVBurnTimer/AppViews.swift`
**Where:** `mainInputsRow` property (~lines 248–260)
**What:** Add `skinTypeChip` as the first chip in both branches (HStack and VStack). Order: `skinTypeChip` → `spfChip` → `locationChip`.

### K-7 — Add `.sheet(isPresented: $showSkinTypeEdit)` to `RootView` body

**File:** `app/Sources/UVBurnTimer/AppViews.swift`
**Where:** After existing `.sheet(isPresented: $showSettings)` (~line 72)
**What:**
```swift
.sheet(isPresented: $showSkinTypeEdit) {
    SkinTypeEditView(session: $session)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}
```

### K-8 — Add "Clear stored skin type" button to `SettingsSheet`

**File:** `app/Sources/UVBurnTimer/AppViews.swift`
**Where:** `SettingsSheet.body`, Privacy section (~line 1241), after the existing "Clear saved location" button.
**What:** Destructive button per §3.3 spec. Calls `UserPreferenceStorage.persist(skinType: nil, to: .standard)` + sets `session.selectedSkinType = nil`.

### K-9 — Update `LAUNCH-PLAN.md` persistence + L1 trigger rules

**File:** `prototype/LAUNCH-PLAN.md`
**Where:** Lines 293 and 296
**What:** Verbatim replacement text in §5 of this spec.

### K-10 — Update G27/G28 inline doc comments only (assertion logic unchanged)

**File:** `app/Tests/UVBurnTimerCoreTests/ForecastProviderTests.swift`
**Where:** Lines 233–235 (G27 doc comment) and 252–253 (G28 doc comment)
**What:** Remove the phrase "personalization stays `@State`-only" from both comments. Replace with: "skin type and SPF must never be transmitted in `ForecastSnapshot` (server-visible payload)." Assertion logic is not modified.

### K-11 — Implement `shouldShowDisclaimerCover` tests (Ma-Ti owns, Kwame to extract the function first)

The testable `static func` must exist before Ma-Ti can write G-D1 through G-D4. K-2 is a prerequisite for the test suite.

---

## §8 — Coordination Points

### 8.1 Plunder — two open items

**P-1 Copy approval:** The chip label `"Type III"` is functional but Plunder may want to confirm it doesn't inadvertently constitute a medical label (unlikely — it's the user's own input display). Confirm `"Set skin type"` CTA copy is acceptable without legal implications. Low risk; flagging for completeness.

**P-2 "Clear stored skin type" button copy:** The exact wording of the destructive button in Settings Privacy section should be Plunder-approved. My proposed text: `"Clear stored skin type"`. Plunder may prefer something like `"Remove stored skin type"` or `"Delete skin type data"`. Flag to Plunder before K-8 ships.

**P-3 L1 cover storage-disclosure sentence (Plunder E13 gate):** Plunder's E13 item requires confirming that user selection + L1 cover stating the storage purpose = explicit GDPR Art.9(2)(a) consent. Plunder must add one sentence to `ProductCopy.disclaimerBody` (or equivalent) stating something like: "Your skin type is stored on this device to remember your selection." Iris does not write new disclaimer copy — this is Plunder's lane. Kwame should not ship K-3/K-4 until Plunder has updated the copy and Yashas has ratified.

### 8.2 Wheeler — one open item

**W-1 Chip copy review:** Wheeler confirmed (memo 2026-05-21T06:35:00Z) that "the chip preserves session-entry user-awareness of the attested type" without injecting instrument noise. Wheeler should confirm that displaying `"Type III"` (roman numeral only, no behavioral description) on the chip does not inadvertently anchor users to re-attest by visible re-confirmation at each session. Wheeler's own memo §5 says the anchoring effect "reduces noise around a stable trait" — so this should be a quick confirm. Not blocking K-5/K-6, but Wheeler should sign off before v1 submit.

### 8.3 Ma-Ti — implementation of §6 tests

G-D1 through G-D4 require K-2 (`shouldShowDisclaimerCover` free function) to exist first. Ma-Ti should pull K-2 from Kwame's branch before writing the L1 policy tests.

---

*Iris sign-off: 2026-05-21T07:00:00Z. AX5 + VoiceOver + Reduce Motion + dark mode worst-case verified in spec. No Swift code in this document.*
