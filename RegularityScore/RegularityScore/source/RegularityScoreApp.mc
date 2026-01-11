import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class RegularityScoreApp extends Application.AppBase {

    function initialize() {
        Application.AppBase.initialize();
    }

    function onStart(state) {
        // initialisation minimale au démarrage
    }

    function onStop(state) {
        // nettoyage éventuel
    }

    function getInitialView() {
        return [ new RegularityScoreView() ];
    }
}

function getApp() {
    return Application.getApp();
}