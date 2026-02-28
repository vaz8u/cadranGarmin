import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application.Properties;

module MenuConfig {
    const ID_MENU_AFFICHAGE = :id_menu_affichage; 
}

class MenuReglages extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "Réglages"});
        
        var val = Properties.getValue("affichage");
        if (!(val instanceof Number)) { val = 2; } 

        var sous_titre = "Auto";
        if (val == 0) { sous_titre = "Mode Jour"; }
        else if (val == 1) { sous_titre = "Mode Nuit"; }

        addItem(
            new WatchUi.MenuItem(
                "Affichage",
                sous_titre,
                MenuConfig.ID_MENU_AFFICHAGE,
                {}
            )
        );
    }
}

class DelegueMenuReglages extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        if (item.getId() == MenuConfig.ID_MENU_AFFICHAGE) {
            WatchUi.pushView(new SousMenuMode(), new DelegueSousMenuMode(), WatchUi.SLIDE_LEFT);
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}