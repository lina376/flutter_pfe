import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/modele_utilisateur.dart';

class ServiceProfil {
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> chargerProfil() async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return null;

    final document = await _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .get();

    if (!document.exists) {
      return UserModel(
        nom: '',
        prenom: '',
        email: utilisateur.email ?? '',
        dateNaissance: '',
      );
    }

    final donnees = document.data() ?? <String, dynamic>{};

    return UserModel.fromMap({
      ...donnees,
      'email': (donnees['email'] ?? utilisateur.email ?? '').toString(),
    });
  }

  Future<void> mettreAJourProfil({required UserModel utilisateurModel}) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return;

    await _firestore.collection('users').doc(utilisateur.uid).set({
      'nom': utilisateurModel.nom,
      'prenom': utilisateurModel.prenom,
      'dateNaissance': utilisateurModel.dateNaissance,
    }, SetOptions(merge: true));
  }
}
