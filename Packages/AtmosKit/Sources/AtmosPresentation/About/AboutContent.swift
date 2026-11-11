import SwiftUI

/// About (US-10): the attribution the Open-Meteo licence requires, the version, the source.
public struct AboutContent: View {
    let version: String

    public init(version: String) {
        self.version = version
    }

    public var body: some View {
        List {
            VStack(spacing: AtmosTheme.Spacing.small) {
                Image(systemName: "cloud.sun.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 64))
                    .accessibilityHidden(true)
                Text(verbatim: "Atmos").font(.title.bold())
                Text("about.version \(version)", bundle: .module).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)

            Link(destination: Links.openMeteo) { Text("about.dataSource", bundle: .module) }
            Link(destination: Links.sourceCode) { Text("about.sourceCode", bundle: .module) }
            Text("about.license", bundle: .module)
        }
        .navigationTitle(Text("about.title", bundle: .module))
    }

    enum Links {
        static let openMeteo = URL(string: "https://open-meteo.com/") ?? URL(fileURLWithPath: "/")
        static let sourceCode = URL(string: "https://github.com/AhmedJAbuSada/atmos-ios") ?? URL(fileURLWithPath: "/")
    }
}

#Preview { NavigationStack { AboutContent(version: "0.5.0") } }
