import 'package:cloud_firestore/cloud_firestore.dart';

class ModeleNote {
  final String id;
  final String titre;
  final String contenu;
  final bool liked;
  final DateTime date;

  // local sync
  final bool estSynchronisee;
  final bool estSupprimee;

  const ModeleNote({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.liked,
    required this.date,
    this.estSynchronisee = true,
    this.estSupprimee = false,
  });

  factory ModeleNote.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return ModeleNote(
      id: doc.id,
      titre: (data['titre'] ?? 'Sans titre').toString(),
      contenu: (data['contenu'] ?? '').toString(),
      liked: (data['liked'] ?? false) == true,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estSynchronisee: true,
      estSupprimee: false,
    );
  }

  factory ModeleNote.fromLocalMap(Map<String, dynamic> map) {
    return ModeleNote(
      id: (map['id'] ?? '').toString(),
      titre: (map['titre'] ?? 'Sans titre').toString(),
      contenu: (map['contenu'] ?? '').toString(),
      liked: (map['liked'] ?? 0) == 1,
      date: DateTime.tryParse((map['date'] ?? '').toString()) ?? DateTime.now(),
      estSynchronisee: (map['estSynchronisee'] ?? 0) == 1,
      estSupprimee: (map['estSupprimee'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titre': titre.isEmpty ? 'Sans titre' : titre,
      'contenu': contenu,
      'liked': liked,
      'date': Timestamp.fromDate(date),
    };
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'titre': titre.isEmpty ? 'Sans titre' : titre,
      'contenu': contenu,
      'liked': liked ? 1 : 0,
      'date': date.toIso8601String(),
      'estSynchronisee': estSynchronisee ? 1 : 0,
      'estSupprimee': estSupprimee ? 1 : 0,
    };
  }

  ModeleNote copyWith({
    String? id,
    String? titre,
    String? contenu,
    bool? liked,
    DateTime? date,
    bool? estSynchronisee,
    bool? estSupprimee,
  }) {
    return ModeleNote(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      liked: liked ?? this.liked,
      date: date ?? this.date,
      estSynchronisee: estSynchronisee ?? this.estSynchronisee,
      estSupprimee: estSupprimee ?? this.estSupprimee,
    );
  }
}
