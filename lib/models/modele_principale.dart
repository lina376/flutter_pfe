import 'package:cloud_firestore/cloud_firestore.dart';

class ModeleUtilisateurPrincipal {
  final String nom;
  final String prenom;

  const ModeleUtilisateurPrincipal({required this.nom, required this.prenom});

  factory ModeleUtilisateurPrincipal.fromMap(Map<String, dynamic>? data) {
    return ModeleUtilisateurPrincipal(
      nom: (data?['nom'] ?? '').toString().trim(),
      prenom: (data?['prenom'] ?? '').toString().trim(),
    );
  }

  String get nomAffichage {
    final nomComplet = '$prenom $nom'.trim();
    return nomComplet.isEmpty ? 'ORA' : nomComplet;
  }

  Map<String, dynamic> toMap() {
    return {'nom': nom, 'prenom': prenom};
  }
}

class ModeleConversation {
  final String id;
  final String titre;
  final String dernierMessage;
  final Timestamp? dateCreation;
  final Timestamp? dateMaj;

  const ModeleConversation({
    required this.id,
    required this.titre,
    required this.dernierMessage,
    this.dateCreation,
    this.dateMaj,
  });

  factory ModeleConversation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return ModeleConversation(
      id: doc.id,
      titre: (data?['titre'] ?? '').toString(),
      dernierMessage: (data?['dernierMessage'] ?? '').toString(),
      dateCreation: data?['dateCreation'] as Timestamp?,
      dateMaj: data?['dateMaj'] as Timestamp?,
    );
  }

  factory ModeleConversation.fromMap(Map<String, dynamic> data, String id) {
    return ModeleConversation(
      id: id,
      titre: (data['titre'] ?? '').toString(),
      dernierMessage: (data['dernierMessage'] ?? '').toString(),
      dateCreation: data['dateCreation'] as Timestamp?,
      dateMaj: data['dateMaj'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'dernierMessage': dernierMessage,
      'dateCreation': dateCreation,
      'dateMaj': dateMaj,
    };
  }

  String get heureFormattee {
    if (dateMaj == null) return '';
    final date = dateMaj!.toDate();
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
