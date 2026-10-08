// Derived from WatchShelf, Copyright (c) 2026 Christian Brooker.
// MIT license: ../third-party/WATCHSHELF-LICENSE.txt; source pin documented there.
using Toybox.WatchUi;

// Back handler for ErrorView (a plain WatchUi.View with no delegate of its own).
// Without this, pressing Back on ANY error/status message screen (queued,
// removing, already downloaded, queue cleared, etc.) has no handler at all and
// hangs instead of dismissing - same bug class already documented and fixed on
// LibraryViewDelegate, just never applied to ErrorView's many call sites.
class ErrorViewDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
    function onNextPage(){return move(1);}
    function onPreviousPage(){return move(-1);}
    function move(delta) {
        var view=WatchUi.getCurrentView()[0];
        if(view instanceof ErrorView){return view.move(delta);}
        return false;
    }
}
