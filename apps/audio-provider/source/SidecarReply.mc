using Toybox.Lang;
using Toybox.PersistedContent;
class SidecarReply {
    var kind;
    var callback;
    function initialize(type,cb){kind=type;callback=cb;}
    function receive(code as Lang.Number,data as Null or Lang.Dictionary or Lang.String or PersistedContent.Iterator) as Void {
        if(code==200 && !SidecarCodec.accepts(kind,data)){callback.invoke(SidecarStatus.INVALID_RESPONSE,{"field"=>SidecarCodec.failure(kind,data),"reason"=>SidecarCodec.reason(kind,data)});return;}
        callback.invoke(code,data);
    }
}

// App schema failure, deliberately outside Garmin Communications error codes.
module SidecarStatus { const INVALID_RESPONSE=-20001; }
