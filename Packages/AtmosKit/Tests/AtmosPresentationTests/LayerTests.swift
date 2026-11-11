import AtmosPresentation
import Testing

@Test("the presentation target builds with SwiftUI and its String Catalog")
@MainActor
func presentationBuilds() {
    _ = HelloView()
}
