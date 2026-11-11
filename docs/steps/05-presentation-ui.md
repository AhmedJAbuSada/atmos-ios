# Step 05 — Presentation: the views, before any data (iOS)

**Branch:** `step-05-presentation-ui` · **Previous:** [step 04](04-data-layer.md) · **Next:** [step 06, integration](06-integration.md)

Every screen is built as a **stateless view of a state value**, with realistic fake data. No
view model, no repository, no network. When a view can only show what it is given, it can be
designed, previewed and reviewed on its own, in every language and theme.

## What this step adds

```
Packages/AtmosKit/Sources/AtmosPresentation/
├── Theme/AtmosTheme.swift          ← brand accent + spacing; the rest is iOS's semantic styles
├── Formatting/WeatherFormatter.swift ← numbers, units, hours, day names per locale
├── Weather/ConditionUI.swift       ← condition → localized label + SF Symbol; error → message
├── Components/Components.swift     ← message view, outdated banner, skeleton
├── Home/  HomeState.swift, HomeContent.swift
├── Cities/ CitiesState.swift, CitiesContent.swift
├── Settings/SettingsContent.swift
├── About/AboutContent.swift
├── Preview/PreviewData.swift       ← fake data shaped like the recorded API response
└── Resources/Localizable.xcstrings  ← 65 keys in en, tr, ar (with plural variations)
Packages/AtmosKit/Tests/AtmosPresentationTests/WeatherFormatterTests.swift
```

## Key ideas

### 1. State in, actions out
```swift
public struct HomeContent: View {
    let state: HomeState      // .loading, .needsLocation, .failed(DomainError), .content(…)
    let actions: HomeActions  // refresh, retry, requestLocation, openCities, openSettings
}
```
The same idea as the Android `HomeScreen(state, onEvent)`. The view decides nothing; the
view model (step 06) will. Every state has a `#Preview`, including Arabic right-to-left, dark
mode, Turkish with outdated data, and the largest Dynamic Type size.

### 2. Lean on the platform
iOS already gives a lot for free, so the design system is tiny:

| Need | iOS gives | Android needed |
|---|---|---|
| Light/dark colours | `.primary`, `.secondary`, `.background` | a full colour scheme |
| Text sizes | Dynamic Type text styles | `sp` + a type scale |
| Icons | SF Symbols, multicolour, never mirrored | 22 hand-drawn vectors |
| Swipe to delete for VoiceOver | `.swipeActions` are exposed as actions | an extra visible button |
| Per-app language UI | the system Settings page | an in-app picker + AppCompat |

### 3. One String Catalog
`Localizable.xcstrings` holds every string in three languages, with plural variations. Arabic
uses all six forms (`zero`, `one`, `two`, `few`, `many`, `other`): "Updated 2 hours ago" is
`تم التحديث قبل ساعتين`. In code, interpolation picks the key and the plural rule:

```swift
Text("home.updated.hours \(hours)", bundle: .module)   // key: "home.updated.hours %lld"
```

### 4. Lessons from Android, built in from day one
- **Directional isolates:** every formatted value is wrapped in `U+2066 … U+2069`, so
  `11°` can never render as `°11` inside Arabic text (the Android screenshots found that bug).
- **Unit symbols isolated too:** the `°C` / `°F` segments.
- **Turkish formatting:** `%69` and `6,9 m/s`; **Arabic** with Latin digits through
  `ar@numbers=latn`. Tests pin all of it.
- **Tap a day for sunrise and sunset** (US-03): built from the start, after Android's lint
  found it missing.

### 5. Swift 6 and SwiftUI actions
The actions structs are `@MainActor`, and buttons call them inside closures
(`Button { actions.openCities() }`) instead of passing them directly. Passing a
`@MainActor` function where an older SDK expects a plain one can fail to compile under
Swift 6's strict concurrency. Writing it this way compiles on every SDK.

## Run it yourself

```bash
git switch step-05-presentation-ui
xcodegen && open Atmos.xcodeproj     # ⌘R: Home with demo data; open any file for previews
(cd Packages/AtmosKit && swift test) # on a Mac this includes the formatter tests
```

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Wrote the String Catalog, formatter, components and all four screens | Reviewed the screens against the wireframes |
| Carried over every lesson from the Android UI (isolates, Turkish `%`, US-03) | — |
| Wrote previews for every state and configuration | — |

**What went wrong, and what we learned:**
1. **Writing SwiftUI without a compiler.** The cloud sandbox runs Linux, where SwiftUI does
   not exist, so this step was written "blind" and checked by CI on macOS. To keep the round
   trips few, the agent kept the code plain, avoided iOS-only APIs where a cross-platform one
   exists, and anticipated a Swift 6 concurrency error (point 5). The first full compile on
   macOS passed, including the UI test.
2. **Two SwiftLint findings**, both fixed without disabling rules: import order, and a
   symbol `switch` that became a lookup table (as the WMO codes did in step 03).

## Checklist: is step 05 done?
- [x] Stateless Home, Cities, Settings and About with every state previewed
- [x] All strings in en, tr, ar with plurals
- [x] Locale-aware formatter with isolates, tested in three languages
- [x] The app shows Home with demo data; the UI test passes
- [x] Step guide and `PROGRESS.md` updated
