# Roadmap — the seven steps

Each step is a branch, and each branch contains everything from the step before.

```bash
git clone https://github.com/AhmedJAbuSada/atmos-ios.git
cd atmos-ios
git switch step-03-domain-layer   # any step
```

| Step | Branch | You learn | Guide |
|---|---|---|---|
| 01 | `step-01-planning` | Requirements, user stories, API contract, architecture and ADRs, team process, AI agent rules | [01-planning.md](steps/01-planning.md) |
| 02 | `step-02-project-structure` | Swift package targets enforcing the layers, XcodeGen, SwiftLint, CI on macOS | [02-project-structure.md](steps/02-project-structure.md) |
| 03 | `step-03-domain-layer` | Entities, use cases, typed throws, Swift Testing, fakes | [03-domain-layer.md](steps/03-domain-layer.md) |
| 04 | `step-04-data-layer` | URLSession, Codable DTOs, mappers, JSON file cache, settings, location | [04-data-layer.md](steps/04-data-layer.md) |
| 05 | `step-05-presentation-ui` | Design system, SwiftUI screens and previews, String Catalog | — |
| 06 | `step-06-integration` | `@Observable` view models, navigation, permissions, real data | — |
| 07 | `step-07-quality-release` | UI tests, screenshots, accessibility, release | — |
| — | `main` | The finished app | — |

Every step follows the loop from [AI_WORKFLOW.md](AI_WORKFLOW.md): spec → plan → review →
build with tests → verify → review → merge.
