import AtmosData
import AtmosDomain
import AtmosPresentation
import Foundation
import SwiftUI

/// The composition root (ADR-0004): the one place that knows which implementation stands
/// behind each domain protocol. Everything else receives its dependencies in `init`.
///
/// Step 04 creates the real repositories; the view models that use them arrive in step 06.
@MainActor
final class AppContainer {
    let repositories: DataModule.Repositories

    init() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        repositories = DataModule.makeRepositories(
            userAgent: "Atmos/\(version) (iOS)", // no personal data (API_CONTRACT §4)
            storageDirectory: URL.applicationSupportDirectory.appendingPathComponent("Atmos", isDirectory: true)
        )
    }

    func makeRootView() -> some View {
        HelloView()
    }
}
