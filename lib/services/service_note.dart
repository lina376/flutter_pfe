import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceNote {
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenirFluxNotes() {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('notes')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> supprimerNote(String idNote) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return;

    await _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('notes')
        .doc(idNote)
        .delete();
  }

  Future<String> ajouterNote({
    required String titre,
    required String contenu,
    required bool aimee,
  }) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return '';

    final donnees = {
      'titre': titre.isEmpty ? 'Sans titre' : titre,
      'contenu': contenu,
      'liked': aimee,
      'date': Timestamp.now(),
    };

    final document = await _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('notes')
        .add(donnees);

    return document.id;
  }

  Future<void> mettreAJourNote({
    required String idNote,
    required String titre,
    required String contenu,
    required bool aimee,
  }) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return;

    final donnees = {
      'titre': titre.isEmpty ? 'Sans titre' : titre,
      'contenu': contenu,
      'liked': aimee,
      'date': Timestamp.now(),
    };

    await _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('notes')
        .doc(idNote)
        .update(donnees);
  }
}
