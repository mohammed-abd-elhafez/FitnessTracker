import Testing
@testable import FitnessTracker

struct GoalProgressTests {
    @Test func zeroCurrentIsZero() {
        #expect(GoalProgress.fraction(current: 0, target: 100) == 0)
    }

    @Test func halfwayIsHalf() {
        #expect(GoalProgress.fraction(current: 5_000, target: 10_000) == 0.5)
    }

    @Test func exceedingTargetClampsToOne() {
        #expect(GoalProgress.fraction(current: 15_000, target: 10_000) == 1)
    }

    @Test func nonPositiveTargetIsZero() {
        #expect(GoalProgress.fraction(current: 100, target: 0) == 0)
        #expect(GoalProgress.fraction(current: 100, target: -5) == 0)
    }

    @Test func negativeCurrentIsZero() {
        #expect(GoalProgress.fraction(current: -10, target: 100) == 0)
    }

    @Test func achievedOnlyWhenTargetMet() {
        #expect(GoalProgress.isAchieved(current: 10, target: 10))
        #expect(!GoalProgress.isAchieved(current: 9, target: 10))
        #expect(!GoalProgress.isAchieved(current: 10, target: 0))
    }
}
