import 'package:firebase_auth/firebase_auth.dart';
import '../models/modele_principale.dart';
import '../services/service_principal.dart';

class ControleurPrincipal {
  final ServicePrincipal _servicePrincipal = ServicePrincipal();

  User? obtenirUtilisateurActuel() {
    return _servicePrincipal.obtenirUtilisateurActuel();
  }

  Stream<ModeleUtilisateurPrincipal?> obtenirFluxUtilisateur() {
    return _servicePrincipal.obtenirFluxUtilisateur();
  }

  Stream<List<ModeleConversation>> obtenirFluxConversations() {
    return _servicePrincipal.obtenirFluxConversations();
  }

  Future<void> seDeconnecter() {
    return _servicePrincipal.seDeconnecter();
  }

  Future<String> creerConversation({required String premierMessage}) {
    return _servicePrincipal.creerConversation(premierMessage: premierMessage);
  }

  String obtenirNomAffichage(ModeleUtilisateurPrincipal? utilisateur) {
    return utilisateur?.nomAffichage ?? 'ORA';
  }
}
