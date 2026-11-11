import CoreLocation

/// Asks iOS for location access and waits for the answer.
///
/// iOS shows the system dialog **once**. After a refusal, the only way back is the Settings
/// app, so the caller opens it instead (see `AppContainer`). The explanation comes first:
/// the Home screen's "Where are you?" state is shown before the dialog (US-01).
@MainActor
final class LocationPermission: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<Bool, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced // enough for weather (NF-06)
    }

    var status: CLAuthorizationStatus { manager.authorizationStatus }

    func request() async -> Bool {
        guard status == .notDetermined else { return isGranted(status) }
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            guard status != .notDetermined, let continuation = self.continuation else { return }
            self.continuation = nil
            continuation.resume(returning: self.isGranted(status))
        }
    }

    private func isGranted(_ status: CLAuthorizationStatus) -> Bool {
        status == .authorizedWhenInUse || status == .authorizedAlways
    }
}
