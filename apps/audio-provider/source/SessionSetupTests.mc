using Toybox.Test;
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
