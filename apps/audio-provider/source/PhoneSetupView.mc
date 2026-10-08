using Toybox.Graphics;
using Toybox.WatchUi;
module ProviderSetupState {
    var status="Open phone Settings > Playback > Devices. Pair, then Send setup. Keep this screen open.";
    function update(value){status=value;WatchUi.requestUpdate();}
    function error(code) {
        if(code.equals("ACCOUNT_MISMATCH")){return "Account differs from saved watch login. Use the same Sidecar URL and username. Do not reset unsynced books.";}
        if(code.equals("LOGIN_REJECTED")){return "Login rejected. Check username / password on phone; Send setup again.";}
        if(code.equals("CONTENT_TYPE")){return "Response type rejected. Check Sidecar URL / proxy; Send setup again.";}
        if(code.equals("INCOMPATIBLE_SIDECAR")){return "Sidecar response incompatible. Check /health and /login; update Sidecar.";}
        return "Sidecar did not respond. Check Garmin Connect and Sidecar access; Send setup again.";
    }
    function loginError(code) {
        if(code==401){return "LOGIN_REJECTED";}
        if(code==-1002){return "CONTENT_TYPE";}
        if(code==SidecarStatus.INVALID_RESPONSE){return "INCOMPATIBLE_SIDECAR";}
        return "SIDECAR_UNAVAILABLE";
    }
}
class PhoneSetupView extends WatchUi.View {
    var page=0; var pages=1; var message="";
    function initialize(){View.initialize();}
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);dc.clear();
        var value=ProviderSetupState.status;
        if(!message.equals(value)){page=0;message=value;}
        dc.drawText(dc.getWidth()/2,dc.getHeight()*12/100,Graphics.FONT_XTINY,"BOOKWAVE AUDIO",Graphics.TEXT_JUSTIFY_CENTER);
        pages=RoundText.draw(dc,value,page,"START: library | BACK");
        dc.drawText(dc.getWidth()/2,dc.getHeight()*85/100,Graphics.FONT_XTINY,BuildLabel.VALUE,Graphics.TEXT_JUSTIFY_CENTER);
    }
    function move(delta){page+=delta;if(page<0){page=0;}if(page>=pages){page=pages-1;}WatchUi.requestUpdate();return true;}
}
class PhoneSetupDelegate extends WatchUi.BehaviorDelegate {
    var view;
    function initialize(value){BehaviorDelegate.initialize();view=value;}
    function onNextPage(){return view.move(1);}
    function onPreviousPage(){return view.move(-1);}
    function onSelect(){
        if(AbsApi.isConfigured() && ProviderControl.setup==null){WatchUi.switchToView(new LibraryView(),new LibraryViewDelegate(),WatchUi.SLIDE_LEFT);}
        return true;
    }
    function onBack(){WatchUi.popView(WatchUi.SLIDE_RIGHT);return true;}
}
