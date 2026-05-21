// ForecastProvider.swift — WI-7: protocol + scenePhase refresh coordinator
// Spec: .squad/designs/wi-7/kwame-forecast-storage-mechanism.md §Refresh strategy

import Foundation

// MARK: - ForecastProviding protocol

/// Abstraction over WeatherKit (production) and test doubles.
/// Kwame's `WeatherKitForecastProvider` will conform to this in the app target.
/// Tests supply `StaticForecastProvider` or `MockCountingForecastProvider`.
public protocol ForecastProviding: Sendable {
    func fetchForecast(at coordinate: UVCoordinate) async throws -> ForecastSnapshot
}

// MARK: - ForecastRefreshCoordinator

/// Drives the scenePhase-active refresh decision: checks whether the stored
/// snapshot is stale or too far from the current coordinate, and re-fetches
/// via `ForecastProviding` when necessary.
///
/// Lives in the Core library so it can be unit-tested without UIKit/SwiftUI.
/// The app target wires this into `RootView`'s scenePhase observer.
public actor ForecastRefreshCoordinator {
    let store: ForecastStore
    let provider: any ForecastProviding

    /// How many times `provider.fetchForecast(at:)` has been called.
    /// Tests inspect this to verify fetch-or-skip decisions.
    public private(set) var fetchCallCount = 0

    public init(store: ForecastStore, provider: any ForecastProviding) {
        self.store = store
        self.provider = provider
    }

    /// Call when `scenePhase` transitions to `.active`.
    /// Re-fetches if the snapshot is nil, stale, or the coord has moved > 50 km.
    public func handleSceneActive(currentLatitude: Double, currentLongitude: Double, now: Date = Date()) async {
        // K-H3: increment exactly once per actual fetch attempt. Previously,
        // both the `do` block (before the fetch) and the `catch` block
        // incremented `fetchCallCount`, so a single failed fetch registered as 2.
        let needsRefresh: Bool
        do {
            let snapshot = try await store.load()
            if let snapshot {
                let stale = snapshot.isStale(now: now)
                let outOfRange = await store.isCoordOutOfRange(
                    latitude: currentLatitude,
                    longitude: currentLongitude
                )
                needsRefresh = stale || outOfRange
            } else {
                needsRefresh = true
            }
        } catch {
            // Schema mismatch or I/O error — treat as absent, attempt re-fetch
            needsRefresh = true
        }

        guard needsRefresh else { return }

        fetchCallCount += 1
        let coord = UVCoordinate(latitude: currentLatitude, longitude: currentLongitude)
        if let fetched = try? await provider.fetchForecast(at: coord) {
            try? await store.save(fetched)
        }
    }
}
