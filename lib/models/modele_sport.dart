class ModeleSport {
  final String id;
  final String userId;
  final String date;
  final int minutes;
  final int objectifMinutes;
  final String objectifSport;
  final String etatSante;
  final String typeSeance;
  final String intensite;
  final int calories;
  final DateTime updatedAt;
  final bool synced;

  ModeleSport({
    required this.id,
    required this.userId,
    required this.date,
    required this.minutes,
    required this.objectifMinutes,
    required this.objectifSport,
    required this.etatSante,
    required this.typeSeance,
    required this.intensite,
    required this.calories,
    required this.updatedAt,
    required this.synced,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'minutes': minutes,
      'objectifMinutes': objectifMinutes,
      'objectifSport': objectifSport,
      'etatSante': etatSante,
      'typeSeance': typeSeance,
      'intensite': intensite,
      'calories': calories,
      'updatedAt': updatedAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory ModeleSport.fromMap(Map<String, dynamic> map) {
    return ModeleSport(
      id: map['id'] ?? '',
      userId: (map['userId'] ?? '').toString(),
      date: map['date'] ?? '',
      minutes: map['minutes'] ?? 0,
      objectifMinutes: map['objectifMinutes'] ?? 30,
      objectifSport: map['objectifSport'] ?? 'Rester en forme',
      etatSante: map['etatSante'] ?? 'Bonne santé',
      typeSeance: map['typeSeance'] ?? 'Marche',
      intensite: map['intensite'] ?? 'Modérée',
      calories: map['calories'] ?? 0,
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      synced: map['synced'] == 1 || map['synced'] == true,
    );
  }

  ModeleSport copyWith({
    String? id,
    String? userId,
    String? date,
    int? minutes,
    int? objectifMinutes,
    String? objectifSport,
    String? etatSante,
    String? typeSeance,
    String? intensite,
    int? calories,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return ModeleSport(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      minutes: minutes ?? this.minutes,
      objectifMinutes: objectifMinutes ?? this.objectifMinutes,
      objectifSport: objectifSport ?? this.objectifSport,
      etatSante: etatSante ?? this.etatSante,
      typeSeance: typeSeance ?? this.typeSeance,
      intensite: intensite ?? this.intensite,
      calories: calories ?? this.calories,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }
}
