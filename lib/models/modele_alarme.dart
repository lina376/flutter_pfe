class ModeleAlarme {
  final int? id;
  final String userId;
  final String titre;
  final String? note;
  final int heure;
  final int minute;
  final String jours;
  final bool active;
  final String? date;

  ModeleAlarme({
    this.id,
    required this.userId,
    required this.titre,
    this.note,
    required this.heure,
    required this.minute,
    required this.jours,
    required this.active,
    this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'titre': titre,
      'note': note,
      'heure': heure,
      'minute': minute,
      'jours': jours,
      'active': active ? 1 : 0,
      'date': date,
    };
  }

  ModeleAlarme copyWith({
    int? id,
    String? userId,
    String? titre,
    String? note,
    int? heure,
    int? minute,
    String? jours,
    bool? active,
    String? date,
  }) {
    return ModeleAlarme(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titre: titre ?? this.titre,
      note: note ?? this.note,
      heure: heure ?? this.heure,
      minute: minute ?? this.minute,
      jours: jours ?? this.jours,
      active: active ?? this.active,
      date: date ?? this.date,
    );
  }

  factory ModeleAlarme.fromMap(Map<String, dynamic> map) {
    return ModeleAlarme(
      id: map['id'],
      userId: (map['userId'] ?? '').toString(),
      titre: map['titre'],
      note: map['note'],
      heure: map['heure'],
      minute: map['minute'],
      jours: map['jours'],
      active: map['active'] == 1,
      date: map['date'],
    );
  }
}
