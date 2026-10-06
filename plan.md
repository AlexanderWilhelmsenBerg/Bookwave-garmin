# BookWave Garmin — Initial Plan

## 1. Goal

Build a Garmin extension for BookWave that gives the user:

1. a reliable phone-connected BookWave companion;
2. correct playback-state synchronization and reconciliation;
3. a BookWave Now Playing complication/state source;
4. a custom BookWave watch face;
5. a running Data Field combining audiobook state with Garmin activity data;
6. optional future native/offline BookWave audio-provider work only if WatchShelf proves insufficient.

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

BookWave-Garmin will initially coexist with it rather than replace it.

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

Initial BookWave-Garmin does **not** replace WatchShelf offline playback.

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
- No WatchShelf or Android integration yet.

---

## Phase 1 — Companion shell and persisted state

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

Phone connected
Synced 12 sec ago
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

Main BookWave must add the Connect IQ Mobile SDK bridge and translate BookWave playback state into the shared wire contract.

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

**Settings → Playback → Garmin / Playback synchronization → Force sync**

Force sync should:

1. journal current phone position;
2. flush pending BookWave progress;
3. request Garmin's latest stored snapshot when reachable;
4. fetch fresh Audiobookshelf progress;
5. compare legitimate update/listen times;
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

Companion publishes a small BookWave Now Playing projection:

```text
title
chapter
percentage
playing
source
updatedAt
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

Do not start an Audio Provider rewrite before this evaluation.

---

## Phase 9 — Optional BookWave Audio Provider

Only enter this phase if the WatchShelf coexistence evaluation demonstrates clear value.

Possible approaches:

1. continue using WatchShelf unchanged;
2. contribute improvements upstream;
3. build a WatchShelf-sidecar-compatible BookWave Audio Provider;
4. fork WatchShelf with retained MIT notices;
5. eventually build a BookWave-native offline stack.

This is intentionally deferred.

---

# 8. Privacy requirements

At minimum:

- no ABS password on Garmin;
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

This milestone gates the BookWave Now Playing complication and watch face.

---

# 13. Current status

As of initial repository planning:

- [x] Repository created.
- [x] Initial `AGENTS.md` drafted.
- [x] Initial `plan.md` drafted.
- [ ] Repository/toolchain foundation.
- [ ] Companion application shell.
- [ ] Shared wire protocol.
- [ ] Android Connect IQ bridge.
- [ ] Physical fēnix 8 handshake.
- [ ] Playback commands.
- [ ] Reconciliation / Force Sync.
- [ ] BookWave Now Playing complication/state publisher.
- [ ] Watch face.
- [ ] Running Data Field.
- [ ] WatchShelf coexistence evaluation.
- [ ] Optional Audio Provider decision.
