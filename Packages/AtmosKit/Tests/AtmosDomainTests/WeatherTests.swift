import AtmosDomain
import AtmosTesting
import Foundation
import Testing

@Suite("WeatherCondition")
struct WeatherConditionTests {
    @Test("every documented WMO code maps to a known condition", arguments: [
        (0, WeatherCondition.clear), (1, .mainlyClear), (2, .partlyCloudy), (3, .overcast),
        (45, .fog), (48, .fog), (51, .drizzle), (53, .drizzle), (55, .drizzle),
        (56, .freezingDrizzle), (57, .freezingDrizzle), (61, .rain), (63, .rain), (65, .rain),
        (66, .freezingRain), (67, .freezingRain), (71, .snow), (73, .snow), (75, .snow), (77, .snow),
        (80, .rainShowers), (81, .rainShowers), (82, .rainShowers), (85, .snowShowers), (86, .snowShowers),
        (95, .thunderstorm), (96, .thunderstormWithHail), (99, .thunderstormWithHail),
    ])
    func knownCodes(code: Int, condition: WeatherCondition) {
        #expect(WeatherCondition(wmoCode: code) == condition)
    }

    @Test("an unknown or missing code maps to unknown instead of crashing", arguments: [4, -1, nil] as [Int?])
    func unknownCodes(code: Int?) {
        #expect(WeatherCondition(wmoCode: code) == .unknown)
    }
}

@Suite("ForecastFreshness")
struct ForecastFreshnessTests {
    let freshness = ForecastFreshness(dates: FixedDateProvider())

    @Test("data fetched 29 minutes ago is fresh")
    func fresh() {
        #expect(freshness.isFresh(TestData.forecast(fetchedAt: TestData.now.addingTimeInterval(-29 * 60))))
    }

    @Test("data fetched exactly 30 minutes ago is stale")
    func staleAtTheBoundary() {
        #expect(!freshness.isFresh(TestData.forecast(fetchedAt: TestData.now.addingTimeInterval(-30 * 60))))
    }

    @Test("age is measured from the fetch time")
    func age() {
        #expect(freshness.age(of: TestData.forecast(fetchedAt: TestData.now.addingTimeInterval(-7200))) == 7200)
    }
}

/// One test per row of the table in GetForecastUseCase's documentation.
@Suite("GetForecastUseCase")
struct GetForecastUseCaseTests {
    let fresh = TestData.forecast(fetchedAt: TestData.now.addingTimeInterval(-5 * 60))
    let stale = TestData.forecast(fetchedAt: TestData.now.addingTimeInterval(-2 * 3600))
    let downloaded = TestData.forecast(fetchedAt: TestData.now)

    func useCase(_ repository: FakeWeatherRepository) -> GetForecastUseCase {
        GetForecastUseCase(repository: repository, freshness: ForecastFreshness(dates: FixedDateProvider()))
    }

    @Test("given fresh cache, when loading, then returns it without a network call")
    func freshCache() async throws {
        let repository = FakeWeatherRepository(cached: fresh)

        let snapshot = try await useCase(repository)(for: TestData.istanbul)

        #expect(snapshot == ForecastSnapshot(forecast: fresh))
        #expect(await repository.fetchCount == 0)
    }

    @Test("given fresh cache, when pulling to refresh, then downloads anyway")
    func forcedRefresh() async throws {
        let repository = FakeWeatherRepository(cached: fresh, fetchResult: .success(downloaded))

        let snapshot = try await useCase(repository)(for: TestData.istanbul, forceRefresh: true)

        #expect(snapshot.forecast == downloaded)
        #expect(await repository.fetchCount == 1)
    }

    @Test("given stale or no cache, when loading, then downloads", arguments: [true, false])
    func staleOrMissing(hasStaleCache: Bool) async throws {
        let repository = FakeWeatherRepository(cached: hasStaleCache ? stale : nil, fetchResult: .success(downloaded))

        let snapshot = try await useCase(repository)(for: TestData.istanbul)

        #expect(snapshot == ForecastSnapshot(forecast: downloaded))
        #expect(!snapshot.isOutdated)
    }

    @Test("given stale cache and no connection, then returns the cache marked outdated")
    func offlineWithCache() async throws {
        let repository = FakeWeatherRepository(cached: stale, fetchResult: .failure(.noConnection))

        let snapshot = try await useCase(repository)(for: TestData.istanbul)

        #expect(snapshot.forecast == stale)
        #expect(snapshot.refreshError == .noConnection)
        #expect(snapshot.isOutdated)
    }

    @Test("given no cache and no connection, then throws the error")
    func offlineWithoutCache() async {
        let repository = FakeWeatherRepository(fetchResult: .failure(.noConnection))

        await #expect(throws: DomainError.noConnection) {
            try await useCase(repository)(for: TestData.istanbul)
        }
    }

    @Test("a cancelled download is never hidden behind old data (ADR-0009)")
    func cancellation() async {
        let repository = FakeWeatherRepository(cached: stale, fetchResult: .failure(.cancelled))

        await #expect(throws: DomainError.cancelled) {
            try await useCase(repository)(for: TestData.istanbul)
        }
    }

    @Test("the cached forecast is read without a download")
    func cachedOnly() async {
        let repository = FakeWeatherRepository(cached: stale)

        #expect(await GetCachedForecastUseCase(repository: repository)(for: TestData.istanbul) == stale)
        #expect(await repository.fetchCount == 0)
    }
}
