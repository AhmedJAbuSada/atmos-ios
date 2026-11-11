import AtmosDomain
import AtmosTesting
import Testing

@Suite("Units")
struct UnitsTests {
    @Test("celsius converts to fahrenheit", arguments: [(0.0, 32.0), (100.0, 212.0), (-40.0, -40.0)])
    func fahrenheit(celsius: Double, expected: Double) {
        #expect(abs(Temperature(celsius: celsius).value(in: .fahrenheit) - expected) < 0.001)
    }

    @Test("celsius is returned unchanged")
    func celsius() {
        #expect(Temperature(celsius: 14.9).value(in: .celsius) == 14.9)
    }

    @Test("wind speed converts to every unit")
    func windSpeed() {
        let wind = WindSpeed(kilometersPerHour: 36)
        #expect(wind.value(in: .kilometersPerHour) == 36)
        #expect(abs(wind.value(in: .metersPerSecond) - 10) < 0.001)
        #expect(abs(wind.value(in: .milesPerHour) - 22.369) < 0.001)
    }
}

@Suite("Settings use cases")
struct SettingsUseCasesTests {
    @Test("first run uses metric units and follows the system theme")
    func defaults() async {
        let stream = await ObserveSettingsUseCase(repository: FakeSettingsRepository())()
        let first = await stream.first { _ in true }
        #expect(first == UserSettings(temperatureUnit: .celsius, windSpeedUnit: .kilometersPerHour, theme: .system))
    }

    @Test("when the unit changes, then observers receive the new settings")
    func update() async {
        let repository = FakeSettingsRepository()
        let stream = await ObserveSettingsUseCase(repository: repository)()
        var iterator = stream.makeAsyncIterator()
        _ = await iterator.next()

        await UpdateSettingsUseCase(repository: repository)() { $0.temperatureUnit = .fahrenheit }

        #expect(await iterator.next()?.temperatureUnit == .fahrenheit)
    }
}
