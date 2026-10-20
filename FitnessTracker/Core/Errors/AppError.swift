import Foundation

/// Unified error type surfaced to the UI.
enum AppError: Error, Equatable, Sendable {
    case healthUnavailable
    case healthAccessDenied
    case storageFailure
    case networkUnavailable
    case notificationsUnavailable
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .healthUnavailable:
            String(localized: "error.healthUnavailable")
        case .healthAccessDenied:
            String(localized: "error.healthAccessDenied")
        case .storageFailure:
            String(localized: "error.storageFailure")
        case .networkUnavailable:
            String(localized: "error.networkUnavailable")
        case .notificationsUnavailable:
            String(localized: "error.notificationsUnavailable")
        }
    }
}
