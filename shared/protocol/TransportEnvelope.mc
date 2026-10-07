using Toybox.Lang;

(:background)
class TransportEnvelope {
    var protocolMajor;
    var type;
    var id;
    var replyTo;
    var sentAt;
    var payload;

    function initialize(values) {
        protocolMajor = values["v"];
        type = values["t"];
        id = values["id"];
        replyTo = values["r"];
        sentAt = values["ts"];
        payload = values["p"];
    }
}
