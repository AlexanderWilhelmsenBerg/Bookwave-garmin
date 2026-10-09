# Cross-repository reconciliation

**Current hardware follow-up — 2026-10-09:** Owner confirms watch download admission/transfer and Android
inventory/phone initiation now work. A transfer was interrupted at 25%; Companion state and visual
acceptance failed. Channel-registration recovery, dual Force sync, scoped explicit resume and named
download progress, and revised Companion geometry are merged in native PR #22 after passing CI; the matching Android changes and physical
acceptance remain separate. [Current evidence and WR01–10 tests](testing/download-recovery.md)
supersede older blanket unknown-download/visual claims below. Build label: **TEST 2026-10-09a**.
The following dated 2026-10-08 summaries are historical; they do not describe current hardware outcomes.


**Earlier physical feedback — 2026-10-08:** setup, immediate download and readability failed; see
[current findings and WD retests](testing/watch-setup-diagnostics.md). Actual download cause/success
remains unverified.

**Classification:** Current dependencies and delivery boundaries. **Updated:** 2026-10-08.

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
player or initiates playback. The selected separate BookWave Audio Provider owns native watch
media/events using existing WatchShelf Sidecar. Provider/control/feed runtime is implemented, with physical acceptance pending; removing
Sidecar is not selected.
[Integration policy](watchshelf-integration.md).

## Ordered dependencies

1. Execute Phase 1 simulator/storage cases and physical G-01 acceptance under
   [#2](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/2).
2. Accept implemented Phase 2 handshake, persisted ack, privacy, reconnect, lifecycle and BLE cost under
   [#3](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/3) and
   [G-02-01–10](testing/phase-2-transport.md). Build/test-compilation/export passes; current simulator test execution is recorded in [the delivery log](testing/provider-delivery.md); physical cases remain NOT RUN. Android forced strict verification/PR CI remains required.
3. Accept the implemented owner-selected [provider/device management plan](device-management-plan.md) under
   [#7](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/7) with Android #119: account/wire boundary, download/inventory/settings vertical
   slice, real events and Force sync. Hardware tests GD-01–10 remain logged, not passed.
4. Accept the implemented validated PHONE/GARMIN [state for the future face](watchface-state-plan.md) under
   [#8](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/8). Physical Companion/control/reconciliation acceptance and publication acceptance
   still gate the watch face itself. Running Data Field and replacing Sidecar remain later.
5. Allowlisted phone playback commands reuse Android's existing action contract. They do not gate
   download/inventory implementation; validate them before accepting the future face's control milestone.
   No reconciliation autoplays or chooses max(position).

## Limits and current acceptance

Transport exists only while the Companion is foreground. A disconnected watch retains its last stored
snapshot until reconnect; privacy deletion cannot arrive offline. New sessions require a nonce-bound
durable clear before metadata. Failed storage is never acknowledged as accepted. Displayed playing state
is the phone snapshot, not proof of watch-local audio. Projection updatedAt is not a durable listening-event
timestamp for future reconciliation. Companion playback transport never transfers credentials/hosts. Separate, paired provider setup now accepts the owner-authorized one-time Sidecar URL/username/password; only the opaque session persists. See the [provider contract](provider-contract.md).

PR5 checks run37627686906 pass both fenix targets, test-enabled compilation and package export after a
callback typing correction. Those six transport/storage methods were compile-only at PR5; current execution is recorded in the provider delivery log.
Acceptance issues #2/#3, selected provider #7, future face feed #8 and Android#119 remain open. Garmin does not block Android release or outrank
Android reliability. The earlier candidate-only reconciliation is superseded by this implementation.

## Provider delivery evidence — 2026-10-08

[PR10](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/pull/10) is merged as `19cc9a67`; all nine PR checks and main CI37699273330 pass. Provider download artifacts now also retain the adapted engine's MIT license and provenance alongside the PRG/IQ and build identity. The matching [Android PR243](https://github.com/AlexanderWilhelmsenBerg/Audiobookshelf-Manager-Claude/pull/243) has full strict local verification passing: 1024 tasks, all37 Garmin and38 migration tests pass with actual-source generation reversion proof. GitHub records subsequent PR/main CI and delivery status.

Final native RNE reruns stalled in the local launcher; the earlier49 passing tests do not establish final-source acceptance. The additional failed-read safety test is compiled, not executed. All hardware gates remain NOT RUN. Use [the installation guide](install-for-testing.md) and recorded binary/signing identity before testing.
