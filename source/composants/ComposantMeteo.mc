import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// ==========================================
// COMPOSANT : MÉTÉO
// ==========================================
// Affiche l'icône météo et la température,
// avec positionnement dynamique de la température
// par rapport à la largeur de l'icône.

class ComposantMeteo {

    private var police_meteo_ as Resource?;
    private var police_date_ as Resource?;
    private var lbl_icon_ as WatchUi.Text?;
    private var lbl_temp_ as WatchUi.Text?;
    private var gestionnaire_meteo_ as GestionnaireMeteo?;

    const ESPACE_ICONE_TEMP = 20;

    function initialize() {}

    // Attache les polices, les labels et le gestionnaire météo
    function initialiser(vue as WatchUi.View, meteo as GestionnaireMeteo?, 
                         police_meteo as Resource?, police_date as Resource?) as Void {
        gestionnaire_meteo_ = meteo;
        police_meteo_ = police_meteo;
        police_date_ = police_date;

        lbl_icon_ = vue.findDrawableById("WeatherIcon") as WatchUi.Text?;
        lbl_temp_ = vue.findDrawableById("TemperatureLabel") as WatchUi.Text?;

        if (police_date_ != null && lbl_temp_ != null) { 
            lbl_temp_.setFont(police_date_); 
        }
        if (police_meteo_ != null && lbl_icon_ != null) { 
            lbl_icon_.setFont(police_meteo_); 
        }
    }

    // Met à jour l'affichage de la météo
    function mettre_a_jour(dc as Graphics.Dc) as Void {
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
}
