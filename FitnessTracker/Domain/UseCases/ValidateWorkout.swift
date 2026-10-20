import Foundation

/// Reasons a workout can fail validation.
enum WorkoutValidationError: Error, Equatable, Sendable {
    case durationOutOfRange
    case startDateInFuture
    case notesTooLong
    case caloriesInvalid
    case invalidSet
}

/// Validates a workout before it is saved.
enum ValidateWorkout {
    static let durationRange = 1...1_440
    static let maxNotesLength = 500

    /// Returns every problem found; empty means valid.
    static func errors(in workout: Workout, now: Date = .now) -> [WorkoutValidationError] {
        var result: [WorkoutValidationError] = []
        if !durationRange.contains(workout.durationMinutes) {
            result.append(.durationOutOfRange)
        }
        if workout.startDate > now.addingTimeInterval(60) {
            result.append(.startDateInFuture)
        }
        if (workout.notes?.count ?? 0) > maxNotesLength {
            result.append(.notesTooLong)
        }
        if let calories = workout.caloriesBurned, !calories.isFinite || calories < 0 {
            result.append(.caloriesInvalid)
        }
        if workout.sets.contains(where: { !isValid($0) }) {
            result.append(.invalidSet)
        }
        return result
    }

    private static func isValid(_ set: ExerciseSet) -> Bool {
        !set.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && set.reps >= 1
            && set.weightKg.isFinite
            && set.weightKg >= 0
    }
}
