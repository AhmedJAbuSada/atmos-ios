# Progress — hand-over note

> Read this first at the start of every work session (human or AI). Update it at the end.

**Current step:** 07, quality & release ✅ done. **iOS v1.0.0 is complete.**
**Next up:** the same seven steps for React Native ([atmos-react-native](https://github.com/AhmedJAbuSada/atmos-react-native)), bare React Native CLI
**Last updated:** 2026-11-11

## Status

| Step | Status | Branch |
|---|---|---|
| 01 Planning | ✅ Done | `step-01-planning` |
| 02 Project structure | ✅ Done | `step-02-project-structure` |
| 03 Domain layer | ✅ Done | `step-03-domain-layer` |
| 04 Data layer | ✅ Done | `step-04-data-layer` |
| 05 Presentation / UI | ✅ Done | `step-05-presentation-ui` |
| 06 Integration | ✅ Done | `step-06-integration` |
| 07 Quality & release | ✅ Done | `step-07-quality-release` |

## After 1.0 (optional)
- Native-speaker review of tr and ar; VoiceOver pass on a real iPhone.
- Snapshot comparison in CI (fail on unexpected screenshot changes).
- TestFlight upload from CI with App Store Connect API keys.

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
