using Toybox.Graphics;
using Toybox.WatchUi;
class CompanionView extends WatchUi.View {
    var _connection="Stored; waiting for phone";
    var _snapshot;var _loadStatus;var _loadError;var page=0;var pages=1;
    function initialize(snapshot,status,error) {View.initialize();_snapshot=snapshot;_loadStatus=status;_loadError=error;}
    function setConnection(value){_connection=value;}
    function setSnapshot(value,status){
        if(value==null || _snapshot==null || !value.bookId.equals(_snapshot.bookId) || !value.profileId.equals(_snapshot.profileId)){page=0;}
        _snapshot=value;_loadStatus=status;_loadError=null;
    }
    function document() {
        var connection=_connection.equals("Stored; waiting for phone")?"Waiting for phone":_connection;
        if(_loadStatus==SnapshotStoreState.LOAD_INVALID) {
            return "Saved state unavailable\nOpen BookWave on phone.\nSettings > Force sync.\n"+connection+(_loadError==null?"":"\n"+_loadError);
        }
        if(_snapshot==null){
            var waiting=_connection.equals("Stored; waiting for phone")?"Waiting for sync":connection;
            return "No phone book\nStart or resume a book in BookWave.\nMenu > Sync phone\nOr phone Settings > Force sync.\n"+waiting;
        }
        // Preserve full metadata. Measured pages replace all old character limits and ellipses.
        return _snapshot.title+"\n"+PlaybackFormat.author(_snapshot)+"\n"+PlaybackFormat.chapter(_snapshot)+
            "\n"+PlaybackFormat.progress(_snapshot)+"\n"+(_snapshot.playing?"Playing on phone":"Paused on phone")+
            "\n"+connection+"\n"+PlaybackFormat.recency(_snapshot);
    }
    function onUpdate(dc) {
        var status=_snapshot==null?"PHONE BOOK":(_snapshot.playing?"PHONE / PLAYING":"PHONE / PAUSED");
        pages=WatchTheme.companion(dc,document(),page,status,"Menu");
        if(page>=pages){page=pages-1;}
    }
    function move(delta){page+=delta;if(page<0){page=0;}if(page>=pages){page=pages-1;}WatchUi.requestUpdate();return true;}
}
