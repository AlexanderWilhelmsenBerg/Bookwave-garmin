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
