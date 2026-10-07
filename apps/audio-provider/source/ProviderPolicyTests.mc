using Toybox.Test;
(:test)
function providerHttpsOnly(logger) {
    Test.assert(ProviderPolicy.validUrl("https://example.invalid/sidecar"));
    Test.assert(!ProviderPolicy.validUrl("http://example.invalid"));
    Test.assert(!ProviderPolicy.validUrl("https://"));
    Test.assert(!ProviderPolicy.validUrl("https://user:secret@example.invalid"));
    return true;
}
(:test)
function providerOpaqueSessionOnly(logger) {
    Test.assert(ProviderPolicy.validSession("01234567-89ab-4cde-8123-456789abcdef"));
    Test.assert(!ProviderPolicy.validSession("header.payload.signature"));
    Test.assert(!ProviderPolicy.validSession(null));
    return true;
}
(:test)
function providerScopeAndNonce(logger) {
    var command = {"v"=>1,"t"=>"inventory","r"=>"r1","p"=>"p1","n"=>"n1"};
    Test.assert(ProviderPolicy.accepts(command,"p1","n1"));
    Test.assert(!ProviderPolicy.accepts(command,"p2","n1"));
    Test.assert(!ProviderPolicy.accepts(command,"p1","n2"));
    command["v"] = 2;
    Test.assert(!ProviderPolicy.accepts(command,"p1","n1"));
    return true;
}
