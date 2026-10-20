import SwiftUI

/// Stepper editing the daily target of one goal kind.
struct GoalStepperRow: View {
    let kind: GoalKind
    let value: Double
    let onChange: (Double) -> Void

    private var title: LocalizedStringKey {
        switch kind {
        case .steps: "today.steps"
        case .calories: "today.calories"
        case .activeMinutes: "today.activeMinutes"
        }
    }

    var body: some View {
        Stepper(
            value: Binding(get: { value }, set: onChange),
            in: kind.allowedRange,
            step: kind.step
        ) {
            HStack {
                Text(title)
                Spacer()
                Text(value, format: .number.precision(.fractionLength(0)))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .accessibilityElement(children: .combine)
    }
}
