/// What a screen gets: the forecast, plus the reason it is outdated if a refresh failed, so
/// the UI can show "Updated 2 hours ago" instead of an error screen (F-08).
public struct ForecastSnapshot: Equatable, Sendable {
    public let forecast: Forecast
    public let refreshError: DomainError?

    public var isOutdated: Bool { refreshError != nil }

    public init(forecast: Forecast, refreshError: DomainError? = nil) {
        self.forecast = forecast
        self.refreshError = refreshError
    }
}

/// Gets the forecast for a place, cache first (US-06, US-07).
///
/// | Cache       | forceRefresh | Network  | Result                                  |
/// |-------------|--------------|----------|-----------------------------------------|
/// | fresh       | false        | not used | cached                                  |
/// | fresh       | true         | ok       | new                                     |
/// | stale/none  | any          | ok       | new                                     |
/// | stale/fresh | any          | fails    | cached, marked outdated with the error  |
/// | none        | any          | fails    | throws the error                        |
public struct GetForecastUseCase: Sendable {
    private let repository: any WeatherRepository
    private let freshness: ForecastFreshness

    public init(repository: any WeatherRepository, freshness: ForecastFreshness) {
        self.repository = repository
        self.freshness = freshness
    }

    public func callAsFunction(
        for coordinates: Coordinates,
        forceRefresh: Bool = false
    ) async throws(DomainError) -> ForecastSnapshot {
        let cached = await repository.cachedForecast(for: coordinates)
        if !forceRefresh, let cached, freshness.isFresh(cached) {
            return ForecastSnapshot(forecast: cached)
        }
        do {
            return ForecastSnapshot(forecast: try await repository.fetchForecast(for: coordinates))
        } catch .cancelled {
            throw .cancelled // never hide a cancellation behind old data (ADR-0009)
        } catch {
            guard let cached else { throw error }
            return ForecastSnapshot(forecast: cached, refreshError: error)
        }
    }
}

/// The last known forecast for a place, **without** a download: for the Cities list.
public struct GetCachedForecastUseCase: Sendable {
    private let repository: any WeatherRepository

    public init(repository: any WeatherRepository) {
        self.repository = repository
    }

    public func callAsFunction(for coordinates: Coordinates) async -> Forecast? {
        await repository.cachedForecast(for: coordinates)
    }
}

/// The forecast where the user is now (US-01): locate, then get the forecast. A location
/// error (for example, permission denied) is thrown as-is, so the UI can offer search (F-02).
public struct GetCurrentLocationForecastUseCase: Sendable {
    private let locations: any LocationRepository
    private let getForecast: GetForecastUseCase

    public init(locations: any LocationRepository, getForecast: GetForecastUseCase) {
        self.locations = locations
        self.getForecast = getForecast
    }

    public func callAsFunction(forceRefresh: Bool = false) async throws(DomainError) -> ForecastSnapshot {
        let coordinates = try await locations.currentLocation()
        return try await getForecast(for: coordinates, forceRefresh: forceRefresh)
    }
}
