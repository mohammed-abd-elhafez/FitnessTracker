import XCTest

/// Critical-flow UI tests. They launch the app with mock data (`UI_TESTING`), English locale.
final class FitnessTrackerUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
    }

    @MainActor
    func testTabsAreReachable() {
        for title in ["Workouts", "Progress", "Settings", "Today"] {
            app.tabBars.buttons[title].tap()
            XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5), "\(title) screen missing")
        }
    }

    @MainActor
    func testAddWorkoutFormOpensAndCancels() {
        app.tabBars.buttons["Workouts"].tap()
        app.buttons["Add workout"].tap()
        XCTAssertTrue(app.navigationBars["New workout"].waitForExistence(timeout: 5))

        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.navigationBars["Workouts"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSavingWorkoutReturnsToList() {
        app.tabBars.buttons["Workouts"].tap()
        app.buttons["Add workout"].tap()
        XCTAssertTrue(app.navigationBars["New workout"].waitForExistence(timeout: 5))

        app.buttons["Save"].tap()

        XCTAssertTrue(app.navigationBars["Workouts"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.navigationBars["New workout"].exists)
    }

    @MainActor
    func testSettingsShowsGoalsAndReminder() {
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Daily goals"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.switches["Daily reminder"].exists)
    }
}
