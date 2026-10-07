// Derived from WatchShelf, Copyright (c) 2026 Christian Brooker.
// MIT license: ../third-party/WATCHSHELF-LICENSE.txt; source pin documented there.
using Toybox.Communications;

// Injects a context object into a web-request callback. The wrapped callback
// always takes 3 args: (responseCode, data, context). Retained from the reviewed WatchShelf source.
class RequestDelegate {
    hidden var mCallback; // Method taking 3 arguments
    hidden var mContext;  // the 3rd argument to hand back

    function initialize(callback, context) {
        mCallback = callback;
        mContext = context;
    }

    function makeWebRequest(url, params, options) {
        Communications.makeWebRequest(url, params, options, self.method(:onWebResponse));
    }

    // Same context-injection, for image downloads (cover art). The callback
    // data is a WatchUi.BitmapResource (or null on error) instead of JSON.
    function makeImageRequest(url, params, options) {
        Communications.makeImageRequest(url, params, options, self.method(:onImageResponse));
    }

    function onWebResponse(code as Toybox.Lang.Number, data as Null or Toybox.Lang.Dictionary or Toybox.Lang.String or Toybox.PersistedContent.Iterator) as Void {
        mCallback.invoke(code, data, mContext);
    }
    function onImageResponse(code as Toybox.Lang.Number, data as Null or Toybox.Graphics.BitmapReference or Toybox.WatchUi.BitmapResource) as Void {
        mCallback.invoke(code, data, mContext);
    }
}
