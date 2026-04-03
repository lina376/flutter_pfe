import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/modele_principale.dart';

class ServicePrincipal {
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? obtenirUtilisateurActuel() {
    return _authentification.currentUser;
  }

  Future<void> seDeconnecter() async {
    await _authentification.signOut();
  }

  Stream<ModeleUtilisateurPrincipal?> obtenirFluxUtilisateur() {
    final utilisateur = _authentification.currentUser;

    if (utilisateur == null) {
      return Stream.value(null);
    }

    return _firestore.collection('users').doc(utilisateur.uid).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return ModeleUtilisateurPrincipal.fromMap(doc.data());
    });
  }

  Stream<List<ModeleConversation>> obtenirFluxConversations() {
    final utilisateur = _authentification.currentUser;

    if (utilisateur == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('conversations')
        .orderBy('dateMaj', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ModeleConversation.fromFirestore(doc))
              .toList(),
        );
  }

  Future<String> creerConversation({required String premierMessage}) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return '';

    final maintenant = Timestamp.now();

    final document = await _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('conversations')
        .add({
          'titre': premierMessage,
          'dernierMessage': premierMessage,
          'dateCreation': maintenant,
          'dateMaj': maintenant,
        });

    return document.id;
  }
}
