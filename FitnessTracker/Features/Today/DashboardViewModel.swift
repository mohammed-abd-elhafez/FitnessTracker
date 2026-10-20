import Foundation
import Observation
import os

/// Loading state shared by data-driven screens.
enum LoadState: Equatable {
    case idle, loading, loaded
    case failed(String)
}

/// Drives the Today screen from health, workout and goal repositories.
@MainActor
@Observable
final class DashboardViewModel {
    private(set) var steps = 0
    private(set) var calories = 0.0
    private(set) var distanceMeters = 0.0
    private(set) var workoutMinutes = 0
    private(set) var goals: [Goal] = []
    private(set) var lastWorkout: Workout?
    private(set) var state: LoadState = .idle

    private var isLoading = false

    private let health: any HealthDataRepository
    private let workouts: any WorkoutRepository
    private let goalRepository: any GoalRepository
    private let snapshots: (any SnapshotPublishing)?

    init(
        health: any HealthDataRepository,
        workouts: any WorkoutRepository,
        goals: any GoalRepository,
        snapshots: (any SnapshotPublishing)? = nil
    ) {
        self.health = health
        self.workouts = workouts
        self.goalRepository = goals
        self.snapshots = snapshots
    }

    /// `true` when loaded but there is no activity to show.
    var hasNoActivity: Bool {
        state == .loaded && steps == 0 && calories == 0 && distanceMeters == 0 && workoutMinutes == 0
    }

    /// Loads today's metrics in parallel. Any failure moves the state to `.failed`.
    /// Overlapping calls are ignored; cancellation leaves the previous content untouched.
    func load(for date: Date = .now) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        if state != .loaded { state = .loading }
        let health = health, workouts = workouts, goalRepository = goalRepository
        do {
            async let steps = health.steps(for: date)
            async let energy = health.activeEnergy(for: date)
            async let distance = health.distance(for: date)
            async let todays = workouts.workouts(on: date)
            async let latest = workouts.latestWorkout()
            async let goals = EnsureDefaultGoals.run(on: goalRepository)
            let result = try await (steps, energy, todays, latest, goals, distance)

            self.steps = result.0
            self.calories = result.1
            self.workoutMinutes = result.2.reduce(0) { $0 + $1.durationMinutes }
            self.lastWorkout = result.3
            self.goals = result.4
            self.distanceMeters = result.5
            state = .loaded
            publishSnapshot(for: date)
        } catch is CancellationError {
            if state == .loading { state = .idle }
        } catch {
            Logger.ui.error("Dashboard load failed: \(error.localizedDescription)")
            state = .failed(error.localizedDescription)
        }
    }

    /// Progress (`0...1`) toward the goal of `kind`, or `nil` if no goal is set.
    func progress(for kind: GoalKind) -> Double? {
        guard let goal = goals.first(where: { $0.kind == kind }) else { return nil }
        return GoalProgress.fraction(current: currentValue(for: kind), target: goal.target)
    }

    private func publishSnapshot(for date: Date) {
        guard let snapshots, Calendar.current.isDateInToday(date) else { return }
        func target(_ kind: GoalKind) -> Double { goals.first { $0.kind == kind }?.target ?? 0 }
        snapshots.publish(DailySnapshot(
            date: date,
            steps: steps,
            stepGoal: target(.steps),
            calories: calories,
            calorieGoal: target(.calories)
        ))
    }

    /// Number of goals currently met; drives the success haptic.
    var achievedGoalCount: Int {
        goals.filter {
            GoalProgress.isAchieved(current: currentValue(for: $0.kind), target: $0.target)
        }.count
    }

    private func currentValue(for kind: GoalKind) -> Double {
        switch kind {
        case .steps: Double(steps)
        case .calories: calories
        case .activeMinutes: Double(workoutMinutes)
        }
    }
}
