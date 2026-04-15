import '../models/modele_maps.dart';
import '../services/service_maps.dart';

class ControleurMaps {
  final ServiceMaps _serviceMaps = ServiceMaps();

  Future<ModeleMaps?> chargerPositionActuelle() async {
    try {
      final position = await _serviceMaps.obtenirPositionActuelle();

      if (position == null) {
        return null;
      }

      final adresse = await _serviceMaps.obtenirAdresse(
        position.latitude,
        position.longitude,
      );

      return ModeleMaps(
        latitude: position.latitude,
        longitude: position.longitude,
        adresse: adresse,
        nomLieu: adresse,
      );
    } catch (_) {
      return null;
    }
  }

  Future<ModeleMaps?> rechercherDestination(String nomLieu) async {
    return await _serviceMaps.obtenirDestinationDepuisNom(nomLieu);
  }

  double calculerDistance(double lat1, double lng1, double lat2, double lng2) {
    return _serviceMaps.calculerDistance(lat1, lng1, lat2, lng2);
  }

  int calculerTempsTrajet(double distanceMetres) {
    return _serviceMaps.calculerTempsTrajet(distanceMetres);
  }

  DateTime calculerHeureSortie({
    required DateTime heureArrivee,
    required int tempsTrajetMinutes,
  }) {
    return _serviceMaps.calculerHeureSortie(
      heureArrivee: heureArrivee,
      tempsTrajetMinutes: tempsTrajetMinutes,
    );
  }
}
