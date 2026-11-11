import SwiftUI

/// The app's entry point. It only asks the composition root for the first screen.
@main
struct AtmosApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            container.makeRootView()
        }
    }
}
