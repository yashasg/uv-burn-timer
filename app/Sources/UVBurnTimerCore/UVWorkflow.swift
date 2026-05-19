import Foundation

public struct UVCoordinate: Codable, Equatable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public var roundedForWeatherRequest: UVCoordinate {
        UVCoordinate(
            latitude: (latitude * 100).rounded() / 100,
            longitude: (longitude * 100).rounded() / 100
        )
    }

    public var privacyDisplayText: String {
        String(format: "Approx. %.2f, %.2f", latitude, longitude)
    }
}

public struct UVSnapshot: Equatable, Sendable {
    public let uvIndex: Double
    public let fetchedAt: Date
    public let roundedCoordinate: UVCoordinate

    public init(uvIndex: Double, fetchedAt: Date, roundedCoordinate: UVCoordinate) {
        self.uvIndex = uvIndex
        self.fetchedAt = fetchedAt
        self.roundedCoordinate = roundedCoordinate
    }
}

public struct CachedRoundedCoordinate: Codable, Equatable, Sendable {
    public let roundedCoordinate: UVCoordinate

    public init(roundedCoordinate: UVCoordinate) {
        self.roundedCoordinate = roundedCoordinate
    }

    public init(snapshot: UVSnapshot) {
        self.roundedCoordinate = snapshot.roundedCoordinate
    }
}

public enum RelativeAgeText {
    public static func text(fetchedAt: Date, now: Date) -> String {
        let elapsedSeconds = max(0, now.timeIntervalSince(fetchedAt))
        let elapsedMinutes = max(1, Int(elapsedSeconds / 60))
        return "Updated \(elapsedMinutes) min ago"
    }
}

public struct LocationPromptGate: Equatable, Sendable {
    public private(set) var hasAcknowledgedRationale: Bool

    public init(hasAcknowledgedRationale: Bool = false) {
        self.hasAcknowledgedRationale = hasAcknowledgedRationale
    }

    public mutating func allowSystemPromptOrAcknowledgeRationale() -> Bool {
        guard hasAcknowledgedRationale else {
            hasAcknowledgedRationale = true
            return false
        }

        return true
    }
}

public protocol UVDataProviding: Sendable {
    func currentUVIndex(at coordinate: UVCoordinate) async throws -> UVSnapshot
}

public struct StaticUVDataProvider: UVDataProviding {
    private let uvIndex: Double
    private let fetchedAt: Date

    public init(uvIndex: Double, fetchedAt: Date = Date(timeIntervalSince1970: 0)) {
        self.uvIndex = uvIndex
        self.fetchedAt = fetchedAt
    }

    public func currentUVIndex(at coordinate: UVCoordinate) async throws -> UVSnapshot {
        UVSnapshot(
            uvIndex: uvIndex,
            fetchedAt: fetchedAt,
            roundedCoordinate: coordinate.roundedForWeatherRequest
        )
    }
}

public enum UVBurnTimerWorkflowError: Error, Equatable, Sendable {
    case missingSkinType
    case disclaimerNotAcknowledged
}

public struct UVBurnTimerWorkflow: Sendable {
    public let uvProvider: any UVDataProviding

    public init(uvProvider: any UVDataProviding) {
        self.uvProvider = uvProvider
    }

    public func fetchEstimate(
        for session: UVBurnTimerSession,
        at coordinate: UVCoordinate
    ) async throws -> (snapshot: UVSnapshot, estimate: BurnTimeEstimate) {
        guard let skinType = session.selectedSkinType else {
            throw UVBurnTimerWorkflowError.missingSkinType
        }

        guard session.acknowledgedDisclaimer else {
            throw UVBurnTimerWorkflowError.disclaimerNotAcknowledged
        }

        let snapshot = try await uvProvider.currentUVIndex(at: coordinate.roundedForWeatherRequest)
        let estimate = try BurnTimeCalculator.estimate(
            skinType: skinType,
            spf: session.selectedSPF,
            uvIndex: snapshot.uvIndex
        )

        return (snapshot, estimate)
    }
}
