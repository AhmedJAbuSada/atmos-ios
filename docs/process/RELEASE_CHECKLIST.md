# Release checklist (iOS)

## Before
- [ ] `main` is green: SwiftLint, package tests (Linux and macOS), UI tests, release build.
- [ ] `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` updated in `project.yml`.
- [ ] `CHANGELOG.md` updated.
- [ ] Translations reviewed ([LOCALIZATION_REVIEW.md](LOCALIZATION_REVIEW.md)).
- [ ] VoiceOver pass done ([ACCESSIBILITY_CHECKLIST.md](ACCESSIBILITY_CHECKLIST.md)).
- [ ] Privacy manifest (`App/Resources/PrivacyInfo.xcprivacy`) still matches what the app does.

## Build and upload
Signing certificates and provisioning profiles are **never** in the repository. On a Mac with
the team's Apple Developer account:

```bash
xcodegen
xcodebuild archive -project Atmos.xcodeproj -scheme Atmos -configuration Release \
  -archivePath build/Atmos.xcarchive
```
Then upload the archive with Xcode's Organizer (or `xcrun altool` / Transporter). In CI, use
App Store Connect API keys stored as encrypted secrets.

- [ ] Install the TestFlight build on a real iPhone and run the manual smoke test: location
      allowed, location denied, search, offline, Arabic, Turkish, largest text size.

## After
- [ ] Create a GitHub Release `v1.0.0` from `main`.
- [ ] Release to TestFlight testers first; submit for review after a day without crashes.
