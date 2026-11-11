import AtmosDomain
import Foundation

/// Turns domain values into text for one locale and one place's time zone (ADR-0005).
///
/// Why not `"\(value)°"`? Because the locale changes more than the words: Turkish writes
/// `%69` and `6,9 m/s`, and Arabic is set to Latin digits by product decision. Every value is
/// also wrapped in Unicode **directional isolates**, so an Arabic sentence cannot reorder
/// `11°` into `°11` (a bug the Android version found through screenshots).
public struct WeatherFormatter: Sendable {
    public let locale: Locale
    public let timeZone: TimeZone

    public init(locale: Locale, timeZone: TimeZone) {
        self.locale = Self.displayLocale(locale)
        self.timeZone = timeZone
    }

    /// `15°`: whole degrees, decimals add noise to a weather glance.
    public func temperature(_ value: Temperature, unit: TemperatureUnit) -> String {
        Self.isolate(integer(value.value(in: unit)) + "°")
    }

    /// `25 km/h`, `6,9 m/s` in Turkish, `15 mph`. Metres per second keep one decimal.
    /// Unit symbols are international (SI) and are not translated.
    public func windSpeed(_ value: WindSpeed, unit: WindSpeedUnit) -> String {
        let number = value.value(in: unit)
        let text: String
        switch unit {
        case .kilometersPerHour: text = integer(number) + " km/h"
        case .metersPerSecond: text = decimal(number) + " m/s"
        case .milesPerHour: text = integer(number) + " mph"
        }
        return Self.isolate(text)
    }

    /// `69%`, `%69` in Turkish.
    public func percentage(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .percent
        return Self.isolate(formatter.string(from: NSNumber(value: Double(value) / 100)) ?? "\(value)%")
    }

    /// `14:00` or `2:00 PM`, as the locale prefers, in the place's time zone.
    public func hour(_ date: Date) -> String {
        var style = Date.FormatStyle(date: .omitted, time: .shortened)
        style.locale = locale
        style.timeZone = timeZone
        return Self.isolate(date.formatted(style))
    }

    /// `Thursday`, `Perşembe`, `الخميس`.
    public func dayName(_ date: Date) -> String {
        var style = Date.FormatStyle().weekday(.wide)
        style.locale = locale
        style.timeZone = timeZone
        return date.formatted(style)
    }

    private func integer(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value.rounded())) ?? String(Int(value.rounded()))
    }

    private func decimal(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    /// Keeps `value` left to right and in one piece, whatever text surrounds it
    /// (Unicode UAX #9: LEFT-TO-RIGHT ISOLATE … POP DIRECTIONAL ISOLATE).
    public static func isolate(_ value: String) -> String {
        "\u{2066}\(value)\u{2069}"
    }

    /// Arabic with Latin digits (ADR-0005, point 7): without `numbers=latn`, Foundation
    /// formats `15` as `١٥`. Other languages are unchanged.
    static func displayLocale(_ locale: Locale) -> Locale {
        guard locale.language.languageCode?.identifier == "ar" else { return locale }
        return Locale(identifier: locale.identifier + "@numbers=latn")
    }
}
