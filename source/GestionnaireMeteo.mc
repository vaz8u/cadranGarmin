import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.Weather;
import Toybox.Time;
import Toybox.Position;
import Toybox.WatchUi;

// ==========================================
// GESTIONNAIRE MÉTÉO
// ==========================================
// Gère la récupération et le cache des données
// météo (température, icône) et des éphémérides
// (lever/coucher du soleil pour le mode jour/nuit).

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
