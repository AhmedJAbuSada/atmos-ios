import AtmosDomain
import Foundation

/// Small builders, so each test shows only the values it cares about.
public enum TestData {
    public static let now = Date(timeIntervalSince1970: 1_794_381_300) // 2026-11-11 07:15 UTC
    // swiftlint:disable:next force_unwrapping
    public static let istanbul = Coordinates(latitude: 41.01, longitude: 28.97)!

    public static func forecast(fetchedAt: Date = now, coordinates: Coordinates = istanbul) -> Forecast {
        Forecast(
            coordinates: coordinates,
            timeZone: TimeZone(identifier: "Europe/Istanbul") ?? .gmt,
            current: CurrentWeather(
                time: now,
                temperature: Temperature(celsius: 14.9),
                feelsLike: Temperature(celsius: 11.2),
                humidityPercent: 69,
                windSpeed: WindSpeed(kilometersPerHour: 24.8),
                condition: .overcast,
                isDay: true
            ),
            hourly: [],
            daily: [],
            fetchedAt: fetchedAt
        )
    }

    public static func city(_ id: Int, _ name: String = "City") -> City {
        City(
            id: id,
            name: name,
            region: nil,
            country: "Türkiye",
            countryCode: "TR",
            coordinates: Coordinates(latitude: 39.92, longitude: 32.85) ?? istanbul
        )
    }
}

/// A clock that stands still, or moves only when the test says so.
public struct FixedDateProvider: DateProvider {
    public var now: Date

    public init(_ now: Date = TestData.now) {
        self.now = now
    }
}
