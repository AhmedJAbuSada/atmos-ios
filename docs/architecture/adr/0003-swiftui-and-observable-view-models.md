# ADR-0003: SwiftUI with `@Observable` view models and unidirectional data flow

- **Status:** Accepted
- **Date:** 2026-11-11

## Context
We need a UI framework and a presentation pattern that are modern, testable, and comparable
with the Android version (Compose + ViewModel).

## Decision
- **UI:** SwiftUI, minimum iOS 17.
- **Pattern:** one `@MainActor @Observable final class` view model per screen, exposing one
  `state` enum and methods for user events.
- Each screen has a **container view** that owns the view model and a **content view** that
  takes `state` and closures only, so every state has a preview and no logic hides in views.
- **Navigation:** `NavigationStack` with a typed path.

## Alternatives considered
| Option | Why not |
|---|---|
| `ObservableObject` + `@Published` | The older API; `@Observable` (iOS 17) tracks only what a view reads and needs less code. |
| The Composable Architecture (TCA) | Powerful, but a large framework to learn; plain `@Observable` shows the same ideas with no dependency. |
| UIKit | Not what new iOS projects start with today. |

## Consequences
- ✅ The same "state in, events out" model as Compose, React and Flutter.
- ✅ View models test without SwiftUI.
- ⚠️ iOS 17 minimum excludes older devices; acceptable for a 2026 app.
