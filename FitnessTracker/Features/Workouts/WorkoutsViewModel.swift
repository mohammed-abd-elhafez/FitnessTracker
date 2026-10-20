import Foundation
import Observation
import os

/// Drives the workout history list.
@MainActor
@Observable
final class WorkoutsViewModel {
    private(set) var workouts: [Workout] = []
    private(set) var state: LoadState = .idle

    private let repository: any WorkoutRepository
    private var operationGeneration = 0

    init(repository: any WorkoutRepository) {
        self.repository = repository
    }

    func load() async {
        operationGeneration += 1
        let generation = operationGeneration
        if workouts.isEmpty { state = .loading }
        do {
            let loaded = try await repository.allWorkouts()
            guard generation == operationGeneration else { return }
            workouts = loaded
            state = .loaded
        } catch is CancellationError {
            guard generation == operationGeneration else { return }
            state = workouts.isEmpty ? .idle : .loaded
        } catch {
            guard generation == operationGeneration else { return }
            Logger.ui.error("Workouts load failed: \(error.localizedDescription)")
            state = .failed(error.localizedDescription)
        }
    }

    func delete(id: UUID) async {
        operationGeneration += 1
        do {
            try await repository.delete(id: id)
            workouts.removeAll { $0.id == id }
        } catch {
            Logger.ui.error("Workout delete failed: \(error.localizedDescription)")
            state = .failed(error.localizedDescription)
        }
    }
}
