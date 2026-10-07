using Toybox.Application as Application;
using Toybox.Background;
using Toybox.Communications;
using Toybox.System;
using Toybox.WatchUi as WatchUi;

(:background)
module CompanionTransportState {
    const WAITING = "waiting";
    const CONNECTED = "connected";
    const DISCONNECTED = "disconnected";
    const INCOMPATIBLE = "incompatible";
}

(:background)
class BookWaveCompanionApp extends Application.AppBase {
    var _snapshot;
    var _loadStatus;
    var _loadError;
    var _transportStatus;
    var _foregroundActive;

    function initialize() {
        AppBase.initialize();
        _snapshot = null;
        _loadStatus = SnapshotStoreState.LOAD_NEVER_SYNCED;
        _loadError = null;
        _transportStatus = CompanionTransportState.WAITING;
        _foregroundActive = false;
    }

    function onStart(state) {
        _foregroundActive = true;
        reloadStoredState();
        registerBackgroundTransport();
        registerForegroundTransport();
        refreshPhoneConnection();

        if (_transportStatus != CompanionTransportState.DISCONNECTED) {
            requestHandshakeAndState();
        }
    }

    function onStop(state) {
        _foregroundActive = false;
        Communications.registerForPhoneAppMessages(null);
        if (Communications has :registerForPhoneAppMessageErrors) {
            Communications.registerForPhoneAppMessageErrors(null);
        }
    }

    function getInitialView() {
        return [new CompanionView(self)];
    }

    function getServiceDelegate() {
        return [new BookWaveServiceDelegate()];
    }

    function onBackgroundData(data) {
        reloadStoredState();
        if (_foregroundActive) {
            WatchUi.requestUpdate();
        }
    }

    function getSnapshot() {
        return _snapshot;
    }

    function getLoadStatus() {
        return _loadStatus;
    }

    function getLoadError() {
        return _loadError;
    }

    function getTransportStatus() {
        return _transportStatus;
    }

    function refreshPhoneConnection() {
        var connected = false;
        try {
            connected = System.getDeviceSettings().phoneConnected;
        } catch (ex) {
            connected = false;
        }

        if (!connected) {
            _transportStatus = CompanionTransportState.DISCONNECTED;
        } else if (_transportStatus == CompanionTransportState.DISCONNECTED) {
            _transportStatus = CompanionTransportState.WAITING;
            requestHandshakeAndState();
        }
        return connected;
    }

    function onPhoneAppMessage(msg) {
        if (msg == null) {
            return;
        }

        var result = TransportProcessor.process(msg.data);
        applyTransportResult(result);
        var reply = result[TransportProcessor.RESULT_REPLY];
        if (reply != null) {
            send(reply);
        }
    }

    function onPhoneAppMessageError(error) {
        refreshPhoneConnection();
        if (_transportStatus != CompanionTransportState.DISCONNECTED) {
            _transportStatus = CompanionTransportState.WAITING;
        }
        WatchUi.requestUpdate();
    }

    function requestHandshakeAndState() {
        var latest = _snapshot == null ? null : _snapshot.updatedAt;
        send(TransportCodec.hello(latest));
        send(TransportCodec.stateRequest());
    }

    function applyTransportResult(result) {
        if (result[TransportProcessor.RESULT_INCOMPATIBLE] == true) {
            _transportStatus = CompanionTransportState.INCOMPATIBLE;
        } else if (result[TransportProcessor.RESULT_COMPATIBLE] == true) {
            _transportStatus = CompanionTransportState.CONNECTED;
        } else if (refreshPhoneConnection()) {
            _transportStatus = CompanionTransportState.CONNECTED;
        }

        if (result[TransportProcessor.RESULT_CHANGED] == true) {
            reloadStoredState();
        }
        WatchUi.requestUpdate();
    }

    function reloadStoredState() {
        var store = new SnapshotStore();
        _snapshot = store.load();
        _loadStatus = store.getLoadStatus();
        _loadError = store.getLastError();
    }

    function registerBackgroundTransport() {
        try {
            Background.registerForPhoneAppMessageEvent();
        } catch (ex) {
            // Foreground transport still works if the platform refuses registration.
        }
    }

    function registerForegroundTransport() {
        Communications.registerForPhoneAppMessages(method(:onPhoneAppMessage));
        if (Communications has :registerForPhoneAppMessageErrors) {
            Communications.registerForPhoneAppMessageErrors(method(:onPhoneAppMessageError));
        }
    }

    function send(payload) {
        try {
            Communications.transmit(payload, {}, new ForegroundTransmitListener(self));
        } catch (ex) {
            refreshPhoneConnection();
        }
    }
}

class ForegroundTransmitListener extends Communications.ConnectionListener {
    var _app;

    function initialize(app) {
        ConnectionListener.initialize();
        _app = app;
    }

    function onComplete() {
        _app.refreshPhoneConnection();
        WatchUi.requestUpdate();
    }

    function onError() {
        _app.refreshPhoneConnection();
        WatchUi.requestUpdate();
    }
}
