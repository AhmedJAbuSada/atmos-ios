import AtmosDomain
import Foundation

/// Fake but realistic data, shaped like the recorded Istanbul response in docs/api/samples.
/// In step 05 the screens run only on this data; step 06 connects the real use cases.
public enum PreviewData {
    private static let zone = TimeZone(identifier: "Europe/Istanbul") ?? .gmt
    private static let start = Date(timeIntervalSince1970: 1_794_384_000) // 2026-11-11 10:00 Istanbul

    static func coordinates(_ latitude: Double, _ longitude: Double) -> Coordinates {
        guard let value = Coordinates(latitude: latitude, longitude: longitude) else {
            preconditionFailure("Invalid preview coordinates")
        }
        return value
    }

    public static let istanbul = City(
        id: 745_044, name: "İstanbul", region: "İstanbul", country: "Türkiye", countryCode: "TR",
        coordinates: coordinates(41.01384, 28.94966)
    )
    public static let ankara = City(
        id: 323_786, name: "Ankara", region: "Ankara", country: "Türkiye", countryCode: "TR",
        coordinates: coordinates(39.91987, 32.85427)
    )
    public static let london = City(
        id: 2_643_743, name: "London", region: "England", country: "United Kingdom", countryCode: "GB",
        coordinates: coordinates(51.50853, -0.12574)
    )

    public static let forecast: Forecast = {
        let hourlyCodes = [3, 3, 2, 61, 63, 61, 3, 2, 1, 0, 0, 0]
        let dailyCodes = [3, 3, 61, 80, 1, 0, 71]
        let chances = [0, 0, 20, 70, 80, 40]
        return Forecast(
            coordinates: coordinates(41.01, 28.97),
            timeZone: zone,
            current: CurrentWeather(
                time: start.addingTimeInterval(15 * 60),
                temperature: Temperature(celsius: 14.9),
                feelsLike: Temperature(celsius: 11.2),
                humidityPercent: 69,
                windSpeed: WindSpeed(kilometersPerHour: 24.8),
                condition: .overcast,
                isDay: true
            ),
            hourly: (0..<24).map { hour in
                HourlyForecast(
                    time: start.addingTimeInterval(Double(hour) * 3600),
                    temperature: Temperature(celsius: 14.8 + Double(hour % 6) - 2),
                    condition: WeatherCondition(wmoCode: hourlyCodes[hour % hourlyCodes.count]),
                    precipitationChancePercent: chances[hour % chances.count]
                )
            },
            daily: (0..<7).map { day in
                let date = start.addingTimeInterval(Double(day) * 86_400 - 10 * 3600)
                return DailyForecast(
                    date: date,
                    condition: WeatherCondition(wmoCode: dailyCodes[day]),
                    minTemperature: Temperature(celsius: 11.4 + Double(day % 3)),
                    maxTemperature: Temperature(celsius: 16.9 + Double(day % 4)),
                    sunrise: date.addingTimeInterval(7 * 3600 + 46 * 60),
                    sunset: date.addingTimeInterval(17 * 3600 + 49 * 60)
                )
            },
            fetchedAt: start
        )
    }()

    public static let content = HomeContentState(placeName: istanbul.name, forecast: forecast, settings: UserSettings())
    public static let outdated = HomeContentState(
        placeName: nil, forecast: forecast, settings: UserSettings(), outdatedBy: 2 * 3600
    )
    public static let cities = CitiesState(places: [
        PlaceItem(place: .currentLocation, temperature: Temperature(celsius: 14.9), condition: .overcast),
        PlaceItem(place: .saved(ankara), temperature: Temperature(celsius: 12), condition: .rain),
        PlaceItem(place: .saved(london), temperature: Temperature(celsius: 9), condition: .fog)
    ])
}
