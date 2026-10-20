import Foundation
import Testing
@testable import FitnessTracker

@MainActor
struct DashboardViewModelTests {
    private func makeViewModel(
        health: MockHealthRepository = MockHealthRepository(),
        workouts: MockWorkoutRepository = MockWorkoutRepository(),
        goals: MockGoalRepository = MockGoalRepository()
    ) -> DashboardViewModel {
        DashboardViewModel(health: health, workouts: workouts, goals: goals)
    }

    @Test func startsIdle() {
        #expect(makeViewModel().state == .idle)
    }

    @Test func loadPublishesMetricsOnSuccess() async {
        let workout = Workout(type: .running, startDate: .now, durationMinutes: 30)
        let vm = makeViewModel(
            health: MockHealthRepository(stepCount: 8_500, energy: 420),
            workouts: MockWorkoutRepository(items: [workout])
        )

        await vm.load()

        #expect(vm.steps == 8_500)
        #expect(vm.calories == 420)
        #expect(vm.workoutMinutes == 30)
        #expect(vm.lastWorkout == workout)
        #expect(vm.state == .loaded)
    }

    @Test func loadFailsWhenHealthThrows() async {
        let vm = makeViewModel(health: MockHealthRepository(error: AppError.healthUnavailable))

        await vm.load()

        #expect(vm.state == .failed(AppError.healthUnavailable.localizedDescription))
    }

    @Test func loadFailsWhenGoalsThrow() async {
        let vm = makeViewModel(goals: MockGoalRepository(error: AppError.storageFailure))

        await vm.load()

        #expect(vm.state == .failed(AppError.storageFailure.localizedDescription))
    }

    @Test func retryAfterFailureRecovers() async {
        let failing = makeViewModel(health: MockHealthRepository(error: AppError.healthUnavailable))
        await failing.load()
        let recovered = makeViewModel()
        await recovered.load()

        #expect(recovered.state == .loaded)
    }

    @Test func progressUsesMatchingGoal() async {
        let vm = makeViewModel(
            health: MockHealthRepository(stepCount: 5_000, energy: 0),
            goals: MockGoalRepository(items: [Goal(kind: .steps, target: 10_000)])
        )

        await vm.load()

        #expect(vm.progress(for: .steps) == 0.5)
        #expect(vm.progress(for: .calories) == nil)
    }

    @Test func noActivityIsFlaggedWhenEverythingIsZero() async {
        let vm = makeViewModel(health: MockHealthRepository(stepCount: 0, energy: 0))

        await vm.load()

        #expect(vm.hasNoActivity)
    }

    @Test func activityClearsNoActivityFlag() async {
        let vm = makeViewModel()

        await vm.load()

        #expect(!vm.hasNoActivity)
    }

    @Test func achievedGoalCountCountsMetGoals() async {
        let vm = makeViewModel(
            health: MockHealthRepository(stepCount: 10_000, energy: 100),
            goals: MockGoalRepository(items: [
                Goal(kind: .steps, target: 10_000),
                Goal(kind: .calories, target: 500)
            ])
        )

        await vm.load()

        #expect(vm.achievedGoalCount == 1)
    }

    @Test func defaultGoalsAreSeededWhenStoreIsEmpty() async {
        let vm = makeViewModel()

        await vm.load()

        #expect(vm.goals.count == EnsureDefaultGoals.defaults.count)
    }

    @Test func refreshKeepsLoadedContentVisible() async {
        let vm = makeViewModel()
        await vm.load()

        await vm.load()

        #expect(vm.state == .loaded)
    }

    @Test func loadPublishesDistance() async {
        let vm = makeViewModel(health: MockHealthRepository(meters: 3_200))

        await vm.load()

        #expect(vm.distanceMeters == 3_200)
    }

    @Test func loadPublishesSnapshotForToday() async {
        let spy = SpySnapshotPublisher()
        let vm = DashboardViewModel(
            health: MockHealthRepository(stepCount: 4_000, energy: 100),
            workouts: MockWorkoutRepository(),
            goals: MockGoalRepository(items: [Goal(kind: .steps, target: 8_000)]),
            snapshots: spy
        )

        await vm.load()

        let published = spy.published
        #expect(published.count == 1)
        #expect(published.first?.steps == 4_000)
        #expect(published.first?.stepFraction == 0.5)
    }

    @Test func loadForPastDayDoesNotPublish() async {
        let spy = SpySnapshotPublisher()
        let vm = DashboardViewModel(
            health: MockHealthRepository(), workouts: MockWorkoutRepository(),
            goals: MockGoalRepository(), snapshots: spy
        )
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .distantPast

        await vm.load(for: lastWeek)

        #expect(spy.published.isEmpty)
    }
}

final class SpySnapshotPublisher: SnapshotPublishing, @unchecked Sendable {
    private let lock = NSLock()
    private var items: [DailySnapshot] = []

    var published: [DailySnapshot] { lock.withLock { items } }

    func publish(_ snapshot: DailySnapshot) {
        lock.withLock { items.append(snapshot) }
    }
}
