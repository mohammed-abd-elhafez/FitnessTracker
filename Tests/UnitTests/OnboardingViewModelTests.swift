import Foundation
import Testing
@testable import FitnessTracker

@MainActor
struct OnboardingViewModelTests {
    private struct Fixture {
        let store: UserDefaultsOnboardingStore
        let goals: MockGoalRepository
        let scheduler: MockNotificationScheduler
        let reminders: InMemoryReminderStore
        let viewModel: OnboardingViewModel
    }

    private func makeFixture(
        health: MockHealthRepository = MockHealthRepository(),
        goals: MockGoalRepository = MockGoalRepository(),
        scheduler: MockNotificationScheduler = MockNotificationScheduler()
    ) -> Fixture {
        let suite = "test.onboarding.\(UUID().uuidString)"
        let store = UserDefaultsOnboardingStore(defaults: UserDefaults(suiteName: suite) ?? .standard, key: suite)
        let reminders = InMemoryReminderStore()
        let viewModel = OnboardingViewModel(
            health: health, goals: goals, scheduler: scheduler, reminderStore: reminders, store: store
        )
        return Fixture(store: store, goals: goals, scheduler: scheduler, reminders: reminders, viewModel: viewModel)
    }

    @Test func startsOnWelcomeAndNotFinished() {
        let vm = makeFixture().viewModel
        #expect(vm.page == .welcome)
        #expect(!vm.isFinished)
    }

    @Test func nextMovesToHealthPage() {
        let vm = makeFixture().viewModel
        vm.next()
        #expect(vm.page == .health)
    }

    @Test func connectHealthAdvancesToGoals() async {
        let vm = makeFixture().viewModel

        await vm.connectHealth()

        #expect(vm.page == .goals)
        #expect(vm.errorMessage == nil)
    }

    @Test func failedConnectStaysOnHealthWithMessage() async {
        let vm = makeFixture(health: MockHealthRepository(error: AppError.healthUnavailable)).viewModel
        vm.next()

        await vm.connectHealth()

        #expect(vm.page == .health)
        #expect(vm.errorMessage != nil)
        #expect(!vm.isFinished)
    }

    @Test func skipHealthAdvancesToGoals() {
        let vm = makeFixture().viewModel
        vm.skipHealth()
        #expect(vm.page == .goals)
    }

    @Test func saveGoalPersistsClampedStepTargetAndAdvances() async throws {
        let fixture = makeFixture()
        fixture.viewModel.stepTarget = 12_500

        await fixture.viewModel.saveGoal()

        let steps = try await fixture.goals.goals().first { $0.kind == .steps }
        #expect(steps?.target == 12_500)
        #expect(fixture.viewModel.page == .reminders)
    }

    @Test func saveGoalClampsOutOfRangeTarget() async throws {
        let fixture = makeFixture()
        fixture.viewModel.stepTarget = 10_000_000

        await fixture.viewModel.saveGoal()

        let steps = try await fixture.goals.goals().first { $0.kind == .steps }
        #expect(steps?.target == GoalKind.steps.allowedRange.upperBound)
    }

    @Test func enableRemindersSchedulesPersistsAndFinishes() async {
        let fixture = makeFixture()

        await fixture.viewModel.enableReminders()

        #expect(fixture.viewModel.isFinished)
        #expect(fixture.store.isCompleted)
        #expect(fixture.reminders.load().isEnabled)
        #expect(await fixture.scheduler.scheduled.count == 1)
    }

    @Test func deniedRemindersStillFinishWithoutScheduling() async {
        let fixture = makeFixture(scheduler: MockNotificationScheduler(grantsPermission: false))

        await fixture.viewModel.enableReminders()

        #expect(fixture.viewModel.isFinished)
        #expect(!fixture.reminders.load().isEnabled)
        #expect(await fixture.scheduler.scheduled.isEmpty)
    }

    @Test func reminderErrorKeepsOnboardingOpen() async {
        let fixture = makeFixture(scheduler: MockNotificationScheduler(error: AppError.notificationsUnavailable))

        await fixture.viewModel.enableReminders()

        #expect(!fixture.viewModel.isFinished)
        #expect(fixture.viewModel.errorMessage != nil)
    }

    @Test func skipRemindersFinishesAndPersists() {
        let fixture = makeFixture()

        fixture.viewModel.skipReminders()

        #expect(fixture.viewModel.isFinished)
        #expect(fixture.store.isCompleted)
    }

    @Test func completedStoreStartsFinished() {
        let fixture = makeFixture()
        fixture.store.markCompleted()
        let vm = OnboardingViewModel(
            health: MockHealthRepository(), goals: MockGoalRepository(),
            scheduler: MockNotificationScheduler(), reminderStore: InMemoryReminderStore(),
            store: fixture.store
        )
        #expect(vm.isFinished)
    }
}
