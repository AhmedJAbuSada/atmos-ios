# ADR-0004: Dependency injection by hand, in one composition root

- **Status:** Accepted
- **Date:** 2026-11-11

## Context
Every class should receive its dependencies instead of creating them, so tests can pass
fakes. Android uses Hilt for this. iOS has no standard DI framework.

## Decision
No framework. Every type takes its dependencies in `init`. One class in the app target,
`AppContainer`, creates the real implementations once and builds the view models. That class
is the **composition root**: the only place that knows which implementation stands behind
each protocol.

## Alternatives considered
| Option | Why not |
|---|---|
| Swinject, Factory, Needle | A dependency and a runtime container for a graph of ~15 objects. |
| SwiftUI `@Environment` for everything | Fine for UI values (locale, theme); hides dependencies of view models and makes them hard to test. |
| Singletons (`Service.shared`) | Global state; tests cannot replace them. |

## Consequences
- ✅ Nothing to learn: it is just initializers. Missing dependencies are compile errors.
- ✅ A useful contrast with Hilt in the Android repo: same idea, no framework.
- ⚠️ `AppContainer` grows with the app; split it per feature when it passes ~200 lines.
