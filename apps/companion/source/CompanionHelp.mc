using Toybox.Application;
using Toybox.WatchUi;
class CompanionHelp extends WatchUi.View {
    var page=0;var pages=1;var text;
    function initialize(body){View.initialize();text=body;}
    function onUpdate(dc){pages=WatchTheme.companion(dc,text,page,"BOOKWAVE GUIDE","Back");}
    function move(delta){page+=delta;if(page<0){page=0;}if(page>=pages){page=pages-1;}WatchUi.requestUpdate();return true;}
}
class CompanionHelpDelegate extends WatchUi.BehaviorDelegate {
    var view;
    function initialize(value){BehaviorDelegate.initialize();view=value;}
    function onNextPage(){return view.move(1);}
    function onPreviousPage(){return view.move(-1);}
    function onSelect(){WatchUi.popView(WatchUi.SLIDE_RIGHT);return true;}
    function onBack(){WatchUi.popView(WatchUi.SLIDE_RIGHT);return true;}
}
class CompanionMenu extends WatchUi.Menu2 {
    function initialize(){
        Menu2.initialize({:title=>"BookWave"});
        addItem(new WatchUi.MenuItem("Sync phone","Refresh current phone book",:sync,{}));
        addItem(new WatchUi.MenuItem("Watch audio","How to open offline books",:audio,{}));
        addItem(new WatchUi.MenuItem("Help",null,:help,{}));
    }
}
class CompanionMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize(){Menu2InputDelegate.initialize();}
    function onSelect(item){
        if(item.getId()==:sync){Application.getApp().syncPhone();WatchUi.popView(WatchUi.SLIDE_RIGHT);return;}
        var body=item.getId()==:audio?
            "Offline books on this watch\nHold DOWN (bottom left) to open Music.\nChoose Music providers > BookWave Audio.\nPlay downloaded: listen offline.\nDownload progress: resume unfinished books.":
            "Phone book\nStart or resume a book in BookWave. Open Companion, then Menu > Sync phone.\nBookWave's current account must be unlocked.\nUP/DOWN reads all text. BACK returns.\n"+BuildLabel.VALUE;
        var view=new CompanionHelp(body);WatchUi.pushView(view,new CompanionHelpDelegate(view),WatchUi.SLIDE_LEFT);
    }
    function onBack(){WatchUi.popView(WatchUi.SLIDE_RIGHT);}
}
class CompanionDelegate extends WatchUi.BehaviorDelegate {
    var view;
    function initialize(value){BehaviorDelegate.initialize();view=value;}
    function onNextPage(){return view.move(1);}
    function onPreviousPage(){return view.move(-1);}
    function onSelect(){return menu();}
    function onMenu(){return menu();}
    function menu(){WatchUi.pushView(new CompanionMenu(),new CompanionMenuDelegate(),WatchUi.SLIDE_LEFT);return true;}
}
