import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceAuthentification {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> seConnecter({
    required String email,
    required String motDePasse,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: motDePasse,
    );

    final utilisateur = credential.user;

    if (utilisateur == null) {
      throw Exception("Utilisateur introuvable");
    }

    final docUtilisateur = await _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .get();

    if (!docUtilisateur.exists) {
      throw Exception("Document utilisateur introuvable dans Firestore");
    }

    final data = docUtilisateur.data();
    final role = data?['role'] ?? 'user';

    return role;
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
      await utilisateur.sendEmailVerification();

      await _firestore.collection('users').doc(utilisateur.uid).set({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'role': 'user',
        'dateCreation': Timestamp.now(),
      });
    }

    return credential;
  }

  Future<void> seDeconnecter() {
    return _firebaseAuth.signOut();
  }

  Future<void> reinitialiserMotDePasse({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
