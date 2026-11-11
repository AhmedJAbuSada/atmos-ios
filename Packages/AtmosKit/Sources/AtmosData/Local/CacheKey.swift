import AtmosDomain
import Foundation

extension Coordinates {
    /// The cache key for a place: coordinates rounded to 2 decimals (about 1 km), so tiny GPS
    /// changes reuse the same entry.
    ///
    /// The fixed `en_US_POSIX` locale is essential. With the user's locale, a Turkish phone
    /// writes `41,01` and an Arabic one may use Arabic-Indic digits, and the cache written in
    /// one language would never be found in another (the same bug was found on Android).
    var cacheKey: String {
        let posix = Locale(identifier: "en_US_POSIX")
        return String(format: "%.2f,%.2f", locale: posix, latitude, longitude)
    }
}
