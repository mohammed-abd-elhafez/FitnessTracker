import SwiftUI

/// Workouts tab: history list with add, edit and delete.
struct WorkoutsView: View {
    @State private var viewModel: WorkoutsViewModel
    @State private var presented: Workout?
    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        _viewModel = State(initialValue: container.makeWorkoutsViewModel())
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("tab.workouts")
                .toolbar {
                    Button("workouts.add", systemImage: "plus") {
                        presented = Workout(type: .running, startDate: .now, durationMinutes: 30)
                    }
                }
        }
        .task { await viewModel.load() }
        .sheet(item: $presented) { workout in
            WorkoutFormView(
                viewModel: container.makeWorkoutFormViewModel(
                    workout: workout,
                    isEditing: viewModel.workouts.contains { $0.id == workout.id }
                ),
                onSaved: { Task { await viewModel.load() } }
            )
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            EmptyStateView(
                title: "error.title", message: "error.title", verbatimMessage: message,
                systemImage: "exclamationmark.triangle",
                actionTitle: "common.retry", action: { Task { await viewModel.load() } }
            )
        case .loaded where viewModel.workouts.isEmpty:
            EmptyStateView(
                title: "workouts.empty.title", message: "workouts.empty.message", systemImage: "figure.run"
            )
        case .loaded:
            list
        }
    }

    private var list: some View {
        List {
            ForEach(viewModel.workouts) { workout in
                Button { presented = workout } label: { WorkoutRow(workout: workout) }
                    .buttonStyle(.plain)
            }
            .onDelete { offsets in
                let ids = offsets.map { viewModel.workouts[$0].id }
                Task { for id in ids { await viewModel.delete(id: id) } }
            }
        }
        .refreshable { await viewModel.load() }
    }
}
