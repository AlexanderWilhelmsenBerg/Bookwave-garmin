# BookWave Garmin — Delivery Plan

**Current hardware follow-up — 2026-10-09:** Owner confirms watch download admission/transfer and Android
inventory/phone initiation now work. A transfer was interrupted at 25%; Companion state and visual
acceptance failed. Channel-registration recovery, dual Force sync, scoped explicit resume and named
download progress, and revised Companion geometry are implemented on the recovery branches; final
checks/delivery and physical acceptance remain separate. [Current evidence and WR01–10 tests](docs/testing/download-recovery.md)
supersede older blanket unknown-download/visual claims below. Build label: **TEST 2026-10-09a**.
The following dated 2026-10-08 summaries are historical; they do not describe current hardware outcomes.


**Current setup — 2026-10-08:** Android setup now needs only the Sidecar address. It derives the
username from the active BookWave profile and asks the watch to reuse its existing opaque Sidecar
session (`reuse_login`). The watch requires a retained exact server/username account anchor, checks
health and authenticated libraries, and refuses a different account or destination. No Android
access token, refresh token or password is sent. Bare addresses get HTTPS; successful canonical
addresses are remembered per profile/device and hidden when locked. A fresh watch must sign in
through BookWave Audio first. First-time setup using the phone's ABS access token remains pending
explicit destination/token-sharing approval and optional Sidecar integration. Hardware acceptance
remains open. Watch build label: **TEST 2026-10-08d**.

**2026-10-08 duration/layout follow-up:** The owner now reports immediate `-20001`,
`files.duration`, and clipped Companion text. Garmin numeric admission and full measured pagination,
BookWave theme/button cues, Android HTTPS defaults and remembered successful Sidecar addresses are
implemented. Actual watch download/visual acceptance remains open. First-time phone bootstrap is
pending exact destination/credential-egress approval and Sidecar integration; no running Sidecar has
changed. [Current implementation and tests](docs/testing/watch-layout-and-duration.md).


**2026-10-08 physical feedback:** Phone setup, immediate Download admission and error readability failed
on the owner's watch; on-watch login/catalogue access worked. Diagnostics and button guidance are
implemented; actual download cause/success remains unverified. [Current findings and WD retests](docs/testing/watch-setup-diagnostics.md)
supersede blanket NOT RUN for exercised paths; keep hardware acceptance open.

**2026-10-08 setup recovery:** Owner-reported pairing/URL failures now have a focused fix: explicit watch Accept/Cancel, code resend/cancel/expiry and phone-driven Sidecar setup. Garmin controls/dialogs and Android sleep schedule reuse glass; sleep enable directly expands time controls. [Regression and physical acceptance register](docs/testing/setup-recovery.md). Hardware retest pending; the reported freeze remains unattributed.

**Provider/control/feed implementation — 2026-10-08:** BookWave Audio is a separate native
Audio Content Provider using existing WatchShelf Sidecar. Android now owns Room-backed device controls,
durable requests, reported inventory and imported original listening events. Companion PHONE and
provider GARMIN complication publishers are implemented. Watch face and Data Field remain deferred.
See the [provider contract](docs/provider-contract.md), [feed contract](docs/feed-contract.md),
[installation guide](docs/install-for-testing.md) and [delivery/test record](docs/testing/provider-delivery.md).
Physical GD/GF and prior Companion acceptance remain pending.



**Updated:** 2026-10-07 for Phase 2 PR #5 and the matching Android bridge integration.
[Cross-repository boundaries and dependencies](docs/reconciliation.md).

## 1. Goal

Build a Garmin extension for BookWave that gives the user:

1. a reliable phone-connected BookWave companion;
2. correct playback-state synchronization and reconciliation;
3. a BookWave Now Playing complication/state source;
4. a custom BookWave watch face;
5. a running Data Field combining audiobook state with Garmin activity data;
6. a separate BookWave Audio Provider using existing WatchShelf Sidecar for the owner-requested download/inventory/session controls.

The project starts with the **Companion**, not the watch face.

## 2. Product boundaries

### Bookwave-garmin

Owns all Garmin Connect IQ applications and shared Garmin-side protocol code.

### Main BookWave Android app

`AlexanderWilhelmsenBerg/Audiobookshelf-Manager-Claude`

Owns:

- Android playback and Media3;
- profile state;
- Audiobookshelf communication;
- Connect IQ Mobile SDK bridge;
- reconciliation policy;
- automatic synchronization;
- Force sync UI/action;
- Android command execution.

### WatchShelf

Initial offline Garmin audiobook engine.

WatchShelf remains responsible for:

