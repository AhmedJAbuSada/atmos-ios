import XCTest

/// Launches the real app on the iOS Simulator. Grows into the end-to-end journey in step 07.
final class LaunchTests: XCTestCase {
    @MainActor
    func testAppLaunchesAndShowsTheTitle() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Hello, Atmos"].waitForExistence(timeout: 10))
    }
}
