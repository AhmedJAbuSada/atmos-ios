import AtmosDomain

/// Which place Home shows. Cities writes it, Home reads it: a small piece of shared UI state,
/// in memory on purpose (the app always opens on the current location).
public final class SelectedPlaceStore: Sendable {
    private let stream = ValueStream<Place>(.currentLocation)

    public init() {}

    public func select(_ place: Place) async {
        await stream.send(place)
    }

    public var current: Place {
        get async { await stream.value }
    }

    public func places() async -> AsyncStream<Place> {
        await stream.values()
    }

    /// If the removed city is on screen, Home goes back to the current location.
    public func cityRemoved(_ city: City) async {
        if case let .saved(selected) = await stream.value, selected.id == city.id {
            await stream.send(.currentLocation)
        }
    }
}
