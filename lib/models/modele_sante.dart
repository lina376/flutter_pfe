class ModeleSante {
  final String id;
  final String userId;
  final String date;
  final int age;
  final double poids;
  final String activite;
  final double heuresSommeil;
  final String humeur;
  final DateTime updatedAt;
  final bool synced;

  ModeleSante({
    required this.id,
    required this.userId,
    required this.date,
    required this.age,
    required this.poids,
    required this.activite,
    required this.heuresSommeil,
    required this.humeur,
    required this.updatedAt,
    required this.synced,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'age': age,
      'poids': poids,
      'activite': activite,
      'heuresSommeil': heuresSommeil,
      'humeur': humeur,
      'updatedAt': updatedAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory ModeleSante.fromMap(Map<String, dynamic> map) {
    return ModeleSante(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      age: map['age'] ?? 20,
      poids: (map['poids'] ?? 65).toDouble(),
      activite: map['activite'] ?? 'Normale',
      heuresSommeil: (map['heuresSommeil'] ?? 7).toDouble(),
      humeur: map['humeur'] ?? 'Heureux',
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      synced: map['synced'] == 1 || map['synced'] == true,
    );
  }

  ModeleSante copyWith({
    int? age,
    double? poids,
    String? activite,
    double? heuresSommeil,
    String? humeur,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return ModeleSante(
      id: id,
      userId: userId,
      date: date,
      age: age ?? this.age,
      poids: poids ?? this.poids,
      activite: activite ?? this.activite,
      heuresSommeil: heuresSommeil ?? this.heuresSommeil,
      humeur: humeur ?? this.humeur,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }
}
