using Toybox.Lang;
// Contract: WatchShelf 93ac7507 /files response. Unknown fields are harmless.
module SidecarCodec {
    // Only fixed schema names leave this boundary; never include response values.
    function failure(kind,value) {
        if(accepts(kind,value)){return null;}
        if(!(value instanceof Lang.Dictionary)){return "response";}
        if(!kind.equals("files")){return kind+".response";}
        if(!ProviderPolicy.text(value["title"],512)){return "title";}
        if(!(value["files"] instanceof Lang.Array) || value["files"].size()==0 || value["files"].size()>JobStore.MAX_FILES){return "files";}
        for(var i=0;i<value["files"].size();i++) {
            var file=value["files"][i];
            if(!(file instanceof Lang.Dictionary)){return "files.entry";}
            if(!ProviderPolicy.text(file["ino"],128)){return "files.ino";}
            if(!duration(file["duration"])){return "files.duration";}
        }
        return "files.response";
    }
    function accepts(kind,value) {
        if(!(value instanceof Lang.Dictionary)){return false;}
        if(kind.equals("files")){return files(value) || value["tooManyFiles"]==true;}
        if(kind.equals("progress")){return progress(value);}
        if(kind.equals("write")){return value["ok"]==true;}
        if(kind.equals("login")){return (value["user"] instanceof Lang.Dictionary) && ProviderPolicy.validSession(value["user"]["token"]);}
        var key=kind.equals("list") || kind.equals("continue") ? "books" : kind;
        var rows=value[key];
        if(!(rows instanceof Lang.Array)){return false;}
        for(var i=0;i<rows.size();i++) {
            var row=rows[i];
            if(!(row instanceof Lang.Dictionary) || !ProviderPolicy.text(row["id"],128)){return false;}
            if(key.equals("books")) {
                if(!ProviderPolicy.text(row["title"],512) || !(row["author"] instanceof Lang.String)){return false;}
            } else if(!ProviderPolicy.text(row["name"],512)){return false;}
            if((key.equals("authors") || key.equals("series")) && (!(row["count"] instanceof Lang.Number) || row["count"]<0)){return false;}
        }
        return true;
    }
    function numeric(value) {
        return (value instanceof Lang.Number) || (value instanceof Lang.Long) ||
            (value instanceof Lang.Float) || (value instanceof Lang.Double);
    }
    // Bound arithmetic/chunk work as well as rejecting NaN/infinity and non-positive audio.
    function duration(value) {return numeric(value) && value>0 && value<=31536000;}
    function durationIssue(value) {
        if(value==null){return "Missing duration";}
        if(!numeric(value)){return "Expected numeric seconds";}
        if(value<=0){return "Duration must be positive";}
        return "Duration outside supported range";
    }
    function reason(kind,value) {
        if(!kind.equals("files") || !(value instanceof Lang.Dictionary) || !(value["files"] instanceof Lang.Array)){return null;}
        for(var i=0;i<value["files"].size();i++) {
            var file=value["files"][i];
            if(file instanceof Lang.Dictionary && !duration(file["duration"])){return durationIssue(file["duration"]);}
        }
        return null;
    }
    function progress(value) {
        if(!(value instanceof Lang.Dictionary)){return false;}
        if(value.size()==0){return true;} // Legitimate no-progress response.
        return numeric(value["currentTime"]) && value["currentTime"]>=0 &&
            numeric(value["duration"]) && value["duration"]>=0 &&
            ((value["lastUpdate"] instanceof Lang.Number) || (value["lastUpdate"] instanceof Lang.Long)) && value["lastUpdate"]>=0 &&
            (value["isFinished"] instanceof Lang.Boolean);
    }
    function files(value) {
        if(!(value instanceof Lang.Dictionary) || !ProviderPolicy.text(value["title"],512) ||
            !(value["files"] instanceof Lang.Array) || value["files"].size()==0 ||
            value["files"].size()>JobStore.MAX_FILES || value["tooManyFiles"]==true){return false;}
        for(var i=0;i<value["files"].size();i++) {
            var file=value["files"][i];
            if(!(file instanceof Lang.Dictionary) || !ProviderPolicy.text(file["ino"],128) ||
                !duration(file["duration"])){return false;}
        }
        return true;
    }
}
