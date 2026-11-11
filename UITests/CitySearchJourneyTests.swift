import XCTest

/// End to end on the iOS Simulator, against the **real** Open-Meteo API: no fakes.
///
/// The journey of a user without location permission (F-02, US-04, US-05): Home explains →
/// search → add → choose → the forecast is shown. Elements are found by accessibility
/// identifier, not by text, so the same test runs in every language.
///
/// When `ATMOS_SCREENSHOTS_DIR` is set (CI: `TEST_RUNNER_ATMOS_SCREENSHOTS_DIR`), each step is
/// saved as a PNG there; that is how the README screenshots are made.
final class CitySearchJourneyTests: XCTestCase {
    private let istanbulID = 745_044
    private let network: TimeInterval = 30

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testJourneyInEnglish() {
        runJourney(language: "en")
    }

    @MainActor
    func testJourneyInArabic() {
        runJourney(language: "ar")
    }

    @MainActor
    func testJourneyInTurkish() {
        runJourney(language: "tr")
    }

    @MainActor
    private func runJourney(language: String) {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(\(language))", "-AppleLocale", language, "-uiTestingReset"]
        app.launch()

        // Home: no permission yet, so the explanation is shown instead of an error.
        let searchCity = app.buttons["message.secondaryAction"]
        XCTAssertTrue(searchCity.waitForExistence(timeout: network))
        save(app, "home_needs_location", language)
        searchCity.tap()

        // Cities: a real, debounced search.
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()
        field.typeText("Istanbul")
        let add = app.buttons["cities.add.\(istanbulID)"]
        XCTAssertTrue(add.waitForExistence(timeout: network))
        save(app, "cities_search", language)
        add.tap()

        // The saved list: choose the city, which goes back to Home.
        let row = app.buttons["cities.place.city-\(istanbulID)"]
        XCTAssertTrue(row.waitForExistence(timeout: 10))
        row.tap()

        // Home: the real forecast for Istanbul.
        XCTAssertTrue(app.staticTexts["home.hourly"].waitForExistence(timeout: network))
        save(app, "home", language)
    }

    @MainActor
    private func save(_ app: XCUIApplication, _ name: String, _ language: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "\(name)_\(language)"
        attachment.lifetime = .keepAlways
        add(attachment)

        guard let directory = ProcessInfo.processInfo.environment["ATMOS_SCREENSHOTS_DIR"], !directory.isEmpty else {
            return
        }
        let url = URL(fileURLWithPath: directory).appendingPathComponent("ios_\(name)_\(language).png")
        try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
        try? screenshot.pngRepresentation.write(to: url)
    }
}
