# Coding standards (Swift / iOS)

Rules a machine can check are checked by tools (set up in step 02). Code review is for
everything else.

## Tooling

| Tool | Checks | Runs |
|---|---|---|
| **Swift 6 compiler** (strict concurrency, warnings as errors) | Data races, unused code, deprecated APIs | Every build |
| **SwiftLint** | Style, complexity, and our custom rules (locale-safe casing, no `print`) | `swiftlint`, in CI |
| **swift test** | Domain and data behaviour, on any platform | `swift test` in `Packages/AtmosKit` |
| **xcodebuild test** | View models, UI tests, on the iOS Simulator | CI on macOS |

## Naming

| Thing | Convention | Example |
|---|---|---|
| Use case | `VerbNounUseCase`, one `callAsFunction` | `GetForecastUseCase` |
| Repository | protocol `NounRepository`, type `DefaultNounRepository` | `WeatherRepository` |
| DTO | `NounDTO` | `ForecastDTO` |
| View model | `ScreenViewModel` | `HomeViewModel` |
| Views | `ScreenView` (container), `ScreenContent` (stateless) | `HomeView`, `HomeContent` |
| Test | a sentence in `@Test("…")` | `@Test("given stale cache, when loading, then downloads")` |

## Swift rules

- Prefer `struct` and `let`. Use `final class` only when identity or `@Observable` is needed.
- No force unwrap (`!`) or `try!` outside tests.
- Default access is `internal`; add `public` only for what other targets need.
- Swift 6 strict concurrency: types crossing tasks are `Sendable`; shared mutable state
  lives in an `actor`; view models are `@MainActor`.
- Never hide a cancellation: map it to `DomainError.cancelled`, never show it (ADR-0009).
- Text casing always takes a locale: `uppercased(with: locale)`. **Never** the version
  without one for display text (Turkish `i`; SwiftLint rule).
- No magic numbers: `static let cacheLifetime: Duration = .seconds(30 * 60)`.
- Functions under ~30 lines; types with one responsibility.

## SwiftUI rules

- Container views own the view model; content views take `state` and closures and have
  `#Preview`s for light, dark, Arabic and the largest Dynamic Type size.
- Use `LocalizedStringKey` / `String(localized:)`; never a hard-coded user-facing string.
- `leading` / `trailing`, never `left` / `right`.
- Meaningful images have an `accessibilityLabel`; decorative ones are hidden from
  VoiceOver.
- Tap targets at least 44 × 44 pt.

## Comments

Code says *what*; comments say *why*. Use `///` documentation comments for public API.
