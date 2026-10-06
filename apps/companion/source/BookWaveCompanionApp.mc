using Toybox.Application as Application;
using Toybox.WatchUi as WatchUi;

class BookWaveCompanionApp extends Application.AppBase {
    var _snapshot;
    var _loadStatus;
    var _loadError;

    function initialize() {
        AppBase.initialize();
        _snapshot = null;
        _loadStatus = SnapshotStoreState.LOAD_NEVER_SYNCED;
        _loadError = null;
    }

    function onStart(state) {
        var store = new SnapshotStore();
        _snapshot = store.load();
        _loadStatus = store.getLoadStatus();
        _loadError = store.getLastError();
    }

    function onStop(state) {
        // Phase 1 has no background work or transport to stop.
    }

    function getInitialView() {
        return [new CompanionView(_snapshot, _loadStatus, _loadError)];
    }
}
