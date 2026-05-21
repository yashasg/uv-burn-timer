import Foundation

// MARK: - ForecastStore

/// Pure storage actor for the 10-day UV forecast snapshot.
/// WeatherKit calls live in WeatherKitForecastProvider (app target), not here.
/// This actor owns all disk I/O and in-memory state.
///
/// Thread safety: Swift actor — all methods are actor-isolated.
/// Strict Concurrency clean (swift-tools-version: 6.0).
public actor ForecastStore {
    private let fileURL: URL

    /// In-memory copy populated by load() and save().
    /// nil if no snapshot has been loaded or if load() threw.
    private var inMemorySnapshot: ForecastSnapshot?

    public init() {
        fileURL = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("forecast-snapshot.json")
    }

    /// Initialiser used in tests to inject an isolated file URL.
    /// `@testable import UVBurnTimerCore` exposes this to test targets.
    internal init(fileURL: URL) {
        self.fileURL = fileURL
    }

    // MARK: - load

    /// Loads the snapshot from disk.
    /// - Returns: The decoded snapshot, or nil if no file exists.
    /// - Throws: `ForecastStoreError.schemaMismatch` when the stored JSON is
    ///   malformed, cannot be decoded, has a schema version mismatch, or
    ///   violates the `hours.count == days.count × 24` invariant.
    ///   On any throw the corrupt file is deleted so the next call returns nil.
    public func load() async throws -> ForecastSnapshot? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            try? FileManager.default.removeItem(at: fileURL)
            throw ForecastStoreError.schemaMismatch
        }

        let snapshot: ForecastSnapshot
        do {
            snapshot = try JSONDecoder().decode(ForecastSnapshot.self, from: data)
        } catch {
            // Malformed or truncated file — discard and let caller refetch.
            try? FileManager.default.removeItem(at: fileURL)
            throw ForecastStoreError.schemaMismatch
        }

        guard snapshot.schemaVersion == ForecastSnapshot.currentSchemaVersion else {
            try? FileManager.default.removeItem(at: fileURL)
            throw ForecastStoreError.schemaMismatch
        }

        // Validate the hours invariant.
        // hours.count == days.count * 24 is guaranteed at write time by
        // WeatherKitForecastProvider; if it is violated here, the file was
        // written by an incompatible version — treat as schema mismatch.
        guard snapshot.hours.count == snapshot.days.count * 24 else {
            try? FileManager.default.removeItem(at: fileURL)
            throw ForecastStoreError.schemaMismatch
        }

        inMemorySnapshot = snapshot
        return snapshot
    }

    // MARK: - save

    /// Atomically writes the snapshot to disk and updates the in-memory copy.
    /// `options: .atomic` (write-then-rename) prevents partial writes on crash.
    public func save(_ snapshot: ForecastSnapshot) async throws {
        let data = try JSONEncoder().encode(snapshot)
        try data.write(to: fileURL, options: .atomic)
        inMemorySnapshot = snapshot
    }

    // MARK: - clear

    /// Deletes the on-disk file and clears the in-memory copy.
    /// Called on coord eviction (>50 km move) and explicit user location clear.
    public func clear() async throws {
        try? FileManager.default.removeItem(at: fileURL)
        inMemorySnapshot = nil
    }

    // MARK: - isStale

    /// Delegates to the in-memory snapshot's `isStale(now:)` predicate.
    /// Returns `true` (treat as stale) when no snapshot is loaded.
    public func isStale(now: Date = Date()) -> Bool {
        inMemorySnapshot?.isStale(now: now) ?? true
    }

    // MARK: - isCoordOutOfRange

    /// Returns `true` when the snapshot's stored coords are more than 50 km
    /// from the given coordinate (Haversine, no CoreLocation dependency).
    /// Returns `true` when no snapshot is loaded (treat as invalidated).
    ///
    /// 50 km rationale: NWP spatial resolution (see Gi lifecycle design §3).
    /// 2dp rounding on stored coords adds ≤ 1.1 km max error — noise at 50 km.
    public func isCoordOutOfRange(latitude: Double, longitude: Double) -> Bool {
        guard let snapshot = inMemorySnapshot else { return true }
        let distMeters = haversineDistanceMeters(
            lat1: snapshot.latitude, lon1: snapshot.longitude,
            lat2: latitude,          lon2: longitude
        )
        return distMeters > 50_000
    }

    // MARK: - uvIndex(at:) — picker lookup API

    /// Returns the UV result for the given date (truncated to the UTC hour).
    ///
    /// Behaviour:
    /// - No in-memory snapshot → `.unavailable(.noSnapshot)`
    /// - Snapshot is stale    → `.unavailable(.snapshotExpired)`
    /// - Hour entry found, uvIndex == 0 → `.nighttime`
    ///   (covers both regular nighttime and polar-night days —
    ///    zero special-case code required for polar latitudes)
    /// - Hour entry found, uvIndex > 0  → `.value(uvIndex)`
    /// - Hour not in snapshot window    → `.unavailable(.snapshotExpired)`
    ///   (conservative: if the picker somehow requests an out-of-window hour,
    ///    treat as expired rather than silently returning wrong data)
    public func uvIndex(at date: Date) -> UVResult {
        guard let snapshot = inMemorySnapshot else {
            return .unavailable(reason: .noSnapshot)
        }
        guard !snapshot.isStale() else {
            return .unavailable(reason: .snapshotExpired)
        }

        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = TimeZone(identifier: "UTC")!
        let targetHour = startOfHour(date, in: utcCal)

        guard let entry = snapshot.hours.first(where: {
            startOfHour($0.timestamp, in: utcCal) == targetHour
        }) else {
            // Distinguish: date outside the snapshot window vs. missing hour inside it.
            // Outside range → truly unavailable. Inside range → absent slot coerces to UVI=0.
            let firstHour = snapshot.hours.first.map { startOfHour($0.timestamp, in: utcCal) }
            let lastHour  = snapshot.hours.last.map  { startOfHour($0.timestamp, in: utcCal) }
            if let first = firstHour, let last = lastHour,
               targetHour >= first && targetHour <= last {
                return .nighttime  // coerce missing hour → UVI=0 per polar-as-nighttime directive
            }
            return .unavailable(reason: .snapshotExpired)
        }

        return entry.uvIndex == 0 ? .nighttime : .value(entry.uvIndex)
    }
}

// MARK: - ForecastStoreError

public enum ForecastStoreError: Error, Sendable {
    /// Covers: malformed file, decode failure, schema version mismatch,
    /// and hours-count invariant violation.
    case schemaMismatch
}

// MARK: - Haversine distance (pure Swift — no CoreLocation dependency)

/// Returns the great-circle distance in metres between two WGS-84 coordinates.
private func haversineDistanceMeters(
    lat1: Double, lon1: Double,
    lat2: Double, lon2: Double
) -> Double {
    let R = 6_371_000.0  // Earth mean radius in metres
    let phi1 = lat1 * .pi / 180
    let phi2 = lat2 * .pi / 180
    let dPhi = (lat2 - lat1) * .pi / 180
    let dLambda = (lon2 - lon1) * .pi / 180
    let a = sin(dPhi / 2) * sin(dPhi / 2)
        + cos(phi1) * cos(phi2) * sin(dLambda / 2) * sin(dLambda / 2)
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c
}

// MARK: - Hour-boundary helper

/// Returns `date` truncated to the start of its UTC hour.
/// Implemented via Calendar components to handle DST correctly.
private func startOfHour(_ date: Date, in calendar: Calendar) -> Date {
    let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)
    return calendar.date(from: comps) ?? date
}
