# Phase 2 transport acceptance inventory

**Classification:** Planned tests, not executed evidence. **Created:** 2026-10-07.
Source boundary: Phase 2 transport is implemented in the linked Android/Garmin integration PRs. Physical acceptance below remains pending; CI does not imply a watch PASS.
Track [#3](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/3); Phase 1 [#2](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/2) retains its own acceptance.

| Case | Required evidence | Status |
| --- | --- | --- |
| G-02-01 | Common envelope/snapshot fixtures: unknown fields, missing/wrong types, unsupported major, optional duration/chapter, bounds, >24h and epoch/integer precision. Run methods in both runtimes. | NOT RUN |
| G-02-02 | Correct Companion app ID; missing/outdated Garmin Connect Mobile, no device, disconnected watch, absent app, compatible/incompatible handshake. Availability never substitutes for accepted persisted state. | NOT RUN |
| G-02-03 | Real initial Android→watch title/chapter/progress, paused/playing and unknown-duration state; accepted ack correlates to successfully persisted snapshot. | NOT RUN |
| G-02-04 | Phone disconnect, watch app close/reopen, phone/watch process restart and reconnect; retain last valid stored state without claiming live connectivity or starting playback. | NOT RUN |
| G-02-05 | Unsupported/malformed/stale/reordered/duplicate snapshots and acks; wrong-type/correlation, delayed callbacks, bounded history and lost/failed async send/ack recovery. | NOT RUN |
| G-02-06 | Profile lock/switch/removal/reauthentication while connected and disconnected; old metadata cleared on watch/reconnect, no stale send or credential/host leakage. | NOT RUN |
| G-02-07 | Book change, chapter crossing, pause/resume, deliberate seek/rewind, no current book and duration changes; truth matches existing Android playback owner. | NOT RUN |
| G-02-08 | Application/service lifecycle, SDK shutdown/restart, listener registration/cleanup and reconnect ordering; Garmin failure does not disturb heard Android audio/progress. | NOT RUN |
| G-02-09 | Long/unicode titles and bounded payload/memory; actual target UI truth, errors and usability on the supported fēnix variant/firmware. | NOT RUN |
| G-02-10 | Measured BLE/send cadence and battery/background cost across active/paused/disconnected states and a bounded soak; no per-second BLE streaming. | NOT RUN |

Before each execution record both exact SHAs/build/signing identities, Android API/app/Garmin Connect
version, watch model/firmware, SDK, fixture and PASS/FAIL/NOT RUN evidence. Use synthetic/private local
fixtures without publishing owner catalogue or accounts. CI builds do not accept this physical matrix.
Automate functional checks where possible; request owner input only for visual/sensory judgment.

Commands, multi-source reconciliation/Force sync and offline Audio Provider are later-phase matrices.
Do not use projection `updatedAt` as a listening-event conflict timestamp without that design.
Phase 2 adds the foreground receiver and Communications permission. No physical PASS is inferred.

## Automated implementation evidence — 2026-10-07

PR5 run37627686906 passes guardrails, fenix843mm/fenix847mm compilations, Run No Evil method
compilation and package export after correcting callback types. Five new methods cover strict envelope
types, privacy-clear ordering, stale/duplicate/old-stream rejection, epoch precision/unknown fields and
durable-clear restore. These methods are compiled but execution is NOT RUN. All physical rows above
remain NOT RUN; no owner hardware was used during this delivery. Android's bridge delivery log owns
its executed JVM/Media3 regressions and forced gate. Later CI/source records supersede these head-specific
build results without promoting missing physical evidence to PASS.
