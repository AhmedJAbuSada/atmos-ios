# Step 07 — Quality & release: prove it works the way users get it (iOS)

**Branch:** `step-07-quality-release` · **Previous:** [step 06](06-integration.md)

Unit tests prove the parts work. This step proves **the product** works: on the iOS
Simulator, against the real API, in all three languages, in a Release build, and gets
everything ready for the App Store.

## What this step adds

```
UITests/CitySearchJourneyTests.swift   ← end to end, real API, en / tr / ar, with screenshots
docs/screenshots/ios_*.png             ← recorded by CI from the real app
App/Resources/InfoPlist.xcstrings      ← the permission dialog text in three languages
App/Resources/PrivacyInfo.xcprivacy    ← the privacy manifest Apple requires
Packages/AtmosKit/Tests/AtmosPresentationTests/StringCatalogTests.swift
.github/workflows/ci.yml               ← + Release build, + screenshot recording
CHANGELOG.md, docs/process/*_CHECKLIST.md, LOCALIZATION_REVIEW.md
project.yml                            ← version 1.0.0
```

## Key ideas

### 1. One journey, three languages, no fakes
The UI test walks the most important journey: a new user without location permission searches
for Istanbul, adds it, chooses it and sees the real forecast. It runs in **English, Turkish
and Arabic**, because it finds elements by **accessibility identifier**
(`cities.add.745044`), not by text that changes with the language. A launch argument
(`-uiTestingReset`) resets the app, so every run starts from a clean install.

### 2. Screenshots found two bugs every test missed

| Before | After |
|---|---|
| "condition.overcast" on screen; invisible white clouds | "Overcast" / "غائم" / "Kapalı"; grey clouds, blue rain |

- **The label bug.** `LocalizedStringKey("condition.\(rawValue)")` looks fine, but SwiftUI
  treats the interpolation as a format *argument* and looks up the key `condition.%@`. It
  does not exist, so the raw key was shown, in every language. The fix builds the key from a
  plain `String`. A new test reads the String Catalog and checks that every condition and
  error key exists in en, tr and ar, so it cannot come back.
- **The icon bug.** Multicolour SF Symbols draw clouds in white, which works on dark
  backgrounds and vanishes on light ones. Icons now use explicit palette colours.

The Android version's screenshots found a bidi bug the same way. **Lesson:** for UI, *look* at
the screen. That is why CI records the screenshots and they are committed: every UI change is
an image in the pull request.

### 3. The App Store's privacy rules, in the repository
`PrivacyInfo.xcprivacy` declares: no tracking; coarse location, not linked to the user, used
for app functionality (sent to Open-Meteo to get the forecast); and the reason code for
`UserDefaults`. Reviewers see it in code review; the App Store reads it at upload.

### 4. System texts are translated too
The location permission dialog is shown by iOS, but its text comes from the app. It lives in
`InfoPlist.xcstrings`, translated like every other string.

### 5. A Release build in every CI run
`xcodebuild -configuration Release` builds with optimizations, the configuration users get.
Signing is never in the repository; [RELEASE_CHECKLIST.md](../process/RELEASE_CHECKLIST.md)
explains how a team signs and uploads.

## What is verified, and what is not

| Verified by CI | Still needs a person |
|---|---|
| Package tests on Linux and macOS (domain, data, view models, String Catalog) | A **native-speaker review** of the Turkish and Arabic texts (AI-written) |
| The end-to-end journey on the Simulator in en, tr, ar, real API | A **VoiceOver pass** on a real iPhone |
| The Release build compiles | **Location on a real device** (the Simulator journey covers the no-permission path) |
| Screenshots of the main screens | Signing, TestFlight and App Store submission (needs the team's Apple account) |

## Run it yourself

```bash
git switch step-07-quality-release
xcodegen
xcodebuild test -project Atmos.xcodeproj -scheme Atmos \
  -destination "platform=iOS Simulator,name=iPhone 16"   # use any installed iPhone
```

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Wrote the journey test, the screenshot recording and the CI steps | Reviews the screenshots in each PR |
| **Looked at the screenshots and found both bugs**, then wrote a test for the label bug | — |
| Wrote the privacy manifest and the checklists | Owns the native-speaker review, VoiceOver pass and App Store submission |

**What went wrong, and what we learned:**
1. **Green tests, wrong screen.** The step-06 run was all green, yet the app showed raw keys.
   Tests check what you thought of; screenshots show what you didn't. Both bugs were fixed and
   one became a test.
2. **The sandbox has no Mac**, so the agent never ran the app itself. Everything here was
   verified through CI: tests, the journey, the Release build, and the screenshots the agent
   then inspected as images.

## Checklist: is step 07 done?
- [x] End-to-end journey in three languages against the real API
- [x] Screenshots recorded by CI; two bugs found and fixed; a String Catalog test added
- [x] Localized permission text; privacy manifest; Release build in CI; version 1.0.0
- [x] Changelog and release, accessibility and localization checklists
- [x] Step guide and `PROGRESS.md` updated
