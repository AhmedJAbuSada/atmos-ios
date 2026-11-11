# ADR-0006: Errors — typed throws with `DomainError`

- **Status:** Accepted
- **Date:** 2026-11-11

## Context
Network calls fail, files can be unreadable, the user can deny location. If `URLError` or
`DecodingError` travel up to the view model, every layer must know data-layer details. The
Android version uses an `AppResult` type for this.

## Decision
Use Swift's **typed throws** (Swift 6):

```swift
public enum DomainError: Error, Equatable, Sendable {
    case noConnection, timeout, server(code: Int), notFound
    case locationPermissionDenied, locationUnavailable
    case unknown
}

func fetchForecast(for coordinates: Coordinates) async throws(DomainError) -> Forecast
```

The data layer catches library errors **at the boundary** and maps them to `DomainError`.
The presentation layer maps each case to a localized message.

## Alternatives considered
| Option | Why not |
|---|---|
| Untyped `throws` | Callers get `any Error` and must guess what can happen. |
| `Result<T, DomainError>` | Works, but typed throws reads like normal code and composes with `async`. |

## Consequences
- ✅ `switch error` is exhaustive: a new case shows every place that must handle it.
- ✅ Same idea as the Android `AppResult`, in idiomatic Swift.
- ⚠️ `CancellationError` must never be turned into a `DomainError`; task cancellation is
  checked separately (`Task.checkCancellation()`), and a test covers it.
