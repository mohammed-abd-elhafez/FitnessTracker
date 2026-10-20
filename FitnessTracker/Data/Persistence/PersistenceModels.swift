import Foundation
import SwiftData

@Model
final class WorkoutModel {
    @Attribute(.unique) var id: UUID
    var typeRaw: String
    var startDate: Date
    var durationMinutes: Int
    var caloriesBurned: Double?
    var notes: String?
    @Relationship(deleteRule: .cascade, inverse: \ExerciseSetModel.workout)
    var sets: [ExerciseSetModel] = []

    init(id: UUID, typeRaw: String, startDate: Date, durationMinutes: Int) {
        self.id = id
        self.typeRaw = typeRaw
        self.startDate = startDate
        self.durationMinutes = durationMinutes
    }
}

@Model
final class ExerciseSetModel {
    var id: UUID
    var position: Int
    var name: String
    var reps: Int
    var weightKg: Double
    var workout: WorkoutModel?

    init(id: UUID, position: Int, name: String, reps: Int, weightKg: Double) {
        self.id = id
        self.position = position
        self.name = name
        self.reps = reps
        self.weightKg = weightKg
    }
}

@Model
final class GoalModel {
    @Attribute(.unique) var id: UUID
    var kindRaw: String
    var target: Double
    var createdAt: Date

    init(id: UUID, kindRaw: String, target: Double, createdAt: Date) {
        self.id = id
        self.kindRaw = kindRaw
        self.target = target
        self.createdAt = createdAt
    }
}

/// Builds the app's SwiftData container.
enum PersistenceSchema {
    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        return try ModelContainer(
            for: WorkoutModel.self, ExerciseSetModel.self, GoalModel.self,
            configurations: configuration
        )
    }
}
