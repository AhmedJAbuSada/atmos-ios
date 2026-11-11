# Step 02 — Project structure: make the architecture a compile-time rule (iOS)

**Branch:** `step-02-project-structure` · **Previous:** [step 01](01-planning.md) · **Next:** [step 03, domain layer](03-domain-layer.md)

In step 01 we *wrote down* the rules. In this step the **tools enforce them**, before any
feature exists.

## What this step adds

```
atmos-ios/
├── project.yml                    ← XcodeGen spec: the app target + UI test target
├── App/
│   ├── AtmosApp.swift             ← @main, asks the container for the first screen
│   ├── AppContainer.swift         ← the composition root (empty for now)
│   └── Resources/Assets.xcassets  ← app icon
├── UITests/LaunchTests.swift      ← launches the real app on the Simulator
├── Packages/AtmosKit/
│   ├── Package.swift              ← THE dependency rule, for the compiler
│   ├── Sources/AtmosDomain/       ← Foundation only
│   ├── Sources/AtmosData/         ← depends on AtmosDomain
│   ├── Sources/AtmosPresentation/ ← depends on AtmosDomain; HelloView + String Catalog
│   └── Tests/…                    ← Swift Testing
├── .swiftlint.yml                 ← style + 2 custom rules
├── scripts/simulator-destination.py, annotate-log.py
└── .github/workflows/ci.yml       ← Linux job + macOS job
```

## Key ideas

### 1. `Package.swift` is the dependency rule
```swift
.target(name: "AtmosDomain"),
.target(name: "AtmosData", dependencies: ["AtmosDomain"]),
.target(name: "AtmosPresentation", dependencies: ["AtmosDomain"], resources: [.process("Resources")]),
```
A target can only import what is listed. Real output when the domain tries to import the
data layer:

```
Sources/AtmosDomain/Leak.swift:1:8: error: circular dependency between modules 'AtmosDomain' and 'AtmosData'
```

### 2. …but not for system frameworks
Swift packages control which **packages** a target may import. They cannot stop
`import SwiftUI` or `import CoreLocation` inside `AtmosDomain` on a Mac, because those are
part of the SDK. So a SwiftLint rule closes the gap:

```yaml
domain_imports_foundation_only:
  included: ".*/Sources/AtmosDomain/.*\\.swift"
  regex: '^\s*import\s+(SwiftUI|UIKit|CoreLocation|Combine|SwiftData|CoreData|AtmosData|AtmosPresentation)\b'
  severity: error
```

**Lesson:** know exactly what each tool guarantees, and cover the gaps with another tool.

### 3. The domain runs on Linux, and that's a feature
On Linux, `Package.swift` leaves out the SwiftUI target:

```swift
#if !os(Linux)
targets += [ .target(name: "AtmosPresentation", …) ]
#endif
```

So `swift test` builds and tests the domain and data layers with nothing but the open-source
Swift toolchain. CI has a fast Linux job for that, and this tutorial's AI agent, working in
a Linux cloud sandbox with no Mac, could build and test those layers itself. If someone ever
adds `import SwiftUI` to the domain, the Linux job fails with `no such module 'SwiftUI'`.

### 4. A generated Xcode project
`project.yml` describes the app in ~70 readable lines; `xcodegen` produces
`Atmos.xcodeproj`, which is git-ignored (ADR-0008). No more `project.pbxproj` merge
conflicts, and project changes are reviewable.

```bash
brew install xcodegen
xcodegen
open Atmos.xcodeproj
```

### 5. A thin app target
The app target holds only `AtmosApp` (the entry point) and `AppContainer` (the composition
root, ADR-0004). Everything else is in the package, where it is modular and testable.

### 6. Strictness from day one
- Swift 6 language mode with **complete** strict concurrency.
- `SWIFT_TREAT_WARNINGS_AS_ERRORS = YES`.
- SwiftLint with `--strict` in CI (warnings fail the build), plus `force_unwrapping` and
  `implicitly_unwrapped_optional` opted in.
- A custom rule against `uppercased()` without a locale (ADR-0005).

### 7. The String Catalog
`Localizable.xcstrings` holds every string in English, Turkish and Arabic in one file, with
translation states. The app's `Info.plist` lists `CFBundleLocalizations: [en, tr, ar]`, so
iOS shows a **Language** option in *Settings → Atmos*: the per-app language comes for free.

### 8. CI on two operating systems

| Job | Runs on | Does |
|---|---|---|
| Domain and data on Linux | ubuntu | `swift test` (domain + data) |
| Lint, package tests and app on macOS | macOS | SwiftLint, `swift test` (all three layers), `xcodegen`, `xcodebuild test` with the UI test on the newest iPhone simulator |

Simulator names change with every Xcode release, so
[`simulator-destination.py`](../../scripts/simulator-destination.py) picks the newest
available iPhone instead of hard-coding "iPhone 16".

## Run it yourself

```bash
git switch step-02-project-structure
(cd Packages/AtmosKit && swift test)    # any Mac or Linux with Swift 6
brew install swiftlint xcodegen
swiftlint
xcodegen && open Atmos.xcodeproj        # then ⌘R
```

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Wrote `Package.swift`, `project.yml`, the SwiftLint rules and CI | Reviewed the target layout |
| Built and tested the package on Linux, and proved the domain cannot import the data layer | — |
| Noticed that packages don't restrict system frameworks, and added a lint rule for it | — |
| Drew the app icon (the same sun and cloud as Android) | Judged the look |

**What went wrong, and what we learned:**
1. **The same CI bug twice.** The first draft of the macOS test step used
   `… | tee log | grep … || true` followed by `${PIPESTATUS[0]}`. After `|| true`,
   `PIPESTATUS` describes `true`, so a failing build would have passed. The Android CI had
   a related `PIPESTATUS` bug. The agent caught it in self-review and rewrote the step to
   capture the exit status explicitly. **Lesson:** shell exit codes are a classic trap;
   prefer simple, explicit code in CI.
2. **An off-centre icon.** The first icon reused the Android drawing coordinates, which are
   offset for Android's adaptive-icon safe zone. The agent looked at the image, saw the
   shapes sitting low and right, and centred them.
3. **CI failed twice without saying why.** Instead of guessing, the agent added
   [`annotate-log.py`](../../scripts/annotate-log.py), which turns any build log into
   GitHub annotations: the `error:` lines, or the last 40 lines. The next run showed both
   causes at once:
   - Linux: `libxml2.so.2: cannot open shared object file`. `ubuntu-latest` had moved to a
     newer Ubuntu than the Swift toolchain is built for. Fix: pin `ubuntu-24.04`.
   - macOS: the simulator-picking script failed before `xcodebuild` even ran (an escaped
     quote inside a Python f-string, rejected by older Python versions). It was rewritten as
     a small tested Python file.

   **Lesson:** make failures *visible* first, then fix them. And pin the versions of
   everything a build depends on, including the operating system image.

Prompts: [docs/ai/prompts/step-02-project-structure.md](../ai/prompts/step-02-project-structure.md).

## Checklist: is step 02 done?
- [x] Three package targets; illegal package imports fail to compile (proved)
- [x] SwiftLint rule for system-framework imports in the domain
- [x] XcodeGen app target and UI test target; composition root
- [x] String Catalog with en, tr, ar; `CFBundleLocalizations`
- [x] CI on Linux and macOS
- [x] Step guide, prompts and `PROGRESS.md` updated
