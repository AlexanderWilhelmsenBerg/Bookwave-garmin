using Toybox.Lang;
using Toybox.Application;

module ProviderDownloads {
    function unfinished(id) {
        var job=JobStore.get(id);var meta=job==null?BookStore.get(id):job;
        if(meta==null || !(meta["durs"] instanceof Lang.Array)){return false;}
        var first=job==null?BookStore.first(id):job["base"];
        if(first==null){first=0;}
        var total=Chunks.total(meta["durs"])-first;
        return total>0 && BookStore.count(id)<total;
    }
    function pendingIds() {
        var ids=JobStore.list();var out=[];
        for(var i=0;i<ids.size();i++){if(unfinished(ids[i])){out.add(ids[i]);}}
        var books=Application.Storage.getValue(Store.BOOK_INDEX);if(books==null){books=[];}
        for(var j=0;j<books.size();j++) {
            if(out.indexOf(books[j])<0 && unfinished(books[j])){out.add(books[j]);}
        }
        return out;
    }
    function percent(id) {
        var job=JobStore.get(id);var meta=job==null?BookStore.get(id):job;
        if(meta==null){return 0;}
        var first=job==null?BookStore.first(id):job["base"];if(first==null){first=0;}
        var total=Chunks.total(meta["durs"])-first;
        if(total<=0){return 0;}
        var result=(100.0*BookStore.count(id)/total).toNumber();return result>100?100:result;
    }

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
