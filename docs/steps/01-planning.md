# Step 01 — Planning: documents before code (iOS)

**Branch:** `step-01-planning` · **Next:** step 02, project structure

There is no code in this step, on purpose. A professional project starts by agreeing on
**what** to build, **why**, and **how the team will work**.

This repository has a twist: the same product was already built for
[Android](https://github.com/AhmedJAbuSada/atmos-android). So this step also shows **how a
team builds one product on several platforms**: what is shared and what is not.

## Shared vs platform-specific

| Shared with Android (same product) | Written for iOS (same ideas, different platform) |
|---|---|
| [PRD](../product/PRD.md): requirements and their IDs | [Architecture](../architecture/ARCHITECTURE.md): Swift package targets |
| [User stories](../product/USER_STORIES.md) and acceptance criteria | [ADRs](../architecture/adr/): SwiftUI, DI, errors, storage, XcodeGen |
| [Wireframes](../design/WIREFRAMES.md) | [Coding standards](../process/CODING_STANDARDS.md): Swift 6, SwiftLint |
| [API contract](../api/API_CONTRACT.md) and the recorded [samples](../api/samples/) | [AGENTS.md](../../AGENTS.md): the rules for this codebase |
| [Git workflow](../process/GIT_WORKFLOW.md), [Definition of Done](../process/DEFINITION_OF_DONE.md) | |

The PRD changed in only three places: minimum OS (iOS 17), touch target size (44 pt,
Apple's guideline, instead of 48 dp), and Dynamic Type instead of Android font scaling.
**Requirement IDs stay the same**, so "F-05" means the same feature in all four repositories.
A bug in city search can be discussed across teams with one ID.

> In a real company these shared documents would live in one place (a product repo or a
> wiki) and each app would link to them. Here they are copied so each repository is
> complete on its own for readers.

## Same architecture, different tools

| Concept | Android | iOS |
|---|---|---|
| Enforce the layers | Gradle modules | Swift package targets (ADR-0001) |
| UI and state | Compose + `StateFlow` | SwiftUI + `@Observable` (ADR-0003) |
| Dependency injection | Hilt | A hand-written composition root (ADR-0004) |
| Errors as values | `AppResult` sealed type | Typed throws: `throws(DomainError)` (ADR-0006) |
| Cache and saved cities | Room | JSON files (ADR-0007) |
| Settings | DataStore | `UserDefaults` |
| Translations | `strings.xml` per language | One String Catalog (ADR-0005) |
| Project file | `build.gradle.kts` | `project.yml` + XcodeGen (ADR-0008) |

Read the ADRs in pairs, one from each repository, to see *why* each platform's choice is
different. For example, iOS has no standard DI framework, and the object graph is small, so
plain initializers are enough (ADR-0004).

## Lessons carried over from Android

A second platform is a chance to start with what the first one learned:
1. **One source of truth for the language.** On Android, storing our own copy of the
   language undid a choice made in the system settings. On iOS, the per-app language lives
   in the system Settings app, and Atmos simply opens that page (ADR-0005).
2. **Directional isolates for values in Arabic text.** Android's screenshots showed `11°`
   rendered as `°11` inside Arabic sentences. The iOS formatter will isolate values from
   day one (ADR-0005, point 6).
3. **Make CI report its own failures.** The Android CI learned to turn test failures into
   annotations; the iOS CI will have that from the start.

## Key ideas (same as every project)

1. **Everything traces to an ID:** commit → user story (US-04) → requirement (F-05).
2. **Write down the non-goals:** no widgets, alerts or accounts in v1.
3. **Acceptance criteria become tests**, with the criterion as the test name.
4. **Never trust an API you haven't called:** the contract is based on recorded responses.
5. **Decisions are recorded, not remembered:** one ADR per decision, with alternatives.

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Copied the product docs and changed only the platform facts | Confirmed iOS 17 as the minimum |
| Proposed the iOS stack and wrote eight ADRs, each comparing with Android | Approved the choices |
| Installed a Swift toolchain in the Linux cloud sandbox (after asking for network access), so pure-Swift layers can be built and tested without a Mac | — |
| Wrote `AGENTS.md` for this codebase | — |

**What went wrong, and what we learned:** the sandbox has no Mac, so it cannot run Xcode
or the iOS Simulator. The plan accounts for it from the start: domain and data are plain
Swift (testable on Linux), and everything with SwiftUI is verified in CI on GitHub's macOS
runners. **Lesson:** know your tools' limits before you design, not after.

Prompts: [docs/ai/prompts/step-01-planning.md](../ai/prompts/step-01-planning.md).

## Exercise for you
1. Compare ADR-0004 here with ADR-0004 in the Android repo. When would you add a DI
   framework to the iOS app?
2. Which documents would you move to a shared "product" repository, and how would each
   app stay in sync with them?

## Checklist: is step 01 done?
- [x] Product documents shared with Android, platform facts adapted
- [x] iOS architecture and eight ADRs
- [x] Swift coding standards, Definition of Done, PR and issue templates
- [x] `AGENTS.md`, `CLAUDE.md`, `AI_WORKFLOW.md`
- [x] `PROGRESS.md` updated
