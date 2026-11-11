import AtmosData
import AtmosDomain
import AtmosPresentation
import Foundation
import SwiftUI

/// The composition root (ADR-0004): the one place that knows which implementation stands
/// behind each domain protocol. Everything else receives its dependencies in `init`.
///
/// In step 05 the app shows the Home screen with **preview data**, so the views can be checked
/// on a device before any real data is connected. Step 06 adds the view models.
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
        NavigationStack {
            HomeContent(state: .content(PreviewData.content), actions: .none)
        }
        .tint(AtmosTheme.accent)
    }
}
