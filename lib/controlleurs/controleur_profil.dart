import 'dart:io';

import '../models/modele_utilisateur.dart';
import '../services/service_profil.dart';

class ControleurProfil {
  final ServiceProfil _serviceProfil = ServiceProfil();

  Future<UserModel?> chargerProfil() {
    return _serviceProfil.chargerProfil();
  }

  Future<void> mettreAJourProfil({required UserModel utilisateurModel}) {
    return _serviceProfil.mettreAJourProfil(utilisateurModel: utilisateurModel);
  }

  Future<String> televerserPhotoProfil(File imageFile) {
    return _serviceProfil.televerserPhotoProfil(imageFile);
  }

  Future<void> supprimerPhotoProfil() {
    return _serviceProfil.supprimerPhotoProfil();
  }

  Future<void> mettreAJourEmail({
    required String nouvelEmail,
    required String motDePasseActuel,
  }) {
    return _serviceProfil.mettreAJourEmail(
      nouvelEmail: nouvelEmail,
      motDePasseActuel: motDePasseActuel,
    );
  }

  Future<void> mettreAJourMotDePasse({
    required String motDePasseActuel,
    required String nouveauMotDePasse,
  }) {
    return _serviceProfil.mettreAJourMotDePasse(
      motDePasseActuel: motDePasseActuel,
      nouveauMotDePasse: nouveauMotDePasse,
    );
  }

  bool emailValide(String email) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(email.trim());
  }

  bool motDePasseValide(String motDePasse) {
    return motDePasse.trim().length >= 6;
  }
}
