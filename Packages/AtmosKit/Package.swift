// swift-tools-version: 6.0
//
// AtmosKit holds all of the app's code, as three Clean Architecture layers (ADR-0001).
// A target can only import the targets listed in its `dependencies`, so this file *is*
// the dependency rule, checked by the compiler:
//
//   AtmosPresentation ─┐
//                      ├──▶ AtmosDomain   (Foundation only)
//   AtmosData ─────────┘
//
// The app target (see project.yml) depends on all three and wires them together.
import PackageDescription

var targets: [Target] = [
    .target(name: "AtmosDomain"),
    .target(name: "AtmosData", dependencies: ["AtmosDomain"]),
    .testTarget(name: "AtmosDomainTests", dependencies: ["AtmosDomain"]),
    .testTarget(name: "AtmosDataTests", dependencies: ["AtmosData"]),
]

// SwiftUI exists only on Apple platforms. On Linux (fast CI, cloud sandboxes) the package
// builds and tests the domain and data layers only; the presentation layer is verified on
// macOS. This is one reason the business logic must not import SwiftUI.
#if !os(Linux)
targets += [
    .target(
        name: "AtmosPresentation",
        dependencies: ["AtmosDomain"],
        resources: [.process("Resources")]
    ),
    .testTarget(name: "AtmosPresentationTests", dependencies: ["AtmosPresentation"]),
]
#endif

let package = Package(
    name: "AtmosKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "AtmosDomain", targets: ["AtmosDomain"]),
        .library(name: "AtmosData", targets: ["AtmosData"]),
    ] + {
        #if !os(Linux)
        [.library(name: "AtmosPresentation", targets: ["AtmosPresentation"])]
        #else
        []
        #endif
    }(),
    targets: targets,
    swiftLanguageModes: [.v6]
)
