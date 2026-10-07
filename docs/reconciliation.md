# Cross-repository reconciliation

**Classification:** Current dependencies and delivery boundaries. **Updated:** 2026-10-07.

Garmin Phase 1 model/storage is merged in PR1; documentation reconciliation is merged in PR4.
[PR5](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/pull/5) adds Phase 2 foreground
transport, negotiated ordered-state messages, durable acks and redaction. The Android bridge incorporates
candidate6239a148 with ownership, privacy, retry and lifecycle corrections. The repos carry identical
[transport contracts](transport-contract.md); the underlying [snapshot model](phone-watch-protocol.md)
remains readable. This implementation status is separate from physical acceptance.

## Authority

Garmin owns Monkey C, manifests, watch storage, receiver and future Garmin surfaces. Android owns
Media3/playback, profile/lock authorization, ABS/session/progress, Mobile SDK adapter, commands,
reconciliation and Settings Force sync. The bridge observes the existing owner; it never creates a second
player or initiates playback. WatchShelf/Sidecar remain the initial offline engine; replacement is deferred.
[Integration policy](watchshelf-integration.md).

## Ordered dependencies

1. Execute Phase 1 simulator/storage cases and physical G-01 acceptance under
   [#2](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/2).
2. Accept implemented Phase 2 handshake, persisted ack, privacy, reconnect, lifecycle and BLE cost under
   [#3](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/3) and
   [G-02-01–10](testing/phase-2-transport.md). Build/test-compilation/export passes; simulator method
   execution and physical cases remain NOT RUN. Android forced strict verification/PR CI remains required.
3. Add allowlisted commands through Android's existing action contract, then legitimate-event
   reconciliation/Settings Force sync without automatic Play. No max(position) conflict rule.
4. Accept Companion Milestone2 before complications/watch face/Data Field implementation.
5. Evaluate physical coexistence before optional provider/helper replacement.

## Limits and current acceptance

Transport exists only while the Companion is foreground. A disconnected watch retains its last stored
snapshot until reconnect; privacy deletion cannot arrive offline. New sessions require a nonce-bound
durable clear before metadata. Failed storage is never acknowledged as accepted. Displayed playing state
is the phone snapshot, not proof of watch-local audio. Projection updatedAt is not a durable listening-event
timestamp for future reconciliation. Credentials/hosts are never transferred.

PR5 checks run37627686906 pass both fenix targets, test-enabled compilation and package export after a
callback typing correction. Six transport/storage Run No Evil methods are compiled, not executed.
Acceptance issues #2/#3 and Android#119 remain open. Garmin does not block Android release or outrank
Android reliability. The earlier candidate-only reconciliation is superseded by this implementation.
