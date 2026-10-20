import Foundation
import Testing
@testable import FitnessTracker

struct SwiftDataWorkoutRepositoryTests {
    private func makeRepository() throws -> SwiftDataWorkoutRepository {
        SwiftDataWorkoutRepository(modelContainer: try PersistenceSchema.makeContainer(inMemory: true))
    }

    @Test func savedWorkoutIsReturned() async throws {
        let repo = try makeRepository()
        let workout = Workout(type: .yoga, startDate: .now, durationMinutes: 45, caloriesBurned: 150, notes: "calm")

        try await repo.save(workout)

        #expect(try await repo.allWorkouts() == [workout])
    }

    @Test func savingSameIdUpdatesInsteadOfDuplicating() async throws {
        let repo = try makeRepository()
        var workout = Workout(type: .running, startDate: .now, durationMinutes: 20)
        try await repo.save(workout)

        workout.durationMinutes = 40
        workout.type = .cycling
        try await repo.save(workout)

        let all = try await repo.allWorkouts()
        #expect(all.count == 1)
        #expect(all.first?.durationMinutes == 40)
        #expect(all.first?.type == .cycling)
    }

    @Test func setsRoundTripInOrderAndAreReplacedOnUpdate() async throws {
        let repo = try makeRepository()
        let first = ExerciseSet(name: "Squat", reps: 5, weightKg: 100)
        let second = ExerciseSet(name: "Bench", reps: 8, weightKg: 60)
        var workout = Workout(type: .strength, startDate: .now, durationMinutes: 50, sets: [first, second])
        try await repo.save(workout)
        #expect(try await repo.allWorkouts().first?.sets == [first, second])

        workout.sets = [second]
        try await repo.save(workout)
        #expect(try await repo.allWorkouts().first?.sets == [second])
    }

    @Test func deleteRemovesWorkout() async throws {
        let repo = try makeRepository()
        let workout = Workout(type: .walking, startDate: .now, durationMinutes: 10)
        try await repo.save(workout)

        try await repo.delete(id: workout.id)

        #expect(try await repo.allWorkouts().isEmpty)
    }

    @Test func workoutsOnDateFiltersByDay() async throws {
        let repo = try makeRepository()
        let today = Workout(type: .running, startDate: .now, durationMinutes: 30)
        let lastWeek = Workout(
            type: .running,
            startDate: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .distantPast,
            durationMinutes: 30
        )
        try await repo.save(today)
        try await repo.save(lastWeek)

        #expect(try await repo.workouts(on: .now) == [today])
    }

    @Test func latestWorkoutIsMostRecent() async throws {
        let repo = try makeRepository()
        let older = Workout(
            type: .yoga,
            startDate: Calendar.current.date(byAdding: .day, value: -2, to: .now) ?? .distantPast,
            durationMinutes: 30
        )
        let newer = Workout(type: .hiit, startDate: .now, durationMinutes: 20)
        try await repo.save(older)
        try await repo.save(newer)

        #expect(try await repo.latestWorkout() == newer)
    }
}
