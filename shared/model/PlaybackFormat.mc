using Toybox.Lang;
using Toybox.Time;

module PlaybackFormat {
    function percent(snapshot) {
        if (snapshot == null || snapshot.durationMs == null || snapshot.durationMs <= 0) {
            return "--";
        }

        var value = (snapshot.positionMs.toDouble() / snapshot.durationMs.toDouble()) * 100.0d;
        return value.format("%.2f") + "%";
    }

    function duration(milliseconds) {
        if (milliseconds == null || milliseconds < 0) {
            return "--:--:--";
        }

        var totalSeconds = milliseconds / 1000;
        var hours = totalSeconds / 3600;
        var minutes = (totalSeconds % 3600) / 60;
        var seconds = totalSeconds % 60;

        return hours.toString() + ":" + pad2(minutes) + ":" + pad2(seconds);
    }

    function progress(snapshot) {
        if (snapshot == null) {
            return "--:--:-- / --:--:--";
        }
        return duration(snapshot.positionMs) + " / " + duration(snapshot.durationMs);
    }

    function chapter(snapshot) {
        if (snapshot == null || snapshot.chapterTitle == null || snapshot.chapterTitle.length() == 0) {
            return "Chapter unavailable";
        }
        return snapshot.chapterTitle;
    }

    function author(snapshot) {
        if (snapshot == null || snapshot.author == null || snapshot.author.length() == 0) {
            return "Author unavailable";
        }
        return snapshot.author;
    }

    function recency(snapshot) {
        if (snapshot == null) {
            return "";
        }

        var nowMs = Time.now().value().toLong() * 1000l;
        var delta = nowMs - snapshot.updatedAt;
        if (delta < 0) {
            return "Stored snapshot";
        }

        var seconds = delta / 1000;
        if (seconds < 60) {
            return "Last state " + seconds.toString() + " sec ago";
        }

        var minutes = seconds / 60;
        if (minutes < 60) {
            return "Last state " + minutes.toString() + " min ago";
        }

        var hours = minutes / 60;
        return "Last state " + hours.toString() + " h ago";
    }

    function pad2(value) {
        if (value < 10) {
            return "0" + value.toString();
        }
        return value.toString();
    }
}
