import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Timer;
import Toybox.Weather;
import Toybox.Application;
import Toybox.Position;

class Constantes {
    // Chiffres pour affichage digital
    static const CHIFFRES = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] as Array<String>;
}

class GestionnaireMeteo {
    // Données météo mises en cache
    private var timer_meteo_ as Timer.Timer?;
    private var temperature_cache_ as String = "--*";
    private var icone_cache_ as String = ""; 
    
    // Éphémérides
    private var moment_lever_ as Time.Moment?;
    private var moment_coucher_ as Time.Moment?;
    
    // Détection changement de jour
    private var jour_dernier_calcul_ as Time.Moment?;

    // Initialise le timer et l'icone par défaut
    function initialize() {
        timer_meteo_ = new Timer.Timer();
        icone_cache_ = 61537.toChar().toString();
    }

    // Démarre le service de mise à jour périodique
    function demarrer_service() as Void {
        timer_meteo_.start(method(:sur_mise_a_jour_timer), 900000, true);
        mettre_a_jour_donnees();
    }

    // Arrête le service
    function arreter_service() as Void {
        if (timer_meteo_ != null) { timer_meteo_.stop(); }
    }

    // Fonction appelée périodiquement pour mettre à jour les données
    function sur_mise_a_jour_timer() as Void {
        mettre_a_jour_donnees();
    }

    // Met à jour les données d'affichage météo et éphémérides
    function mettre_a_jour_donnees() as Void {
        // Température
        var conditions = Weather.getCurrentConditions();
        if (conditions != null && conditions.temperature != null) {
            temperature_cache_ = conditions.temperature.format("%d") + "*";
        } else {
            temperature_cache_ = "--*";
        }
        
        // Soleil (Force le calcul)
        rafraichir_ephemerides_si_necessaire(true);

        // Icône
        var char_icone = determiner_icone(conditions);
        icone_cache_ = char_icone.toString();
        
        WatchUi.requestUpdate();
    }

    // Calcul des éphémérides
    private function rafraichir_ephemerides_si_necessaire(forcer as Boolean) as Void {
        var aujourdhui = Time.today();
        
        // Si on a déjà calculé pour aujourd'hui et qu'on ne force pas, on sort.
        if (!forcer && jour_dernier_calcul_ != null && jour_dernier_calcul_.equals(aujourdhui)) {
            return;
        }

        var info_position = Position.getInfo();
        // Vérification de sécurité sur la position
        if (info_position.position != null) {
            var location = info_position.position;
            var maintenant = Time.now();
            
            // On demande à la montre les heures pour le moment donné
            moment_lever_ = Weather.getSunrise(location, maintenant);
            moment_coucher_ = Weather.getSunset(location, maintenant);
            
            jour_dernier_calcul_ = aujourdhui;
        }
    }

    function lire_temperature() as String { 
        return temperature_cache_; 
    }

    function lire_icone() as String { 
        return icone_cache_; 
    }

    function est_il_nuit() as Boolean {
        // On vérifie si la date a changé (Saut dans le temps)
        rafraichir_ephemerides_si_necessaire(false);

        // Comparaison précise
        if (moment_lever_ != null && moment_coucher_ != null) {
            var maintenant = Time.now();
            // Nuit si avant le lever OU après le coucher
            return (maintenant.lessThan(moment_lever_) || maintenant.greaterThan(moment_coucher_));
        }

        // Fallback (Pas de GPS) : 18h - 7h
        var h = System.getClockTime().hour;
        return (h >= 18 || h < 7);
    }

