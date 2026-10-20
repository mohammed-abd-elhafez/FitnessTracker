import Foundation
import os
import WidgetKit

/// Stores the latest `DailySnapshot` in the shared App Group and refreshes the widget.
/// Compiled into both the app and the widget extension.
struct AppGroupSnapshotStore: SnapshotPublishing {
    private static let key = "widget.dailySnapshot"
    private let suiteName: String

    init(suiteName: String = AppGroup.identifier) {
        self.suiteName = suiteName
    }

    func publish(_ snapshot: DailySnapshot) {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            Logger.storage.error("App Group \(suiteName) unavailable")
            return
        }
        do {
            defaults.set(try JSONEncoder().encode(snapshot), forKey: Self.key)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            Logger.storage.error("Snapshot encode failed: \(error.localizedDescription)")
        }
    }

    /// Latest published snapshot, if any.
    func read() -> DailySnapshot? {
        guard
            let data = UserDefaults(suiteName: suiteName)?.data(forKey: Self.key),
            let snapshot = try? JSONDecoder().decode(DailySnapshot.self, from: data)
        else { return nil }
        return snapshot
    }
}
