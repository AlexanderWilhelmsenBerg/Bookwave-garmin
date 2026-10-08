using Toybox.Application;
using Toybox.Communications;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi;

class ProviderSendListener extends Communications.ConnectionListener {
    function initialize() { ConnectionListener.initialize(); }
    function onComplete() as Void {}
    function onError() as Void {} // A later request retries; no private error text.
}

// SET-002 / DL-001/003. One profile binding; foreign profiles get no inventory/events.
module ProviderControl {
    const PAIR = "bookwave.providerPair.v1";
    const REDACTED = "bookwave.providerRedacted.v1";
    var nonce = null;
    var running = false;
    var download = null;
    var pendingPair = null;
    var pairAt = 0;
    var pairMenuShowing = false;
    var setup = null;
    var receiver = new ProviderReceiver();
    function profile() { return Application.Storage.getValue(PAIR); }
    function start() {
        nonce="provider-"+Time.now().value().toString()+"-"+System.getTimer().toString();
        running=true;
        try { Communications.registerForPhoneAppMessages(receiver.method(:receive)); }
        catch(ex) { running=false; }
        announce("ready");
    }
    function stop() {
        announce("sleeping");
        running=false; pendingPair=null; pairMenuShowing=false;
        if(setup!=null){setup.cancel();setup=null;ProviderSetupState.status="Setup interrupted. Open phone setup and Send setup again.";}
        try { Communications.registerForPhoneAppMessages(null); } catch(ex) {}
    }
    function announce(type) {
        if(!running){return;}
        try {Communications.transmit({"v"=>1,"t"=>type,"n"=>nonce,"p"=>profile()},{},new ProviderSendListener());} catch(ex) {}
    }
    function clearPair() {
        // Keep the account anchor: retained media/events must never be rebound to another profile.
        Application.Storage.setValue(REDACTED,true);
        BookWaveFeed.clear("GARMIN");
        pendingPair=null;
        if(setup!=null){setup.cancel();}
    }
    function reply(command,type,fields) {
        if(!running){return;}
        var out={"v"=>1,"t"=>type,"r"=>command["r"],"p"=>command["p"],"n"=>nonce};
        var keys=fields.keys();
        for(var i=0;i<keys.size();i++){out[keys[i]]=fields[keys[i]];}
        try { Communications.transmit(out,{},new ProviderSendListener()); } catch(ex) {}
    }
    function error(command,code) { reply(command,"result",{"ok"=>false,"error"=>code}); }
    function receive(message as Communications.PhoneAppMessage) as Void {
        var command=message.data;
        if(!running || !ProviderPolicy.envelope(command)){return;}
        var type=command["t"];
        if(type.equals("hello")) {
            var same=ProviderPolicy.text(profile(),64) && profile().equals(command["p"]);
            reply(command,"hello",{"configured"=>AbsApi.isConfigured(),"paired"=>same,"pairing"=>pairing(command["p"]),
                "caps"=>["setup","cancel_pair","pair","authorize","download","inventory","events","ack_events","sync","redact"]});
            return;
        }
        if(!ProviderPolicy.text(command["n"],64) || !command["n"].equals(nonce)){return;}
        if(type.equals("pair")) { requestPair(command); return; }
        if(type.equals("cancel_pair")) {
            if(pendingPair!=null && pendingPair["p"].equals(command["p"])){pendingPair=null;}
            reply(command,"result",{"ok"=>true});return;
        }
        if(!ProviderPolicy.accepts(command,profile(),nonce)){error(command,"PROFILE_MISMATCH");return;}
        if(type.equals("redact")) {
            Application.Storage.setValue(REDACTED,true);
            if(setup!=null){setup.cancel();}
        BookWaveFeed.clear("GARMIN");
            reply(command,"result",{"ok"=>true}); return;
        }
        if(type.equals("authorize")) {
            Application.Storage.setValue(REDACTED,false);
            reply(command,"result",{"ok"=>true}); return;
        }
        if(Application.Storage.getValue(REDACTED)==true){error(command,"REDACTED");return;}
        if(type.equals("setup")) {
            if(!ProviderPolicy.setup(command)){error(command,"INVALID_SETUP");return;}
            if(setup!=null){error(command,"BUSY");return;}
            setup=new ProviderSetupRequest(command);setup.begin();return;
        }
        if(type.equals("inventory")){inventory(command);return;}
        if(type.equals("events")){events(command);return;}
        if(type.equals("ack_events")) {
            reply(command,"result",{"ok"=>ProviderJournal.acknowledge(command["ids"])});return;
        }
        if(type.equals("sync")) {
            Application.Storage.setValue("bookwave.syncRequest.v1",command["r"]);
            Application.Storage.setValue(Store.FORCE_SYNC,true);
            reply(command,"result",{"ok"=>true,"state"=>"queued"});
            try { Communications.startSync(); }
            catch(ex) { Application.Storage.setValue("bookwave.failedSyncRequest.v1",command["r"]); }
            return;
        }
        if(type.equals("download")){queue(command);return;}
        error(command,"UNSUPPORTED");
    }
    function requestPair(command) {
        if(ProviderPolicy.text(profile(),64)) {
            if(profile().equals(command["p"])) {
                Application.Storage.setValue(REDACTED,false);
                reply(command,"result",{"ok"=>true});
            } else {error(command,"PROFILE_MISMATCH");}
            return;
        }
        var books=Application.Storage.getValue(Store.BOOK_INDEX);
        // Do not relabel another account's retained cache/journal as the new phone profile.
        if((books!=null && books.size()>0) || JobStore.list().size()>0 || ProviderJournal.events().size()>0) {
            error(command,"RESET_REQUIRED");return;
        }
        if(pendingPair!=null && !pendingPair["p"].equals(command["p"]) && pairing(pendingPair["p"])) {error(command,"PAIR_PENDING");return;}
        if(!ProviderPolicy.code(command["code"])){error(command,"INVALID_COMMAND");return;}
        pendingPair=command;
        pairAt=Time.now().value();
        var menu=new WatchUi.Menu2({:title=>"BookWave " + command["code"]});
        menu.addItem(new WatchUi.MenuItem("Accept " + command["code"],"Code matches phone?",:accept,{}));
        menu.addItem(new WatchUi.MenuItem("Cancel",null,:cancel,{}));
        var delegate=new ProviderPairDelegate(command["r"]);
        if(pairMenuShowing){WatchUi.switchToView(menu,delegate,WatchUi.SLIDE_IMMEDIATE);}
        else {WatchUi.pushView(menu,delegate,WatchUi.SLIDE_LEFT);}
        pairMenuShowing=true;
        reply(command,"result",{"ok"=>false,"error"=>"CONFIRM_ON_WATCH"});
    }
    function pairing(owner) {
        return pendingPair!=null && pendingPair["p"].equals(owner) && Time.now().value()-pairAt<120;
    }
    function confirmPair(yes,request) {
        if(pendingPair==null || !pendingPair["r"].equals(request)){return;}
        var valid=pairing(pendingPair["p"]);
        var command=pendingPair; pendingPair=null;
        if(!valid){error(command,"PAIR_EXPIRED");return;}
        if(!yes){error(command,"PAIR_CANCELLED");return;}
        try {
            Application.Storage.setValue(PAIR,command["p"]);
            Application.Storage.setValue(REDACTED,false);
            reply(command,"result",{"ok"=>true});
            announce("ready");
        } catch(ex){error(command,"STORE_FAILED");}
    }
    function failedBook(id) {
        var failed=Application.Storage.getValue("bookwave.failedBook.v1");
        return ProviderPolicy.text(failed,128) && failed.equals(id);
    }
    function inventory(command) {
        var all=[];
        var books=Application.Storage.getValue(Store.BOOK_INDEX);
        if(books==null){books=[];}
        for(var i=0;i<books.size();i++){all.add(books[i]);}
        var jobs=JobStore.list();
        for(var j=0;j<jobs.size();j++) {
            var found=false;
            for(var k=0;k<all.size();k++){if(all[k].equals(jobs[j])){found=true;}}
            if(!found){all.add(jobs[j]);}
        }
        var offset=command["offset"];
        if(!(offset instanceof Lang.Number) || offset<0 || offset>all.size()){error(command,"INVALID_COMMAND");return;}
        var rows=[];
        if(offset<all.size()) {
            var id=all[offset]; var job=JobStore.get(id); var meta=BookStore.get(id);
            if(meta==null){meta=job;}
            var total=0;
            if(meta!=null && (meta["durs"] instanceof Lang.Array)){total=Chunks.total(meta["durs"]);}
            var count=BookStore.count(id); var first=BookStore.first(id);
            if(BookStore.get(id)==null && job!=null && job["base"]!=null){first=job["base"];}
            var from=0;
            if(meta!=null && (meta["durs"] instanceof Lang.Array)) {
                var part=Chunks.at(meta["durs"],first);
                if(part!=null){from=part["start"].toNumber();}
            }
            total=total-first; if(total<0){total=0;}
            var state=(job!=null)?"queued":((count>0 && total>0 && count>=total)?"downloaded":"partial");
            var row={"b"=>id,"title"=>(meta==null)?"Book":meta["title"],"state"=>((job==null && failedBook(id))?"failed":state),
                "done"=>count,"total"=>total,"from"=>from};
            var progress=Progress.get(id);
            if(progress!=null){row["pos"]=progress[0].toNumber();row["at"]=progress[1];}
            rows.add(row);
        }
        reply(command,"inventory",{"offset"=>offset,"rows"=>rows,"more"=>offset+rows.size()<all.size(),
            "at"=>Time.now().value(),"synced"=>Application.Storage.getValue("bookwave.lastSync.v1"),"syncRequest"=>Application.Storage.getValue("bookwave.completedSyncRequest.v1"),"failedSync"=>Application.Storage.getValue("bookwave.failedSyncRequest.v1")});
    }
    function events(command) {
        // One page is re-read until Android durably imports and acknowledges it.
        var all=ProviderJournal.events(); var page=[];
        for(var i=0;i<all.size() && i<5;i++){page.add(all[i]);}
        reply(command,"events",{"rows"=>page,"more"=>page.size()==5,"gap"=>Application.Storage.getValue(ProviderJournal.GAP)==true,"at"=>Time.now().value()});
    }
    function queue(command) {
        if(!ProviderPolicy.text(command["b"],128)){error(command,"INVALID_COMMAND");return;}
        if(!AbsApi.isConfigured()){error(command,"NOT_CONFIGURED");return;}
        var id=command["b"];
        if(JobStore.get(id)!=null) {
            reply(command,"result",{"ok"=>true,"state"=>(JobStore.get(id)!=null)?"queued":"stored"});return;
        }
        if(download!=null){error(command,"BUSY");return;}
        download=new ProviderDownloadRequest(command);
        download.begin();
    }
}