- browsing/downloading books to Garmin;
- Garmin-native offline audio playback;
- transcoding/chunking through WatchShelf Sidecar;
- writing offline watch progress back to Audiobookshelf.

WatchShelf may continue during transition. The owner subsequently selected a separate BookWave Audio
Provider using existing Sidecar, justified by the absence of a supported remote queue/inventory/events
interface. The selected implementation is present; it does not replace/remove Sidecar. See
[the provider/device plan](docs/device-management-plan.md).

---

# 3. Target repository structure

```text
Bookwave-garmin/
├── AGENTS.md
├── README.md
├── plan.md
│
├── apps/
│   ├── companion/
│   │   ├── manifest.xml
│   │   ├── monkey.jungle
│   │   ├── source/
│   │   └── resources/
│   │
│   ├── watchface/
│   │   ├── manifest.xml
│   │   ├── monkey.jungle
│   │   ├── source/
│   │   └── resources/
│   │
│   └── run-data-field/
│       ├── manifest.xml
│       ├── monkey.jungle
│       ├── source/
│       └── resources/
│
├── shared/
│   ├── protocol/
│   ├── model/
│   └── test-fixtures/
│
├── docs/
│   ├── architecture.md
│   ├── phone-watch-protocol.md
│   ├── reconciliation.md
│   ├── watchshelf-integration.md
│   └── testing/
│
└── tools/
```

The applications share concepts and fixtures, but remain independently installable Connect IQ applications.

---

# 4. Core architecture

```text
                         AUDIOBOOKSHELF
                              ▲
                              │
                    progress / account truth
                              │
             ┌────────────────┴───────────────┐
             │                                │
      BookWave Android                 WatchShelf Sidecar
             │                                │
     Connect IQ Mobile SDK                    │
             │                                ▼
             ▼                        WatchShelf Garmin
    BookWave Companion                offline playback
             │
             ├──── BookWave Now Playing state
             │               │
             │               ├── Watch Face
             │               └── Running Data Field
             │
             └──── playback commands → BookWave Android
```

The diagram describes the initial coexistence path. The owner-selected next integration adds a
separate BookWave Audio Provider → existing Sidecar path and Android device control/report messages.
Companion PHONE and provider GARMIN state publish to a future face through Complications.
The separate provider and both publishers are implemented; hardware acceptance remains pending.

---

# 5. Shared protocol

## 5.1 PlaybackSnapshot

Initial conceptual contract:

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

`source`:

```text
PHONE
GARMIN
SERVER
```

The actual encoded shape should be documented in `docs/phone-watch-protocol.md`.

## 5.2 Commands

Initial Garmin → Android commands:

```text
CONTINUE
PLAY
PAUSE
TOGGLE_PLAYBACK
SKIP_FORWARD
SKIP_BACK
```

Potential later commands:

```text
START_SLEEP_TIMER
CANCEL_SLEEP_TIMER
OPEN_CURRENT_BOOK
OPEN_PLAYER
```

No command may bypass BookWave Android playback policy.

---

# 6. Reconciliation model

BookWave may receive evidence from:

```text
BookWave local state
Audiobookshelf progress
Garmin companion snapshot
WatchShelf -> Audiobookshelf progress
```

Correctness rule:

> Resolve by the newest legitimate listening/update event, not the greatest position.

Example:

```text
Phone
18:20
01:48:00

Garmin
19:05
01:21:00
```

Result:

```text
01:21:00
```

The Garmin rewind is newer and therefore authoritative.

Reconciliation must never start playback.

---

# 7. Delivery phases

## Current sequencing — owner decision 2026-10-07

