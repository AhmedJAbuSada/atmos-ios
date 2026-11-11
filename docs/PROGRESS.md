# Progress — hand-over note

> Read this first at the start of every work session (human or AI). Update it at the end.

**Current step:** 05, presentation / UI ✅ done
**Next up:** step 06, integration (`step-06-integration`)
**Last updated:** 2026-11-11

## Status

| Step | Status | Branch |
|---|---|---|
| 01 Planning | ✅ Done | `step-01-planning` |
| 02 Project structure | ✅ Done | `step-02-project-structure` |
| 03 Domain layer | ✅ Done | `step-03-domain-layer` |
| 04 Data layer | ✅ Done | `step-04-data-layer` |
| 05 Presentation / UI | ✅ Done | `step-05-presentation-ui` |
| 06 Integration | ⏳ Next | `step-06-integration` |
| 07 Quality & release | ⬜ | — |

## Next up: step 06 plan
1. `@MainActor @Observable` view models in AtmosPresentation: `HomeViewModel` (selected
   place, load, refresh, outdated banner, permission result), `CitiesViewModel` (debounced
   search with a cancelled previous task, add/remove with undo), `SettingsViewModel`.
2. Container views (`HomeView`, `CitiesView`, `SettingsView`) owning the view models and
   handling navigation, the location permission request (`CLLocationManager`, explanation
   first) and opening the system Settings page for the language.
3. `SelectedPlaceStore` shared by Home and Cities; `NavigationStack` with a typed path.
4. `AppContainer` builds the use cases and view models; theme applied with
   `preferredColorScheme`.
5. View model tests with the `AtmosTesting` fakes (they run on macOS).

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
