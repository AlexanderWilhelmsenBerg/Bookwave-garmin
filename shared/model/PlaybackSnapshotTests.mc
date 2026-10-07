using Toybox.Application.Storage;
using Toybox.Test;

class PlaybackSnapshotTests {
    (:test)
    static function validSnapshotAccepted(logger) {
        return SnapshotCodec.decode(PlaybackFixtures.playing()) != null;
    }

    (:test)
    static function invalidProtocolRejected(logger) {
        return SnapshotCodec.decode(PlaybackFixtures.unsupportedProtocol()) == null;
    }

    (:test)
    static function percentageCalculation(logger) {
        var snapshot = SnapshotCodec.decode(PlaybackFixtures.playing());
        return PlaybackFormat.percent(snapshot) == "48.45%";
    }

    (:test)
    static function durationBeyond24Hours(logger) {
        return PlaybackFormat.duration(261781000l) == "72:43:01";
    }

    (:test)
    static function unknownDuration(logger) {
        var value = PlaybackFixtures.playing();
        value["durationMs"] = null;
        var snapshot = SnapshotCodec.decode(value);
        return snapshot != null
            && PlaybackFormat.percent(snapshot) == "--"
            && PlaybackFormat.progress(snapshot) == "35:13:50 / --:--:--";
    }

    (:test)
    static function missingOptionalTextAccepted(logger) {
        var snapshot = SnapshotCodec.decode(PlaybackFixtures.missingChapter());
        return snapshot != null
            && PlaybackFormat.chapter(snapshot) == "Chapter unavailable";
    }

    (:test)
    static function supportedSourcesAccepted(logger) {
        var value = PlaybackFixtures.playing();

        value["source"] = "PHONE";
        if (SnapshotCodec.decode(value) == null) { return false; }

        value["source"] = "GARMIN";
        if (SnapshotCodec.decode(value) == null) { return false; }

        value["source"] = "SERVER";
        return SnapshotCodec.decode(value) != null;
    }

    (:test)
    static function persistenceRoundTrip(logger) {
        var store = new SnapshotStore();
        store.clear();

        if (!store.saveIfValid(PlaybackFixtures.playing())) {
            return false;
        }

        var restored = store.load();
        var result = restored != null
            && restored.bookId == "book-dcc-1"
            && restored.positionMs == 126830000l;

        store.clear();
        return result;
    }

    (:test)
    static function rejectedUpdatePreservesLastGood(logger) {
        var store = new SnapshotStore();
        store.clear();

        if (!store.saveIfValid(PlaybackFixtures.playing())) {
            return false;
        }

        if (store.saveIfValid(PlaybackFixtures.invalidSnapshot())) {
            store.clear();
            return false;
        }

        var restored = store.load();
        var result = restored != null && restored.positionMs == 126830000l;
        store.clear();
        return result;
    }

    (:test)
    static function malformedPersistedStateFailsSafely(logger) {
        var store = new SnapshotStore();
        store.clear();
        Storage.setValue(SnapshotStoreState.STORAGE_KEY, {"broken" => true});

        var restored = store.load();
        var result = restored == null
            && store.getLoadStatus() == SnapshotStoreState.LOAD_INVALID;

        store.clear();
        return result;
    }

    (:test)
    static function envelopeParsesCompatibleMessage(logger) {
        var envelope = TransportCodec.decode(TransportCodec.stateRequest());
        return envelope != null
            && envelope.protocolMajor == 1
            && envelope.type == BookWaveProtocol.TYPE_STATE_REQUEST;
    }

    (:test)
    static function incompatibleEnvelopeRejected(logger) {
        var value = TransportCodec.stateRequest();
        value["v"] = 2;
        return TransportCodec.decode(value) == null
            && TransportCodec.getLastError() == "unsupported_protocol_major";
    }

    (:test)
    static function unknownMessageTypeRejected(logger) {
        var value = TransportCodec.stateRequest();
        value["t"] = "future_message";
        return TransportCodec.decode(value) == null
            && TransportCodec.getLastError() == "unsupported_message_type";
    }

