# Changelog

All notable changes to Atmos for iOS. The format follows
[Keep a Changelog](https://keepachangelog.com/), and versions follow
[Semantic Versioning](https://semver.org/). Each tutorial step is one minor version until 1.0.0.

## [1.0.0] — step 07, quality & release
### Added
- End-to-end UI test of the city-search journey against the real API, in English, Turkish
  and Arabic, with screenshots recorded by CI.
- Release build in CI; privacy manifest; localized location permission text.
- Release, accessibility and localization checklists.

## [0.6.0] — step 06, integration
### Added
- Observable view models, typed navigation, debounced search with Undo, the
  explanation-first location permission flow, the system per-app language page.

## [0.5.0] — step 05, presentation
### Added
- Stateless SwiftUI screens with previews; String Catalog in en, tr, ar; locale-aware
  formatting with directional isolates.

## [0.4.0] — step 04, data layer
### Added
- URLSession client with retry, Codable DTOs and mappers tested on recorded responses, JSON
  file cache, saved cities, UserDefaults settings, CoreLocation.

## [0.3.0] — step 03, domain layer
### Added
- Entities, use cases and repository protocols in plain Swift; typed throws; ADR-0009.

## [0.2.0] — step 02, project structure
### Added
- AtmosKit package targets, XcodeGen app, SwiftLint rules, CI on Linux and macOS.

## [0.1.0] — step 01, planning
### Added
- Product documents shared with Android; iOS architecture and ADRs; AI agent rules.
