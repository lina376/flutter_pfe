import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceTache {
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>? _refTaches() {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return null;

    return _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('taches');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenirFluxTaches() {
    final ref = _refTaches();
    if (ref == null) return const Stream.empty();

    return ref.orderBy('date', descending: false).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenirFluxTachesParDate(
    DateTime date,
  ) {
    final ref = _refTaches();
    if (ref == null) return const Stream.empty();

    final debutJour = DateTime(date.year, date.month, date.day);
    final finJour = debutJour.add(const Duration(days: 1));

    return ref
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(debutJour))
        .where('date', isLessThan: Timestamp.fromDate(finJour))
        .orderBy('date', descending: false)
        .snapshots();
  }

  Future<void> ajouterTache({
    required String titre,
    required String heure,
    required DateTime date,
  }) async {
    final ref = _refTaches();
    if (ref == null) return;

    final dateSansHeure = DateTime(date.year, date.month, date.day);

    await ref.add({
      'titre': titre,
      'heure': heure,
      'date': Timestamp.fromDate(dateSansHeure),
      'terminee': false,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> supprimerTache(String idTache) async {
    final ref = _refTaches();
    if (ref == null) return;

    await ref.doc(idTache).delete();
  }

  Future<void> changerEtatTache({
    required String idTache,
    required bool terminee,
  }) async {
    final ref = _refTaches();
    if (ref == null) return;

    await ref.doc(idTache).update({'terminee': terminee});
  }
}