    (:test)
    static function transportSnapshotUsesExistingValidationAndPersistence(logger) {
        var store = new SnapshotStore();
        store.clear();

        var result = TransportProcessor.process(
            TransportCodec.envelope(
                BookWaveProtocol.TYPE_SNAPSHOT,
                PlaybackFixtures.playing(),
                null
            )
        );
        var restored = store.load();
        var reply = TransportCodec.decode(result[TransportProcessor.RESULT_REPLY]);

        var passed = result[TransportProcessor.RESULT_CHANGED] == true
            && restored != null
            && restored.bookId == "book-dcc-1"
            && reply != null
            && reply.type == BookWaveProtocol.TYPE_SNAPSHOT_ACK
            && reply.payload["accepted"] == true;

        store.clear();
        return passed;
    }

    (:test)
    static function malformedEnvelopeRetainsLastGood(logger) {
        var store = new SnapshotStore();
        store.clear();
        if (!store.saveIfValid(PlaybackFixtures.playing())) {
            return false;
        }

        TransportProcessor.process({"broken" => true});
        var restored = store.load();
        var passed = restored != null && restored.updatedAt == PlaybackFixtures.playing()["updatedAt"];

        store.clear();
        return passed;
    }

    (:test)
    static function staleSnapshotRejected(logger) {
        var store = new SnapshotStore();
        store.clear();
        if (!store.saveIfValid(PlaybackFixtures.playing())) {
            return false;
        }

        var stale = PlaybackFixtures.playing();
        stale["updatedAt"] = stale["updatedAt"] - 1000l;
        stale["positionMs"] = stale["positionMs"] - 1000l;

        var result = TransportProcessor.process(
            TransportCodec.envelope(BookWaveProtocol.TYPE_SNAPSHOT, stale, null)
        );
        var restored = store.load();
        var reply = TransportCodec.decode(result[TransportProcessor.RESULT_REPLY]);

        var passed = result[TransportProcessor.RESULT_CHANGED] == false
            && restored.positionMs == PlaybackFixtures.playing()["positionMs"]
            && reply.payload["accepted"] == false
            && reply.payload["reason"] == "stale_snapshot";

        store.clear();
        return passed;
    }

    (:test)
    static function exactReplayIsIdempotent(logger) {
        var store = new SnapshotStore();
        store.clear();
        if (!store.saveIfValid(PlaybackFixtures.playing())) {
            return false;
        }

        var result = TransportProcessor.process(
            TransportCodec.envelope(
                BookWaveProtocol.TYPE_SNAPSHOT,
                PlaybackFixtures.playing(),
                null
            )
        );
        var reply = TransportCodec.decode(result[TransportProcessor.RESULT_REPLY]);
        var restored = store.load();

        var passed = result[TransportProcessor.RESULT_CHANGED] == false
            && reply.payload["accepted"] == true
            && reply.payload["reason"] == "replay"
            && restored.positionMs == PlaybackFixtures.playing()["positionMs"];

        store.clear();
        return passed;
    }

    (:test)
    static function snapshotAckCarriesCorrelationAndNoSnapshotEcho(logger) {
        var ack = TransportCodec.snapshotAck("phone-42", true, 1234l, null);
        var parsed = TransportCodec.decode(ack);
        return parsed != null
            && parsed.replyTo == "phone-42"
            && parsed.payload["accepted"] == true
            && parsed.payload["updatedAt"] == 1234l
            && parsed.payload["bookId"] == null;
    }

    (:test)
    static function stateRequestGeneration(logger) {
        var parsed = TransportCodec.decode(TransportCodec.stateRequest());
        return parsed != null
            && parsed.type == BookWaveProtocol.TYPE_STATE_REQUEST
            && parsed.payload != null;
    }

