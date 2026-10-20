import Foundation

/// Creates the starter daily goals when none exist yet.
enum EnsureDefaultGoals {
    static let defaults: [Goal] = [
        Goal(kind: .steps, target: 10_000),
        Goal(kind: .calories, target: 500),
        Goal(kind: .activeMinutes, target: 30)
    ]

    /// Returns the stored goals, seeding the defaults first if the store is empty.
    static func run(on repository: any GoalRepository) async throws -> [Goal] {
        let existing = try await repository.goals()
        guard existing.isEmpty else { return existing }
        for goal in defaults { try await repository.save(goal) }
        return defaults
    }
}
