import 'package:ora/models/modele_statistique_admin.dart';
import 'package:ora/services/service_statistique_admin.dart';

class ControleurStatistiqueAdmin {
  final ServiceStatistiqueAdmin _service = ServiceStatistiqueAdmin();

  Future<ModeleStatistiqueAdmin> chargerStatistiques(String periode) {
    return _service.chargerStatistiques(periode);
  }
}
