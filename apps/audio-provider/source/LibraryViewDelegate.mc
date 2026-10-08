// Derived from WatchShelf, Copyright (c) 2026 Christian Brooker.
// MIT license: ../third-party/WATCHSHELF-LICENSE.txt; source pin documented there.
using Toybox.WatchUi;

// Back handler for LibraryView. LibraryView is a plain WatchUi.View (a loading
// screen), so without a paired input delegate the Back button has no handler and
// the configuration view hangs instead of dismissing. This provides it.
class LibraryViewDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Pop the loading screen -> exits the sync-configuration flow.
    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
    function onNextPage(){return move(1);}
    function onPreviousPage(){return move(-1);}
    function move(delta){var view=WatchUi.getCurrentView()[0];if(view instanceof LoginView){return view.move(delta);}return false;}
}
