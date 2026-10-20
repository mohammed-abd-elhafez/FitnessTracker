import Foundation

extension WorkoutModel {
    convenience init(_ workout: Workout) {
        self.init(
            id: workout.id,
            typeRaw: workout.type.rawValue,
            startDate: workout.startDate,
            durationMinutes: workout.durationMinutes
        )
        apply(workout)
    }

    /// Copies scalar fields and replaces the sets. Old set models must be deleted by the caller.
    func apply(_ workout: Workout) {
        typeRaw = workout.type.rawValue
        startDate = workout.startDate
        durationMinutes = workout.durationMinutes
        caloriesBurned = workout.caloriesBurned
        notes = workout.notes
        sets = workout.sets.enumerated().map { index, set in
            ExerciseSetModel(
                id: set.id, position: index, name: set.name, reps: set.reps, weightKg: set.weightKg
            )
        }
    }

    var domain: Workout {
        Workout(
            id: id,
            type: WorkoutType(rawValue: typeRaw) ?? .other,
            startDate: startDate,
            durationMinutes: durationMinutes,
            caloriesBurned: caloriesBurned.flatMap { $0.isFinite && $0 >= 0 ? $0 : nil },
            notes: notes,
            sets: sets.sorted { $0.position < $1.position }.map {
                ExerciseSet(id: $0.id, name: $0.name, reps: $0.reps, weightKg: $0.weightKg)
            }
        )
    }
}

extension GoalModel {
    convenience init(_ goal: Goal) {
        self.init(id: goal.id, kindRaw: goal.kind.rawValue, target: goal.target, createdAt: goal.createdAt)
    }

    var domain: Goal? {
        guard let kind = GoalKind(rawValue: kindRaw) else { return nil }
        return Goal(id: id, kind: kind, target: target, createdAt: createdAt)
    }
}
