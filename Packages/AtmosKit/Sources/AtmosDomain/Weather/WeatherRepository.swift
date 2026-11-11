/// Source of forecasts. The protocol lives in the domain; the implementation (URLSession +
/// file cache) lives in AtmosData. That inversion keeps the domain free of frameworks.
///
/// The repository only *stores and fetches*. *When* to fetch is a business rule, so it lives
/// in ``GetForecastUseCase``.
public protocol WeatherRepository: Sendable {
    /// The last saved forecast for `coordinates`, or `nil`.
    func cachedForecast(for coordinates: Coordinates) async -> Forecast?

    /// Downloads a new forecast and saves it to the cache.
    func fetchForecast(for coordinates: Coordinates) async throws(DomainError) -> Forecast
}
