import AtmosDomain
import SwiftUI

/// Where the user can go from Home (wireframes, "Navigation"). A typed path: a destination is
/// a value, so a typo is a compile error.
public enum Route: Hashable, Sendable {
    case cities, settings, about
}

/// Things only the app target can do, because they need UIKit or CoreLocation authorisation.
/// Passed in as closures, so this package stays platform-neutral and testable.
@MainActor
public struct PlatformActions {
    /// Shows the explanation-first permission flow and returns whether access was granted.
    public var requestLocationPermission: @MainActor () async -> Bool
    /// Opens the app's page in the system Settings app (language, and location if denied).
    public var openAppSettings: @MainActor () -> Void
    public var version: String

    public init(
        requestLocationPermission: @escaping @MainActor () async -> Bool,
        openAppSettings: @escaping @MainActor () -> Void,
        version: String
    ) {
        self.requestLocationPermission = requestLocationPermission
        self.openAppSettings = openAppSettings
        self.version = version
    }
}

/// The app's root: navigation, theme, and the container views that connect each stateless
/// content view from step 05 to its view model.
public struct AppRoot: View {
    @State private var path: [Route] = []
    @State private var home: HomeViewModel
    @State private var cities: CitiesViewModel
    @State private var settings: SettingsViewModel
    private let platform: PlatformActions

    public init(home: HomeViewModel, cities: CitiesViewModel, settings: SettingsViewModel, platform: PlatformActions) {
        _home = State(initialValue: home)
        _cities = State(initialValue: cities)
        _settings = State(initialValue: settings)
        self.platform = platform
    }

    public var body: some View {
        NavigationStack(path: $path) {
            HomeContent(state: home.state, actions: homeActions)
                .task { await home.run() }
                .navigationDestination(for: Route.self, destination: destination)
        }
        .tint(AtmosTheme.accent)
        .preferredColorScheme(colorScheme)
        .task { await settings.run() } // the theme applies everywhere
    }

    @ViewBuilder private func destination(_ route: Route) -> some View {
        switch route {
        case .cities:
            CitiesContent(state: cities.state, actions: citiesActions)
                .task { await cities.run() }
        case .settings:
            SettingsContent(settings: settings.settings, actions: settingsActions)
        case .about:
            AboutContent(version: platform.version)
        }
    }

    private var colorScheme: ColorScheme? {
        switch settings.settings.theme {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    private var homeActions: HomeActions {
        HomeActions(
            refresh: { await home.refresh() },
            retry: { home.retry() },
            requestLocation: {
                Task {
                    let granted = await platform.requestLocationPermission()
                    home.locationPermissionChanged(granted: granted)
                }
            },
            openCities: { path.append(.cities) },
            openSettings: { path.append(.settings) }
        )
    }

    private var citiesActions: CitiesActions {
        CitiesActions(
            queryChanged: { cities.queryChanged($0) },
            retrySearch: { cities.retrySearch() },
            add: { cities.add($0) },
            remove: { cities.remove($0) },
            select: { place in
                Task {
                    await cities.select(place)
                    path.removeLast()
                }
            },
            undo: { cities.undo() }
        )
    }

    private var settingsActions: SettingsActions {
        SettingsActions(
            change: { settings.change($0) },
            openLanguageSettings: { platform.openAppSettings() },
            openAbout: { path.append(.about) }
        )
    }
}
