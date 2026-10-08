using Toybox.Test;
(:debug)
class TestTextMeasure {
    function initialize(){}
    function width(value){return value.length()*10;}
}
(:test)
function roundTextPreservesAllErrorCharactersAndLineBreaks(logger) {
    var measure=new TestTextMeasure();
    var lines=RoundText.wrap("Response type\n(-1002)",80,measure.method(:width));
    Test.assert(lines.size()==3);
    Test.assert(lines[0].equals("Response"));
    Test.assert(lines[1].equals("type"));
    Test.assert(lines[2].equals("(-1002)"));
    var word="abcdefghijk";
    lines=RoundText.wrap(word,30,measure.method(:width));
    var joined="";
    for(var i=0;i<lines.size();i++){Test.assert(lines[i].length()<=3);joined+=lines[i];}
    Test.assert(joined.equals(word));
    return true;
}
