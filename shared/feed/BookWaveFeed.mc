using Toybox.Application;
using Toybox.Complications;
using Toybox.Lang;
using Toybox.Time;

// One atomic value, not four partially updated complications. No profile/book/credential identity.
// Stable id 0. Fields: version|source|observedAtMs|eventAtMs(-1 unknown)|state|posMs|durMs|privacy|title|chapter.
module BookWaveFeed {
    const KEY="bookwave.faceFeed.v1";
    function bounded(value,max) {
        if(!(value instanceof Lang.String)){return "";}
        return value.length()>max ? value.substring(0,max) : value;
    }
    function escape(value) {
        var out="";
        for(var i=0;i<value.length();i++) {
            var c=value.substring(i,i+1);
            out += c.equals("%")?"%25":(c.equals("|")?"%7C":(c.equals("\n")?"%0A":(c.equals("\r")?"%0D":c)));
        }
        return out;
    }
    function encode(source,title,chapter,pos,dur,observed,event,state,privacy) {
        if(!privacy.equals("authorized")) {title="";chapter="";pos=0;dur=0;event=-1;state="unknown";}
        if(pos<0){pos=0;} if(dur<0){dur=0;} if(dur>0 && pos>dur){pos=dur;}
        return "1|"+source+"|"+observed.toString()+"|"+event.toString()+"|"+state+"|"+
            pos.toString()+"|"+dur.toString()+"|"+privacy+"|"+escape(bounded(title,80))+"|"+escape(bounded(chapter,80));
    }
    function publish(value) {
        // A failed durable save cannot publish success. Always overwrite ALL runtime fields.
        try {
            Application.Storage.setValue(KEY,value);
            Complications.updateComplication(0,{:value=>value,:shortLabel=>"BookWave",:unit=>Toybox.Complications.UNIT_INVALID});
            return true;
        } catch(ex){return false;}
    }
    function clear(source) {
        var value=encode(source,"","",0,0,Time.now().value().toLong()*1000l,-1,"unknown","redacted");
        // Privacy clears must reach the runtime even if persistence is unavailable.
        var success=true;
        try { Complications.updateComplication(0,{:value=>value,:shortLabel=>"BookWave",:unit=>Toybox.Complications.UNIT_INVALID}); } catch(ex){success=false;}
        try { Application.Storage.setValue(KEY,value); } catch(ex){success=false;}
        return success;
    }
    function phone(snapshot,live) {
        if(snapshot==null){return clear("PHONE");}
        return publish(encode("PHONE",snapshot["title"],snapshot["chapterTitle"],snapshot["positionMs"],snapshot["durationMs"]==null?0:snapshot["durationMs"],
            snapshot["updatedAt"],-1,live?(snapshot["playing"]?"playing":"paused"):"unknown","authorized"));
    }
}
