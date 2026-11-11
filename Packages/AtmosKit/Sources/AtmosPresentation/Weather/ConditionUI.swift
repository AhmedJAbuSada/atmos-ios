import AtmosDomain
import SwiftUI

/// How a ``WeatherCondition`` looks: a localized label and an SF Symbol. The domain knows
/// *what* the weather is; only the presentation layer knows how to say and draw it.
extension WeatherCondition {
    var label: LocalizedStringKey {
        LocalizedStringKey("condition.\(rawValue)")
    }

    /// At night a clear sky shows a moon, not a sun (US-01). Multicolour SF Symbols look right
    /// in light and dark mode and are never mirrored in right-to-left layouts.
    func symbolName(isDay: Bool = true) -> String {
        switch self {
        case .clear: isDay ? "sun.max.fill" : "moon.stars.fill"
        case .mainlyClear, .partlyCloudy: isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case .overcast: "cloud.fill"
        case .fog: "cloud.fog.fill"
        case .drizzle: "cloud.drizzle.fill"
        case .freezingDrizzle, .freezingRain: "cloud.sleet.fill"
        case .rain: "cloud.rain.fill"
        case .rainShowers: "cloud.heavyrain.fill"
        case .snow, .snowShowers: "cloud.snow.fill"
        case .thunderstorm: "cloud.bolt.rain.fill"
        case .thunderstormWithHail: "cloud.hail.fill"
        case .unknown: "questionmark.circle"
        }
    }
}

extension DomainError {
    /// A human message for every error. The `switch` is exhaustive, so a new error case does
    /// not compile until it has a message (ADR-0006). `.cancelled` is never shown (ADR-0009);
    /// it maps to the generic text only so the switch is complete.
    var message: LocalizedStringKey {
        switch self {
        case .noConnection: "error.noConnection"
        case .timeout: "error.timeout"
        case .server: "error.server"
        case .notFound: "error.notFound"
        case .locationPermissionDenied: "error.locationDenied"
        case .locationUnavailable: "error.locationUnavailable"
        case .cancelled, .unknown: "error.unknown"
        }
    }
}
