using Toybox.Application.Storage;
using Toybox.Lang;

(:background)
module SnapshotStoreState {
    const STORAGE_KEY = "bookwave.playbackSnapshot.v1";
    const REDACTION_KEY = "bookwave.playbackRedaction.v1";

    const LOAD_NEVER_SYNCED = "never_synced";
    const LOAD_VALID = "valid";
    const LOAD_INVALID = "invalid";

    const ACCEPTED = "accepted";
    const REPLAY = "replay";
    const REJECTED = "rejected";
}

(:background)
class SnapshotStore {
    var _loadStatus = SnapshotStoreState.LOAD_NEVER_SYNCED;
    var _lastError = null;

    function getLoadStatus() {
        return _loadStatus;
    }

    function getLastError() {
        return _lastError;
    }

    function load() {
        _lastError = null;

        var stored = Storage.getValue(SnapshotStoreState.STORAGE_KEY);
        if (stored == null) {
            _loadStatus = SnapshotStoreState.LOAD_NEVER_SYNCED;
            return null;
        }

        var snapshot = SnapshotCodec.decode(stored);
        if (snapshot == null) {
            _loadStatus = SnapshotStoreState.LOAD_INVALID;
            _lastError = SnapshotCodec.getLastError();
            try {
                Storage.deleteValue(SnapshotStoreState.STORAGE_KEY);
            } catch (ex) {
                // The invalid value remains quarantined by validation even if deletion fails.
            }
            return null;
        }

        _loadStatus = SnapshotStoreState.LOAD_VALID;
        return snapshot;
    }

    function saveIfValid(candidate) {
        _lastError = null;

        var encoded = candidate;
        if (candidate instanceof PlaybackSnapshot) {
            encoded = candidate.toDictionary();
        }

        var snapshot = SnapshotCodec.decode(encoded);
        if (snapshot == null) {
            _lastError = SnapshotCodec.getLastError();
            return false;
        }

        return write(snapshot);
    }

    function acceptTransportCandidate(candidate) {
        _lastError = null;

        var encoded = candidate;
        if (candidate instanceof PlaybackSnapshot) {
            encoded = candidate.toDictionary();
        }

        var snapshot = SnapshotCodec.decode(encoded);
        if (snapshot == null) {
            _lastError = SnapshotCodec.getLastError();
            return SnapshotStoreState.REJECTED;
        }

        var redactedAt = getRedactedAt();
        if (redactedAt != null && snapshot.updatedAt <= redactedAt) {
            _lastError = "redacted_snapshot";
            return SnapshotStoreState.REJECTED;
        }

        var current = load();
        if (current != null) {
            if (snapshot.updatedAt < current.updatedAt) {
                _lastError = "stale_snapshot";
                return SnapshotStoreState.REJECTED;
            }

            if (snapshot.updatedAt == current.updatedAt) {
                if (snapshot.sameState(current)) {
                    return SnapshotStoreState.REPLAY;
                }
                _lastError = "timestamp_conflict";
                return SnapshotStoreState.REJECTED;
            }
        }

        if (!write(snapshot)) {
            return SnapshotStoreState.REJECTED;
        }
        return SnapshotStoreState.ACCEPTED;
    }

    function getRedactedAt() {
        var value = Storage.getValue(SnapshotStoreState.REDACTION_KEY);
        if (SnapshotCodec.isInteger(value) && value > 0) {
            return value;
        }
        return null;
    }

    function redact(updatedAt) {
        _lastError = null;
        if (!SnapshotCodec.isInteger(updatedAt) || updatedAt <= 0) {
            _lastError = "invalid_redaction_timestamp";
            return false;
        }

        var watermarkWritten = true;
        try {
            Storage.setValue(SnapshotStoreState.REDACTION_KEY, updatedAt);
        } catch (ex) {
            watermarkWritten = false;
            _lastError = "redaction_watermark_failed";
        }

        // Privacy still requires immediate visible clearing even if the secondary
        // watermark write failed. The false result keeps that failure observable.
        try {
            Storage.deleteValue(SnapshotStoreState.STORAGE_KEY);
        } catch (ex) {
            _lastError = "storage_clear_failed";
            return false;
        }

        _loadStatus = SnapshotStoreState.LOAD_NEVER_SYNCED;
        return watermarkWritten;
    }

    function write(snapshot) {
        try {
            Storage.setValue(SnapshotStoreState.STORAGE_KEY, snapshot.toDictionary());
            _loadStatus = SnapshotStoreState.LOAD_VALID;
            return true;
        } catch (ex) {
            _lastError = "storage_write_failed";
            return false;
        }
    }

    // Local reset used by tests/simulator setup. Transport privacy uses redact()
    // so delayed pre-clear messages cannot repopulate private metadata.
    function clear() {
        try {
            Storage.deleteValue(SnapshotStoreState.STORAGE_KEY);
        } catch (ex) {
            // A missing value already satisfies the reset.
        }
        try {
            Storage.deleteValue(SnapshotStoreState.REDACTION_KEY);
        } catch (ex) {
            // A missing value already satisfies the reset.
        }
        _loadStatus = SnapshotStoreState.LOAD_NEVER_SYNCED;
        _lastError = null;
    }
}