    // Détermine l'icône météo à afficher en fonction des conditions et du moment de la journée
    private function determiner_icone(conditions as Weather.CurrentConditions?) as Char {
        var est_nuit = est_il_nuit();
        if (conditions == null || conditions.condition == null) { return 61443.toChar(); }
        
        var c = conditions.condition;
        // Mapping Météo
        if (c == Weather.CONDITION_CLEAR || c == Weather.CONDITION_FAIR || c == Weather.CONDITION_MOSTLY_CLEAR || c == Weather.CONDITION_PARTLY_CLEAR) {
            return est_nuit ? 61486.toChar() : 61453.toChar();
        }
        if (c == Weather.CONDITION_PARTLY_CLOUDY || c == Weather.CONDITION_MOSTLY_CLOUDY) {
            return est_nuit ? 61489.toChar() : 61442.toChar();
        }
        if (c == Weather.CONDITION_RAIN || c == Weather.CONDITION_SHOWERS || c == Weather.CONDITION_HEAVY_RAIN) {
             return est_nuit ? 61494.toChar() : 61444.toChar();
        }
        if (c == Weather.CONDITION_SNOW || c == Weather.CONDITION_HEAVY_SNOW) { return 61466.toChar(); }
        if (c == Weather.CONDITION_THUNDERSTORMS) { return 61469.toChar(); }
        
        return 61453.toChar(); 
    }
}

// ==========================================
// CLASSE PRINCIPALE : VUE CADRAN
// ==========================================
class VueCadran extends WatchUi.WatchFace {
    
    // Police 
    private var police_digitale_ as Resource?;
    private var police_digitale_petite_ as Resource?;
    private var police_date_ as Resource?;
    private var police_meteo_ as Resource?;
    
    // Images
    private var image_fond_ as Resource?;
    private var bitmap_fond_ as WatchUi.Bitmap?;
    
    // Gestionnaire Météo
    private var gestionnaire_meteo_ as GestionnaireMeteo?;

    // États
    private var est_mode_nuit_ as Boolean = false;
    private var en_basse_consommation_ as Boolean = false;
    private var type_affichage_ as Number = 2;
    
    // Objets Texte 
    private var lbl_heure_1_ as Text?;
    private var lbl_heure_2_ as Text?;
    private var lbl_min_1_ as Text?;
    private var lbl_min_2_ as Text?;
    private var lbl_sec_1_ as Text?;
    private var lbl_sec_2_ as Text?;
    private var lbl_colon_ as Text?;
    private var lbl_bg_sec_1_ as Text?;
    private var lbl_bg_sec_2_ as Text?;
    private var lbl_date_ as Text?;
    private var lbl_temp_ as Text?;
    private var lbl_icon_ as Text?;

    // Date
    private var centre_x_date_ as Number?;
    private var date_cache_texte_ as String = "";
    private var date_largeur_cache_ as Number = 0;

    // Constantes
    const LARGEUR_ZONE_DATE = 90; 
    const ESPACE_ICONE_TEMP = 20; 

    function initialize() {
        WatchFace.initialize();
        gestionnaire_meteo_ = new GestionnaireMeteo();
        charger_reglages();
    }

    function onShow() as Void {
        assurer_polices_chargees();
        if (gestionnaire_meteo_ != null) { gestionnaire_meteo_.demarrer_service(); }
    }

    function onStop() as Void {
        if (gestionnaire_meteo_ != null) { gestionnaire_meteo_.arreter_service(); }
    }

    function onEnterSleep() as Void {
        en_basse_consommation_ = true;
        WatchUi.requestUpdate(); 
    }

    function onExitSleep() as Void {
        en_basse_consommation_ = false;
        WatchUi.requestUpdate();
    }

    private function assurer_polices_chargees() as Void {
        if (police_digitale_ == null) {
            police_digitale_petite_ = WatchUi.loadResource(Rez.Fonts.ds_digital_b_i_s);
            police_digitale_ = WatchUi.loadResource(Rez.Fonts.ds_digital_b_i);
            police_date_ = WatchUi.loadResource(Rez.Fonts.font_date);
            police_meteo_ = WatchUi.loadResource(Rez.Fonts.font_weather);
        }
    }

