import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ora/models/modele_sport.dart';

class ServiceSportFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sauvegarder(ModeleSport sport) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sport')
        .doc(sport.id)
        .set({
          'id': sport.id,
          'userId': sport.userId,
          'date': sport.date,
          'minutes': sport.minutes,
          'objectifMinutes': sport.objectifMinutes,
          'objectifSport': sport.objectifSport,
          'etatSante': sport.etatSante,
          'typeSeance': sport.typeSeance,
          'intensite': sport.intensite,
          'calories': sport.calories,
          'updatedAt': sport.updatedAt.toIso8601String(),
        });
  }
}
