import Foundation

/// A logged workout session.
struct Workout: Identifiable, Equatable, Sendable {
    let id: UUID
    var type: WorkoutType
    var startDate: Date
    var durationMinutes: Int
    var caloriesBurned: Double?
    var notes: String?
    var sets: [ExerciseSet]

    init(
        id: UUID = UUID(),
        type: WorkoutType,
        startDate: Date,
        durationMinutes: Int,
        caloriesBurned: Double? = nil,
        notes: String? = nil,
        sets: [ExerciseSet] = []
    ) {
        self.id = id
        self.type = type
        self.startDate = startDate
        self.durationMinutes = durationMinutes
        self.caloriesBurned = caloriesBurned
        self.notes = notes
        self.sets = sets
    }
}
