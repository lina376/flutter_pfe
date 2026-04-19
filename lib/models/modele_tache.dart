class ModeleTache {
  final String id;
  final String titre;
  final String heure;
  final DateTime date;
  final bool terminee;
  final String categorie;
  final bool estSynchronisee;
  final bool estSupprimee;

  ModeleTache({
    required this.id,
    required this.titre,
    required this.heure,
    required this.date,
    required this.terminee,
    required this.categorie,
    this.estSynchronisee = true,
    this.estSupprimee = false,
  });

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'titre': titre,
      'heure': heure,
      'date': date.toIso8601String(),
      'categorie': categorie,
      'terminee': terminee ? 1 : 0,
      'estSynchronisee': estSynchronisee ? 1 : 0,
      'estSupprimee': estSupprimee ? 1 : 0,
    };
  }

  Map<String, dynamic> toCloudMap() {
    return {
      'titre': titre,
      'heure': heure,
      'date': date.toIso8601String(),
      'categorie': categorie,
      'terminee': terminee,
    };
  }

  factory ModeleTache.fromMap(Map<String, dynamic> map) {
    return ModeleTache(
      id: (map['id'] ?? '').toString(),
      titre: (map['titre'] ?? '').toString(),
      heure: (map['heure'] ?? '--:--').toString(),
      date: DateTime.parse(map['date']),
      categorie: (map['categorie'] ?? 'Autre').toString(),
      terminee: (map['terminee'] ?? 0) == 1 || (map['terminee'] == true),
      estSynchronisee: (map['estSynchronisee'] ?? 1) == 1,
      estSupprimee: (map['estSupprimee'] ?? 0) == 1,
    );
  }

  ModeleTache copyWith({
    String? id,
    String? titre,
    String? heure,
    DateTime? date,
    bool? terminee,
    String? categorie,
    bool? estSynchronisee,
    bool? estSupprimee,
  }) {
    return ModeleTache(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      heure: heure ?? this.heure,
      date: date ?? this.date,
      terminee: terminee ?? this.terminee,
      categorie: categorie ?? this.categorie,
      estSynchronisee: estSynchronisee ?? this.estSynchronisee,
      estSupprimee: estSupprimee ?? this.estSupprimee,
    );
  }
}
