# BookWave Garmin

**Current Phase 2 implementation (2026-10-07):** foreground phone transport, negotiated ordered
snapshot delivery, durable clear/snapshot acknowledgements and bounded reconnect handling are
implemented. See [the shared wire contract](docs/transport-contract.md). Build/test-compilation and physical acceptance
are recorded separately in the Phase 2 inventory. Commands, reconciliation/Force sync,
complications and other Garmin surfaces remain deferred. Earlier Phase 1 descriptions below
describe the persisted model and its original acceptance, not the current transport scope.


Garmin Connect IQ applications for BookWave.

Phase 1 is Companion-first: a normal Connect IQ Device App that owns Garmin-side playback snapshot validation, persistence and truthful disconnected-state display. Phase 2 adds foreground phone transport; playback commands, watch face, Running Data Field and Audio Provider remain later phases.

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
Phase 2 implements the foreground receiver, ordered snapshot/clear acknowledgements, and
Android bridge integration. Physical acceptance remains pending. [#3](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/3) tracks that integration. See
[cross-repository dependencies](docs/reconciliation.md) and [Phase 2 test inventory](docs/testing/phase-2-transport.md).
WatchShelf + Sidecar remain the initial offline-audio path; helper/provider replacement is optional future work.

## Downloadable development acceptance artifacts

Garmin Verification retains each target's PRG, the fenix847mm Run No Evil PRG and the exported IQ package
for 30 days. Each artifact includes BUILD-INFO with exact source, target, binary hashes and the generated
CI public-key fingerprint. Only out/ is uploaded; private developer keys are excluded. These are
development builds signed with fresh temporary CI keys, not an owner-signed Connect IQ Store release.
Sideload/run acceptance against the matching target and record its identity; preserve the app/storage
boundary when changing development signing identities. No simulator or physical PASS follows upload.
