# Architecture Decision Records (ADRs)

An ADR records **one** important decision: the context, the choice, and the consequences.
Accepted ADRs are never edited; a new ADR *supersedes* an old one, so the history of *why*
is never lost.

| # | Title | Status |
|---|---|---|
| [0001](0001-clean-architecture-with-swift-package-targets.md) | Clean Architecture enforced by Swift package targets | Accepted |
| [0002](0002-open-meteo-as-data-source.md) | Open-Meteo as the weather data source | Accepted |
| [0003](0003-swiftui-and-observable-view-models.md) | SwiftUI with `@Observable` view models and unidirectional data flow | Accepted |
| [0004](0004-composition-root-without-di-framework.md) | Dependency injection by hand, in one composition root | Accepted |
| [0005](0005-localization-en-tr-ar.md) | Localization: English, Turkish, Arabic (RTL) with a String Catalog | Accepted |
| [0006](0006-typed-throws-domain-error.md) | Errors: typed throws with `DomainError` | Accepted |
| [0007](0007-json-files-instead-of-swiftdata.md) | Storage: JSON files and `UserDefaults`, not SwiftData | Accepted |
| [0008](0008-xcodegen-project.md) | Generate the Xcode project with XcodeGen | Accepted |
| [0009](0009-cancellation-with-typed-throws.md) | Cancellation with typed throws: an explicit `DomainError.cancelled` | Accepted |

Template: copy [`template.md`](template.md).
