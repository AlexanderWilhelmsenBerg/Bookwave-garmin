# BookWave Garmin Architecture

**Current Phase 2 implementation (2026-10-07):** foreground phone transport, negotiated ordered
snapshot delivery, durable clear/snapshot acknowledgements and bounded reconnect handling are
implemented. See [the shared wire contract](transport-contract.md). Build/test-compilation and physical acceptance
are recorded separately in the Phase 2 inventory. Commands, reconciliation/Force sync,
complications and other Garmin surfaces remain deferred. Earlier Phase 1 descriptions below
describe the persisted model and its original acceptance, not the current transport scope.


## Repository boundary

This repository owns Garmin Connect IQ applications and Garmin-side shared playback-state logic.

The first production application is:

- **BookWave Companion** — a Connect IQ Device App responsible for displaying and persisting the latest valid BookWave playback snapshot.

Future applications belong in this repository but are deliberately not implemented in Phase 1:

- **BookWave Watch Face** — presentation-only surface for the current BookWave state.
- **BookWave Running Data Field** — activity surface combining BookWave state with Garmin activity metrics.
- **BookWave Audio Provider** — optional future work only if replacing/extending WatchShelf is justified.

Each future application will have its own manifest, application id and build artifact. Shared playback/protocol concepts live below `shared/` and must not depend on Companion UI classes.

## Companion responsibility

Phase 1 Companion owns:

- Connect IQ application lifecycle;
- restoring the last valid playback snapshot at startup;
- validating snapshots before persistence;
- persisting only playback/display state;
- truthful never-synced, invalid-state and stored/disconnected UI;
- deterministic test fixtures used only in debug/test builds;
- the Garmin-side versioned playback model.

Phase 1 Companion does **not** own phone transport, playback execution, reconciliation, Audiobookshelf credentials, WatchShelf downloads, or activity metrics.

## Android BookWave responsibility

`AlexanderWilhelmsenBerg/Audiobookshelf-Manager-Claude` remains authoritative for:

- Android playback and Media3;
- BookWave profile state and locks;
- Audiobookshelf authentication/API access;
- future Connect IQ Mobile SDK integration;
- command execution;
- automatic reconciliation and Force Sync policy.

No Android BookWave code is implemented in this repository.

## WatchShelf responsibility

WatchShelf remains the Garmin offline-audiobook engine during the initial BookWave Garmin phases. It owns Garmin-native audiobook browsing/download/offline playback and progress upload through its Sidecar.

BookWave Companion does not duplicate WatchShelf or store Audiobookshelf credentials.

## Phase 1 physical layout

```text
apps/
  companion/
    manifest.xml
    monkey.jungle
    source/
    resources/

shared/
  model/
  protocol/
  test-fixtures/

docs/
  architecture.md
  phone-watch-protocol.md
  testing/
```

The Companion jungle adds `shared/model`, `shared/protocol`, and `shared/test-fixtures` to its source path. The fixture module is annotated `:debug`, and all fixture-seeding entry points are `:test`, so demo values are excluded from release builds and have no production activation path.

## Target products

Phase 1 targets the current fēnix 8 AMOLED device profiles:

- `fenix843mm`
- `fenix847mm` (47 mm / 51 mm AMOLED family)

Solar, Pro, and unrelated Garmin families are intentionally deferred until there is a concrete compatibility/acceptance need.

The manifest minimum API is 6.0.0, matching current fēnix 8 support.

## Persistence decision

The Companion uses `Toybox.Application.Storage`, not app settings/properties.

Reasoning:

- the snapshot is runtime state, not user configuration;
- Storage supports dictionaries and nested persistable primitive values;
- it does not require an app-settings schema;
- a single snapshot is comfortably below Garmin's per-value storage limit.

The current storage key is:

`bookwave.playbackSnapshot.v1`

A rejected candidate never replaces the stored value. A malformed/incompatible stored value is treated as invalid and deletion is attempted. If deletion itself fails, validation still prevents the value from being presented as valid playback state.

A future privacy/profile-lock message can call the store's clear operation before any redacted replacement state is accepted.

## UI decision

Phase 1 draws a single simple view directly with `Graphics.Dc`.

This intentionally avoids spending the first slice on layout machinery. The view distinguishes:

- never synced;
- invalid persisted state;
- valid stored snapshot;
- playing vs paused stored snapshot;
- waiting-for-phone/disconnected truth.

Because phone transport does not exist in Phase 1, the Companion never claims that a phone is connected.

## Lifecycle

`BookWaveCompanionApp.onStart()` restores persisted state before the initial view is requested.

There is no background service, network polling, BLE loop, or timer in Phase 1. This keeps battery/network behavior effectively inert until Phase 2 introduces an explicit transport contract.
