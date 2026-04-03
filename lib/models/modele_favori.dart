import 'package:cloud_firestore/cloud_firestore.dart';

class ModeleFavori {
  final String id;
  final String idOriginal;
  final String type;
  final String title;
  final String desc;
  final String contenu;
  final DateTime date;
  final String noteDocId;

  const ModeleFavori({
    required this.id,
    required this.idOriginal,
    required this.type,
    required this.title,
    required this.desc,
    required this.contenu,
    required this.date,
    required this.noteDocId,
  });

  factory ModeleFavori.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return ModeleFavori(
      id: doc.id,
      idOriginal: (data['idOriginal'] ?? '').toString(),
      type: (data['type'] ?? 'note').toString(),
      title: (data['title'] ?? '').toString(),
      desc: (data['desc'] ?? '').toString(),
      contenu: (data['contenu'] ?? '').toString(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      noteDocId: (data['noteDocId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idOriginal': idOriginal,
      'type': type,
      'title': title,
      'desc': desc,
      'contenu': contenu,
      'date': Timestamp.fromDate(date),
      'noteDocId': noteDocId,
    };
  }
}
