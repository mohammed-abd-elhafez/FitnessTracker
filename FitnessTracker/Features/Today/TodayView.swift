import SwiftUI

/// Today tab: goal rings, daily stats and the last workout.
struct TodayView: View {
    @State private var viewModel: DashboardViewModel
    /// Changes whenever the tab is re-selected, so the data reloads.
    let reloadToken: Int

    init(viewModel: DashboardViewModel, reloadToken: Int = 0) {
        _viewModel = State(initialValue: viewModel)
        self.reloadToken = reloadToken
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("today.title")
        }
        .task(id: reloadToken) { await viewModel.load() }
        .sensoryFeedback(.success, trigger: viewModel.achievedGoalCount) { old, new in new > old }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            EmptyStateView(
                title: "error.title",
                message: "error.title",
                verbatimMessage: message,
                systemImage: "exclamationmark.triangle",
                actionTitle: "common.retry",
                action: { Task { await viewModel.load() } }
            )
        case .loaded:
            loadedContent
        }
    }

    @ViewBuilder
    private var loadedContent: some View {
        if viewModel.hasNoActivity {
            EmptyStateView(
                title: "today.noData.title",
                message: "today.noData.message",
                systemImage: "figure.walk"
            )
        } else {
            ScrollView {
                VStack(spacing: 24) {
                    GoalRingsSection(viewModel: viewModel)
                    StatsSection(viewModel: viewModel)
                }
                .padding(16)
            }
            .refreshable { await viewModel.load() }
        }
    }
}
