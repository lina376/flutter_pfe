import '../models/modele_alarme.dart';
import '../services/service_alarme.dart';

class ControleurAlarme {
  final ServiceAlarme _service = ServiceAlarme();

  Future<List<ModeleAlarme>> recupererToutesLesAlarmes() {
    return _service.recupererToutesLesAlarmes();
  }

  Future<void> ajouterAlarme({
    required String titre,
    String? note,
    required int heure,
    required int minute,
    required String jours,
  }) {
    final alarme = ModeleAlarme(
      titre: titre,
      note: note,
      heure: heure,
      minute: minute,
      jours: jours,
      active: true,
    );

    return _service.ajouterAlarme(alarme);
  }

  Future<void> supprimerAlarme(int id) {
    return _service.supprimerAlarme(id);
  }

  Future<void> basculerActivation(int id, bool active) {
    return _service.basculerActivation(id, active);
  }

  void dispose() {}
}
