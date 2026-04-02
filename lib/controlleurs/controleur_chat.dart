import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/service_chat.dart';

class ControleurChat {
  final ServiceChat _serviceChat = ServiceChat();

  User? obtenirUtilisateurActuel() {
    return _serviceChat.obtenirUtilisateurActuel();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenirFluxMessages({
    required String conversationId,
  }) {
    return _serviceChat.obtenirFluxMessages(conversationId: conversationId);
  }

  Future<void> ajouterMessage({
    required String conversationId,
    required String texte,
  }) {
    return _serviceChat.ajouterMessage(
      conversationId: conversationId,
      texte: texte,
    );
  }

  String formaterHeure(Timestamp? timestamp) {
    if (timestamp == null) return "";

    final date = timestamp.toDate();
    final heure = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return "$heure:$minute";
  }
}
