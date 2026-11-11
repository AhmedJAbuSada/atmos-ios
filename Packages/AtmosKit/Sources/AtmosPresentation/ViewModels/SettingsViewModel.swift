import AtmosDomain
import Observation

/// Settings (US-08). Every screen observes the same settings stream, so a change here updates
/// them all without being told.
@MainActor
@Observable
public final class SettingsViewModel {
    public private(set) var settings = UserSettings()

    private let observeSettings: ObserveSettingsUseCase
    private let updateSettings: UpdateSettingsUseCase

    public init(observeSettings: ObserveSettingsUseCase, updateSettings: UpdateSettingsUseCase) {
        self.observeSettings = observeSettings
        self.updateSettings = updateSettings
    }

    public func run() async {
        for await settings in await observeSettings() {
            self.settings = settings
        }
    }

    public func change(_ settings: UserSettings) {
        self.settings = settings // the UI answers at once; the stream confirms it
        Task { await updateSettings { $0 = settings } }
    }
}
