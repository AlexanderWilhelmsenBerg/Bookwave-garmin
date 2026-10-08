using Toybox.Graphics;
using Toybox.WatchUi;
class CompanionHelp extends WatchUi.View {
    var page=0; var pages=1;
    function initialize(){View.initialize();}
    function onUpdate(dc){
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);dc.clear();
        pages=RoundText.draw(dc,"Companion displays phone playback. Open BookWave on phone; use Force sync. For offline books, open BookWave Audio in watch music providers, then Browse library. UP/DOWN: pages. BACK: return.\n"+BuildLabel.VALUE,page,"BACK: return");
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
    function initialize(){BehaviorDelegate.initialize();}
    function onSelect(){return help();}
    function onMenu(){return help();}
    function help(){var view=new CompanionHelp();WatchUi.pushView(view,new CompanionHelpDelegate(view),WatchUi.SLIDE_LEFT);return true;}
}
