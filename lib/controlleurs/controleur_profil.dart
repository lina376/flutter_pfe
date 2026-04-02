import '../services/service_profil.dart';

class ControleurProfil {
  final ServiceProfil _serviceProfil = ServiceProfil();

  Future<Map<String, dynamic>?> chargerProfil() {
    return _serviceProfil.chargerProfil();
  }

  Future<void> mettreAJourProfil({
    required String nom,
    required String prenom,
    String? dateNaissance,
  }) {
    return _serviceProfil.mettreAJourProfil(
      nom: nom,
      prenom: prenom,
      dateNaissance: dateNaissance,
    );
  }

  bool emailValide(String email) {
    return email.contains('@');
  }
}
