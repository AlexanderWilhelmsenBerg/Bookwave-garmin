# BookWave Garmin

Garmin Connect IQ applications for BookWave.

Phase 1 is Companion-first: a normal Connect IQ Device App that owns Garmin-side playback snapshot validation, persistence and truthful disconnected-state display. Phone transport, playback commands, watch face, Running Data Field and Audio Provider work are later phases.

## Current target

- fēnix 8 43 mm AMOLED: `fenix843mm`
- fēnix 8 47/51 mm AMOLED: `fenix847mm`
- minimum Connect IQ API: 6.0.0
- recommended development SDK: Connect IQ 9.2.0

## Structure

```text
apps/companion/       Connect IQ Device App
shared/model/         playback state, persistence, formatting
shared/protocol/      versioning and validation
shared/test-fixtures/ debug/test-only deterministic fixtures
docs/                 architecture, protocol and acceptance notes
```

See:

- `AGENTS.md` for repository boundaries and agent rules;
- `plan.md` for delivery phases;
- `docs/architecture.md` for app boundaries;
- `docs/phone-watch-protocol.md` for the Phase 1 playback contract;
- `docs/testing/phase-1-companion.md` for build, simulator, sideload and physical acceptance steps.

No Android BookWave changes are made in this repository.


## Delivery snapshot — 2026-10-07

Phase 1 is merged in [PR #1](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/pull/1). PR and main verification pass both supported target
builds, test-enabled compilation and export. Run No Evil **execution**, simulator and physical fēnix8
acceptance remain NOT RUN under [#2](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/2).
Android's owner-confirmed `mcp/garmin-phase-2-mobile-bridge` branch is an unmerged candidate; Garmin has
no transport counterpart yet. [#3](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/3) tracks that integration. See
[cross-repository dependencies](docs/reconciliation.md) and [Phase 2 test inventory](docs/testing/phase-2-transport.md).
WatchShelf + Sidecar remain the initial offline-audio path; helper/provider replacement is optional future work.
