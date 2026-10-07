using Toybox.Lang;

(:background)
class PlaybackSnapshot {
    var protocolVersion;
    var profileId;
    var bookId;
    var title;
    var author;
    var chapterTitle;
    var positionMs;
    var durationMs;
    var updatedAt;
    var playing;
    var source;

    function initialize(values) {
        protocolVersion = values["protocolVersion"];
        profileId = values["profileId"];
        bookId = values["bookId"];
        title = values["title"];
        author = values["author"];
        chapterTitle = values["chapterTitle"];
        positionMs = values["positionMs"];
        durationMs = values["durationMs"];
        updatedAt = values["updatedAt"];
        playing = values["playing"];
        source = values["source"];
    }

    function toDictionary() {
        return {
            "protocolVersion" => protocolVersion,
            "profileId" => profileId,
            "bookId" => bookId,
            "title" => title,
            "author" => author,
            "chapterTitle" => chapterTitle,
            "positionMs" => positionMs,
            "durationMs" => durationMs,
            "updatedAt" => updatedAt,
            "playing" => playing,
            "source" => source
        };
    }

    function sameState(other) {
        if (other == null) {
            return false;
        }
        return protocolVersion == other.protocolVersion
            && profileId == other.profileId
            && bookId == other.bookId
            && title == other.title
            && author == other.author
            && chapterTitle == other.chapterTitle
            && positionMs == other.positionMs
            && durationMs == other.durationMs
            && updatedAt == other.updatedAt
            && playing == other.playing
            && source == other.source;
    }
}
