class ModeleContexte {
  final String type;
  final String id;
  final String titre;
  final String contenu;
  final String source;

  ModeleContexte({
    required this.type,
    required this.id,
    required this.titre,
    required this.contenu,
    required this.source,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'id': id,
      'titre': titre,
      'contenu': contenu,
      'source': source,
    };
  }

  factory ModeleContexte.fromMap(Map<String, dynamic> map) {
    return ModeleContexte(
      type: (map['type'] ?? '').toString(),
      id: (map['id'] ?? '').toString(),
      titre: (map['titre'] ?? '').toString(),
      contenu: (map['contenu'] ?? '').toString(),
      source: (map['source'] ?? '').toString(),
    );
  }

  bool get estVide {
    return type.trim().isEmpty &&
        id.trim().isEmpty &&
        titre.trim().isEmpty &&
        contenu.trim().isEmpty &&
        source.trim().isEmpty;
  }
}
