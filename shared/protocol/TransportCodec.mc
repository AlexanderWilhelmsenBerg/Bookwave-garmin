using Toybox.Lang;
using Toybox.Time;

(:background)
module TransportCodec {
    const MAX_MESSAGE_ID_LENGTH = 64;
    const MAX_ERROR_LENGTH = 64;
    var _lastError = null;
    var _counter = 0;

    function getLastError() {
        return _lastError;
    }

    function decode(value) {
        _lastError = null;
        if (!(value instanceof Lang.Dictionary)) {
            return reject("envelope_not_dictionary");
        }

        var major = value["v"];
        if (!(major instanceof Lang.Number)) {
            return reject("protocol_major_missing");
        }
        if (major != BookWaveProtocol.PROTOCOL_MAJOR) {
            return reject("unsupported_protocol_major");
        }

        var type = value["t"];
        if (!(type instanceof Lang.String) || !BookWaveProtocol.isKnownMessageType(type)) {
            return reject("unsupported_message_type");
        }

        var id = value["id"];
        if (!(id instanceof Lang.String)
            || id.length() == 0
            || id.length() > MAX_MESSAGE_ID_LENGTH) {
            return reject("invalid_message_id");
        }

        var replyTo = value["r"];
        if (replyTo != null
            && (!(replyTo instanceof Lang.String)
                || replyTo.length() == 0
                || replyTo.length() > MAX_MESSAGE_ID_LENGTH)) {
            return reject("invalid_correlation_id");
        }

        var sentAt = value["ts"];
        if (sentAt != null && !SnapshotCodec.isInteger(sentAt)) {
            return reject("invalid_sent_timestamp");
        }

        var payload = value["p"];
        if (payload != null && !(payload instanceof Lang.Dictionary)) {
            return reject("invalid_payload");
        }

        return new TransportEnvelope(value);
    }

    function envelope(type, payload, replyTo) {
        var value = {
            "v" => BookWaveProtocol.PROTOCOL_MAJOR,
            "t" => type,
            "id" => nextId(type),
            "ts" => Time.now().value().toLong() * 1000l,
            "p" => payload
        };
        if (replyTo != null) {
            value["r"] = replyTo;
        }
        return value;
    }

    function hello(latestUpdatedAt) {
        var payload = {
            "majors" => [BookWaveProtocol.PROTOCOL_MAJOR],
            "caps" => BookWaveProtocol.capabilities()
        };
        if (latestUpdatedAt != null) {
            payload["latestUpdatedAt"] = latestUpdatedAt;
        }
        return envelope(BookWaveProtocol.TYPE_HELLO, payload, null);
    }

    function stateRequest() {
        return envelope(BookWaveProtocol.TYPE_STATE_REQUEST, {}, null);
    }

    function snapshotAck(replyTo, accepted, updatedAt, reason) {
        var payload = {"accepted" => accepted};
        if (updatedAt != null) {
            payload["updatedAt"] = updatedAt;
        }
        if (reason != null) {
            payload["reason"] = boundedReason(reason);
        }
        return envelope(BookWaveProtocol.TYPE_SNAPSHOT_ACK, payload, replyTo);
    }

    function clearAck(replyTo) {
        return envelope(
            BookWaveProtocol.TYPE_CLEAR_ACK,
            {"accepted" => true},
            replyTo
        );
    }

    function error(replyTo, reason) {
        return envelope(
            BookWaveProtocol.TYPE_ERROR,
            {"reason" => boundedReason(reason)},
            replyTo
        );
    }

    function boundedReason(reason) {
        if (reason == null) {
            return null;
        }
        if (reason.length() <= MAX_ERROR_LENGTH) {
            return reason;
        }
        return reason.substring(0, MAX_ERROR_LENGTH);
    }

    function nextId(prefix) {
        _counter += 1;
        if (_counter > 9999) {
            _counter = 1;
        }
        return prefix + "-" + Time.now().value().toString() + "-" + _counter.toString();
    }

    function reject(reason) {
        _lastError = reason;
        return null;
    }
}
