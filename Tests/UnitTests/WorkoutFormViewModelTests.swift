import Foundation
import Testing
@testable import FitnessTracker

@MainActor
struct WorkoutFormViewModelTests {
    private func makeViewModel(
        workout: Workout = Workout(type: .running, startDate: .now, durationMinutes: 30),
        repository: MockWorkoutRepository = MockWorkoutRepository()
    ) -> WorkoutFormViewModel {
        WorkoutFormViewModel(workout: workout, isEditing: false, repository: repository)
    }

    @Test func validDraftSaves() async throws {
        let repo = MockWorkoutRepository()
        let vm = makeViewModel(repository: repo)

        let saved = await vm.save()

        #expect(saved)
        #expect(try await repo.allWorkouts().count == 1)
    }

    @Test func invalidDraftIsNotSaved() async throws {
        let repo = MockWorkoutRepository()
        let vm = makeViewModel(
            workout: Workout(type: .running, startDate: .now, durationMinutes: 0),
            repository: repo
        )

        let saved = await vm.save()

        #expect(!saved)
        #expect(vm.errors == [.durationOutOfRange])
        #expect(try await repo.allWorkouts().isEmpty)
    }

    @Test func repositoryFailureSurfacesError() async {
        let vm = makeViewModel(repository: MockWorkoutRepository(error: AppError.storageFailure))

        let saved = await vm.save()

        #expect(!saved)
        #expect(vm.saveError != nil)
    }

    @Test func emptyNotesMapToNil() {
        let vm = makeViewModel()
        vm.notesText = "hello"
        #expect(vm.draft.notes == "hello")
        vm.notesText = ""
        #expect(vm.draft.notes == nil)
    }

    @Test func addAndRemoveSets() {
        let vm = makeViewModel()
        vm.addSet()
        vm.addSet()
        #expect(vm.draft.sets.count == 2)
        vm.removeSets(at: IndexSet(integer: 0))
        #expect(vm.draft.sets.count == 1)
    }
}
