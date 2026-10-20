import SwiftUI

extension WorkoutType {
    /// Localized display name (keys `workoutType.<rawValue>`).
    var title: LocalizedStringKey {
        LocalizedStringKey("workoutType.\(rawValue)")
    }

    /// SF Symbol representing the workout type.
    var systemImage: String {
        switch self {
        case .running: "figure.run"
        case .walking: "figure.walk"
        case .cycling: "figure.outdoor.cycle"
        case .strength: "dumbbell"
        case .yoga: "figure.yoga"
        case .swimming: "figure.pool.swim"
        case .hiit: "bolt.heart"
        case .other: "figure.mixed.cardio"
        }
    }
}
