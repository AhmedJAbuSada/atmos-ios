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
        if !isDay, let night = Self.nightSymbols[self] { return night }
        return Self.symbols[self] ?? "questionmark.circle"
    }

    private static let symbols: [WeatherCondition: String] = [
        .clear: "sun.max.fill",
        .mainlyClear: "cloud.sun.fill",
        .partlyCloudy: "cloud.sun.fill",
        .overcast: "cloud.fill",
        .fog: "cloud.fog.fill",
        .drizzle: "cloud.drizzle.fill",
        .freezingDrizzle: "cloud.sleet.fill",
        .rain: "cloud.rain.fill",
        .freezingRain: "cloud.sleet.fill",
        .snow: "cloud.snow.fill",
        .rainShowers: "cloud.heavyrain.fill",
        .snowShowers: "cloud.snow.fill",
        .thunderstorm: "cloud.bolt.rain.fill",
        .thunderstormWithHail: "cloud.hail.fill",
        .unknown: "questionmark.circle"
    ]

    private static let nightSymbols: [WeatherCondition: String] = [
        .clear: "moon.stars.fill",
        .mainlyClear: "cloud.moon.fill",
        .partlyCloudy: "cloud.moon.fill"
    ]
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
