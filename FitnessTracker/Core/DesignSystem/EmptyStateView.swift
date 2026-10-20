import SwiftUI

/// Placeholder for empty, error or not-yet-built screens, with an optional action.
struct EmptyStateView: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let systemImage: String
    var verbatimMessage: String?
    var actionTitle: LocalizedStringKey?
    var action: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            if let verbatimMessage {
                Text(verbatim: verbatimMessage)
            } else {
                Text(message)
            }
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    EmptyStateView(title: "workouts.empty.title", message: "workouts.empty.message", systemImage: "figure.run")
}
