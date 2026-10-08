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

(:test)
function providerSetupIsBoundedAndHttpsOnly(logger) {
    Test.assert(ProviderPolicy.setup({"url"=>"https://example.invalid/sidecar","user"=>"fixture","password"=>"secret"}));
    Test.assert(!ProviderPolicy.setup({"url"=>"http://example.invalid","user"=>"fixture","password"=>"secret"}));
    Test.assert(!ProviderPolicy.setup({"url"=>"https://example.invalid","user"=>"fixture","password"=>""}));
    Test.assert(!ProviderPolicy.validUrl("https:///login"));
    Test.assert(!ProviderPolicy.validUrl("https://example.invalid/../login"));
    return true;
}
(:test)
function providerPairExpiresWithoutBinding(logger) {
    var previous=ProviderControl.profile();
    ProviderControl.pendingPair={"r"=>"request","p"=>"fixture","code"=>"123456"};
    ProviderControl.pairAt=Toybox.Time.now().value()-121;
    Test.assert(!ProviderControl.pairing("fixture"));
    ProviderControl.confirmPair(true,"request");
    Test.assert(ProviderControl.pendingPair==null);
    Test.assert(ProviderControl.profile()==previous);
    return true;
}

(:test)
function providerSetupCancelDiscardsSecretAndReleasesBusyState(logger) {
    var request=new ProviderSetupRequest({"v"=>1,"t"=>"setup","r"=>"request","p"=>"fixture","n"=>"nonce","url"=>"https://example.invalid","user"=>"fixture","password"=>"fixture-secret"});
    ProviderControl.setup=request;
    Test.assert(request.command["password"]==null);
    request.cancel();
    Test.assert(request.password==null);
    Test.assert(ProviderControl.setup==null);
    Test.assert(ProviderPolicy.code("123456"));
    Test.assert(!ProviderPolicy.code("123"));
    Test.assert(!ProviderPolicy.code("12abcd"));
    return true;
}
