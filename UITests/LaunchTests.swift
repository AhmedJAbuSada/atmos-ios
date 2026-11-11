import XCTest

/// Launches the real app on the iOS Simulator. Grows into the end-to-end journey in step 07.
final class LaunchTests: XCTestCase {
    @MainActor
    func testAppLaunchesAndShowsTheForecast() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Next 24 hours"].waitForExistence(timeout: 10))
    }
}
