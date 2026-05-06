class ModeleTache {
  final String id;
  final String userId;
  final String titre;
  final String heure;
  final DateTime date;
  final bool terminee;
  final String categorie;
  final String priorite; // haute, moyenne, basse
  final bool estSynchronisee;
  final bool estSupprimee;

  ModeleTache({
    required this.id,
    required this.userId,
    required this.titre,
    required this.heure,
    required this.date,
    required this.terminee,
    required this.categorie,
    this.priorite = 'moyenne',
    this.estSynchronisee = true,
    this.estSupprimee = false,
  });

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'userId': userId,
      'titre': titre,
      'heure': heure,
      'date': date.toIso8601String(),
      'categorie': categorie,
      'priorite': priorite,
      'terminee': terminee ? 1 : 0,
      'estSynchronisee': estSynchronisee ? 1 : 0,
      'estSupprimee': estSupprimee ? 1 : 0,
    };
  }

  Map<String, dynamic> toCloudMap() {
    return {
      'userId': userId,
      'titre': titre,
      'heure': heure,
      'date': date.toIso8601String(),
      'categorie': categorie,
      'priorite': priorite,
      'terminee': terminee,
    };
  }

  factory ModeleTache.fromMap(Map<String, dynamic> map) {
    return ModeleTache(
      id: (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      titre: (map['titre'] ?? '').toString(),
      heure: (map['heure'] ?? '--:--').toString(),
      date: DateTime.parse(map['date']),
      categorie: (map['categorie'] ?? 'Autre').toString(),
      priorite: (map['priorite'] ?? 'moyenne').toString(),
      terminee: (map['terminee'] ?? 0) == 1 || (map['terminee'] == true),
      estSynchronisee: (map['estSynchronisee'] ?? 1) == 1,
      estSupprimee: (map['estSupprimee'] ?? 0) == 1,
    );
  }

  ModeleTache copyWith({
    String? id,
    String? userId,
    String? titre,
    String? heure,
    DateTime? date,
    bool? terminee,
    String? categorie,
    String? priorite,
    bool? estSynchronisee,
    bool? estSupprimee,
  }) {
    return ModeleTache(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titre: titre ?? this.titre,
      heure: heure ?? this.heure,
      date: date ?? this.date,
      terminee: terminee ?? this.terminee,
      categorie: categorie ?? this.categorie,
      priorite: priorite ?? this.priorite,
      estSynchronisee: estSynchronisee ?? this.estSynchronisee,
      estSupprimee: estSupprimee ?? this.estSupprimee,
    );
  }
}
