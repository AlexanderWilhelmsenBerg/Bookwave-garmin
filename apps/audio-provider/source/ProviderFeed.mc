using Toybox.Application;
using Toybox.Time;
module ProviderFeed {
    var latest=null;
    function publish(item,pos,dur,state,event) {
        if(ProviderControl.profile()==null || Application.Storage.getValue(ProviderControl.REDACTED)==true){BookWaveFeed.clear("GARMIN");return;}
        var meta=BookStore.get(item);
        if(meta==null){BookWaveFeed.clear("GARMIN");return;}
        var now=Time.now().value().toLong()*1000l;
        latest=[item,pos,dur,event];
        BookWaveFeed.publish(BookWaveFeed.encode("GARMIN",meta["title"],"",pos.toLong()*1000l,
            dur==null?0:dur.toLong()*1000l,now,event==null?-1:event.toLong()*1000l,state,"authorized"));
    }
    function stopped() {
        if(latest!=null){publish(latest[0],latest[1],latest[2],"unknown",latest[3]);}
    }
}
