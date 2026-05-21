# Skill: Policy-Version-Gated Onboarding Cover (iOS)

**Extracted by:** Kwame
**Date:** 2026-05-21T07:50:00Z
**Origin:** UV Burn Timer — K-1/K-2/K-3/K-4 implementation of Iris Pattern B spec

---

## Problem

iOS apps with legal/disclaimer covers often show them on every cold launch as a precaution. This creates friction for returning users who have already attested. At the same time, if a material policy change ships, existing users must see the updated disclaimer.

## Pattern

Store an integer `policyVersion` in `UserDefaults`. Compare against a `currentPolicyVersion` constant shipped in code. Show the cover only when:
1. First install (stored == 0 AND no existing-user signal)
2. Material policy change shipped (stored < current)

Never show on a plain cold launch.

## Migration Concern

When introducing this pattern to an app that previously showed the cover on every cold launch, existing users must be silently migrated — do NOT re-fire the cover just because they're upgrading from the old mechanism. Detect existing users via any stable `UserDefaults` key they would have written on first meaningful interaction (e.g., a selected preference key). If detected, silently write `currentPolicyVersion` and skip the cover.

## Implementation Template (Swift / UserDefaults)

```swift
// In UserPreferenceStorage (or equivalent namespace):
public static let disclaimerPolicyVersionKey = "disclaimerPolicyVersion"
public static let currentDisclaimerPolicyVersion = 1  // bump with Plunder/legal sign-off

/// Returns true if the L1 cover should be shown.
/// Side effect: writes currentVersion on the migration path.
public static func shouldShowDisclaimerCover(
    defaults: UserDefaults,
    currentVersion: Int
) -> Bool {
    let storedVersion = defaults.integer(forKey: disclaimerPolicyVersionKey)
    let isExistingUser = defaults.object(forKey: selectedSkinTypeKey) != nil
        || defaults.bool(forKey: someOtherExistingUserSignalKey)

    if storedVersion == 0 && isExistingUser {
        defaults.set(currentVersion, forKey: disclaimerPolicyVersionKey)
        return false
    } else if storedVersion < currentVersion {
        return true
    } else {
        return false
    }
}
```

In `App.init`:
```swift
var initialShowCover = UserPreferenceStorage.shouldShowDisclaimerCover(
    defaults: defaults,
    currentVersion: UserPreferenceStorage.currentDisclaimerPolicyVersion
)
```

In the cover's acknowledgment closure:
```swift
// Write BEFORE dismissing the cover — synchronous, not in onDismiss.
UserDefaults.standard.set(
    UserPreferenceStorage.currentDisclaimerPolicyVersion,
    forKey: UserPreferenceStorage.disclaimerPolicyVersionKey
)
showCover = false
```

## Testability

Extract the evaluation logic as a `public static func` that accepts `UserDefaults` as a parameter. This enables:
- G-D1: first install → returns true
- G-D2: after acknowledgment → returns false
- G-D3: policy bump → returns true
- G-D4: existing user migration → returns false AND writes policyVersion

## When to Increment `currentPolicyVersion`

Only when a material change ships (formula change, new data collected, legal language update). Minor copy tweaks and UI polish are NOT material. Requires legal/compliance sign-off. Increment in source control; the bump itself serves as the audit trail.

## Applicability

Any iOS app with:
- A one-time legal/onboarding cover
- The need to re-present on material policy changes
- Existing users who should NOT be surprised by a re-fire on a routine upgrade
