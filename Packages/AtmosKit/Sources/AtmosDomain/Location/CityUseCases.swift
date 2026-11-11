/// Searches cities by name (US-04).
///
/// The rules live here, not in the UI: the query is trimmed, and fewer than
/// ``minimumQueryLength`` characters returns no results **without** a network call.
/// Debouncing (waiting 300 ms after typing stops) is a UI concern, in the view model.
public struct SearchCitiesUseCase: Sendable {
    public static let minimumQueryLength = 2
    private let repository: any CityRepository

    public init(repository: any CityRepository) {
        self.repository = repository
    }

    public func callAsFunction(_ query: String, languageCode: String) async throws(DomainError) -> [City] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= Self.minimumQueryLength else { return [] }
        return try await repository.search(trimmed, languageCode: languageCode)
    }
}

/// The outcome of ``SaveCityUseCase``; the UI shows a different message for each.
public enum SaveCityResult: Equatable, Sendable {
    case saved, alreadySaved
}

/// Saves a city to the favourites. Saving the same city twice does nothing (US-05).
public struct SaveCityUseCase: Sendable {
    private let repository: any CityRepository

    public init(repository: any CityRepository) {
        self.repository = repository
    }

    public func callAsFunction(_ city: City) async -> SaveCityResult {
        let saved = await repository.savedCities().first { _ in true } ?? []
        if saved.contains(where: { $0.id == city.id }) { return .alreadySaved }
        await repository.save(city)
        return .saved
    }
}

/// Removes a saved city. Saving it again is the "Undo" (US-05).
public struct RemoveCityUseCase: Sendable {
    private let repository: any CityRepository

    public init(repository: any CityRepository) {
        self.repository = repository
    }

    public func callAsFunction(cityID: Int) async {
        await repository.remove(cityID: cityID)
    }
}

/// The places list: the current location first, then the saved cities (US-05).
public struct ObservePlacesUseCase: Sendable {
    private let repository: any CityRepository

    public init(repository: any CityRepository) {
        self.repository = repository
    }

    public func callAsFunction() async -> AsyncStream<[Place]> {
        let cities = await repository.savedCities()
        return AsyncStream { continuation in
            let task = Task {
                for await list in cities {
                    continuation.yield([.currentLocation] + list.map(Place.saved))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
