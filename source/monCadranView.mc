import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Timer;
import Toybox.Weather;


class monCadranView extends WatchUi.WatchFace {
    var _timer;
    var digital_font = null;
    var digital_font_small = null;
    var bitmap = null;
    var background_image = WatchUi.loadResource(Rez.Drawables.g1);
    var animation = null;
    var animationFinished = true;
    var jour = null;
    var nom_jour = null;
    var font_date = null;
    var temperature = null;
    var temperatureLogo = null;
    var font_weather = null;
    var mWeatherTimer = null;
    var isNight = null;

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
        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        nom_jour = info.day_of_week + "-" + info.day.format("%02d");

        // Initialiser le timer pour mettre à jour la météo toutes les 15 minutes (900000 ms)
        mWeatherTimer = new Timer.Timer();
        mWeatherTimer.start(method(:updateWeather), 900000, true);
        // Première mise à jour au démarrage
        updateWeather();

        digital_font_small = WatchUi.loadResource(Rez.Fonts.ds_digital_b_i_s);
        digital_font = WatchUi.loadResource(Rez.Fonts.ds_digital_b_i);
        font_date = WatchUi.loadResource(Rez.Fonts.font_date);
        font_weather = WatchUi.loadResource(Rez.Fonts.font_weather);
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

        var dayNameDrawable = View.findDrawableById("DayNameLabel") as Text;
        if (dayNameDrawable != null) {  
            dayNameDrawable.setFont(font_date);
            dayNameDrawable.setText(nom_jour);
        }

