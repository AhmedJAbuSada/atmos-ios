import AtmosDomain
import AtmosTesting
import Foundation
import Testing

@Suite("Coordinates")
struct CoordinatesTests {
    @Test("accepts the edges of the valid range")
    func edges() {
        #expect(Coordinates(latitude: 90, longitude: 180) != nil)
        #expect(Coordinates(latitude: -90, longitude: -180) != nil)
    }

    @Test("refuses impossible values", arguments: [(999.0, 28.0), (41.0, -181.0)])
    func impossible(latitude: Double, longitude: Double) {
        // The API answers 400 for latitude 999 (docs/api/samples/forecast_error.json).
        #expect(Coordinates(latitude: latitude, longitude: longitude) == nil)
    }
}

/// Acceptance criteria of US-04 that belong to the domain.
@Suite("SearchCitiesUseCase")
struct SearchCitiesUseCaseTests {
    @Test("given fewer than 2 characters, then no search is made", arguments: ["i", "  i  ", ""])
    func tooShort(query: String) async throws {
        let repository = FakeCityRepository()

        #expect(try await SearchCitiesUseCase(repository: repository)(query, languageCode: "tr").isEmpty)
        #expect(await repository.searches.isEmpty)
    }

    @Test("given a valid query, then searches the trimmed text in the requested language")
    func trimmedQuery() async throws {
        let repository = FakeCityRepository()

        _ = try await SearchCitiesUseCase(repository: repository)("  ista ", languageCode: "tr")

        let searches = await repository.searches
        #expect(searches.map(\.query) == ["ista"])
        #expect(searches.map(\.languageCode) == ["tr"])
    }

    @Test("given no city matches, then returns an empty list, not an error")
    func noMatch() async throws {
        #expect(try await SearchCitiesUseCase(repository: FakeCityRepository())("zzqqxx", languageCode: "en").isEmpty)
    }

    @Test("given the network fails, then throws the error")
    func networkFailure() async {
        let repository = FakeCityRepository(searchResult: .failure(.noConnection))

        await #expect(throws: DomainError.noConnection) {
            try await SearchCitiesUseCase(repository: repository)("ista", languageCode: "en")
        }
    }
}

/// Acceptance criteria of US-05 (favourite cities).
@Suite("City use cases")
struct CityUseCasesTests {
    let ankara = TestData.city(1, "Ankara")
    let london = TestData.city(2, "London")

    @Test("given no saved cities, then the list holds only the current location")
    func onlyCurrentLocation() async {
        let places = await ObservePlacesUseCase(repository: FakeCityRepository())()
        #expect(await places.first { _ in true } == [.currentLocation])
    }

    @Test("saved cities follow the current location, in the order they were added")
    func order() async {
        let repository = FakeCityRepository()
        _ = await SaveCityUseCase(repository: repository)(ankara)
        _ = await SaveCityUseCase(repository: repository)(london)

        let places = await ObservePlacesUseCase(repository: repository)()

        #expect(await places.first { _ in true } == [.currentLocation, .saved(ankara), .saved(london)])
    }

    @Test("saving a city twice changes nothing the second time")
    func duplicate() async {
        let repository = FakeCityRepository()
        let save = SaveCityUseCase(repository: repository)

        #expect(await save(ankara) == .saved)
        #expect(await save(ankara) == .alreadySaved)
        #expect(await repository.currentSaved() == [ankara])
    }

    @Test("removing a city, then saving it again (undo), restores it")
    func removeAndUndo() async {
        let repository = FakeCityRepository()
        _ = await SaveCityUseCase(repository: repository)(ankara)

        await RemoveCityUseCase(repository: repository)(cityID: ankara.id)
        #expect(await repository.currentSaved().isEmpty)

        _ = await SaveCityUseCase(repository: repository)(ankara)
        #expect(await repository.currentSaved() == [ankara])
    }

    @Test("observers see a removed city disappear")
    func observeRemoval() async {
        let repository = FakeCityRepository()
        _ = await SaveCityUseCase(repository: repository)(ankara)
        var iterator = await ObservePlacesUseCase(repository: repository)().makeAsyncIterator()
        _ = await iterator.next()

        await RemoveCityUseCase(repository: repository)(cityID: ankara.id)

        #expect(await iterator.next() == [.currentLocation])
    }
}

@Suite("GetCurrentLocationForecastUseCase")
struct GetCurrentLocationForecastUseCaseTests {
    @Test("given a location, then returns its forecast")
    func located() async throws {
        let weather = FakeWeatherRepository()
        let useCase = GetCurrentLocationForecastUseCase(
            locations: FakeLocationRepository(),
            getForecast: GetForecastUseCase(repository: weather, freshness: ForecastFreshness(dates: FixedDateProvider()))
        )

        #expect(try await useCase().forecast == TestData.forecast())
    }

    @Test("given permission is denied, then throws that error without fetching weather")
    func denied() async {
        let weather = FakeWeatherRepository()
        let useCase = GetCurrentLocationForecastUseCase(
            locations: FakeLocationRepository(result: .failure(.locationPermissionDenied)),
            getForecast: GetForecastUseCase(repository: weather, freshness: ForecastFreshness(dates: FixedDateProvider()))
        )

        await #expect(throws: DomainError.locationPermissionDenied) { try await useCase() }
        #expect(await weather.fetchCount == 0)
    }
}
