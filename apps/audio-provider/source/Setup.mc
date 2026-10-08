// Derived from WatchShelf, Copyright (c) 2026 Christian Brooker.
// MIT license: ../third-party/WATCHSHELF-LICENSE.txt; source pin documented there.
using Toybox.WatchUi;
module Setup {
    function start() {
        var menu=new WatchUi.Menu2({:title=>"Set up BookWave Audio"});
        menu.addItem(new WatchUi.MenuItem("Use BookWave phone app","Pair, then set Sidecar URL",:phone,{}));
        menu.addItem(new WatchUi.MenuItem("Enter on watch",null,:watch,{}));
        WatchUi.switchToView(menu,new ProviderSetupMenuDelegate(),WatchUi.SLIDE_LEFT);
    }
    function isUnconfigured() { return !AbsApi.isConfigured(); }
}
class ProviderSetupMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize(){Menu2InputDelegate.initialize();}
    function onSelect(item){
        if(item.getId()==:watch){Login.start();}
        else if(AbsApi.isConfigured()){WatchUi.switchToView(new LibraryView(),new LibraryViewDelegate(),WatchUi.SLIDE_LEFT);}
        else {ProviderControl.announce("ready");}
    }
    function onBack(){WatchUi.popView(WatchUi.SLIDE_RIGHT);}
}
