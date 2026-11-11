import AtmosDomain
import Foundation

/// ``WeatherRepository`` on Open-Meteo (network) and ``JSONFileStore`` (cache).
///
/// It only stores and fetches; *when* to fetch is decided by `GetForecastUseCase`. The cache
/// holds the **raw API response** and the fetch time, and maps it again on read, so fresh and
/// cached data can never disagree.
struct DefaultWeatherRepository: WeatherRepository {
    private let api: OpenMeteoAPI
    private let store: JSONFileStore
    private let dates: any DateProvider

    init(api: OpenMeteoAPI, store: JSONFileStore, dates: any DateProvider) {
        self.api = api
        self.store = store
        self.dates = dates
    }

    func cachedForecast(for coordinates: Coordinates) async -> Forecast? {
        guard let entry = await store.read(CachedResponse.self, key: key(coordinates)),
              let dto = try? JSONDecoder().decode(ForecastDTO.self, from: entry.response) else { return nil }
        return try? ForecastMapper.map(dto, requested: coordinates, fetchedAt: entry.fetchedAt)
    }

    func fetchForecast(for coordinates: Coordinates) async throws(DomainError) -> Forecast {
        do {
            let (dto, raw) = try await api.forecast(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let fetchedAt = dates.now
            let forecast = try ForecastMapper.map(dto, requested: coordinates, fetchedAt: fetchedAt) // validate first
            try? await store.write(CachedResponse(fetchedAt: fetchedAt, response: raw), key: key(coordinates))
            return forecast
        } catch {
            throw DomainError.from(error)
        }
    }

    private func key(_ coordinates: Coordinates) -> String { "forecast-" + coordinates.cacheKey }

    private struct CachedResponse: Codable {
        let fetchedAt: Date
        let response: Data
    }
}
