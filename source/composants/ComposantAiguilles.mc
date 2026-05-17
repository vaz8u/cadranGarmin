import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

// ==========================================
// COMPOSANT : AIGUILLES ANALOGIQUES
// ==========================================
// Gère le chargement, le rendu et la rotation
// des aiguilles (heures, minutes, secondes)
// et des sous-cadrans (gauche, droite, bas).

class ComposantAiguilles {

    // Aiguilles principales
    private var bmp_heure_ as Graphics.BufferedBitmap?;
    private var bmp_minute_ as Graphics.BufferedBitmap?;
    private var bmp_seconde_ as Graphics.BufferedBitmap?;
    
    // Sous-cadrans
    private var bmp_gauche_ as Graphics.BufferedBitmap?;
    private var bmp_droite_ as Graphics.BufferedBitmap?;
    private var bmp_bas_ as Graphics.BufferedBitmap?;

    function initialize() {}

    // Charge les bitmaps des aiguilles depuis les IDs de ressources
    function charger(res_h as ResourceId?, res_m as ResourceId?, res_s as ResourceId?,
                     res_g as ResourceId?, res_d as ResourceId?, res_b as ResourceId?) as Void {
        bmp_heure_   = (res_h != null) ? charger_bitmap_natif(res_h) : null;
        bmp_minute_  = (res_m != null) ? charger_bitmap_natif(res_m) : null;
        bmp_seconde_ = (res_s != null) ? charger_bitmap_natif(res_s) : null;
        bmp_gauche_  = (res_g != null) ? charger_bitmap_natif(res_g) : null;
        bmp_droite_  = (res_d != null) ? charger_bitmap_natif(res_d) : null;
        bmp_bas_     = (res_b != null) ? charger_bitmap_natif(res_b) : null;
    }

    // Libère les bitmaps pour économiser la mémoire
    function liberer() as Void {
        bmp_heure_ = null;
        bmp_minute_ = null;
        bmp_seconde_ = null;
        bmp_gauche_ = null;
        bmp_droite_ = null;
        bmp_bas_ = null;
    }

    // Dessine toutes les aiguilles sur le DC
    function dessiner(dc as Graphics.Dc, en_basse_conso as Boolean) as Void {
        var cx = dc.getWidth() / 2.0d;
        var cy = dc.getHeight() / 2.0d;
        var t = System.getClockTime();
        
        // --- Heures ---
        if (bmp_heure_ != null) {
            var angle_h = (((t.hour % 12) * 30.0d + t.min * 0.5d)) * Math.PI / 180.0d;
            var px = 13.0d; 
            var py = bmp_heure_.getHeight() - 18.0d;
            dessiner_image_tournante(dc, cx, cy, angle_h.toFloat(), bmp_heure_, px, py);
        }
        
        // --- Minutes ---
        if (bmp_minute_ != null) {
            var angle_m = ((t.min * 6.0d + t.sec * 0.1d)) * Math.PI / 180.0d;
            var px = 16.5d; 
            var py = bmp_minute_.getHeight() - 18.0d;
            dessiner_image_tournante(dc, cx, cy, angle_m.toFloat(), bmp_minute_, px, py);
        }
        
        // --- Secondes ---
        if (!en_basse_conso && bmp_seconde_ != null) {
            var angle_s = (t.sec * 6.0d) * Math.PI / 180.0d;
            var px = 12.5d; 
            var py = bmp_seconde_.getHeight() - 40.0d;
            dessiner_image_tournante(dc, cx, cy, angle_s.toFloat(), bmp_seconde_, px, py);
        }
        
        // --- SOUS-CADRANS / PETITES AIGUILLES ---
        var angle_h_f = 0;

        if (bmp_gauche_ != null) {
            var px = bmp_gauche_.getWidth() / 2.0d; 
            var py = bmp_gauche_.getHeight() / 2.0d;
            dessiner_image_tournante(dc, cx - 90, cy, angle_h_f.toFloat(), bmp_gauche_, px, py);
        }
        
        if (bmp_droite_ != null) {
            var px = bmp_droite_.getWidth() / 2.0d; 
            var py = bmp_droite_.getHeight() / 2.0d;
            dessiner_image_tournante(dc, cx + 90, cy, angle_h_f.toFloat(), bmp_droite_, px, py);
        }
        
        if (bmp_bas_ != null) {
            var px = bmp_bas_.getWidth() / 2.0d; 
            var py = bmp_bas_.getHeight() / 2.0d;
            dessiner_image_tournante(dc, cx, cy + 90, angle_h_f.toFloat(), bmp_bas_, px, py);
        }
    }

    // Charge un bitmap et le convertit en format natif pour le rendu avec transformations
    private function charger_bitmap_natif(res_id as Lang.ResourceId) as Graphics.BufferedBitmap? {
        try {
            var res = WatchUi.loadResource(res_id);
            if (res != null) {
                var temp_ref = Graphics.createBufferedBitmap({:bitmapResource => res});
                var b_temp = temp_ref.get() as Graphics.BufferedBitmap;
                
                var final_ref = Graphics.createBufferedBitmap({
                    :width => b_temp.getWidth(),
                    :height => b_temp.getHeight()
                });
                var b_final = final_ref.get() as Graphics.BufferedBitmap;
                
                var bdc = b_final.getDc();
                bdc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
                bdc.clear();
                bdc.drawBitmap(0, 0, b_temp);
                
                return b_final;
            }
        } catch (e) {
            System.println("ERREUR CHARGEMENT AIGUILLE: " + e.getErrorMessage());
        }
        return null;
    }

    // Dessine un bitmap avec rotation autour d'un point de pivot
    private function dessiner_image_tournante(dc as Graphics.Dc, x as Numeric, y as Numeric, 
            angle as Float, bmp as Graphics.BufferedBitmap, px as Numeric, py as Numeric) as Void {
        var transform = new Graphics.AffineTransform();
        transform.translate(x, y);
        transform.rotate(angle);
        transform.translate(-px, -py);
        
        var options = { :transform => transform };
        
        if (Graphics has :FILTER_HIGH) {
            options[:filter] = Graphics.FILTER_HIGH;
        }
        
        dc.drawBitmap2(0, 0, bmp, options);
    }
}
