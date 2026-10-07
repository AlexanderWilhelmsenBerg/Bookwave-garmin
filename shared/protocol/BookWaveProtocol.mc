(:background)
module BookWaveProtocol {
    const PROTOCOL_MAJOR = 1;

    const SOURCE_PHONE = "PHONE";
    const SOURCE_GARMIN = "GARMIN";
    const SOURCE_SERVER = "SERVER";

    const TYPE_HELLO = "hello";
    const TYPE_HELLO_ACK = "hello_ack";
    const TYPE_SNAPSHOT = "snapshot";
    const TYPE_SNAPSHOT_ACK = "snapshot_ack";
    const TYPE_STATE_REQUEST = "state_request";
    const TYPE_CLEAR_STATE = "clear_state";
    const TYPE_CLEAR_ACK = "clear_ack";
    const TYPE_ERROR = "error";

    const CAP_SNAPSHOT = "snapshot";
    const CAP_SNAPSHOT_ACK = "snapshot_ack";
    const CAP_STATE_REQUEST = "state_request";
    const CAP_CLEAR_STATE = "clear_state";
    const CAP_BACKGROUND_RX = "background_rx";

    function isSupportedSource(value) {
        return value == SOURCE_PHONE
            || value == SOURCE_GARMIN
            || value == SOURCE_SERVER;
    }

    function isKnownMessageType(value) {
        return value == TYPE_HELLO
            || value == TYPE_HELLO_ACK
            || value == TYPE_SNAPSHOT
            || value == TYPE_SNAPSHOT_ACK
            || value == TYPE_STATE_REQUEST
            || value == TYPE_CLEAR_STATE
            || value == TYPE_CLEAR_ACK
            || value == TYPE_ERROR;
    }

    function capabilities() {
        return [
            CAP_SNAPSHOT,
            CAP_SNAPSHOT_ACK,
            CAP_STATE_REQUEST,
            CAP_CLEAR_STATE,
            CAP_BACKGROUND_RX
        ];
    }
}
