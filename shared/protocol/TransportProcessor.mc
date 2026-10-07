using Toybox.Lang;

(:background)
module TransportProcessor {
    const RESULT_REPLY = "reply";
    const RESULT_CHANGED = "changed";
    const RESULT_COMPATIBLE = "compatible";
    const RESULT_INCOMPATIBLE = "incompatible";

    function process(raw) {
        var envelope = TransportCodec.decode(raw);
        if (envelope == null) {
            return result(
                TransportCodec.error(null, TransportCodec.getLastError()),
                false,
                false,
                TransportCodec.getLastError() == "unsupported_protocol_major"
            );
        }

        if (envelope.type == BookWaveProtocol.TYPE_SNAPSHOT) {
            return processSnapshot(envelope);
        }

        if (envelope.type == BookWaveProtocol.TYPE_CLEAR_STATE) {
            var store = new SnapshotStore();
            store.clear();
            return result(TransportCodec.clearAck(envelope.id), true, false, false);
        }

        if (envelope.type == BookWaveProtocol.TYPE_HELLO_ACK) {
            var payload = envelope.payload;
            if (payload == null
                || !(payload["selected"] instanceof Lang.Number)
                || payload["selected"] != BookWaveProtocol.PROTOCOL_MAJOR
                || !(payload["compatible"] instanceof Lang.Boolean)
                || payload["compatible"] != true) {
                return result(
                    TransportCodec.error(envelope.id, "protocol_incompatible"),
                    false,
                    false,
                    true
                );
            }
            return result(null, false, true, false);
        }

        if (envelope.type == BookWaveProtocol.TYPE_ERROR) {
            var incompatible = false;
            if (envelope.payload != null
                && envelope.payload["reason"] == "unsupported_protocol_major") {
                incompatible = true;
            }
            return result(null, false, false, incompatible);
        }

        // These are watch-originated protocol messages. Receiving them from the
        // phone is harmless but not meaningful for this phase.
        return result(
            TransportCodec.error(envelope.id, "unexpected_message_type"),
            false,
            false,
            false
        );
    }

    function processSnapshot(envelope) {
        if (envelope.payload == null) {
            return result(
                TransportCodec.snapshotAck(envelope.id, false, null, "snapshot_missing"),
                false,
                false,
                false
            );
        }

        var store = new SnapshotStore();
        var status = store.acceptTransportCandidate(envelope.payload);
        if (status == SnapshotStoreState.REJECTED) {
            // load() intentionally resets the store's diagnostic state, so preserve
            // the transport rejection before reading the last-good snapshot.
            var rejectionReason = store.getLastError();
            var current = store.load();
            var currentUpdatedAt = current == null ? null : current.updatedAt;
            return result(
                TransportCodec.snapshotAck(
                    envelope.id,
                    false,
                    currentUpdatedAt,
                    rejectionReason
                ),
                false,
                false,
                false
            );
        }

        var accepted = store.load();
        return result(
            TransportCodec.snapshotAck(
                envelope.id,
                true,
                accepted == null ? null : accepted.updatedAt,
                status == SnapshotStoreState.REPLAY ? "replay" : null
            ),
            status == SnapshotStoreState.ACCEPTED,
            false,
            false
        );
    }

    function result(reply, changed, compatible, incompatible) {
        return {
            RESULT_REPLY => reply,
            RESULT_CHANGED => changed,
            RESULT_COMPATIBLE => compatible,
            RESULT_INCOMPATIBLE => incompatible
        };
    }
}
