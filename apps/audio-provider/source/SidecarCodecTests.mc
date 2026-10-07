using Toybox.Test;
(:test)
function sidecarFilesRequiredFields(logger) {
    var valid={"title"=>"Fixture","files"=>[{"ino"=>"1","duration"=>3600}],"future"=>true};
    Test.assert(SidecarCodec.files(valid));
    Test.assert(!SidecarCodec.files({"files"=>valid["files"]}));
    Test.assert(!SidecarCodec.files({"title"=>"Fixture","files"=>[{"ino"=>"1"}]}));
    Test.assert(!SidecarCodec.files({"title"=>"Fixture","files"=>[{"ino"=>"1","duration"=>0}]}));
    Test.assert(!SidecarCodec.files({"title"=>"Fixture","files"=>[]}));
    return true;
}

(:test)
function sidecarNoProgressIsValidButMalformedProgressIsRejected(logger) {
    Toybox.Test.assert(SidecarCodec.progress({}));
    Toybox.Test.assert(!SidecarCodec.progress({"currentTime"=>10}));
    Toybox.Test.assert(SidecarCodec.progress({"currentTime"=>10,"duration"=>100,"lastUpdate"=>1800000000,"isFinished"=>false,"future"=>true}));
    Toybox.Test.assert(!SidecarCodec.progress({"currentTime"=>-1,"duration"=>100,"lastUpdate"=>1800000000,"isFinished"=>false}));
    return true;
}
(:test)
function providerLoginCannotRelabelRetainedAccount(logger) {
    Toybox.Application.Storage.deleteValue("bookwave.sidecarAccount.v1");
    Toybox.Test.assert(AbsApi.saveLogin("https://example.invalid","01234567-89ab-4cde-8123-456789abcdef","fixture-user"));
    Toybox.Test.assert(!AbsApi.saveLogin("https://example.invalid","01234567-89ab-4cde-8123-456789abcdef","other-user"));
    Toybox.Test.assert(!AbsApi.saveLogin("https://other.invalid","01234567-89ab-4cde-8123-456789abcdef","fixture-user"));
    Toybox.Test.assert(!AbsApi.saveLogin("https://example.invalid","normal.abs.jwt","fixture-user"));
    Toybox.Application.Storage.deleteValue("bookwave.sidecarAccount.v1");
    Toybox.Application.Storage.deleteValue(Store.SERVER);
    Toybox.Application.Storage.deleteValue(Store.TOKEN);
    return true;
}

(:test)
function sidecarGoldenEndpointResponsesAndBinaryRequestShapes(logger) {
    var cases=SidecarFixtures.cases();
    for(var i=0;i<cases.size();i++) {
        var fixture=cases[i];
        if(fixture["kind"].equals("health")){Toybox.Test.assert(fixture["response"].equals("ok"));}
        else if(fixture["kind"].equals("binary")) {
            Toybox.Test.assert(fixture["method"].equals("GET"));
            Toybox.Test.assert(fixture["query"]["item"].equals("book"));
        } else {
            Toybox.Test.assert(SidecarCodec.accepts(fixture["kind"],fixture["response"]));
            Toybox.Test.assert(!SidecarCodec.accepts(fixture["kind"],null));
        }
    }
    return true;
}
