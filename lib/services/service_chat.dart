import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ora/services/service_gemini.dart';
import 'service_note.dart';
import 'service_tache.dart';
import 'service_alarme.dart';

import '../models/modele_contexte.dart';
import '../models/modele_alarme.dart';

class ServiceChat {
  final ServiceTache _serviceTache = ServiceTache();
  final ServiceGemini _gemini = ServiceGemini();
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ServiceNote _serviceNote = ServiceNote();
  final ServiceAlarme _serviceAlarme = ServiceAlarme();

  User? obtenirUtilisateurActuel() {
    return _authentification.currentUser;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenirFluxMessages({
    required String conversationId,
  }) {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('date', descending: true)
        .snapshots();
  }

  int _extraireHeure(String heureTexte, int valeurDefaut) {
    try {
      if (!heureTexte.contains(":")) return valeurDefaut;
      return int.parse(heureTexte.split(":")[0]);
    } catch (_) {
      return valeurDefaut;
    }
  }

  int _extraireMinute(String heureTexte, int valeurDefaut) {
    try {
      if (!heureTexte.contains(":")) return valeurDefaut;
      return int.parse(heureTexte.split(":")[1]);
    } catch (_) {
      return valeurDefaut;
    }
  }

  Future<void> ajouterMessage({
    required String conversationId,
    required String texte,
    ModeleContexte? contexte,
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

    if (contexte == null) {
      final conversationDoc = await conversationRef.get();
      final data = conversationDoc.data();

      if (data != null &&
          (data['contexteType'] ?? '').toString().isNotEmpty &&
          (data['contexteId'] ?? '').toString().isNotEmpty) {
        contexte = ModeleContexte(
          type: (data['contexteType'] ?? '').toString(),
          id: (data['contexteId'] ?? '').toString(),
          titre: (data['contexteTitre'] ?? '').toString(),
          contenu: (data['contexteContenu'] ?? '').toString(),
          source: (data['contexteSource'] ?? '').toString(),
        );
      }
    }

    final resultat = await _gemini.analyserCommande(texte, contexte: contexte);
    String reponseOra = "";
    final action = (resultat["action"] ?? "CHAT").toString();

    if (action == "CREATE_NOTE") {
      final titre = (resultat["titre"] ?? "Sans titre").toString();
      final contenu = (resultat["contenu"] ?? "").toString();

      final nouvelId = await _serviceNote.ajouterNote(
        titre: titre,
        contenu: contenu,
        aimee: false,
      );

      contexte = ModeleContexte(
        type: "note",
        id: nouvelId,
        titre: titre,
        contenu: contenu,
        source: "chat",
      );

      await conversationRef.set({
        'contexteType': 'note',
        'contexteId': nouvelId,
        'contexteTitre': titre,
        'contexteContenu': contenu,
        'contexteSource': 'chat',
      }, SetOptions(merge: true));

      reponseOra = "La note a été ajoutée avec succès.";
    } else if (action == "UPDATE_NOTE") {
      final titre = (resultat["titre"] ?? "").toString();
      final contenu = (resultat["contenu"] ?? "").toString();

      if (contexte != null &&
          contexte.type == "note" &&
          contexte.id.isNotEmpty) {
        await _serviceNote.mettreAJourNote(
          idNote: contexte.id,
          titre: (resultat["nouveau_titre"] ?? contexte.titre).toString(),
          contenu: contenu.isEmpty ? contexte.contenu : contenu,
          aimee: false,
        );

        reponseOra = "La note actuelle a été modifiée avec succès.";
      } else {
        final note = await _serviceNote.trouverNoteParTitre(titre);

        if (note != null) {
          await _serviceNote.mettreAJourNote(
            idNote: note.id,
            titre: (resultat["nouveau_titre"] ?? note.titre).toString(),
            contenu: contenu.isEmpty ? note.contenu : contenu,
            aimee: note.liked,
          );

          reponseOra = "La note a été modifiée avec succès.";
        } else {
          reponseOra = "Je n'ai pas trouvé la note à modifier.";
        }
      }
    } else if (action == "DELETE_NOTE") {
      if (contexte != null &&
          contexte.type == "note" &&
          contexte.id.isNotEmpty) {
        await _serviceNote.supprimerNote(contexte.id);

        await conversationRef.set({
          'contexteType': '',
          'contexteId': '',
          'contexteTitre': '',
          'contexteContenu': '',
          'contexteSource': '',
        }, SetOptions(merge: true));

        reponseOra = "La note actuelle a été supprimée avec succès.";
      } else {
        final titre = (resultat["titre"] ?? "").toString();
        final note = await _serviceNote.trouverNoteParTitre(titre);

        if (note != null) {
          await _serviceNote.supprimerNote(note.id);
          reponseOra = "La note a été supprimée avec succès.";
        } else {
          reponseOra = "Je n'ai pas trouvé la note à supprimer.";
        }
      }
    } else if (action == "SEARCH_NOTE") {
      final titre = (resultat["titre"] ?? "").toString();
      final notes = await _serviceNote.rechercherNotesParTitre(titre);

      if (notes.isEmpty) {
        reponseOra = "Je n'ai trouvé aucune note avec ce titre.";
      } else if (notes.length == 1) {
        final note = notes.first;
        reponseOra = 'J\'ai trouvé la note "${note.titre}" : ${note.contenu}';
      } else {
        final titres = notes.map((n) => n.titre).join(", ");
        reponseOra = "J'ai trouvé plusieurs notes : $titres";
      }
    } else if (action == "CREATE_TASK") {
      final titre = (resultat["titre"] ?? "Nouvelle tâche").toString();
      final heure = (resultat["heure"] ?? "--:--").toString();
      final categorie = (resultat["categorie"] ?? "Autre").toString();
      final dateTexte = (resultat["date"] ?? "").toString();

      DateTime dateTache;
      try {
        dateTache = DateTime.parse(dateTexte);
      } catch (_) {
        dateTache = DateTime.now();
      }

      await _serviceTache.ajouterTache(
        titre: titre,
        heure: heure,
        date: dateTache,
        categorie: categorie,
      );

      reponseOra = "La tâche a été ajoutée avec succès.";
    } else if (action == "UPDATE_TASK") {
      final titre = (resultat["titre"] ?? "").toString();
      final heure = (resultat["heure"] ?? "--:--").toString();
      final categorie = (resultat["categorie"] ?? "Autre").toString();
      final dateTexte = (resultat["date"] ?? "").toString();

      final tache = await _serviceTache.trouverTacheParTitre(titre);

      if (tache != null) {
        DateTime dateTache;
        try {
          dateTache = DateTime.parse(dateTexte);
        } catch (_) {
          dateTache = tache.date;
        }

        await _serviceTache.mettreAJourTache(
          idTache: tache.id,
          titre: tache.titre,
          heure: heure,
          date: dateTache,
          categorie: categorie,
          terminee: tache.terminee,
        );

        reponseOra = "La tâche a été modifiée avec succès.";
      } else {
        reponseOra = "Je n'ai pas trouvé la tâche à modifier.";
      }
    } else if (action == "DELETE_TASK") {
      final titre = (resultat["titre"] ?? "").toString();
      final tache = await _serviceTache.trouverTacheParTitre(titre);

      if (tache != null) {
        await _serviceTache.supprimerTache(tache.id);
        reponseOra = "La tâche a été supprimée avec succès.";
      } else {
        reponseOra = "Je n'ai pas trouvé la tâche à supprimer.";
      }
    } else if (action == "SEARCH_TASK") {
      final titre = (resultat["titre"] ?? "").toString();
      final taches = await _serviceTache.rechercherTachesParTitre(titre);

      if (taches.isEmpty) {
        reponseOra = "Je n'ai trouvé aucune tâche avec ce titre.";
      } else if (taches.length == 1) {
        final tache = taches.first;
        reponseOra =
            'J\'ai trouvé la tâche "${tache.titre}" - ${tache.categorie} à ${tache.heure}.';
      } else {
        final titres = taches.map((t) => t.titre).join(", ");
        reponseOra = "J'ai trouvé plusieurs tâches : $titres";
      }
    } else if (action == "CREATE_ALARME") {
      final dateTexte = (resultat["date"] ?? "").toString();
      final titre = (resultat["titre"] ?? "Alarme").toString();
      final heureTexte = (resultat["heure"] ?? "--:--").toString();
      final jours = (resultat["jours"] ?? "quotidien").toString();

      final heure = _extraireHeure(heureTexte, DateTime.now().hour);
      final minute = _extraireMinute(heureTexte, DateTime.now().minute);

      await _serviceAlarme.ajouterAlarme(
        ModeleAlarme(
          titre: titre,
          note: dateTexte.isEmpty ? "Ajoutée par ORA" : "Date: $dateTexte",
          heure: heure,
          minute: minute,
          jours: jours,
          active: true,
        ),
      );

      reponseOra = "L’alarme a été ajoutée avec succès.";
    } else if (action == "UPDATE_ALARME") {
      final titre = (resultat["titre"] ?? "").toString();
      final nouveauTitre = (resultat["nouveau_titre"] ?? "").toString();
      final heureTexte = (resultat["heure"] ?? "").toString();
      final jours = (resultat["jours"] ?? "").toString();

      final alarme = await _serviceAlarme.trouverAlarmeParTitre(titre);

      if (alarme != null) {
        final heure = _extraireHeure(heureTexte, alarme.heure);
        final minute = _extraireMinute(heureTexte, alarme.minute);

        await _serviceAlarme.modifierAlarme(
          ModeleAlarme(
            id: alarme.id,
            titre: nouveauTitre.isEmpty ? alarme.titre : nouveauTitre,
            note: alarme.note,
            heure: heure,
            minute: minute,
            jours: jours.isEmpty ? alarme.jours : jours,
            active: alarme.active,
          ),
        );

        reponseOra = "L’alarme a été modifiée avec succès.";
      } else {
        reponseOra = "Je n’ai pas trouvé l’alarme à modifier.";
      }
    } else if (action == "DELETE_ALARME") {
      final titre = (resultat["titre"] ?? "").toString();
      final alarme = await _serviceAlarme.trouverAlarmeParTitre(titre);

      if (alarme != null && alarme.id != null) {
        await _serviceAlarme.supprimerAlarme(alarme.id!);
        reponseOra = "L’alarme a été supprimée avec succès.";
      } else {
        reponseOra = "Je n’ai pas trouvé l’alarme à supprimer.";
      }
    } else if (action == "TOGGLE_ALARME") {
      final titre = (resultat["titre"] ?? "").toString();
      final active = (resultat["active"] ?? true) == true;

      final alarme = await _serviceAlarme.trouverAlarmeParTitre(titre);

      if (alarme != null && alarme.id != null) {
        await _serviceAlarme.basculerActivation(alarme.id!, active);

        reponseOra = active
            ? "L’alarme a été activée avec succès."
            : "L’alarme a été désactivée avec succès.";
      } else {
        reponseOra = "Je n’ai pas trouvé l’alarme.";
      }
    } else {
      reponseOra = await _gemini.envoyerMessageChat(texte, contexte: contexte);
    }

    await conversationRef.collection('messages').add({
      'texte': reponseOra,
      'sender': 'ora',
      'date': Timestamp.now(),
    });

    await conversationRef.set({
      'dernierMessage': reponseOra,
      'dateMaj': Timestamp.now(),
      'titre': texte.length > 20 ? "${texte.substring(0, 20)}..." : texte,
    }, SetOptions(merge: true));
  }
}
