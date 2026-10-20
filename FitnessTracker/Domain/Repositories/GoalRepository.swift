import Foundation

/// Access to the user's daily goals.
protocol GoalRepository: Sendable {
    func goals() async throws -> [Goal]
    /// Inserts a new goal or updates the one with the same `id`.
    func save(_ goal: Goal) async throws
    func delete(id: UUID) async throws
}
