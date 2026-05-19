import Foundation

public enum FitzpatrickSkinType: Int, CaseIterable, Codable, Identifiable, Sendable {
    case typeI = 1
    case typeII
    case typeIII
    case typeIV
    case typeV
    case typeVI

    public var id: Int { rawValue }

    public var romanNumeral: String {
        switch self {
        case .typeI: "I"
        case .typeII: "II"
        case .typeIII: "III"
        case .typeIV: "IV"
        case .typeV: "V"
        case .typeVI: "VI"
        }
    }

    public var pickerDescription: String {
        switch self {
        case .typeI:
            "Always burns, never tans. Very fair; often freckles, red/blonde hair."
        case .typeII:
            "Burns easily, tans minimally. Fair skin; light eyes common."
        case .typeIII:
            "Burns moderately, tans gradually. Medium skin tone."
        case .typeIV:
            "Burns minimally, tans easily. Olive or medium-brown skin."
        case .typeV:
            "Rarely burns, tans deeply. Brown skin."
        case .typeVI:
            "Almost never burns, deeply pigmented. Dark brown to black skin."
        }
    }

    public var minimalErythemalDoseJoules: Double {
        switch self {
        case .typeI: 200
        case .typeII: 250
        case .typeIII: 300
        case .typeIV: 450
        case .typeV: 600
        case .typeVI: 1_000
        }
    }
}
