import '../models/modele_meteo.dart';
import '../services/service_meteo.dart';

class ControleurMeteo {
  final ServiceMeteo _service = ServiceMeteo();

  Future<MeteoActuelle> chargerMeteoActuelle({String ville = 'Sousse'}) {
    return _service.obtenirMeteoActuelle(ville: ville);
  }

  Future<List<PrevisionJour>> chargerPrevisions({String ville = 'Sousse'}) {
    return _service.obtenirPrevisions(ville: ville);
  }
}
