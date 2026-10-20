import SwiftUI

/// First-run flow explaining the app, requesting Health access, setting a goal and reminders.
struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel
    private let onFinish: () -> Void

    init(viewModel: OnboardingViewModel, onFinish: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onFinish = onFinish
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            switch viewModel.page {
            case .welcome:
                OnboardingPage(icon: "figure.run.circle.fill", title: "onboarding.welcome.title",
                               message: "onboarding.welcome.message") {
                    PrimaryButton(title: "onboarding.continue") { viewModel.next() }
                }
            case .health:
                OnboardingPage(icon: "heart.text.square", title: "onboarding.health.title",
                               message: "onboarding.health.message", error: viewModel.errorMessage) {
                    PrimaryButton(title: "onboarding.health.connect", isDisabled: viewModel.isWorking) {
                        Task { await viewModel.connectHealth() }
                    }
                    Button("onboarding.skip") { viewModel.skipHealth() }
                }
            case .goals:
                goalsPage
            case .reminders:
                OnboardingPage(icon: "bell.badge", title: "onboarding.reminders.title",
                               message: "onboarding.reminders.message", error: viewModel.errorMessage) {
                    PrimaryButton(title: "onboarding.reminders.enable", isDisabled: viewModel.isWorking) {
                        Task { await viewModel.enableReminders() }
                    }
                    Button("onboarding.skip") { viewModel.skipReminders() }
                }
            }
            Spacer()
        }
        .padding(24)
        .onChange(of: viewModel.isFinished) { _, finished in
            if finished { onFinish() }
        }
    }

    private var goalsPage: some View {
        OnboardingPage(icon: "target", title: "onboarding.goals.title",
                       message: "onboarding.goals.message", error: viewModel.errorMessage) {
            Stepper(value: $viewModel.stepTarget, in: GoalKind.steps.allowedRange, step: GoalKind.steps.step) {
                HStack {
                    Text("today.steps")
                    Spacer()
                    Text(viewModel.stepTarget, format: .number.precision(.fractionLength(0)))
                        .monospacedDigit()
                }
            }
            PrimaryButton(title: "onboarding.continue", isDisabled: viewModel.isWorking) {
                Task { await viewModel.saveGoal() }
            }
        }
    }
}
