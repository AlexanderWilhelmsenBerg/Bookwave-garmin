# Companion connection and interrupted downloads — 2026-10-09

Requirements: SET-002, DL-001/003, SYNC-001/002; existing playback/account owners and privacy guards.

## Hardware evidence and cause

The owner confirms actual watch downloads work and Android reports inventory; phone selection initiates
a transfer. This supersedes the earlier unknown download admission result. A phone-started transfer
stopped at 25%; full completion/offline playback remains unverified. Companion never displayed a book;
the supplied fēnix 8 51 mm AMOLED photo shows crowded key labels and an ineffective headphone glyph.
Those visual findings supersede the previous approximate layout preview.

The installed Android Garmin SDK 2.4.0 `unregisterForApplicationEvents(device, app)` clears every local
app listener on that device. Replacing Audio Provider's registration could therefore remove Companion's
receiver. The adapter now restores the surviving channel after unregister, with current lifecycle/device
guards. A regression uses the actual SDK listener table and delivers messages through both callbacks
after replacing either app. Integer/Long protocol majors are admitted without accepting strings/floats.

## Changes and limits

- Phone Force sync now also resets Companion's bounded handshake/ack delivery after rereading privacy.
  Watch Menu > Sync phone initiates a new nonce. Neither operation starts/stops/seeks phone playback.
- Android Downloads shows the authorized book title, stored part count, suffix percentage and explicit
  Resume download. Resume captures profile/device, rechecks authorization and incomplete inventory,
  makes an accepted request pending again, and preserves its ID. Duplicate ordinary requests still
  deduplicate; locked/foreign/device-changed/completed/revoked rows cannot initiate a retry.
- Watch Audio > Download progress lists unfinished books by title and stored percentage, with Resume
  download; an existing partial book also has a distinct Resume download action beside playback Resume.
  Retained jobs use their durable cursor/generation; failed partial jobs rebuild using existing normal
  source/duration/speed/coverage policy. No cache reset, migration, unbinding or uninstall is introduced.
- Calls to start a native sync while this sync delegate is already active are suppressed. New queued
  work is consumed by the existing fresh-queue loop. Interruptions keep jobs/cursors; transfer failures
  remain retryable through partial-book coverage. This is a mitigation, not a proven cause of the owner's
  interruption; actual firmware behavior still needs the tests below.
- Companion has a dedicated dark teal round layout: smaller source/state header, wider left-aligned
  measured reading area, separate START menu cue and page count. Full title/author/chapter/state/recency
  remain paged; same-book updates preserve the page. START/Menu opens Sync phone, Watch audio and Help.
  Audio/setup/error layouts retain their existing independent geometry. Label: **TEST 2026-10-09a**.
- Garmin's `System.exitTo` supports watch-app/widget targets, not Audio Content Provider targets.
  Companion therefore offers explicit Watch audio guidance to the native Music provider route, rather
  than a direct launch it cannot support. Both installed app IDs remain unchanged.
- `Communications.notifySyncProgress` accepts only 0–100 percent, without a title. The firmware-owned
  “Synchronizing BookWave…” heading cannot be changed per book through this API. Book titles/progress
  are shown in Android Downloads and watch Download progress; no unsupported sync drawing is claimed.

Sources: [System.exitTo](https://developer.garmin.com/connect-iq/api-docs/Toybox/System.html#exitTo-instance_function),
[sync progress](https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html#notifySyncProgress-instance_function).

## Verification record

Focused Android regressions, actual fix-removal checks, strict verifyDebug, native type checking, contract
guardrails, Node tests and exact-head PR CI are recorded with delivery. Native test-enabled compilation
must not be reported as Run No Evil execution. No physical pass is inferred from compilation or photos.

## Physical acceptance register

| ID | Needed test | Status |
| --- | --- | --- |
| WR01 | Upgrade APK and both matching `fenix847mm` PRGs with retained signer/filenames; account, media and progress survive; verify TEST 2026-10-09a. | Pending |
| WR02 | BookWave phone has a current book; open Companion, Sync phone, confirm full title/position/playing and paused changes. Retry after opening Audio, reconnecting Bluetooth, and restarting either app. | Previously never displays book; fix retest pending |
| WR03 | Start phone book sync after a stalled handshake; lock/switch BookWave profile during delivery; foreign title clears and cannot reappear from an old ack. Playback stays continuous. | Pending |
| WR04 | Visual only: empty and long-metadata Companion pages on 51 mm; title/body contrast, full text, START/Menu cue, no key/text overlap; same-book updates keep page. Also 43 mm if available. | Prior photo fails; revised visual acceptance pending |
| WR05 | Start a book from phone; interrupt Wi-Fi midway; reopen provider then phone Downloads and Resume download. Percentage increases from retained parts; no restart from zero, duplicates, missing parts or unintended playback. | Prior phone-started transfer stopped at 25%; retry pending |
| WR06 | Resume via watch Download progress and per-book Resume download after cancel, transfer error and watch restart; correct title, speed and retained suffix; fully downloaded books offer no download retry. | Pending |
| WR07 | Queue another book / retry while native sync active; no interruption caused by another startSync; both jobs finish. Record code/step if interrupted; do not collect credentials or URLs. | Pending |
| WR08 | Phone Downloads refresh shows book name/parts/percentage; 200% text remains usable; revoked local download or changed/locked profile blocks stale resume. | Pending |
| WR09 | Finish transfer and play offline with phone absent; chapter boundaries, restart resume, listening history original times, then reconnect/force sync to ABS. | Pending |
| WR10 | Companion Watch audio guidance reaches Music > BookWave Audio; firmware heading remains generic while app-owned progress identifies the book. | Pending; platform limits documented |

iOS, Silo, watch face and Data Field are not started. Credential bootstrap and Sidecar deployment remain
separate pending work; this change exports no Android token/password and changes no running Sidecar.
