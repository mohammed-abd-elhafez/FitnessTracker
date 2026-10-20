import Foundation

/// Computes progress toward a daily goal.
enum GoalProgress {
    /// Fraction of `target` reached by `current`, clamped to `0...1`.
    /// A non-positive target yields `0`.
    static func fraction(current: Double, target: Double) -> Double {
        guard target > 0, current > 0 else { return 0 }
        return min(current / target, 1)
    }

    /// Whether `current` meets or exceeds a positive `target`.
    static func isAchieved(current: Double, target: Double) -> Bool {
        target > 0 && current >= target
    }
}
