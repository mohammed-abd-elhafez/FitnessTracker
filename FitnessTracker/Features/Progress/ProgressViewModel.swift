import Foundation
import Observation
import os

/// Drives the Progress screen: daily steps over the last 30 days, goal line and streak.
@MainActor
@Observable
final class ProgressViewModel {
    static let historyDays = 30

    var period: ProgressPeriod = .week
    private(set) var points: [DailyStepsPoint] = []
    private(set) var stepGoal: Double?
    private(set) var state: LoadState = .idle

    private let health: any HealthDataRepository
    private let goalRepository: any GoalRepository
    private let calendar: Calendar
    private var today = Date.now

    init(health: any HealthDataRepository, goals: any GoalRepository, calendar: Calendar = .current) {
        self.health = health
        self.goalRepository = goals
        self.calendar = calendar
    }

    var visiblePoints: [DailyStepsPoint] {
        Array(points.suffix(period.dayCount))
    }

    var averageSteps: Int {
        let visible = visiblePoints
        guard !visible.isEmpty else { return 0 }
        return visible.reduce(0) { $0 + $1.steps } / visible.count
    }

    /// Current streak of days meeting the step goal (looks back at most `historyDays`).
    var streak: Int {
        guard let stepGoal, stepGoal > 0 else { return 0 }
        let achieved = points.filter { Double($0.steps) >= stepGoal }.map(\.date)
        return StreakCalculator.currentStreak(achievedDays: achieved, today: today, calendar: calendar)
    }

    var hasNoData: Bool {
        state == .loaded && points.allSatisfy { $0.steps == 0 }
    }

    /// Fetches the last 30 days of steps in parallel.
    func load(today: Date = .now) async {
        if state != .loaded { state = .loading }
        let health = health, goalRepository = goalRepository
        let days = StreakCalculator.days(endingOn: today, count: Self.historyDays, calendar: calendar)
        do {
            let goals = try await EnsureDefaultGoals.run(on: goalRepository)
            let fetched = try await withThrowingTaskGroup(of: DailyStepsPoint.self) { group in
                for day in days {
                    group.addTask { DailyStepsPoint(date: day, steps: try await health.steps(for: day)) }
                }
                var result: [DailyStepsPoint] = []
                for try await point in group { result.append(point) }
                return result
            }
            self.today = today
            points = fetched.sorted { $0.date < $1.date }
            stepGoal = goals.first { $0.kind == .steps }?.target
            state = .loaded
        } catch is CancellationError {
            if state == .loading { state = .idle }
        } catch {
            Logger.ui.error("Progress load failed: \(error.localizedDescription)")
            state = .failed(error.localizedDescription)
        }
    }
}
