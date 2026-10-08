using Toybox.Graphics;
// Shared presentation only: measured wrapping, safe central rectangle on round displays.
module RoundText {
    function wrap(text,width,measure) {
        var rows=[]; var line=""; var word="";
        for(var i=0;i<=text.length();i++) {
            var ch=i==text.length()?"\n":text.substring(i,i+1);
            if(!ch.equals(" ") && !ch.equals("\n")){word+=ch;continue;}
            if(word.length()>0) {
                var candidate=line.length()==0?word:line+" "+word;
                if(line.length()>0 && measure.invoke(candidate)>width){rows.add(line);line="";}
                while(measure.invoke(word)>width && word.length()>1) {
                    var count=1;
                    while(count<word.length() && measure.invoke(word.substring(0,count+1))<=width){count++;}
                    rows.add(word.substring(0,count));word=word.substring(count,word.length());
                }
                line=line.length()==0?word:line+" "+word;word="";
            }
            if(ch.equals("\n")){rows.add(line);line="";}
        }
        return rows;
    }
    function draw(dc,text,page,footer) {
        var font=Graphics.FONT_XTINY;
        var measure=new RoundTextMeasure(dc,font);
        var lines=wrap(text,dc.getWidth()*72/100,measure.method(:width));
        var step=dc.getFontHeight(font)+2;
        var count=(dc.getHeight()*50/100/step).toNumber();
        if(count<1){count=1;}
        var pages=((lines.size()+count-1)/count).toNumber();
        if(page>=pages){page=pages-1;}
        if(page<0){page=0;}
        var offset=page*count;
        var y=dc.getHeight()*23/100;
        for(var i=offset;i<lines.size() && i<offset+count;i++) {
            dc.drawText(dc.getWidth()/2,y,font,lines[i],Graphics.TEXT_JUSTIFY_CENTER);
            y+=step;
        }
        var label=pages>1?"UP/DOWN "+(page+1)+"/"+pages:footer;
        dc.drawText(dc.getWidth()/2,dc.getHeight()*77/100,font,label,Graphics.TEXT_JUSTIFY_CENTER);
        return pages;
    }
}
class RoundTextMeasure {
    var dc; var font;
    function initialize(context,value){dc=context;font=value;}
    function width(text){return dc.getTextWidthInPixels(text,font);}
}
