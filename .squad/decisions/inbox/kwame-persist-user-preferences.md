# Kwame — Persist user preferences locally

**Date:** 2026-05-19T22:43:49.465-07:00  
**Status:** Implemented on `squad/fix-location-gauge-ui`

- Skin type and SPF are restored from device-local UserDefaults and kept in sync through the SwiftUI app session.
- SPF persistence rejects invalid or legacy unprotected/"none" values and falls back to SPF 30, preserving the no user-facing SPF none rule.
- Location persistence stays privacy-safe: exact device permission state is OS-managed, exact coordinates are not stored by the app, and the existing rounded last coordinate plus local location-rationale/mode acknowledgement are stored locally only.
- Disclaimer acknowledgement remains transient so the safety attestation still appears on cold launch.
- Added core preference restoration tests and a UI regression for returning users with saved skin type, SPF, and rounded location.
