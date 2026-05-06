import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ora/models/modele_sante.dart';

class ServiceSanteFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
