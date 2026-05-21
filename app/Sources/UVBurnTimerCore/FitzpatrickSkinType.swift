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
        // WI-wheeler-ff (Loop-11) AUDIT-ONLY — Strings adapted from NCBI
        // Bookshelf NBK481857 Ch.6 Table 1 (Ward & Farma 2017, Codon
        // Publications) with the behavior-first reorder ratified in
        // D-CYCLE-1-001 (see .squad/decisions.md ~L1476). Type I "freckles,
        // red/blonde hair" descriptor traces to Fitzpatrick TB 1988
        // (clinical-history §), NOT NBK481857 Table 1. Paraphrase is
        // canonical per D-2026-05-19-009; do NOT swap to verbatim NCBI.
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

    // MARK: - Minimal Erythemal Dose (J/m², erythemally weighted per CIE S 007/E:1998)
    // WI-wheeler-ff (Loop-11) — per-row citation comments.
    // Sources: Fitzpatrick TB 1988 (Arch Dermatol 124:869–871); Sayre RM et al.
    //   1981 (J Am Acad Dermatol 5:439–443); Diffey BL 1991
    //   (Phys Med Biol 36:299–328); Harrison GI & Young AR 2002
    //   (Methods 28:14–19). SI units; do NOT convert to mJ/cm² narrowband-UVB
    //   phototherapy doses (5–10× safety drift — see
    //   .squad/decisions/archive/wheeler-fitzpatrick-and-med-anchor.md §2.3).
    public var minimalErythemalDoseJoules: Double {
        switch self {
        // AUDIT-ONLY: 200 J/m² — Fitzpatrick 1988 p.870 Table 1; Sayre 1981 p.441. Established.
        case .typeI: 200
        // AUDIT-ONLY: 250 J/m² — Fitzpatrick 1988 p.870 Table 1; Sayre 1981 p.441. Established.
        case .typeII: 250
        // AUDIT-ONLY: 300 J/m² — Fitzpatrick 1988 p.870 Table 1 (modal of 250–400 range); Harrison & Young 2002 p.16. Established.
        case .typeIII: 300
        // AUDIT-ONLY: 450 J/m² — Sayre 1981 p.441 (range 350–600; 450 = consensus mid); Diffey 1991 §3. Reasonable approximation.
        case .typeIV: 450
        // AUDIT-ONLY: 600 J/m² — Harrison & Young 2002 p.16 (range 600–800; 600 chosen conservative-for-user). Reasonable approximation.
        case .typeV: 600
        // AUDIT-ONLY: 1_000 J/m² — Harrison & Young 2002 p.16 (range 800–1500; 1000 = conservative mid). Reasonable approximation; wider uncertainty disclosed in ProductCopy.aboutEstimateApplicability.
        case .typeVI: 1_000
        }
    }
}
