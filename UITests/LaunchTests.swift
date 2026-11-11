import XCTest

/// Launches the real app on the iOS Simulator. Grows into the end-to-end journey in step 07.
final class LaunchTests: XCTestCase {
    /// A fresh simulator has not granted location access, so Home must explain why it needs it
    /// and offer city search, instead of showing an error (US-01, F-02).
    @MainActor
    func testFirstLaunchExplainsLocationAccess() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Where are you?"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["Search for a city"].exists)
    }
}
