import AtmosDomain
import Foundation

/// ``SettingsRepository`` on `UserDefaults` (ADR-0007). Stored as one JSON value: unknown or
/// unreadable data falls back to the defaults instead of crashing.
actor UserDefaultsSettingsRepository: SettingsRepository {
    private static let key = "user-settings"
    private let defaults: UserDefaults
    private let stream: ValueStream<UserSettings>

    /// `suiteName` nil is the app's standard defaults; tests pass a unique suite.
    init(suiteName: String? = nil) {
        let defaults = suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
        self.defaults = defaults
        let stored = defaults.data(forKey: Self.key).flatMap { try? JSONDecoder().decode(UserSettings.self, from: $0) }
        stream = ValueStream(stored ?? UserSettings())
    }

    func settings() async -> AsyncStream<UserSettings> {
        await stream.values()
    }

    func update(_ transform: @Sendable (UserSettings) -> UserSettings) async {
        let updated = transform(await stream.value)
        if let data = try? JSONEncoder().encode(updated) { defaults.set(data, forKey: Self.key) }
        await stream.send(updated)
    }
}
