using Toybox.Test;
(:test)
function providerReusesOnlyAnAnchoredWatchLogin(logger) {
    var value={"url"=>"https://example.invalid","user"=>"fixture"};
    Test.assert(ProviderPolicy.reuseSetup(value));
    value["password"]="must-not-send";Test.assert(!ProviderPolicy.reuseSetup(value));
    value["password"]=null;
    Toybox.Application.Storage.deleteValue("bookwave.sidecarAccount.v1");
    Test.assert(!AbsApi.canReuse(value["url"],value["user"]));
    Test.assert(AbsApi.saveLogin(value["url"],"01234567-89ab-4cde-8123-456789abcdef",value["user"]));
    Test.assert(AbsApi.canReuse(value["url"],value["user"]));
    Test.assert(!AbsApi.canReuse("https://other.invalid",value["user"]));
    Test.assert(!AbsApi.canReuse(value["url"],"other"));
    Toybox.Application.Storage.deleteValue("bookwave.sidecarAccount.v1");
    Toybox.Application.Storage.deleteValue(Store.SERVER);Toybox.Application.Storage.deleteValue(Store.TOKEN);
    return true;
}
(:test)
function providerSessionSetupNeverAcceptsAbsCredentials(logger) {
    var value={"url"=>"https://example.invalid","user"=>"fixture","session"=>"01234567-89ab-4cde-8123-456789abcdef"};
    Test.assert(ProviderPolicy.sessionSetup(value));
    value["session"]="header.payload.signature";
    Test.assert(!ProviderPolicy.sessionSetup(value));
    value["session"]=null; value["password"]="fixture";
    Test.assert(!ProviderPolicy.sessionSetup(value));
    return true;
}
