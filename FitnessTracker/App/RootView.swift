import SwiftUI

/// Onboarding on first launch, then the four-tab shell: Today, Workouts, Progress, Settings.
struct RootView: View {
    private enum Tab: Hashable { case today, workouts, progress, settings }

    let container: AppContainer
    @State private var showsOnboarding: Bool
    @State private var selection: Tab = .today
    @State private var reloadToken = 0

    init(container: AppContainer) {
        self.container = container
        _showsOnboarding = State(initialValue: !container.onboarding.isCompleted)
    }

    var body: some View {
        if container.storageError != nil {
            EmptyStateView(
                title: "error.title",
                message: "error.storageFailure",
                systemImage: "externaldrive.badge.exclamationmark"
            )
            .padding()
        } else if showsOnboarding {
            OnboardingView(viewModel: container.makeOnboardingViewModel()) {
                showsOnboarding = false
            }
        } else {
            tabs
        }
    }

    private var tabs: some View {
        TabView(selection: $selection) {
            TodayView(viewModel: container.makeDashboardViewModel(), reloadToken: reloadToken)
                .tabItem { Label("tab.today", systemImage: "sun.max") }
                .tag(Tab.today)
            WorkoutsView(container: container)
                .tabItem { Label("tab.workouts", systemImage: "figure.run") }
                .tag(Tab.workouts)
            ProgressTabView(viewModel: container.makeProgressViewModel(), reloadToken: reloadToken)
                .tabItem { Label("tab.progress", systemImage: "chart.bar") }
                .tag(Tab.progress)
            SettingsView(viewModel: container.makeSettingsViewModel())
                .tabItem { Label("tab.settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        .onChange(of: selection) { reloadToken += 1 }
    }
}

#Preview {
    RootView(container: .mock())
}
