import Foundation

/// Compact summary of today's progress shared with the home-screen widget.
struct DailySnapshot: Codable, Equatable, Sendable {
    var date: Date
    var steps: Int
    var stepGoal: Double
    var calories: Double
    var calorieGoal: Double

    var stepFraction: Double {
        GoalProgress.fraction(current: Double(steps), target: stepGoal)
    }

    var calorieFraction: Double {
        GoalProgress.fraction(current: calories, target: calorieGoal)
    }

    static let empty = DailySnapshot(date: .now, steps: 0, stepGoal: 10_000, calories: 0, calorieGoal: 500)
}
