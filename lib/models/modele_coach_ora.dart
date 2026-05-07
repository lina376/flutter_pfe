class ModeleCoachOra {
  final String userId;
  final String date;
  final double eauBu;
  final double objectifEau;
  final int minutesSport;
  final int objectifSport;
  final double heuresSommeil;
  final String humeur;
  final String etatGeneral;
  final int scoreBienEtre;
  final String conseilDuJour;
  final String recommandationHydratation;
  final String recommandationSport;
  final String alerteSante;
  final DateTime updatedAt;

  ModeleCoachOra({
    required this.userId,
    required this.date,
    required this.eauBu,
    required this.objectifEau,
    required this.minutesSport,
    required this.objectifSport,
    required this.heuresSommeil,
    required this.humeur,
    required this.etatGeneral,
    required this.scoreBienEtre,
    required this.conseilDuJour,
    required this.recommandationHydratation,
    required this.recommandationSport,
    required this.alerteSante,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'eauBu': eauBu,
      'objectifEau': objectifEau,
      'minutesSport': minutesSport,
      'objectifSport': objectifSport,
      'heuresSommeil': heuresSommeil,
      'humeur': humeur,
      'etatGeneral': etatGeneral,
      'scoreBienEtre': scoreBienEtre,
      'conseilDuJour': conseilDuJour,
      'recommandationHydratation': recommandationHydratation,
      'recommandationSport': recommandationSport,
      'alerteSante': alerteSante,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ModeleCoachOra.fromMap(Map<String, dynamic> map) {
    return ModeleCoachOra(
      userId: (map['userId'] ?? '').toString(),
      date: (map['date'] ?? '').toString(),
      eauBu: (map['eauBu'] ?? 0).toDouble(),
      objectifEau: (map['objectifEau'] ?? 2.0).toDouble(),
      minutesSport: map['minutesSport'] ?? 0,
      objectifSport: map['objectifSport'] ?? 30,
      heuresSommeil: (map['heuresSommeil'] ?? 7).toDouble(),
      humeur: map['humeur'] ?? 'Stable',
      etatGeneral: map['etatGeneral'] ?? 'Normal',
      scoreBienEtre: map['scoreBienEtre'] ?? 70,
      conseilDuJour: map['conseilDuJour'] ?? '',
      recommandationHydratation: map['recommandationHydratation'] ?? '',
      recommandationSport: map['recommandationSport'] ?? '',
      alerteSante: map['alerteSante'] ?? '',
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
