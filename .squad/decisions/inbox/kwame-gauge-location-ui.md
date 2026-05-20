# Kwame — Gauge prominence and Location chip routing

- Date: 2026-05-19T22:27:48.170-07:00
- Owner: Kwame
- Status: proposed

## Decision

The main-screen Location chip routes to the same location/UV request flow as the primary location CTA. It must not open Settings; Settings remains available only from the gear button.

The burn-risk gauge is a large, centered circular SwiftUI ring in the hero card for both valid estimates and honest unavailable states. Unavailable states keep the gauge shell visible without fabricating WeatherKit data; the accessibility value remains "Unavailable" until real UV data exists.

## Rationale

Users expected the Location affordance to start the location flow, and the small accessory gauge was still too visually subtle compared with the shared design direction. A custom SwiftUI circular ring keeps the safety cue prominent while preserving WeatherKit/CoreLocation honesty.
