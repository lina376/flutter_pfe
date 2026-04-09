import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/modele_utilisateur.dart';

class ServiceProfil {
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
        photoUrl: '',
      );
    }

    final donnees = document.data() ?? <String, dynamic>{};

    return UserModel.fromMap({
      ...donnees,
      'email': (utilisateurMisAJour?.email ?? donnees['email'] ?? '')
          .toString(),
      'photoUrl': (donnees['photoUrl'] ?? '').toString(),
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
      'photoUrl': utilisateurModel.photoUrl,
    }, SetOptions(merge: true));
  }

  Future<void> _reauthentifier({
    required String email,
    required String motDePasseActuel,
  }) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) {
      throw Exception("Aucun utilisateur connecté.");
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
      throw Exception("Aucun utilisateur connecté.");
    }

    final ancienEmail = utilisateur.email;
    if (ancienEmail == null || ancienEmail.isEmpty) {
      throw Exception("Email actuel introuvable.");
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
      throw Exception("Aucun utilisateur connecté.");
    }

    final email = utilisateur.email;
    if (email == null || email.isEmpty) {
      throw Exception("Email utilisateur introuvable.");
    }

    await _reauthentifier(email: email, motDePasseActuel: motDePasseActuel);

    await utilisateur.updatePassword(nouveauMotDePasse);
  }

  Future<String> televerserPhotoProfil(File imageFile) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) {
      throw Exception("Aucun utilisateur connecté.");
    }

    final reference = _storage
        .ref()
        .child('photos_profils')
        .child('${utilisateur.uid}.jpg');

    await reference.putFile(imageFile);

    final url = await reference.getDownloadURL();

    await _firestore.collection('users').doc(utilisateur.uid).set({
      'photoUrl': url,
    }, SetOptions(merge: true));

    return url;
  }

  Future<void> supprimerPhotoProfil() async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return;

    final reference = _storage
        .ref()
        .child('photos_profils')
        .child('${utilisateur.uid}.jpg');

    try {
      await reference.delete();
    } catch (_) {}

    await _firestore.collection('users').doc(utilisateur.uid).set({
      'photoUrl': '',
    }, SetOptions(merge: true));
  }
}
