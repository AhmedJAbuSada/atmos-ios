import Foundation

/// Decides whether cached data is still good enough to show without a download (F-07).
public struct ForecastFreshness: Sendable {
    /// Data younger than this is shown as-is, with no network call (US-06).
    public static let maximumAge: TimeInterval = 30 * 60

    private let dates: any DateProvider

    public init(dates: any DateProvider) {
        self.dates = dates
    }

    public func isFresh(_ forecast: Forecast) -> Bool {
        age(of: forecast) < Self.maximumAge
    }

    public func age(of forecast: Forecast) -> TimeInterval {
        dates.now.timeIntervalSince(forecast.fetchedAt)
    }
}
