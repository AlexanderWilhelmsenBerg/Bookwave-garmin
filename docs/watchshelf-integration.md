# WatchShelf Sidecar integration policy

**Classification:** Current owner-selected boundary; runtime integration still planned. **Updated:** 2026-10-07.

The owner selected a separate BookWave Audio Provider using **existing WatchShelf Sidecar**. Companion
remains a Device App for PHONE state/controls; the provider owns native offline watch media and actual
GARMIN events. WatchShelf may coexist during transition; its media cache is not BookWave's inventory.
The previous optional-provider/evaluation-only rule is superseded for the requested integration.
Replacing/removing Sidecar remains outside the selected scope.

Inspection at WatchShelf commit `93ac7507dae1cae1221509cefd97441dab36e955` found no BookWave phone
receiver or Sidecar watch-inventory/queue/listening-session route. Sidecar login sessions are auth state.
Phone download selection identifies a server item; Sidecar fetches/transcodes ABS audio rather than
reading the phone's local bytes. No WatchShelf code has been copied; any reuse retains MIT notices and
needs provenance review. Do not carry destructive upgrade resets, private logs or normal ABS-key fallback
into the new provider. Provider credentials/account pairing need their own explicit contract.

[Provider/device plan](device-management-plan.md), [Garmin #7](https://github.com/AlexanderWilhelmsenBerg/Bookwave-garmin/issues/7) and Android
[#119](https://github.com/AlexanderWilhelmsenBerg/Audiobookshelf-Manager-Claude/issues/119) track the work.
Record actual phone-free playback, chapter/rewind/restart, queue/resume/storage/battery and sync privacy
with exact firmware/app/source hashes. No physical interoperability is accepted here. Preserve legitimate
rewinds and never start playback during reconciliation. The [future face feed](watchface-state-plan.md)
uses on-watch BookWave Complications; it does not add direct watch-face ABS authentication.
