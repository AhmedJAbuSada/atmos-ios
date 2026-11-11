# ADR-0009: Cancellation with typed throws — an explicit `DomainError.cancelled`

- **Status:** Accepted (refines the consequences of ADR-0006)
- **Date:** 2026-11-11

## Context
ADR-0006 chose typed throws (`throws(DomainError)`) and said cancellation would be "checked
separately". When the domain was written in step 03, that turned out to be impossible as
written: a function declared `throws(DomainError)` **cannot throw** Swift's
`CancellationError`, and `Task.checkCancellation()` throws exactly that.

Cancellation still has to travel through the layers: when the user leaves a screen, its
download is cancelled, and that must not be reported as "you're offline", nor hidden behind
cached data.

## Decision
Add `case cancelled` to `DomainError`:
- The data layer maps `URLError.cancelled` and `CancellationError` to `.cancelled`.
- Use cases pass `.cancelled` through untouched; in particular `GetForecastUseCase` never
  answers a cancelled download with outdated cached data (a test covers it).
- The presentation layer **never shows** `.cancelled` to the user; it simply ignores it.

## Alternatives considered
| Option | Why not |
|---|---|
| Untyped `throws` everywhere | Loses the exhaustive error handling that ADR-0006 was for. |
| Return `nil` on cancellation | Callers could not tell "nothing found" from "stopped". |

## Consequences
- ✅ Typed throws keeps its benefits, and cancellation is still distinguishable.
- ⚠️ Every `switch` over `DomainError` in the UI must handle `.cancelled` (by doing nothing);
  the compiler makes sure nobody forgets.

## How this ADR came about
A plan met the compiler. Like the Android repository's ADR-0007 (detekt), the original ADR
stays as it was, and this one records what changed and why.
