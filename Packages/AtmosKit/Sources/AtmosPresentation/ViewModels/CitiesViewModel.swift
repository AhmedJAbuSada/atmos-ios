import AtmosDomain
import Foundation
import Observation

/// City search and the saved places (US-04, US-05).
@MainActor
@Observable
public final class CitiesViewModel {
    public private(set) var state = CitiesState()

    private let searchCities: SearchCitiesUseCase
    private let saveCity: SaveCityUseCase
    private let removeCity: RemoveCityUseCase
    private let observePlaces: ObservePlacesUseCase
    private let getCachedForecast: GetCachedForecastUseCase
    private let observeSettings: ObserveSettingsUseCase
    private let places: SelectedPlaceStore
    private let languageCode: @Sendable () -> String
    private let debounce: Duration
    private let noticeDuration: Duration

    private var searchTask: Task<Void, Never>?
    private var noticeTask: Task<Void, Never>?

    public init(
        searchCities: SearchCitiesUseCase,
        saveCity: SaveCityUseCase,
        removeCity: RemoveCityUseCase,
        observePlaces: ObservePlacesUseCase,
        getCachedForecast: GetCachedForecastUseCase,
        observeSettings: ObserveSettingsUseCase,
        places: SelectedPlaceStore,
        languageCode: @escaping @Sendable () -> String,
        debounce: Duration = .milliseconds(300),
        noticeDuration: Duration = .seconds(5)
    ) {
        self.searchCities = searchCities
        self.saveCity = saveCity
        self.removeCity = removeCity
        self.observePlaces = observePlaces
        self.getCachedForecast = getCachedForecast
        self.observeSettings = observeSettings
        self.places = places
        self.languageCode = languageCode
        self.debounce = debounce
        self.noticeDuration = noticeDuration
    }

    public func run() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.followPlaces() }
            group.addTask { await self.followSettings() }
        }
    }

    /// Searches as the user types (US-04): each keystroke cancels the previous search, which
    /// waits `debounce` first, so only the last one reaches the network.
    public func queryChanged(_ query: String) {
        state.query = query
        searchTask?.cancel()
        searchTask = Task { await search(query) }
    }

    public func retrySearch() {
        queryChanged(state.query)
    }

    public func add(_ city: City) {
        Task {
            switch await saveCity(city) {
            case .saved: queryChanged("")
            case .alreadySaved: show(.alreadySaved(city))
            }
        }
    }

    public func remove(_ city: City) {
        Task {
            await removeCity(cityID: city.id)
            await places.cityRemoved(city)
            show(.removed(city))
        }
    }

    /// "Undo": saving the city again restores it (US-05).
    public func undo() {
        guard case let .removed(city) = state.notice else { return }
        state.notice = nil
        Task { _ = await saveCity(city) }
    }

    public func select(_ place: Place) async {
        await places.select(place)
    }

    /// Waits until the current search is finished. For tests.
    func searchFinished() async {
        await searchTask?.value
    }

    private func search(_ query: String) async {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count >= SearchCitiesUseCase.minimumQueryLength else {
            state.search = .idle
            return
        }
        do {
            try await Task.sleep(for: debounce)
        } catch {
            return // a newer keystroke cancelled this search
        }
        state.search = .searching
        do {
            let cities = try await searchCities(text, languageCode: languageCode())
            guard !Task.isCancelled else { return }
            state.search = cities.isEmpty ? .noResults : .results(cities)
        } catch .cancelled {
            return
        } catch {
            state.search = .failed(error)
        }
    }

    private func followPlaces() async {
        for await list in await observePlaces() {
            var items: [PlaceItem] = []
            for place in list {
                guard case let .saved(city) = place else {
                    items.append(PlaceItem(place: place))
                    continue
                }
                let cached = await getCachedForecast(for: city.coordinates)
                items.append(PlaceItem(
                    place: place,
                    temperature: cached?.current.temperature,
                    condition: cached?.current.condition
                ))
            }
            state.places = items
        }
    }

    private func followSettings() async {
        for await settings in await observeSettings() {
            state.temperatureUnit = settings.temperatureUnit
        }
    }

    /// Shows a notice and hides it after `noticeDuration` (the undo window).
    private func show(_ notice: CitiesNotice) {
        state.notice = notice
        noticeTask?.cancel()
        noticeTask = Task {
            try? await Task.sleep(for: noticeDuration)
            if !Task.isCancelled, state.notice == notice { state.notice = nil }
        }
    }
}
