using Toybox.Application;
using Toybox.Test;

(:test)
function nativeRequestPersistsUntilItsOwnTerminalResult(logger) {
    Application.Storage.setValue(ProviderSyncRequest.KEY,"request-one");
    var captured=ProviderSyncRequest.current();
    Test.assertEqual(ProviderSyncRequest.current(),"request-one");
    Application.Storage.setValue(ProviderSyncRequest.KEY,"request-two");
    ProviderSyncRequest.complete(captured,true);
    Test.assertEqual(ProviderSyncRequest.current(),"request-two");
    ProviderSyncRequest.complete("request-two",false);
    Test.assertEqual(ProviderSyncRequest.current(),null);
    Test.assertEqual(Application.Storage.getValue("bookwave.completedSyncRequest.v1"),"request-one");
    Test.assertEqual(Application.Storage.getValue("bookwave.failedSyncRequest.v1"),"request-two");
    Application.Storage.deleteValue("bookwave.completedSyncRequest.v1");
    Application.Storage.deleteValue("bookwave.failedSyncRequest.v1");
    return true;
}
