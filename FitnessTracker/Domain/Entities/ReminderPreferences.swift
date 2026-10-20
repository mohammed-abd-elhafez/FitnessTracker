import Foundation

/// User settings for the daily workout reminder.
struct ReminderPreferences: Equatable, Sendable {
    var isEnabled = false
    var hour = 18
    var minute = 0
}

extension GoalKind {
    /// Values the user may pick for a daily target of this kind.
    var allowedRange: ClosedRange<Double> {
        switch self {
        case .steps: 1_000...50_000
        case .calories: 50...5_000
        case .activeMinutes: 5...600
        }
    }

    /// Increment used by the target stepper.
    var step: Double {
        switch self {
        case .steps: 500
        case .calories: 50
        case .activeMinutes: 5
        }
    }
}
