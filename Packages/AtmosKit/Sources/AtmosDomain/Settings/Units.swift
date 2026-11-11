/// Unit the user wants temperatures shown in (F-09).
public enum TemperatureUnit: String, CaseIterable, Sendable, Codable {
    case celsius, fahrenheit
}

/// Unit the user wants wind speed shown in (F-09).
public enum WindSpeedUnit: String, CaseIterable, Sendable, Codable {
    case kilometersPerHour, metersPerSecond, milesPerHour
}

/// A temperature, stored in Celsius as the API returns it and converted only when shown, so
/// changing the unit never needs a network call (US-08). A dedicated type stops a wind speed
/// from being passed where a temperature is expected.
public struct Temperature: Equatable, Hashable, Sendable {
    public let celsius: Double

    public init(celsius: Double) {
        self.celsius = celsius
    }

    public func value(in unit: TemperatureUnit) -> Double {
        switch unit {
        case .celsius: celsius
        case .fahrenheit: celsius * 9 / 5 + 32
        }
    }
}

/// A wind speed, stored in km/h as the API returns it.
public struct WindSpeed: Equatable, Hashable, Sendable {
    public let kilometersPerHour: Double

    public init(kilometersPerHour: Double) {
        self.kilometersPerHour = kilometersPerHour
    }

    public func value(in unit: WindSpeedUnit) -> Double {
        switch unit {
        case .kilometersPerHour: kilometersPerHour
        case .metersPerSecond: kilometersPerHour / Self.kilometersPerHourPerMeterPerSecond
        case .milesPerHour: kilometersPerHour / Self.kilometersPerHourPerMilePerHour
        }
    }

    private static let kilometersPerHourPerMeterPerSecond = 3.6
    private static let kilometersPerHourPerMilePerHour = 1.609344
}
