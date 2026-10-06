(:debug)
module PlaybackFixtures {
    function neverSynced() {
        return null;
    }

    function playing() {
        return {
            "protocolVersion" => 1,
            "profileId" => "profile-main",
            "bookId" => "book-dcc-1",
            "title" => "Dungeon Crawler Carl",
            "author" => "Matt Dinniman",
            "chapterTitle" => "Chapter 31",
            "positionMs" => 126830000l,
            "durationMs" => 261781000l,
            "updatedAt" => 1791312000000l,
            "playing" => true,
            "source" => "PHONE"
        };
    }

    function paused() {
        var value = playing();
        value["playing"] = false;
        return value;
    }

    function veryLongTitle() {
        var value = playing();
        value["title"] = "The Extremely Long Audiobook Title That Keeps Going Across the Garmin Screen Without Pretending the Display Is a Tablet";
        return value;
    }

    function missingChapter() {
        var value = playing();
        value["chapterTitle"] = null;
        return value;
    }

    function over24Hours() {
        var value = playing();
        value["positionMs"] = 126830000l;
        value["durationMs"] = 261781000l;
        return value;
    }

    function nearFinished() {
        var value = playing();
        value["positionMs"] = 261650000l;
        return value;
    }

    function invalidSnapshot() {
        var value = playing();
        value["positionMs"] = -10;
        return value;
    }

    function unsupportedProtocol() {
        var value = playing();
        value["protocolVersion"] = 2;
        return value;
    }
}
