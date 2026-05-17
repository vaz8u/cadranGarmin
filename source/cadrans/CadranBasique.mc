import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

// ==========================================
// CADRAN : VIDE (Template)
// ==========================================
// Cadran minimaliste servant de modèle pour
// créer de nouvelles watchfaces. Affiche uniquement
// l'heure en blanc sur fond noir, dessinée
// directement sur le DC (pas de layout/labels).
//
// Pour créer un nouveau cadran à partir de celui-ci :
//   1. Copier ce fichier et renommer la classe
//   2. Personnaliser le rendu dans mettre_a_jour_apres()
//   3. Ajouter des composants selon les besoins
//   4. Enregistrer dans RegistreCadrans

class CadranBasique extends CadranBase {


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
        return "Basique Digital"; 
    }

    function fond_jour() as ResourceId? { 
        return null; 
    }

    function fond_nuit() as ResourceId? { 
        return null; 
    }

    function obtenir_layout_jour(dc as Graphics.Dc) as Array<WatchUi.Drawable> { 
        return Rez.Layouts.WatchFaceDigitalBasique(dc); 
    }

    function obtenir_layout_nuit(dc as Graphics.Dc) as Array<WatchUi.Drawable> { 
        return Rez.Layouts.WatchFaceDigitalBasique(dc); 
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
