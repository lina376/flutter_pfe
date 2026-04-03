import 'package:cloud_firestore/cloud_firestore.dart';

class ModeleNote {
  final String id;
  final String titre;
  final String contenu;
  final bool liked;
  final DateTime date;

  const ModeleNote({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.liked,
    required this.date,
  });

  factory ModeleNote.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return ModeleNote(
      id: doc.id,
      titre: (data['titre'] ?? 'Sans titre').toString(),
      contenu: (data['contenu'] ?? '').toString(),
      liked: (data['liked'] ?? false) == true,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
}
