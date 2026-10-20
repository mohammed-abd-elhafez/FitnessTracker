import Foundation
import Observation
import os

/// Drives the first-run flow: welcome, Health permission, daily step goal, reminders.
@MainActor
@Observable
final class OnboardingViewModel {
    enum Page { case welcome, health, goals, reminders }

    private(set) var page: Page = .welcome
    private(set) var isWorking = false
    private(set) var errorMessage: String?
    private(set) var isFinished = false
    /// Daily step goal chosen on the goals page.
    var stepTarget = 10_000.0

    private let health: any HealthDataRepository
    private let goalRepository: any GoalRepository
    private let scheduler: any NotificationScheduling
    private let reminderStore: any ReminderPreferencesStore
    private let store: any OnboardingStatusStore

    init(
        health: any HealthDataRepository,
        goals: any GoalRepository,
        scheduler: any NotificationScheduling,
        reminderStore: any ReminderPreferencesStore,
        store: any OnboardingStatusStore
    ) {
        self.health = health
        self.goalRepository = goals
        self.scheduler = scheduler
        self.reminderStore = reminderStore
        self.store = store
        self.isFinished = store.isCompleted
    }

    func next() {
        page = .health
    }

    /// Asks for Health access. On failure the user may retry or skip.
    func connectHealth() async {
        await run {
            try await health.requestAuthorization()
            page = .goals
        }
    }

    /// Continues without Health access (the app then shows "no data").
    func skipHealth() {
        errorMessage = nil
        page = .goals
    }

    /// Saves the chosen step goal and moves to the reminders page.
    func saveGoal() async {
        let range = GoalKind.steps.allowedRange
        let target = min(max(stepTarget, range.lowerBound), range.upperBound)
        await run {
            var goals = try await EnsureDefaultGoals.run(on: goalRepository)
            if let index = goals.firstIndex(where: { $0.kind == .steps }) {
                goals[index].target = target
                try await goalRepository.save(goals[index])
            }
            page = .reminders
        }
    }

    /// Requests notification permission and schedules the daily reminder if allowed.
    func enableReminders() async {
        await run {
            if try await scheduler.requestAuthorization() {
                var preferences = reminderStore.load()
                try await scheduler.scheduleDailyReminder(hour: preferences.hour, minute: preferences.minute)
                preferences.isEnabled = true
                reminderStore.save(preferences)
            }
            finish()
        }
    }

    func skipReminders() {
        finish()
    }

    private func run(_ work: () async throws -> Void) async {
        guard !isWorking else { return }
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do {
            try await work()
        } catch {
            Logger.ui.error("Onboarding step failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    private func finish() {
        store.markCompleted()
        isFinished = true
    }
}
