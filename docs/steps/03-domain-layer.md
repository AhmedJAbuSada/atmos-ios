# Step 03 — Domain layer: the business rules, in plain Swift

**Branch:** `step-03-domain-layer` · **Previous:** [step 02](02-project-structure.md) · **Next:** step 04, data layer

The domain is what Atmos **knows and decides**, written with nothing but Foundation. It
holds the same rules as the
[Android domain](https://github.com/AhmedJAbuSada/atmos-android/blob/step-03-domain-layer/docs/steps/03-domain-layer.md).
Reading the two side by side shows what is **architecture** (identical) and what is
**language** (different).

## What this step adds

```
Packages/AtmosKit/Sources/
├── AtmosDomain/
│   ├── Common/     DomainError (typed throws), DateProvider, ValueStream
│   ├── Settings/   Temperature, WindSpeed, UserSettings, settings use cases
│   ├── Location/   Coordinates, City, Place, protocols, city use cases
│   └── Weather/    Forecast, WeatherCondition, ForecastFreshness, GetForecastUseCase …
└── AtmosTesting/   actor-based fakes + TestData, shared by every layer's tests
Packages/AtmosKit/Tests/AtmosDomainTests/   33 tests (with parameterised cases)
docs/architecture/adr/0009-cancellation-with-typed-throws.md
```

## Same architecture, different language

| Idea | Android (Kotlin) | iOS (Swift) |
|---|---|---|
| Errors as values | `AppResult<T>` sealed type | `async throws(DomainError)` (typed throws) |
| Observable values | `StateFlow` | `ValueStream` actor → `AsyncStream` |
| Units | `@JvmInline value class` | `struct` |
| Invalid coordinates | `require(...)` throws | failable `init?` returns `nil` |
| Use case call | `operator fun invoke` | `func callAsFunction` |
| Injected time | `java.time.Clock` | `DateProvider` protocol |
| Shared test fakes | Gradle test fixtures | an `AtmosTesting` target |
| Thread safety of fakes | `MutableStateFlow` | `actor` (Swift 6 strict concurrency) |

## Key ideas

### 1. The domain owns the protocols
`GetForecastUseCase` depends on `WeatherRepository`, a protocol declared **in the domain**.
The implementation (step 04) will conform to it from `AtmosData`. Source dependencies point
inwards, even though data flows outwards.

### 2. The business rule is one table, and one test per row
```swift
/// | Cache       | forceRefresh | Network  | Result                                  |
/// | fresh       | false        | not used | cached                                  |
/// | stale/none  | any          | ok       | new                                     |
/// | stale/fresh | any          | fails    | cached, marked outdated with the error  |
/// | none        | any          | fails    | throws the error                        |
```

### 3. Typed throws, and a plan that met the compiler
```swift
func fetchForecast(for coordinates: Coordinates) async throws(DomainError) -> Forecast
```
Callers know exactly what can fail, and `switch error` is exhaustive. But a function declared
`throws(DomainError)` **cannot throw** Swift's `CancellationError`, which ADR-0006 had
assumed. Instead of quietly bending the code, the decision was recorded in
[ADR-0009](../architecture/adr/0009-cancellation-with-typed-throws.md): an explicit
`.cancelled` case that is passed through and never shown. A test proves a cancelled download
is never hidden behind old cached data.

### 4. Parameterised tests
```swift
@Test("every documented WMO code maps to a known condition", arguments: [
    (0, WeatherCondition.clear), (1, .mainlyClear), …
])
func knownCodes(code: Int, condition: WeatherCondition)
```
One test function, 28 reported cases: a failure names the exact code.

### 5. Lint made the code better
SwiftLint rejected the 15-branch `switch` for WMO codes (cyclomatic complexity). The answer
was not to disable the rule but to write the mapping as a **lookup table**, which is also
easier to compare with the API documentation.

## Run it yourself

```bash
git switch step-03-domain-layer
cd Packages/AtmosKit && swift test     # macOS or Linux; ~10 ms
```

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Ported every domain rule from Kotlin to idiomatic Swift, tests first | Compared behaviour with Android |
| Found the typed-throws / cancellation conflict and wrote ADR-0009 | Accepted the decision |
| Built and ran all tests on Linux before pushing | — |

**What went wrong, and what we learned:**
1. **Seven SwiftLint findings in CI** (long lines, trailing commas, a complex `switch`). The
   agent cannot run SwiftLint in its Linux sandbox, so CI caught them. All were fixed
   without disabling a single rule.
2. **Naming clash:** the Android rules said "inject a `Clock`", but Swift's standard library
   already has a `Clock` protocol (for durations). The type became `DateProvider`, and
   `AGENTS.md` was updated so future sessions use the right name.

Prompts: the step-03 task was *"Port the Android domain to Swift. Same rules, same tests,
idiomatic Swift 6. Record any decision that differs from the ADRs."*

## Checklist: is step 03 done?
- [x] Entities, protocols and use cases with Foundation only
- [x] Typed throws; ADR-0009 for cancellation
- [x] 33 tests, shared fakes target, green on Linux and macOS
- [x] Step guide and `PROGRESS.md` updated
