# Skill: iOS Reduced-Accuracy Location — No Custom Pre-Prompt Needed

**Category:** iOS UX / Privacy  
**Applies to:** Any iOS app using `kCLLocationAccuracyReduced` / `CLAccuracyAuthorization.reducedAccuracy`

---

## The Pattern

When an iOS app requests location with **reduced accuracy**, skip the custom in-app rationale
card. The OS system prompt already says "approximate location" and is self-explanatory for
obvious use cases.

## Rule of Thumb

| Location accuracy | Use case obviousness | Custom pre-prompt needed? |
|---|---|---|
| Precise (`kCLLocationAccuracyBest` etc.) | Obvious | No |
| Precise | Non-obvious | Yes — explain why precision matters |
| Reduced (`kCLLocationAccuracyReduced`) | Obvious | **No** — OS dialog is sufficient |
| Reduced | Non-obvious | Maybe — but rare; approximate = low-sensitivity |

**UV index lookup** is the canonical "obvious reduced-accuracy" case. No pre-prompt.

## What the OS Provides

```
"Allow [App Name] to use your approximate location?
[App Name] uses your approximate location to [usage description from Info.plist]."
```

The word **"approximate"** is set by iOS itself when `kCLLocationAccuracyReduced` is the
requested level. Users understand approximate = not precise.

## Implementation Signal (Swift)

```swift
// This combination signals: no custom rationale card needed
locationManager.desiredAccuracy = kCLLocationAccuracyReduced
locationManager.requestWhenInUseAuthorization()
// → OS dialog is the sole permission UI
```

## Anti-Pattern to Avoid

```
User taps "Use my location"
    → App shows custom card: "UV Burn Timer needs your location to fetch UV index"
    → User taps "Continue to location request"
    → OS shows: "Allow UV Burn Timer to use your approximate location?"
    → User taps "Allow"
```

The middle step is redundant. Remove it.

## What to Keep Even After Removing the Card

1. **UserDefaults migration cleanup** — If the card previously persisted an acknowledgment
   key, keep the key's removal in `clearStoredPreferences()` so upgrading users don't carry
   orphaned data.
2. **Privacy copy in About/Settings** — `locationPrivacyLine` or equivalent belongs in
   Settings or About, not as a mandatory pre-prompt on the main screen.
3. **LocationPromptGate struct** — If unit tests exercise the struct independently of the
   card, keep the struct rather than breaking tests.

## Real-World Reference

UV Burn Timer, `feature/main-screen-cleanup`, commit `22e98a5`:
- Removed `LocationRationaleCard` + `allowLocationRequestOrPersistRationale()` + two-step UI flow
- Preserved `LocationPromptGate` struct, migration key, and `locationPrivacyLine` constant
- Result: single-tap "Use my location" directly triggers `requestWhenInUseAuthorization()`
