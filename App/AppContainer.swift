import AtmosData
import AtmosDomain
import AtmosPresentation
import Foundation
import SwiftUI
import UIKit

/// The composition root (ADR-0004): the one place that knows which implementation stands
/// behind each domain protocol, and that builds the use cases and view models. Everything else
/// receives its dependencies in `init`; nothing reaches for a singleton.
@MainActor
final class AppContainer {
    private let repositories: DataModule.Repositories
    private let places = SelectedPlaceStore()
    private let locationPermission = LocationPermission()
    private let version: String

    init() {
        version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let storage = URL.applicationSupportDirectory.appendingPathComponent("Atmos", isDirectory: true)
        // UI tests start from a clean install, so every run sees the first-launch flow.
        if ProcessInfo.processInfo.arguments.contains("-uiTestingReset") {
            try? FileManager.default.removeItem(at: storage)
            if let id = Bundle.main.bundleIdentifier { UserDefaults.standard.removePersistentDomain(forName: id) }
        }
        repositories = DataModule.makeRepositories(
            userAgent: "Atmos/\(version) (iOS)", // no personal data (API_CONTRACT §4)
            storageDirectory: storage
        )
    }

    func makeRootView() -> some View {
        let freshness = ForecastFreshness(dates: SystemDateProvider())
        let getForecast = GetForecastUseCase(repository: repositories.weather, freshness: freshness)
        let observeSettings = ObserveSettingsUseCase(repository: repositories.settings)

        let home = HomeViewModel(
            getCurrentLocationForecast: GetCurrentLocationForecastUseCase(
                locations: repositories.location,
                getForecast: getForecast
            ),
            getForecast: getForecast,
            freshness: freshness,
            places: places,
            observeSettings: observeSettings
        )
        let cities = CitiesViewModel(
            searchCities: SearchCitiesUseCase(repository: repositories.cities),
            saveCity: SaveCityUseCase(repository: repositories.cities),
            removeCity: RemoveCityUseCase(repository: repositories.cities),
            observePlaces: ObservePlacesUseCase(repository: repositories.cities),
            getCachedForecast: GetCachedForecastUseCase(repository: repositories.weather),
            observeSettings: observeSettings,
            places: places,
            languageCode: Self.languageCode
        )
        let settings = SettingsViewModel(
            observeSettings: observeSettings,
            updateSettings: UpdateSettingsUseCase(repository: repositories.settings)
        )
        let platform = PlatformActions(
            requestLocationPermission: { [locationPermission] in
                // iOS shows the dialog only once; after a refusal, Settings is the only way.
                if locationPermission.status == .denied {
                    Self.openAppSettings()
                    return false
                }
                return await locationPermission.request()
            },
            openAppSettings: { Self.openAppSettings() },
            version: version
        )
        return AppRoot(home: home, cities: cities, settings: settings, platform: platform)
    }

    /// The app's own page in Settings: per-app language (ADR-0005) and location access.
    private static func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    /// The language the app is shown in, for city names (F-05): the per-app language iOS chose
    /// from the app's localizations.
    private static let languageCode: @Sendable () -> String = {
        let supported = ["en", "tr", "ar"]
        let preferred = Bundle.main.preferredLocalizations.first ?? "en"
        return supported.first { preferred.hasPrefix($0) } ?? "en"
    }
}
