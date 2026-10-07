using Toybox.Application;
using Toybox.Media;
// DL-001/003: separate native audio provider; additive state never erases cache on upgrade.
class BookWaveAudioApp extends Application.AudioContentProviderApp {
    function initialize() { AudioContentProviderApp.initialize(); }
    function onStart(state) { ProviderControl.start(); }
    function onStop(state) { ProviderFeed.stopped();ProviderControl.stop(); }
    function getContentDelegate(args) { return new ContentDelegate(args); }
    function getSyncDelegate() { return new SyncDelegate(); }
    function getPlaybackConfigurationView() { return [new DownloadedMenu(),new DownloadedMenuDelegate()]; }
    function getSyncConfigurationView() { return [new LibraryView(),new LibraryViewDelegate()]; }
    function getProviderIconInfo() { return new Media.ProviderIconInfo(Rez.Drawables.providerIcon,0x80CBC4); }
}