        var tempDrawable = View.findDrawableById("TemperatureLabel") as Text;
        if (tempDrawable != null) {  
            tempDrawable.setFont(font_date);
            tempDrawable.setText(temperature);
        }
        var weatherIconDrawable = View.findDrawableById("WeatherIcon") as Text;
        if (weatherIconDrawable != null && temperatureLogo != null) {  
            weatherIconDrawable.setFont(font_weather);
            weatherIconDrawable.setText(temperatureLogo.toString());
        }



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
            colon.setText(":");
        }

        View.onUpdate(dc);
    }

    function getWeatherIcon() as Lang.Char {
        // Détermine si le soleil est couché (basé sur la fonction isSunDown() que vous avez définie)
        var isNight = isSunDown();
        var condition = Weather.getCurrentConditions().condition;

        if (condition == null) {
            return 61443.toChar(); // ☁️ Cloudy (f003) par défaut
        }

        switch (condition) {
            // --- Ciel dégagé / Clair ---
            case Weather.CONDITION_CLEAR: // Ciel dégagé
            case Weather.CONDITION_FAIR: // Beau temps
                if (isNight) {
                    // NUIT : Lune dégagée
                    return 61486.toChar(); // 🌙 61486 (f02e) : Night-Clear
                } else {
                    // JOUR : Soleil dégagé
                    return 61453.toChar(); // ☀️ 61453 (f00d) : Day-Sunny
                }
            
            case Weather.CONDITION_PARTLY_CLEAR: // Partiellement clair
            case Weather.CONDITION_MOSTLY_CLEAR: // Généralement clair
                if (isNight) {
                    // NUIT : Lune avec petits nuages
                    return 61489.toChar(); // 🌤️ 61489 (f031) : Night-Alt-Cloudy (Partly/Mostly Clear)
                } else {
                    // JOUR : Soleil avec petits nuages
                    return 61442.toChar(); // ⛅ 61442 (f002) : Day-Cloudy
                }
                
            // --- Nuageux ---
            // Les icônes purement nuageuses ou de pluie/neige n'ont souvent qu'une seule version (identique jour/nuit)
            
            case Weather.CONDITION_PARTLY_CLOUDY: // Partiellement nuageux
            case Weather.CONDITION_MOSTLY_CLOUDY: // Généralement nuageux
                if (isNight) {
                    // NUIT : Nuages avec lune derrière
                    return 61488.toChar(); // 🌥️ 61488 (f030) : Night-Alt-Cloudy
                } else {
                    // JOUR : Nuages avec soleil derrière
                    return 61442.toChar(); // ⛅ 61442 (f002) : Day-Cloudy
                }
            
            case Weather.CONDITION_CLOUDY: // Nuageux
            case Weather.CONDITION_THIN_CLOUDS: // Nuages minces
                // Icône sans distinction jour/nuit
                return 61443.toChar(); // ☁️ 61443 (f003) : Cloudy

            // --- Pluie / Averses / Bruine ---
            case Weather.CONDITION_RAIN: // Pluie
                return 61465.toChar(); // 🌧️ 61465 (f019) : Rain
            
            case Weather.CONDITION_LIGHT_RAIN: // Pluie légère
            case Weather.CONDITION_DRIZZLE: // Bruine
                return 61468.toChar(); // 🌦️ 61468 (f01c) : Rain-Mix
                
            case Weather.CONDITION_HEAVY_RAIN: // Forte pluie
            case Weather.CONDITION_SHOWERS: // Averses
            case Weather.CONDITION_HEAVY_SHOWERS: // Fortes averses
                if (isNight) {
                    // NUIT : Nuage de pluie de nuit
                    return 61494.toChar(); // ⛈️ 61494 (f036) : Night-Alt-Rain
                } else {
                    // JOUR : Nuage de pluie de jour
                    return 61444.toChar(); // ⛈️ 61444 (f004) : Day-Rain
                }
                
            case Weather.CONDITION_SCATTERED_SHOWERS: // Averses éparses
            case Weather.CONDITION_LIGHT_SHOWERS: // Averses légères
            case Weather.CONDITION_CHANCE_OF_SHOWERS: // Risque d'averses
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN: // Nuageux avec risque de pluie
                if (isNight) {
                    // NUIT : Lune/Nuages/Pluie
                    return 61498.toChar(); // 🌥️ 61498 (f03a) : Night-Alt-Showers
                } else {
                    // JOUR : Soleil/Nuages/Pluie
                    return 61450.toChar(); // 🌦️ 61450 (f00a) : Day-Showers
                }
                
            // --- Neige / Grésil / Mixte ---
            case Weather.CONDITION_SNOW: // Neige
            case Weather.CONDITION_LIGHT_SNOW: // Neige légère
            case Weather.CONDITION_FLURRIES: // Flocons / Rafales de neige
            case Weather.CONDITION_CHANCE_OF_SNOW: // Risque de neige
                return 61466.toChar(); // ❄️ 61466 (f01a) : Snow (Icône générique)
                
            case Weather.CONDITION_HEAVY_SNOW: // Forte neige
                if (isNight) {
                    return 61495.toChar(); // 🌨️ 61495 (f037) : Night-Alt-Snow (Forte neige)
                } else {
                    return 61449.toChar(); // 🌨️ 61449 (f009) : Day-Snow (Forte neige)
                }

            case Weather.CONDITION_WINTRY_MIX: // Temps hivernal mixte (neige et pluie)
            case Weather.CONDITION_RAIN_SNOW: // Pluie et neige
            case Weather.CONDITION_LIGHT_RAIN_SNOW: // Pluie et neige légère
            case Weather.CONDITION_HEAVY_RAIN_SNOW: // Pluie et neige forte
            case Weather.CONDITION_CHANCE_OF_RAIN_SNOW: // Risque de pluie et neige
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW: // Nuageux avec risque de pluie et neige
            case Weather.CONDITION_SLEET: // Grésil
                return 61481.toChar(); // 🌨️ 61481 (f029) : Sleet
                
            case Weather.CONDITION_FREEZING_RAIN: // Pluie verglaçante
            case Weather.CONDITION_ICE: // Glace
            case Weather.CONDITION_ICE_SNOW: // Neige et glace
                return 61454.toChar(); // 🧊 61454 (f00e) : Day-Storm-Showers
                
            case Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW: // Nuageux avec risque de neige
                if (isNight) {
                    return 61499.toChar(); // ❄️ 61499 (f03b) : Night-Alt-Snow
                } else {
                    return 61449.toChar(); // 🌨️ 61449 (f009) : Day-Snow
                }
                
            // --- Orages / Extrême / Autre (Pas de distinction jour/nuit nécessaire ici) ---
            case Weather.CONDITION_THUNDERSTORMS: // Orages
            case Weather.CONDITION_SCATTERED_THUNDERSTORMS: // Orages épars
            case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS: // Risque d'orages
                return 61469.toChar(); // ⚡ 61469 (f01d) : Thunderstorm
                
            case Weather.CONDITION_TORNADO: // Tornade
                return 61506.toChar(); // 🌪️ 61506 (f03e) : Tornado
                
            case Weather.CONDITION_HURRICANE: // Ouragan
            case Weather.CONDITION_TROPICAL_STORM: // Tempête tropicale
                return 61556.toChar(); // 🌀 61556 (f06c) : Hurricane
                
            case Weather.CONDITION_FOG: // Brouillard
            case Weather.CONDITION_MIST: // Brume
                return 61460.toChar(); // 🌫️ 61460 (f014) : Fog
                
            case Weather.CONDITION_HAZY: // Brume légère
            case Weather.CONDITION_HAZE: // Brume sèche / Voile
            case Weather.CONDITION_SMOKE: // Fumée
                return 61463.toChar(); // 🌫️ 61463 (f017) : Smoke
                
            case Weather.CONDITION_WINDY: // Venteux
            case Weather.CONDITION_SQUALL: // Rafale (Bourrasque)
                return 61473.toChar(); // 🌬️ 61473 (f021) : Windy
                
            case Weather.CONDITION_DUST: // Poussière
            case Weather.CONDITION_SAND: // Sable
            case Weather.CONDITION_SANDSTORM: // Tempête de sable
            case Weather.CONDITION_VOLCANIC_ASH: // Cendres volcaniques
                return 61510.toChar(); // 🌬️ 61510 (f02e) : Dust
                
            case Weather.CONDITION_HAIL: // Grêle
                return 61452.toChar(); // 🧊 61452 (f00c) : Hail
                
            // --- Inconnu ---
            case Weather.CONDITION_UNKNOWN_PRECIPITATION: // Précipitations inconnues
            case Weather.CONDITION_UNKNOWN: // Inconnu
            default:
                return 61537.toChar(); // ❓ 61537 (f081) : Question-Signe (Fallback)
        }
    }

    // Fonction de mise à jour de la météo (appelée par le timer)
    function updateWeather() as Void {
        temperature = Weather.getCurrentConditions().temperature.toNumber().toString() + "*";
        temperatureLogo = getWeatherIcon();
        // Forcer le redessin de la vue après la mise à jour des données
        WatchUi.requestUpdate(); 
    }

    // Nettoyage à l'arrêt (bonne pratique)
    function onStop() as Void {
        mWeatherTimer.stop();
    }

    function isSunDown() as Boolean {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour;
        if (hour >= 18 || hour < 7) {
            return true;
        }
        return false;
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
