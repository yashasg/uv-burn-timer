# Kwame — Approximate Location Directive Implementation

**Date:** 2026-05-19T23:31:00-07:00  
**Owner:** Kwame  
**Status:** Implemented in active location persistence branch

## Decision

UV Burn Timer should request and retain only approximate/coarse location data needed for Apple Weather UV and burn-time estimates. It should not ask for temporary full accuracy or preserve precise GPS coordinates.

## Implementation Notes

- CoreLocation requests use `kCLLocationAccuracyReduced` on iOS 14+ and kilometer accuracy fallback on older OS behavior.
- Coordinates are rounded before leaving `DeviceLocationProvider` and again at WeatherKit/storage boundaries.
- `CachedRoundedCoordinate` now normalizes any input coordinate to the app's rounded weather coordinate before encoding, preventing accidental precise persistence.
- User-facing location copy and the When In Use usage description now say approximate location.

## Validation

- Debug build succeeded.
- Swift Testing core suite passed 62/62, including a new regression test ensuring cached coordinate JSON does not contain precise coordinate strings.
- UI automation was retried but blocked by simulator/device-state automation failures after launch; no compile or core-test regression was found.
