using Toybox.Lang;
// SET-002 / AUTH-002: provider-scoped Sidecar session, never an ABS/JWT fallback.
module ProviderPolicy {
    function text(value, maxLength) {
        return (value instanceof Lang.String) && value.length() > 0 && value.length() <= maxLength;
    }
    function validUrl(value) {
        if (!text(value,512) || value.length() <= 8 || !value.substring(0,8).equals("https://")) { return false; }
        var host=value.substring(8,value.length());
        var slash=host.find("/");
        if(slash!=null){host=host.substring(0,slash);}
        if(host.length()==0 || value.find("/../")!=null || value.find("/./")!=null || value.find("\\")!=null || value.find("\r")!=null || value.find("\t")!=null){return false;}
        return value.find("@") == null && value.find(" ") == null && value.find("\n") == null && value.find("?") == null && value.find("#") == null;
    }
    function code(value) {
        if(!text(value,6) || value.length()!=6){return false;}
        for(var i=0;i<6;i++){if("0123456789".find(value.substring(i,i+1))==null){return false;}}
        return true;
    }
    function setup(value) {
        return validUrl(value["url"]) && text(value["user"],128) && text(value["password"],256);
    }
    function validSession(value) {
        if (!text(value,36) || value.length() != 36) { return false; }
        for (var i=0;i<36;i++) {
            var c=value.substring(i,i+1);
            if (i==8 || i==13 || i==18 || i==23) { if (!c.equals("-")) { return false; } }
            else if ("0123456789abcdefABCDEF".find(c)==null) { return false; }
        }
        return true;
    }
    function envelope(raw) {
        return (raw instanceof Lang.Dictionary) && raw["v"]==1 && text(raw["t"],24) && text(raw["r"],64) && text(raw["p"],64);
    }
    function accepts(raw, profile, nonce) {
        return envelope(raw) && text(profile,64) && raw["p"].equals(profile) && text(raw["n"],64) && raw["n"].equals(nonce);
    }
}
