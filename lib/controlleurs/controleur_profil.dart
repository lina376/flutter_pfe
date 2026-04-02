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

  bool emailValide(String email) {
    return email.contains('@');
  }
}
