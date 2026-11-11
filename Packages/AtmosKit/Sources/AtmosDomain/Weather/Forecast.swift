import Foundation

/// The full forecast for one place, as the app understands it.
///
/// Times are real instants (`Date`); `timeZone` is the place's own zone, so the UI shows
/// "14:00" in Istanbul time even on a phone set to London. `fetchedAt` is when the data was
/// downloaded, used for freshness (F-07) and "Updated 2 hours ago" (F-08).
public struct Forecast: Equatable, Sendable {
    public let coordinates: Coordinates
    public let timeZone: TimeZone
    public let current: CurrentWeather
    public let hourly: [HourlyForecast]
    public let daily: [DailyForecast]
    public let fetchedAt: Date

    public init(
        coordinates: Coordinates,
        timeZone: TimeZone,
        current: CurrentWeather,
        hourly: [HourlyForecast],
        daily: [DailyForecast],
        fetchedAt: Date
    ) {
        self.coordinates = coordinates
        self.timeZone = timeZone
        self.current = current
        self.hourly = hourly
        self.daily = daily
        self.fetchedAt = fetchedAt
    }
}

/// Conditions right now (F-01).
public struct CurrentWeather: Equatable, Sendable {
    public let time: Date
    public let temperature: Temperature
    public let feelsLike: Temperature
    public let humidityPercent: Int
    public let windSpeed: WindSpeed
    public let condition: WeatherCondition
    public let isDay: Bool

    public init(
        time: Date,
        temperature: Temperature,
        feelsLike: Temperature,
        humidityPercent: Int,
        windSpeed: WindSpeed,
        condition: WeatherCondition,
        isDay: Bool
    ) {
        self.time = time
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.humidityPercent = humidityPercent
        self.windSpeed = windSpeed
        self.condition = condition
        self.isDay = isDay
    }
}

/// One hour of the 24-hour forecast (F-03). The precipitation chance may be unknown.
public struct HourlyForecast: Equatable, Sendable, Identifiable {
    public var id: Date { time }
    public let time: Date
    public let temperature: Temperature
    public let condition: WeatherCondition
    public let precipitationChancePercent: Int?

    public init(time: Date, temperature: Temperature, condition: WeatherCondition, precipitationChancePercent: Int?) {
        self.time = time
        self.temperature = temperature
        self.condition = condition
        self.precipitationChancePercent = precipitationChancePercent
    }
}

/// One day of the 7-day forecast (F-04). `date` is the start of the day at the place.
public struct DailyForecast: Equatable, Sendable, Identifiable {
    public var id: Date { date }
    public let date: Date
    public let condition: WeatherCondition
    public let minTemperature: Temperature
    public let maxTemperature: Temperature
    public let sunrise: Date?
    public let sunset: Date?

    public init(
        date: Date,
        condition: WeatherCondition,
        minTemperature: Temperature,
        maxTemperature: Temperature,
        sunrise: Date?,
        sunset: Date?
    ) {
        self.date = date
        self.condition = condition
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.sunrise = sunrise
        self.sunset = sunset
    }
}
