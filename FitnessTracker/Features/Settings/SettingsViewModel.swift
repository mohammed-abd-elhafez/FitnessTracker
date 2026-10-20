import Foundation
import Observation
import os

/// Drives Settings: daily goal targets and the workout reminder.
@MainActor
@Observable
final class SettingsViewModel {
    private(set) var goals: [Goal] = []
    private(set) var preferences: ReminderPreferences
    private(set) var permissionDenied = false
    private(set) var errorMessage: String?

    private let goalRepository: any GoalRepository
    private let scheduler: any NotificationScheduling
    private let store: any ReminderPreferencesStore
    private let calendar: Calendar

    init(
        goals: any GoalRepository,
        scheduler: any NotificationScheduling,
        store: any ReminderPreferencesStore,
        calendar: Calendar = .current
    ) {
        self.goalRepository = goals
        self.scheduler = scheduler
        self.store = store
        self.calendar = calendar
        self.preferences = store.load()
    }

    /// Reminder time as a `Date` (today at the stored hour and minute) for a time picker.
    var reminderDate: Date {
        calendar.date(from: DateComponents(hour: preferences.hour, minute: preferences.minute)) ?? .now
    }

    func load() async {
        do {
            goals = try await EnsureDefaultGoals.run(on: goalRepository)
        } catch {
            report(error)
        }
    }

    func target(for kind: GoalKind) -> Double {
        goals.first { $0.kind == kind }?.target ?? kind.allowedRange.lowerBound
    }

    /// Saves a new target for `kind`, clamped to the allowed range.
    func updateTarget(_ kind: GoalKind, to value: Double) async {
        let clamped = min(max(value, kind.allowedRange.lowerBound), kind.allowedRange.upperBound)
        var goal = goals.first { $0.kind == kind } ?? Goal(kind: kind, target: clamped)
        goal.target = clamped
        do {
            try await goalRepository.save(goal)
            if let index = goals.firstIndex(where: { $0.id == goal.id }) {
                goals[index] = goal
            } else {
                goals.append(goal)
            }
        } catch {
            report(error)
        }
    }

    /// Turns the reminder on (asking for permission first) or off.
    func setReminderEnabled(_ enabled: Bool) async {
        permissionDenied = false
        guard enabled else {
            preferences.isEnabled = false
            store.save(preferences)
            await scheduler.cancelDailyReminder()
            return
        }
        do {
            guard try await scheduler.requestAuthorization() else {
                permissionDenied = true
                return
            }
            try await scheduler.scheduleDailyReminder(hour: preferences.hour, minute: preferences.minute)
            preferences.isEnabled = true
            store.save(preferences)
        } catch {
            report(error)
        }
    }

    /// Changes the reminder time and reschedules if the reminder is on.
    func setReminderTime(_ date: Date) async {
        let previous = preferences
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        var updated = preferences
        updated.hour = parts.hour ?? updated.hour
        updated.minute = parts.minute ?? updated.minute
        guard updated.isEnabled else {
            preferences = updated
            store.save(updated)
            return
        }
        do {
            try await scheduler.scheduleDailyReminder(hour: updated.hour, minute: updated.minute)
            preferences = updated
            store.save(updated)
        } catch {
            preferences = previous
            report(error)
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    private func report(_ error: any Error) {
        Logger.ui.error("Settings operation failed: \(error.localizedDescription)")
        errorMessage = error.localizedDescription
    }
}
