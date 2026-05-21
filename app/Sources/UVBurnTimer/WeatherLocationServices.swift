import CoreLocation
import Foundation
import UVBurnTimerCore
import WeatherKit

enum DeviceLocationError: Error {
    case denied
    case unavailable
    case requestAlreadyInProgress
}

@MainActor
final class DeviceLocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<UVCoordinate, Error>?

    override init() {
        super.init()
        manager.delegate = self
        if #available(iOS 14.0, *) {
            manager.desiredAccuracy = kCLLocationAccuracyReduced
        } else {
            manager.desiredAccuracy = kCLLocationAccuracyKilometer
        }
    }

    func currentCoordinate() async throws -> UVCoordinate {
        guard continuation == nil else {
            throw DeviceLocationError.requestAlreadyInProgress
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
            case .denied, .restricted:
                finish(with: .failure(DeviceLocationError.denied))
            @unknown default:
                finish(with: .failure(DeviceLocationError.unavailable))
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_: CLLocationManager) {
        Task { @MainActor in
            switch self.manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                self.manager.requestLocation()
            case .denied, .restricted:
                finish(with: .failure(DeviceLocationError.denied))
            case .notDetermined:
                break
            @unknown default:
                finish(with: .failure(DeviceLocationError.unavailable))
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations.last?.coordinate

        Task { @MainActor in
            guard let coordinate else {
                finish(with: .failure(DeviceLocationError.unavailable))
                return
            }

            finish(
                with: .success(
                    UVCoordinate(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    ).roundedForWeatherRequest
                )
            )
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didFailWithError _: Error) {
        Task { @MainActor in
            finish(with: .failure(DeviceLocationError.unavailable))
        }
    }

    private func finish(with result: Result<UVCoordinate, Error>) {
        guard let continuation else {
            return
        }

        self.continuation = nil
        continuation.resume(with: result)
    }
}

struct WeatherKitUVDataProvider: UVDataProviding {
    func currentUVIndex(at coordinate: UVCoordinate) async throws -> UVSnapshot {
        let roundedCoordinate = coordinate.roundedForWeatherRequest
        let location = CLLocation(
            latitude: roundedCoordinate.latitude,
            longitude: roundedCoordinate.longitude
        )
        let weather = try await WeatherService.shared.weather(for: location)

        return UVSnapshot(
            uvIndex: Double(weather.currentWeather.uvIndex.value),
            fetchedAt: Date(),
            roundedCoordinate: roundedCoordinate
        )
    }
}

// MARK: - WeatherKitForecastProvider

/// Fetches the 10-day UV forecast from WeatherKit in a single round-trip and
/// maps it to a ForecastSnapshot for persistence in ForecastStore.
///
/// WeatherKit calls are isolated here; ForecastStore never calls WeatherKit.
struct WeatherKitForecastProvider: Sendable {

    // UTC-based calendar used for all hour-slot coercions.
    // Stored as a let so it is initialised once per provider instance.
    private let utcCalendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }()

    /// Fetches daily + hourly forecasts in one WeatherKit call and returns a
    /// ForecastSnapshot ready for persistence.
    ///
    /// - Parameter coordinate: 2dp-rounded coordinate per LAUNCH-PLAN policy.
    /// - Returns: ForecastSnapshot with hours.count == days.count × 24.
    func fetchSnapshot(at coordinate: UVCoordinate) async throws -> ForecastSnapshot {
        let location = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        // Single round-trip — both .daily and .hourly in one call.
        let (daily, hourly) = try await WeatherService.shared.weather(
            for: location,
            including: .daily, .hourly
        )

        // Map up to 10 DayWeather entries to DayForecast.
        // DayWeather.sun is `var sun: SunEvents` — a NON-optional struct.
        // Access path: dayWeather.sun.sunrise (SunEvents type, not Sun).
        // sunrise/sunset are Date? inside SunEvents — nil at polar latitudes.
        let days: [DayForecast] = daily.forecast.prefix(10).map { dayWeather in
            DayForecast(
                date: dayWeather.date,
                // WeatherKit DayWeather does not expose a separate daily-min UVI.
                // Overnight UVI is always 0 by physics — use 0.0 for dailyMin.
                dailyMinUVI: 0.0,
                // dayWeather.uvIndex.value is Int — the peak daytime UVI for the day.
                dailyMaxUVI: Double(dayWeather.uvIndex.value),
                // DayWeather.sun is non-optional SunEvents; sunrise/sunset are Date? inside.
                sunrise: dayWeather.sun.sunrise,
                sunset: dayWeather.sun.sunset
            )
        }

        // Build a UTC-hour → UVI index from WeatherKit's hourly array.
        // HourWeather.uvIndex is non-optional (UVIndex type, confirmed research).
        // Value is Int — cast to Double for storage.
        var hourIndex: [Date: Double] = [:]
        for hourWeather in hourly.forecast {
            let key = startOfHour(hourWeather.date, in: utcCalendar)
            hourIndex[key] = Double(hourWeather.uvIndex.value)
        }

        // Coerce to exactly days.count × 24 UTC-based hour slots.
        //
        // DST transition coercion:
        //   Spring-forward day has 23 civil hours → WeatherKit may return 23
        //   entries for that day. The missing UTC slot is filled with UVI = 0.
        //   Fall-back day has 25 civil hours → truncated to first 24 UTC slots.
        //
        // Polar-night coercion:
        //   All 24 slots have UVI = 0 from WeatherKit (physics inference;
        //   HourWeather.uvIndex is non-optional so no nil-handling needed).
        //   These render as .nighttime in ForecastStore.uvIndex(at:) without
        //   any special-case polar code.
        //
        // Post-condition: hours.count == days.count × 24 (loop guarantees this).
        var hours: [HourForecast] = []
        hours.reserveCapacity(days.count * 24)
        for day in days {
            let dayStart = utcCalendar.startOfDay(for: day.date)
            for slotOffset in 0..<24 {
                // Each slot is exactly 3600 s apart in UTC — immune to DST.
                let slotDate = dayStart.addingTimeInterval(TimeInterval(slotOffset * 3_600))
                let slotKey = startOfHour(slotDate, in: utcCalendar)
                // Coerce missing entries (e.g., DST gap) to UVI = 0.
                let uvi = hourIndex[slotKey] ?? 0.0
                hours.append(HourForecast(timestamp: slotDate, uvIndex: uvi))
            }
        }

        // Use Apple's expiration signal from the daily forecast metadata.
        // Forecast<DayWeather>.metadata.expirationDate is the authoritative
        // staleness boundary — no hardcoded N-hour threshold.
        return ForecastSnapshot(
            schemaVersion: ForecastSnapshot.currentSchemaVersion,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            fetchedAt: Date(),
            expirationDate: daily.metadata.expirationDate,
            days: Array(days),
            hours: hours
        )
    }
}

// MARK: - Hour-boundary helper (app target)

/// Returns `date` truncated to the start of its hour in the given calendar.
private func startOfHour(_ date: Date, in calendar: Calendar) -> Date {
    let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)
    return calendar.date(from: comps) ?? date
}
