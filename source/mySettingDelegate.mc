import Toybox.WatchUi;
import Toybox.Application.Properties;

class mySettingsDelegate extends WatchUi.Menu2InputDelegate {
    
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId().toString();

        if (id.equals("affichage")) {
            // Au clic sur "Affichage", on ouvre un sous-menu
            var subMenu = new WatchUi.Menu2({:title => "Mode d'affichage"});
            
            // On ajoute les 3 options
            subMenu.addItem(new WatchUi.MenuItem("Normal", null, 0, {}));
            subMenu.addItem(new WatchUi.MenuItem("Nuit", null, 1, {}));
            subMenu.addItem(new WatchUi.MenuItem("Auto", null, 2, {}));
            
            // On pousse ce nouveau menu avec un nouveau délégué dédié
            WatchUi.pushView(subMenu, new MySubMenuDelegate(), WatchUi.SLIDE_LEFT);
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}