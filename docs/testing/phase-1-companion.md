# Phase 1 Companion Testing

## Verification status

This document defines the reproducible Phase 1 verification path.

Repository implementation does not imply simulator or physical-device acceptance. Those layers must be recorded separately.

## Toolchain

Current upstream Garmin documentation lists Connect IQ SDK **9.2.0** as the latest SDK as of 2026-08-25.

Phase 1 requires:

- Connect IQ SDK 9.2.0 (recommended current SDK);
- Java/runtime required by that SDK;
- a Garmin developer signing key;
- VS Code + Monkey C extension, or the SDK command-line tools.

The app manifest has `minSdkVersion="6.0.0"`.

### Shell setup

Example:

```bash
export CIQ_HOME="/path/to/connectiq-sdk"
export CIQ_KEY="$HOME/.Garmin/ConnectIQ/developer_key"
```

## Build

Default fēnix 8 47/51 mm AMOLED target:

```bash
mkdir -p apps/companion/bin
"$CIQ_HOME/bin/monkeyc" \
  -d fenix847mm \
  -f apps/companion/monkey.jungle \
  -o apps/companion/bin/BookWaveCompanion.prg \
  -y "$CIQ_KEY"
```

43 mm AMOLED target:

```bash
"$CIQ_HOME/bin/monkeyc" \
  -d fenix843mm \
  -f apps/companion/monkey.jungle \
  -o apps/companion/bin/BookWaveCompanion-43mm.prg \
  -y "$CIQ_KEY"
```

## Unit tests (Run No Evil)

Build a test executable:

```bash
"$CIQ_HOME/bin/monkeyc" \
  --unit-test \
  -d fenix847mm \
  -f apps/companion/monkey.jungle \
  -o apps/companion/bin/BookWaveCompanionTests.prg \
  -y "$CIQ_KEY"
```

Start the simulator:

```bash
"$CIQ_HOME/bin/connectiq"
```

Then run tests:

```bash
"$CIQ_HOME/bin/monkeydo" \
  apps/companion/bin/BookWaveCompanionTests.prg \
  fenix847mm \
  /t
```

(Use `-t` instead of `/t` where required by the host platform's SDK wrapper.)

Covered logic includes:

- valid snapshot accepted;
- unsupported protocol rejected;
- rejected update preserves last valid snapshot;
- percentage calculation;
- >24-hour duration formatting;
- unknown duration;
- missing optional chapter;
- PHONE/GARMIN/SERVER source values;
- storage round trip;
- malformed stored state fails safely.

## Simulator launch

Build the normal debug PRG, start the simulator, then:

```bash
"$CIQ_HOME/bin/monkeydo" \
  apps/companion/bin/BookWaveCompanion.prg \
  fenix847mm
```

Expected first-launch state:

```text
BOOKWAVE
No current book
Never synced
Waiting for BookWave
```

## Fixture usage

Fixtures live in `shared/test-fixtures/PlaybackFixtures.mc` and are marked `:debug`.

Production release builds exclude them.

Available deterministic fixtures:

1. never synced;
2. playing audiobook;
3. paused audiobook;
4. very long title;
5. missing chapter;
6. >24-hour audiobook;
7. near-finished book;
8. invalid snapshot;
9. unsupported protocol version.

For persistence/UI inspection, run the single Run No Evil test `PlaybackSnapshotTests.seedPlayingFixture` against the same simulator product, then launch the normal debug application. The fixture is written through the real `SnapshotStore`, so reopening the app exercises the same restore path as a later phone-delivered snapshot.

Other fixtures are intended for focused validator/format tests until a richer developer fixture selector is justified. Do not add a production demo-data switch.

## Expected valid stored-state UI

The exact typography may vary with the target, but the truth must remain equivalent to:

```text
BOOKWAVE

Dungeon Crawler Carl
Matt Dinniman
Chapter 31

48.45%
35:13:50 / 72:43:01

PLAYING • STORED SNAPSHOT
Waiting for phone
Last state ...
```

For a paused fixture, the state label must say PAUSED.

For unknown duration, percentage and duration must not fabricate a total.

## Invalid persisted state

A malformed stored dictionary must:

- not crash the app;
- fail validation;
- not be displayed as playback state;
- attempt to delete the invalid stored value;
- show an invalid/empty truth state.

A rejected update must leave the previous valid stored snapshot unchanged.

## Physical fēnix 8 sideload

Garmin's documented sideload path:

1. connect the fēnix 8 over USB;
2. in VS Code run **Monkey C: Build for Device**;
3. select the matching fēnix 8 product;
4. choose an output directory;
5. copy the generated PRG to the watch's `GARMIN/APPS` directory;
6. safely eject/disconnect the watch;
7. launch BookWave from the app list.

Do not mark physical acceptance from simulator evidence.

## Physical acceptance checklist

All items remain **UNVERIFIED** until tested on the actual fēnix 8.

- [ ] UNVERIFIED — install/sideload succeeds.
- [ ] UNVERIFIED — application launches.
- [ ] UNVERIFIED — never-synced screen is correct.
- [ ] UNVERIFIED — fixture snapshot renders.
- [ ] UNVERIFIED — long book/title renders acceptably.
- [ ] UNVERIFIED — >24-hour duration renders correctly.
- [ ] UNVERIFIED — app close/reopen restores the last valid snapshot.
- [ ] UNVERIFIED — reboot/restart persistence behavior is understood.
- [ ] UNVERIFIED — malformed persisted state cannot brick/crash the app.
- [ ] UNVERIFIED — UI remains responsive.
- [ ] UNVERIFIED — no unexpected battery/network activity occurs.

Record physical findings here with watch model, firmware, SDK version, build SHA and result.


## GitHub CI

The repository runs **Garmin Verification** for pull requests to `main`, pushes to `main`, and explicit manual dispatches.

CI uses the Connect IQ 9.2.0 build/release tool images and a temporary CI-only 4096-bit RSA signing key generated inside each job. The temporary key is not the production/store signing identity and is discarded with the runner.

Required CI checks:

- **Repository guardrails** — verifies the Phase 1 app boundary, no Garmin permissions, no Android source, no watch-face/Data Field production directories, and no obvious credential fields in Garmin source.
- **Compile Companion (fenix843mm)** — normal PRG compilation for the 43 mm fēnix 8 AMOLED target.
- **Compile Companion (fenix847mm)** — normal PRG compilation for the 47/51 mm fēnix 8 AMOLED target.
- **Compile Run No Evil tests** — compiles the test-enabled application for `fenix847mm` with Garmin's `--unit-test` flag.
- **Export Companion package** — performs an export build across the manifest's supported products.

The build action is pinned to the exact commit behind its Connect IQ 9.2.0 release. CI therefore does not float to a newer Garmin SDK/action implicitly.

### What CI does not prove

Garmin Run No Evil **execution** still requires the Connect IQ simulator. The maintained 9.2.0 headless build image deliberately does not include a working simulator, so CI currently verifies that the complete test suite compiles but does not claim the test methods executed.

Simulator execution and the physical fēnix 8 acceptance checklist remain separate gates. A green GitHub workflow must never be recorded as physical-device PASS.