    private function rafraichir_pointeurs_objets() as Void {
        lbl_heure_1_ = View.findDrawableById("HourLabel") as Text;
        lbl_heure_2_ = View.findDrawableById("HourLabel2") as Text;
        lbl_min_1_   = View.findDrawableById("MinuteLabel") as Text;
        lbl_min_2_   = View.findDrawableById("MinuteLabel2") as Text;
        lbl_sec_1_   = View.findDrawableById("SecondLabel") as Text;
        lbl_sec_2_   = View.findDrawableById("SecondLabel2") as Text;
        lbl_colon_   = View.findDrawableById("ColonLabel") as Text;
        
        lbl_bg_sec_1_ = View.findDrawableById("_SecondLabel") as Text;
        lbl_bg_sec_2_ = View.findDrawableById("_SecondLabel2") as Text;
        
        lbl_date_ = View.findDrawableById("DayNameLabel") as Text;
        lbl_temp_ = View.findDrawableById("TemperatureLabel") as Text;
        lbl_icon_ = View.findDrawableById("WeatherIcon") as Text;

        if (police_date_ != null) { 
            lbl_date_.setFont(police_date_); 
            centre_x_date_ = lbl_date_.locX + (LARGEUR_ZONE_DATE / 2);
        }

        if (police_date_ != null) { 
            lbl_temp_.setFont(police_date_); 
        }

        if (police_meteo_ != null) { 
            lbl_icon_.setFont(police_meteo_); 
        }
        
        dessiner_chiffres_fond_static();
    }

    function onLayout(dc as Dc) as Void {
        assurer_polices_chargees();
        appliquer_layout_selon_heure(dc);
        rafraichir_pointeurs_objets();
    }

    function onUpdate(dc as Dc) as Void {
        dc.clear();

        // On vérifie TOUJOURS si on doit changer de layout (Jour/Nuit).
        appliquer_layout_selon_heure(dc);

        // On dessine le fond
        if (bitmap_fond_ != null) {
            bitmap_fond_.draw(dc);
        }

        dessiner_chiffres_fond_dynamique(); 
        mettre_a_jour_date(dc);
        mettre_a_jour_meteo(dc);
        mettre_a_jour_heure_optimisee(); 

        View.onUpdate(dc);
    }

    // Rechargement des réglages
    public function recharger_configuration_externe() as Void {
        charger_reglages();
        bitmap_fond_ = null; 
        WatchUi.requestUpdate();
    }

    // Chargement des réglages depuis les propriétés
    private function charger_reglages() as Void {
        var v = Application.Properties.getValue("affichage");
        type_affichage_ = (v instanceof Number) ? v : 2;
    }

    // Applique le layout Jour/Nuit selon l'heure et les réglages
    private function appliquer_layout_selon_heure(dc as Dc) as Void {
        // Logique Jour/Nuit Automatique via GestionnaireMeteo
        var est_nuit_reelle = false;
        if (gestionnaire_meteo_ != null) {
            est_nuit_reelle = gestionnaire_meteo_.est_il_nuit();
        } else {
            var h = System.getClockTime().hour;
            est_nuit_reelle = (h >= 18 || h < 7);
        }

        var target = false;
        if (type_affichage_ == 1) { 
            target = true; 
        } 
        else if (type_affichage_ == 0) { 
            target = false; 
        }
        else { 
            target = est_nuit_reelle; 
        }

        if (est_mode_nuit_ == target && bitmap_fond_ != null) { return; }
        
        var res = target ? Rez.Drawables.g2 : Rez.Drawables.g1;
        est_mode_nuit_ = target;
        
        setLayout(target ? Rez.Layouts.WatchFaceNight(dc) : Rez.Layouts.WatchFace(dc));
        rafraichir_pointeurs_objets(); 
        
        image_fond_ = WatchUi.loadResource(res);
        bitmap_fond_ = new WatchUi.Bitmap({
            :bitmap => image_fond_,
            :locX => ((dc.getWidth() - image_fond_.getWidth()) / 2),
            :locY => ((dc.getHeight() - image_fond_.getHeight()) / 2)
        });
    }

