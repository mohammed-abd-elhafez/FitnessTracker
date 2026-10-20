import Foundation
import Testing
@testable import FitnessTracker

@MainActor
struct ProgressViewModelTests {
    private func makeViewModel(
        health: MockHealthRepository = MockHealthRepository(stepCount: 12_000),
        goals: MockGoalRepository = MockGoalRepository(items: [Goal(kind: .steps, target: 10_000)])
    ) -> ProgressViewModel {
        ProgressViewModel(health: health, goals: goals)
    }

    @Test func loadFetchesThirtyDaysOldestFirst() async {
        let vm = makeViewModel()

        await vm.load()

        #expect(vm.points.count == ProgressViewModel.historyDays)
        #expect(vm.points == vm.points.sorted { $0.date < $1.date })
        #expect(vm.state == .loaded)
    }

    @Test func periodControlsVisiblePoints() async {
        let vm = makeViewModel()
        await vm.load()

        vm.period = .week
        #expect(vm.visiblePoints.count == 7)
        vm.period = .month
        #expect(vm.visiblePoints.count == 30)
    }

    @Test func streakCountsAllDaysWhenEveryDayMeetsGoal() async {
        let vm = makeViewModel()

        await vm.load()

        #expect(vm.streak == ProgressViewModel.historyDays)
    }

    @Test func streakIsZeroWhenGoalNeverMet() async {
        let vm = makeViewModel(health: MockHealthRepository(stepCount: 100))

        await vm.load()

        #expect(vm.streak == 0)
    }

    @Test func averageUsesVisiblePeriod() async {
        let vm = makeViewModel(health: MockHealthRepository(stepCount: 6_000))

        await vm.load()

        #expect(vm.averageSteps == 6_000)
    }

    @Test func allZeroStepsMeansNoData() async {
        let vm = makeViewModel(health: MockHealthRepository(stepCount: 0))

        await vm.load()

        #expect(vm.hasNoData)
    }

    @Test func failureSetsFailedState() async {
        let vm = makeViewModel(health: MockHealthRepository(error: AppError.healthUnavailable))

        await vm.load()

        #expect(vm.state == .failed(AppError.healthUnavailable.localizedDescription))
    }
}
