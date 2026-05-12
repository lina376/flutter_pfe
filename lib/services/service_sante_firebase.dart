import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ora/models/modele_sante.dart';

class ServiceSanteFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
Future<List<ModeleSante>> obtenirEntreDates({
  required String userId,
  required String debut,
  required String fin,
}) async {
  final snapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('sante')
      .where('date', isGreaterThanOrEqualTo: debut)
      .where('date', isLessThanOrEqualTo: fin)
      .orderBy('date')
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    return ModeleSante.fromMap({
      ...data,
      'synced': true,
    });
  }).toList();
}

Future<List<ModeleSante>> obtenirSemaine(String userId, String debut, String fin) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('sante')
      .where('userId', isEqualTo: userId)
      .where('date', isGreaterThanOrEqualTo: debut)
      .where('date', isLessThanOrEqualTo: fin)
      .get();

  return snapshot.docs.map((doc) {
    return ModeleSante.fromMap(doc.data());
  }).toList();
}
  Future<void> sauvegarder(ModeleSante sante) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sante')
        .doc(sante.id)
        .set({
          'id': sante.id,
          'userId': sante.userId,
          'date': sante.date,
          'age': sante.age,
          'poids': sante.poids,
          'activite': sante.activite,
          'heuresSommeil': sante.heuresSommeil,
          'humeur': sante.humeur,
          'updatedAt': sante.updatedAt.toIso8601String(),
        });
  }
}
