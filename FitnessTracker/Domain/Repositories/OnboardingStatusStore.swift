import Foundation

/// Remembers whether the user has completed onboarding.
protocol OnboardingStatusStore: Sendable {
    var isCompleted: Bool { get }
    func markCompleted()
}
