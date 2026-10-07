using Toybox.Graphics as Graphics;
using Toybox.Timer;
using Toybox.WatchUi as WatchUi;

class CompanionView extends WatchUi.View {
    const TITLE_LIMIT = 38;
    const CHAPTER_LIMIT = 42;
    const AUTHOR_LIMIT = 38;
    const CONNECTION_POLL_MS = 15000;

    var _app;
    var _timer;

    function initialize(app) {
        View.initialize();
        _app = app;
        _timer = null;
    }

    function onShow() {
        _app.refreshPhoneConnection();
        if (_timer == null) {
            _timer = new Timer.Timer();
        }
        _timer.start(method(:pollPhone), CONNECTION_POLL_MS, true);
    }

    function onHide() {
        if (_timer != null) {
            _timer.stop();
        }
    }

    function pollPhone() {
        _app.refreshPhoneConnection();
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var cx = dc.getWidth() / 2;
        var height = dc.getHeight();
        var snapshot = _app.getSnapshot();
        var loadStatus = _app.getLoadStatus();

        drawCentered(dc, cx, height * 8 / 100, Graphics.FONT_SMALL, "BOOKWAVE");

        if (loadStatus == SnapshotStoreState.LOAD_INVALID) {
            drawInvalidState(dc, cx, height);
            return;
        }

        if (snapshot == null) {
            drawNeverSyncedState(dc, cx, height);
            return;
        }

        drawSnapshot(dc, cx, height, snapshot);
    }

    function drawNeverSyncedState(dc, cx, height) {
        drawCentered(dc, cx, height * 36 / 100, Graphics.FONT_MEDIUM, "No current book");
        drawCentered(dc, cx, height * 48 / 100, Graphics.FONT_SMALL, connectionLabel());
        drawCentered(dc, cx, height * 62 / 100, Graphics.FONT_SMALL, "Waiting for BookWave");
    }

    function drawInvalidState(dc, cx, height) {
        drawCentered(dc, cx, height * 34 / 100, Graphics.FONT_MEDIUM, "Stored state invalid");
        drawCentered(dc, cx, height * 47 / 100, Graphics.FONT_SMALL, "Playback data was discarded");
        drawCentered(dc, cx, height * 61 / 100, Graphics.FONT_SMALL, connectionLabel());

        var error = _app.getLoadError();
        if (error != null) {
            drawCentered(dc, cx, height * 72 / 100, Graphics.FONT_XTINY, clip(error, 34));
        }
    }

    function drawSnapshot(dc, cx, height, snapshot) {
        var stateLabel = snapshot.playing ? "PLAYING" : "PAUSED";

        drawCentered(dc, cx, height * 19 / 100, Graphics.FONT_MEDIUM, clip(snapshot.title, TITLE_LIMIT));
        drawCentered(dc, cx, height * 29 / 100, Graphics.FONT_XTINY, clip(PlaybackFormat.author(snapshot), AUTHOR_LIMIT));
        drawCentered(dc, cx, height * 38 / 100, Graphics.FONT_SMALL, clip(PlaybackFormat.chapter(snapshot), CHAPTER_LIMIT));
        drawCentered(dc, cx, height * 49 / 100, Graphics.FONT_LARGE, PlaybackFormat.percent(snapshot));
        drawCentered(dc, cx, height * 61 / 100, Graphics.FONT_SMALL, PlaybackFormat.progress(snapshot));

        drawCentered(dc, cx, height * 72 / 100, Graphics.FONT_XTINY, stateLabel + " • " + connectionLabel());
        drawCentered(dc, cx, height * 82 / 100, Graphics.FONT_SMALL, transportDetail());
        drawCentered(dc, cx, height * 91 / 100, Graphics.FONT_XTINY, PlaybackFormat.recency(snapshot));
    }

    function connectionLabel() {
        var status = _app.getTransportStatus();
        if (status == CompanionTransportState.CONNECTED) {
            return "Connected";
        }
        if (status == CompanionTransportState.INCOMPATIBLE) {
            return "Protocol incompatible";
        }
        if (status == CompanionTransportState.DISCONNECTED) {
            return "Phone disconnected";
        }
        return "Waiting for BookWave";
    }

    function transportDetail() {
        var status = _app.getTransportStatus();
        if (status == CompanionTransportState.CONNECTED) {
            return "BookWave available";
        }
        if (status == CompanionTransportState.INCOMPATIBLE) {
            return "Update BookWave";
        }
        if (status == CompanionTransportState.DISCONNECTED) {
            return "Using last valid state";
        }
        return "Negotiating transport";
    }

    function drawCentered(dc, cx, y, font, text) {
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
