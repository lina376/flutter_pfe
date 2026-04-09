import '../models/modele_meteo.dart';
import '../services/service_meteo.dart';

class ControleurMeteo {
  final ServiceMeteo _service = ServiceMeteo();

  Future<MeteoActuelle> chargerMeteoActuelle() {
    return _service.obtenirMeteoActuelle();
  }

  Future<List<PrevisionJour>> chargerPrevisions() {
    return _service.obtenirPrevisions();
  }
}
