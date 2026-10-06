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
        Storage.setValue(SnapshotStore.STORAGE_KEY, {"broken" => true});

        var restored = store.load();
        var result = restored == null
            && store.getLoadStatus() == SnapshotStore.LOAD_INVALID;

        store.clear();
        return result;
    }

    // Simulator-only fixture seeding path. Test code is excluded from normal builds.
    (:test)
    static function seedPlayingFixture(logger) {
        var store = new SnapshotStore();
        store.clear();
        return store.saveIfValid(PlaybackFixtures.playing());
    }
}
