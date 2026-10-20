import Foundation
import os

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "FitnessTracker"

    /// HealthKit access and queries.
    static let health = Logger(subsystem: subsystem, category: "health")
    /// Persistence layer.
    static let storage = Logger(subsystem: subsystem, category: "storage")
    /// View models and UI flow.
    static let ui = Logger(subsystem: subsystem, category: "ui")
}
