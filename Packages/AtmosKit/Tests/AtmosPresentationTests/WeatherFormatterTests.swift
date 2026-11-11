@testable import AtmosPresentation
import AtmosDomain
import Foundation
import Testing

/// The same values, formatted in all three app languages (ADR-0005).
@Suite("WeatherFormatter")
struct WeatherFormatterTests {
    let istanbul = TimeZone(identifier: "Europe/Istanbul") ?? .gmt

    func formatter(_ language: String) -> WeatherFormatter {
        WeatherFormatter(locale: Locale(identifier: language), timeZone: istanbul)
    }

    @Test("temperatures are whole degrees in the chosen unit")
    func temperatures() {
        let english = formatter("en")
        #expect(english.temperature(Temperature(celsius: 14.9), unit: .celsius).visible == "15°")
        #expect(english.temperature(Temperature(celsius: 14.9), unit: .fahrenheit).visible == "59°")
        #expect(english.temperature(Temperature(celsius: -2.6), unit: .celsius).visible.hasSuffix("3°"))
    }

    @Test("Arabic uses Western digits, as decided in ADR-0005")
    func arabicDigits() {
        let arabic = formatter("ar")
        #expect(arabic.temperature(Temperature(celsius: 14.9), unit: .celsius).visible == "15°")
        #expect(arabic.windSpeed(WindSpeed(kilometersPerHour: 24.8), unit: .kilometersPerHour).visible == "25 km/h")
    }

    @Test("Turkish uses a decimal comma")
    func turkishComma() {
        let wind = WindSpeed(kilometersPerHour: 24.8)
        #expect(formatter("tr").windSpeed(wind, unit: .metersPerSecond).visible == "6,9 m/s")
        #expect(formatter("en").windSpeed(wind, unit: .metersPerSecond).visible == "6.9 m/s")
    }

    @Test("Turkish puts the percent sign first")
    func turkishPercent() {
        #expect(formatter("en").percentage(69).visible == "69%")
        #expect(formatter("tr").percentage(69).visible == "%69")
    }

    @Test("day names are in the app language and the place's time zone")
    func dayNames() {
        // 2026-11-12 is a Thursday in Istanbul.
        let thursday = Date(timeIntervalSince1970: 1_794_470_400 + 6 * 3600)
        #expect(formatter("en").dayName(thursday) == "Thursday")
        #expect(formatter("tr").dayName(thursday) == "Perşembe")
        #expect(formatter("ar").dayName(thursday) == "الخميس")
    }

    @Test("every value is isolated, so Arabic text cannot reorder it")
    func isolation() {
        let wind = formatter("ar").windSpeed(WindSpeed(kilometersPerHour: 24.8), unit: .kilometersPerHour)
        #expect(wind.unicodeScalars.first == "\u{2066}")
        #expect(wind.unicodeScalars.last == "\u{2069}")
    }
}

private extension String {
    /// The visible text, without the invisible directional isolates.
    var visible: String { String(unicodeScalars.filter { $0 != "\u{2066}" && $0 != "\u{2069}" }) }
}
