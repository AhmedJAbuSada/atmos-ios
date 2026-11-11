import AtmosDomain
import Foundation

/// Turns the JSON-shaped ``ForecastDTO`` into the domain ``Forecast``.
///
/// - `requested` are the coordinates **we asked for**: the API snaps them to its grid
///   (API_CONTRACT §1, point 5), so the response's own coordinates are ignored.
/// - Times like `2026-11-11T10:15` are local to the place and have no offset; they are read
///   in the place's time zone and become real instants (`Date`).
/// - Current conditions are required. Hourly and daily entries are zipped from parallel
///   arrays; an incomplete entry is **skipped**, not fatal.
enum ForecastMapper {
    static func map(_ dto: ForecastDTO, requested: Coordinates, fetchedAt: Date) throws -> Forecast {
        let timeZone = timeZone(named: dto.timezone, offsetSeconds: dto.utcOffsetSeconds)
        let parser = LocalTimeParser(timeZone: timeZone)
        guard let current = dto.current.flatMap({ mapCurrent($0, parser) }) else {
            throw InvalidResponseError(reason: "Missing current conditions")
        }
        return Forecast(
            coordinates: requested,
            timeZone: timeZone,
            current: current,
            hourly: dto.hourly.map { mapHourly($0, parser) } ?? [],
            daily: dto.daily.map { mapDaily($0, parser) } ?? [],
            fetchedAt: fetchedAt
        )
    }

    private static func mapCurrent(_ dto: CurrentDTO, _ parser: LocalTimeParser) -> CurrentWeather? {
        guard let time = parser.dateTime(dto.time),
              let temperature = dto.temperature,
              let humidity = dto.relativeHumidity,
              let wind = dto.windSpeed else { return nil }
        return CurrentWeather(
            time: time,
            temperature: Temperature(celsius: temperature),
            feelsLike: Temperature(celsius: dto.apparentTemperature ?? temperature),
            humidityPercent: humidity,
            windSpeed: WindSpeed(kilometersPerHour: wind),
            condition: WeatherCondition(wmoCode: dto.weatherCode),
            // The API sends 1 or 0. Unknown? Assume day: a sun icon is the safer default.
            isDay: dto.isDay != 0
        )
    }

    private static func mapHourly(_ dto: HourlyDTO, _ parser: LocalTimeParser) -> [HourlyForecast] {
        let times = dto.time ?? []
        return times.indices.compactMap { index in
            guard let time = parser.dateTime(times[index]),
                  let temperature = dto.temperature?[safe: index] ?? nil else { return nil }
            return HourlyForecast(
                time: time,
                temperature: Temperature(celsius: temperature),
                condition: WeatherCondition(wmoCode: dto.weatherCode?[safe: index] ?? nil),
                precipitationChancePercent: dto.precipitationProbability?[safe: index] ?? nil
            )
        }
    }

    private static func mapDaily(_ dto: DailyDTO, _ parser: LocalTimeParser) -> [DailyForecast] {
        let days = dto.time ?? []
        return days.indices.compactMap { index in
            guard let date = parser.date(days[index]),
                  let minimum = dto.temperatureMin?[safe: index] ?? nil,
                  let maximum = dto.temperatureMax?[safe: index] ?? nil else { return nil }
            return DailyForecast(
                date: date,
                condition: WeatherCondition(wmoCode: dto.weatherCode?[safe: index] ?? nil),
                minTemperature: Temperature(celsius: minimum),
                maxTemperature: Temperature(celsius: maximum),
                sunrise: parser.dateTime(dto.sunrise?[safe: index] ?? nil),
                sunset: parser.dateTime(dto.sunset?[safe: index] ?? nil)
            )
        }
    }

    /// The named zone handles daylight saving; fall back to the fixed offset, then UTC.
    static func timeZone(named name: String?, offsetSeconds: Int?) -> TimeZone {
        name.flatMap(TimeZone.init(identifier:))
            ?? offsetSeconds.flatMap(TimeZone.init(secondsFromGMT:))
            ?? .gmt
    }
}

/// Reads Open-Meteo's local date/time strings in one time zone.
struct LocalTimeParser {
    private let dateTimeFormatter: DateFormatter
    private let dateFormatter: DateFormatter

    init(timeZone: TimeZone) {
        dateTimeFormatter = Self.formatter("yyyy-MM-dd'T'HH:mm", timeZone)
        dateFormatter = Self.formatter("yyyy-MM-dd", timeZone)
    }

    func dateTime(_ text: String?) -> Date? { text.flatMap(dateTimeFormatter.date(from:)) }

    func date(_ text: String?) -> Date? { text.flatMap(dateFormatter.date(from:)) }

    /// `en_US_POSIX` is essential: with the user's locale, a phone set to a non-Gregorian
    /// calendar or 12-hour clock would fail to parse "2026-11-11T14:00".
    private static func formatter(_ format: String, _ timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        return formatter
    }
}

extension Array {
    /// The element at `index`, or `nil` when the array is shorter: parallel arrays from the
    /// API may have different lengths, and that must not crash.
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
