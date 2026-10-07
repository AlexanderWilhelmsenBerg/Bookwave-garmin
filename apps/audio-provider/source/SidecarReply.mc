using Toybox.Lang;
using Toybox.PersistedContent;
class SidecarReply {
    var kind;
    var callback;
    function initialize(type,cb){kind=type;callback=cb;}
    function receive(code as Lang.Number,data as Null or Lang.Dictionary or Lang.String or PersistedContent.Iterator) as Void {
        if(code==200 && !SidecarCodec.accepts(kind,data)){callback.invoke(-1002,null);return;}
        callback.invoke(code,data);
    }
}
