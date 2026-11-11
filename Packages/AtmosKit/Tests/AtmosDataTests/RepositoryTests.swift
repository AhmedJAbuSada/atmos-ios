@testable import AtmosData
import AtmosDomain
import AtmosTesting
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing

@Suite("Cache key")
struct CacheKeyTests {
    @Test("rounds to 2 decimals, with a dot, whatever the phone's language")
    func key() throws {
        let place = try #require(Coordinates(latitude: 41.0123, longitude: 28.9711))
        #expect(place.cacheKey == "41.01,28.97")
        let nearby = try #require(Coordinates(latitude: 41.0149, longitude: 28.9749))
        #expect(nearby.cacheKey == place.cacheKey)
    }
}

@Suite("DefaultWeatherRepository")
struct DefaultWeatherRepositoryTests {
    func repository(_ replies: [FakeHTTPClient.Reply]) -> (DefaultWeatherRepository, JSONFileStore) {
        let store = JSONFileStore(directory: temporaryDirectory())
        let api = OpenMeteoAPI(client: FakeHTTPClient(replies))
        return (DefaultWeatherRepository(api: api, store: store, dates: FixedDateProvider()), store)
    }

    @Test("a successful fetch returns the forecast and caches it")
    func fetchAndCache() async throws {
        let (repository, _) = repository([.response(try Samples.data("forecast_istanbul.json"), 200)])

        let fetched = try await repository.fetchForecast(for: TestData.istanbul)
        let cached = await repository.cachedForecast(for: TestData.istanbul)

        #expect(fetched.fetchedAt == TestData.now)
        #expect(cached == fetched)
    }

    @Test("given nothing was fetched, then there is no cache")
    func noCache() async {
        #expect(await repository([]).0.cachedForecast(for: TestData.istanbul) == nil)
    }

    @Test("errors are mapped and nothing is cached")
    func failure() async {
        let (repository, _) = repository([.response(Data(), 503)])

        await #expect(throws: DomainError.server(code: 503)) {
            try await repository.fetchForecast(for: TestData.istanbul)
        }
        #expect(await repository.cachedForecast(for: TestData.istanbul) == nil)
    }

    @Test("a response without current conditions is rejected and not cached")
    func invalid() async {
        let (repository, _) = repository([.response(Data(#"{"timezone":"UTC"}"#.utf8), 200)])

        await #expect(throws: DomainError.unknown) { try await repository.fetchForecast(for: TestData.istanbul) }
        #expect(await repository.cachedForecast(for: TestData.istanbul) == nil)
    }

    @Test("offline is reported as no connection")
    func offline() async {
        let (repository, _) = repository([.failure(URLError(.notConnectedToInternet))])

        await #expect(throws: DomainError.noConnection) { try await repository.fetchForecast(for: TestData.istanbul) }
    }

    @Test("an unreadable cache entry is treated as no cache")
    func corruptCache() async throws {
        let (repository, store) = repository([])
        try await store.write("not a forecast", key: "forecast-" + TestData.istanbul.cacheKey)

        #expect(await repository.cachedForecast(for: TestData.istanbul) == nil)
    }
}

@Suite("DefaultCityRepository")
struct DefaultCityRepositoryTests {
    @Test("search returns cities in the requested language; no match is an empty list")
    func search() async throws {
        let fake = FakeHTTPClient([
            .response(try Samples.data("geocoding_istanbul_ar.json"), 200),
            .response(try Samples.data("geocoding_empty.json"), 200)
        ])
        let repository = DefaultCityRepository(
            api: OpenMeteoAPI(client: fake),
            store: JSONFileStore(directory: temporaryDirectory())
        )

        #expect(try await repository.search("Istanbul", languageCode: "ar").first?.name == "اسطنبول")
        #expect(try await repository.search("zzqqxx", languageCode: "en").isEmpty)
    }

    @Test("saved cities survive a restart, in order, without duplicates")
    func persistence() async throws {
        let directory = temporaryDirectory()
        let api = OpenMeteoAPI(client: FakeHTTPClient([]))
        let first = DefaultCityRepository(api: api, store: JSONFileStore(directory: directory))
        await first.save(TestData.city(1, "Ankara"))
        await first.save(TestData.city(2, "London"))
        await first.save(TestData.city(1, "Ankara"))

        let restarted = DefaultCityRepository(api: api, store: JSONFileStore(directory: directory))
        let saved = await restarted.savedCities().first { _ in true }

        #expect(saved?.map(\.name) == ["Ankara", "London"])
    }

    @Test("observers see a removed city disappear")
    func removal() async {
        let repository = DefaultCityRepository(
            api: OpenMeteoAPI(client: FakeHTTPClient([])),
            store: JSONFileStore(directory: temporaryDirectory())
        )
        await repository.save(TestData.city(1, "Ankara"))
        var iterator = await repository.savedCities().makeAsyncIterator()
        _ = await iterator.next()

        await repository.remove(cityID: 1)

        #expect(await iterator.next() == [])
    }
}

@Suite("UserDefaultsSettingsRepository")
struct SettingsRepositoryTests {
    @Test("first run returns the defaults")
    func defaults() async {
        let repository = UserDefaultsSettingsRepository(suiteName: "atmos-tests-\(UUID().uuidString)")
        #expect(await repository.settings().first { _ in true } == UserSettings())
    }

    @Test("settings are saved and survive a restart")
    func persistence() async {
        let suite = "atmos-tests-\(UUID().uuidString)"
        await UserDefaultsSettingsRepository(suiteName: suite).update { _ in
            UserSettings(temperatureUnit: .fahrenheit, windSpeedUnit: .milesPerHour, theme: .dark)
        }

        let restarted = UserDefaultsSettingsRepository(suiteName: suite)

        #expect(await restarted.settings().first { _ in true }
            == UserSettings(temperatureUnit: .fahrenheit, windSpeedUnit: .milesPerHour, theme: .dark))
    }
}
