import Foundation

/// Read-only access to health metrics (HealthKit is the source of truth).
protocol HealthDataRepository: Sendable {
    func requestAuthorization() async throws
    func steps(for date: Date) async throws -> Int
    func activeEnergy(for date: Date) async throws -> Double
    /// Walking + running distance in meters.
    func distance(for date: Date) async throws -> Double
}
