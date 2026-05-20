# Kwame — Simulator gauge fallback

- Date: 2026-05-19T21:34:24.682-07:00
- Decision: Keep the circular burn-window gauge shell visible when no live UV estimate is available, including simulator no-location and WeatherKit-unavailable states.
- Rationale: The gauge was easy to miss in development because it only rendered after CoreLocation and WeatherKit succeeded. Showing an explicitly unavailable shell makes the UI testable without silently injecting fake weather data.
- Guardrail: Production users still see honest location/weather error copy. No sample UV value is used in release or simulator fallback states.
