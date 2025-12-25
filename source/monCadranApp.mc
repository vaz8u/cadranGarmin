import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class monCadranApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new monCadranView() ];
    }

    // Cette fonction permet à la montre de savoir qu'il y a un menu local
    function getSettingsView() {
        // On retourne un tableau avec : [La Vue du Menu, Le Délégué qui gère les clics]
        return [new mySettingsMenu(), new mySettingsDelegate()] as Array;
    }

}

function getApp() as monCadranApp {
    return Application.getApp() as monCadranApp;
}