import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ora/models/modele_sante.dart';

class ServiceSanteFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('sante');
  }

  Future<void> sauvegarder(ModeleSante sante) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _collection(user.uid).doc(sante.id).set({
      'id': sante.id,
      'userId': sante.userId,
      'date': sante.date,
      'age': sante.age,
      'poids': sante.poids,
      'activite': sante.activite,
      'heuresSommeil': sante.heuresSommeil,
      'humeur': sante.humeur,
      'updatedAt': sante.updatedAt.toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<ModeleSante?> obtenirParDate({
    required String userId,
    required String date,
  }) async {
    final snapshot = await _collection(userId)
        .where('date', isEqualTo: date)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return ModeleSante.fromMap({
      ...snapshot.docs.first.data(),
      'synced': true,
    });
  }

  Future<List<ModeleSante>> obtenirEntreDates({
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
      return ModeleSante.fromMap({
        ...doc.data(),
        'synced': true,
      });
    }).toList();
  }

  // Gardée pour compatibilité avec l'ancien code.
  Future<List<ModeleSante>> obtenirSemaine(
    String userId,
    String debut,
    String fin,
  ) {
    return obtenirEntreDates(userId: userId, debut: debut, fin: fin);
  }
}
