# iOS Refresh State Banner Pattern

**Author:** Kwame  
**Date:** 2026-05-21T03:35:00Z  
**Origin:** WI-7 — Iris §8 item 9 (stale-data banner + error retry)

---

## Problem

A view shows cached/stale data while a background refresh is in flight. The user needs to know:
1. "I have data, but it's updating" — non-blocking disclosure.
2. "Update failed — here's a Retry" — recoverable error with action.
3. Nothing when data is fresh (idle) or when there's no data at all (skeleton handles cold start).

---

## Pattern

### 1. State enum (define once, near the view that drives it)

```swift
public enum ForecastRefreshState: Equatable {
    case idle
    case refreshing
    case error(String)  // localizedDescription of the thrown error
}
```

Keep it `public` if the owning view is `public`. `Equatable` is required for `.animation(value:)` triggers.

### 2. State machine in the async fetch function

```swift
@State private var refreshState: ForecastRefreshState = .idle

private func performRefresh() async {
    guard !isFetching, let coord = coordinate else { return }
    isFetching = true
    refreshState = .refreshing          // ← always after the guard
    defer { isFetching = false }
    do {
        let result = try await provider.fetch(at: coord)
        snapshot = result
        refreshState = .idle            // ← success path
    } catch {
        refreshState = .error(error.localizedDescription)  // ← failure path; keep stale data
    }
}
```

**Critical:** set `.refreshing` *after* the `guard` so early returns (no coord, already fetching) leave the state unchanged. Reset to `.idle` in any clear/reset function (e.g., location cleared).

### 3. Pass state down as a plain `let` + retry closure

The view is dumb; the parent owns the state machine:

```swift
// Parent (e.g., RootView)
ForecastPickerView(
    forecastRefreshState: refreshState,
    onRetry: { Task { await performRefresh() } }
)
```

No `@Binding` needed — the parent's `@State` drives re-renders.

### 4. Banner UI (slim, non-blocking)

```swift
@ViewBuilder
private var staleBannerView: some View {
    switch forecastRefreshState {
    case .idle:
        EmptyView()

    case .refreshing:
        HStack(spacing: 6) {
            Image(systemName: "arrow.clockwise")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .animation(
                    reduceMotion ? nil : .linear(duration: 1.5).repeatForever(autoreverses: false),
                    value: isRotating
                )
                .onAppear { isRotating = true }
                .onDisappear { isRotating = false }
            Text("Updating…")
                .font(.footnote).foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
        .padding(.horizontal, 16)
        .background(Color(.systemYellow).opacity(0.12))

    case .error:
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.icloud")
                .font(.footnote).foregroundStyle(.secondary)
            Text("Could not update")
                .font(.footnote).foregroundStyle(.secondary)
                .accessibilityLabel("Could not update forecast")
            Spacer()
            Button("Retry") { onRetry() }
                .font(.footnote).foregroundStyle(.tint)
                .frame(minHeight: 44)   // HIG 44pt hit target
        }
        .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
        .padding(.horizontal, 16)
        .background(Color(.systemRed).opacity(0.08))
    }
}
```

### 5. Animation + Reduce Motion

```swift
// On the container that owns the banner (not on the banner itself):
.animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: forecastRefreshState)
```

- `reduceMotion` from `@Environment(\.accessibilityReduceMotion)`
- `.animation(nil, value:)` = instant switch, no tween

### 6. Guard: never show banner over skeleton

Only insert `staleBannerView` inside the `else` branch where you know data exists:

```swift
if data.isEmpty {
    skeletonView          // cold start — no banner
} else {
    staleBannerView       // stale data — banner if non-idle
    dataListView
}
```

---

## Gotchas

- **`public enum` for `public` view**: if the owning view is `public`, the state enum must be `public` too, or the property/init will fail to compile ("property cannot be declared public because its type uses an internal type").
- **Double-tap Retry is safe** because `performRefresh()` guards on `!isFetching`.
- **Cold-start error stays hidden**: if `.error` fires before any data lands, `data.isEmpty` keeps the skeleton visible. The error state is harmless — clears on the next `scenePhase → .active` retry.
- **Location clear resets state**: call `refreshState = .idle` in any "clear location / clear data" path so a stale `.error` banner doesn't appear over a fresh skeleton after the user resets.

---

## Reusability

Applies anywhere you have:
- A view that renders cached/stale data
- A background fetch that can fail
- A need to disclose staleness without blocking the user
