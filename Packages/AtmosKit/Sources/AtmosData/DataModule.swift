import AtmosDomain
import Foundation

/// The public face of AtmosData: everything else in this target is `internal`. The app's
/// composition root calls these factories and only ever sees **domain protocols**.
public enum DataModule {
    public struct Repositories: Sendable {
        public let weather: any WeatherRepository
        public let cities: any CityRepository
        public let settings: any SettingsRepository
        public let location: any LocationRepository
    }

    /// The real implementations: Open-Meteo over `URLSession`, files in `storageDirectory`,
    /// settings in `UserDefaults`, CoreLocation.
    public static func makeRepositories(
        userAgent: String,
        storageDirectory: URL,
        dates: any DateProvider = SystemDateProvider()
    ) -> Repositories {
        let api = OpenMeteoAPI(client: RetryingHTTPClient(wrapping: URLSessionHTTPClient(userAgent: userAgent)))
        let store = JSONFileStore(directory: storageDirectory)
        return Repositories(
            weather: DefaultWeatherRepository(api: api, store: store, dates: dates),
            cities: DefaultCityRepository(api: api, store: store),
            settings: UserDefaultsSettingsRepository(),
            location: platformLocation()
        )
    }

    private static func platformLocation() -> any LocationRepository {
        #if canImport(CoreLocation)
        CoreLocationRepository()
        #else
        UnavailableLocationRepository()
        #endif
    }
}

/// Used where CoreLocation does not exist (Linux builds of the package).
struct UnavailableLocationRepository: LocationRepository {
    func currentLocation() async throws(DomainError) -> Coordinates {
        throw .locationUnavailable
    }
}
