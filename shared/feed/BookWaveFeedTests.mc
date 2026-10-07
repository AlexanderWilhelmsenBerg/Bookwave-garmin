using Toybox.Test;
(:test)
function feedClearRemovesAllPrivateValues(logger) {
    var v=BookWaveFeed.encode("PHONE","Secret","Chapter",120,200,1000,900,"playing","redacted");
    Test.assert(v.equals("1|PHONE|1000|-1|unknown|0|0|redacted||"));
    return true;
}
(:test)
function feedPreservesSourceTimesAndRewind(logger) {
    Test.assert(BookWaveFeed.encode("GARMIN","Book","",10,200,1000,900,"paused","authorized").equals("1|GARMIN|1000|900|paused|10|200|authorized|Book|"));
    Test.assert(BookWaveFeed.escape("a|b%\n").equals("a%7Cb%25%0A"));
    return true;
}

(:test)
function feedUnknownDurationAndChapterRemainUnknown(logger) {
    var data={"title"=>"Fixture","chapterTitle"=>null,"positionMs"=>10,"durationMs"=>null,"updatedAt"=>1000,"playing"=>true};
    Test.assert(BookWaveFeed.encode("PHONE",data["title"],data["chapterTitle"],10,0,1000,-1,"unknown","authorized").equals("1|PHONE|1000|-1|unknown|10|0|authorized|Fixture|"));
    return true;
}

(:test)
function feedPhoneCallerHandlesUnknownDurationAndClearsPublisher(logger) {
    var data={"title"=>"Fixture","chapterTitle"=>null,"positionMs"=>10,"durationMs"=>null,"updatedAt"=>1000,"playing"=>true};
    Toybox.Complications.updateComplication(0,{:value=>"Fixture",:shortLabel=>"BookWave",:unit=>Toybox.Complications.UNIT_INVALID});
    Test.assert(BookWaveFeed.phone(data,false));
    Test.assert(Toybox.Application.Storage.getValue(BookWaveFeed.KEY).equals("1|PHONE|1000|-1|unknown|10|0|authorized|Fixture|"));
    Test.assert(BookWaveFeed.clear("PHONE"));
    return true;
}
