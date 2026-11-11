# Progress — hand-over note

> Read this first at the start of every work session (human or AI). Update it at the end.

**Current step:** 06, integration ✅ done
**Next up:** step 07, quality & release (`step-07-quality-release`)
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
| 07 Quality & release | ⏳ Next | `step-07-quality-release` |

## Next up: step 07 plan
1. UI test journey on the Simulator against the real API: no permission → search
   "Istanbul" → add → choose → the forecast appears.
2. Screenshots of every main screen in light, dark, Arabic and Turkish, recorded in CI with
   `XCUIScreenshot` (or a snapshot test) and committed to `docs/screenshots`; README gallery.
3. Localize the system texts (location usage description) in en, tr, ar via
   `InfoPlist.xcstrings`.
4. Release: version 1.0.0, a `Release` build in CI, signing documented (never committed),
   privacy manifest (`PrivacyInfo.xcprivacy`: no tracking, UserDefaults reason code).
5. CHANGELOG, release / accessibility (VoiceOver) / localization checklists.
6. Merge to `main` as v1.0.0.

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
