import Toybox.WatchUi;
import Toybox.Application.Properties;

class SousMenuMode extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "Mode"});
        
        addItem(new WatchUi.MenuItem("Jour", null, 0, {}));
        addItem(new WatchUi.MenuItem("Nuit", null, 1, {}));
        addItem(new WatchUi.MenuItem("Auto", null, 2, {}));
    }
}

class DelegueSousMenuMode extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var valeur = item.getId();
        
        if (valeur instanceof Number) {
            Properties.setValue("affichage", valeur);
            WatchUi.requestUpdate();
        }
        
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
    
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}