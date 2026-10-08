using Toybox.Test;
(:test)
function malformedSidecarReplyDoesNotImpersonateGarminTransport(logger) {
    var capture=new SidecarReplyCapture();
    new SidecarReply("files",capture.method(:receive)).receive(200,{"title"=>"Fixture","files"=>[]});
    Test.assert(capture.code==SidecarStatus.INVALID_RESPONSE);
    Test.assert(capture.code!=-1002);
    Test.assert(capture.data["field"].equals("files"));
    new SidecarReply("files",capture.method(:receive)).receive(-1002,null);
    Test.assert(capture.code==-1002 && capture.data==null);
    return true;
}
(:debug)
class SidecarReplyCapture {
    var code; var data;
    function initialize(){}
    function receive(value,body){code=value;data=body;}
}
(:test)
function rejectedBookDetailsIdentifyOnlySchemaField(logger) {
    Test.assert(SidecarCodec.failure("files",{"title"=>"Fixture","files"=>[{"ino"=>"1","duration"=>0}]}).equals("files.duration"));
    Test.assert(SidecarCodec.failure("files",{"title"=>"Fixture","files"=>[{"ino"=>null,"duration"=>3}]}).equals("files.ino"));
    Test.assert(SidecarCodec.failure("files",{"files"=>[]}).equals("title"));
    Test.assert(SidecarCodec.failure("files",{"title"=>"Fixture","files"=>[{"ino"=>"1","duration"=>3}]} )==null);
    return true;
}
(:test)
function phoneSetupSeparatesTransportSchemaAndLoginFailures(logger) {
    Test.assert(ProviderSetupState.loginError(-1002).equals("CONTENT_TYPE"));
    Test.assert(ProviderSetupState.loginError(SidecarStatus.INVALID_RESPONSE).equals("INCOMPATIBLE_SIDECAR"));
    Test.assert(ProviderSetupState.loginError(401).equals("LOGIN_REJECTED"));
    Test.assert(ProviderSetupState.loginError(-104).equals("SIDECAR_UNAVAILABLE"));
    return true;
}
