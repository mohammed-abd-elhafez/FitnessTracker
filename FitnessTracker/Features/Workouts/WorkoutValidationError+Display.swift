import SwiftUI

extension WorkoutValidationError {
    /// Localized, user-facing explanation.
    var message: LocalizedStringKey {
        switch self {
        case .durationOutOfRange: "validation.duration"
        case .startDateInFuture: "validation.futureDate"
        case .notesTooLong: "validation.notesTooLong"
        case .caloriesInvalid: "validation.caloriesInvalid"
        case .invalidSet: "validation.invalidSet"
        }
    }
}
