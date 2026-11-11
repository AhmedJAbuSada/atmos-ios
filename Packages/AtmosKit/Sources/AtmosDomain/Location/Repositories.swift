/// The device location. Implemented with CoreLocation in AtmosData (step 04).
public protocol LocationRepository: Sendable {
    /// The current position. Throws `.locationPermissionDenied` or `.locationUnavailable`.
    func currentLocation() async throws(DomainError) -> Coordinates
}

/// City search (remote) and the saved-cities list (local).
public protocol CityRepository: Sendable {
    /// Searches by name. `languageCode` selects the language of the returned names.
    func search(_ query: String, languageCode: String) async throws(DomainError) -> [City]

    /// Saved cities, oldest first: the current list, then every change.
    func savedCities() async -> AsyncStream<[City]>

    /// Saves `city`. A city with an id that is already saved keeps its position.
    func save(_ city: City) async

    /// Removes the saved city with `cityID`. Does nothing if it is not saved.
    func remove(cityID: Int) async
}
