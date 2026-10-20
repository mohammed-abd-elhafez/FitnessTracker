import SwiftUI

/// Progress tab: period picker, steps chart, average and streak.
struct ProgressTabView: View {
    @State private var viewModel: ProgressViewModel
    /// Changes whenever the tab is re-selected, so the data reloads.
    let reloadToken: Int

    init(viewModel: ProgressViewModel, reloadToken: Int = 0) {
        _viewModel = State(initialValue: viewModel)
        self.reloadToken = reloadToken
    }

    var body: some View {
        NavigationStack {
            content.navigationTitle("tab.progress")
        }
        .task(id: reloadToken) { await viewModel.load() }
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
        case .loaded where viewModel.hasNoData:
            EmptyStateView(
                title: "progress.empty.title", message: "progress.empty.message", systemImage: "chart.bar"
            )
        case .loaded:
            loaded
        }
    }

    private var loaded: some View {
        ScrollView {
            VStack(spacing: 16) {
                Picker("progress.period", selection: $viewModel.period) {
                    Text("progress.period.week").tag(ProgressPeriod.week)
                    Text("progress.period.month").tag(ProgressPeriod.month)
                }
                .pickerStyle(.segmented)
                StepsChart(points: viewModel.visiblePoints, goal: viewModel.stepGoal)
                HStack(spacing: 12) {
                    StatCard(title: "progress.average", value: viewModel.averageSteps.formatted(),
                             systemImage: "chart.line.uptrend.xyaxis")
                    StatCard(title: "progress.streak", value: viewModel.streak.formatted(),
                             systemImage: "flame")
                }
            }
            .padding(16)
        }
        .refreshable { await viewModel.load() }
    }
}
