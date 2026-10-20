import Foundation
import Testing
@testable import FitnessTracker

struct StreakCalculatorTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    private let today = Date(timeIntervalSince1970: 1_800_000_000)

    private func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: today) ?? today
    }

    @Test func noAchievedDaysIsZero() {
        #expect(StreakCalculator.currentStreak(achievedDays: [], today: today, calendar: calendar) == 0)
    }

    @Test func consecutiveDaysEndingTodayCount() {
        let days = [day(0), day(-1), day(-2)]
        #expect(StreakCalculator.currentStreak(achievedDays: days, today: today, calendar: calendar) == 3)
    }

    @Test func streakSurvivesUntilTodayIsOver() {
        let days = [day(-1), day(-2)]
        #expect(StreakCalculator.currentStreak(achievedDays: days, today: today, calendar: calendar) == 2)
    }

    @Test func gapBreaksTheStreak() {
        let days = [day(0), day(-1), day(-3)]
        #expect(StreakCalculator.currentStreak(achievedDays: days, today: today, calendar: calendar) == 2)
    }

    @Test func missingYesterdayAndTodayIsZero() {
        let days = [day(-2), day(-3)]
        #expect(StreakCalculator.currentStreak(achievedDays: days, today: today, calendar: calendar) == 0)
    }

    @Test func timesWithinADayCollapse() {
        let days = [day(0), day(0).addingTimeInterval(3_600), day(-1)]
        #expect(StreakCalculator.currentStreak(achievedDays: days, today: today, calendar: calendar) == 2)
    }

    @Test func daysAreOldestFirstAndCounted() {
        let days = StreakCalculator.days(endingOn: today, count: 3, calendar: calendar)
        #expect(days.count == 3)
        #expect(days == days.sorted())
        #expect(days.last == calendar.startOfDay(for: today))
    }

    @Test func zeroCountYieldsNoDays() {
        #expect(StreakCalculator.days(endingOn: today, count: 0, calendar: calendar).isEmpty)
    }
}
