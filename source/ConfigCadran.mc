import Toybox.Lang;

// ==========================================
// MODULE DE COMPATIBILITÉ (DÉPRÉCIÉ)
// ==========================================
// Redirige vers RegistreCadrans.
// Ce fichier peut être supprimé une fois que
// tous les appelants utilisent RegistreCadrans.

module ConfigCadran {

    function nombre_cadrans() as Number {
        return RegistreCadrans.nombre_cadrans();
    }

    function obtenir_nom(index as Number) as String {
        return RegistreCadrans.obtenir_nom(index);
    }
}
