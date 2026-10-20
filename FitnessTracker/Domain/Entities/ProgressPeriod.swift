import Foundation

/// Time window shown on the Progress screen.
enum ProgressPeriod: CaseIterable, Hashable, Sendable {
    case week, month

    var dayCount: Int {
        switch self {
        case .week: 7
        case .month: 30
        }
    }
}

/// Step total for one calendar day.
struct DailyStepsPoint: Identifiable, Equatable, Sendable {
    let date: Date
    let steps: Int

    var id: Date { date }
}
