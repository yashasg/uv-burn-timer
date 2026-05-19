# UV Burn Timer — Prototype

Open `index.html` in any modern browser. No server required.

## What to click

1. **Dismiss the disclaimer modal** — fires every browser session (by design).
2. **Select your Fitzpatrick skin type** (I–VI) from the picker.
3. **Select your SPF level** — None / 15 / 30 / 50 / 70+.
4. **Tap "Use my location"** — browser permission prompt → ~1–2 seconds → UV data fetched from Open-Meteo.
5. **See the estimate:** "Estimated time to 1 MED of skin reddening: ~22 minutes (Fitzpatrick III, SPF 30, UV index 8.0)."

Your skin type + SPF selection are reflected in the URL hash (`#fitz=3&spf=30`) — bookmark the URL to restore your preferred setup.

## Debug query strings (test without GPS or API)

Append to the file URL:

- `index.html?uv=8` — force UV index 8 (disables location button)
- `index.html?uv=11` — force UV index 11 (high UV scenario)
- `index.html?uv=0` — force UV index 0 (zero / nighttime scenario)
- Combine with hash: `index.html?uv=8#fitz=1&spf=1` — Type I skin, no SPF, UV 8

## Privacy

UV Burn Timer is designed with a zero-data architecture. Here is what persists where — and why.

| Data | Storage | Rationale |
|------|---------|-----------|
| **Fitzpatrick skin type** | URL hash + in-memory only | Skin type is special-category health-adjacent data. It is **never** written to `localStorage`. Storing it persistently would create a long-lived record of a personal health attribute. URL hash keeps it bookmarkable without server-side or persistent local storage. |
| **SPF level** | URL hash + in-memory only | Same rationale as skin type — paired health-adjacent input. Never in `localStorage`. |
| **Disclaimer seen flag** | `sessionStorage` only | The disclaimer must re-fire on every new browser session (Donatello M1 non-negotiable). `sessionStorage` is cleared when the browser session ends. No "don't show again." |
| **Last-used coordinates** | `localStorage` (rounded to 2 decimal places) | Coordinates are location data, not health data. Rounding to 2 decimals (~1 km precision) before any persistence or API call is a proportionality measure. `ubt.lastCoords` key only. |

**No third-party analytics.** No Firebase, Sentry, Mixpanel, or any SDK. The only network call is to Open-Meteo for UV index data.

**Open-Meteo privacy:** UV index is fetched with rounded coordinates. Open-Meteo's privacy policy governs their server logs. No user identifier is sent.

## About & citations

Tap **About & Citations** in the footer to see:

- Fitzpatrick skin phototype scale reference: **Fitzpatrick TB (1988)** — the source of the Minimal Erythemal Dose (MED) tables used in the calculation.
- Erythemal action spectrum reference: **Diffey BL (1991) / CIE Standard S 007/E-1998** — the erythemal reference spectrum that defines how UV irradiance maps to biological effect.

This is a clickable prototype for evaluating the idea, not a production app.
See `LAUNCH-PLAN.md` for distribution + monetization handoff.
