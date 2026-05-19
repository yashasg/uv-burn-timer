### 2026-05-19T06:42:14Z: User directive
**By:** yashasgujjar (via Copilot)
**What:** iOS implementation uses Apple WeatherKit (not Open-Meteo) for UV index data. The web prototype's existing Open-Meteo integration is grandfathered as-is; the iOS app does not use Open-Meteo.
**Why:** User request — captured for team memory.
**Implications:**
- WeatherKit ships with the Apple Developer Program ($99/yr already required for App Store submission); free up to 500K calls/month.
- Break-even math in `prototype/LAUNCH-PLAN.md` (currently uses Open-Meteo €29/yr ≈ $31) needs revision — incremental API cost is effectively $0 if amortized against the existing dev-program fee.
- Attribution requirement changes from `Weather data: Open-Meteo (CC BY 4.0)` to Apple WeatherKit's required attribution lockup + link to Apple's Weather data sources page (per WeatherKit Display Requirements).
- App Store description and any in-app About surface require an update before iOS launch.
- JWT signing required for WeatherKit REST API access (configured via Apple Developer account). No API key in repo.

### 2026-05-19T06:42:14Z: Team pivot — web prototype → iOS app
**By:** yashasgujjar (via Copilot)
**What:** Team roles are pivoting from the web prototype to the iOS app build. Linka shifts from Frontend Dev → UI/UX Designer (Apple HIG & Accessibility). Kwame shifts from Backend Dev → iOS Developer (Swift + WeatherKit). The web prototype remains as the evaluation artifact in `prototype/`.
**Why:** User request — captured for team memory.
