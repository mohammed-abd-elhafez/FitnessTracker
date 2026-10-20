import Foundation

/// Access to logged workouts.
protocol WorkoutRepository: Sendable {
    /// All workouts, newest first.
    func allWorkouts() async throws -> [Workout]
    func workouts(on date: Date) async throws -> [Workout]
    func latestWorkout() async throws -> Workout?
    /// Inserts a new workout or updates the one with the same `id`.
    func save(_ workout: Workout) async throws
    func delete(id: UUID) async throws
}
