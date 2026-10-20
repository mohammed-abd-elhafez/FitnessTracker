import Foundation
import Testing
@testable import FitnessTracker

@MainActor
struct SettingsViewModelTests {
    private func makeViewModel(
        goals: MockGoalRepository = MockGoalRepository(),
        scheduler: MockNotificationScheduler = MockNotificationScheduler(),
        store: InMemoryReminderStore = InMemoryReminderStore()
    ) -> SettingsViewModel {
        SettingsViewModel(goals: goals, scheduler: scheduler, store: store)
    }

    @Test func loadSeedsDefaultGoals() async {
        let vm = makeViewModel()
        await vm.load()
        #expect(vm.goals.count == EnsureDefaultGoals.defaults.count)
    }

    @Test func updateTargetSavesAndPublishes() async {
        let vm = makeViewModel()
        await vm.load()

        await vm.updateTarget(.steps, to: 12_000)

        #expect(vm.target(for: .steps) == 12_000)
    }

    @Test func updateTargetClampsToAllowedRange() async {
        let vm = makeViewModel()
        await vm.load()

        await vm.updateTarget(.steps, to: 1_000_000)
        #expect(vm.target(for: .steps) == GoalKind.steps.allowedRange.upperBound)

        await vm.updateTarget(.steps, to: 1)
        #expect(vm.target(for: .steps) == GoalKind.steps.allowedRange.lowerBound)
    }

    @Test func enablingReminderSchedulesAndPersists() async {
        let scheduler = MockNotificationScheduler()
        let store = InMemoryReminderStore()
        let vm = makeViewModel(scheduler: scheduler, store: store)

        await vm.setReminderEnabled(true)

        #expect(vm.preferences.isEnabled)
        #expect(store.load().isEnabled)
        #expect(await scheduler.scheduled.count == 1)
    }

    @Test func deniedPermissionDoesNotEnableReminder() async {
        let scheduler = MockNotificationScheduler(grantsPermission: false)
        let vm = makeViewModel(scheduler: scheduler)

        await vm.setReminderEnabled(true)

        #expect(!vm.preferences.isEnabled)
        #expect(vm.permissionDenied)
        #expect(await scheduler.scheduled.isEmpty)
    }

    @Test func disablingReminderCancelsIt() async {
        let scheduler = MockNotificationScheduler()
        let vm = makeViewModel(scheduler: scheduler)
        await vm.setReminderEnabled(true)

        await vm.setReminderEnabled(false)

        #expect(!vm.preferences.isEnabled)
        #expect(await scheduler.cancelCount == 1)
    }

    @Test func changingTimeReschedulesWhenEnabled() async {
        let scheduler = MockNotificationScheduler()
        let vm = makeViewModel(scheduler: scheduler)
        await vm.setReminderEnabled(true)
        let newTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 30)) ?? .now

        await vm.setReminderTime(newTime)

        #expect(vm.preferences.hour == 7)
        #expect(vm.preferences.minute == 30)
        #expect(await scheduler.scheduled.last == DateComponents(hour: 7, minute: 30))
    }

    @Test func changingTimeWhileDisabledOnlyPersists() async {
        let scheduler = MockNotificationScheduler()
        let store = InMemoryReminderStore()
        let vm = makeViewModel(scheduler: scheduler, store: store)
        let newTime = Calendar.current.date(from: DateComponents(hour: 6, minute: 15)) ?? .now

        await vm.setReminderTime(newTime)

        #expect(store.load().hour == 6)
        #expect(await scheduler.scheduled.isEmpty)
    }

    @Test func failedRescheduleKeepsPreviousTime() async {
        let scheduler = MockNotificationScheduler(error: AppError.notificationsUnavailable)
        let store = InMemoryReminderStore(ReminderPreferences(isEnabled: true, hour: 18, minute: 0))
        let vm = makeViewModel(scheduler: scheduler, store: store)
        let newTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 30)) ?? .now

        await vm.setReminderTime(newTime)

        #expect(vm.preferences.hour == 18)
        #expect(vm.preferences.minute == 0)
        #expect(store.load().hour == 18)
        #expect(store.load().minute == 0)
        #expect(vm.errorMessage != nil)
    }

    @Test func schedulerFailureSurfacesError() async {
        let vm = makeViewModel(scheduler: MockNotificationScheduler(error: AppError.notificationsUnavailable))

        await vm.setReminderEnabled(true)

        #expect(!vm.preferences.isEnabled)
        #expect(vm.errorMessage != nil)
    }
}
