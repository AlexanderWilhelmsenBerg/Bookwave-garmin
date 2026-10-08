// Derived from WatchShelf, Copyright (c) 2026 Christian Brooker.
// MIT license: ../third-party/WATCHSHELF-LICENSE.txt; source pin documented there.
using Toybox.Graphics;
using Toybox.WatchUi;

// Centered single-message view used for errors and short confirmations.
class ErrorView extends WatchUi.View {

    private var mMessage;
    var page=0;
    var pages=1;

    function initialize(message) {
        View.initialize();
        mMessage = message;
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        pages=RoundText.draw(dc,mMessage,page,"BACK: return");
    }
    function move(delta) {
        page+=delta;
        if(page<0){page=0;}
        if(page>=pages){page=pages-1;}
        WatchUi.requestUpdate();
        return true;
    }
}
