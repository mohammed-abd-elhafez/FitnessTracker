import Foundation

/// The metric a daily goal tracks.
enum GoalKind: String, Codable, CaseIterable, Sendable {
    case steps, calories, activeMinutes
}

/// A daily target for one metric.
struct Goal: Identifiable, Equatable, Sendable {
    let id: UUID
    var kind: GoalKind
    var target: Double
    var createdAt: Date

    init(id: UUID = UUID(), kind: GoalKind, target: Double, createdAt: Date = .now) {
        self.id = id
        self.kind = kind
        self.target = target
        self.createdAt = createdAt
    }
}
