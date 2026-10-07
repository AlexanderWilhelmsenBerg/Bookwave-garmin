using Toybox.Test;

(:test)
class NoBlindWriteSync extends ProgressSync {
    var attemptedPush=false;
    function initialize(){ProgressSync.initialize();}
    function bookDuration(itemId){attemptedPush=true;return null;}
}

(:test)
function failedPullNeverAttemptsBlindProgressPush(logger) {
    Progress.record("read-failure",10,10,false);
    var sync=new NoBlindWriteSync();
    sync.onPullDone(500,null);
    Test.assert(!sync.succeeded);
    Test.assert(!sync.attemptedPush);
    Test.assert(Progress.dirtyIds().size()>0);
    Progress.markClean("read-failure",10,10,false);
    return true;
}
