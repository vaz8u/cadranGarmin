import Toybox.WatchUi;
import Toybox.Application.Properties;

class mySettingsMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title=>"Réglages"});
        
        var currentValue = Properties.getValue("affichage");
        if (currentValue == null) { currentValue = 0; }

        // Traduction de la valeur numérique en texte pour le menu
        var labels = ["Normal", "Nuit", "Auto"];
        var currentLabel = labels[currentValue];

        Menu2.addItem(
            new WatchUi.MenuItem(
                "Affichage",       // Titre
                currentLabel,      // Sous-titre (Normal, Nuit ou Auto)
                "affichage",       // ID de la propriété
                {}                 // Pas besoin d'options complexes ici
            )
        );
    }
}