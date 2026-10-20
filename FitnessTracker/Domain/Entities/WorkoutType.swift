import Foundation

/// Kinds of workout a user can log.
enum WorkoutType: String, Codable, CaseIterable, Sendable {
    case running, walking, cycling, strength, yoga, swimming, hiit, other
}
