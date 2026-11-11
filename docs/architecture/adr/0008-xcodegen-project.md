# ADR-0008: Generate the Xcode project with XcodeGen

- **Status:** Accepted
- **Date:** 2026-11-11

## Context
`.xcodeproj/project.pbxproj` is a large machine-written file. Two people adding files at
the same time produce merge conflicts that are hard to resolve, and reviewers cannot read it.

## Decision
Describe the app target in a short, readable [`project.yml`](../../../project.yml) and
generate `Atmos.xcodeproj` with [XcodeGen](https://github.com/yonaskolb/XcodeGen). The
generated project is **not** committed. All real code lives in the Swift package, which
Xcode reads directly.

```bash
brew install xcodegen
xcodegen        # creates Atmos.xcodeproj
open Atmos.xcodeproj
```

## Alternatives considered
| Option | Why not |
|---|---|
| Commit `.xcodeproj` | Merge conflicts and unreviewable diffs. |
| Tuist | More powerful (caching, modular graphs), but heavier to learn for one app target. |
| Package-only app (Swift Playgrounds style) | Limited control over signing, Info.plist and UI test targets. |

## Consequences
- ✅ Project changes are readable in review.
- ⚠️ One extra command after cloning; the README says so first.
