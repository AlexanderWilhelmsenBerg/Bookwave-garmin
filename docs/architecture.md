# BookWave Garmin Architecture

**Current Phase 2 implementation (2026-10-07):** foreground phone transport, negotiated ordered
snapshot delivery, durable clear/snapshot acknowledgements and bounded reconnect handling are
implemented. See [the shared wire contract](transport-contract.md). Build/test-compilation and physical acceptance
are recorded separately in the Phase 2 inventory. Commands, reconciliation/Force sync,
provider/device controls and BookWave complication publishing are owner-selected planned work
([provider plan](device-management-plan.md), [future face feed](watchface-state-plan.md)).
Watch face and Data Field implementation remain deferred. Earlier Phase 1 descriptions below
describe the persisted model and its original acceptance, not the current transport scope.


## Repository boundary

This repository owns Garmin Connect IQ applications and Garmin-side shared playback-state logic.

The first production application is:

- **BookWave Companion** — a Connect IQ Device App responsible for displaying and persisting the latest valid BookWave playback snapshot.

Future applications belong in this repository but are deliberately not implemented in Phase 1:

- **BookWave Watch Face** — presentation-only surface for the current BookWave state.
- **BookWave Running Data Field** — activity surface combining BookWave state with Garmin activity metrics.
- **BookWave Audio Provider** — selected separate Audio Content Provider using existing WatchShelf Sidecar; implementation pending.

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
- Connect IQ Mobile SDK integration in Android;
- command execution;
- automatic reconciliation and Force Sync policy.

No Android BookWave code is implemented in this repository.

## WatchShelf responsibility

WatchShelf remains the Garmin offline-audiobook engine during the initial BookWave Garmin phases. It owns Garmin-native audiobook browsing/download/offline playback and progress upload through its Sidecar.

BookWave Companion remains a display/control app. The owner's selected separate Audio Provider will
own watch cache/queue/playback and actual GARMIN events, using existing Sidecar. Neither app receives
normal ABS credentials through the Companion protocol. [Current provider/account boundary](device-management-plan.md)
and [future face publication](watchface-state-plan.md) supersede the older optional-provider deferral.

## Current physical layout

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

The Companion reports recent accepted phone-state receipt or stored/waiting state. Foreground transport
is stopped on app close; receipt is not proof of continuous connectivity or watch-local playback.

## Lifecycle

`BookWaveCompanionApp.onStart()` restores persisted state before the initial view is requested.

There is no background service. Phase 2 has a foreground 30-second state-request timer and bounded
phone delivery retries; the timer stops with the app. Physical BLE/battery measurements remain pending.

## Phase 2 transport ownership and privacy

BookWaveCompanionApp starts/stops PhoneTransport and updates CompanionView from accepted state.
TransportCodec validates envelopes; TransportOrder enforces the current nonce, sequence and first clear.
SnapshotCodec validates the payload; SnapshotStore atomically persists valid state or a redaction
tombstone. Duplicate accepted messages resend the cached ack without writing twice. Clear failures
redact the current view and return accepted:false; no durable-success claim follows a storage exception.
The timer/receiver exists only in the foreground. See [the wire contract](transport-contract.md).
