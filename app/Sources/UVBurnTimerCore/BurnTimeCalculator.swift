import Foundation

public enum BurnTimeCalculatorError: Error, Equatable, Sendable {
    case negativeUVIndex
}

public enum BurnTimeTier: Equatable, Sendable {
    case none
    case long
    case moderate
    case short
}

public struct BurnTimeEstimate: Equatable, Sendable {
    public let rawMinutes: Double
    public let tier: BurnTimeTier

    public var isCappedForDisplay: Bool {
        rawMinutes.isFinite && rawMinutes >= 240
    }

    public var roundedDisplayMinutes: Int? {
        guard rawMinutes.isFinite else { return nil }
        return Int(rawMinutes.rounded())
    }

    public var displayText: String {
        if !rawMinutes.isFinite {
            return "No UV"
        }

        if isCappedForDisplay {
            return "240+ min"
        }

        return "~\(Int(rawMinutes.rounded())) min"
    }

    public var accessibilitySummary: String {
        if !rawMinutes.isFinite {
            return "UV index is 0. No erythemal irradiance detected."
        }

        if isCappedForDisplay {
            return "Estimated burn time: 4 or more hours."
        }

        return "Estimated burn time: \(Int(rawMinutes.rounded())) minutes."
    }

    public func isElapsed(fetchedAt: Date, now: Date) -> Bool {
        guard rawMinutes.isFinite else {
            return false
        }

        let burnWindowSeconds = rawMinutes * 60
        let refreshWindowSeconds = ProductTiming.sunscreenReapplicationIntervalSeconds
        return now.timeIntervalSince(fetchedAt) >= min(burnWindowSeconds, refreshWindowSeconds)
    }
}

public enum BurnTimeCalculator {
    public static func estimate(
        skinType: FitzpatrickSkinType,
        spf: SPFLevel,
        uvIndex: Double
    ) throws -> BurnTimeEstimate {
        guard uvIndex >= 0 else {
            throw BurnTimeCalculatorError.negativeUVIndex
        }

        guard uvIndex > 0 else {
            return BurnTimeEstimate(rawMinutes: .infinity, tier: .none)
        }

        let erythemalIrradianceWattsPerSquareMeter = uvIndex * 0.025
        let secondsToOneMED = skinType.minimalErythemalDoseJoules / erythemalIrradianceWattsPerSquareMeter
        let unprotectedMinutes = secondsToOneMED / 60
        let protectedMinutes = unprotectedMinutes * Double(spf.rawValue)

        return BurnTimeEstimate(
            rawMinutes: protectedMinutes,
            tier: tier(for: protectedMinutes)
        )
    }

    public static func tier(for minutes: Double) -> BurnTimeTier {
        guard minutes.isFinite else { return .none }

        if minutes >= 60 {
            return .long
        }

        if minutes >= 20 {
            return .moderate
        }

        return .short
    }
}
