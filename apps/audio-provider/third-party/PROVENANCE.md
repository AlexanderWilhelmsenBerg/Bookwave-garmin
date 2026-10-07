# WatchShelf engine reuse

Source: https://github.com/JediBrooker/WatchShelf
Commit: `93ac7507dae1cae1221509cefd97441dab36e955`
License reviewed: MIT, Copyright (c) 2026 Christian Brooker.

Selected because the owner requires a separate native provider using existing Sidecar and unmodified
WatchShelf has no phone queue/inventory/event receiver. No official Audiobookshelf app code was copied.
The upstream source references Garmin's MonkeyMusic API shape; no additional sample source was imported.

The native cache/chunk/sync/playback foundation and its tests are adapted below. BookWave removes the
destructive version wipe, normal ABS key fallback and raw private logs. New provider control/account
policy is separate. Preserve this license in source and distribution notices.

Copied/adapted files:

- source/AbsApi.mc
- source/BookActionMenu.mc
- source/BookMenuDelegate.mc
- source/BookStore.mc
- source/Browse.mc
- source/Chunks.mc
- source/ChunksTests.mc
- source/Constants.mc
- source/ContentDelegate.mc
- source/ContentIterator.mc
- source/DownloadedMenu.mc
- source/DownloadedMenuDelegate.mc
- source/Downloads.mc
- source/Errors.mc
- source/ErrorView.mc
- source/ErrorViewDelegate.mc
- source/IntegrationTests.mc
- source/JobStore.mc
- source/LibraryMenuDelegate.mc
- source/LibraryView.mc
- source/LibraryViewDelegate.mc
- source/LiveProgressTests.mc
- source/Login.mc
- source/Notify.mc
- source/PlaybackSpeed.mc
- source/PlayMenu.mc
- source/Progress.mc
- source/ProgressConflictTests.mc
- source/ProgressSync.mc
- source/ProxyHeader.mc
- source/ProxyHeaderTests.mc
- source/RequestDelegate.mc
- source/Setup.mc
- source/SyncDelegate.mc
- source/TextEntry.mc
- source/TextEntryTests.mc
- source/VariantTests.mc
- resources/drawables/book_icon.png
- resources/drawables/drawables.xml
- resources/drawables/launcher_icon.png
- resources/drawables/provider_icon.png
- resources/settings/properties.xml
- resources/settings/settings.xml
- resources/strings/strings.xml
