import SwiftUI

/// A placeholder screen for step 02, proving the app, the package and the String Catalog
/// work together. Real screens arrive in step 05.
public struct HelloView: View {
    public init() {}

    public var body: some View {
        Text("hello.title", bundle: .module)
            .font(.largeTitle)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview("English") { HelloView() }

#Preview("Arabic") {
    HelloView().environment(\.locale, Locale(identifier: "ar"))
}
