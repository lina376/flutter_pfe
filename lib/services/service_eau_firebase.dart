import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ora/models/modele_eau.dart';

class ServiceEauFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('eau');
  }

  Future<void> sauvegarder(ModeleEau eau) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _collection(user.uid).doc(eau.id).set({
      'id': eau.id,
      'userId': eau.userId,
      'date': eau.date,
      'verres': eau.verres,
      'objectif': eau.objectif,
      'updatedAt': eau.updatedAt.toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<ModeleEau?> obtenirParDate({
    required String userId,
    required String date,
  }) async {
    final snapshot = await _collection(userId)
        .where('date', isEqualTo: date)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return ModeleEau.fromMap({
      ...snapshot.docs.first.data(),
      'userId': userId,
      'synced': true,
    });
  }

  Future<List<ModeleEau>> obtenirEntreDates({
    required String userId,
    required String debut,
    required String fin,
  }) async {
    final snapshot = await _collection(userId)
        .where('date', isGreaterThanOrEqualTo: debut)
        .where('date', isLessThanOrEqualTo: fin)
        .orderBy('date')
        .get();

    return snapshot.docs.map((doc) {
      return ModeleEau.fromMap({
        ...doc.data(),
        'userId': userId,
        'synced': true,
      });
    }).toList();
  }
}
