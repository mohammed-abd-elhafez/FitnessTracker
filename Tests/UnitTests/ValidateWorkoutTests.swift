import Foundation
import Testing
@testable import FitnessTracker

struct ValidateWorkoutTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func workout(
        minutes: Int = 30,
        start: Date? = nil,
        notes: String? = nil,
        sets: [ExerciseSet] = []
    ) -> Workout {
        Workout(type: .strength, startDate: start ?? now, durationMinutes: minutes, notes: notes, sets: sets)
    }

    @Test func validWorkoutHasNoErrors() {
        #expect(ValidateWorkout.errors(in: workout(), now: now).isEmpty)
    }

    @Test(arguments: [0, -5, 1_441])
    func durationOutOfRangeIsRejected(minutes: Int) {
        #expect(ValidateWorkout.errors(in: workout(minutes: minutes), now: now) == [.durationOutOfRange])
    }

    @Test func futureStartIsRejected() {
        let future = now.addingTimeInterval(3_600)
        #expect(ValidateWorkout.errors(in: workout(start: future), now: now) == [.startDateInFuture])
    }

    @Test func tinyClockSkewIsAllowed() {
        let almostNow = now.addingTimeInterval(30)
        #expect(ValidateWorkout.errors(in: workout(start: almostNow), now: now).isEmpty)
    }

    @Test func longNotesAreRejected() {
        let notes = String(repeating: "a", count: ValidateWorkout.maxNotesLength + 1)
        #expect(ValidateWorkout.errors(in: workout(notes: notes), now: now) == [.notesTooLong])
    }

    @Test(arguments: [-1.0, .infinity, -.infinity, .nan])
    func invalidCaloriesAreRejected(calories: Double) {
        let draft = Workout(
            type: .running, startDate: now, durationMinutes: 30, caloriesBurned: calories
        )
        #expect(ValidateWorkout.errors(in: draft, now: now) == [.caloriesInvalid])
    }

    @Test func invalidSetsAreRejected() {
        let bad = [
            ExerciseSet(name: "  ", reps: 5, weightKg: 10),
            ExerciseSet(name: "Squat", reps: 0, weightKg: 10),
            ExerciseSet(name: "Squat", reps: 5, weightKg: -1)
        ]
        for set in bad {
            #expect(ValidateWorkout.errors(in: workout(sets: [set]), now: now) == [.invalidSet])
        }
    }

    @Test func validSetIsAccepted() {
        let set = ExerciseSet(name: "Squat", reps: 5, weightKg: 100)
        #expect(ValidateWorkout.errors(in: workout(sets: [set]), now: now).isEmpty)
    }
}