Phase numbers below identify capabilities; the owner's selected next integration is [Garmin #7](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/7),
not an instruction to wait until the old optional Phase 9 deferral. Establish provider/account/wire fixtures;
then deliver the provider/Android download-inventory-device-menu vertical slice; then actual listening
events and Force sync; then validated [BookWave Complications state](docs/watchface-state-plan.md)
([#8](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/8)). Keep Phase 1/2 acceptance #2/#3 and GD/GF hardware cases open until actually run.
Commands reuse Android's existing executor; a missing phone does not silently pass hardware gates or
block independent implementation. The watch face itself remains behind physical Companion/control/
reconciliation and publication acceptance. Data Field remains later; Android reliability keeps priority.


## Phase 0 — Repository and toolchain foundation

### Scope

- Establish repository structure.
- Add Connect IQ build instructions.
- Pin/document required Connect IQ SDK/tooling.
- Create first fēnix 8 target configuration.
- Add basic local build command(s).
- Add CI only after local build flow is understood.
- Add architecture and protocol documentation skeletons.

### Acceptance

- A minimal Connect IQ application compiles for the target fēnix 8.
- Simulator launch path is documented.
- Physical sideload path is documented.
- Historical Phase 1 excluded integration; current Phase 2 and provider delivery are recorded above.

---

## Phase 1 — Companion shell and persisted state

### Implementation status — 2026-10-06

Merged in [PR #1](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/pull/1), main `d8de6fb8`:

- Companion Device App project and fēnix 8 AMOLED targets;
- shared PlaybackSnapshot model and major-version validation;
- last-known-good persistence using Application.Storage;
- never-synced, invalid-state and stored/disconnected UI;
- deterministic debug/test fixtures;
- Run No Evil unit-test coverage for core validation/format/persistence behavior;
- Phase 1 architecture, protocol and test/sideload documentation.

PR37522590573 and main37534424183 PASS: guardrails, both target compilations, test-enabled compilation and package export. **Run No Evil execution, simulator and physical acceptance remain NOT RUN**, tracked by [#2](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/2) and `docs/testing/phase-1-companion.md`. Test compilation is not test execution. Phone transport remains Phase 2.

### Scope

Create `apps/companion`.

Implement:

- companion application shell;
- basic navigation;
- local `PlaybackSnapshot` model;
- persistent last-known valid snapshot;
- disconnected/never-synced UI;
- protocol-version field;
- safe parse/validation behavior.

Initial UI should be intentionally simple:

```text
BOOKWAVE

Dungeon Crawler Carl
Chapter 31

45.34%
35:13:43 / 72:43:01

PLAYING • STORED SNAPSHOT
Waiting for phone
```

### Acceptance

- Companion installs on physical fēnix 8.
- Stored snapshot survives app close/reopen.
- Invalid/incompatible snapshot cannot corrupt persisted state.
- Disconnected state is explicit.

---

## Phase 2 — Phone ↔ Garmin transport

### Garmin repo scope

Implement Garmin-side message transport:

- receive snapshot;
- acknowledge accepted version/state;
- request latest state;
- send connection/capability information;
- survive disconnect/reconnect;
- deduplicate stale/replayed messages where necessary.

### Android dependency

**Implemented in [PR #5](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/pull/5):** foreground
Communications receiver, shared ordered-state contract, nonce handshake, sequence/duplicate validation,
durable snapshot/clear acknowledgements, redaction tombstone and truthful recent-state/stored UI.
Android incorporates candidate6239a148 with captured queue ownership, privacy/generation guards,
bounded paused-state retries and lifecycle callback rejection. Both repositories carry the
[same wire contract](docs/transport-contract.md). PR CI37630137658 passes guardrails, both supported
target builds, test-method compilation and package export. Run No Evil execution and physical
acceptance remain NOT RUN under [#3](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/3)
and [G-02-01–10](docs/testing/phase-2-transport.md). Phase 2 implementation does not accept Milestone 1
hardware gates or authorize commands/reconciliation/other surfaces.

This Android work belongs in the main BookWave repository.

### Acceptance

On physical fēnix 8:

1. start playback in BookWave;
2. watch receives book/chapter/progress;
3. disconnect phone;
4. watch retains last valid state;
5. reconnect;
6. watch reconciles to current BookWave state.

---

## Phase 3 — Playback commands

### Scope

Add Garmin command UI:

- Continue / Play;
- Pause;
- Skip back;
- Skip forward.

Garmin sends requests only.

Android executes commands through BookWave's stable playback-action layer.

### Acceptance

- Every command reaches the correct BookWave action.
- Repeated button taps are bounded/debounced where required.
- Commands while disconnected fail visibly and harmlessly.
- Commands never cross profile/privacy boundaries.

---

## Phase 4 — Automatic reconciliation and Force Sync support

### Garmin repo scope

Implement:

- return-latest-snapshot request;
- resolved-snapshot acceptance;
- source/update metadata preservation;
- stale-snapshot rejection;
- sync result/status presentation.

### Android BookWave scope

Implement automatic reconciliation and:

**Settings → Playback → Devices → expanded watch menu → Force sync**

Force sync should:

1. journal current phone position;
2. flush pending BookWave progress;
3. request actual provider listening events/inventory and latest validated display state when reachable;
4. fetch fresh Audiobookshelf progress;
5. compare legitimate update/listen times; a PHONE display snapshot's observedAt is not a listening event;
6. resolve the authoritative state;
7. update BookWave local state;
8. update Audiobookshelf if required;
9. return the resolved state to Garmin;
10. refresh BookWave Garmin presentation state.

It must not start playback.

### Acceptance

Test:

- phone newest;
- Garmin newest;
- server newest;
- deliberate rewind on Garmin;
- deliberate rewind on phone;
- Garmin offline;
- server offline;
- pending local progress;
- profile change during sync;
- duplicate/stale message;
- same timestamp/ambiguous evidence.

---

## Phase 5 — BookWave Now Playing complication/state publisher

### Scope

Companion PHONE and the selected Audio Provider GARMIN state publish through Garmin Complications,
following [the accepted future face feed plan](docs/watchface-state-plan.md). The consumer does not
read another app's private Storage or authenticate to ABS. Minimum logical projection:

```text
title
chapter
percentage
playing
source
observedAt
listeningEventAt (when known)
freshness
privacyState
```

Watch-face networking must not be required.

### Acceptance

- state updates after play/pause/seek/book change;
- stale private metadata is cleared;
- updates remain useful when the phone temporarily disconnects;
- update cadence is battery-conscious.

This phase is the gate before custom watch-face work.

---

## Phase 6 — BookWave Watch Face

### Location

`apps/watchface`

Same repository, separate Connect IQ app/application ID.

### Scope

Consume BookWave Now Playing state.

Initial concept:

```text
             20:37

       DUNGEON CRAWLER CARL
            Chapter 31

       ████████░░░ 45.3%

          ♥ 68       BAT 82%

             TUE 6
```

The face should support graceful states for:

- playing;
- paused;
- no current book;
- stale/disconnected;
- locked/redacted profile.

### Explicit non-goal

The watch face must not become the phone/network synchronization owner.

### Acceptance

- renders from companion-published state;
- no direct ABS integration;
- no continuous networking;
- acceptable battery behavior on physical hardware;
- readable in normal and always-on behavior where supported.

---

## Phase 7 — Running Data Field

### Location

`apps/run-data-field`

### Scope

Combine Garmin activity metrics with the shared BookWave playback projection.

Initial information:

- time of day;
- heart rate;
- heart-rate zone;
- pace;
- current book;
- chapter;
- progress percentage or elapsed/total.

Concept:

```text
10:51                     ♥153
                           Z3

DUNGEON CRAWLER CARL
Chapter 31

█████████░░░░ 45.34%

PACE
5:12/km
```

### Acceptance

- readable while moving;
- BookWave state remains useful when phone connectivity changes;
- Garmin activity data remains primary and reliable;
- no small/high-risk touch targets during activity.

---

## Phase 8 — WatchShelf coexistence evaluation

After real daily usage, record what WatchShelf does well and what remains missing.

Questions:

- Is having separate BookWave and WatchShelf Garmin surfaces annoying?
- Does WatchShelf progress reconciliation behave reliably?
- Is download UX acceptable?
- Are chapter/progress semantics sufficient?
- Can BookWave controls/state coexist cleanly with WatchShelf offline playback?
- Is deeper integration worth the maintenance cost?

This was the original evaluation gate. The 2026-10-07 owner decision selects a separate provider using
existing Sidecar for the requested remote controls; it supersedes that deferral for this scope. Continue
logging physical tradeoffs; removing/replacing Sidecar still requires a separate decision.

---

## Phase 9 — Selected BookWave Audio Provider using existing Sidecar

**Owner decision accepted 2026-10-07; implementation present 2026-10-08, physical acceptance pending.** [Garmin #7](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/7) and
[the device/account/wire/test plan](docs/device-management-plan.md) are the current scope. Build a separate
Audio Content Provider with a distinct app ID, native Wi-Fi/cache/queue/playback ownership and actual
listening-event journal. Android adds Room-backed inline device management, the completed authorized
phone-book picker, truthful watch downloads/timestamps and idempotent Force sync. Sidecar retrieves/
transcodes the selected server item; this is not a local phone-file transfer. No normal ABS credentials
travel in the Companion protocol. Reviewed WatchShelf MIT engine reuse retains notices and source provenance in `apps/audio-provider/third-party/`. Do not import destructive upgrades or private logging.

Publish real GARMIN state alongside Companion PHONE state for the [future watch face](docs/watchface-state-plan.md).
The face itself, Data Field and replacing/removing Sidecar remain deferred. GD-01–10/GF-01–07 and
existing transport acceptance stay NOT RUN until evidence is logged.

---

# 8. Privacy requirements

At minimum:

- no stored ABS password on Garmin; Companion never receives it. The separate provider accepts only explicitly submitted one-time Sidecar-login credentials under the [provider setup contract](docs/provider-contract.md);
- no long-lived normal ABS access token in BookWave Garmin state;
- locked profiles redact metadata;
- profile changes clear stale metadata;
- persisted state is minimal;
- error/log output must not include credentials or sensitive tokens.

---

# 9. Battery and transport requirements

- No per-second BLE progress messages.
- Send snapshots on meaningful state changes.
- Reconcile periodically rather than continuously.
- Watch may interpolate visual playback position locally while playing.
- Authoritative state must periodically replace interpolation.
- Watch face performs presentation, not network ownership.
- Background behavior must be measured on physical hardware.

---

# 10. Testing strategy

## Automated

Prioritize deterministic tests for:

- message/version parsing;
- timestamp ordering;
- stale-message rejection;
- progress interpolation;
- privacy redaction;
- disconnect/reconnect state;
- reconciliation fixtures.

## Simulator

Use for:

- layout;
- navigation;
- state rendering;
- protocol fixtures;
- common error states.

## Physical fēnix 8

Required for:

- BLE/mobile bridge;
- reconnect behavior;
- complication delivery;
- background behavior;
- command latency;
- battery impact;
- watch-face readability;
- activity Data Field usability.

Physical-device findings belong in `docs/testing/`.

---

# 11. Initial milestone

## Milestone 1 — Companion handshake

Definition:

> BookWave Android and a physical fēnix 8 can exchange a versioned PlaybackSnapshot, retain it through disconnect/reconnect, and display truthful current state.

Must include:

- companion builds/installs;
- protocol documented;
- one-way Android → Garmin state transfer;
- persisted watch snapshot;
- connection state;
- stale/incompatible message behavior;
- physical acceptance notes.

Does not require:

- watch face;
- Data Field;
- WatchShelf replacement;
- full Force Sync;
- production polish.

---

# 12. Milestone 2 — Companion control and reconciliation

Definition:

> Garmin can control BookWave playback through the Android action contract and participate in correct progress reconciliation, including manual Force Sync from BookWave Settings.

Must include:

- Play/Pause/Continue/Skip controls;
- reconnect reconciliation;
- newest-event-wins semantics;
- deliberate rewind correctness;
- Force Sync support;
- privacy/profile handling;
- physical acceptance.

This milestone's physical acceptance, together with publication acceptance, gates the watch face.
The owner-selected publisher contract/implementation can be developed with provider/device work
while missing hardware acceptance stays explicitly logged.

---

# 13. Current status

As of the 2026-10-07 reconciliation:

- [x] Repository, agreement, build instructions, two AMOLED targets and CI foundation.
- [x] Companion shell and validated last-known snapshot persistence merged in PR #1.
- [x] Target compilation, test-enabled compilation and package export PASS in PR/main CI.
- [ ] Run No Evil execution and simulator acceptance ([#2](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/2)).
- [ ] Physical Phase 1 fēnix8 acceptance ([#2](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/2)).
- [x] Shared wire protocol/foreground transport implemented with Android counterpart (PR #5).
- [ ] Executed simulator and physical interoperability acceptance ([#3](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/3)).
- [x] Android bridge review/merge (Android PR #240); physical handshake remains in #3.
- [ ] Playback commands through Android's action contract.
- [ ] Reconciliation / Android Settings Force sync.
- [x] Owner selected separate BookWave Audio Provider using existing Sidecar ([#7](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/7)).
- [ ] Provider/device controls, real events and Force sync implementation; GD-01–10 hardware acceptance.
- [x] Owner selected BookWave Complications feed for a future watch face ([#8](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/8)).
- [ ] PHONE/GARMIN publisher implementation and GF-01–07 acceptance, then gated watch face, then Data Field.
- [ ] Physical WatchShelf/provider tradeoff evidence; Sidecar replacement remains outside selected scope.

No phase is accepted by compilation alone. Android reliability remains its own primary roadmap lane;
this reconciliation does not begin new runtime implementation or a physical test campaign.

## Provider delivery evidence — 2026-10-08

[PR10](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/pull/10) is merged as `19cc9a67`; all nine PR checks and main CI37699273330 pass. Provider download artifacts now also retain the adapted engine's MIT license and provenance alongside the PRG/IQ and build identity. The matching [Android PR243](https://github.com/AlexanderWilhelmsenBerg/Audiobookshelf-Manager-Claude/pull/243) has full strict local verification passing: 1024 tasks, all37 Garmin and38 migration tests pass with actual-source generation reversion proof. GitHub records subsequent PR/main CI and delivery status.

Final native RNE reruns stalled in the local launcher; the earlier49 passing tests do not establish final-source acceptance. The additional failed-read safety test is compiled, not executed. All hardware gates remain NOT RUN. Use [the installation guide](docs/install-for-testing.md) and recorded binary/signing identity before testing.
