import AtmosDomain

/// The Cities screen (US-04, US-05): a search field over the saved places.
public struct CitiesState: Equatable, Sendable {
    public var query: String
    public var search: SearchState
    public var places: [PlaceItem]
    public var temperatureUnit: TemperatureUnit
    /// A short message under the list; "removed" offers Undo for a few seconds (US-05).
    public var notice: CitiesNotice?

    public init(
        query: String = "",
        search: SearchState = .idle,
        places: [PlaceItem] = [],
        temperatureUnit: TemperatureUnit = .celsius,
        notice: CitiesNotice? = nil
    ) {
        self.query = query
        self.search = search
        self.places = places
        self.temperatureUnit = temperatureUnit
        self.notice = notice
    }
}

public enum CitiesNotice: Equatable, Sendable {
    case removed(City)
    case alreadySaved(City)
}

/// The area under the search field. `idle` shows the saved places instead.
public enum SearchState: Equatable, Sendable {
    case idle
    case searching
    case results([City])
    case noResults
    case failed(DomainError)
}

/// A row in the places list, with its last known weather when there is one.
public struct PlaceItem: Equatable, Sendable, Identifiable {
    public let place: Place
    public let temperature: Temperature?
    public let condition: WeatherCondition?

    public var id: String {
        switch place {
        case .currentLocation: "current"
        case let .saved(city): "city-\(city.id)"
        }
    }

    public init(place: Place, temperature: Temperature? = nil, condition: WeatherCondition? = nil) {
        self.place = place
        self.temperature = temperature
        self.condition = condition
    }
}

@MainActor
public struct CitiesActions {
    public var queryChanged: @MainActor (String) -> Void
    public var retrySearch: @MainActor () -> Void
    public var add: @MainActor (City) -> Void
    public var remove: @MainActor (City) -> Void
    public var select: @MainActor (Place) -> Void
    public var undo: @MainActor () -> Void

    public init(
        queryChanged: @escaping @MainActor (String) -> Void,
        retrySearch: @escaping @MainActor () -> Void,
        add: @escaping @MainActor (City) -> Void,
        remove: @escaping @MainActor (City) -> Void,
        select: @escaping @MainActor (Place) -> Void,
        undo: @escaping @MainActor () -> Void
    ) {
        self.queryChanged = queryChanged
        self.retrySearch = retrySearch
        self.add = add
        self.remove = remove
        self.select = select
        self.undo = undo
    }

    public static var none: CitiesActions {
        CitiesActions(
            queryChanged: { _ in }, retrySearch: {}, add: { _ in }, remove: { _ in }, select: { _ in }, undo: {}
        )
    }
}
