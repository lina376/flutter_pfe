import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/service_tache.dart';

class ControleurTache {
  final ServiceTache _serviceTache = ServiceTache();

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenirFluxTaches() {
    return _serviceTache.obtenirFluxTaches();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenirFluxTachesParDate(
    DateTime date,
  ) {
    return _serviceTache.obtenirFluxTachesParDate(date);
  }

  Future<void> ajouterTache({
    required String titre,
    required String heure,
    required DateTime date,
  }) {
    return _serviceTache.ajouterTache(titre: titre, heure: heure, date: date);
  }

  Future<void> supprimerTache(String idTache) {
    return _serviceTache.supprimerTache(idTache);
  }

  Future<void> changerEtatTache({
    required String idTache,
    required bool terminee,
  }) {
    return _serviceTache.changerEtatTache(idTache: idTache, terminee: terminee);
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filtrerParDate(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTime date,
  ) {
    return docs.where((doc) {
      final data = doc.data();
      if (data['date'] is! Timestamp) return false;

      final tacheDate = (data['date'] as Timestamp).toDate();

      return tacheDate.year == date.year &&
          tacheDate.month == date.month &&
          tacheDate.day == date.day;
    }).toList();
  }
}
