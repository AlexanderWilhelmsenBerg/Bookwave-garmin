using Toybox.WatchUi;
class DownloadProgressMenu extends WatchUi.Menu2 {
    function initialize(){
        Menu2.initialize({:title=>"Download progress"});
        var ids=ProviderDownloads.pendingIds();
        for(var i=0;i<ids.size();i++) {
            var meta=JobStore.get(ids[i]);if(meta==null){meta=BookStore.get(ids[i]);}
            addItem(new WatchUi.MenuItem(meta["title"],ProviderDownloads.percent(ids[i])+"% / Resume download",ids[i],{}));
        }
    }
}
class DownloadProgressDelegate extends WatchUi.Menu2InputDelegate {
    function initialize(){Menu2InputDelegate.initialize();}
    function onSelect(item){
        var id=item.getId();if(!ProviderDownloads.unfinished(id)){return;}
        if(JobStore.get(id)!=null){ProviderSyncRequest.start();}
        else {new BookMenuDelegate().downloadAtSpeed(id,BookStore.activeSpeed(id));}
    }
    function onBack(){WatchUi.popView(WatchUi.SLIDE_RIGHT);}
}
