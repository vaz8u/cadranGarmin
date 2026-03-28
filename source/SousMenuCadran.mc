import Toybox.WatchUi;
import Toybox.Application.Properties;

// ==========================================
// SOUS-MENU : CHOIX DU CADRAN
// ==========================================
class SousMenuCadran extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "Cadran"});
        
        // Ajouter dynamiquement tous les cadrans disponibles
        var nb = ConfigCadran.nombre_cadrans();
        for (var i = 0; i < nb; i++) {
            var nom = ConfigCadran.obtenir_nom(i);
            addItem(new WatchUi.MenuItem(nom, null, i, {}));
        }
    }
}

class DelegueSousMenuCadran extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var valeur = item.getId();
        
        if (valeur instanceof Number) {
            Properties.setValue("cadran", valeur);
            WatchUi.requestUpdate();
        }
        
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
    
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
