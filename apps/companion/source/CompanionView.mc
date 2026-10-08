using Toybox.Graphics as Graphics;
using Toybox.WatchUi as WatchUi;

class CompanionView extends WatchUi.View {
    const TITLE_LIMIT = 38;
    const CHAPTER_LIMIT = 42;
    const AUTHOR_LIMIT = 38;

    var _connection = "Stored; waiting for phone";
    var _snapshot;
    var _loadStatus;
    var _loadError;

    function initialize(snapshot, loadStatus, loadError) {
        View.initialize();
        _snapshot = snapshot;
        _loadStatus = loadStatus;
        _loadError = loadError;
    }

    function setConnection(value) { _connection = value; }
    function setSnapshot(value, status) { _snapshot = value; _loadStatus = status; _loadError = null; }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var cx = dc.getWidth() / 2;
        var height = dc.getHeight();

        drawCentered(dc, cx, height * 8 / 100, Graphics.FONT_XTINY, "BOOKWAVE PHONE");

        if (_loadStatus == SnapshotStoreState.LOAD_INVALID) {
            drawInvalidState(dc, cx, height);
            return;
        }

        if (_snapshot == null) {
            drawNeverSyncedState(dc, cx, height);
            return;
        }

        drawSnapshot(dc, cx, height);
    }

    function drawNeverSyncedState(dc, cx, height) {
        drawCentered(dc, cx, height * 32 / 100, Graphics.FONT_SMALL, "No phone book yet");
        drawCentered(dc, cx, height * 46 / 100, Graphics.FONT_XTINY, "Open BookWave on phone");
        drawCentered(dc, cx, height * 59 / 100, Graphics.FONT_XTINY, _connection.equals("Stored; waiting for phone")?"Waiting for phone":_connection);
        drawCentered(dc, cx, height * 72 / 100, Graphics.FONT_XTINY, "START: help | BACK: exit");
        drawCentered(dc, cx, height * 83 / 100, Graphics.FONT_XTINY, BuildLabel.VALUE);
    }

    function drawInvalidState(dc, cx, height) {
        drawCentered(dc, cx, height * 34 / 100, Graphics.FONT_MEDIUM, "Stored state invalid");
        drawCentered(dc, cx, height * 47 / 100, Graphics.FONT_SMALL, "Playback data was discarded");
        drawCentered(dc, cx, height * 61 / 100, Graphics.FONT_XTINY, _connection);

        if (_loadError != null) {
            drawCentered(dc, cx, height * 72 / 100, Graphics.FONT_XTINY, clip(_loadError, 34));
        }
    }

    function drawSnapshot(dc, cx, height) {
        var stateLabel = _snapshot.playing ? "PLAYING • STORED SNAPSHOT" : "PAUSED • STORED SNAPSHOT";

        drawCentered(dc, cx, height * 19 / 100, Graphics.FONT_MEDIUM, clip(_snapshot.title, TITLE_LIMIT));
        drawCentered(dc, cx, height * 29 / 100, Graphics.FONT_XTINY, clip(PlaybackFormat.author(_snapshot), AUTHOR_LIMIT));
        drawCentered(dc, cx, height * 38 / 100, Graphics.FONT_SMALL, clip(PlaybackFormat.chapter(_snapshot), CHAPTER_LIMIT));
        drawCentered(dc, cx, height * 49 / 100, Graphics.FONT_LARGE, PlaybackFormat.percent(_snapshot));
        drawCentered(dc, cx, height * 61 / 100, Graphics.FONT_SMALL, PlaybackFormat.progress(_snapshot));

        drawCentered(dc, cx, height * 70 / 100, Graphics.FONT_XTINY, stateLabel);
        drawCentered(dc, cx, height * 77 / 100, Graphics.FONT_XTINY, _connection);
        drawCentered(dc, cx, height * 84 / 100, Graphics.FONT_XTINY, PlaybackFormat.recency(_snapshot));
        drawCentered(dc, cx, height * 90 / 100, Graphics.FONT_XTINY, "START: help");
    }

    function drawCentered(dc, cx, y, font, text) {
        // The safe chord narrows near the circle's top/bottom; never clip glyphs there.
        var width=dc.getWidth()*(y<dc.getHeight()*15/100 || y>dc.getHeight()*80/100?55:78)/100;
        while(text.length()>1 && dc.getTextWidthInPixels(text,font)>width){text=text.substring(0,text.length()-2)+"…";}
        dc.drawText(cx, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function clip(value, limit) {
        if (value == null) {
            return "";
        }

        if (value.length() <= limit) {
            return value;
        }

        return value.substring(0, limit - 1) + "…";
    }
}
