# ADR-0001: Clean Architecture enforced by Swift package targets

- **Status:** Accepted
- **Date:** 2026-11-11

## Context
We want business rules that are testable without a simulator, and layer boundaries that
stay intact when many people and AI agents contribute. In a single Xcode target, every file
can import everything; nothing stops a view from calling `URLSession`.

## Decision
Three targets in one local Swift package, `Packages/AtmosKit`: `AtmosDomain` (Foundation
only), `AtmosData` (depends on Domain), `AtmosPresentation` (depends on Domain). The app
target depends on all three and is the composition root. Inside each target, folders are by
feature.

## Alternatives considered
| Option | Why not |
|---|---|
| One app target, layers as folders | Folders don't enforce anything; a stray import compiles. |
| One framework target per layer in the Xcode project | Works, but the rules hide in project settings; `Package.swift` is readable code. |
| One package per feature *and* layer | Good for big teams; too much ceremony for four screens. |

## Consequences
- ✅ An import across the rule is a compile error.
- ✅ `AtmosDomain` and `AtmosData` build and test with `swift test` on any platform,
  including Linux, in seconds.
- ✅ Same three layers as the Android version: the two codebases can be compared file by file.
- ⚠️ More files (DTO + entity + mapper). We accept this for clear boundaries.
