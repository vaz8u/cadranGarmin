import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

// ==========================================
// COMPOSANT : DATE
// ==========================================
// Affiche la date (jour de la semaine + numéro)
// centrée dans sa zone, avec cache pour éviter
// les recalculs inutiles.

class ComposantDate {

    private var police_date_ as Resource?;
    private var lbl_date_ as WatchUi.Text?;
    private var centre_x_date_ as Number?;
    private var date_cache_texte_ as String = "";
    private var date_largeur_cache_ as Number = 0;

    const LARGEUR_ZONE_DATE = 90;

    function initialize() {}

    // Attache la police et récupère le label depuis la vue
    function initialiser(vue as WatchUi.View, police as Resource?) as Void {
        police_date_ = police;
        lbl_date_ = vue.findDrawableById("DayNameLabel") as WatchUi.Text?;

        if (police_date_ != null && lbl_date_ != null) { 
            lbl_date_.setFont(police_date_); 
            centre_x_date_ = lbl_date_.locX + (LARGEUR_ZONE_DATE / 2);
        }
    }

    // Met à jour l'affichage de la date
    function mettre_a_jour(dc as Graphics.Dc) as Void {
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
}
