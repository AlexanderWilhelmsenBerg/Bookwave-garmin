# AGENTS.md

## Purpose

This repository owns the Garmin side of BookWave.

The product is expected to grow into a small family of Connect IQ applications that share one BookWave playback contract:

- **BookWave Companion** — phone-connected controls, state, reconciliation participation, and complication publishing.
- **BookWave Watch Face** — a low-power presentation surface for current audiobook state.
- **BookWave Running Data Field** — audiobook state alongside Garmin activity metrics.
- **BookWave Audio Provider** — owner-selected separate Audio Content Provider using existing WatchShelf Sidecar; implementation and outstanding acceptance are recorded in `docs/device-management-plan.md`.

The initial implementation priority is the **Companion**. Do not start with the watch face.

## Repository authority and boundaries

### This repository owns

- Connect IQ / Monkey C source.
- Garmin manifests, resources, build configuration, simulator support, and device compatibility.
- Garmin-side protocol models and compatibility handling.
- Garmin-side command UI and transport handling.
- Garmin-side persistent playback snapshot state.
- BookWave complication publishing.
- Watch face and Data Field implementations once their dependencies are stable.
- Garmin physical acceptance notes and compatibility evidence.

### Main BookWave Android repository owns

Repository:

`AlexanderWilhelmsenBerg/Audiobookshelf-Manager-Claude`

It remains authoritative for:

- Android playback.
- Media3 integration.
- BookWave profile identity and profile locking.
- playback/session persistence;
- Audiobookshelf API access.
- Android-side Garmin Connect IQ Mobile SDK integration.
- command dispatch into BookWave playback actions.
- progress reconciliation.
- automatic sync policy.
- the user-facing **Force sync** action in BookWave Settings.
- Android Auto and other Android playback surfaces.

Do not duplicate those responsibilities in this repository.

### WatchShelf

WatchShelf is an external integration and reference implementation.

For the initial BookWave-Garmin phases:

- Keep using existing WatchShelf Sidecar for the separate BookWave Audio Provider; unmodified WatchShelf may coexist.
- The 2026-10-07 owner decision selects a separate BookWave Audio Provider using existing Sidecar for remote download/inventory/listening control. It supersedes the prior optional-provider/evaluation-only deferral for this scope; see `docs/device-management-plan.md`. Removing/replacing Sidecar remains deferred.
- Do not copy WatchShelf internals merely because they exist.
- Protocol-compatible integration may be added later if justified.
- Any reused WatchShelf code must comply with its MIT license and retain required notices.

### Audiobookshelf

Audiobookshelf remains server-side progress/account truth.

Garmin must not receive or persist the user's normal Audiobookshelf credentials through the BookWave companion protocol.

## Product architecture

The intended repository shape is:

```text
Bookwave-garmin/
├── apps/
│   ├── companion/
│   ├── watchface/
│   ├── run-data-field/
│   └── audio-provider/
├── shared/
│   ├── protocol/
│   ├── model/
│   └── test-fixtures/
├── docs/
└── tools/
```

The watch face, Data Field and selected Audio Provider belong in this repository but are **separate Connect IQ applications with separate application IDs and build artifacts**. Their listed directories are a target structure, not a claim of implementation. The Companion and provider expose a versioned BookWave Complications feed for a future watch face; see `docs/watchface-state-plan.md`. The face itself stays behind the physical acceptance gates below.

Do not create a separate repository for the watch face unless an actual distribution/tooling constraint later requires it.

## Companion-first rule

The watch face is a renderer, not the integration authority.

Before watch-face implementation begins, the Companion must prove on physical hardware that it can:

1. receive a BookWave playback snapshot;
2. persist and restore it;
3. survive phone disconnect/reconnect;
4. send allowlisted playback commands;
5. reject stale/incompatible protocol messages safely;
6. participate in reconciliation without starting playback;
7. publish the BookWave Now Playing complication/state.

Only after those are accepted should the watch face be implemented.

## Shared playback contract

Use a small, versioned contract rather than serializing Android/Audiobookshelf domain objects.

Initial conceptual model:

```text
PlaybackSnapshot
  protocolVersion
  profileId
  bookId
  title
  author
  chapterTitle
  positionMs
  durationMs
  updatedAt
  playing
  source
```

