# WatchShelf coexistence policy

**Classification:** Current repository boundary; future integration candidate. Reconciled 2026-10-07.

Under this repository's agreement, initial BookWave Garmin phases coexist with WatchShelf + WatchShelf
Sidecar for offline audiobook preparation/download/playback and server progress upload. This documents
the selected boundary; it is not fresh verification of external WatchShelf capabilities or an installed
version. No WatchShelf code was copied and no interoperability has been physically accepted here.

BookWave Companion currently persists display state only. It neither transfers audio nor executes
watch-local playback. Android's proposed bridge adds phone snapshots, not a replacement provider/helper.
WatchShelf-origin progress may later enter reconciliation after reaching Audiobookshelf; the timestamp/
identity/conflict contract must be established with observed fixtures before claiming that integration.

Record physical coexistence findings with exact watch/firmware/apps/server versions: standalone offline
playback, rewind/chapter/resume, disconnect/restart, later server progress, conflicting phone events and
battery/storage/transfer failures. Preserve legitimate rewinds and do not start playback during sync.
No coexistence test has run in this reconciliation.

Replacing/extending the Audio Content Provider or removing Sidecar is an optional later decision justified
by those findings, not an accepted transport/transcoder/hosting design. Review upstream behavior and
licensing before any dependency or reuse; retain required notices if code is reused. See `../plan.md`
and [cross-repository status](reconciliation.md).
