import Foundation

/// One set of an exercise within a strength workout.
struct ExerciseSet: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var reps: Int
    var weightKg: Double

    init(id: UUID = UUID(), name: String = "", reps: Int = 10, weightKg: Double = 0) {
        self.id = id
        self.name = name
        self.reps = reps
        self.weightKg = weightKg
    }
}
