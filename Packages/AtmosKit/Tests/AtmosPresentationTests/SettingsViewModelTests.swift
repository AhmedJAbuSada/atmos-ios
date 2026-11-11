import AtmosDomain
@testable import AtmosPresentation
import AtmosTesting
import Testing

@MainActor
@Suite("SettingsViewModel")
struct SettingsViewModelTests {
    @Test("a change is shown at once and saved")
    func change() async {
        let repository = FakeSettingsRepository()
        let viewModel = SettingsViewModel(
            observeSettings: ObserveSettingsUseCase(repository: repository),
            updateSettings: UpdateSettingsUseCase(repository: repository)
        )
        let changed = UserSettings(temperatureUnit: .fahrenheit, windSpeedUnit: .milesPerHour, theme: .dark)

        viewModel.change(changed)

        #expect(viewModel.settings == changed)
        #expect(await eventuallyAsync { await repository.current() == changed })
    }
}
