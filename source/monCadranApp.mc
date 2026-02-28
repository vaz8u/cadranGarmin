import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class ApplicationMontre extends Application.AppBase {

    private var vue_active_ as VueCadran?;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(etat as Dictionary?) as Void {
    }

    function onStop(etat as Dictionary?) as Void {
        vue_active_ = null;
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        vue_active_ = new VueCadran();
        return [ vue_active_ ];
    }

    function getSettingsView(){
        return [ new MenuReglages(), new DelegueMenuReglages() ];
    }

    function onSettingsChanged() as Void {
        if (vue_active_ != null) {
            vue_active_.recharger_configuration_externe();
            WatchUi.requestUpdate();
        }
    }
}

function obtenir_application() as ApplicationMontre {
    return Application.getApp() as ApplicationMontre;
}