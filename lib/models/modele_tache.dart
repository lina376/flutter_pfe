class ModeleTache {
  final String? id;
  final String titre;
  final String heure;
  final DateTime date;
  final bool terminee;

  ModeleTache({
    this.id,
    required this.titre,
    required this.heure,
    required this.date,
    required this.terminee,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id != null ? int.tryParse(id!) : null,
      'titre': titre,
      'heure': heure,
      'date': date.toIso8601String(),
      'terminee': terminee ? 1 : 0,
    };
  }

  factory ModeleTache.fromMap(Map<String, dynamic> map) {
    return ModeleTache(
      id: map['id'].toString(),
      titre: (map['titre'] ?? '').toString(),
      heure: (map['heure'] ?? '--:--').toString(),
      date: DateTime.parse(map['date']),
      terminee: (map['terminee'] ?? 0) == 1,
    );
  }

  ModeleTache copyWith({
    String? id,
    String? titre,
    String? heure,
    DateTime? date,
    bool? terminee,
  }) {
    return ModeleTache(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      heure: heure ?? this.heure,
      date: date ?? this.date,
      terminee: terminee ?? this.terminee,
    );
  }
}
