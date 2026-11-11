/// A point on Earth in decimal degrees. The initializer fails for impossible values, so the
/// rest of the app never has to check them (the API answers 400 for latitude 999).
public struct Coordinates: Equatable, Hashable, Sendable, Codable {
    public let latitude: Double
    public let longitude: Double

    public init?(latitude: Double, longitude: Double) {
        guard (-90...90).contains(latitude), (-180...180).contains(longitude) else { return nil }
        self.latitude = latitude
        self.longitude = longitude
    }
}