class ProviderPairDelegate extends WatchUi.Menu2InputDelegate {
    var request;
    function initialize(id){Menu2InputDelegate.initialize();request=id;}
    function onSelect(item){
        ProviderControl.confirmPair(item.getId()==:accept,request);
        ProviderControl.pairMenuShowing=false;
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
    function onBack(){
        ProviderControl.confirmPair(false,request);
        ProviderControl.pairMenuShowing=false;
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

// AUTH-001/003: explicit one-time provider setup, separate from Companion state.
// Only the opaque Sidecar session survives. HTTP callbacks cannot commit after stop/profile change.
class ProviderSetupRequest {
    var command;
    var password;
    function initialize(raw) {
        command={"v"=>raw["v"],"t"=>raw["t"],"r"=>raw["r"],"p"=>raw["p"],"n"=>raw["n"],"url"=>raw["url"],"user"=>raw["user"]};
        password=raw["password"];
    }
    function cancel(){password=null;if(ProviderControl.setup==self){ProviderControl.setup=null;}}
    function active(){return ProviderControl.setup==self && ProviderControl.running && ProviderPolicy.accepts(command,ProviderControl.profile(),ProviderControl.nonce) && Application.Storage.getValue(ProviderControl.REDACTED)!=true;}
    function begin(){
        if(!AbsApi.sameAccount(command["url"],command["user"])) {finish("ACCOUNT_MISMATCH");return;}
        ProviderSetupState.update("Checking Sidecar /health...");
        AbsApi.checkHealth(command["url"],method(:health));
    }
    function health(code,data){
        if(!active()){cancel();return;}
        if(code!=200 || !(data instanceof Lang.String) || !data.equals("ok")){finish(code==200?"INCOMPATIBLE_SIDECAR":ProviderSetupState.loginError(code));return;}
        ProviderSetupState.update("Signing in to Sidecar...");
        var secret=password;password=null;
        AbsApi.login(command["url"],command["user"],secret,method(:loggedIn));
    }
    function loggedIn(code,data){
        if(!active()){cancel();return;}
        if(code==200 && (data instanceof Lang.Dictionary) && (data["user"] instanceof Lang.Dictionary) && AbsApi.saveLogin(command["url"],data["user"]["token"],command["user"])) {
            cancel();ProviderControl.setup=null;
            ProviderSetupState.update("Sidecar configured. START: open library.");
            ProviderControl.reply(command,"result",{"ok"=>true});
            ProviderControl.announce("ready");return;
        }
        finish(ProviderSetupState.loginError(code));
    }
    function finish(error){cancel();ProviderControl.setup=null;ProviderSetupState.update(ProviderSetupState.error(error));ProviderControl.error(command,error);}
}

class ProviderDownloadRequest extends BookMenuDelegate {
    var command;
    function initialize(value){BookMenuDelegate.initialize();command=value;}
    function begin(){AbsApi.getFiles(command["b"],method(:receivedFiles));}
    function receivedFiles(code,data) {
        ProviderControl.download=null;
        if(!ProviderPolicy.accepts(command,ProviderControl.profile(),ProviderControl.nonce) ||
            Application.Storage.getValue(ProviderControl.REDACTED)==true){return;}
        if(code!=200){ProviderControl.error(command,code==401?"REAUTH_REQUIRED":"SOURCE_UNAVAILABLE");return;}
        if(!SidecarCodec.files(data)){ProviderControl.error(command,"INCOMPATIBLE_SIDECAR");return;}
        try {
            onFiles(command["b"],PlaybackSpeed.NORMAL,code,data);
            var stored=JobStore.get(command["b"]);
            if(stored!=null){
                if(ProviderControl.failedBook(command["b"])){Application.Storage.deleteValue("bookwave.failedBook.v1");}
                ProviderControl.reply(command,"result",{"ok"=>true,"state"=>"queued"});}
            else if(ProviderDownloads.storedFor(command["b"],data)) {
                ProviderControl.reply(command,"result",{"ok"=>true,"state"=>"stored"});
            } else {ProviderControl.error(command,"QUEUE_REJECTED");}
        } catch(ex){ProviderControl.error(command,"STORE_FAILED");}
    }
}

class ProviderReceiver {
    function initialize() {}
    function receive(message as Communications.PhoneAppMessage) as Void { ProviderControl.receive(message); }
}
