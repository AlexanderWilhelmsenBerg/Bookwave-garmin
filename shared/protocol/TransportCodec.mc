using Toybox.Lang;

module TransportCodec {
    function decode(value) {
        if (!(value instanceof Lang.Dictionary)) { return null; }
        if (!(value["v"] instanceof Lang.Number) || value["v"] != 1) { return null; }
        if (!id(value["id"]) || !(value["t"] instanceof Lang.String)) { return null; }
        if (value["r"] != null && !id(value["r"])) { return null; }
        if (!SnapshotCodec.isInteger(value["ts"]) || value["ts"] <= 0) { return null; }
        if (!(value["p"] instanceof Lang.Dictionary) || value["p"].size() > 16) { return null; }
        var keys = value["p"].keys();
        for (var i = 0; i < keys.size(); i++) {
            if (!(keys[i] instanceof Lang.String)) { return null; }
        }
        if (value["s"] != null && !id(value["s"])) { return null; }
        if (value["n"] != null && (!SnapshotCodec.isInteger(value["n"]) || value["n"] < 0)) { return null; }
        return value;
    }

    function id(value) {
        return value instanceof Lang.String && value.length() > 0 && value.length() <= 64;
    }
}

// Per-foreground-session ordering. Durable data is accepted only after this session's privacy clear.
class TransportOrder {
    var stream = null;
    var sequence = 0;
    var messageId = null;
    var cleared = false;

    function bind(value) {
        if (stream == value) { return; }
        stream = value;
        sequence = 0;
        messageId = null;
        cleared = false;
    }

    function classify(envelope) {
        if (stream == null || envelope["s"] != stream || !SnapshotCodec.isInteger(envelope["n"])) { return "stale"; }
        if (envelope["n"] == sequence && envelope["id"] == messageId) { return "duplicate"; }
        if (envelope["n"] <= sequence) { return "stale"; }
        if (envelope["t"] == "snapshot" && !cleared) { return "clear_required"; }
        return "new";
    }

    function accept(envelope) {
        sequence = envelope["n"];
        messageId = envelope["id"];
        if (envelope["t"] == "clear_state") { cleared = true; }
    }
}
