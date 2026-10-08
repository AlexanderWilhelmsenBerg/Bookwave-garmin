using Toybox.Graphics;
using Toybox.WatchUi;
class CompanionHelp extends WatchUi.View {
    var page=0; var pages=1;
    function initialize(){View.initialize();}
    function onUpdate(dc){
        WatchTheme.frame(dc,"Help","","Back",true);WatchTheme.headphones(dc);
        pages=WatchTheme.page(dc,"Phone playback\nOpen BookWave on phone. In Settings, choose Devices > Force sync.\nOffline books\nOn the watch, open Music > Music providers > BookWave Audio > Browse library.\nUP/DOWN: pages. BACK: return.\n"+BuildLabel.VALUE,page,"BOOKWAVE HELP","Back");
    }
    function move(delta){page+=delta;if(page<0){page=0;}if(page>=pages){page=pages-1;}WatchUi.requestUpdate();return true;}
}
class CompanionHelpDelegate extends WatchUi.BehaviorDelegate {
    var view;
    function initialize(value){BehaviorDelegate.initialize();view=value;}
    function onNextPage(){return view.move(1);}
    function onPreviousPage(){return view.move(-1);}
    function onBack(){WatchUi.popView(WatchUi.SLIDE_RIGHT);return true;}
}
class CompanionDelegate extends WatchUi.BehaviorDelegate {
    var view;
    function initialize(value){BehaviorDelegate.initialize();view=value;}
    function onNextPage(){return view.move(1);}
    function onPreviousPage(){return view.move(-1);}
    function onSelect(){return help();}
    function onMenu(){return help();}
    function help(){var view=new CompanionHelp();WatchUi.pushView(view,new CompanionHelpDelegate(view),WatchUi.SLIDE_LEFT);return true;}
}
