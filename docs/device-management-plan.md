# Owner-selected BookWave Audio Provider and device management

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

**2026-10-08 setup recovery:** Owner-reported pairing/URL failures now have a focused fix: explicit watch Accept/Cancel, code resend/cancel/expiry and phone-driven Sidecar setup. Garmin controls/dialogs and Android sleep schedule reuse glass; sleep enable directly expands time controls. [Regression and physical acceptance register](testing/setup-recovery.md). Hardware retest pending; the reported freeze remains unattributed.

**Classification:** Accepted product/architecture plan; runtime implemented; physical acceptance pending. **Updated:** 2026-10-08.
Track [Garmin #7](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/7) and Android [#119](https://github.com/AlexanderWilhelmsenBerg/Audiobookshelf-Manager-Claude/issues/119).

The owner accepted a separate BookWave **Audio Content Provider** using existing WatchShelf Sidecar.
Keep Companion as a normal Device App; each app has a distinct manifest, application ID and artifact.
This owner decision supersedes the earlier evaluation-only/optional-provider deferral for the requested
controls. It does not authorize replacing Sidecar, a watch face, a Data Field or broader hardware support.

## Reason and external boundary

Inspected [WatchShelf](https://github.com/JediBrooker/WatchShelf) at
`93ac7507dae1cae1221509cefd97441dab36e955`. Unmodified WatchShelf has no BookWave phone-message receiver;
Sidecar exposes authentication/catalogue/files/transcoding/cover/progress, not watch inventory,
remote queue or actual listening-session routes. Sidecar login sessions are authentication state,
not audiobook listening sessions. The normal Companion cannot own native Media downloads by adding
a URL. Garmin's [Media API](https://developer.garmin.com/connect-iq/api-docs/Toybox/Media.html) requires
an Audio Content Provider context. A separate provider is justified by the owner's requested controls.

Reviewed WatchShelf engine source was adapted under MIT, with original notices, exact upstream pin and
file provenance retained in `apps/audio-provider/third-party/`. Do not copy destructive cache/storage reset on upgrade, private logging or normal ABS key
fallback into a BookWave provider. Document provider-scoped Sidecar authentication and explicit account
pairing before queueing; normal ABS credentials never travel in the Companion protocol.

Android's New download selects only completed, current-profile-authorized phone books and rechecks
eligibility when queued. It identifies the matching server item. Sidecar fetches/transcodes that item's
audio from ABS; the phone's local media bytes are not the transfer source. Server/source/authorization/
Sidecar failure must be reported honestly. The provider owns native watch Wi-Fi/cache admission, actual
download/resume/inventory state and phone-free playback; sending a BLE request is not completion.

## Vertical slices and owners

1. **Contract/account boundary:** provider-specific capabilities and bounded correlated requests/reports,
   explicit account binding, durable request IDs, profile/session/generation checks and fixtures. Preserve
   the released Companion protocol; Android keeps one Mobile SDK lifecycle owner.
2. **Download/inventory:** provider queue/cache/native Wi-Fi; Android Room-backed timestamps, request and
   inventory projections; Settings → Playback → Devices inline menu. Show Force sync, real connected green
   dot or last connected, last successful sync, Downloads dialog and New download dialog. Preserve phone
   output-device policy controls. Unknown inventory is not an empty watch; cached state is dated.
3. **Events/Force sync:** journal actual GARMIN book/chapter/pause/seek/checkpoint/completion events with
   captured identity/time/position; durable idempotent import and original times. PHONE display snapshots
   are not watch listens. Existing Android progress/session owners reconcile legitimate events, preserve
   rewinds and never autoplay. ACK only after persistence. Expose real watch session history in the device
   flow; Sidecar authentication sessions do not count.
4. **Future face publisher:** use the [accepted BookWave Complications feed](watchface-state-plan.md)
   from validated persisted Companion PHONE and provider GARMIN state. The face itself remains later.

## Verification register

Automated: used Sidecar endpoint and new wire fixtures; missing required vs unknown fields; capabilities/
correlation/identity; durable queue and import deduplication; partial/corrupt chunk recovery and restart;
Room migration; auth/privacy/lock/switch; no autoplay/max-position; actual UI/provider/repository callers;
formatter/strict Android verifyDebug and Garmin supported-target/test/package CI. Guarded fixes need
actual-source reversion proof. Record execution separately from test compilation.

Physical **GD-01–10 remaining matrix pending** (owner-reported pairing/URL failures and GS01–10 retests are tracked in [setup recovery](testing/setup-recovery.md)): connection/timestamps; compact menu/dialog appearance; authorized
picker/right-account queue; native Wi-Fi admission/resume/integrity; phone-free playback/chapters/
rewind/reboot; idempotent Force sync; outages/expired credentials; profile/account/second-watch
isolation; Android audio/timer continuity; provider retention/battery/Connect lifecycle. Exact cases
are canonical in the [Android device plan](https://github.com/AlexanderWilhelmsenBerg/Audiobookshelf-Manager-Claude/blob/main/docs/garmin-device-management.md).
Also log GF-01–07 for publication. Existing G-01/G-02 acceptance under #2/#3 remains required. Record
source/PRG/APK hashes, watch/firmware/Garmin Connect/Sidecar versions. Ask the owner for visual judgment
only when automation cannot establish it; no device access or physical acceptance occurred here.

Phone privacy changes cannot erase disconnected watch media. Document provider-local account retention
and face-cache clearing honestly. Android reliability retains priority; missing hardware gates remain
logged while independent development can progress.

## Current implementation and evidence

The provider, durable Android device controls/event import and both protected publishers are implemented.
See [provider-delivery.md](testing/provider-delivery.md) for exact build/test delivery. Runtime policy is recorded in the provider/feed contracts; the tests above remain physical acceptance obligations.

Claimed native sync IDs remain durable through stop/process loss until their own completed/failed
outcome, and do not consume a newer queued ID. Duplicating a download already covered by matching
normal-speed cached audio returns stored; mismatched duration or partial coverage cannot claim success.
Android retries after a fresh full inventory proves an accepted download absent.
