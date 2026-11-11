# Step 06 — Integration: connect the views to the real data (iOS)

**Branch:** `step-06-integration` · **Previous:** [step 05](05-presentation-ui.md) · **Next:** [step 07, quality & release](07-quality-release.md)

Every piece exists: rules (step 03), data (step 04), views (step 05). This step adds the glue:
**view models** that turn use-case results into view state, **container views** that connect
each stateless view to its view model, **navigation**, and the iOS-only parts (location
permission, the system Settings page). After this step Atmos works end to end.

## What this step adds

```
Packages/AtmosKit/Sources/AtmosPresentation/
├── ViewModels/
│   ├── HomeViewModel.swift      ← load, refresh, retry, outdated banner, permission result
│   ├── CitiesViewModel.swift    ← debounced search, add / remove / undo, cached temperatures
│   ├── SettingsViewModel.swift
│   └── SelectedPlaceStore.swift ← which place Home shows (shared by Home and Cities)
└── Navigation/AppRoot.swift     ← NavigationStack with a typed path; theme; containers
App/
├── AppContainer.swift           ← builds repositories → use cases → view models
└── LocationPermission.swift     ← CLLocationManager, explanation first
Packages/AtmosKit/Tests/AtmosPresentationTests/   ← 13 view model tests on the shared fakes
```

## Key ideas

### 1. Views from step 05 did not change
`AppRoot` passes `home.state` into the same `HomeContent` and builds a `HomeActions` from the
view model's methods. Because the views were stateless, integration is just wiring.

### 2. Work that lives as long as the screen
```swift
HomeContent(state: home.state, actions: homeActions)
    .task { await home.run() }
```
`run()` follows the settings and the selected place. SwiftUI cancels the task when the screen
goes away, which cancels any download in progress; the use cases report it as `.cancelled`
(ADR-0009) and the view model simply ignores it.

### 3. Debounce with task cancellation
```swift
public func queryChanged(_ query: String) {
    searchTask?.cancel()                       // the previous keystroke's search
    searchTask = Task { await search(query) }  // waits 300 ms, then searches
}
```
The Android version used `transformLatest`; Swift does the same with plain tasks. A test types
`is`, `ist`, `ista` quickly and checks that only `ista` reached the network.

### 4. Platform-specific code stays at the edge
`AtmosPresentation` builds on macOS and in tests, so it must not depend on UIKit. Anything
iPhone-only is passed in as a closure from the app target:

```swift
PlatformActions(
    requestLocationPermission: { … },   // CoreLocation; Settings after a refusal
    openAppSettings: { … },             // UIApplication.openSettingsURLString
    version: version
)
```

### 5. The permission flow, the iOS way
1. A fresh install has no permission, so the first load ends in **Where are you?**, the
   explanation *before* any system dialog (US-01). The UI test checks exactly this.
2. **Allow location** shows the system dialog. iOS shows it only **once**.
3. After a refusal, the same button opens the app's page in Settings, the only place to change
   it. City search works all along (F-02).

### 6. The language: one source of truth, again
The Settings screen's *Language* row opens the system Settings page of Atmos, where iOS keeps
the per-app language. City names are searched in the language iOS actually chose
(`Bundle.main.preferredLocalizations`). No second copy that could disagree, the lesson from
the Android version.

### 7. Tests that wait for outcomes, not for time
View models update state from background tasks. Instead of `sleep(1)`, the tests poll the
outcome for up to two seconds:
```swift
#expect(await eventually { viewModel.state == .needsLocation })
```
Fast when things work, and a clear failure when they don't.

## Run it yourself

```bash
git switch step-06-integration
xcodegen && open Atmos.xcodeproj   # ⌘R: the real app with real weather
```
Try it: deny location (search still works), choose a city, remove it and tap Undo, switch to
°F, switch the theme, change the language in Settings → Atmos → Language.

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Wrote the view models, the app root and the permission flow | Tries the flows on a device |
| Wrote 13 view model tests from the user stories | — |
| Kept UIKit and CoreLocation out of the package by passing closures | — |

**What went wrong, and what we learned:**
1. **Nothing failed in CI this time**, and that is worth explaining. Writing SwiftUI without a
   compiler, the agent avoided constructs that differ between Swift versions (a `switch`
   expression containing `try await` became a plain `switch` statement), called `@MainActor`
   actions inside closures, and fixed every long line before pushing. Preparation replaced
   trial and error.
2. **A test that tested nothing.** A draft of the undo test contained
   `await eventually { true }`, which always passes. It was replaced with a real wait on the
   saved list during self-review. **Lesson:** read your tests as critically as your code.
3. **The UI test had to change its expectation.** In step 05 the app showed demo data, so
   the test looked for "Next 24 hours". With real data, a fresh simulator has no location
   permission, so the correct first screen is the explanation. The test now checks that.

## Checklist: is step 06 done?
- [x] View models for Home, Cities and Settings, using only use cases
- [x] Typed navigation, theme, permission flow, per-app language
- [x] Debounced search, undo, offline banner
- [x] 13 view model tests; UI test for the first launch
- [x] Step guide and `PROGRESS.md` updated
