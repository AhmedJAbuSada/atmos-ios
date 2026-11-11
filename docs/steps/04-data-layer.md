# Step 04 — Data layer: the app's backend on the phone (iOS)

**Branch:** `step-04-data-layer` · **Previous:** [step 03](03-domain-layer.md) · **Next:** [step 05, presentation / UI](05-presentation-ui.md)

The data layer talks to the outside world (Open-Meteo, files, `UserDefaults`, CoreLocation)
and **conforms to the protocols the domain declared in step 03**. Nothing outside
`AtmosData` knows that `URLSession`, JSON or CoreLocation exist; the app only ever sees
domain protocols.

## What this step adds

```
Packages/AtmosKit/Sources/AtmosData/
├── Remote/
│   ├── DTOs.swift            ← the JSON, field by field, all optional
│   ├── HTTPClient.swift      ← a one-method protocol; URLSession client; retry with back-off
│   ├── OpenMeteoAPI.swift    ← builds URLs, decodes DTOs
│   └── ErrorMapping.swift    ← the ONLY place that knows URLError
├── Mappers/                  ← DTO → domain entities (time zones!)
├── Local/
│   ├── JSONFileStore.swift   ← an actor writing Codable values as files (ADR-0007)
│   └── CacheKey.swift        ← "41.01,28.97", always en_US_POSIX
├── Repositories/             ← conform to WeatherRepository, CityRepository, SettingsRepository
├── Location/CoreLocationRepository.swift   ← iOS 17 CLLocationUpdate (Apple platforms only)
└── DataModule.swift          ← the only public type: factories returning domain protocols

Packages/AtmosKit/Tests/AtmosDataTests/   ← 37 tests on the recorded samples, also on Linux
App/AppContainer.swift                    ← creates the real repositories
```

## Same ideas as Android, different tools

| Concern | Android | iOS |
|---|---|---|
| HTTP | Retrofit + OkHttp interceptors | `URLSession` behind an `HTTPClient` protocol |
| JSON | kotlinx.serialization | `Codable` with `CodingKeys` |
| Retry | an OkHttp `Interceptor` | a decorator: `RetryingHTTPClient` wraps any `HTTPClient` |
| Test server | MockWebServer | a fake `HTTPClient` replaying the samples (no network, any OS) |
| Cache + saved cities | Room | `JSONFileStore` actor (ADR-0007) |
| Settings | DataStore | `UserDefaults` |
| Location | FusedLocationProviderClient | `CLLocationUpdate.liveUpdates()` |
| Wiring | Hilt `@Binds` | `DataModule.makeRepositories` called by `AppContainer` |

## Key ideas

### 1. A protocol at the edge of the network
```swift
protocol HTTPClient: Sendable {
    func get(_ url: URL) async throws -> (data: Data, statusCode: Int)
}
```
Everything above it (the API, the retry rule, the repositories) is tested with a fake that
replays the **real recorded responses** from `docs/api/samples`. No mock server, no
`URLProtocol` tricks, and the tests run on Linux in milliseconds.

### 2. Retry as a decorator
`RetryingHTTPClient(wrapping: URLSessionHTTPClient(...))` adds retries without the real
client knowing. The rule from the API contract, tested case by case:

| Failure | Retried? |
|---|---|
| Network error (`URLError`) | ✅ up to 2×, 1 s then 2 s |
| HTTP 5xx | ✅ up to 2× |
| HTTP 4xx | ❌ our request is wrong |
| Cancellation | ❌ the user left; stop now |

### 3. Time zones are part of the data
Open-Meteo sends `"2026-11-11T10:15"`: local time at the place, with no offset. The mapper
reads it **in the place's time zone** (`Europe/Istanbul`), producing a real instant. A test
checks that 10:15 in Istanbul is 07:15 UTC. The parser uses `en_US_POSIX`, so a phone with a
12-hour clock or another calendar still reads the API correctly.

### 4. Typed errors at the boundary
Every repository function looks like this:
```swift
func fetchForecast(for coordinates: Coordinates) async throws(DomainError) -> Forecast {
    do { … } catch { throw DomainError.from(error) }
}
```
`DomainError.from` is the single translation table: `URLError.timedOut` → `.timeout`,
`URLError.cancelled` and `CancellationError` → `.cancelled` (ADR-0009), HTTP 404 →
`.notFound`, any other status → `.server(code:)`.

### 5. One public type
Everything in `AtmosData` is `internal` except `DataModule`, whose factory returns
`any WeatherRepository`, `any CityRepository` and so on. The app target cannot even name
`DefaultWeatherRepository`. That is the iOS version of Android's `internal` + Hilt bindings.

### 6. Lessons carried over from Android
- **The empty search has no `results` key.** The DTO makes it optional, and a test uses the
  recorded `geocoding_empty.json`.
- **The cache key ignores the phone's language** (`en_US_POSIX`), so `41.01` never becomes
  `41,01` on a Turkish phone.
- **An unreadable cache is "no cache"**, never a crash.

## Run it yourself

```bash
git switch step-04-data-layer
cd Packages/AtmosKit && swift test     # 70 tests: domain + data, macOS or Linux
```

## How the AI agent helped in this step

| The agent | The human |
|---|---|
| Wrote the DTOs, client, mappers, store and repositories | Reviewed the storage choice (ADR-0007) |
| Tested everything against the recorded samples, on Linux, before pushing | — |
| Carried over the Android lessons (empty results, cache key locale, corrupt cache) | — |

**What went wrong, and what we learned:**
1. **A brace too many.** A scripted edit to a test file left an extra `}`; the compiler
   caught it at once. Mechanical edits still need a build.
2. **CoreLocation cannot be compiled in the sandbox** (it is Apple-only). The file is
   wrapped in `#if canImport(CoreLocation)`, and the macOS CI job is the first place it
   compiles. Know which parts of your code each machine can check.
3. **Not done yet:** the location permission text in `project.yml` is English only; it is
   translated in step 07 with the other system texts.

## Checklist: is step 04 done?
- [x] Every domain protocol has an implementation in `AtmosData`
- [x] DTOs and mappers tested against every recorded sample
- [x] Error mapping, retry rules and the API queries tested
- [x] File store, cache, saved cities and settings tested
- [x] The composition root creates the real repositories
- [x] Step guide and `PROGRESS.md` updated