    (:test)
    static function clearStateIsIdempotent(logger) {
        var store = new SnapshotStore();
        store.clear();
        if (!store.saveIfValid(PlaybackFixtures.playing())) {
            return false;
        }

        var clear = TransportCodec.envelope(BookWaveProtocol.TYPE_CLEAR_STATE, {}, null);
        TransportProcessor.process(clear);
        TransportProcessor.process(clear);
        var restored = store.load();

        store.clear();
        return restored == null;
    }

    (:test)
    static function rejectedTransportRetainsLastGood(logger) {
        var store = new SnapshotStore();
        store.clear();
        if (!store.saveIfValid(PlaybackFixtures.playing())) {
            return false;
        }

        var bad = PlaybackFixtures.playing();
        bad["positionMs"] = -10;
        TransportProcessor.process(
            TransportCodec.envelope(BookWaveProtocol.TYPE_SNAPSHOT, bad, null)
        );
        var restored = store.load();

        var passed = restored != null
            && restored.positionMs == PlaybackFixtures.playing()["positionMs"];
        store.clear();
        return passed;
    }

    (:test)
    static function privacyClearBlocksDelayedPreClearSnapshot(logger) {
        var store = new SnapshotStore();
        store.clear();

        var clear = TransportCodec.envelope(BookWaveProtocol.TYPE_CLEAR_STATE, {}, null);
        var clearAt = clear["ts"];
        TransportProcessor.process(clear);

        var delayed = PlaybackFixtures.playing();
        delayed["updatedAt"] = clearAt - 1l;
        var result = TransportProcessor.process(
            TransportCodec.envelope(BookWaveProtocol.TYPE_SNAPSHOT, delayed, null)
        );
        var reply = TransportCodec.decode(result[TransportProcessor.RESULT_REPLY]);
        var restored = store.load();

        var passed = restored == null
            && reply != null
            && reply.payload["accepted"] == false
            && reply.payload["reason"] == "redacted_snapshot";

        store.clear();
        return passed;
    }

    (:test)
    static function postClearNewerSnapshotMayRepublish(logger) {
        var store = new SnapshotStore();
        store.clear();

        var clear = TransportCodec.envelope(BookWaveProtocol.TYPE_CLEAR_STATE, {}, null);
        var clearAt = clear["ts"];
        TransportProcessor.process(clear);

        var fresh = PlaybackFixtures.playing();
        fresh["updatedAt"] = clearAt + 1l;
        var result = TransportProcessor.process(
            TransportCodec.envelope(BookWaveProtocol.TYPE_SNAPSHOT, fresh, null)
        );
        var restored = store.load();

        var passed = result[TransportProcessor.RESULT_CHANGED] == true
            && restored != null
            && restored.updatedAt == clearAt + 1l;

        store.clear();
        return passed;
    }

    // Simulator-only fixture seeding paths. Test code and fixtures are excluded
    // from release builds and there is no production demo-data switch.
    (:test)
    static function seedPlayingFixture(logger) {
        return seed(PlaybackFixtures.playing());
    }

    (:test)
    static function seedPausedFixture(logger) {
        return seed(PlaybackFixtures.paused());
    }

    (:test)
    static function seedVeryLongTitleFixture(logger) {
        return seed(PlaybackFixtures.veryLongTitle());
    }

    (:test)
    static function seedMissingChapterFixture(logger) {
        return seed(PlaybackFixtures.missingChapter());
    }

    (:test)
    static function seedOver24HoursFixture(logger) {
        return seed(PlaybackFixtures.over24Hours());
    }

    (:test)
    static function seedNearFinishedFixture(logger) {
        return seed(PlaybackFixtures.nearFinished());
    }

    // These two deliberately assert rejection instead of persisting bad state.
    (:test)
    static function invalidFixtureRejected(logger) {
        return !seed(PlaybackFixtures.invalidSnapshot());
    }

    (:test)
    static function unsupportedProtocolFixtureRejected(logger) {
        return !seed(PlaybackFixtures.unsupportedProtocol());
    }

    private static function seed(value) {
        var store = new SnapshotStore();
        store.clear();
        return store.saveIfValid(value);
    }
}
