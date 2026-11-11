import AtmosDomain
import SwiftUI

@MainActor
public struct SettingsActions {
    public var change: @MainActor (_ settings: UserSettings) -> Void
    /// Opens the system Settings page of Atmos, where iOS manages the app language (ADR-0005).
    public var openLanguageSettings: @MainActor () -> Void
    public var openAbout: @MainActor () -> Void

    public init(
        change: @escaping @MainActor (UserSettings) -> Void,
        openLanguageSettings: @escaping @MainActor () -> Void,
        openAbout: @escaping @MainActor () -> Void
    ) {
        self.change = change
        self.openLanguageSettings = openLanguageSettings
        self.openAbout = openAbout
    }

    public static var none: SettingsActions {
        SettingsActions(change: { _ in }, openLanguageSettings: {}, openAbout: {})
    }
}

/// Settings (US-08). The state is simply the domain's ``UserSettings``.
public struct SettingsContent: View {
    let settings: UserSettings
    let actions: SettingsActions

    public init(settings: UserSettings, actions: SettingsActions) {
        self.settings = settings
        self.actions = actions
    }

    public var body: some View {
        Form {
            Section { unitPicker(\.temperatureUnit, options: [(.celsius, "°C"), (.fahrenheit, "°F")]) } header: {
                Text("settings.temperature", bundle: .module)
            }
            Section {
                unitPicker(\.windSpeedUnit, options: [
                    (.kilometersPerHour, "km/h"), (.metersPerSecond, "m/s"), (.milesPerHour, "mph")
                ])
            } header: {
                Text("settings.windSpeed", bundle: .module)
            }
            Section {
                Picker(selection: binding(\.theme)) {
                    Text("settings.theme.system", bundle: .module).tag(AppTheme.system)
                    Text("settings.theme.light", bundle: .module).tag(AppTheme.light)
                    Text("settings.theme.dark", bundle: .module).tag(AppTheme.dark)
                } label: {
                    Text("settings.theme", bundle: .module)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } header: {
                Text("settings.theme", bundle: .module)
            }
            Section {
                Button { actions.openLanguageSettings() } label: {
                    Label { Text("settings.language", bundle: .module) } icon: { Image(systemName: "globe") }
                }
            } footer: {
                Text("settings.language.footer", bundle: .module)
            }
            Section {
                Button { actions.openAbout() } label: {
                    Label { Text("settings.about", bundle: .module) } icon: { Image(systemName: "info.circle") }
                }
            }
        }
        .navigationTitle(Text("settings.title", bundle: .module))
    }

    /// Unit symbols are isolated, or an Arabic layout shows `C°` (found on Android).
    private func unitPicker<Unit: Hashable>(
        _ keyPath: WritableKeyPath<UserSettings, Unit>,
        options: [(Unit, String)]
    ) -> some View {
        Picker(selection: binding(keyPath)) {
            ForEach(options, id: \.0) { unit, symbol in
                Text(verbatim: WeatherFormatter.isolate(symbol)).tag(unit)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<UserSettings, Value>) -> Binding<Value> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { value in
                var changed = settings
                changed[keyPath: keyPath] = value
                actions.change(changed)
            }
        )
    }
}

#Preview("Settings") {
    NavigationStack { SettingsContent(settings: UserSettings(), actions: .none) }
}

#Preview("Settings, Arabic, dark") {
    NavigationStack { SettingsContent(settings: UserSettings(theme: .dark), actions: .none) }
        .environment(\.locale, Locale(identifier: "ar"))
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}
