using Toybox.Application as Application;
using Toybox.WatchUi as WatchUi;

class BookWaveCompanionApp extends Application.AppBase {
    var _snapshot;
    var _loadStatus;
    var _loadError;
    var _view = null;
    var _transport = null;
    var _connection = "Stored; waiting for phone";

    function initialize() {
        AppBase.initialize();
        _snapshot = null;
        _loadStatus = SnapshotStoreState.LOAD_NEVER_SYNCED;
        _loadError = null;
    }

    function onStart(state) {
        var store = new SnapshotStore();
        _snapshot = store.load();
        BookWaveFeed.phone(_snapshot==null?null:_snapshot.toDictionary(),false);
        _loadStatus = store.getLoadStatus();
        _loadError = store.getLastError();
        _transport = new PhoneTransport(self, store);
        _transport.start();
    }

    function onStop(state) {
        BookWaveFeed.phone(_snapshot==null?null:_snapshot.toDictionary(),false);
        if (_transport != null) { _transport.stop(); }
        _transport = null;
    }

    function getInitialView() {
        _view = new CompanionView(_snapshot, _loadStatus, _loadError);
        _view.setConnection(_connection);
        return [_view,new CompanionDelegate(_view)];
    }

    function syncPhone() {
        if(_transport!=null){_transport.requestNow();}
    }

    function transportStatus(value) {
        _connection = value;
        if (_view != null) { _view.setConnection(value); WatchUi.requestUpdate(); }
    }

    function transportSnapshot(snapshot, connection) {
        _snapshot = snapshot;
        BookWaveFeed.phone(snapshot==null?null:snapshot.toDictionary(),true);
        _loadStatus = snapshot == null ? SnapshotStoreState.LOAD_NEVER_SYNCED : SnapshotStoreState.LOAD_VALID;
        _loadError = null;
        if (_view != null) { _view.setSnapshot(snapshot, _loadStatus); }
        transportStatus(connection);
    }
}
