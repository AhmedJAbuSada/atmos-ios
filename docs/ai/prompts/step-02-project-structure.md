# Prompts — step 02: project structure (iOS)

## 1. The task (human → agent)

> Continue from `docs/PROGRESS.md`: build step 02 for iOS. The layers must be enforced by
> the compiler. Nothing that only Xcode can produce should be committed. Prove each guard.

## 2. Sub-prompts

| Task | Instruction |
|---|---|
| Package | "One local package, three targets, the dependency rule in `Package.swift` with a diagram in a comment. Swift 6 language mode. Leave the SwiftUI target out on Linux." |
| Proof | "Add an `import AtmosData` to the domain and an `import SwiftUI`, build, capture the errors for the guide, remove them." |
| Gaps | "What can a package *not* prevent? Cover it with a lint rule." |
| App | "XcodeGen spec with the app and a UI test target; the app target only has the entry point and the composition root." |
| CI | "A fast Linux job for domain and data; a macOS job for lint, all package tests and the UI test. Don't hard-code a simulator name. Report errors as annotations." |
| Self-review | "Re-read every shell step in CI: can a failure ever pass?" (This caught the `PIPESTATUS` bug.) |
