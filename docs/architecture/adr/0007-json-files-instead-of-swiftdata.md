# ADR-0007: Storage — JSON files and `UserDefaults`, not SwiftData

- **Status:** Accepted
- **Date:** 2026-11-11

## Context
We store three things: the last forecast per place, the saved cities (a short list), and
the settings (four values). The Android version uses Room and DataStore.

## Decision
- **Saved cities and the forecast cache:** `Codable` values written as JSON files in
  Application Support, behind a small `actor` (`JSONFileStore`).
- **Settings:** `UserDefaults`.

## Alternatives considered
| Option | Why not |
|---|---|
| SwiftData | Great for querying object graphs; we have none. It needs Apple platforms to test, and adds schema and migration machinery for a list of ten cities. |
| Core Data | Same, with more code. |
| SQLite (GRDB) | A dependency we would not use beyond key-value access. |

## Consequences
- ✅ The whole data layer builds and tests with `swift test` anywhere, including Linux CI.
- ✅ The cached forecast is stored as the raw API JSON and mapped on read, like Android:
  fresh and cached data can never disagree.
- ⚠️ If the app ever needs queries (search history, statistics), revisit with a new ADR.
