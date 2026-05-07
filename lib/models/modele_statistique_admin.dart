class ModeleStatistiqueAdmin {
  final int totalUtilisateurs;
  final int utilisateursEauObjectif;
  final int utilisateursSport;
  final int utilisateursChat;
  final String periode;

  const ModeleStatistiqueAdmin({
    required this.totalUtilisateurs,
    required this.utilisateursEauObjectif,
    required this.utilisateursSport,
    required this.utilisateursChat,
    required this.periode,
  });

  int get utilisateursSansEau => totalUtilisateurs - utilisateursEauObjectif;
  int get utilisateursSansSport => totalUtilisateurs - utilisateursSport;
  int get utilisateursSansChat => totalUtilisateurs - utilisateursChat;

  double get pourcentageEau => _calculerPourcentage(utilisateursEauObjectif);
  double get pourcentageSport => _calculerPourcentage(utilisateursSport);
  double get pourcentageChat => _calculerPourcentage(utilisateursChat);

  double _calculerPourcentage(int valeur) {
    if (totalUtilisateurs == 0) return 0;
    return (valeur / totalUtilisateurs) * 100;
  }
}
