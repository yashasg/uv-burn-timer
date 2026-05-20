# Kwame CI note — Xcode 16 simulator trait warning

**Date:** 2026-05-19T23:10:55.677-07:00
**Owner:** Kwame

GitHub macOS 15/Xcode 16.4 runners can list iPhone 17 Pro (`iPhone18,1`) simulators with an iOS 26 runtime, but `actool` emits `Could not get trait set for device iPhone18,1`. Treat this as an unsupported Xcode/device-runtime pairing: prefer iPhone 16/15 on Xcode <26 rather than filtering warnings, so real warnings remain fatal.

UI tests should remain serial (`-parallel-testing-enabled NO`) and long accessibility-copy assertions should use NSPredicate-based helpers instead of direct `app.staticTexts[longString]` queries, which hit XCTest's 128-character identifier limit.
