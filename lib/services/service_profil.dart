import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/modele_utilisateur.dart';

class ServiceProfil {
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> chargerProfil() async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return null;

    await utilisateur.reload();
    final utilisateurMisAJour = _authentification.currentUser;

    final document = await _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .get();

    if (!document.exists) {
      return UserModel(
        nom: '',
        prenom: '',
        email: utilisateurMisAJour?.email ?? utilisateur.email ?? '',
        dateNaissance: '',
      );
    }

    final donnees = document.data() ?? <String, dynamic>{};

    return UserModel.fromMap({
      ...donnees,
      'email': (utilisateurMisAJour?.email ?? donnees['email'] ?? '')
          .toString(),
    });
  }

  Future<void> mettreAJourProfil({required UserModel utilisateurModel}) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return;

    await _firestore.collection('users').doc(utilisateur.uid).set({
      'nom': utilisateurModel.nom,
      'prenom': utilisateurModel.prenom,
      'email': utilisateurModel.email,
      'dateNaissance': utilisateurModel.dateNaissance,
    }, SetOptions(merge: true));
  }

  Future<void> _reauthentifier({
    required String email,
    required String motDePasseActuel,
  }) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) {
      throw Exception("profil_aucun_utilisateur_connecte".tr());
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: motDePasseActuel,
    );

    await utilisateur.reauthenticateWithCredential(credential);
  }

  Future<void> mettreAJourEmail({
    required String nouvelEmail,
    required String motDePasseActuel,
  }) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) {
      throw Exception("profil_aucun_utilisateur_connecte".tr());
    }

    final ancienEmail = utilisateur.email;
    if (ancienEmail == null || ancienEmail.isEmpty) {
      throw Exception("profil_email_actuel_introuvable".tr());
    }

    await _reauthentifier(
      email: ancienEmail,
      motDePasseActuel: motDePasseActuel,
    );

    await utilisateur.verifyBeforeUpdateEmail(nouvelEmail);

    await _firestore.collection('users').doc(utilisateur.uid).set({
      'email': nouvelEmail,
    }, SetOptions(merge: true));
  }

  Future<void> mettreAJourMotDePasse({
    required String motDePasseActuel,
    required String nouveauMotDePasse,
  }) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) {
      throw Exception("profil_aucun_utilisateur_connecte".tr());
    }

    final email = utilisateur.email;
    if (email == null || email.isEmpty) {
      throw Exception("profil_email_utilisateur_introuvable".tr());
    }

    await _reauthentifier(email: email, motDePasseActuel: motDePasseActuel);

    await utilisateur.updatePassword(nouveauMotDePasse);
  }
}