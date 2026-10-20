import Foundation

/// Consecutive-day streak logic.
enum StreakCalculator {
    /// `count` days ending on `date`, oldest first, normalized to start of day.
    static func days(endingOn date: Date, count: Int, calendar: Calendar = .current) -> [Date] {
        let end = calendar.startOfDay(for: date)
        return (0..<max(count, 0)).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: end)
        }
    }

    /// Length of the run of consecutive achieved days ending today.
    /// If today is not achieved yet, the run ending yesterday still counts, so a streak
    /// is not shown as broken before the day is over.
    static func currentStreak(achievedDays: [Date], today: Date, calendar: Calendar = .current) -> Int {
        let achieved = Set(achievedDays.map { calendar.startOfDay(for: $0) })
        var cursor = calendar.startOfDay(for: today)
        if !achieved.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else { return 0 }
            cursor = yesterday
        }
        var count = 0
        while achieved.contains(cursor) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return count
    }
}
