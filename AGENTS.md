# AGENTS.md — rules for AI coding agents

Read automatically by AI coding agents (Claude Code reads it through `CLAUDE.md`). It is
also a one-page summary for human contributors.

## Project
Atmos is an iOS weather app (Swift 6, SwiftUI) built as a **tutorial**. Clarity matters more
than speed: readers learn from every line. The same app exists for Android, React Native and
Flutter; keep the behaviour identical to the product docs.

## Before you write code
1. Read [`docs/PROGRESS.md`](docs/PROGRESS.md): the current step and what is next.
2. Read the step guide in [`docs/steps/`](docs/steps/).
3. Find the user story in [`docs/product/USER_STORIES.md`](docs/product/USER_STORIES.md).
   No story? Ask before building.
4. For anything non-trivial, **write a plan first** and wait for approval.

## Architecture (non-negotiable)
Full rules: [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md).

- Targets in `Packages/AtmosKit`: `AtmosDomain` ← `AtmosData` and `AtmosPresentation`.
  **`AtmosDomain` imports Foundation only.**
- DTOs never leave `AtmosData`. Views never see a DTO or a library error.
- Fallible functions are `async throws(DomainError)`; map library errors in `AtmosData`;
  map cancellation to `.cancelled` and never show it (ADR-0009).
- One `@MainActor @Observable` view model per screen; content views take `state` + closures.
- Dependencies come through `init`; only `AppContainer` creates real implementations.
- Inject a `DateProvider`; never call `Date()` in logic.

## Code rules
- Follow [`docs/process/CODING_STANDARDS.md`](docs/process/CODING_STANDARDS.md).
- No `!` or `try!` outside tests. Swift 6 strict concurrency, no warnings.
- **Never** `uppercased()`/`lowercased()` without a locale for display text (Turkish `i`).
- No hard-coded user-facing strings: add every string to `Localizable.xcstrings` in **en, tr
  and ar**.
- `leading` / `trailing`, never `left` / `right`.

## Tests
- Write tests **with** the change, including at least one failure path.
- Data tests use the recorded JSON in [`docs/api/samples/`](docs/api/samples/). Do not
  invent API responses.
- Run before saying "done":
  ```bash
  swiftlint
  (cd Packages/AtmosKit && swift test)
  ```
  View model and UI tests run on macOS in CI. If you cannot run something, **say so**.

## Git
- Conventional Commits: `feat(search): …`, `fix(l10n): …`.
- Small commits, one logical change each.
- Update `docs/PROGRESS.md` at the end of every work session.

## Do not
- Add dependencies without an ADR or explicit approval.
- Add features that are not in the PRD.
- Commit secrets, signing certificates or provisioning profiles.
- Change an accepted ADR: write a new one that supersedes it.
- Disable a lint rule or a test to make the build pass.

## When unsure
Stop and ask. A question costs one message; a wrong assumption costs a rewrite.
