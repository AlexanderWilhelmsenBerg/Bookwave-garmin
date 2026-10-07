// Derived from WatchShelf, Copyright (c) 2026 Christian Brooker.
// MIT license: ../third-party/WATCHSHELF-LICENSE.txt; source pin documented there.
module Setup {
    function start() { Login.start(); }
    function isUnconfigured() { return !AbsApi.isConfigured(); }
}
