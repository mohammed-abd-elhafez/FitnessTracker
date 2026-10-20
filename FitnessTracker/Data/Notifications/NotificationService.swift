import Foundation
import os
import UserNotifications

/// `UserNotifications`-backed daily reminder.
struct NotificationService: NotificationScheduling, @unchecked Sendable {
    private static let reminderID = "daily-workout-reminder"
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async throws -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            Logger.ui.error("Notification authorization failed: \(error.localizedDescription)")
            throw AppError.notificationsUnavailable
        }
    }

    func scheduleDailyReminder(hour: Int, minute: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "reminder.title")
        content.body = String(localized: "reminder.body")
        content.sound = .default

        let components = DateComponents(hour: hour, minute: minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: Self.reminderID, content: content, trigger: trigger)

        do {
            // Adding a request with the same identifier replaces the previous request.
            // Keep the old request in place if the replacement fails.
            try await center.add(request)
        } catch {
            Logger.ui.error("Scheduling reminder failed: \(error.localizedDescription)")
            throw AppError.notificationsUnavailable
        }
    }

    func cancelDailyReminder() async {
        center.removePendingNotificationRequests(withIdentifiers: [Self.reminderID])
    }
}
