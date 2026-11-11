#if canImport(CoreLocation)
import AtmosDomain
import CoreLocation

/// ``LocationRepository`` on CoreLocation, with iOS 17's async `CLLocationUpdate` API.
///
/// Asking for permission is the UI's job (step 06); this type only *checks* it, so it never
/// shows a dialog by itself. Accuracy is reduced (kilometres), enough for weather and kinder
/// to privacy and battery (NF-06). Only compiled on Apple platforms.
struct CoreLocationRepository: LocationRepository {
    private static let timeout: Duration = .seconds(15)

    func currentLocation() async throws(DomainError) -> Coordinates {
        switch CLLocationManager().authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways: break
        default: throw .locationPermissionDenied
        }
        do {
            return try await withThrowingTaskGroup(of: Coordinates?.self) { group in
                group.addTask {
                    for try await update in CLLocationUpdate.liveUpdates(.default) {
                        if let location = update.location,
                           let coordinates = Coordinates(
                               latitude: location.coordinate.latitude,
                               longitude: location.coordinate.longitude
                           ) {
                            return coordinates
                        }
                    }
                    return nil
                }
                group.addTask {
                    try await Task.sleep(for: Self.timeout)
                    return nil
                }
                let first = try await group.next() ?? nil
                group.cancelAll()
                guard let first else { throw DomainError.locationUnavailable }
                return first
            }
        } catch {
            let mapped = DomainError.from(error)
            throw mapped == .unknown ? .locationUnavailable : mapped
        }
    }
}
#endif
