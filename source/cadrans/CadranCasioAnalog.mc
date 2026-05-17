import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// ==========================================
// CADRAN : CASIO ANALOG
// ==========================================
// Watchface analogique avec :
//   - Aiguilles heures/minutes/secondes (ComposantAiguilles)
//   - Sous-cadrans gauche/droite/bas
// Fond : omega1.png (jour et nuit)

class CadranCasioAnalog extends CadranBase {

    private var composant_aiguilles_ as ComposantAiguilles?;

    function initialize(meteo as GestionnaireMeteo?) {
        CadranBase.initialize(meteo);
        composant_aiguilles_ = new ComposantAiguilles();
    }

    function nom() as String { 
        return "Casio Analog"; 
    }

    function fond_jour() as ResourceId? { 
        return Rez.Drawables.omega1; 
    }

    function fond_nuit() as ResourceId? { 
        return Rez.Drawables.omega1; 
    }

    function obtenir_layout_jour(dc as Graphics.Dc) as Array<WatchUi.Drawable> { 
        return Rez.Layouts.WatchFaceAnalog(dc); 
    }

    function obtenir_layout_nuit(dc as Graphics.Dc) as Array<WatchUi.Drawable> { 
        return Rez.Layouts.WatchFaceAnalogNight(dc); 
    }

    function affiche_meteo() as Boolean { 
        return false; 
    }

    function charger_ressources() as Void {
        if (composant_aiguilles_ != null) {
            composant_aiguilles_.charger(
                Rez.Drawables.aiguille_heure,
                Rez.Drawables.aiguille_minute,
                Rez.Drawables.aiguille_seconde,
                Rez.Drawables.aiguille_gauche,
                Rez.Drawables.aiguille_droite,
                Rez.Drawables.aiguille_bas
            );
        }
    }

    function liberer_ressources() as Void {
        if (composant_aiguilles_ != null) {
            composant_aiguilles_.liberer();
        }
    }

    function mettre_a_jour_apres(dc as Graphics.Dc, en_basse_conso as Boolean) as Void {
        if (composant_aiguilles_ != null) {
            composant_aiguilles_.dessiner(dc, en_basse_conso);
        }
    }
}
