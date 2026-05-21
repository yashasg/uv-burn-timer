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
    public let isSunscreenProtected: Bool

    public var effectiveWindowMinutes: Double {
        guard rawMinutes.isFinite else { return rawMinutes }

        if isCappedForSunscreenReapplication {
            return ProductTiming.sunscreenReapplicationIntervalMinutes
        }

        return rawMinutes
    }

    public var isCappedForSunscreenReapplication: Bool {
        rawMinutes.isFinite && isSunscreenProtected && rawMinutes > ProductTiming.sunscreenReapplicationIntervalMinutes
    }

    public var isCappedForDisplay: Bool {
        isCappedForSunscreenReapplication || (rawMinutes.isFinite && rawMinutes >= 240)
    }

    public var roundedDisplayMinutes: Int? {
        guard effectiveWindowMinutes.isFinite else { return nil }
        return Int(effectiveWindowMinutes.rounded())
    }

    public var displayText: String {
        if !rawMinutes.isFinite {
            return "No UV"
        }

        if isCappedForSunscreenReapplication {
            return "Up to 2 hr"
        }

        if isCappedForDisplay {
            return "4+ hr"
        }

        return "~\(Self.compactDurationText(minutes: roundedDisplayMinutes ?? 0))"
    }

    public var accessibilitySummary: String {
        if !rawMinutes.isFinite {
            // Wheeler L13-H1 (Bundle Q) — UVI=0 is the rounded forecast value
            // (WHO 2002 §2.1), so the true erythemal irradiance is not
            // necessarily zero. Drop the categorical "no irradiance detected"
            // claim and use the same time-bounded hedge as the visible-copy
            // path (`ProductCopy.noUVAtThisHourAccessibilityLabel`).
            return "UV index is 0 at this hour. Burn risk returns when the sun is up."
        }

        if isCappedForSunscreenReapplication {
            return
                "Sunscreen reapplication window: up to 2 hours. "
                + "The mathematical burn estimate may be longer, "
                + "but reapply sunscreen at least every 2 hours."
        }

        if isCappedForDisplay {
            return "Estimated burn time: 4 or more hours."
        }

        return "Estimated burn time: \(Self.accessibilityDurationText(minutes: roundedDisplayMinutes ?? 0))."
    }

    public func isElapsed(fetchedAt: Date, now: Date) -> Bool {
        guard effectiveWindowMinutes.isFinite else {
            return false
        }

        return now.timeIntervalSince(fetchedAt) >= effectiveWindowMinutes * 60
    }

    private static func compactDurationText(minutes: Int) -> String {
        guard minutes >= 60 else {
            return "\(minutes) min"
        }

        let hours = minutes / 60
        let remainder = minutes % 60

        if remainder == 0 {
            return "\(hours) hr"
        }

        return "\(hours) hr \(remainder) min"
    }

    private static func accessibilityDurationText(minutes: Int) -> String {
        guard minutes >= 60 else {
            return "\(minutes) minutes"
        }

        let hours = minutes / 60
        let remainder = minutes % 60
        let hourText = hours == 1 ? "1 hour" : "\(hours) hours"

        if remainder == 0 {
            return hourText
        }

        return "\(hourText) \(remainder) minutes"
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
            return BurnTimeEstimate(rawMinutes: .infinity, tier: .none, isSunscreenProtected: spf.isSunscreen)
        }

        // WI-wheeler-nn (Loop-11) AUDIT-ONLY: WHO 2002 Practical Guide §2 —
        // UVI = E_ery × 40 m²/W ⇒ E_ery = UVI × 0.025 W/m². Definitional.
        // The constant `0.025` is the inverse of WHO's 40 m²/W weighting
        // factor and converts the unitless UV-Index back into erythemally
        // weighted irradiance.
        let erythemalIrradianceWattsPerSquareMeter = uvIndex * 0.025
        let secondsToOneMED = skinType.minimalErythemalDoseJoules / erythemalIrradianceWattsPerSquareMeter
        let unprotectedMinutes = secondsToOneMED / 60
        let protectedMinutes = unprotectedMinutes * Double(spf.modelMultiplier)

        return BurnTimeEstimate(
            rawMinutes: protectedMinutes,
            tier: tier(
                for: min(
                    protectedMinutes,
                    spf.isSunscreen ? ProductTiming.sunscreenReapplicationIntervalMinutes : protectedMinutes
                )),
            isSunscreenProtected: spf.isSunscreen
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
