import Foundation
import os

/// Composition root: owns the app's dependencies and builds view models.
struct AppContainer: Sendable {
    let health: any HealthDataRepository
    let workouts: any WorkoutRepository
    let goals: any GoalRepository
    let onboarding: any OnboardingStatusStore
    let notifications: any NotificationScheduling
    let reminderStore: any ReminderPreferencesStore
    var snapshots: (any SnapshotPublishing)?
    let storageError: AppError?

    /// Production wiring. Surfaces a storage failure if the database cannot be opened.
    static func live() -> AppContainer {
        let workouts: any WorkoutRepository
        let goals: any GoalRepository
        let storageError: AppError?
        do {
            let store = try PersistenceSchema.makeContainer()
            workouts = SwiftDataWorkoutRepository(modelContainer: store)
            goals = SwiftDataGoalRepository(modelContainer: store)
            storageError = nil
        } catch {
            Logger.storage.error("Persistent storage unavailable: \(error.localizedDescription)")
            // Never accept writes into volatile production storage. The root view
            // presents a recovery state instead of making user data appear to vanish.
            workouts = MockWorkoutRepository(error: .storageFailure)
            goals = MockGoalRepository(error: .storageFailure)
            storageError = .storageFailure
        }
        return AppContainer(
            health: HealthKitService(),
            workouts: workouts,
            goals: goals,
            onboarding: UserDefaultsOnboardingStore(),
            notifications: NotificationService(),
            reminderStore: UserDefaultsReminderStore(),
            snapshots: AppGroupSnapshotStore(),
            storageError: storageError
        )
    }

    /// Container backed by in-memory mocks (previews and tests).
    static func mock(onboardingCompleted: Bool = false) -> AppContainer {
        let suite = "mock.\(UUID().uuidString)"
        let onboarding = UserDefaultsOnboardingStore(
            defaults: UserDefaults(suiteName: suite) ?? .standard, key: suite
        )
        if onboardingCompleted { onboarding.markCompleted() }
        return AppContainer(
            health: MockHealthRepository(),
            workouts: MockWorkoutRepository(items: [
                Workout(type: .running, startDate: .now, durationMinutes: 30, caloriesBurned: 280)
            ]),
            goals: MockGoalRepository(),
            onboarding: onboarding,
            notifications: MockNotificationScheduler(),
            reminderStore: InMemoryReminderStore(),
            storageError: nil
        )
    }

    @MainActor
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(health: health, workouts: workouts, goals: goals, snapshots: snapshots)
    }

    @MainActor
    func makeProgressViewModel() -> ProgressViewModel {
        ProgressViewModel(health: health, goals: goals)
    }

    @MainActor
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(goals: goals, scheduler: notifications, store: reminderStore)
    }

    @MainActor
    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(
            health: health, goals: goals, scheduler: notifications,
            reminderStore: reminderStore, store: onboarding
        )
    }

    @MainActor
    func makeWorkoutsViewModel() -> WorkoutsViewModel {
        WorkoutsViewModel(repository: workouts)
    }

    @MainActor
    func makeWorkoutFormViewModel(workout: Workout, isEditing: Bool) -> WorkoutFormViewModel {
        WorkoutFormViewModel(workout: workout, isEditing: isEditing, repository: workouts)
    }
}
