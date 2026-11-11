import Foundation

/// Where "now" comes from. Injected instead of calling `Date()`, so tests can control time
/// ("data fetched exactly 30 minutes ago is stale") without waiting.
///
/// Not named `Clock`: Swift's standard library already has a `Clock` protocol, for measuring
/// durations.
public protocol DateProvider: Sendable {
    var now: Date { get }
}

/// The real clock.
public struct SystemDateProvider: DateProvider {
    public init() {}

    public var now: Date { Date() }
}
