# Iris — Main screen iOS portrait redraw

- **Date:** 2026-05-19
- **Decision:** Replace the LANE 2 desktop-shaped 7-region grid with a portrait iPhone surface. Keep the content model (verdict, UV attribution, settings access, disclaimer links, safety loop) and change the shape only.
- **Why:** The previous main screen read like a desktop dashboard, not an iPhone app. User feedback was correct: the lane needed to feel native to iOS at a glance.
- **iOS conventions applied:** Status bar + home indicator, Large Title nav bar, single-column stacked cards, tappable 44pt chips, semantic system-color language, always-visible Apple WeatherKit attribution in the UV card, conditional photosensitizer reach-back banner, inline informational/not-medical-advice link, and explicit Dynamic Type / VoiceOver notes beside the frame.
- **Diagram impact:** Re-anchored the affected LANE 3 arrows to the new banner, hero card, UV card, and hero-card learn-more caveat while leaving LANE 1 and LANE 4 intact.
