import Foundation
import Testing
@testable import FitnessTracker

struct SwiftDataGoalRepositoryTests {
    private func makeRepository() throws -> SwiftDataGoalRepository {
        SwiftDataGoalRepository(modelContainer: try PersistenceSchema.makeContainer(inMemory: true))
    }

    @Test func savedGoalIsReturned() async throws {
        let repo = try makeRepository()
        let goal = Goal(kind: .steps, target: 9_000)

        try await repo.save(goal)

        #expect(try await repo.goals().map(\.id) == [goal.id])
    }

    @Test func savingSameIdUpdatesTarget() async throws {
        let repo = try makeRepository()
        var goal = Goal(kind: .calories, target: 400)
        try await repo.save(goal)

        goal.target = 650
        try await repo.save(goal)

        let goals = try await repo.goals()
        #expect(goals.count == 1)
        #expect(goals.first?.target == 650)
    }

    @Test func deleteRemovesGoal() async throws {
        let repo = try makeRepository()
        let goal = Goal(kind: .activeMinutes, target: 30)
        try await repo.save(goal)

        try await repo.delete(id: goal.id)

        #expect(try await repo.goals().isEmpty)
    }

    @Test func ensureDefaultsSeedsOnlyOnce() async throws {
        let repo = try makeRepository()

        let first = try await EnsureDefaultGoals.run(on: repo)
        let second = try await EnsureDefaultGoals.run(on: repo)

        #expect(first.count == EnsureDefaultGoals.defaults.count)
        #expect(try await repo.goals().count == second.count)
        #expect(second.count == EnsureDefaultGoals.defaults.count)
    }
}
