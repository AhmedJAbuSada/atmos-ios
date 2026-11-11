/// Light or dark appearance. `system` follows the device.
public enum AppTheme: String, CaseIterable, Sendable, Codable {
    case system, light, dark
}

/// What the user can change in Settings (F-09). The defaults are the first-run values.
///
/// There is no language here on purpose: on iOS the per-app language lives in the system
/// Settings app, and keeping a second copy would let the two disagree (ADR-0005).
public struct UserSettings: Equatable, Sendable, Codable {
    public var temperatureUnit: TemperatureUnit
    public var windSpeedUnit: WindSpeedUnit
    public var theme: AppTheme

    public init(
        temperatureUnit: TemperatureUnit = .celsius,
        windSpeedUnit: WindSpeedUnit = .kilometersPerHour,
        theme: AppTheme = .system
    ) {
        self.temperatureUnit = temperatureUnit
        self.windSpeedUnit = windSpeedUnit
        self.theme = theme
    }
}

/// Stores ``UserSettings``. Implemented with `UserDefaults` in AtmosData (step 04).
public protocol SettingsRepository: Sendable {
    /// The current settings, then every change, so the UI updates instantly (US-08).
    func settings() async -> AsyncStream<UserSettings>

    /// Replaces the settings with the result of `transform`.
    func update(_ transform: @Sendable (UserSettings) -> UserSettings) async
}

/// Streams the user's settings.
public struct ObserveSettingsUseCase: Sendable {
    private let repository: any SettingsRepository

    public init(repository: any SettingsRepository) {
        self.repository = repository
    }

    public func callAsFunction() async -> AsyncStream<UserSettings> {
        await repository.settings()
    }
}

/// Changes settings, for example `update { $0.theme = .dark }`.
public struct UpdateSettingsUseCase: Sendable {
    private let repository: any SettingsRepository

    public init(repository: any SettingsRepository) {
        self.repository = repository
    }

    public func callAsFunction(_ change: @escaping @Sendable (inout UserSettings) -> Void) async {
        await repository.update { settings in
            var copy = settings
            change(&copy)
            return copy
        }
    }
}
