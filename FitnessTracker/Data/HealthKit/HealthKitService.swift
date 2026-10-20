import Foundation
import HealthKit
import os

/// HealthKit-backed implementation of `HealthDataRepository` (read-only).
///
/// `HKHealthStore` is documented as thread-safe, hence `@unchecked Sendable`.
/// HealthKit never reveals whether *read* access was denied: a denied type simply
/// returns no data, so callers must treat zeros as "no data", not as an error.
struct HealthKitService: HealthDataRepository, @unchecked Sendable {
    private let store = HKHealthStore()

    private var readTypes: Set<HKObjectType> {
        [
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.activeEnergyBurned),
            HKObjectType.workoutType()
        ]
    }

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { throw AppError.healthUnavailable }
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
        } catch {
            Logger.health.error("Authorization failed: \(error.localizedDescription)")
            throw AppError.healthAccessDenied
        }
    }

    func steps(for date: Date) async throws -> Int {
        Int(try await dailySum(.stepCount, unit: .count(), on: date))
    }

    func activeEnergy(for date: Date) async throws -> Double {
        try await dailySum(.activeEnergyBurned, unit: .kilocalorie(), on: date)
    }

    func distance(for date: Date) async throws -> Double {
        try await dailySum(.distanceWalkingRunning, unit: .meter(), on: date)
    }

    private func dailySum(
        _ identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        on date: Date
    ) async throws -> Double {
        guard HKHealthStore.isHealthDataAvailable() else { throw AppError.healthUnavailable }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(type: HKQuantityType(identifier), predicate: predicate),
            options: .cumulativeSum
        )
        do {
            let statistics = try await descriptor.result(for: store)
            return statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as HKError where error.code == .errorNoData {
            return 0
        } catch let error as HKError where error.code == .errorAuthorizationDenied {
            throw AppError.healthAccessDenied
        } catch {
            Logger.health.error("Query failed: \(error.localizedDescription)")
            throw AppError.healthUnavailable
        }
    }
}
