import AtmosDomain
@testable import AtmosPresentation
import Foundation
import Testing

/// Every key the code asks for must exist in the String Catalog, in every language.
///
/// This test exists because of a real bug: `LocalizedStringKey("condition.\(rawValue)")`
/// looked up `condition.%@`, and the screens showed "condition.overcast". No unit test noticed;
/// the CI screenshots did. This test makes sure it cannot come back.
@Suite("String Catalog")
struct StringCatalogTests {
    static let languages = ["en", "tr", "ar"]

    /// The catalog source file, read through this file's own path (one source of truth).
    static func catalog() throws -> [String: Any] {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<3 { url.deleteLastPathComponent() } // → Packages/AtmosKit
        url.appendPathComponent("Sources/AtmosPresentation/Resources/Localizable.xcstrings")
        let json = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
        return json?["strings"] as? [String: Any] ?? [:]
    }

    func assertTranslated(_ key: String, in strings: [String: Any]) {
        let localizations = (strings[key] as? [String: Any])?["localizations"] as? [String: Any] ?? [:]
        for language in Self.languages {
            #expect(localizations[language] != nil, "missing \(language) for \(key)")
        }
    }

    @Test("every weather condition has a label in en, tr and ar")
    func conditions() throws {
        let strings = try Self.catalog()
        for condition in WeatherCondition.allCases {
            assertTranslated(condition.labelKey, in: strings)
        }
    }

    @Test("every error has a message in en, tr and ar")
    func errors() throws {
        let strings = try Self.catalog()
        let errors: [DomainError] = [
            .noConnection, .timeout, .server(code: 500), .notFound,
            .locationPermissionDenied, .locationUnavailable, .cancelled, .unknown
        ]
        for error in errors {
            assertTranslated(error.messageKey, in: strings)
        }
    }

    @Test("every key in the catalog is translated into every language")
    func everyKey() throws {
        let strings = try Self.catalog()
        for key in strings.keys {
            assertTranslated(key, in: strings)
        }
    }
}
