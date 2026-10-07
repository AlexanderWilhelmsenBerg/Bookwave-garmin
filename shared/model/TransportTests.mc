using Toybox.Test;

class TransportTests {
    (:test)
    static function commonGoldenEnvelopeCases(logger) {
        var cases = TransportFixtures.cases();
        for (var i = 0; i < cases.size(); i++) {
            if ((TransportCodec.decode(cases[i]["raw"]) != null) != cases[i]["accepted"]) { return false; }
        }
        return true;
    }

    (:test)
    static function strictEnvelopeTypes(logger) {
        var raw = envelope("snapshot", "message-1", 1);
        if (TransportCodec.decode(raw) == null) { return false; }
        raw["v"] = 1.5;
        if (TransportCodec.decode(raw) != null) { return false; }
        raw["v"] = 1;
        raw["ts"] = -1;
        if (TransportCodec.decode(raw) != null) { return false; }
        raw["ts"] = 1700000000000l;
        raw["r"] = 42;
        return TransportCodec.decode(raw) == null;
    }

    (:test)
    static function privacyClearBeforeSnapshot(logger) {
        var order = new TransportOrder();
        order.bind("watch-session");
        var snapshot = envelope("snapshot", "snapshot-1", 2);
        if (order.classify(snapshot) != "clear_required") { return false; }
        var clear = envelope("clear_state", "clear-1", 1);
        order.accept(clear);
        return order.classify(snapshot) == "new";
    }

    (:test)
    static function staleDuplicateAndOldStream(logger) {
        var order = new TransportOrder();
        order.bind("watch-session");
        var clear = envelope("clear_state", "clear-1", 1);
        order.accept(clear);
        if (order.classify(clear) != "duplicate") { return false; }
        var stale = envelope("snapshot", "snapshot-old", 1);
        if (order.classify(stale) != "stale") { return false; }
        order.bind("watch-new");
        return order.classify(clear) == "stale" && !order.cleared;
    }

    (:test)
    static function epochPrecisionAndUnknownFields(logger) {
        var raw = envelope("snapshot", "message-1", 1);
        raw["future"] = "ignored";
        var decoded = TransportCodec.decode(raw);
        return decoded != null && decoded["ts"] == 1700000000000l;
    }

    (:test)
    static function privacyClearSurvivesRestore(logger) {
        var store = new SnapshotStore();
        if (!store.saveIfValid(PlaybackFixtures.playing()) || !store.clear()) { return false; }
        return new SnapshotStore().load() == null;
    }

    static function envelope(type, id, sequence) {
        return {"v" => 1, "t" => type, "id" => id, "ts" => 1700000000000l,
            "s" => "watch-session", "n" => sequence, "p" => {}};
    }
}
