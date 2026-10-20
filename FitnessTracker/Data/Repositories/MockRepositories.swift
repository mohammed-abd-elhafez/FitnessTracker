import Foundation

/// Fixed-value health repository used in previews and tests.
struct MockHealthRepository: HealthDataRepository {
    var stepCount = 8_500
    var energy = 420.0
    var meters = 5_200.0
    /// Per-day overrides keyed by start of day.
    var stepsByDay: [Date: Int] = [:]
    var error: AppError?

    func requestAuthorization() async throws {
        if let error { throw error }
    }

    func steps(for date: Date) async throws -> Int {
        if let error { throw error }
        return stepsByDay[Calendar.current.startOfDay(for: date)] ?? stepCount
    }

    func activeEnergy(for date: Date) async throws -> Double {
        if let error { throw error }
        return energy
    }

    func distance(for date: Date) async throws -> Double {
        if let error { throw error }
        return meters
    }
}

/// In-memory workout repository for previews and tests.
actor MockWorkoutRepository: WorkoutRepository {
    private var items: [Workout]
    private let error: AppError?

    init(items: [Workout] = [], error: AppError? = nil) {
        self.items = items
        self.error = error
    }

    func allWorkouts() async throws -> [Workout] {
        if let error { throw error }
        return items.sorted { $0.startDate > $1.startDate }
    }

    func workouts(on date: Date) async throws -> [Workout] {
        if let error { throw error }
        return items.filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
    }

    func latestWorkout() async throws -> Workout? {
        if let error { throw error }
        return items.max { $0.startDate < $1.startDate }
    }

    func save(_ workout: Workout) async throws {
        if let error { throw error }
        if let index = items.firstIndex(where: { $0.id == workout.id }) {
            items[index] = workout
        } else {
            items.append(workout)
        }
    }

    func delete(id: UUID) async throws {
        if let error { throw error }
        items.removeAll { $0.id == id }
    }
}

/// In-memory goal repository for previews and tests.
actor MockGoalRepository: GoalRepository {
    private var items: [Goal]
    private let error: AppError?

    init(items: [Goal] = [], error: AppError? = nil) {
        self.items = items
        self.error = error
    }

    func goals() async throws -> [Goal] {
        if let error { throw error }
        return items
    }

    func save(_ goal: Goal) async throws {
        if let error { throw error }
        if let index = items.firstIndex(where: { $0.id == goal.id }) {
            items[index] = goal
        } else {
            items.append(goal)
        }
    }

    func delete(id: UUID) async throws {
        if let error { throw error }
        items.removeAll { $0.id == id }
    }
}
