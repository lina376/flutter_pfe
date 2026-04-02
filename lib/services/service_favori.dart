import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceFavori {
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>? _referenceFavorisUtilisateur() {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return null;

    return _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('favoris');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenirFluxFavoris() {
    final reference = _referenceFavorisUtilisateur();
    if (reference == null) {
      return const Stream.empty();
    }

    return reference.orderBy('date', descending: true).snapshots();
  }

  Future<bool> estFavori(String idOriginal) async {
    final reference = _referenceFavorisUtilisateur();
    if (reference == null) return false;

    final resultat = await reference
        .where('idOriginal', isEqualTo: idOriginal)
        .get();

    return resultat.docs.isNotEmpty;
  }

  Future<void> supprimerFavori(String idFavori) async {
    final reference = _referenceFavorisUtilisateur();
    if (reference == null) return;

    await reference.doc(idFavori).delete();
  }

  Future<void> supprimerFavoriLieANote(String idNote) async {
    final reference = _referenceFavorisUtilisateur();
    if (reference == null) return;

    final resultat = await reference
        .where('idOriginal', isEqualTo: 'note_$idNote')
        .get();

    for (final document in resultat.docs) {
      await document.reference.delete();
    }
  }

  Future<void> mettreAJourFavoriLieANote({
    required String idNote,
    required String titre,
    required String contenu,
    required bool aimee,
  }) async {
    final reference = _referenceFavorisUtilisateur();
    if (reference == null) return;

    final resultat = await reference
        .where('idOriginal', isEqualTo: 'note_$idNote')
        .get();

    for (final document in resultat.docs) {
      await document.reference.update({
        'title': titre,
        'desc': contenu,
        'contenu': contenu,
        'liked': aimee,
        'date': Timestamp.now(),
      });
    }
  }

  Future<void> basculerFavoriNote({
    required String idNote,
    required String titre,
    required String contenu,
    required DateTime date,
  }) async {
    final reference = _referenceFavorisUtilisateur();
    if (reference == null) return;

    final idOriginal = 'note_$idNote';

    final resultat = await reference
        .where('idOriginal', isEqualTo: idOriginal)
        .get();

    if (resultat.docs.isNotEmpty) {
      for (final document in resultat.docs) {
        await document.reference.delete();
      }
    } else {
      await reference.add({
        'idOriginal': idOriginal,
        'type': 'note',
        'title': titre,
        'desc': contenu,
        'contenu': contenu,
        'date': Timestamp.fromDate(date),
        'noteDocId': idNote,
      });
    }
  }
}
