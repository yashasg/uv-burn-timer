import Foundation

// MARK: - ForecastSnapshot

/// The complete on-disk snapshot written by ForecastStore.
/// Schema version field guards against shape changes: a mismatch on load
/// triggers a throw + refetch instead of migration.
///
/// Invariant: `hours.count == days.count * 24` — always.
/// DST transition days (23 or 25 civil hours) and polar-night days (24 rows
/// of UVI = 0) are both coerced to exactly 24 UTC-based hour slots at write
/// time in WeatherKitForecastProvider. Validated on load in ForecastStore.
public struct ForecastSnapshot: Codable, Sendable, Equatable {
    public static let currentSchemaVersion: Int = 1

    /// Bump when the struct shape changes incompatibly.
    /// Mismatch on load → throw ForecastStoreError.schemaMismatch → refetch.
    public let schemaVersion: Int

    /// 2dp-rounded latitude per LAUNCH-PLAN coords policy.
    public let latitude: Double

    /// 2dp-rounded longitude per LAUNCH-PLAN coords policy.
    public let longitude: Double

    /// UTC timestamp of the WeatherKit fetch.
    public let fetchedAt: Date

    /// Expiry signal from Apple — `Weather.metadata.expirationDate` (via
    /// `Forecast<DayWeather>.metadata.expirationDate` in one-shot fetch).
    /// Prefer this over any hardcoded N-hour threshold.
    public let expirationDate: Date

    /// Up to 10 DayForecast entries (one per calendar day).
    public let days: [DayForecast]

    /// Exactly `days.count × 24` HourForecast entries.
    /// Coerced to this count at write time; validated at read time.
    public let hours: [HourForecast]

    public init(
        schemaVersion: Int,
        latitude: Double,
        longitude: Double,
        fetchedAt: Date,
        expirationDate: Date,
        days: [DayForecast],
        hours: [HourForecast]
    ) {
        self.schemaVersion = schemaVersion
        self.latitude = latitude
        self.longitude = longitude
        self.fetchedAt = fetchedAt
        self.expirationDate = expirationDate
        self.days = days
        self.hours = hours
    }

    /// Staleness predicate — uses Apple's expiration signal directly.
    /// No hardcoded threshold.
    public func isStale(now: Date = Date()) -> Bool {
        now >= expirationDate
    }
}

// MARK: - DayForecast

/// Minimum fields needed to render the day picker row.
/// Does NOT include solarNoon or any polar-detection field —
/// polar night is handled by the existing UVI = 0 → .nighttime
/// treatment in ForecastStore.uvIndex(at:).
public struct DayForecast: Codable, Sendable, Equatable {
    /// Midnight (start-of-day) in UTC for this forecast day.
    public let date: Date

    /// Minimum UV Index for the day (overnight is always 0 by physics).
    public let dailyMinUVI: Double

    /// Peak UV Index for the day, as reported by WeatherKit DayWeather.uvIndex.
    public let dailyMaxUVI: Double

    /// Sunrise time from WeatherKit SunEvents — optional because it is nil
    /// during both polar night and polar day (Apple documentation confirms
    /// ambiguity; see skill weatherkit-optional-sun-fields-polar-latitudes).
    /// Display only; not used for any conditional logic.
    public let sunrise: Date?

    /// Sunset time from WeatherKit SunEvents — optional for the same reason
    /// as sunrise. Display only.
    public let sunset: Date?

    public init(
        date: Date,
        dailyMinUVI: Double,
        dailyMaxUVI: Double,
        sunrise: Date?,
        sunset: Date?
    ) {
        self.date = date
        self.dailyMinUVI = dailyMinUVI
        self.dailyMaxUVI = dailyMaxUVI
        self.sunrise = sunrise
        self.sunset = sunset
    }
}

// MARK: - HourForecast

/// One UTC hour slot. `hours` array has exactly `days.count × 24` entries
/// to satisfy the invariant in ForecastSnapshot.
public struct HourForecast: Codable, Sendable, Equatable {
    /// UTC timestamp for the start of this hour slot.
    public let timestamp: Date

    /// Raw WeatherKit UVI value. Non-optional — WeatherKit's
    /// HourWeather.uvIndex is non-optional (confirmed research). Missing
    /// entries (e.g., DST gap or padding) are coerced to 0.0 at write time.
    public let uvIndex: Double

    public init(timestamp: Date, uvIndex: Double) {
        self.timestamp = timestamp
        self.uvIndex = uvIndex
    }
}

// MARK: - UVResult

/// Result type for ForecastStore.uvIndex(at:).
/// UVI == 0 collapses to .nighttime — this covers both regular nighttime hours
/// and polar-night days (all 24 hours have UVI = 0), with zero special-case code.
public enum UVResult: Equatable, Sendable {
    /// A non-zero UV Index value is available for this hour.
    case value(Double)

    /// UVI is 0 — sun protection not needed at this hour.
    /// Includes polar-night hours (collapsed to same treatment as regular night).
    case nighttime

    /// Forecast data cannot produce a result for the requested date.
    case unavailable(reason: UnavailableReason)
}

// MARK: - UnavailableReason

public enum UnavailableReason: String, Codable, Equatable, Sendable {
    /// No snapshot file exists on disk.
    case noSnapshot

    /// Snapshot exists but expirationDate has passed.
    case snapshotExpired

    /// Snapshot coords are more than 50 km from the requested location.
    case coordOutOfRange

    /// Snapshot schema version does not match currentSchemaVersion,
    /// or the hours invariant (hours.count == days.count × 24) is violated.
    case schemaMismatch
}
