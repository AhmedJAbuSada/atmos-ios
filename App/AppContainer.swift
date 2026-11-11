import AtmosData
import AtmosDomain
import AtmosPresentation
import SwiftUI

/// The composition root (ADR-0004): the one place that knows which implementation stands
/// behind each domain protocol. Everything else receives its dependencies in `init`.
///
/// In step 02 there is nothing to wire yet; repositories and view models are added in
/// steps 04 and 06.
@MainActor
final class AppContainer {
    func makeRootView() -> some View {
        HelloView()
    }
}
