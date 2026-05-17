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

class CadranVide extends CadranBase {

    function initialize(meteo as GestionnaireMeteo?) {
        CadranBase.initialize(meteo);
    }

    function nom() as String { 
        return "Vide (Template)"; 
    }

    // Pas de fond — on dessine directement
    function fond_jour() as ResourceId? { 
        return null; 
    }

    function fond_nuit() as ResourceId? { 
        return null; 
    }

    // Layout vide
    function obtenir_layout_jour(dc as Graphics.Dc) as Array<WatchUi.Drawable> { 
        return Rez.Layouts.WatchFaceVide(dc); 
    }

    function obtenir_layout_nuit(dc as Graphics.Dc) as Array<WatchUi.Drawable> { 
        return Rez.Layouts.WatchFaceVide(dc); 
    }

    function affiche_meteo() as Boolean { 
        return false; 
    }

    // Dessine l'heure directement sur le DC
    function mettre_a_jour_apres(dc as Graphics.Dc, en_basse_conso as Boolean) as Void {
        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;
        var t = System.getClockTime();

        // Fond noir
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Heure centrée en blanc
        var heure_txt = t.hour.format("%02d") + ":" + t.min.format("%02d");
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 30, Graphics.FONT_NUMBER_HOT, heure_txt, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Secondes (sauf en basse consommation)
        if (!en_basse_conso) {
            var sec_txt = t.sec.format("%02d");
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + 30, Graphics.FONT_MEDIUM, sec_txt, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Date en bas
        var info = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var date_txt = info.day_of_week + " " + info.day.format("%02d");
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 70, Graphics.FONT_SMALL, date_txt, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
