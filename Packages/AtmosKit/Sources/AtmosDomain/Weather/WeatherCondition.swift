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
        self = switch code {
        case 0: .clear
        case 1: .mainlyClear
        case 2: .partlyCloudy
        case 3: .overcast
        case 45, 48: .fog
        case 51, 53, 55: .drizzle
        case 56, 57: .freezingDrizzle
        case 61, 63, 65: .rain
        case 66, 67: .freezingRain
        case 71, 73, 75, 77: .snow
        case 80, 81, 82: .rainShowers
        case 85, 86: .snowShowers
        case 95: .thunderstorm
        case 96, 99: .thunderstormWithHail
        default: .unknown
        }
    }
}
