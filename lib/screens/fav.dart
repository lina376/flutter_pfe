import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final query = await ref.where('idOriginal', isEqualTo: item['id']).get();

  if (query.docs.isNotEmpty) {
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  } else {
    await ref.add({
      'idOriginal': item['id'],
      'type': item['type'] ?? 'note',
      'title': item['title'] ?? '',
      'desc': item['desc'] ?? '',
      'contenu': item['contenu'] ?? '',
      'date': item['date'] is DateTime
          ? Timestamp.fromDate(item['date'])
          : Timestamp.now(),
      'noteDocId': item['noteDocId'] ?? '',
    });
  }
}
