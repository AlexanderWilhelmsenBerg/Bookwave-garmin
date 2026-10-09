# BookWave Garmin

**Current recovery delivery — 2026-10-09:** Owner confirms watch downloads, Android inventory and phone
initiation work; an interrupted 25% transfer and Companion state/appearance remain hardware retests.
[Native PR #22](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/pull/22) is merged after nine
passing checks; main CI also passes. The retained-signer bundle uses source `9a0f7eaa`, label
**TEST 2026-10-09a**, and both Companion/Audio Provider targets. The matching Android channel/Force
sync/resume changes are in development; use the paired delivery APK, not the earlier APK2206.
Full WR01–10 acceptance is recorded in [the recovery register](docs/testing/download-recovery.md).
Earlier 2026-10-08 summaries below are historical and superseded for download success and layout.


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


**Provider/control/feed implementation — 2026-10-08:** BookWave Audio is a separate native
Audio Content Provider using existing WatchShelf Sidecar. Android now owns Room-backed device controls,
durable requests, reported inventory and imported original listening events. Companion PHONE and
provider GARMIN complication publishers are implemented. Watch face and Data Field remain deferred.
See the [provider contract](docs/provider-contract.md), [feed contract](docs/feed-contract.md),
[installation guide](docs/install-for-testing.md) and [delivery/test record](docs/testing/provider-delivery.md).
Physical GD/GF and prior Companion acceptance remain pending.



Garmin Connect IQ applications for BookWave.

Phase 1 is Companion-first: a normal Connect IQ Device App that owns Garmin-side playback snapshot validation, persistence and truthful disconnected-state display. Phase 2 adds foreground phone transport; phone playback commands, watch face and Running Data Field remain later phases. The separate Audio Provider and publishers are implemented.

## Current target

- fēnix 8 43 mm AMOLED: `fenix843mm`
- fēnix 8 47/51 mm AMOLED: `fenix847mm`
- minimum Connect IQ API: 6.0.0
- recommended development SDK: Connect IQ 9.2.0

## Structure

```text
apps/companion/       Connect IQ Device App
apps/audio-provider/  native music provider, Sidecar downloads and event journal
shared/feed/          protected Complications projection
shared/model/         playback state, persistence, formatting
shared/protocol/      versioning and validation
shared/test-fixtures/ debug/test-only deterministic fixtures
docs/                 architecture, protocol and acceptance notes
```

See:

- `AGENTS.md` for repository boundaries and agent rules;
- `plan.md` for delivery phases;
- `docs/architecture.md` for app boundaries;
- `docs/phone-watch-protocol.md` for the Phase 1 playback contract;
- `docs/testing/phase-1-companion.md` for build, simulator, sideload and physical acceptance steps.

No Android BookWave changes are made in this repository.


## Delivery snapshot — 2026-10-07

Phase 1 is merged in [PR #1](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/pull/1). PR and main verification pass both supported target
builds, test-enabled compilation and export. Current Run No Evil execution is recorded in the provider delivery report. Final reruns remain pending after a launcher stall. Physical fēnix8
acceptance remains NOT RUN under [#2](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/2).
Phase 2 implements the foreground receiver, ordered snapshot/clear acknowledgements, and
Android bridge integration. Physical acceptance remains pending. [#3](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/3) tracks that integration. See
[cross-repository dependencies](docs/reconciliation.md) and [Phase 2 test inventory](docs/testing/phase-2-transport.md).
The owner selected a separate BookWave Audio Provider using existing WatchShelf Sidecar for device
downloads/inventory/sessions ([#7](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/7)), and a BookWave Complications feed for a future face
([#8](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/8)). Provider and feed source are implemented; hardware acceptance remains pending. Removing Sidecar is not selected.

## Downloadable development acceptance artifacts

Garmin Verification retains each target's PRG, the fenix847mm Run No Evil PRG and the exported IQ package
for 30 days. Each artifact includes BUILD-INFO with exact source, target, binary hashes and the generated
CI public-key fingerprint. Only out/ is uploaded; private developer keys are excluded. These are
development builds signed with fresh temporary CI keys, not an owner-signed Connect IQ Store release.
Sideload/run acceptance against the matching target and record its identity; preserve the app/storage
boundary when changing development signing identities. No simulator or physical PASS follows upload.

## Provider delivery evidence — 2026-10-08

**Latest physical feedback and fixes:** [PR16](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/pull/16)
and matching [Android PR247](https://github.com/AlexanderWilhelmsenBerg/Audiobookshelf-Manager-Claude/pull/247)
are merged after passed CI. Native production/test compiles and guardrails pass; Android strict
verification passes with all645 app debug tests and actual-source reversion evidence. Owner-reported
phone setup, immediate Download and clipped errors failed; on-watch catalogue access worked. Current
diagnostics separate Garmin -1002 from schema -20001, wrap/page errors and identify PHONE/Audio with
button help. Actual admission/transfer now works per owner; completion, resume and offline acceptance remain pending. Use the retained-key testing ZIP for
repeat USB upgrades; [WD01–08 and current findings](docs/testing/watch-setup-diagnostics.md) remain open.

The original provider-delivery evidence below is retained for provenance.

[PR10](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/pull/10) is merged as `19cc9a67`; all nine PR checks and main CI37699273330 pass. Provider download artifacts now also retain the adapted engine's MIT license and provenance alongside the PRG/IQ and build identity. The matching [Android PR243](https://github.com/AlexanderWilhelmsenBerg/Audiobookshelf-Manager-Claude/pull/243) has full strict local verification passing: 1024 tasks, all37 Garmin and38 migration tests pass with actual-source generation reversion proof. GitHub records subsequent PR/main CI and delivery status.

Final native RNE reruns stalled in the local launcher; the earlier49 passing tests do not establish final-source acceptance. The additional failed-read safety test and new diagnostics tests are compiled, not executed. Hardware acceptance remains open; the current report above supersedes blanket NOT RUN for exercised paths. Use [the installation guide](docs/install-for-testing.md) and recorded binary/signing identity before testing.
