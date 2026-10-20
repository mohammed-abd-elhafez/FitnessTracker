import Foundation
import Observation
import os

/// Drives the add/edit workout form.
@MainActor
@Observable
final class WorkoutFormViewModel {
    var draft: Workout
    let isEditing: Bool
    private(set) var errors: [WorkoutValidationError] = []
    private(set) var saveError: String?
    private(set) var isSaving = false

    private let repository: any WorkoutRepository

    init(workout: Workout, isEditing: Bool, repository: any WorkoutRepository) {
        self.draft = workout
        self.isEditing = isEditing
        self.repository = repository
    }

    /// Notes as non-optional text for binding; empty maps back to `nil`.
    var notesText: String {
        get { draft.notes ?? "" }
        set { draft.notes = newValue.isEmpty ? nil : newValue }
    }

    func addSet() {
        draft.sets.append(ExerciseSet())
    }

    func removeSets(at offsets: IndexSet) {
        draft.sets.remove(atOffsets: offsets)
    }

    /// Validates and saves. Returns `true` on success.
    func save() async -> Bool {
        errors = ValidateWorkout.errors(in: draft)
        saveError = nil
        guard errors.isEmpty, !isSaving else { return false }
        isSaving = true
        defer { isSaving = false }
        do {
            try await repository.save(draft)
            return true
        } catch {
            Logger.ui.error("Workout save failed: \(error.localizedDescription)")
            saveError = error.localizedDescription
            return false
        }
    }
}
