import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<bool> isFavori(String idOriginal) async {
  final user = _auth.currentUser;
  if (user == null) return false;

  final query = await _firestore
      .collection('users')
      .doc(user.uid)
      .collection('favoris')
      .where('idOriginal', isEqualTo: idOriginal)
      .get();

  return query.docs.isNotEmpty;
}

Future<void> toggleFavori(Map<String, dynamic> item) async {
  final user = _auth.currentUser;
  if (user == null) return;

  final ref = _firestore
      .collection('users')
      .doc(user.uid)
      .collection('favoris');

  final String idOriginal = (item['idOriginal'] ?? item['id'] ?? '').toString();
  if (idOriginal.isEmpty) return;

  final query = await ref.where('idOriginal', isEqualTo: idOriginal).get();

  if (query.docs.isNotEmpty) {
    for (final doc in query.docs) {
      await doc.reference.delete();
    }
  } else {
    await ref.add({
      'idOriginal': idOriginal,
      'type': item['type'] ?? 'note',
      'title': item['title'] ?? item['titre'] ?? '',
      'desc': item['desc'] ?? item['contenu'] ?? '',
      'contenu': item['contenu'] ?? '',
      'date': item['date'] is DateTime
          ? Timestamp.fromDate(item['date'])
          : Timestamp.now(),
      'noteDocId':
          item['noteDocId'] ?? idOriginal.toString().replaceFirst('note_', ''),
    });
  }
}
