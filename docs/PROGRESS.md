# Progress — hand-over note

> Read this first at the start of every work session (human or AI). Update it at the end.

**Current step:** 03, domain layer ✅ done
**Next up:** step 04, data layer (`step-04-data-layer`)
**Last updated:** 2026-11-11

## Status

| Step | Status | Branch |
|---|---|---|
| 01 Planning | ✅ Done | `step-01-planning` |
| 02 Project structure | ✅ Done | `step-02-project-structure` |
| 03 Domain layer | ✅ Done | `step-03-domain-layer` |
| 04 Data layer | ⏳ Next | `step-04-data-layer` |
| 05 Presentation / UI | ⬜ | — |
| 06 Integration | ⬜ | — |
| 07 Quality & release | ⬜ | — |

## Next up: step 04 plan
Everything in `AtmosData`; conforms to the domain protocols. Tests read
`docs/api/samples/` directly through `#filePath` (one source of truth).
1. Codable DTOs (all optional; `results` defaults to empty), an `OpenMeteoClient` on
   `URLSession` with timeouts, User-Agent and retry (network errors and 5xx, never 4xx).
2. Mappers DTO → entities (local times + time zone → `Date`), tested on every sample.
3. Error mapping: `URLError` (incl. `.cancelled` → `.cancelled`), HTTP status,
   `DecodingError` → `DomainError`.
4. `JSONFileStore` actor for the forecast cache (raw JSON, key with `Locale(identifier:
   "en_US_POSIX")`) and saved cities; `UserDefaultsSettingsRepository`.
5. `CoreLocationRepository` behind `#if canImport(CoreLocation)`; permission checked, not
   requested.
6. Tests with a stub `URLProtocol` replaying the samples (macOS) and pure mapper/store tests
   (Linux).
7. Wire the implementations in `AppContainer`.

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
