// Derived from WatchShelf, Copyright (c) 2026 Christian Brooker.
// MIT license: ../third-party/WATCHSHELF-LICENSE.txt; source pin documented there.
using Toybox.Application;

// ---------------------------------------------------------------------------
// Application.Storage keys (object store). These hold app STATE (not user
// settings). Storage (not Properties) because these are code-managed and a
// sync/background process CAN write Storage but NOT Properties.
//
// SIZE MATTERS HERE - this layout exists because the first design stored one
// dictionary entry PER CHUNK in a single Storage value ({ "itemId:idx" =>
// 9-field dict }), and a long audiobook (The Algebraist: 19.4h = 389 chunks)
// made that value large enough that Storage.setValue() died with a FATAL,
// UNCATCHABLE "Out Of Memory Error" - reproduced in the simulator against
// this exact device profile (fenix8solar51mm), which gives an
// audioContentProvider app only 512KB. On the watch that crash surfaces as
// the native "Media Error Occurred" dialog + app exit. Storage values are
// also hard-limited to 32KB each (SDK-documented). So: everything below is
// O(books), never O(chunks) - chunk boundaries are DERIVED via the Chunks
// module, and per-chunk refIds live in one small per-book value.
// ---------------------------------------------------------------------------
module Store {
    // Queued download jobs live in JobStore (one job per key + a small
    // index) - O(files) inos/durs arrays per job must not share one value.
    // ALWAYS read queue state fresh per event, never held across events: a
    // long-lived in-memory snapshot persisted wholesale silently clobbers
    // queue writes made while a (background) sync is running.
    //
    // [ itemId, ... ] - books queued for DELETION (whole books only; the UI
    // has no per-chunk delete).
    const DELETE_LIST = "deleteList";
    // [ itemId, ... ] - books with downloaded chunks (index for the menu).
    const BOOK_INDEX  = "bookIndex";
    const APP_VERSION = "appVersion";  // Number, see Versions
    const SERVER      = "absServer";   // server URL saved by on-watch login
    const TOKEN       = "absToken";    // bearer token saved by on-watch login
    // Optional reverse-proxy credential, set on-watch (see ProxyHeader.mc).
    // A proxy in front of the sidecar can require this header before it
    // forwards anything, so the sidecar can be exposed without being open to
    // the internet. Both are needed for the header to be sent.
    // These persist across BookWave upgrades; a
    // user behind a proxy who lost them could not reach the server to re-enter
    // them, which is a lockout, not an inconvenience.
    const PROXY_NAME  = "proxyHdrName";
    const PROXY_VALUE = "proxyHdrValue";

    // Two-way play-progress state, O(books): one small dictionary keyed by
    // itemId (never per-chunk - see the OOM post-mortem above). See Progress.mc
    // for the value shape and the last-write-wins merge.
    const PROGRESS    = "prog";
    // One-shot flag: the user tapped "Sync now". Makes isSyncNeeded() true for
    // exactly one sync (onStartSync deletes it immediately), so an on-demand
    // progress exchange runs even when no download/delete is queued - WITHOUT
    // leaving isSyncNeeded() permanently true (which the OS would turn into
    // endless no-op syncs).
    const FORCE_SYNC  = "forceSync";
    // Last foreground-readable download failure. Some device firmware renders
    // only the native "Transfer failed" heading and drops the descriptive
    // string passed to notifySyncComplete(), so keep the same detail here for
    // DownloadedMenu -> "Last sync failed".
    const LAST_SYNC_ERROR = "syncError";
    // Diagnostic for issue #61: how often a server position has displaced an
    // UNFLUSHED local listen, plus the shape of the last one. Absent until it
    // actually happens, and O(1) - a count and three numbers, never a list.
    const MERGE_CONFLICT  = "mergeConflict";
}

// ---------------------------------------------------------------------------
// Application.Properties keys. These are USER-EDITABLE in Garmin Connect Mobile
// / Garmin Express and MUST be declared in resources/settings/properties.xml.
// Properties.getValue throws InvalidKeyException for an undeclared key.
// ---------------------------------------------------------------------------
module Settings {
    const SERVER_URL  = "absServerUrl";  // the sidecar's public URL (no trailing slash)
    const PROXY_NAME  = "absProxyHeader";  // e.g. "X-Client-Authentication"
    const PROXY_VALUE = "absProxySecret";  // the shared secret the proxy checks
}

// Retained engine shape revision; BookWave uses additive/defaulted records and never wipes on upgrade.
module Versions {
    const current = 3;
    const tag = "BW-A1";
}
