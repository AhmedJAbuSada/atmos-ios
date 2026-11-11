# Progress — hand-over note

> Read this first at the start of every work session (human or AI). Update it at the end.

**Current step:** 04, data layer ✅ done
**Next up:** step 05, presentation / UI (`step-05-presentation-ui`)
**Last updated:** 2026-11-11

## Status

| Step | Status | Branch |
|---|---|---|
| 01 Planning | ✅ Done | `step-01-planning` |
| 02 Project structure | ✅ Done | `step-02-project-structure` |
| 03 Domain layer | ✅ Done | `step-03-domain-layer` |
| 04 Data layer | ✅ Done | `step-04-data-layer` |
| 05 Presentation / UI | ⏳ Next | `step-05-presentation-ui` |
| 06 Integration | ⬜ | — |
| 07 Quality & release | ⬜ | — |

## Next up: step 05 plan
Everything in `AtmosPresentation`, with fake data; no view models yet (step 06).
1. Design system: colours (light/dark, AA contrast), typography with Dynamic Type, spacing.
2. `WeatherFormatter`: `FormatStyle` with the environment locale; Turkish `%69` and decimal
   comma, Arabic with Latin digits (`ar@numbers=latn`); values wrapped in directional
   isolates from the start. Tests in en, tr, ar (they run on macOS only).
3. Condition labels and SF Symbols per `WeatherCondition` (night variants); `DomainError`
   messages.
4. Stateless content views: Home, Cities, Settings, About; every state previewed in light,
   dark, Arabic and the largest Dynamic Type size.
5. All strings in `Localizable.xcstrings` (en, tr, ar), with plural variations.
6. `AppContainer.makeRootView()` shows Home with preview data.

## Process rule
After a step is merged into `main`, add the "📍 You are on Step N" section to the top of
that step branch's README (see earlier branches for the format), then push the branch. Doing
it after the merge keeps `main`'s README free of step sections.

## Notes for the next session
- Real Open-Meteo responses are in `docs/api/samples/`.
- Bundle identifier: `dev.ahmedabusada.atmos`.
- SwiftLint cannot run in the cloud sandbox; CI reports its findings as annotations.
- Cloud sessions have no Xcode: domain and data build with the Linux Swift toolchain
  (install it to `/opt/swift`); anything with SwiftUI is verified in CI on macOS.
