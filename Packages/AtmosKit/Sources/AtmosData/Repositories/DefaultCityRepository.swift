import AtmosDomain

/// ``CityRepository``: search on Open-Meteo geocoding, favourites in a ``JSONFileStore``.
actor DefaultCityRepository: CityRepository {
    private static let savedKey = "saved-cities"
    private let api: OpenMeteoAPI
    private let store: JSONFileStore
    private var saved: ValueStream<[City]>?

    init(api: OpenMeteoAPI, store: JSONFileStore) {
        self.api = api
        self.store = store
    }

    func search(_ query: String, languageCode: String) async throws(DomainError) -> [City] {
        do {
            return CityMapper.map(try await api.searchCities(name: query, languageCode: languageCode))
        } catch {
            throw DomainError.from(error)
        }
    }

    func savedCities() async -> AsyncStream<[City]> {
        await savedStream().values()
    }

    func save(_ city: City) async {
        let stream = await savedStream()
        let list = await stream.value
        guard !list.contains(where: { $0.id == city.id }) else { return } // keeps its position
        await persist(list + [city], to: stream)
    }

    func remove(cityID: Int) async {
        let stream = await savedStream()
        await persist(await stream.value.filter { $0.id != cityID }, to: stream)
    }

    /// Loaded from disk on first use, then kept in memory and observed.
    private func savedStream() async -> ValueStream<[City]> {
        if let saved { return saved }
        let stream = ValueStream(await store.read([City].self, key: Self.savedKey) ?? [])
        saved = stream
        return stream
    }

    private func persist(_ list: [City], to stream: ValueStream<[City]>) async {
        try? await store.write(list, key: Self.savedKey)
        await stream.send(list)
    }
}
