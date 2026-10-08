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
        WatchTheme.frame(dc,"BookWave Audio","","Back",false);WatchTheme.headphones(dc);
        pages=WatchTheme.page(dc,mMessage,page,"WATCH AUDIO","Back");
        if(pages>1){WatchTheme.framePageCues(dc);}
    }
    function move(delta) {
        page+=delta;
        if(page<0){page=0;}
        if(page>=pages){page=pages-1;}
        WatchUi.requestUpdate();
        return true;
    }
}
