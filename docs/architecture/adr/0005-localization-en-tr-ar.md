# ADR-0005: Localization — English, Turkish, Arabic (RTL) with a String Catalog

- **Status:** Accepted
- **Date:** 2026-11-11

## Context
The audience includes Turkish and Arabic speakers. Turkish has special casing rules
(`i/İ`, `ı/I`) and a decimal comma; Arabic is right to left with its own plural rules.

## Decision
1. All user-facing text in one **String Catalog** (`Localizable.xcstrings`) in
   `AtmosPresentation`, with `en` (source), `tr` and `ar`, including plural variations.
2. The language follows the system per-app language setting (Settings → Atmos → Language).
   iOS manages this itself; the app opens that page instead of keeping its own copy (the
   Android version learned the hard way that two sources of truth disagree).
3. **Unit conversion is a domain concern; formatting is a presentation concern.** Numbers,
   dates and units are formatted with `FormatStyle` and the environment `Locale`.
4. **Never** call `uppercased()`/`lowercased()`/`capitalized` without a locale for display
   text. A SwiftLint custom rule makes it a build error.
5. Layouts use `leading`/`trailing`, never `left`/`right`. Directional SF Symbols mirror
   automatically.
6. Formatted values inside sentences are wrapped in Unicode directional isolates, so Arabic
   text cannot reorder `11°` into `°11` (found by screenshot in the Android version).
7. Arabic uses Western digits (0–9) by product decision, as in the Android app.

## Consequences
- ✅ One file holds every translation, with Xcode's built-in review states.
- ⚠️ Every UI PR needs an RTL check; translations need a native-speaker review before release.
