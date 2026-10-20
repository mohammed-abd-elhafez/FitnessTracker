import Foundation
import SwiftUI

extension UnitSystem {
    /// Reads the stored value, defaulting to metric.
    init(storedValue: String) {
        self = UnitSystem(rawValue: storedValue) ?? .metric
    }

    var weightUnitTitle: LocalizedStringKey {
        self == .metric ? "units.kg" : "units.lb"
    }

    var title: LocalizedStringKey {
        self == .metric ? "units.metric" : "units.imperial"
    }

    /// "5.2 km" or "3.2 mi".
    func distanceText(meters: Double) -> String {
        let value = distance(fromMeters: meters).formatted(.number.precision(.fractionLength(0...1)))
        let unit = String(localized: self == .metric ? "units.km" : "units.mi")
        return "\(value) \(unit)"
    }
}
