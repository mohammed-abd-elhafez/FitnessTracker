import Foundation

/// Schedules the repeating daily workout reminder.
protocol NotificationScheduling: Sendable {
    /// Asks for permission; returns whether notifications are allowed.
    func requestAuthorization() async throws -> Bool
    /// Replaces any existing reminder with one firing daily at the given time.
    func scheduleDailyReminder(hour: Int, minute: Int) async throws
    func cancelDailyReminder() async
}

/// Persists `ReminderPreferences`.
protocol ReminderPreferencesStore: Sendable {
    func load() -> ReminderPreferences
    func save(_ preferences: ReminderPreferences)
}