    // Mise à jour optimisée de l'heure
    private function mettre_a_jour_heure_optimisee() as Void {
        if (police_digitale_ == null) { return; }
        var t = System.getClockTime();
        
        if (lbl_heure_1_ != null) { 
            lbl_heure_1_.setFont(police_digitale_);
            lbl_heure_1_.setText(Constantes.CHIFFRES[t.hour / 10]); 
        }
        if (lbl_heure_2_ != null) { 
            lbl_heure_2_.setFont(police_digitale_);
            lbl_heure_2_.setText(Constantes.CHIFFRES[t.hour % 10]); 
        }
        if (lbl_min_1_ != null) { 
            lbl_min_1_.setFont(police_digitale_);
            lbl_min_1_.setText(Constantes.CHIFFRES[t.min / 10]); 
        }
        if (lbl_min_2_ != null) { 
            lbl_min_2_.setFont(police_digitale_);
            lbl_min_2_.setText(Constantes.CHIFFRES[t.min % 10]); 
        }
        
        if (!en_basse_consommation_) {
            if (police_digitale_petite_ != null) {
                if (lbl_sec_1_ != null) { 
                    lbl_sec_1_.setFont(police_digitale_petite_);
                    lbl_sec_1_.setText(Constantes.CHIFFRES[t.sec / 10]); 
                }
                if (lbl_sec_2_ != null) { 
                    lbl_sec_2_.setFont(police_digitale_petite_);
                    lbl_sec_2_.setText(Constantes.CHIFFRES[t.sec % 10]); 
                }
            }
            if (lbl_colon_ != null) {
                lbl_colon_.setFont(police_digitale_);
                lbl_colon_.setText(":");
            }
        } else {
            if (lbl_sec_1_ != null) { lbl_sec_1_.setText(""); }
            if (lbl_sec_2_ != null) { lbl_sec_2_.setText(""); }
            if (lbl_colon_ != null) { lbl_colon_.setText(" "); }
        }
    }

    // Mise à jour de la date
    private function mettre_a_jour_date(dc as Dc) as Void {
        if (lbl_date_ == null || centre_x_date_ == null || police_date_ == null) { return; }

        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var texte = info.day_of_week + "-" + info.day.format("%02d");

        if (texte.equals(date_cache_texte_)) {
            lbl_date_.setText(texte);
            var x = centre_x_date_ - (date_largeur_cache_ / 2);
            lbl_date_.setLocation(x, lbl_date_.locY);
            return;
        }

        date_cache_texte_ = texte;
        lbl_date_.setText(texte);
        date_largeur_cache_ = dc.getTextWidthInPixels(texte, police_date_);
        var nouveau_x = centre_x_date_ - (date_largeur_cache_ / 2);
        lbl_date_.setLocation(nouveau_x, lbl_date_.locY);
    }

    // Mise à jour de la météo
    private function mettre_a_jour_meteo(dc as Dc) as Void {
        if (gestionnaire_meteo_ == null || lbl_icon_ == null || lbl_temp_ == null) { return; }
        if (police_meteo_ == null || police_date_ == null) { return; }
        
        var iconText = gestionnaire_meteo_.lire_icone();
        var tempText = gestionnaire_meteo_.lire_temperature();

        lbl_icon_.setText(iconText);
        var largeur_icone = dc.getTextWidthInPixels(iconText, police_meteo_);
        var pos_x = lbl_icon_.locX + largeur_icone + ESPACE_ICONE_TEMP;

        lbl_temp_.setText(tempText);
        lbl_temp_.setLocation(pos_x, lbl_temp_.locY);
    }

    // Dessine les chiffres de fond statiques
    private function dessiner_chiffres_fond_static() as Void {
        set_static_text("_HourLabel", police_digitale_, "8");
        set_static_text("_HourLabel2", police_digitale_, "8");
        set_static_text("_MinuteLabel", police_digitale_, "8");
        set_static_text("_MinuteLabel2", police_digitale_, "8");
    }

    // Dessine les chiffres de fond dynamiques
    private function dessiner_chiffres_fond_dynamique() as Void {
        var txt = en_basse_consommation_ ? "" : "8";
        if (lbl_bg_sec_1_ != null && police_digitale_petite_ != null) {
            lbl_bg_sec_1_.setFont(police_digitale_petite_);
            lbl_bg_sec_1_.setText(txt);
        }
        if (lbl_bg_sec_2_ != null && police_digitale_petite_ != null) {
            lbl_bg_sec_2_.setFont(police_digitale_petite_);
            lbl_bg_sec_2_.setText(txt);
        }
    }

    // Mise à jour d'un texte statique
    private function set_static_text(id as String, font as Resource?, txt as String) as Void {
        if (font == null) { return; }
        var d = View.findDrawableById(id) as Text;
        d.setFont(font);
        d.setText(txt);
    }
}