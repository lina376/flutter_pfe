import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicePrincipal {
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? obtenirUtilisateurActuel() {
    return _authentification.currentUser;
  }

  Future<void> seDeconnecter() async {
    await _authentification.signOut();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> obtenirFluxUtilisateur() {
    final utilisateur = _authentification.currentUser;

    if (utilisateur == null) {
      return const Stream.empty();
    }

    return _firestore.collection('users').doc(utilisateur.uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenirFluxConversations() {
    final utilisateur = _authentification.currentUser;

    if (utilisateur == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('conversations')
        .orderBy('dateMaj', descending: true)
        .snapshots();
  }

  Future<String> creerConversation({required String premierMessage}) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return '';

    final document = await _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('conversations')
        .add({
          'titre': premierMessage,
          'dernierMessage': premierMessage,
          'dateCreation': Timestamp.now(),
          'dateMaj': Timestamp.now(),
        });

    return document.id;
  }
}
