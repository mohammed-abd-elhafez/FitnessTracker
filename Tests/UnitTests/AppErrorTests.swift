import Testing
@testable import FitnessTracker

struct AppErrorTests {
    @Test(arguments: [
        AppError.healthUnavailable,
        .healthAccessDenied,
        .storageFailure,
        .networkUnavailable,
        .notificationsUnavailable
    ])
    func everyCaseHasADescription(error: AppError) {
        #expect(error.errorDescription?.isEmpty == false)
    }
}
