using Toybox.Background;
using Toybox.Communications;
using Toybox.System;

(:background)
class BookWaveServiceDelegate extends System.ServiceDelegate {
    function initialize() {
        ServiceDelegate.initialize();
    }

    function onPhoneAppMessage(msg) {
        if (msg == null) {
            Background.exit(null);
            return;
        }

        var result = TransportProcessor.process(msg.data);
        var reply = result[TransportProcessor.RESULT_REPLY];
        var changed = result[TransportProcessor.RESULT_CHANGED] == true;

        if (reply == null) {
            Background.exit({"changed" => changed});
            return;
        }

        try {
            Communications.transmit(
                reply,
                {},
                new BackgroundTransmitListener(changed)
            );
        } catch (ex) {
            Background.exit({"changed" => changed, "replySent" => false});
        }
    }
}

(:background)
class BackgroundTransmitListener extends Communications.ConnectionListener {
    var _changed;

    function initialize(changed) {
        ConnectionListener.initialize();
        _changed = changed;
    }

    function onComplete() {
        Background.exit({"changed" => _changed, "replySent" => true});
    }

    function onError() {
        Background.exit({"changed" => _changed, "replySent" => false});
    }
}
