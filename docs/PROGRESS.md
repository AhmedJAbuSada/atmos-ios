# Progress — hand-over note

> Read this first at the start of every work session (human or AI). Update it at the end.

**Current step:** 01, planning ✅ done
**Next up:** step 02, project structure (`step-02-project-structure`)
**Last updated:** 2026-11-11

## Status

| Step | Status | Branch |
|---|---|---|
| 01 Planning | ✅ Done | `step-01-planning` |
| 02 Project structure | ⏳ Next | `step-02-project-structure` |
| 03 Domain layer | ⬜ | — |
| 04 Data layer | ⬜ | — |
| 05 Presentation / UI | ⬜ | — |
| 06 Integration | ⬜ | — |
| 07 Quality & release | ⬜ | — |

## Next up: step 02 plan
1. `Packages/AtmosKit/Package.swift` with targets `AtmosDomain`, `AtmosData`,
   `AtmosPresentation` and their test targets; Swift 6 language mode, iOS 17.
2. `project.yml` (XcodeGen) for the app target and a UI test target; `App/AtmosApp.swift`
   with a "Hello, Atmos" view; `App/AppContainer.swift`; String Catalog with en/tr/ar.
3. `.swiftlint.yml` with a custom rule against locale-less `uppercased()`/`lowercased()`.
4. GitHub Actions: `swift test` on Linux (fast) and `xcodegen` + `xcodebuild test` on macOS.
5. Prove the guards: an import of `AtmosData` in `AtmosPresentation` fails to compile.
6. `docs/steps/02-project-structure.md`, prompts file, update this file.

## Notes for the next session
- Real Open-Meteo responses are in `docs/api/samples/`.
- Bundle identifier: `dev.ahmedabusada.atmos`.
- Cloud sessions have no Xcode: domain and data build with the Linux Swift toolchain
  (install it to `/opt/swift`); anything with SwiftUI is verified in CI on macOS.
