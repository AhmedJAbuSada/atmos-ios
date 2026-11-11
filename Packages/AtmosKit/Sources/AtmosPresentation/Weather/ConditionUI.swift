import AtmosDomain
import SwiftUI

/// How a ``WeatherCondition`` looks: a localized label and an SF Symbol. The domain knows
/// *what* the weather is; only the presentation layer knows how to say and draw it.
extension WeatherCondition {
    /// The String Catalog key, for example `condition.overcast`.
    var labelKey: String { "condition." + rawValue }

    /// Built from a plain `String`. Careful: `LocalizedStringKey("condition.\(rawValue)")`
    /// treats the interpolation as a format *argument* and looks up the key `condition.%@`,
    /// which does not exist, so the raw key appeared on screen (found in the screenshots).
    var label: LocalizedStringKey {
        LocalizedStringKey(labelKey)
    }

    /// At night a clear sky shows a moon, not a sun (US-01). SF Symbols are never mirrored in
    /// right-to-left layouts. They are drawn with ``ConditionIcon``'s colours: multicolour
    /// symbols draw clouds in white, which disappeared on light backgrounds.
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

/// A weather symbol with explicit colours that work on light and dark backgrounds: grey
/// clouds, a yellow sun or moon, blue rain, cyan snow and ice.
struct ConditionIcon: View {
    let condition: WeatherCondition
    var isDay = true

    var body: some View {
        let (primary, secondary) = colors
        Image(systemName: condition.symbolName(isDay: isDay))
            .symbolRenderingMode(.palette)
            .foregroundStyle(primary, secondary)
    }

    private var colors: (Color, Color) {
        switch condition {
        case .clear: (.yellow, .yellow)
        case .mainlyClear, .partlyCloudy: (.gray, .yellow)
        case .overcast, .fog, .unknown: (.gray, .gray)
        case .drizzle, .rain, .rainShowers: (.gray, .blue)
        case .freezingDrizzle, .freezingRain, .snow, .snowShowers, .thunderstormWithHail: (.gray, .cyan)
        case .thunderstorm: (.gray, .yellow)
        }
    }
}

extension DomainError {
    /// A human message for every error. The `switch` is exhaustive, so a new error case does
    /// not compile until it has a message (ADR-0006). `.cancelled` is never shown (ADR-0009);
    /// it maps to the generic text only so the switch is complete.
    var message: LocalizedStringKey {
        LocalizedStringKey(messageKey)
    }

    var messageKey: String {
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
