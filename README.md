# Atmos — iOS

**A weather app built step by step, as a public tutorial on professional iOS development
with Clean Architecture, SwiftUI and an AI coding agent.**

<!-- step-banner:start -->
## 📍 You are on Step 01 of 7 — Planning: documents before code

`step-01-planning` · [Step 02 →](https://github.com/AhmedJAbuSada/atmos-ios/tree/step-02-project-structure) · [All steps](docs/ROADMAP.md)

**What this step is.** There is **no code** in this branch, on purpose. It shows how one product is built on several platforms: the requirements, user stories, wireframes and API contract are **shared** with the Android version (same IDs), while the architecture, eight ADRs, Swift coding standards and `AGENTS.md` are written **for iOS**, each decision compared with Android.

**Why it matters.** A second platform is a chance to start with what the first one learned. Shared requirement IDs mean a bug in "F-05" is the same feature in all four apps; platform documents explain *why* iOS chooses differently (no DI framework, typed throws, JSON files instead of SwiftData).

**What you will find in this branch**

| Where | What |
|---|---|
| `docs/product/, docs/design/, docs/api/` | Shared with Android: the same product |
| `docs/architecture/ARCHITECTURE.md` | Three layers as Swift package targets |
| `docs/architecture/adr/` | Eight iOS decisions, each compared with Android |
| `docs/process/CODING_STANDARDS.md` | Swift 6, SwiftLint, SwiftUI rules |
| `AGENTS.md, docs/AI_WORKFLOW.md` | How to work with an AI coding agent |

**How to study this step**

1. **Read the full guide:** [docs/steps/01-planning.md](docs/steps/01-planning.md): key ideas, diagrams, and *how the AI agent helped* (including what went wrong).
2. **Read in this order:** PRD → user stories → API contract → architecture → ADRs → AGENTS.md.
3. **Try the exercise:** Compare ADR-0004 here with ADR-0004 in the Android repo. When would you add a DI framework to the iOS app?

> This README shows the project *as it was at this step*. The finished app is on
> [`main`](https://github.com/AhmedJAbuSada/atmos-ios).

---
<!-- step-banner:end -->

![Swift](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017+-0D96F6?logo=apple&logoColor=white)
![Clean Architecture](https://img.shields.io/badge/Clean%20Architecture-3%20layers-success)
![Languages](https://img.shields.io/badge/i18n-EN%20%7C%20TR%20%7C%20AR%20(RTL)-blue)
![License](https://img.shields.io/badge/license-MIT-green)

> 🚧 **In progress:** step 01 of 7 is done. Follow along in [PROGRESS.md](docs/PROGRESS.md).
> The [Android version](https://github.com/AhmedJAbuSada/atmos-android) is complete (v1.0.0).

## Why this repository exists

Most sample apps show only the finished code. This one shows **how a professional project
grows**, one level per branch, each explained:

| Step | Branch | What you learn |
|---|---|---|
| 01 | [`step-01-planning`](../../tree/step-01-planning) | PRD, user stories, API contract, architecture, ADRs, team process, AI agent rules |
| 02 | `step-02-project-structure` | Swift package targets that enforce Clean Architecture, XcodeGen, SwiftLint, CI |
| 03 | `step-03-domain-layer` | Entities, use cases, typed throws, Swift Testing |
| 04 | `step-04-data-layer` | URLSession + Codable, mappers, JSON file cache, settings, location |
| 05 | `step-05-presentation-ui` | Design system, SwiftUI screens with previews (dark, RTL, Dynamic Type) |
| 06 | `step-06-integration` | `@Observable` view models, navigation, permissions, real data |
| 07 | `step-07-quality-release` | UI tests, screenshots, accessibility, release |
| — | `main` | The finished app |

Full details: [ROADMAP.md](docs/ROADMAP.md).

## The same app on four platforms

| Platform | Repository |
|---|---|
| Android (Kotlin, Compose) | [atmos-android](https://github.com/AhmedJAbuSada/atmos-android) |
| **iOS** (Swift, SwiftUI) | you are here |
| React Native (TypeScript) | [atmos-react-native](https://github.com/AhmedJAbuSada/atmos-react-native) |
| Flutter (Dart) | [atmos-flutter](https://github.com/AhmedJAbuSada/atmos-flutter) |

Same product documents, same architecture, same seven steps. Compare how each platform
solves the same problem: Hilt vs a hand-written composition root, Room vs JSON files,
`StateFlow` vs `@Observable`.

## Features (v1.0)

- 📍 Current weather at your location
- 🕐 Next 24 hours and 🗓 next 7 days
- 🔍 City search with names in your language, ⭐ saved cities
- 📴 Works offline with the last known data
- 🌡 °C / °F, km/h / m/s / mph
- 🌙 Dark mode
- 🌍 **English, Türkçe, العربية** (full right-to-left layout)

Weather data by [Open-Meteo.com](https://open-meteo.com/). No API key is needed.

## Architecture at a glance

```mermaid
flowchart LR
    app["App target<br/>composition root"] --> pres["AtmosPresentation<br/>SwiftUI + view models"]
    app --> data["AtmosData<br/>URLSession, files"]
    pres --> domain["AtmosDomain<br/>Foundation only"]
    data --> domain
```

Each layer is a Swift package target, so the compiler enforces the dependency rule. Read
[ARCHITECTURE.md](docs/architecture/ARCHITECTURE.md).

## 🤖 Built with an AI agent, the professional way

- [**AI_WORKFLOW.md**](docs/AI_WORKFLOW.md): spec → plan → review → build → verify → review.
- [**AGENTS.md**](AGENTS.md): the rules every AI session loads.
- [**docs/ai/prompts/**](docs/ai/prompts/): the real prompts used at each step.
- Every step guide ends with **"How the AI agent helped in this step"**, including what
  went wrong.

## Start reading

1. [Step 01 guide](docs/steps/01-planning.md)
2. [PRD](docs/product/PRD.md) → [User stories](docs/product/USER_STORIES.md)
3. [Architecture](docs/architecture/ARCHITECTURE.md) → [ADRs](docs/architecture/adr/)

## Author

**Ahmed J. AbuSada**, senior mobile and front-end developer.
GitHub: [@AhmedJAbuSada](https://github.com/AhmedJAbuSada)

## License

[MIT](LICENSE). Weather data © Open-Meteo.com, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
