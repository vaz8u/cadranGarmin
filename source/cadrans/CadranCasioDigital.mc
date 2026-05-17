import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// ==========================================
// CADRAN : CASIO DIGITAL
// ==========================================
// Watchface digitale style Casio avec :
//   - Heure digitale LCD (ComposantHeureDigitale)
//   - Date centrée (ComposantDate)
//   - Météo avec icône (ComposantMeteo)
// Fond : g1.png (jour) / g2_n.png (nuit)

class CadranCasioDigital extends CadranBase {

    private var composant_heure_ as ComposantHeureDigitale?;
    private var composant_date_ as ComposantDate?;
    private var composant_meteo_ as ComposantMeteo?;

    function initialize(meteo as GestionnaireMeteo?) {
        CadranBase.initialize(meteo);
        composant_heure_ = new ComposantHeureDigitale();
        composant_date_ = new ComposantDate();
        composant_meteo_ = new ComposantMeteo();
    }

    function nom() as String { 
        return "Casio Digital"; 
    }

    function fond_jour() as ResourceId? { 
        return Rez.Drawables.g1; 
    }

    function fond_nuit() as ResourceId? { 
        return Rez.Drawables.g2; 
    }

    function obtenir_layout_jour(dc as Graphics.Dc) as Array<WatchUi.Drawable> { 
        return Rez.Layouts.WatchFace(dc); 
    }

    function obtenir_layout_nuit(dc as Graphics.Dc) as Array<WatchUi.Drawable> { 
        return Rez.Layouts.WatchFaceNight(dc); 
    }

    function affiche_meteo() as Boolean { 
        return true; 
    }

    function initialiser_labels(vue as WatchUi.View, polices as Dictionary) as Void {
        var p_dig = polices[:digitale];
        var p_dig_p = polices[:digitale_petite];
        var p_date = polices[:date];
        var p_meteo = polices[:meteo];

        if (composant_heure_ != null) {
            composant_heure_.initialiser(vue, p_dig, p_dig_p);
        }
        if (composant_date_ != null) {
            composant_date_.initialiser(vue, p_date);
        }
        if (composant_meteo_ != null) {
            composant_meteo_.initialiser(vue, gestionnaire_meteo_, p_meteo, p_date);
        }
    }

    function mettre_a_jour_avant(dc as Graphics.Dc, en_basse_conso as Boolean) as Void {
        if (composant_heure_ != null) {
            composant_heure_.mettre_a_jour_fond_dynamique(en_basse_conso);
        }
        if (composant_date_ != null) {
            composant_date_.mettre_a_jour(dc);
        }
        if (composant_meteo_ != null) {
            composant_meteo_.mettre_a_jour(dc);
        }
        if (composant_heure_ != null) {
            composant_heure_.mettre_a_jour(en_basse_conso);
        }
    }
}
