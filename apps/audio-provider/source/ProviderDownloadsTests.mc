using Toybox.Application;
using Toybox.Test;

(:test)
function duplicateCachedRequestChecksCoverageAndSourceDurations(logger) {
    var id="__provider_cached__";
    var durs=[400];var total=Chunks.total(durs);var refs=[];
    for(var i=0;i<total;i++){refs.add("ref"+i.toString());}
    Application.Storage.setValue("trk:"+id,{"title"=>"Fixture","durs"=>durs,"first"=>0,"speed"=>100});
    Application.Storage.setValue("trkc:"+id+":0",refs);
    var files={"title"=>"Fixture","files"=>[{"ino"=>"file","duration"=>400}],"progress"=>{}};
    Test.assert(ProviderDownloads.storedFor(id,files));
    files["files"][0]["duration"]=500;
    Test.assert(!ProviderDownloads.storedFor(id,files));
    files["files"][0]["duration"]=400;
    Application.Storage.setValue("trkc:"+id+":0",["ref0"]);
    Test.assert(!ProviderDownloads.storedFor(id,files));
    Application.Storage.deleteValue("trk:"+id);
    Application.Storage.deleteValue("trkc:"+id+":0");
    return true;
}
