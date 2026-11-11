import AtmosDomain
@testable import AtmosPresentation
import AtmosTesting
import Foundation
import Testing

@MainActor
@Suite("HomeViewModel")
struct HomeViewModelTests {
    let weather = FakeWeatherRepository()
    let location = FakeLocationRepository()
    let settings = FakeSettingsRepository()
    let places = SelectedPlaceStore()

    func makeViewModel() -> HomeViewModel {
        let freshness = ForecastFreshness(dates: FixedDateProvider())
        let getForecast = GetForecastUseCase(repository: weather, freshness: freshness)
        return HomeViewModel(
            getCurrentLocationForecast: GetCurrentLocationForecastUseCase(
                locations: location,
                getForecast: getForecast
            ),
            getForecast: getForecast,
            freshness: freshness,
            places: places,
            observeSettings: ObserveSettingsUseCase(repository: settings)
        )
    }

    func content(_ viewModel: HomeViewModel) -> HomeContentState? {
        if case let .content(content) = viewModel.state { return content }
        return nil
    }

    @Test("shows the weather where the user is")
    func currentLocation() async {
        let viewModel = makeViewModel()
        let task = Task { await viewModel.run() }
        defer { task.cancel() }

        #expect(await eventually { content(viewModel)?.forecast == TestData.forecast() })
        #expect(content(viewModel)?.placeName == nil) // shown as "Current location"
    }

    @Test("without location permission, offers location or search instead of an error")
    func needsLocation() async {
        await location.setResult(.failure(.locationPermissionDenied))
        let viewModel = makeViewModel()
        let task = Task { await viewModel.run() }
        defer { task.cancel() }

        #expect(await eventually { viewModel.state == .needsLocation })
    }

    @Test("when permission is granted, loads the weather")
    func permissionGranted() async {
        await location.setResult(.failure(.locationPermissionDenied))
        let viewModel = makeViewModel()
        let task = Task { await viewModel.run() }
        defer { task.cancel() }
        _ = await eventually { viewModel.state == .needsLocation }

        await location.setResult(.success(TestData.istanbul))
        viewModel.locationPermissionChanged(granted: true)

        #expect(await eventually { content(viewModel) != nil })
    }

    @Test("with no cache and no connection, shows the error; retry recovers")
    func errorAndRetry() async {
        await weather.setFetchResult(.failure(.noConnection))
        let viewModel = makeViewModel()
        let task = Task { await viewModel.run() }
        defer { task.cancel() }
        #expect(await eventually { viewModel.state == .failed(.noConnection) })

        await weather.setFetchResult(.success(TestData.forecast()))
        viewModel.retry()

        #expect(await eventually { content(viewModel) != nil })
    }

    @Test("with stale cache and no connection, shows the cache and how old it is")
    func outdated() async {
        await weather.setCached(TestData.forecast(fetchedAt: TestData.now.addingTimeInterval(-7200)))
        await weather.setFetchResult(.failure(.noConnection))
        let viewModel = makeViewModel()
        let task = Task { await viewModel.run() }
        defer { task.cancel() }

        #expect(await eventually { content(viewModel)?.outdatedBy == 7200 })
    }

    @Test("pull to refresh downloads even when the cache is fresh")
    func refresh() async {
        let viewModel = makeViewModel()
        let task = Task { await viewModel.run() }
        defer { task.cancel() }
        _ = await eventually { content(viewModel) != nil }
        let before = await weather.fetchCount

        await viewModel.refresh()

        #expect(await weather.fetchCount == before + 1)
    }

    @Test("a failed refresh keeps the weather on screen")
    func failedRefresh() async {
        let viewModel = makeViewModel()
        let task = Task { await viewModel.run() }
        defer { task.cancel() }
        _ = await eventually { content(viewModel) != nil }

        await location.setResult(.failure(.locationUnavailable))
        await viewModel.refresh()

        #expect(content(viewModel) != nil)
    }

    @Test("changing the unit updates the screen without a download")
    func unitChange() async {
        let viewModel = makeViewModel()
        let task = Task { await viewModel.run() }
        defer { task.cancel() }
        _ = await eventually { content(viewModel) != nil }
        let before = await weather.fetchCount

        await settings.update { _ in UserSettings(temperatureUnit: .fahrenheit) }

        #expect(await eventually { content(viewModel)?.settings.temperatureUnit == .fahrenheit })
        #expect(await weather.fetchCount == before)
    }

    @Test("choosing a saved city shows that city")
    func savedCity() async {
        let viewModel = makeViewModel()
        let task = Task { await viewModel.run() }
        defer { task.cancel() }

        await places.select(.saved(TestData.city(1, "Ankara")))

        #expect(await eventually { content(viewModel)?.placeName == "Ankara" })
    }
}
