class ModeleAlarme {
  final int? id;
  final String titre;
  final String? note;
  final int heure;
  final int minute;
  final String jours;
  final bool active;

  ModeleAlarme({
    this.id,
    required this.titre,
    this.note,
    required this.heure,
    required this.minute,
    required this.jours,
    required this.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'note': note,
      'heure': heure,
      'minute': minute,
      'jours': jours,
      'active': active ? 1 : 0,
    };
  }

  factory ModeleAlarme.fromMap(Map<String, dynamic> map) {
    return ModeleAlarme(
      id: map['id'],
      titre: map['titre'],
      note: map['note'],
      heure: map['heure'],
      minute: map['minute'],
      jours: map['jours'],
      active: map['active'] == 1,
    );
  }
}
