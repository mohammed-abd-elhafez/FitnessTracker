import Foundation
import Testing
@testable import FitnessTracker

struct UnitSystemTests {
    @Test func metricWeightIsUnchanged() {
        #expect(UnitSystem.metric.weight(fromKilograms: 80) == 80)
        #expect(UnitSystem.metric.kilograms(fromWeight: 80) == 80)
    }

    @Test func imperialWeightConvertsBothWays() {
        let pounds = UnitSystem.imperial.weight(fromKilograms: 100)
        #expect(abs(pounds - 220.462) < 0.01)
        #expect(abs(UnitSystem.imperial.kilograms(fromWeight: pounds) - 100) < 1e-9)
    }

    @Test func distanceConvertsToKilometersAndMiles() {
        #expect(UnitSystem.metric.distance(fromMeters: 5_000) == 5)
        #expect(abs(UnitSystem.imperial.distance(fromMeters: 1_609.344) - 1) < 1e-9)
    }

    @Test func unknownStoredValueFallsBackToMetric() {
        #expect(UnitSystem(storedValue: "bogus") == .metric)
        #expect(UnitSystem(storedValue: "imperial") == .imperial)
    }
}
