import Foundation
import os
import SwiftData

/// SwiftData-backed workout store. Runs on its own model actor.
@ModelActor
actor SwiftDataWorkoutRepository: WorkoutRepository {
    func allWorkouts() async throws -> [Workout] {
        let descriptor = FetchDescriptor<WorkoutModel>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        return try perform { try modelContext.fetch(descriptor).map(\.domain) }
    }

    func workouts(on date: Date) async throws -> [Workout] {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        let descriptor = FetchDescriptor<WorkoutModel>(
            predicate: #Predicate { $0.startDate >= start && $0.startDate < end },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return try perform { try modelContext.fetch(descriptor).map(\.domain) }
    }

    func latestWorkout() async throws -> Workout? {
        var descriptor = FetchDescriptor<WorkoutModel>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        descriptor.fetchLimit = 1
        return try perform { try modelContext.fetch(descriptor).first?.domain }
    }

    func save(_ workout: Workout) async throws {
        try perform {
            let id = workout.id
            let descriptor = FetchDescriptor<WorkoutModel>(predicate: #Predicate { $0.id == id })
            if let existing = try modelContext.fetch(descriptor).first {
                for old in existing.sets { modelContext.delete(old) }
                existing.apply(workout)
            } else {
                modelContext.insert(WorkoutModel(workout))
            }
            try modelContext.save()
        }
    }

    func delete(id: UUID) async throws {
        try perform {
            let descriptor = FetchDescriptor<WorkoutModel>(predicate: #Predicate { $0.id == id })
            for model in try modelContext.fetch(descriptor) { modelContext.delete(model) }
            try modelContext.save()
        }
    }

    private func perform<T>(_ work: () throws -> T) throws -> T {
        do {
            return try work()
        } catch {
            Logger.storage.error("Workout store failure: \(error.localizedDescription)")
            throw AppError.storageFailure
        }
    }
}
