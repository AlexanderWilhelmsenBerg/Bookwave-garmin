using Toybox.Graphics;
// Hallmark · Stat-Led · BookWave dark teal, adapted to native round displays.
// Audience: owner/listener; use: read playback/find offline audio; tone: calm, practical.
// Native system fonts, measured pagination, still presentation. Pixel acceptance pending.
// Pre-emit critique P/H/E/S/R/V = 4/4/4/4/4/4.
module WatchTheme {
    const PAPER=0x101414; const SURFACE=0x1C292A; const INK=0xE0E3E2;
    const MUTED=0xBEC9C8; const ACCENT=0x9ACACC; const RULE=0x3F4949;
    const BODY=Graphics.FONT_XTINY; const HEADING=Graphics.FONT_SMALL;
    const HERO=Graphics.FONT_MEDIUM; const GAP=4;
    // Companion has its own geometry: side-key text never shares the reading area.
    // Keep the center rectangle inside both supported round displays; wrap by measured glyph width.
    function companion(dc,text,page,status,selectLabel) {
        var w=dc.getWidth();var h=dc.getHeight();
        dc.setColor(INK,PAPER);dc.clear();
        dc.setColor(ACCENT,PAPER);
        dc.drawText(w/2,h*11/100,BODY,"BookWave",Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(MUTED,PAPER);
        dc.drawText(w/2,h*20/100,BODY,status,Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(SURFACE,PAPER);
        dc.fillRoundedRectangle(w*13/100,h*29/100,w*74/100,h*42/100,18);
        var measure=new RoundTextMeasure(dc,BODY);
        var rows=RoundText.wrap(text,w*66/100,measure.method(:width));
        var step=dc.getFontHeight(BODY)+GAP;
        var count=(h*38/100/step).toNumber();if(count<1){count=1;}
        var pages=((rows.size()+count-1)/count).toNumber();if(pages<1){pages=1;}
        if(page>=pages){page=pages-1;}if(page<0){page=0;}
        dc.setColor(INK,SURFACE);var y=h*31/100;
        for(var i=page*count;i<rows.size() && i<(page+1)*count;i++) {
            dc.drawText(w*17/100,y,BODY,rows[i],Graphics.TEXT_JUSTIFY_LEFT);y+=step;
        }
        dc.setColor(ACCENT,PAPER);
        dc.drawText(w/2,h*75/100,BODY,"START: "+selectLabel,Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(MUTED,PAPER);
        dc.drawText(w/2,h*84/100,BODY,pages>1?"UP/DOWN  "+(page+1)+"/"+pages:"BACK: Exit",Graphics.TEXT_JUSTIFY_CENTER);
        // Physical-key markers only, outside the text rectangle.
        dc.setColor(ACCENT,PAPER);
        dc.drawLine(w*91/100,h*28/100,w*94/100,h*30/100);
        dc.drawLine(w*94/100,h*30/100,w*91/100,h*32/100);
        return pages;
    }
    function frame(dc,title,selectLabel,backLabel,paging) {
        var w=dc.getWidth();var h=dc.getHeight();
        dc.setColor(INK,PAPER);dc.clear();dc.setColor(SURFACE,PAPER);
        dc.fillRoundedRectangle(w*16/100,h*36/100,w*68/100,h*39/100,16);
        dc.setColor(ACCENT,PAPER);
        var heading=dc.getTextWidthInPixels(title,HEADING)>w*60/100?BODY:HEADING;
        dc.drawText(w/2,h*11/100,heading,title,Graphics.TEXT_JUSTIFY_CENTER);
        // START upper-right / BACK lower-right, aligned with physical fenix 8 keys.
        button(dc,selectLabel,w*91/100,h*29/100);
        button(dc,backLabel,w*91/100,h*69/100);
        if(paging){framePageCues(dc);}dc.setColor(INK,PAPER);
    }
    function button(dc,label,x,y) {
        if(label.length()==0){return;}var step=dc.getWidth()*2/100;
        dc.drawLine(x,y,x+step,y+step);dc.drawLine(x+step,y+step,x,y+2*step);
        dc.drawText(x-step,y-step,BODY,label,Graphics.TEXT_JUSTIFY_RIGHT);
    }
    function framePageCues(dc) {
        var w=dc.getWidth();var h=dc.getHeight();dc.setColor(ACCENT,PAPER);
        dc.drawLine(w*5/100,h*49/100,w*7/100,h*47/100);
        dc.drawLine(w*7/100,h*47/100,w*9/100,h*49/100);
        dc.drawLine(w*12/100,h*71/100,w*14/100,h*73/100);
        dc.drawLine(w*14/100,h*73/100,w*16/100,h*71/100);dc.setColor(INK,PAPER);
    }
    function headphones(dc) {
        var cx=dc.getWidth()/2;var cy=dc.getHeight()*28/100;var radius=dc.getWidth()*4/100;
        dc.setColor(ACCENT,PAPER);dc.setPenWidth(3);
        dc.drawArc(cx,cy,radius,Graphics.ARC_CLOCKWISE,0,180);
        dc.fillRoundedRectangle(cx-radius-3,cy,6,radius,3);
        dc.fillRoundedRectangle(cx+radius-3,cy,6,radius,3);dc.setPenWidth(1);dc.setColor(INK,PAPER);
    }
    function page(dc,text,page,source,backLabel) {
        var measure=new RoundTextMeasure(dc,BODY);
        // Reserve the measured key label, rather than assuming a font's character width.
        var keyLeft=dc.getWidth()*89/100-dc.getTextWidthInPixels(backLabel,BODY)-GAP;
        var width=2*(keyLeft-dc.getWidth()/2);
        var maximum=dc.getWidth()*54/100;if(width>maximum){width=maximum;}
        var rows=RoundText.wrap(text,width,measure.method(:width));
        var step=dc.getFontHeight(BODY)+GAP;var count=(dc.getHeight()*37/100/step).toNumber();
        if(count<1){count=1;}var pages=((rows.size()+count-1)/count).toNumber();
        if(pages<1){pages=1;}if(page>=pages){page=pages-1;}if(page<0){page=0;}
        var y=dc.getHeight()*39/100;
        for(var i=page*count;i<rows.size() && i<(page+1)*count;i++) {
            dc.drawText(dc.getWidth()/2,y,BODY,rows[i],Graphics.TEXT_JUSTIFY_CENTER);y+=step;
        }
        dc.setColor(MUTED,PAPER);
        var label=pages>1?(page+1)+" / "+pages+"  UP/DOWN":source;
        dc.drawText(dc.getWidth()/2,dc.getHeight()*81/100,BODY,label,Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(INK,PAPER);return pages;
    }
}
