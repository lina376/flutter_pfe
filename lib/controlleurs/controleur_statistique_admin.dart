import 'package:ora/models/modele_statistique_admin.dart';
import 'package:ora/services/service_statistique_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
class ControleurStatistiqueAdmin {
  final ServiceStatistiqueAdmin _service = ServiceStatistiqueAdmin();
Future<int> compterUtilisateursObjectifEauAtteint() async {
  final usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

  int compteur = 0;
  final dateAujourdhui = DateFormat('yyyy-MM-dd').format(DateTime.now());

  for (final userDoc in usersSnapshot.docs) {
    final eauSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDoc.id)
        .collection('eau')
        .where('date', isEqualTo: dateAujourdhui)
        .get();

    for (final doc in eauSnapshot.docs) {
      final data = doc.data();

      final verres = data['verres'] ?? 0;
      final objectif = data['objectif'] ?? 8;

      if (verres >= objectif) {
        compteur++;
        break;
      }
    }
  }

  return compteur;
}
  Future<ModeleStatistiqueAdmin> chargerStatistiques(String periode) {
    return _service.chargerStatistiques(periode);
  }
}
