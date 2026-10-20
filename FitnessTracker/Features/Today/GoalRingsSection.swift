import SwiftUI

/// Row of progress rings, one per goal kind that has a goal set.
struct GoalRingsSection: View {
    let viewModel: DashboardViewModel

    private let items: [(kind: GoalKind, title: LocalizedStringKey)] = [
        (.steps, "today.steps"),
        (.calories, "today.calories"),
        (.activeMinutes, "today.activeMinutes")
    ]

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ForEach(items, id: \.kind) { item in
                if let progress = viewModel.progress(for: item.kind) {
                    VStack(spacing: 8) {
                        ProgressRing(progress: progress)
                            .frame(width: 88, height: 88)
                            .accessibilityLabel(Text(item.title))
                        Text(item.title)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
