using Toybox.Application;
using Toybox.Lang;
using Toybox.Time;

// One storage value per event: pending history is never discarded to fit a single 32KB array.
// Allocate sequence before writing; a failed write leaves a gap, not a reused delivered identity.
module ProviderJournal {
    const NEXT = "bookwave.eventNext.v2";
    const HEAD = "bookwave.eventHead.v2";
    const GAP = "bookwave.eventGap.v2";
    var lastCheckpoint = null;
    function key(n) { return "bookwave.event.v2."+n.toString(); }
    function next() { var n=Application.Storage.getValue(NEXT); return (n instanceof Lang.Number)?n:0; }
    function head() { var n=Application.Storage.getValue(HEAD); return (n instanceof Lang.Number)?n:1; }
    function events() {
        var rows=[];
        for(var n=head();n<=next() && rows.size()<5;n++) {
            var row=Application.Storage.getValue(key(n));
            if(row instanceof Lang.Dictionary){rows.add(row);}
        }
        return rows;
    }
    function record(item, position, duration, kind, finished) {
        if(ProviderControl.profile()==null){return;}
        var at=Time.now().value();
        if(kind.equals("checkpoint") && lastCheckpoint!=null && lastCheckpoint[0].equals(item) &&
            at>=lastCheckpoint[1] && at-lastCheckpoint[1]<60){return;}
        var n=next()+1;
        try {
            Application.Storage.setValue(NEXT,n);
            Application.Storage.setValue(key(n),{"id"=>n.toString(),"p"=>ProviderControl.profile(),"b"=>item,
                "pos"=>position.toNumber(),"dur"=>(duration==null)?0:duration.toNumber(),
                "at"=>at,"k"=>kind,"finished"=>finished==true});
            if(kind.equals("checkpoint")){lastCheckpoint=[item,at];}else{lastCheckpoint=null;}
        } catch(ex) {
            // Resume progress was persisted first by ContentDelegate. Expose history loss explicitly.
            try { Application.Storage.setValue(GAP,true); } catch(ignored) {}
        }
    }
    function acknowledge(ids) {
        if(!(ids instanceof Lang.Array) || ids.size()>10){return false;}
        var rows=events(); var accepted=0;
        // Only a contiguous reported prefix may be acknowledged, after durable Android import.
        for(var i=0;i<rows.size();i++) {
            if(i>=ids.size() || !ProviderPolicy.text(ids[i],64) || !rows[i]["id"].equals(ids[i])){break;}
            accepted++;
        }
        if(accepted!=ids.size()){return false;}
        if(accepted==0){return true;}
        var old=head(); var end=rows[accepted-1]["id"].toNumber();
        Application.Storage.setValue(HEAD,end+1);
        for(var n=old;n<=end;n++){Application.Storage.deleteValue(key(n));}
        return true;
    }
}
