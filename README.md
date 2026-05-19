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

1. Cold launch shows a required disclaimer every app session, with no "do not show again" escape hatch.
2. A user must deliberately choose a Fitzpatrick skin type; there is no default skin-type selection.
3. SPF defaults to 30 and can be changed to None, 15, 30, 50, or 70+.
4. The main screen shows the burn-time verdict, a photosensitization reach-back link, Apple Weather attribution, and the persistent "not medical advice" footer.
5. The calculator caps very long displayed estimates at `240+ min` while preserving the raw model value internally.
6. Location permission has an inline rationale and rounded-coordinate privacy line before the system prompt.
7. Denied location access shows an empty state with a path to retry after enabling When In Use access.
8. Estimates older than the earlier of the burn-time window or two hours show a recalculate warning and re-present the disclaimer when returning from background, while the footer reminds users to cover up if skin reddens and reapply sunscreen every two hours regardless of timer.
9. Repeating users can revisit About, citations, and one-time pricing from Settings without adding any account, analytics, or subscription flow.
10. The last approximate UV lookup can be restored on device, with rounded coordinates shown only at two-decimal precision.

## Privacy and product guardrails

- Skin type and SPF live in app memory only.
- Rounded two-decimal coordinates are sent to Apple Weather for UV lookup; the app may cache the last UV value, fetch time, and rounded coordinates on device to restore the previous estimate.
- No HealthKit integration.
- No analytics, ads, crash SDKs, account system, subscription, or third-party tracking.
- Weather attribution is shown as Apple Weather on iOS surfaces.

The browser prototype remains in `prototype/`; all iOS app code lives in `app/`.
