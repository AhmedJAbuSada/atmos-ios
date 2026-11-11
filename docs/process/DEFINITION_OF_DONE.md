# Definition of Done

A story or task is **done** only when every box is ticked. This applies equally to code
written by a person and code written by an AI agent.

## Code
- [ ] Meets every acceptance criterion of its user story.
- [ ] Follows the [architecture rules](../architecture/ARCHITECTURE.md) and
      [coding standards](CODING_STANDARDS.md).
- [ ] No hard-coded user-facing strings; English, Turkish and Arabic added to the String Catalog.
- [ ] No new compiler warnings; SwiftLint passes (including the locale-safe casing rule).

## Tests
- [ ] Unit tests for new logic, including at least one **failure** path.
- [ ] Existing tests pass locally and in CI.
- [ ] Coverage of `AtmosDomain` and `AtmosData` did not drop.

## UI (if the change has UI)
- [ ] Checked in light and dark mode.
- [ ] Checked in **Arabic (RTL)** and **Turkish**.
- [ ] Checked with the largest Dynamic Type size.
- [ ] Loading, empty and error states exist.
- [ ] Screenshots attached to the PR.

## Review
- [ ] PR template filled in.
- [ ] Approved by at least one human reviewer.
- [ ] CI is green.

## Docs
- [ ] README, ADRs or step guide updated if behaviour or decisions changed.
- [ ] `docs/PROGRESS.md` updated.
