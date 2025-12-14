import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Timer;

class monCadranView extends WatchUi.WatchFace {
    var _timer;
    var _showColon = true;
    var digital_font = null;
    var digital_font_small = null;
    var bitmap = null;
    var background_image = WatchUi.loadResource(Rez.Drawables.g1);
    var animation = null;
    var animationFinished = true;


    function initialize() {
        WatchFace.initialize();

    }
    
    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));   
        bitmap = new WatchUi.Bitmap({
            :rezId=>background_image,
            :locX=>((dc.getWidth() - background_image.getWidth()) / 2),
            :locY=>((dc.getHeight() - background_image.getHeight()) / 2)
        });
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        _timer = new Timer.Timer();
        _timer.start(method(:onTimer), 1000, true);
        digital_font_small = WatchUi.loadResource(Rez.Fonts.ds_digital_b_i_s);
        digital_font = WatchUi.loadResource(Rez.Fonts.ds_digital_b_i);
        View.onShow();
    }

    function onUpdate(dc as Dc) as Void {
      // Clear the screen
        
        dc.clear();
        bitmap.draw(dc);
        // background
        setupDigit("_HourLabel", digital_font, "8");
        setupDigit("_HourLabel2", digital_font, "8");
        setupDigit("_MinuteLabel", digital_font, "8");
        setupDigit("_MinuteLabel2", digital_font, "8");
        setupDigit("_SecondLabel", digital_font_small, "8");
        setupDigit("_SecondLabel2", digital_font_small, "8");





        // Dessiner le reste de l'interface utilisateur
        // 1. Récupérer l'heure système
        var clockTime = System.getClockTime();

        // 2. Simplifier le formatage (pas besoin de Lang.format)
        var hourString = clockTime.hour.format("%02d");
        var minuteString = clockTime.min.format("%02d");
        var secondString = clockTime.sec.format("%02d");
        
        // 3. Mise à jour centralisée des chiffres de l'heure et des minutes
        setupDigit("HourLabel", digital_font, hourString.substring(0, 1));
        setupDigit("HourLabel2", digital_font, hourString.substring(1, 2));
        setupDigit("MinuteLabel", digital_font, minuteString.substring(0, 1));
        setupDigit("MinuteLabel2", digital_font, minuteString.substring(1, 2));
        
        // 4. Mise à jour des secondes (si elles sont affichées)
        setupDigit("SecondLabel", digital_font_small, secondString.substring(0, 1));
        setupDigit("SecondLabel2", digital_font_small, secondString.substring(1, 2));
        
        // 5. Gérer le côlon (clignotement)
        var colon = View.findDrawableById("ColonLabel") as Text;
        if (colon != null) {
            colon.setFont(digital_font);
            colon.setText(_showColon ? ":" : " ");
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

    

    // Fonction utilitaire pour configurer l'affichage d'un chiffre
    function setupDigit(drawableId, font, text) as Void {
        var drawable = View.findDrawableById(drawableId) as Text;
        if (drawable != null) {
            drawable.setFont(font);
            drawable.setText(text);
            // drawable.setSize(50, 50); 
        }
    }
}
