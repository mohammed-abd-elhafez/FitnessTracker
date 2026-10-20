import Foundation

/// Measurement system chosen in Settings. Data is always stored in kg and meters.
enum UnitSystem: String, CaseIterable, Sendable {
    case metric, imperial

    static let storageKey = "units.system"
    static let kilogramsPerPound = 0.45359237
    static let metersPerMile = 1_609.344

    /// Weight in the display unit (kg or lb).
    func weight(fromKilograms kg: Double) -> Double {
        self == .metric ? kg : kg / Self.kilogramsPerPound
    }

    /// Converts a display weight (kg or lb) back to kilograms.
    func kilograms(fromWeight value: Double) -> Double {
        self == .metric ? value : value * Self.kilogramsPerPound
    }

    /// Distance in the display unit (km or mi).
    func distance(fromMeters meters: Double) -> Double {
        self == .metric ? meters / 1_000 : meters / Self.metersPerMile
    }
}
