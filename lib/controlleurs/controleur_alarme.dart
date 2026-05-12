import 'package:firebase_auth/firebase_auth.dart';
import '../models/modele_alarme.dart';
import '../services/service_alarme.dart';

class ControleurAlarme {
  final ServiceAlarme _service = ServiceAlarme();

  String get _userId {
    return FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  }

  Future<List<ModeleAlarme>> recupererToutesLesAlarmes() {
    return _service.recupererToutesLesAlarmes();
  }

  Future<int> ajouterAlarme({
    required String titre,
    String? note,
    required int heure,
    required int minute,
    required String jours,
  }) {
    final alarme = ModeleAlarme(
      userId: _userId,
      titre: titre,
      note: note,
      heure: heure,
      minute: minute,
      jours: jours,
      active: true,
      date: DateTime.now().toIso8601String(),
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