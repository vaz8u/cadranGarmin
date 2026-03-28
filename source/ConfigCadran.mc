import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// ==========================================
// MODULE DE CONFIGURATION DES CADRANS
// ==========================================
// Pour ajouter un nouveau cadran :
// 1. Ajouter les bitmaps jour/nuit dans resources/
// 2. Ajouter les layouts jour/nuit dans resources/layouts/layout.xml
// 3. Déclarer les bitmaps dans resources/drawables/drawables.xml
// 4. Ajouter une entrée dans CADRANS ci-dessous
// 5. Ajouter l'entrée dans resources.xml (settings) et strings.xml

module ConfigCadran {

    // Clés de configuration
    const CLE_NOM = :nom;
    const CLE_FOND_JOUR = :fond_jour;
    const CLE_FOND_NUIT = :fond_nuit;
    const CLE_LAYOUT_JOUR = :layout_jour;
    const CLE_LAYOUT_NUIT = :layout_nuit;
    const CLE_METEO = :meteo;
    const CLE_AIGUILLES = :aiguilles;
    const CLE_IMG_HEURE = :img_heure;
    const CLE_IMG_MINUTE = :img_minute;
    const CLE_IMG_SECONDE = :img_seconde;
    const CLE_IMG_GAUCHE = :img_gauche;
    const CLE_IMG_DROITE = :img_droite;
    const CLE_IMG_BAS = :img_bas;

    // === TABLEAU DES CADRANS ===

    function obtenir_config(index as Number) as Dictionary {
        if (index == 1) {
            return {
                CLE_NOM => "Casio Analog",
                CLE_FOND_JOUR => Rez.Drawables.omega1,
                CLE_FOND_NUIT => Rez.Drawables.omega1,
                CLE_LAYOUT_JOUR => :layout_jour_1,
                CLE_LAYOUT_NUIT => :layout_nuit_1,
                CLE_METEO => false,
                CLE_AIGUILLES => true,
                CLE_IMG_HEURE => Rez.Drawables.aiguille_heure,
                CLE_IMG_MINUTE => Rez.Drawables.aiguille_minute,
                CLE_IMG_SECONDE => Rez.Drawables.aiguille_seconde,
                CLE_IMG_GAUCHE => Rez.Drawables.aiguille_gauche,
                CLE_IMG_DROITE => Rez.Drawables.aiguille_droite,
                CLE_IMG_BAS => Rez.Drawables.aiguille_bas,
            };
        }
        if (index == 0) {
            return {
                CLE_NOM => "Casio Digital",
                CLE_FOND_JOUR => Rez.Drawables.g1,
                CLE_FOND_NUIT => Rez.Drawables.g2,
                CLE_LAYOUT_JOUR => :layout_jour_0,
                CLE_LAYOUT_NUIT => :layout_nuit_0,
                CLE_METEO => true,
                CLE_AIGUILLES => false,
                CLE_IMG_HEURE => null,
                CLE_IMG_MINUTE => null,
                CLE_IMG_SECONDE => null,
            };
        }
        // Cadran par défaut = 0
        return obtenir_config(0);
    }

    function obtenir_layout_jour(index as Number, dc as Graphics.Dc) as Array<WatchUi.Drawable> {
        if (index == 0) { return Rez.Layouts.WatchFace(dc); }
        if (index == 1) { return Rez.Layouts.WatchFaceAnalog(dc); }
        // Défaut
        return Rez.Layouts.WatchFace(dc);
    }

    function obtenir_layout_nuit(index as Number, dc as Graphics.Dc) as Array<WatchUi.Drawable> {
        if (index == 0) { return Rez.Layouts.WatchFaceNight(dc); }
        if (index == 1) { return Rez.Layouts.WatchFaceAnalogNight(dc); }
        // Défaut
        return Rez.Layouts.WatchFaceNight(dc);
    }

    function nombre_cadrans() as Number {
        return 2;
    }

    function obtenir_nom(index as Number) as String {
        var config = obtenir_config(index);
        return config[CLE_NOM] as String;
    }
}
