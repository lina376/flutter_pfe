class ModeleEau {
  final String id;
  final String userId;
  final String date;
  final int verres;
  final int objectif;
  final DateTime updatedAt;
  final bool synced;

  ModeleEau({
    required this.id,
    required this.userId,
    required this.date,
    required this.verres,
    required this.objectif,
    required this.updatedAt,
    required this.synced,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'verres': verres,
      'objectif': objectif,
      'updatedAt': updatedAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory ModeleEau.fromMap(Map<String, dynamic> map) {
    return ModeleEau(
      id: map['id'] ?? '',
      userId: (map['userId'] ?? '').toString(),
      date: map['date'] ?? '',
      verres: map['verres'] ?? 0,
      objectif: map['objectif'] ?? 12,
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      synced: map['synced'] == 1 || map['synced'] == true,
    );
  }

  ModeleEau copyWith({
    String? id,
    String? userId,
    String? date,
    int? verres,
    int? objectif,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return ModeleEau(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      verres: verres ?? this.verres,
      objectif: objectif ?? this.objectif,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }
}
