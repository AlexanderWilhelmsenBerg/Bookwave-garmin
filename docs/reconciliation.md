# Cross-repository reconciliation

**Current Phase 2 implementation (2026-10-07):** foreground phone transport, negotiated ordered
snapshot delivery, durable clear/snapshot acknowledgements and bounded reconnect handling are
implemented. See [the shared wire contract](transport-contract.md). Build/test-compilation and physical acceptance
are recorded separately in the Phase 2 inventory. Commands, reconciliation/Force sync,
complications and other Garmin surfaces remain deferred. Earlier Phase 1 descriptions below
describe the persisted model and its original acceptance, not the current transport scope.


**Classification:** Current dependency/status map; internal Garmin sequencing stays in `../plan.md`.
**Snapshot:** 2026-10-07. No runtime work or physical tests are started by this reconciliation.

| Repository | Verified source/state | Authority |
| --- | --- | --- |
| Garmin | main `d8de6fb8`, PR #1 merged; PR/main build/export/test-compilation green | `AGENTS.md`, `plan.md`, protocol/architecture docs and source-specific test logs |
| Android | main `36c25043`, #238 merged; current main CI/security/APK green | [Android roadmap](https://github.com/AlexanderWilhelmsenBerg/Audiobookshelf-Manager-Claude/blob/main/docs/roadmap.md), product decisions/spec and current architecture |
| Android bridge | `mcp/garmin-phase-2-mobile-bridge`, `6239a148` | Candidate code, absent from Android main. No open PR or Actions result returned for this head; owner confirmed it is the intended work. |

Garmin owns Monkey C, manifests, state persistence, wire counterpart and future Garmin surfaces.
Android owns playback/Media3, profile/privacy, ABS communication, Mobile SDK adapter, commands,
reconciliation and Settings Force sync. WatchShelf/Sidecar coexistence remains the initial offline
playback path. [Integration policy](watchshelf-integration.md). This is not helper/provider replacement.

## Ordered dependencies

1. Finish Phase 1 simulator/test execution and physical persisted-state acceptance: [#2](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/2),
   [G-01-01–11](testing/phase-1-companion.md). Compilation/export pass; these runtime cases do not.
2. Jointly finalize/review transport fixtures and Android candidate; add Garmin counterpart separately:
   [#3](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/3), [G-02-01–10](testing/phase-2-transport.md). Android requires forced strict
   verification after its SDK/classpath change. Review existing code instead of duplicating the bridge.
3. Accept physical handshake/disconnect/reconnect/privacy behavior before declaring Milestone 1 complete.
4. Add commands through Android's action contract and legitimate-event reconciliation/Force sync without
   automatic playback; accept Milestone 2 before complication/watch face/Data Field delivery.
5. Evaluate coexistence from physical use before deciding on optional Audio Provider/helper replacement.

The earlier Android PD-007 blanket deferral is historical; its current supplement acknowledges these
repositories. This does not promote Garmin above Android reliability or require Garmin for Android release.

## Protocol boundary and review gaps

Garmin's main contract remains a validated **persisted snapshot dictionary**, not a transport envelope.
Android proposes major1 with `v/t/id/r/ts/p`, hello/hello_ack, snapshot/snapshot_ack, state_request,
clear_state/clear_ack and error. Companion ID and field bounds agree, but Garmin main has no receiver,
transport permissions, negotiation or ack handling. The proposed shape is not a released wire contract.
See [phone-watch contract](phone-watch-protocol.md) and Android's [candidate plan](https://github.com/AlexanderWilhelmsenBerg/Audiobookshelf-Manager-Claude/blob/main/docs/garmin-integration.md).

Review integer/epoch precision, payload bounds, unknown/malformed fields, stale/replayed messages,
async send failure/ack loss, listener stop/restart/reconnect, no-current-book clearing and disconnected
privacy/profile changes. Candidate Android `updatedAt` is projection time, not yet a legitimate durable
listening-event timestamp for future conflict resolution. Never infer the winner from maximum position;
reconciliation must preserve rewinds and must not start playback. Never transfer ABS credentials/hosts.

## Documentation and issue disposition

All repository Markdown was inventoried during this reconciliation. `AGENTS.md` remains the current
agreement; README/plan/status/testing are corrected to merged/build-verified state. Architecture and
Phase 1 protocol remain accurate: transport is absent. The target structure in plan is prospective;
watchface/run-data-field directories and artifacts do not exist. Missing planned reconciliation and
WatchShelf policy documents now exist with boundaries, not invented implementations.
PR #1 is merged; issues #2/#3 track unfinished acceptance/integration. No acceptance issue is closed.
Simulator and physical results remain NOT RUN; no CI compile result is relabelled as test execution.
