import SwiftUI

/// Shared layout for one onboarding step: icon, title, message, optional error and actions.
struct OnboardingPage<Actions: View>: View {
    let icon: String
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let error: String?
    let actions: Actions

    init(
        icon: String,
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        error: String? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.error = error
        self.actions = actions()
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            Text(title).font(.title.bold())
            Text(message).multilineTextAlignment(.center)
            if let error {
                Text(verbatim: error).font(.footnote).foregroundStyle(.red)
            }
            actions
        }
    }
}
