import Foundation

/// `UserDefaults`-backed onboarding flag.
struct UserDefaultsOnboardingStore: OnboardingStatusStore {
    var defaults: UserDefaults = .standard
    var key = "onboarding.completed"

    var isCompleted: Bool { defaults.bool(forKey: key) }

    func markCompleted() {
        defaults.set(true, forKey: key)
    }
}
