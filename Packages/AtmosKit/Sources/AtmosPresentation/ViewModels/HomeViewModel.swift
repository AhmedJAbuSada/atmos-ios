import AtmosDomain
import Foundation
import Observation

/// Turns use-case results into ``HomeState`` (US-01, US-06, US-07).
///
/// Presentation logic only: which state to show and when to load. The business rules (cache
/// freshness, offline fallback) stay in the use cases from step 03, which is why this class
/// is short.
@MainActor
@Observable
public final class HomeViewModel {
    public private(set) var state: HomeState = .loading

    private let getCurrentLocationForecast: GetCurrentLocationForecastUseCase
    private let getForecast: GetForecastUseCase
    private let freshness: ForecastFreshness
    private let places: SelectedPlaceStore
    private let observeSettings: ObserveSettingsUseCase

    private var place: Place = .currentLocation
    private var settings = UserSettings()
    private var loaded: (place: Place, snapshot: ForecastSnapshot)?
    private var loadTask: Task<Void, Never>?

    public init(
        getCurrentLocationForecast: GetCurrentLocationForecastUseCase,
        getForecast: GetForecastUseCase,
        freshness: ForecastFreshness,
        places: SelectedPlaceStore,
        observeSettings: ObserveSettingsUseCase
    ) {
        self.getCurrentLocationForecast = getCurrentLocationForecast
        self.getForecast = getForecast
        self.freshness = freshness
        self.places = places
        self.observeSettings = observeSettings
    }

    /// Runs while the screen is visible (`.task { await viewModel.run() }`); SwiftUI cancels it
    /// when the screen goes away, which also cancels any download in progress.
    public func run() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.followSettings() }
            group.addTask { await self.followPlace() }
        }
    }

    /// Pull to refresh: always downloads (US-06). Awaited, so the spinner stays until done.
    public func refresh() async {
        await load(force: true)
    }

    public func retry() {
        startLoading(force: false)
    }

    /// Called after the system permission dialog closes.
    public func locationPermissionChanged(granted: Bool) {
        if granted { startLoading(force: false) }
    }

    private func followSettings() async {
        for await settings in await observeSettings() {
            self.settings = settings
            render() // °C → °F updates the screen without a new download (US-08)
        }
    }

    private func followPlace() async {
        for await place in await places.places() {
            self.place = place
            startLoading(force: false)
        }
    }

    private func startLoading(force: Bool) {
        loadTask?.cancel()
        loadTask = Task { await load(force: force) }
    }

    private func load(force: Bool) async {
        let place = self.place
        if loaded?.place != place { state = .loading }
        do {
            let snapshot: ForecastSnapshot
            switch place {
            case .currentLocation:
                snapshot = try await getCurrentLocationForecast(forceRefresh: force)
            case let .saved(city):
                snapshot = try await getForecast(for: city.coordinates, forceRefresh: force)
            }
            loaded = (place, snapshot)
            render()
        } catch .cancelled {
            return // the screen went away, or a newer load replaced this one
        } catch .locationPermissionDenied {
            state = .needsLocation
        } catch {
            // A failed refresh keeps what is on screen; the use case already fell back to the
            // cache when it could.
            if loaded?.place != place { state = .failed(error) }
        }
    }

    private func render() {
        guard let loaded, loaded.place == place else { return }
        let snapshot = loaded.snapshot
        state = .content(HomeContentState(
            placeName: place.cityName,
            forecast: snapshot.forecast,
            settings: settings,
            outdatedBy: snapshot.isOutdated ? freshness.age(of: snapshot.forecast) : nil
        ))
    }
}

private extension Place {
    var cityName: String? {
        if case let .saved(city) = self { return city.name }
        return nil
    }
}
