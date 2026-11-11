/// The forecast response **exactly as the JSON looks** (API_CONTRACT §1). DTOs never leave
/// AtmosData. Every field is optional: the API is outside our control, and a missing field
/// must not crash the app. The mapper decides what is truly required.
struct ForecastDTO: Decodable, Sendable {
    let latitude: Double?
    let longitude: Double?
    let timezone: String?
    let utcOffsetSeconds: Int?
    let current: CurrentDTO?
    let hourly: HourlyDTO?
    let daily: DailyDTO?

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, timezone, current, hourly, daily
        case utcOffsetSeconds = "utc_offset_seconds"
    }
}

struct CurrentDTO: Decodable, Sendable {
    let time: String?
    let temperature: Double?
    let apparentTemperature: Double?
    let relativeHumidity: Int?
    let windSpeed: Double?
    let weatherCode: Int?
    let isDay: Int?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case relativeHumidity = "relative_humidity_2m"
        case windSpeed = "wind_speed_10m"
        case weatherCode = "weather_code"
        case isDay = "is_day"
    }
}

/// Parallel arrays: index `i` of every list belongs to `time[i]`.
struct HourlyDTO: Decodable, Sendable {
    let time: [String]?
    let temperature: [Double?]?
    let weatherCode: [Int?]?
    let precipitationProbability: [Int?]?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case weatherCode = "weather_code"
        case precipitationProbability = "precipitation_probability"
    }
}

/// Parallel arrays: index `i` of every list belongs to `time[i]`.
struct DailyDTO: Decodable, Sendable {
    let time: [String]?
    let weatherCode: [Int?]?
    let temperatureMax: [Double?]?
    let temperatureMin: [Double?]?
    let sunrise: [String?]?
    let sunset: [String?]?

    enum CodingKeys: String, CodingKey {
        case time, sunrise, sunset
        case weatherCode = "weather_code"
        case temperatureMax = "temperature_2m_max"
        case temperatureMin = "temperature_2m_min"
    }
}

/// The geocoding response (API_CONTRACT §2). When nothing matches, the API **omits
/// `results` entirely** instead of sending `[]` (docs/api/samples/geocoding_empty.json),
/// so it is optional and treated as empty by the mapper.
struct GeocodingDTO: Decodable, Sendable {
    let results: [CityDTO]?
}

struct CityDTO: Decodable, Sendable {
    let id: Int?
    let name: String?
    let latitude: Double?
    let longitude: Double?
    let countryCode: String?
    let country: String?
    let admin1: String?

    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, country, admin1
        case countryCode = "country_code"
    }
}
