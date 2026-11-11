# Localization review (ADR-0005)

The Turkish and Arabic texts were written with an AI agent and have **not yet been reviewed
by a native speaker**. Before a release, a native speaker checks each language.

## Where the texts are
- `Packages/AtmosKit/Sources/AtmosPresentation/Resources/Localizable.xcstrings`: every screen.
- `App/Resources/InfoPlist.xcstrings`: the location permission dialog text.

Open them in Xcode for a side-by-side table with translation states.

## For each language
- [ ] Every string reads naturally, not like a translation.
- [ ] Weather terms match what local weather services use.
- [ ] Plurals: Turkish (`one`, `other`); Arabic (`zero`, `one`, `two`, `few`, `many`,
      `other`). Check "Updated N hours ago" for N = 0, 1, 2, 3, 11, 100.
- [ ] Numbers: Turkish decimal comma (`6,9 m/s`) and leading percent (`%69`); Arabic with Latin
      digits by product decision.
- [ ] City search returns names in the language (`İstanbul`, `اسطنبول`).

## Arabic layout
- [ ] Everything with a direction is mirrored (back button, lists, chevrons).
- [ ] Numbers, temperatures and SF Symbols are **not** mirrored; values like `11°` never
      appear as `°11`.
