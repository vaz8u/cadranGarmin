import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// ==========================================
// COMPOSANT : HEURE DIGITALE (style LCD)
// ==========================================
// Affiche l'heure en chiffres digitaux avec un
// fond "8" (effet LCD) et gère le mode basse consommation.

class Constantes {
    // Chiffres pour affichage digital
    static const CHIFFRES = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] as Array<String>;
}

class ComposantHeureDigitale {

    // Polices
    private var police_digitale_ as Resource?;
    private var police_digitale_petite_ as Resource?;

    // Labels principaux
    private var lbl_heure_1_ as WatchUi.Text?;
    private var lbl_heure_2_ as WatchUi.Text?;
    private var lbl_min_1_ as WatchUi.Text?;
    private var lbl_min_2_ as WatchUi.Text?;
    private var lbl_sec_1_ as WatchUi.Text?;
    private var lbl_sec_2_ as WatchUi.Text?;
    private var lbl_colon_ as WatchUi.Text?;

    // Labels fond LCD
    private var lbl_bg_sec_1_ as WatchUi.Text?;
    private var lbl_bg_sec_2_ as WatchUi.Text?;

    function initialize() {}

    // Attache les polices et récupère les labels depuis la vue
    function initialiser(vue as WatchUi.View, police_grande as Resource?, police_petite as Resource?) as Void {
        police_digitale_ = police_grande;
        police_digitale_petite_ = police_petite;

        lbl_heure_1_ = vue.findDrawableById("HourLabel") as WatchUi.Text?;
        lbl_heure_2_ = vue.findDrawableById("HourLabel2") as WatchUi.Text?;
        lbl_min_1_   = vue.findDrawableById("MinuteLabel") as WatchUi.Text?;
        lbl_min_2_   = vue.findDrawableById("MinuteLabel2") as WatchUi.Text?;
        lbl_sec_1_   = vue.findDrawableById("SecondLabel") as WatchUi.Text?;
        lbl_sec_2_   = vue.findDrawableById("SecondLabel2") as WatchUi.Text?;
        lbl_colon_   = vue.findDrawableById("ColonLabel") as WatchUi.Text?;
        lbl_bg_sec_1_ = vue.findDrawableById("_SecondLabel") as WatchUi.Text?;
        lbl_bg_sec_2_ = vue.findDrawableById("_SecondLabel2") as WatchUi.Text?;

        dessiner_fond_statique(vue);
    }

    // Met à jour les chiffres de l'heure
    function mettre_a_jour(en_basse_conso as Boolean) as Void {
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
        
        if (!en_basse_conso) {
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

    // Met à jour les "8" de fond pour les secondes (dynamique car dépend du mode basse conso)
    function mettre_a_jour_fond_dynamique(en_basse_conso as Boolean) as Void {
        var txt = en_basse_conso ? "" : "8";
        if (lbl_bg_sec_1_ != null && police_digitale_petite_ != null) {
            lbl_bg_sec_1_.setFont(police_digitale_petite_);
            lbl_bg_sec_1_.setText(txt);
        }
        if (lbl_bg_sec_2_ != null && police_digitale_petite_ != null) {
            lbl_bg_sec_2_.setFont(police_digitale_petite_);
            lbl_bg_sec_2_.setText(txt);
        }
    }

    // Dessine les "8" de fond pour les heures/minutes (statique)
    private function dessiner_fond_statique(vue as WatchUi.View) as Void {
        set_texte_statique(vue, "_HourLabel", police_digitale_, "8");
        set_texte_statique(vue, "_HourLabel2", police_digitale_, "8");
        set_texte_statique(vue, "_MinuteLabel", police_digitale_, "8");
        set_texte_statique(vue, "_MinuteLabel2", police_digitale_, "8");
    }

    private function set_texte_statique(vue as WatchUi.View, id as String, font as Resource?, txt as String) as Void {
        if (font == null) { return; }
        var d = vue.findDrawableById(id) as WatchUi.Text?;
        if (d != null) {
            d.setFont(font);
            d.setText(txt);
        }
    }
}
