/// A city from the geocoding search (F-05) or the saved list (F-06).
///
/// `id` comes from the geocoding service and is stable, so it identifies a saved city (no
/// duplicates, US-05). Names are already in the language used for the search.
public struct City: Identifiable, Equatable, Hashable, Sendable, Codable {
    public let id: Int
    public let name: String
    public let region: String?
    public let country: String?
    public let countryCode: String?
    public let coordinates: Coordinates

    public init(
        id: Int,
        name: String,
        region: String?,
        country: String?,
        countryCode: String?,
        coordinates: Coordinates
    ) {
        self.id = id
        self.name = name
        self.region = region
        self.country = country
        self.countryCode = countryCode
        self.coordinates = coordinates
    }
}

/// An entry in the places list. The current location is always first and cannot be removed
/// (US-05); saved cities follow in the order they were added.
public enum Place: Equatable, Hashable, Sendable {
    case currentLocation
    case saved(City)
}
