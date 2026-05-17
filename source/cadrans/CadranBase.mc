import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// ==========================================
// CLASSE DE BASE : CADRAN
// ==========================================
// Classe mère que chaque watchface étend.
// Fournit des implémentations par défaut (ne rien faire)
// pour toutes les méthodes du cycle de vie.
//
// Pour créer un nouveau cadran :
//   1. Créer une classe qui étend CadranBase
//   2. Surcharger les méthodes nécessaires
//   3. Enregistrer dans RegistreCadrans

class CadranBase {

    protected var gestionnaire_meteo_ as GestionnaireMeteo?;

    function initialize(meteo as GestionnaireMeteo?) {
        gestionnaire_meteo_ = meteo;
    }

    // --- Identité ---

    // Nom affiché dans le menu de sélection
    function nom() as String { 
        return "Base"; 
    }

    // --- Ressources fond d'écran ---

    // ID ressource du fond de jour (null = pas de fond)
    function fond_jour() as ResourceId? { 
        return null; 
    }

    // ID ressource du fond de nuit (null = pas de fond)
    function fond_nuit() as ResourceId? { 
        return null; 
    }

    // --- Layouts ---

    // Layout à utiliser en mode jour
    function obtenir_layout_jour(dc as Graphics.Dc) as Array<WatchUi.Drawable> { 
        return [] as Array<WatchUi.Drawable>; 
    }

    // Layout à utiliser en mode nuit
    function obtenir_layout_nuit(dc as Graphics.Dc) as Array<WatchUi.Drawable> { 
        return [] as Array<WatchUi.Drawable>; 
    }

    // --- Capacités ---

    // Indique si ce cadran affiche la météo
    function affiche_meteo() as Boolean { 
        return false; 
    }

    // --- Cycle de vie ---

    // Charge les ressources lourdes (bitmaps aiguilles, etc.)
    function charger_ressources() as Void {}

    // Libère les ressources lourdes
    function liberer_ressources() as Void {}

    // Appelé après chaque changement de layout pour récupérer les labels
    function initialiser_labels(vue as WatchUi.View, polices as Dictionary) as Void {}

    // --- Rendu ---

    // Appelé AVANT View.onUpdate(dc) — pour mettre à jour les labels
    function mettre_a_jour_avant(dc as Graphics.Dc, en_basse_conso as Boolean) as Void {}

    // Appelé APRÈS View.onUpdate(dc) — pour dessiner par-dessus (aiguilles, etc.)
    function mettre_a_jour_apres(dc as Graphics.Dc, en_basse_conso as Boolean) as Void {}
}
