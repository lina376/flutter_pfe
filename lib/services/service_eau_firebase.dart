import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ora/models/modele_eau.dart';

class ServiceEauFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
Future<List<ModeleEau>> obtenirEntreDates({
  required String userId,
  required String debut,
  required String fin,
}) async {
  final snapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('eau')
      .where('date', isGreaterThanOrEqualTo: debut)
      .where('date', isLessThanOrEqualTo: fin)
      .get();

  return snapshot.docs.map((doc) {
    return ModeleEau.fromMap({
      ...doc.data(),
      'userId': userId,
      'synced': true,
    });
  }).toList();
}
  Future<void> sauvegarder(ModeleEau eau) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('eau')
        .doc(eau.id)
        .set({
          'id': eau.id,
          'date': eau.date,
          'verres': eau.verres,
          'objectif': eau.objectif,
          'updatedAt': eau.updatedAt.toIso8601String(),
        });
  }
}
