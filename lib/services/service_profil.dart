import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceProfil {
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> chargerProfil() async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return null;

    final document = await _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .get();

    if (!document.exists) {
      return {
        'nom': '',
        'prenom': '',
        'email': utilisateur.email ?? '',
        'dateNaissance': '',
      };
    }

    final donnees = document.data() ?? <String, dynamic>{};

    return {
      'nom': (donnees['nom'] ?? '').toString(),
      'prenom': (donnees['prenom'] ?? '').toString(),
      'email': (donnees['email'] ?? utilisateur.email ?? '').toString(),
      'dateNaissance': (donnees['dateNaissance'] ?? '').toString(),
    };
  }

  Future<void> mettreAJourProfil({
    required String nom,
    required String prenom,
    String? dateNaissance,
  }) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return;

    await _firestore.collection('users').doc(utilisateur.uid).set({
      'nom': nom,
      'prenom': prenom,
      'dateNaissance': dateNaissance ?? '',
    }, SetOptions(merge: true));
  }
}
