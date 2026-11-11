import Foundation

/// The two Open-Meteo endpoints (API_CONTRACT §1, §2): builds the URLs, sends them, decodes
/// the JSON. Returns DTOs; mapping to the domain happens in the repositories.
struct OpenMeteoAPI: Sendable {
    static let currentFields =
        "temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m"
    static let hourlyFields = "temperature_2m,weather_code,precipitation_probability"
    static let dailyFields = "weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset"

    private let client: any HTTPClient
    private let forecastBase: URL
    private let geocodingBase: URL

    init(
        client: any HTTPClient,
        forecastBase: URL = URL(literal: "https://api.open-meteo.com/v1/forecast"),
        geocodingBase: URL = URL(literal: "https://geocoding-api.open-meteo.com/v1/search")
    ) {
        self.client = client
        self.forecastBase = forecastBase
        self.geocodingBase = geocodingBase
    }

    /// Returns the decoded forecast **and the raw bytes**, which the cache stores as they are.
    func forecast(latitude: Double, longitude: Double) async throws -> (dto: ForecastDTO, raw: Data) {
        let url = forecastBase.appending(queryItems: [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: Self.currentFields),
            URLQueryItem(name: "hourly", value: Self.hourlyFields),
            URLQueryItem(name: "daily", value: Self.dailyFields),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "7"),
            URLQueryItem(name: "forecast_hours", value: "24")
        ])
        let data = try await send(url)
        return (try JSONDecoder().decode(ForecastDTO.self, from: data), data)
    }

    func searchCities(name: String, languageCode: String) async throws -> GeocodingDTO {
        let url = geocodingBase.appending(queryItems: [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "language", value: languageCode),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "format", value: "json")
        ])
        return try JSONDecoder().decode(GeocodingDTO.self, from: try await send(url))
    }

    private func send(_ url: URL) async throws -> Data {
        let (data, status) = try await client.get(url)
        guard (200..<300).contains(status) else { throw HTTPStatusError(code: status) }
        return data
    }
}

/// The server answered with a non-2xx status.
struct HTTPStatusError: Error, Equatable {
    let code: Int
}

/// The server answered, but the response is missing something we cannot do without.
struct InvalidResponseError: Error, Equatable {
    let reason: String
}

extension URL {
    /// A URL written in the source code. A typo is a programmer error, caught by the first
    /// test that uses it, so failing loudly is right here (instead of a force unwrap).
    init(literal: StaticString) {
        guard let url = URL(string: "\(literal)") else { preconditionFailure("Invalid URL literal: \(literal)") }
        self = url
    }
}
