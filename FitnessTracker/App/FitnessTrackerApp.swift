import SwiftUI

/// Application entry point.
@main
struct FitnessTrackerApp: App {
    private let container: AppContainer = {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING")
            ? .mock(onboardingCompleted: true)
            : .live()
    }()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}
