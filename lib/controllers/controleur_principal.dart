import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/service_principal.dart';

class ControleurPrincipal {
  final ServicePrincipal _servicePrincipal = ServicePrincipal();

  User? obtenirUtilisateurActuel() {
    return _servicePrincipal.obtenirUtilisateurActuel();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> obtenirFluxUtilisateur() {
    return _servicePrincipal.obtenirFluxUtilisateur();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenirFluxConversations() {
    return _servicePrincipal.obtenirFluxConversations();
  }

  Future<void> seDeconnecter() {
    return _servicePrincipal.seDeconnecter();
  }

  Future<String> creerConversation({required String premierMessage}) {
    return _servicePrincipal.creerConversation(premierMessage: premierMessage);
  }

  String obtenirNomAffichage(Map<String, dynamic>? donnees) {
    if (donnees == null) return 'ORA';

    final prenom = (donnees['prenom'] ?? '').toString().trim();
    final nom = (donnees['nom'] ?? '').toString().trim();
    final nomComplet = '$prenom $nom'.trim();

    return nomComplet.isEmpty ? 'ORA' : nomComplet;
  }
}
