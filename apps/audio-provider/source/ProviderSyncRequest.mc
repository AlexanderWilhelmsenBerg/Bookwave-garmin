using Toybox.Application;
using Toybox.Communications;

// A claimed native sync request survives stop/process loss until an actual terminal outcome.
module ProviderSyncRequest {
    var active=false;
    function start(){if(!active){Communications.startSync();}}
    const KEY="bookwave.syncRequest.v1";
    function current(){return Application.Storage.getValue(KEY);}
    function complete(id,success) {
        if(!ProviderPolicy.text(id,64)){return;}
        Application.Storage.setValue(success?"bookwave.completedSyncRequest.v1":"bookwave.failedSyncRequest.v1",id);
        var pending=current();
        if(ProviderPolicy.text(pending,64) && pending.equals(id)){Application.Storage.deleteValue(KEY);}
    }
}
