# UV Burn Timer

Estimated burn time, no subscription.

UV Burn Timer is a SwiftUI iOS app that estimates minutes to one minimal erythemal dose from Fitzpatrick skin type, SPF, and current UV index. It is informational only and is not medical advice.

## Build and test

Use the canonical build script:

```sh
./build.sh
```

The script builds Debug, runs Swift tests, and validates a Release simulator build with Swift warnings treated as errors.

## User scenarios captured

1. Cold launch shows a required disclaimer on first install and whenever the integer `disclaimerPolicyVersion` is bumped to reflect a material policy or methodology change; returning users at the current policy version skip the cover on routine cold launch. The disclaimer is also re-presented on foreground after the burn-time estimate window has elapsed. There is no "do not show again" escape hatch on those triggers.
2. A user must deliberately choose a Fitzpatrick skin type; there is no default skin-type selection.
3. SPF defaults to 30 and can be changed to 15, 30, 50, or 70+.
4. The main screen shows the burn-time verdict, a photosensitization reach-back link, Apple Weather attribution, and the persistent "not medical advice" footer.
5. Estimates render in a compact duration format: sub-hour values as `~45 min`, hour-plus values as `~1 hr` / `~1 hr 20 min`, sunscreen-protected windows capped at `Up to 2 hr`, and unprotected estimates of 240 minutes or more capped at `4+ hr`. The raw model value is preserved internally for accessibility and elapsed-window logic.
6. Location permission has an inline rationale and rounded-coordinate privacy line before the system prompt.
7. Denied location access shows an empty state with a path to retry after enabling When In Use access.
8. Estimates older than the earlier of the burn-time window or two hours show a recalculate warning and re-present the disclaimer when returning from background, while the footer reminds users to cover up if skin reddens and reapply sunscreen every two hours regardless of timer.
9. Repeating users can revisit Settings — Fitzpatrick skin type edit, SPF, About & Citations, Attribution & Legal, one-time pricing, and the clear-saved-location control — without adding any account, analytics, or subscription flow. The Fitzpatrick picker uses the same source-backed copy and accessibility wiring in both onboarding and Settings.
10. Skin type and SPF persist on device so returning users do not re-enter them on every cold launch; the last rounded coordinate may also be restored on device for location context. UV values, burn estimates, and forecast-picker selections are never persisted. Settings includes a clear-saved-location control, and launching with a saved coordinate skips the location-rationale gate.
11. A 10-day day-and-hour UV forecast picker (WI-7) shows hourly UV index with WHO-band color encoding; selecting any future hour drives the burn-time gauge for that hour. The forecast is cached locally with a 50 km coordinate-eviction policy and honors Apple Weather's `expirationDate` staleness; the selected hour itself is never persisted across app launches.

## Privacy and product guardrails

- Skin type, SPF, the `disclaimerPolicyVersion` acknowledgment, and the location-rationale acknowledgment persist in `UserDefaults` on this device only; they are never transmitted off-device or synced.
- Rounded two-decimal coordinates are sent to Apple Weather for UV lookup; the app may save only the last rounded coordinate on device for location context.
- UV index values, burn-time estimates, and disclaimer acknowledgments are never persisted between launches.
- No HealthKit integration.
- No analytics, ads, crash SDKs, account system, subscription, or third-party tracking.
- Weather attribution is shown as Apple Weather on iOS surfaces.

The browser prototype remains in `prototype/`; all iOS app code lives in `app/`.
