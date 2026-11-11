import AtmosDomain
import Foundation

/// Everything the Home screen can show. The view is a pure function of this value: previews
/// and tests need no view model.
public enum HomeState: Equatable, Sendable {
    /// First load, nothing cached: the skeleton (US-09).
    case loading
    /// No permission and no saved city: offer both ways forward (F-02).
    case needsLocation
    /// Nothing to show, and the load failed.
    case failed(DomainError)
    case content(HomeContentState)
}

public struct HomeContentState: Equatable, Sendable {
    /// The city name, or `nil` for the current location.
    public var placeName: String?
    public var forecast: Forecast
    public var settings: UserSettings
    /// Set when the data is outdated because a refresh failed (F-08), in seconds.
    public var outdatedBy: TimeInterval?

    public init(placeName: String?, forecast: Forecast, settings: UserSettings, outdatedBy: TimeInterval? = nil) {
        self.placeName = placeName
        self.forecast = forecast
        self.settings = settings
        self.outdatedBy = outdatedBy
    }
}

/// What the user can do on Home. The view reports; whoever owns the screen decides.
@MainActor
public struct HomeActions {
    public var refresh: @MainActor () async -> Void
    public var retry: @MainActor () -> Void
    public var requestLocation: @MainActor () -> Void
    public var openCities: @MainActor () -> Void
    public var openSettings: @MainActor () -> Void

    public init(
        refresh: @escaping @MainActor () async -> Void,
        retry: @escaping @MainActor () -> Void,
        requestLocation: @escaping @MainActor () -> Void,
        openCities: @escaping @MainActor () -> Void,
        openSettings: @escaping @MainActor () -> Void
    ) {
        self.refresh = refresh
        self.retry = retry
        self.requestLocation = requestLocation
        self.openCities = openCities
        self.openSettings = openSettings
    }

    /// Does nothing: for previews and demos.
    public static var none: HomeActions {
        HomeActions(refresh: {}, retry: {}, requestLocation: {}, openCities: {}, openSettings: {})
    }
}
