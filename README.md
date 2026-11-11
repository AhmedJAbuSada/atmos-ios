# Atmos — iOS

**A weather app built step by step, as a public tutorial on professional iOS development
with Clean Architecture, SwiftUI and an AI coding agent.**

<!-- step-banner:start -->
## 📍 You are on Step 07 of 7 — Quality & release: prove it works the way users get it

`step-07-quality-release` · [← Step 06](https://github.com/AhmedJAbuSada/atmos-ios/tree/step-06-integration) · [All steps](docs/ROADMAP.md)

**What this step is.** Proof that the product works the way users get it: an end-to-end UI test on the iOS Simulator against the real API in English, Turkish and Arabic (found by accessibility identifiers, not text), screenshots recorded by CI that found two real bugs (raw string keys and invisible white clouds), a String Catalog test, the localized permission text, the App Store privacy manifest, a Release build in CI, a changelog and release/accessibility/localization checklists.

**Why it matters.** Unit tests prove the parts work; this step proves the *product* does. The CI run was green while the app showed raw keys: tests check what you thought of, screenshots show what you didn't. The guide separates what CI verified from what still needs a person.

**What you will find in this branch**

| Where | What |
|---|---|
| `UITests/CitySearchJourneyTests.swift` | The journey in three languages, with screenshots |
| `docs/screenshots/` | Recorded by CI from the real app |
| `…/AtmosPresentationTests/StringCatalogTests.swift` | Every key exists in en, tr, ar |
| `App/Resources/PrivacyInfo.xcprivacy` | No tracking; coarse location; UserDefaults reason |
| `App/Resources/InfoPlist.xcstrings` | The permission dialog text, translated |
| `docs/process/*_CHECKLIST.md` | Release, VoiceOver, localization review |

**How to study this step**

1. **Read the full guide:** [docs/steps/07-quality-release.md](docs/steps/07-quality-release.md): key ideas, diagrams, and *how the AI agent helped* (including what went wrong).
2. **See exactly what this step changed:** [compare with step 06](https://github.com/AhmedJAbuSada/atmos-ios/compare/step-06-integration...step-07-quality-release).
3. **Run it:**
   ```bash
   xcodegen
   xcodebuild test -project Atmos.xcodeproj -scheme Atmos -destination "platform=iOS Simulator,name=iPhone 16"
   ```
4. **Try the exercise:** Add a fourth journey run in dark mode (`xcrun simctl ui booted appearance dark`) and compare the screenshots.

> This README shows the project *as it was at this step*. The finished app is on
> [`main`](https://github.com/AhmedJAbuSada/atmos-ios).

---
<!-- step-banner:end -->

![Swift](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017+-0D96F6?logo=apple&logoColor=white)
![Clean Architecture](https://img.shields.io/badge/Clean%20Architecture-3%20layers-success)
![Languages](https://img.shields.io/badge/i18n-EN%20%7C%20TR%20%7C%20AR%20(RTL)-blue)
![License](https://img.shields.io/badge/license-MIT-green)

> ✅ **Version 1.0.0.** All seven steps are done.

| English | العربية (RTL) | Türkçe | City search |
|---|---|---|---|
| ![English](docs/screenshots/ios_home_en.png) | ![Arabic](docs/screenshots/ios_home_ar.png) | ![Turkish](docs/screenshots/ios_home_tr.png) | ![Search](docs/screenshots/ios_cities_search_tr.png) |

<sub>Recorded by CI from the real app on the iOS Simulator, with live weather
([CitySearchJourneyTests](UITests/CitySearchJourneyTests.swift)).</sub>

> The [Android version](https://github.com/AhmedJAbuSada/atmos-android) is complete (v1.0.0).

## Why this repository exists

Most sample apps show only the finished code. This one shows **how a professional project
grows**, one level per branch, each explained:

| Step | Branch | What you learn |
|---|---|---|
| 01 | [`step-01-planning`](../../tree/step-01-planning) | PRD, user stories, API contract, architecture, ADRs, team process, AI agent rules |
| 02 | [`step-02-project-structure`](../../tree/step-02-project-structure) | Swift package targets that enforce Clean Architecture, XcodeGen, SwiftLint, CI |
| 03 | [`step-03-domain-layer`](../../tree/step-03-domain-layer) | Entities, use cases, typed throws, Swift Testing |
| 04 | [`step-04-data-layer`](../../tree/step-04-data-layer) | URLSession + Codable, mappers, JSON file cache, settings, location |
| 05 | [`step-05-presentation-ui`](../../tree/step-05-presentation-ui) | Design system, SwiftUI screens with previews (dark, RTL, Dynamic Type) |
| 06 | [`step-06-integration`](../../tree/step-06-integration) | `@Observable` view models, navigation, permissions, real data |
| 07 | [`step-07-quality-release`](../../tree/step-07-quality-release) | UI tests, screenshots, accessibility, release |
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

> **Note on translations:** the Turkish and Arabic texts are written with an AI agent and
> have **not yet been reviewed by a native speaker**. Corrections are welcome.

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
