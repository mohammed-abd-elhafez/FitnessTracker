import Foundation
import Testing
@testable import FitnessTracker

@MainActor
struct WorkoutsViewModelTests {
    @Test func loadPublishesWorkoutsNewestFirst() async {
        let older = Workout(type: .yoga, startDate: .now.addingTimeInterval(-3_600), durationMinutes: 20)
        let newer = Workout(type: .hiit, startDate: .now, durationMinutes: 15)
        let vm = WorkoutsViewModel(repository: MockWorkoutRepository(items: [older, newer]))

        await vm.load()

        #expect(vm.workouts == [newer, older])
        #expect(vm.state == .loaded)
    }

    @Test func deleteRemovesWorkout() async {
        let workout = Workout(type: .walking, startDate: .now, durationMinutes: 10)
        let vm = WorkoutsViewModel(repository: MockWorkoutRepository(items: [workout]))
        await vm.load()

        await vm.delete(id: workout.id)

        #expect(vm.workouts.isEmpty)
    }

    @Test func loadFailureSetsFailedState() async {
        let vm = WorkoutsViewModel(repository: MockWorkoutRepository(error: AppError.storageFailure))

        await vm.load()

        #expect(vm.state == .failed(AppError.storageFailure.localizedDescription))
    }
}
