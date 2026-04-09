import 'package:firebase_auth/firebase_auth.dart';
import '../services/service_authentification.dart';

class ControleurAuthentification {
  final ServiceAuthentification _serviceAuthentification =
      ServiceAuthentification();

  Future<UserCredential> seConnecter({
    required String email,
    required String motDePasse,
  }) async {
    return await _serviceAuthentification.seConnecter(
      email: email,
      motDePasse: motDePasse,
    );
  }

  Future<UserCredential> creerCompte({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
  }) async {
    return await _serviceAuthentification.creerCompte(
      nom: nom,
      prenom: prenom,
      email: email,
      motDePasse: motDePasse,
    );
  }

  Future<void> seDeconnecter() async {
    await _serviceAuthentification.seDeconnecter();
  }

  Future<void> reinitialiserMotDePasse({required String email}) async {
    await _serviceAuthentification.reinitialiserMotDePasse(email: email);
  }
}
