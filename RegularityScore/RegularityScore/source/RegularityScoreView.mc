import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.Lang;
import Toybox.ActivityMonitor;

class RegularityScoreView extends WatchUi.View {

    var score = 0;
    var message = "";
    var nbStars = 0; 
    var scoreColor = Graphics.COLOR_WHITE; 

    function initialize() {
        View.initialize();
        var modeTest = false; 
        
        var history;
        if (modeTest) {
             history = [25, 25, 25, 25, 25, 25, 25] as Array<Number>;
        } else {
             history = getHistoryFromGarmin();
        }

        score = computeScore(history);
        updateData(); 
    }

    function getHistoryFromGarmin() as Array<Number?> {
        var history = ActivityMonitor.getHistory();
        var result = new [7];
        if (history != null) {
            for (var i = 0; i < 7; i++) {
                if (i < history.size() && history[i] != null && history[i] has :activeMinutes && history[i].activeMinutes != null) {
                    result[i] = history[i].activeMinutes.total;
                } else { result[i] = 0; }
            }
        }
        return result;
    }

    
    function computeScore(daysArray as Array<Number?>) {
        var arr = new [7];
        for (var i = 0; i < 7; i++) {
            if (i < daysArray.size() && daysArray[i] != null) {
                arr[i] = daysArray[i] as Number;
            } else { arr[i] = 0; }
        }
        var daysActive = 0; var totalMinutes = 0; var maxStreak = 0; var cur = 0;
        for (var i = 0; i < arr.size(); i++) {
            if (arr[i] > 0) {
                daysActive++; totalMinutes += arr[i]; cur++;
                if (cur > maxStreak) { maxStreak = cur; }
            } else { cur = 0; }
        }
        var freqScore = (daysActive / 7.0) * 50.0;
        var streakScore = (maxStreak / 7.0) * 30.0;
        var ratio = totalMinutes / 210.0;
        var durationScore = (ratio > 1.0) ? 20.0 : (ratio * 20.0);
        var total = Math.round(freqScore + streakScore + durationScore).toNumber();
        if (total < 0) { total = 0; }
        if (total > 100) { total = 100; }
        return total;
    }

    
    function updateData() {
        if (score >= 80) {
            nbStars = 4;
            message = "EXCELLENT";
            scoreColor = Graphics.COLOR_GREEN; 
        } else if (score >= 60) {
            nbStars = 3;
            message = "BIEN";
            scoreColor = 0xFFAA00; 
        } else if (score >= 40) {
            nbStars = 2;
            message = "MOYEN";
            scoreColor = Graphics.COLOR_YELLOW; 
        } else {
            nbStars = 1;
            message = "ALLEZ !";
            scoreColor = Graphics.COLOR_RED; 
        }
    }

    

    function onUpdate(dc) {
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;
        
        
        dc.setPenWidth(10); 
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, cx - 10);

        
        if (score > 0) {
            dc.setColor(scoreColor, Graphics.COLOR_TRANSPARENT);
            var endAngle = 90 - (score * 3.6); 
            dc.drawArc(cx, cy, cx - 10, Graphics.ARC_CLOCKWISE, 90, endAngle);
        }

        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 10, Graphics.FONT_NUMBER_HOT, score.toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        

      
        var starSize = 8; 
        var spacing = 20; 
        var totalWidth = (nbStars * spacing);
        var startX = cx - (totalWidth / 2) + (spacing / 2);

        dc.setColor(scoreColor, Graphics.COLOR_TRANSPARENT);
        
        for (var i = 0; i < nbStars; i++) {
            drawStar(dc, startX + (i * spacing), cy - 60, starSize);
        }

       
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 60, Graphics.FONT_TINY, message, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    
    function drawStar(dc, x, y, radius) {
        var pts = new [10]; 
        var angle = -Math.PI / 2; 
        var step = Math.PI / 5;   

        for (var i = 0; i < 10; i++) {
            var r = (i % 2 == 0) ? radius : radius / 2; 
            pts[i] = [
                x + r * Math.cos(angle),
                y + r * Math.sin(angle)
            ];
            angle += step;
        }
        dc.fillPolygon(pts);
    }
}