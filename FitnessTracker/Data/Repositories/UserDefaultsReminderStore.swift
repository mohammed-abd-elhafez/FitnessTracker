import Foundation

/// `UserDefaults`-backed reminder preferences.
struct UserDefaultsReminderStore: ReminderPreferencesStore {
    var defaults: UserDefaults = .standard
    var prefix = "reminder."

    func load() -> ReminderPreferences {
        let fallback = ReminderPreferences()
        guard defaults.object(forKey: prefix + "hour") != nil else { return fallback }
        return ReminderPreferences(
            isEnabled: defaults.bool(forKey: prefix + "enabled"),
            hour: defaults.integer(forKey: prefix + "hour"),
            minute: defaults.integer(forKey: prefix + "minute")
        )
    }

    func save(_ preferences: ReminderPreferences) {
        defaults.set(preferences.isEnabled, forKey: prefix + "enabled")
        defaults.set(preferences.hour, forKey: prefix + "hour")
        defaults.set(preferences.minute, forKey: prefix + "minute")
    }
}
