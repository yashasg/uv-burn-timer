# Kwame — Gauge Visibility Fix

- **Date:** 2026-05-19T20:34:41.561-07:00
- **Owner:** Kwame
- **Status:** proposed

## Decision

Render the circular `BurnRiskGaugeCard` inside `HeroTimerCard` immediately below the estimate inputs instead of as a separate main-screen sibling card.

## Why

On iPhone 17 Pro, the separate sibling card appeared below the large hero card and was partially covered by the persistent footer/safe-area inset at first paint. Users saw at most a clipped arc, which made the circular gauge effectively invisible. Keeping it inside the hero preserves the intended secondary-cue relationship while making it visible without scrolling.

## Scope

- `app/Sources/UVBurnTimer/AppViews.swift`
- `app/Tests/UVBurnTimerUITests/UVBurnTimerUITests.swift`

The existing gauge data guard, health caveat copy, and accessibility label/value remain intact.
