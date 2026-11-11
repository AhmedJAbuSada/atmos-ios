/// What the sky is doing, independent of any provider or language. The UI maps each case to
/// a localized label and an icon; ``init(wmoCode:)`` translates the international WMO code
/// that Open-Meteo returns (API_CONTRACT §3).
public enum WeatherCondition: String, CaseIterable, Sendable, Codable {
    case clear, mainlyClear, partlyCloudy, overcast, fog
    case drizzle, freezingDrizzle, rain, freezingRain, snow
    case rainShowers, snowShowers, thunderstorm, thunderstormWithHail
    /// A code we do not know. Shown with a neutral icon; it must never crash the app.
    case unknown

    public init(wmoCode code: Int?) {
        self = code.flatMap { Self.byWMOCode[$0] } ?? .unknown
    }

    /// The WMO weather interpretation codes (API_CONTRACT §3). A table reads better than a
    /// long `switch` for a pure mapping, and it is easy to compare with the documentation.
    private static let byWMOCode: [Int: WeatherCondition] = [
        0: .clear, 1: .mainlyClear, 2: .partlyCloudy, 3: .overcast,
        45: .fog, 48: .fog,
        51: .drizzle, 53: .drizzle, 55: .drizzle,
        56: .freezingDrizzle, 57: .freezingDrizzle,
        61: .rain, 63: .rain, 65: .rain,
        66: .freezingRain, 67: .freezingRain,
        71: .snow, 73: .snow, 75: .snow, 77: .snow,
        80: .rainShowers, 81: .rainShowers, 82: .rainShowers,
        85: .snowShowers, 86: .snowShowers,
        95: .thunderstorm,
        96: .thunderstormWithHail, 99: .thunderstormWithHail
    ]
}
