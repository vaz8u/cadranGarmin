import Toybox.Lang;

// ==========================================
// REGISTRE DES CADRANS
// ==========================================
// Point d'entrée central pour l'ajout et la
// récupération des cadrans disponibles.
//
// Pour ajouter un nouveau cadran :
//   1. Créer la classe dans source/cadrans/
//   2. Ajouter une entrée dans creer_cadran() ci-dessous
//   3. Incrémenter NOMBRE_CADRANS
//   4. Ajouter le nom dans resources/strings/strings.xml
//   5. Ajouter l'entrée dans resources/resources.xml (settings)

module RegistreCadrans {

    const NOMBRE_CADRANS = 4;

    // Crée une instance du cadran correspondant à l'index
    function creer_cadran(index as Number, meteo as GestionnaireMeteo?) as CadranBase {
        switch (index) {
            case 0:
                return new CadranCasioDigital(meteo);
            case 1:
                return new CadranCasioAnalog(meteo);
            case 2:
                return new CadranVide(meteo);
            case 3:
                return new CadranBasique(meteo);
            default:
                // Sécurité : cadran par défaut
                return new CadranCasioDigital(meteo);
        }
    }

    // Retourne le nombre de cadrans disponibles
    function nombre_cadrans() as Number {
        return NOMBRE_CADRANS;
    }

    // Retourne le nom d'un cadran par son index
    function obtenir_nom(index as Number) as String {
        // On crée temporairement le cadran pour récupérer son nom
        // (pas d'impact mémoire, le GC libère immédiatement)
        var cadran = creer_cadran(index, null);
        return cadran.nom();
    }
}
