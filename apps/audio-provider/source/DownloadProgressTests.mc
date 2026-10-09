using Toybox.Application;
using Toybox.Test;
(:test)
function incompleteJobReportsStoredPartsAndRetainsResumeCursor(logger) {
    var id="resume-fixture";
    var job={"inos"=>[1],"durs"=>[400],"title"=>"Fixture book","author"=>"Fixture", "speed"=>100,"base"=>0,"done"=>1,"gen"=>1};
    JobStore.put(id,job);
    Test.assert(ProviderDownloads.unfinished(id));
    Test.assert(ProviderDownloads.pendingIds().indexOf(id)>=0);
    Test.assertEqual(ProviderDownloads.percent(id),0);
    Application.Storage.setValue("trk:"+id,{"title"=>"Fixture","durs"=>[400],"first"=>0,"speed"=>100});
    Application.Storage.setValue("trkc:"+id+":0",["fixture-ref"]);
    Test.assertEqual(ProviderDownloads.percent(id),25);
    Test.assertEqual(JobStore.get(id)["done"],1);
    Test.assertEqual(JobStore.get(id)["gen"],1);
    Application.Storage.deleteValue("trk:"+id);
    Application.Storage.deleteValue("trkc:"+id+":0");
    JobStore.remove(id);
    Test.assert(!ProviderDownloads.unfinished(id));
    return true;
}
