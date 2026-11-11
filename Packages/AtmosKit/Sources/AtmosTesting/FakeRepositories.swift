import AtmosDomain

/// In-memory ``WeatherRepository`` that also counts downloads. Fakes are preferred over
/// mocks here: they behave like the real thing, so tests check outcomes, not calls.
public actor FakeWeatherRepository: WeatherRepository {
    public var cached: Forecast?
    public var fetchResult: Result<Forecast, DomainError>
    public private(set) var fetchCount = 0

    public init(cached: Forecast? = nil, fetchResult: Result<Forecast, DomainError> = .success(TestData.forecast())) {
        self.cached = cached
        self.fetchResult = fetchResult
    }

    public func setCached(_ forecast: Forecast?) { cached = forecast }

    public func setFetchResult(_ result: Result<Forecast, DomainError>) { fetchResult = result }

    public func cachedForecast(for coordinates: Coordinates) async -> Forecast? { cached }

    public func fetchForecast(for coordinates: Coordinates) async throws(DomainError) -> Forecast {
        fetchCount += 1
        let forecast = try fetchResult.get()
        cached = forecast
        return forecast
    }
}

public actor FakeCityRepository: CityRepository {
    public var searchResult: Result<[City], DomainError>
    /// Every (query, language) the use case sent to the "network".
    public private(set) var searches: [(query: String, languageCode: String)] = []
    private let saved = ValueStream<[City]>([])

    public init(searchResult: Result<[City], DomainError> = .success([])) {
        self.searchResult = searchResult
    }

    public func setSearchResult(_ result: Result<[City], DomainError>) { searchResult = result }

    public func search(_ query: String, languageCode: String) async throws(DomainError) -> [City] {
        searches.append((query, languageCode))
        return try searchResult.get()
    }

    public func savedCities() async -> AsyncStream<[City]> { await saved.values() }

    public func save(_ city: City) async {
        let list = await saved.value
        guard !list.contains(where: { $0.id == city.id }) else { return }
        await saved.send(list + [city])
    }

    public func remove(cityID: Int) async {
        await saved.send(await saved.value.filter { $0.id != cityID })
    }

    public func currentSaved() async -> [City] { await saved.value }
}

public actor FakeLocationRepository: LocationRepository {
    public var result: Result<Coordinates, DomainError>

    public init(result: Result<Coordinates, DomainError> = .success(TestData.istanbul)) {
        self.result = result
    }

    public func setResult(_ result: Result<Coordinates, DomainError>) { self.result = result }

    public func currentLocation() async throws(DomainError) -> Coordinates { try result.get() }
}

public actor FakeSettingsRepository: SettingsRepository {
    private let stream: ValueStream<UserSettings>

    public init(_ initial: UserSettings = UserSettings()) {
        stream = ValueStream(initial)
    }

    public func settings() async -> AsyncStream<UserSettings> { await stream.values() }

    public func update(_ transform: @Sendable (UserSettings) -> UserSettings) async {
        await stream.send(transform(await stream.value))
    }

    public func current() async -> UserSettings { await stream.value }
}
