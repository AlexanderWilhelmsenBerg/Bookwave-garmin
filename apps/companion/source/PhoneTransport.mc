using Toybox.Communications;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Timer;

class PhoneSendListener extends Communications.ConnectionListener {
    var _owner;
    function initialize(owner) { ConnectionListener.initialize(); _owner = owner; }
    function onComplete() as Void { } // BLE completion is not confirmation of accepted state.
    function onError() as Void { _owner.sendFailed(); }
}

class PhoneTransport {
    var _owner;
    var _store;
    var _order;
    var _timer;
    var _listener;
    var _helloId;
    var _counter = 0;
    var _running = false;
    var _lastReceived = null;
    var _lastAck = null;

    function initialize(owner, store) {
        _owner = owner;
        _store = store;
        _order = new TransportOrder();
        _listener = new PhoneSendListener(self);
        _timer = new Timer.Timer();
    }

    function start() {
        _running = true;
        _helloId = nextId();
        Communications.registerForPhoneAppMessages(method(:receive));
        // Registration may immediately deliver queued messages; they cannot bypass the nonce/clear gate.
        sendHello();
        _timer.start(method(:heartbeat), 30000, true);
    }

    function requestNow() {
        if(!_running){return;}
        _helloId=nextId();_order=new TransportOrder();_lastAck=null;_lastReceived=null;
        _owner.transportStatus("Connecting to phone");
        sendHello();
    }

    function stop() {
        _running = false;
        _timer.stop();
        Communications.registerForPhoneAppMessages(null);
        _lastReceived = null;
    }

    function heartbeat() as Void {
        if (!_running) { return; }
        if (_lastReceived == null || System.getTimer() - _lastReceived > 60000) {
            _owner.transportStatus("Stored; waiting for phone");
            if (_order.stream != null) {
                // A fresh nonce recovers a stale/reordered handshake after the receipt lease expires.
                _helloId = nextId();
                _order = new TransportOrder();
                _lastAck = null;
                _lastReceived = null;
            }
        }
        if (_order.stream == null) { sendHello(); }
        else { send(envelope("state_request", {}, null)); }
    }

    function sendHello() {
        var hello = envelope("hello", {"majors" => [1],
            "caps" => ["snapshot", "snapshot_ack", "state_request", "clear_state", "ordered_state"]}, null);
        hello["id"] = _helloId;
        send(hello);
    }

    function receive(message as Communications.PhoneAppMessage) as Void {
        if (!_running) { return; }
        var value = TransportCodec.decode(message.data);
        if (value == null) {
            if (message.data instanceof Lang.Dictionary && message.data["v"] instanceof Lang.Number && message.data["v"] != 1) {
                _owner.transportStatus("Phone protocol incompatible");
            }
            return;
        }
        var type = value["t"];
        if (type == "hello") {
            _helloId = nextId();
            _order = new TransportOrder();
            _lastAck = null;
            _lastReceived = null;
            _owner.transportStatus("Connecting to phone");
            sendHello();
            return;
        }
        if (type == "hello_ack") {
            negotiate(value);
            return;
        }
        if (type != "snapshot" && type != "clear_state") { return; }
        var classification = _order.classify(value);
        if (classification == "duplicate") {
            if (_lastAck != null) { send(_lastAck); }
            return;
        }
        if (classification != "new") { return; }
        acceptState(value);
    }

    function negotiate(value) {
        if (value["r"] != _helloId || value["s"] != _helloId) { return; }
        var payload = value["p"];
        if (payload["compatible"] != true || payload["selected"] != 1 ||
            !(payload["caps"] instanceof Lang.Array) || payload["caps"].indexOf("ordered_state") == -1) {
            _owner.transportStatus("Phone protocol incompatible");
            return;
        }
        _order.bind(_helloId);
        _owner.transportStatus("Connecting to phone");
    }

    function acceptState(value) {
        var clear = value["t"] == "clear_state";
        var accepted = false;
        var snapshot = null;
        if (clear) {
            // Always redact memory, even when durable storage is unavailable. Do not acknowledge success then.
            _owner.transportSnapshot(null, "No current book");
            accepted = _store.clear();
        } else {
            snapshot = SnapshotCodec.decode(value["p"]);
            accepted = snapshot != null && snapshot.source == "PHONE" && _store.saveIfValid(snapshot);
        }
        var ack = envelope(clear ? "clear_ack" : "snapshot_ack", {"accepted" => accepted}, value["id"]);
        ack["n"] = value["n"];
        if (accepted) {
            _order.accept(value);
            _lastAck = ack;
            _lastReceived = System.getTimer();
            _owner.transportSnapshot(snapshot, "Phone state received");
        } else { _owner.transportStatus("State storage failed"); }
        send(ack);
    }

    function envelope(type, payload, reply) {
        var value = {"v" => 1, "t" => type, "id" => nextId(), "ts" => Time.now().value().toLong() * 1000l, "p" => payload};
        if (_order.stream != null) { value["s"] = _order.stream; }
        if (reply != null) { value["r"] = reply; }
        return value;
    }

    function nextId() {
        _counter++;
        return "watch-" + Time.now().value().toString() + "-" + System.getTimer().toString() + "-" + _counter.toString();
    }

    function send(value) {
        if (!_running) { return; }
        try { Communications.transmit(value, {}, _listener); }
        catch (ex) { sendFailed(); }
    }

    function sendFailed() {
        if (_running) { _owner.transportStatus("Stored; waiting for phone"); }
    }
}
