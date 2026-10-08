using Toybox.Test;
(:test)
function companionPresentationPreservesLongMetadataAndSeparatesOfflineHelp(logger) {
    var values={"title"=>"A very long fixture title with information at the very end",
        "author"=>"A long fixture author ending in a surname",
        "chapterTitle"=>"A long chapter title with its final words intact",
        "positionMs"=>1000l,"durationMs"=>10000l,"updatedAt"=>1000l,"playing"=>false};
    var view=new CompanionView(new PlaybackSnapshot(values),SnapshotStoreState.LOAD_VALID,null);
    var body=view.document();
    Test.assert(body.find(values["title"])!=null);
    Test.assert(body.find(values["author"])!=null);
    Test.assert(body.find(values["chapterTitle"])!=null);
    Test.assert(body.find("Paused on phone")!=null);
    Test.assert(body.find("Waiting for phone")!=null);
    var empty=new CompanionView(null,SnapshotStoreState.LOAD_NEVER_SYNCED,null);
    Test.assert(empty.document().find("Force sync")!=null);
    Test.assert(empty.document().find("Waiting for sync")!=null);
    Test.assert(empty.document().find("…")==null);
    return true;
}
