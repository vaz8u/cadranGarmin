import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Timer;

class monCadranView extends WatchUi.WatchFace {
    var _timer;
    var _showColon = true;
    var digital_font = null;
    var bitmap = null;
    var animation = null;
    var animationFinished = true;

    function initialize() {
        WatchFace.initialize();
        animation  = new WatchUi.AnimationLayer(Rez.Drawables.BackgroundAnimation, {:locX=>100, :locY=>100});
        addLayer(animation);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        _timer = new Timer.Timer();
        _timer.start(method(:onTimer), 1000, true);
        digital_font = WatchUi.loadResource(Rez.Fonts.DigitalFont);
        //animation.play({:locX=>100, :locY=>100});
        View.onShow();
    }

    function onUpdate(dc as Dc) as Void {
    // Clear the screen
    dc.clear();

    // Vérifier si l'animation est terminée
    if (animationFinished) {
        animation.stop();
        animation.play({:locX=>100, :locY=>100});
        animationFinished = false;
    }

    // Dessiner le reste de l'interface utilisateur
    var clockTime = System.getClockTime();
    var hourString = Lang.format("$1$", [clockTime.hour.format("%02d")]) as String; 
    var minuteString = Lang.format("$1$", [clockTime.min.format("%02d")]) as String;
    var secondString = Lang.format("$1$", [clockTime.sec.format("%02d")]) as String;

    var firstHour = View.findDrawableById("HourLabel") as Text;
    firstHour.setText(hourString.toCharArray()[0].toString());
    firstHour.setFont(digital_font);
    firstHour.setColor(Graphics.COLOR_PINK);

    var secondHour = View.findDrawableById("HourLabel2") as Text;
    secondHour.setText(hourString.toCharArray()[1].toString());
    secondHour.setFont(digital_font);

    var firstMinute = View.findDrawableById("MinuteLabel") as Text;
    firstMinute.setText(minuteString.toCharArray()[0].toString());
    firstMinute.setFont(digital_font);

    var secondMinute = View.findDrawableById("MinuteLabel2") as Text;
    secondMinute.setText(minuteString.toCharArray()[1].toString());
    secondMinute.setFont(digital_font);

    var firstSecond = View.findDrawableById("SecondLabel") as Text;
    firstSecond.setText(secondString.toCharArray()[0].toString());
    firstSecond.setFont(digital_font);

    var secondSecond = View.findDrawableById("SecondLabel2") as Text;
    secondSecond.setText(secondString.toCharArray()[1].toString());
    secondSecond.setFont(digital_font);  

    var colon = View.findDrawableById("ColonLabel") as Text;
    colon.setFont(digital_font);
    if (_showColon) {
        colon.setText(":");
    } else {
        colon.setText(" ");
    }

    View.onUpdate(dc);
}

function onAnimationFinished() as Void {
    animationFinished = true;
}


    // Timer callback to toggle the colon
    function onTimer() as Void {
        _showColon = !_showColon;
        WatchUi.requestUpdate();
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        _timer.stop();
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        _timer.start(method(:onTimer), 500, true);
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        _timer.stop();
    }
}
