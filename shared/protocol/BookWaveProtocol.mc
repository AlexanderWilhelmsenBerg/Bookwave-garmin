module BookWaveProtocol {
    const PROTOCOL_MAJOR = 1;

    const SOURCE_PHONE = "PHONE";
    const SOURCE_GARMIN = "GARMIN";
    const SOURCE_SERVER = "SERVER";

    function isSupportedSource(value) {
        return value == SOURCE_PHONE
            || value == SOURCE_GARMIN
            || value == SOURCE_SERVER;
    }
}
