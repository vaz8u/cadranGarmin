import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Application;

// ==========================================
// CLASSE PRINCIPALE : VUE CADRAN
// ==========================================
// Orchestrateur léger qui délègue le rendu
// au cadran actif (pattern Strategy).
// Ne contient plus de logique de rendu spécifique.

class VueCadran extends WatchUi.WatchFace {
    
    // Polices (partagées entre tous les cadrans)
    private var police_digitale_ as Resource?;
    private var police_digitale_petite_ as Resource?;
    private var police_date_ as Resource?;
    private var police_meteo_ as Resource?;
    
    // Image de fond
    private var image_fond_ as Resource?;
    private var bitmap_fond_ as WatchUi.Bitmap?;
    
    // Gestionnaire Météo (partagé)
    private var gestionnaire_meteo_ as GestionnaireMeteo?;

    // États
    private var est_mode_nuit_ as Boolean = false;
    private var en_basse_consommation_ as Boolean = false;
    private var type_affichage_ as Number = 2;
    
    // === CADRAN ACTIF (Strategy) ===
    private var cadran_index_ as Number = 0;
    private var cadran_actif_ as CadranBase?;

    function initialize() {
        WatchFace.initialize();
        gestionnaire_meteo_ = new GestionnaireMeteo();
        charger_reglages();
    }

    function onShow() as Void {
        assurer_polices_chargees();
        if (gestionnaire_meteo_ != null) { gestionnaire_meteo_.demarrer_service(); }
    }

    function onStop() as Void {
        if (gestionnaire_meteo_ != null) { gestionnaire_meteo_.arreter_service(); }
        if (cadran_actif_ != null) { cadran_actif_.liberer_ressources(); }
    }

    function onEnterSleep() as Void {
        en_basse_consommation_ = true;
        WatchUi.requestUpdate(); 
    }

    function onExitSleep() as Void {
        en_basse_consommation_ = false;
        WatchUi.requestUpdate();
    }

    private function assurer_polices_chargees() as Void {
        if (police_digitale_ == null) {
            police_digitale_petite_ = WatchUi.loadResource(Rez.Fonts.ds_digital_b_i_s);
            police_digitale_ = WatchUi.loadResource(Rez.Fonts.ds_digital_b_i);
            police_date_ = WatchUi.loadResource(Rez.Fonts.font_date);
            police_meteo_ = WatchUi.loadResource(Rez.Fonts.font_weather);
        }
    }

    // Construit le dictionnaire de polices pour les cadrans
    private function obtenir_polices() as Dictionary {
        return {
            :digitale => police_digitale_,
            :digitale_petite => police_digitale_petite_,
            :date => police_date_,
            :meteo => police_meteo_
        };
    }

    function onLayout(dc as Dc) as Void {
        assurer_polices_chargees();
        appliquer_layout_selon_heure(dc);
        if (cadran_actif_ != null) {
            cadran_actif_.initialiser_labels(self, obtenir_polices());
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.clear();

        // Vérifier si on doit changer de layout (Jour/Nuit)
        appliquer_layout_selon_heure(dc);

        // Dessiner le fond
        if (bitmap_fond_ != null) {
            bitmap_fond_.draw(dc);
        }

        // Phase 1 : Le cadran met à jour les labels (AVANT View.onUpdate)
        if (cadran_actif_ != null) {
            cadran_actif_.mettre_a_jour_avant(dc, en_basse_consommation_);
        }

        // Rendu des labels du layout
        View.onUpdate(dc);

        // Phase 2 : Le cadran dessine par-dessus (aiguilles, etc.)
        if (cadran_actif_ != null) {
            cadran_actif_.mettre_a_jour_apres(dc, en_basse_consommation_);
        }
    }

    // Rechargement des réglages depuis l'extérieur
    public function recharger_configuration_externe() as Void {
        System.println("Rechargement de la configuration...");
        var ancien_cadran = cadran_index_;
        charger_reglages();
        if (ancien_cadran != cadran_index_) {
            bitmap_fond_ = null;
            est_mode_nuit_ = !est_mode_nuit_;
        }
        bitmap_fond_ = null; 
        WatchUi.requestUpdate();
    }

    // Chargement des réglages depuis les propriétés
    private function charger_reglages() as Void {
        // Mode d'affichage (jour/nuit/auto)
        var v = Application.Properties.getValue("affichage");
        type_affichage_ = (v instanceof Number) ? v : 2;
        
        // Index du cadran sélectionné
        var c = Application.Properties.getValue("cadran");
        cadran_index_ = (c instanceof Number) ? c : 0;
        
        // Sécurité : valider l'index
        if (cadran_index_ < 0 || cadran_index_ >= RegistreCadrans.nombre_cadrans()) {
            cadran_index_ = 0;
        }
        
        // Libérer l'ancien cadran
        if (cadran_actif_ != null) {
            cadran_actif_.liberer_ressources();
        }

        // Créer le nouveau cadran via le registre
        cadran_actif_ = RegistreCadrans.creer_cadran(cadran_index_, gestionnaire_meteo_);
        cadran_actif_.charger_ressources();
        
        System.println("Cadran chargé: " + cadran_actif_.nom() + " (index " + cadran_index_ + ")");
    }

    // Applique le layout Jour/Nuit selon l'heure et les réglages
    private function appliquer_layout_selon_heure(dc as Dc) as Void {
        if (cadran_actif_ == null) { return; }

        // Logique Jour/Nuit
        var est_nuit_reelle = false;
        if (gestionnaire_meteo_ != null) {
            est_nuit_reelle = gestionnaire_meteo_.est_il_nuit();
        } else {
            var h = System.getClockTime().hour;
            est_nuit_reelle = (h >= 18 || h < 7);
        }

        var target = false;
        if (type_affichage_ == 1) { 
            target = true; 
        } 
        else if (type_affichage_ == 0) { 
            target = false; 
        }
        else { 
            target = est_nuit_reelle; 
        }

        if (est_mode_nuit_ == target && bitmap_fond_ != null) { return; }
        
        est_mode_nuit_ = target;

        // Layout depuis le cadran actif
        var layout = target 
            ? cadran_actif_.obtenir_layout_nuit(dc) 
            : cadran_actif_.obtenir_layout_jour(dc);
        setLayout(layout);
        cadran_actif_.initialiser_labels(self, obtenir_polices());
        
        // Fond depuis le cadran actif
        var res = target ? cadran_actif_.fond_nuit() : cadran_actif_.fond_jour();
        if (res != null) {
            image_fond_ = WatchUi.loadResource(res);
            bitmap_fond_ = new WatchUi.Bitmap({
                :bitmap => image_fond_,
                :locX => ((dc.getWidth() - image_fond_.getWidth()) / 2),
                :locY => ((dc.getHeight() - image_fond_.getHeight()) / 2)
            });
        } else {
            image_fond_ = null;
            bitmap_fond_ = null;
        }
    }
}