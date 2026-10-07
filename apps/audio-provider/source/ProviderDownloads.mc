using Toybox.Lang;

module ProviderDownloads {
    // An already cached matching normal-speed suffix may satisfy a duplicate request.
    function storedFor(id,data) {
        var meta=BookStore.get(id);
        if(meta==null || !(meta["durs"] instanceof Lang.Array) || !SidecarCodec.files(data)){return false;}
        if(BookStore.activeSpeed(id)!=PlaybackSpeed.NORMAL){return false;}
        var durs=meta["durs"];var files=data["files"];
        if(durs.size()!=files.size()){return false;}
        for(var i=0;i<durs.size();i++) {
            if(durs[i].toNumber()!=files[i]["duration"].toNumber()){return false;}
        }
        var progress=Progress.get(id);
        var required=(progress==null || Progress.entryFinished(progress))?0:Chunks.indexAt(durs,progress[0]);
        var first=BookStore.first(id);
        var expected=Chunks.total(durs)-first;
        return first<=required && expected>0 && BookStore.count(id)>=expected;
    }
}
