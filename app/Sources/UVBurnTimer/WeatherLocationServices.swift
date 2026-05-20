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