Initial source values:

```text
PHONE
GARMIN
SERVER
```

The exact wire representation may evolve, but these rules are mandatory:

- Version every message contract.
- Unknown fields must be harmless.
- Unsupported major protocol versions must fail safely and visibly.
- Never infer authority from the greatest playback position.
- Never transmit full Audiobookshelf objects when a small projection is sufficient.
- Keep watch payloads compact.
- Persist the most recent valid snapshot on the watch so UI survives temporary disconnection.

## Command contract

Garmin commands must be tiny and allowlisted.

Initial command surface:

- Continue
- Play
- Pause
- Toggle playback
- Skip forward
- Skip back
- Open current book / player request where supported by Android integration

Future commands may include sleep-timer actions.

The Garmin app must not directly invent Android playback behavior. Commands are requests; Android BookWave remains the executor and policy owner.

## Progress and reconciliation policy

Correctness is more important than choosing the numerically largest position.

Core rule:

> The newest legitimate playback event wins. A deliberate rewind is valid state.

Never implement `max(position)` conflict resolution.

Garmin must preserve enough timestamp/source information for Android BookWave to reconcile:

- current local BookWave state;
- fresh Audiobookshelf progress;
- latest Garmin companion snapshot;
- WatchShelf progress after it has reached Audiobookshelf.

### Force sync

The **Force sync** UI lives in the Android BookWave Settings screen.

Garmin-side responsibilities are limited to:

- return the latest persisted valid snapshot when asked;
- accept the resolved snapshot after reconciliation;
- update local/complication state;
- report availability/connection truthfully.

A force sync must **never start playback automatically**.

## Privacy and profile rules

Garmin is an external display surface.

When the active BookWave profile is locked or metadata should not be exposed:

- redact title/author/chapter as required;
- retain only the minimum state necessary to show safe connection/playback status;
- do not leak metadata from a previously active unlocked profile;
- clear stale private metadata when profile/privacy state changes.

Do not persist secrets, Audiobookshelf passwords, or normal ABS access tokens in Garmin storage.

## Networking and battery rules

- Prefer phone-mediated messages for live BookWave state.
- Do not send position updates every second over BLE.
- Send snapshots on meaningful state transitions and periodic reconciliation.
- While playing, the watch may interpolate display progress locally from `position + elapsed time`, but must reconcile against authoritative snapshots.
- Watch faces must not become networking owners.
- Keep background work minimal and measurable.

## Agent workflow

Before proposing or changing code:

1. Refresh current GitHub `main`, open issues/PRs, and the exact relevant HEAD.
2. Read this file and `plan.md`.
3. Inspect current Connect IQ manifests/build files and relevant shared protocol docs.
4. Refresh upstream Garmin Connect IQ documentation for fast-moving APIs or device compatibility.
5. Inspect WatchShelf upstream only when the task depends on its behavior.

When implementing:

- Work in small, physically testable slices.
- Prefer protocol/model tests before UI polish.
- Keep companion, watch face, and Data Field concerns separated.
- Do not silently change cross-repo protocol assumptions.
- Document every wire-contract change.
- Preserve backwards compatibility within a released protocol major version.
- Do not merge pull requests unless explicitly requested.
- Do not start or rerun GitHub Actions unless explicitly requested or the current task specifically requires it.

## Verification hierarchy

Use all applicable layers:

1. static/build validation;
2. unit tests for protocol/model logic;
3. Connect IQ simulator;
4. package/build validation for supported devices;
5. **physical fēnix 8 acceptance**.

Simulator success does not override physical-device failure.

Record physical-device findings under `docs/testing/`.

## Initial supported hardware

Primary development/acceptance target:

- Garmin fēnix 8.

Broader device support can follow after the initial protocol and UI stabilize.

Do not broaden the compatibility matrix during early companion work unless necessary to keep the architecture portable.

## Definition of done for an implementation slice

A slice is complete only when:

- scope is documented;
- code/build validation passes;
- protocol behavior has focused tests where practical;
- disconnect/error behavior is handled;
- privacy implications are considered;
- physical acceptance steps are written when hardware behavior matters;
- relevant docs and `plan.md` status are updated;
- no unrelated Garmin surface was coupled into the change.
