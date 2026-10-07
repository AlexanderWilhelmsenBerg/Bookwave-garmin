using Toybox.Lang;

(:background)
module SnapshotCodec {
    const MAX_ID_LENGTH = 96;
    const MAX_TITLE_LENGTH = 160;
    const MAX_AUTHOR_LENGTH = 120;
    const MAX_CHAPTER_LENGTH = 160;

    var _lastError = null;

    function getLastError() {
        return _lastError;
    }

    function decode(value) {
        _lastError = null;

        if (!(value instanceof Lang.Dictionary)) {
            return reject("snapshot_not_dictionary");
        }

        var protocolVersion = value["protocolVersion"];
        if (!(protocolVersion instanceof Lang.Number)) {
            return reject("protocol_version_missing");
        }
        if (protocolVersion != BookWaveProtocol.PROTOCOL_MAJOR) {
            return reject("unsupported_protocol_major");
        }

        if (!isRequiredString(value["profileId"], MAX_ID_LENGTH)) {
            return reject("invalid_profile_id");
        }
        if (!isRequiredString(value["bookId"], MAX_ID_LENGTH)) {
            return reject("invalid_book_id");
        }
        if (!isRequiredString(value["title"], MAX_TITLE_LENGTH)) {
            return reject("invalid_title");
        }

        if (!isOptionalString(value["author"], MAX_AUTHOR_LENGTH)) {
            return reject("invalid_author");
        }
        if (!isOptionalString(value["chapterTitle"], MAX_CHAPTER_LENGTH)) {
            return reject("invalid_chapter_title");
        }

        var positionMs = value["positionMs"];
        if (!isInteger(positionMs) || positionMs < 0) {
            return reject("invalid_position");
        }

        var durationMs = value["durationMs"];
        if (durationMs != null) {
            if (!isInteger(durationMs) || durationMs <= 0) {
                return reject("invalid_duration");
            }
            if (positionMs > durationMs) {
                return reject("position_beyond_duration");
            }
        }

        var updatedAt = value["updatedAt"];
        if (!isInteger(updatedAt) || updatedAt <= 0) {
            return reject("invalid_timestamp");
        }

        var playing = value["playing"];
        if (!(playing instanceof Lang.Boolean)) {
            return reject("invalid_playing_state");
        }

        var source = value["source"];
        if (!(source instanceof Lang.String) || !BookWaveProtocol.isSupportedSource(source)) {
            return reject("invalid_source");
        }

        return new PlaybackSnapshot(value);
    }

    function reject(reason) {
        _lastError = reason;
        return null;
    }

    function isInteger(value) {
        return value instanceof Lang.Number || value instanceof Lang.Long;
    }

    function isRequiredString(value, maxLength) {
        return value instanceof Lang.String
            && value.length() > 0
            && value.length() <= maxLength;
    }

    function isOptionalString(value, maxLength) {
        return value == null
            || (value instanceof Lang.String && value.length() <= maxLength);
    }
}
