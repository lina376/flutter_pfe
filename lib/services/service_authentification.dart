import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceAuthentification {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> seConnecter({
    required String email,
    required String motDePasse,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: motDePasse,
    );
  }

  Future<UserCredential> creerCompte({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: motDePasse,
    );

    final utilisateur = credential.user;

    if (utilisateur != null) {
      await _firestore.collection('users').doc(utilisateur.uid).set({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'dateCreation': Timestamp.now(),
      });
    }

    return credential;
  }

  Future<void> seDeconnecter() {
    return _firebaseAuth.signOut();
  }
}
