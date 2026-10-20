import Foundation

/// Records scheduling calls; used in previews and tests.
actor MockNotificationScheduler: NotificationScheduling {
    private let grantsPermission: Bool
    private let error: AppError?
    private(set) var scheduled: [DateComponents] = []
    private(set) var cancelCount = 0

    init(grantsPermission: Bool = true, error: AppError? = nil) {
        self.grantsPermission = grantsPermission
        self.error = error
    }

    func requestAuthorization() async throws -> Bool {
        if let error { throw error }
        return grantsPermission
    }

    func scheduleDailyReminder(hour: Int, minute: Int) async throws {
        if let error { throw error }
        scheduled.append(DateComponents(hour: hour, minute: minute))
    }

    func cancelDailyReminder() async {
        cancelCount += 1
    }
}

/// In-memory reminder preferences for previews and tests.
final class InMemoryReminderStore: ReminderPreferencesStore, @unchecked Sendable {
    private let lock = NSLock()
    private var preferences: ReminderPreferences

    init(_ preferences: ReminderPreferences = ReminderPreferences()) {
        self.preferences = preferences
    }

    func load() -> ReminderPreferences {
        lock.withLock { preferences }
    }

    func save(_ preferences: ReminderPreferences) {
        lock.withLock { self.preferences = preferences }
    }
}
