import AtmosDomain
@testable import AtmosPresentation
import AtmosTesting
import Foundation
import Testing

/// The acceptance criteria of US-04 and US-05 that live in the presentation layer.
@MainActor
@Suite("CitiesViewModel")
struct CitiesViewModelTests {
    let cities = FakeCityRepository()
    let weather = FakeWeatherRepository()
    let places = SelectedPlaceStore()
    let istanbul = TestData.city(745_044, "İstanbul")
    let ankara = TestData.city(1, "Ankara")

    func makeViewModel(debounce: Duration = .zero, noticeDuration: Duration = .seconds(5)) -> CitiesViewModel {
        CitiesViewModel(
            searchCities: SearchCitiesUseCase(repository: cities),
            saveCity: SaveCityUseCase(repository: cities),
            removeCity: RemoveCityUseCase(repository: cities),
            observePlaces: ObservePlacesUseCase(repository: cities),
            getCachedForecast: GetCachedForecastUseCase(repository: weather),
            observeSettings: ObserveSettingsUseCase(repository: FakeSettingsRepository()),
            places: places,
            languageCode: { "tr" },
            debounce: debounce,
            noticeDuration: noticeDuration
        )
    }

    @Test("typing quickly searches only the last text")
    func debounce() async {
        let viewModel = makeViewModel(debounce: .milliseconds(100))

        viewModel.queryChanged("is")
        viewModel.queryChanged("ist")
        viewModel.queryChanged("ista")
        await viewModel.searchFinished()

        #expect(await cities.searches.map(\.query) == ["ista"])
    }

    @Test("fewer than 2 characters shows the saved list and searches nothing")
    func tooShort() async {
        let viewModel = makeViewModel()

        viewModel.queryChanged("i")
        await viewModel.searchFinished()

        #expect(viewModel.state.search == .idle)
        #expect(await cities.searches.isEmpty)
    }

    @Test("results are shown, searched in the app language")
    func results() async {
        await cities.setSearchResult(.success([istanbul]))
        let viewModel = makeViewModel()

        viewModel.queryChanged("ista")
        await viewModel.searchFinished()

        #expect(viewModel.state.search == .results([istanbul]))
        #expect(await cities.searches.map(\.languageCode) == ["tr"])
    }

    @Test("no match shows the empty message; a failure shows an error and retry searches again")
    func noMatchAndFailure() async {
        let viewModel = makeViewModel()
        viewModel.queryChanged("zzqqxx")
        await viewModel.searchFinished()
        #expect(viewModel.state.search == .noResults)

        await cities.setSearchResult(.failure(.noConnection))
        viewModel.retrySearch()
        await viewModel.searchFinished()
        #expect(viewModel.state.search == .failed(.noConnection))
    }

    @Test("adding a city saves it and clears the search")
    func add() async {
        let viewModel = makeViewModel()
        viewModel.queryChanged("ista")

        viewModel.add(istanbul)

        #expect(await eventually { viewModel.state.query.isEmpty })
        #expect(await eventuallyAsync { await cities.currentSaved() == [istanbul] })
    }

    @Test("adding a saved city again only tells the user")
    func alreadySaved() async {
        await cities.save(ankara)
        let viewModel = makeViewModel()

        viewModel.add(ankara)

        #expect(await eventually { viewModel.state.notice == .alreadySaved(ankara) })
        #expect(await cities.currentSaved() == [ankara])
    }

    @Test("removing a city offers undo, and undo restores it")
    func removeAndUndo() async {
        await cities.save(ankara)
        let viewModel = makeViewModel()

        viewModel.remove(ankara)
        #expect(await eventually { viewModel.state.notice == .removed(ankara) })
        #expect(await cities.currentSaved().isEmpty)

        viewModel.undo()
        #expect(viewModel.state.notice == nil)
        #expect(await eventuallyAsync { await cities.currentSaved() == [ankara] })
    }

    @Test("the undo notice disappears by itself")
    func noticeExpires() async {
        await cities.save(ankara)
        let viewModel = makeViewModel(noticeDuration: .milliseconds(50))

        viewModel.remove(ankara)

        #expect(await eventually { viewModel.state.notice == .removed(ankara) })
        #expect(await eventually { viewModel.state.notice == nil })
    }

    @Test("removing the city shown on Home switches Home back to the current location")
    func removeSelected() async {
        await cities.save(ankara)
        await places.select(.saved(ankara))
        let viewModel = makeViewModel()

        viewModel.remove(ankara)

        #expect(await eventuallyAsync { await places.current == .currentLocation })
    }

    @Test("saved cities show their last known temperature")
    func cachedTemperature() async {
        await weather.setCached(TestData.forecast())
        await cities.save(ankara)
        let viewModel = makeViewModel()
        let task = Task { await viewModel.run() }
        defer { task.cancel() }

        #expect(await eventually {
            viewModel.state.places.contains { $0.temperature == TestData.forecast().current.temperature }
        })
    }
}
