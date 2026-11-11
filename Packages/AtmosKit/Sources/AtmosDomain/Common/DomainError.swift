/// Everything that can go wrong, in the language of the business, not of the libraries
/// (ADR-0006). The data layer maps `URLError`, `DecodingError` and HTTP statuses to these
/// cases at the boundary; the UI maps each case to a localized message.
public enum DomainError: Error, Equatable, Sendable {
    /// The device is offline or the host cannot be reached.
    case noConnection
    /// The server did not answer in time.
    case timeout
    /// The server answered with an error status (HTTP 4xx or 5xx).
    case server(code: Int)
    /// The requested data does not exist.
    case notFound
    /// The user has not granted location permission.
    case locationPermissionDenied
    /// Permission is granted, but the device cannot determine a location right now.
    case locationUnavailable
    /// The work was cancelled, for example because the screen went away. Never shown to the
    /// user (ADR-0009).
    case cancelled
    /// Anything we did not anticipate.
    case unknown
}
