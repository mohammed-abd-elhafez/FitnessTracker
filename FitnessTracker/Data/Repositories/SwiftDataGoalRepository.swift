import Foundation
import os
import SwiftData

/// SwiftData-backed goal store. Runs on its own model actor.
@ModelActor
actor SwiftDataGoalRepository: GoalRepository {
    func goals() async throws -> [Goal] {
        let descriptor = FetchDescriptor<GoalModel>(sortBy: [SortDescriptor(\.createdAt)])
        return try perform { try modelContext.fetch(descriptor).compactMap(\.domain) }
    }

    func save(_ goal: Goal) async throws {
        try perform {
            let id = goal.id
            let descriptor = FetchDescriptor<GoalModel>(predicate: #Predicate { $0.id == id })
            if let existing = try modelContext.fetch(descriptor).first {
                existing.kindRaw = goal.kind.rawValue
                existing.target = goal.target
            } else {
                modelContext.insert(GoalModel(goal))
            }
            try modelContext.save()
        }
    }

    func delete(id: UUID) async throws {
        try perform {
            let descriptor = FetchDescriptor<GoalModel>(predicate: #Predicate { $0.id == id })
            for model in try modelContext.fetch(descriptor) { modelContext.delete(model) }
            try modelContext.save()
        }
    }

    private func perform<T>(_ work: () throws -> T) throws -> T {
        do {
            return try work()
        } catch {
            Logger.storage.error("Goal store failure: \(error.localizedDescription)")
            throw AppError.storageFailure
        }
    }
}
