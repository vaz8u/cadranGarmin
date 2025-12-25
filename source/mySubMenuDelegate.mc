import Toybox.WatchUi;
import Toybox.Application.Properties;

class MySubMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        // L'ID ici est directement le chiffre 0, 1 ou 2 que nous avons mis dans le sous-menu
        var value = item.getId();
        
        // On enregistre la propriété
        Properties.setValue("affichage", value);
        
        // On force la mise à jour du cadran
        WatchUi.requestUpdate();
        
        // On ferme le sous-menu pour revenir au menu principal de réglages
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}