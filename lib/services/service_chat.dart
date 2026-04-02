import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceChat {
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? obtenirUtilisateurActuel() {
    return _authentification.currentUser;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenirFluxMessages({
    required String conversationId,
  }) {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> ajouterMessage({
    required String conversationId,
    required String texte,
  }) async {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return;

    final conversationRef = _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('conversations')
        .doc(conversationId);

    await conversationRef.collection('messages').add({
      'texte': texte,
      'sender': 'user',
      'date': Timestamp.now(),
    });

    const String reponseOra =
        "Bonjour, je suis ORA. J'ai bien reçu votre message.";

    await conversationRef.collection('messages').add({
      'texte': reponseOra,
      'sender': 'ora',
      'date': Timestamp.now(),
    });

    await conversationRef.update({
      'dernierMessage': reponseOra,
      'dateMaj': Timestamp.now(),
      'titre': texte.length > 20 ? "${texte.substring(0, 20)}..." : texte,
    });
  }
}
