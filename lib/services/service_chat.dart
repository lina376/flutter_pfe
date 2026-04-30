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

  User? obtenirUtilisateurActuel() => _authentification.currentUser;

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

  String _valeur(Map<String, dynamic> data, String cle, String defaut) {
    final valeur = data[cle];
    if (valeur == null) return defaut;
    final texte = valeur.toString().trim();
    return texte.isEmpty ? defaut : texte;
  }

  DateTime _dateDepuisTexte(String texte, DateTime defaut) {
    try {
      if (texte.trim().isEmpty) return defaut;
      return DateTime.parse(texte);
    } catch (_) {
      return defaut;
    }
  }

  String _formaterDate(DateTime date) {
    String deux(int v) => v.toString().padLeft(2, '0');
    return '${deux(date.day)}/${deux(date.month)}/${date.year}';
  }

  String _iconePriorite(String priorite) {
    switch (priorite.toLowerCase().trim()) {
      case 'haute':
      case 'élevée':
      case 'elevee':
      case 'urgent':
        return '🔴';
      case 'basse':
      case 'faible':
        return '🟢';
      default:
        return '🟡';
    }
  }

  String _normaliserPriorite(String priorite) {
    final p = priorite.toLowerCase().trim();
    if (p == 'urgent' || p == 'élevée' || p == 'elevee') return 'haute';
    if (p == 'faible') return 'basse';
    if (p == 'haute' || p == 'moyenne' || p == 'basse') return p;
    return 'moyenne';
  }

  Future<ModeleContexte?> _chargerContexte(
    DocumentReference<Map<String, dynamic>> conversationRef,
    ModeleContexte? contexte,
  ) async {
    if (contexte != null && !contexte.estVide) return contexte;

    final conversationDoc = await conversationRef.get();
    final data = conversationDoc.data();

    if (data == null) return contexte;

    if ((data['contexteType'] ?? '').toString().isNotEmpty &&
        (data['contexteId'] ?? '').toString().isNotEmpty) {
      return ModeleContexte(
        type: (data['contexteType'] ?? '').toString(),
        id: (data['contexteId'] ?? '').toString(),
        titre: (data['contexteTitre'] ?? '').toString(),
        contenu: (data['contexteContenu'] ?? '').toString(),
        source: (data['contexteSource'] ?? '').toString(),
      );
    }

    return contexte;
  }

  Future<void> _enregistrerContexte(
    DocumentReference<Map<String, dynamic>> conversationRef,
    ModeleContexte? contexte,
  ) async {
    if (contexte == null || contexte.estVide) {
      await conversationRef.set({
        'contexteType': '',
        'contexteId': '',
        'contexteTitre': '',
        'contexteContenu': '',
        'contexteSource': '',
      }, SetOptions(merge: true));
      return;
    }

    await conversationRef.set({
      'contexteType': contexte.type,
      'contexteId': contexte.id,
      'contexteTitre': contexte.titre,
      'contexteContenu': contexte.contenu,
      'contexteSource': contexte.source,
    }, SetOptions(merge: true));
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

    contexte = await _chargerContexte(conversationRef, contexte);

    final commandes = await _gemini.analyserCommandes(
      texte,
      contexte: contexte,
    );
    final reponses = <String>[];

    for (final commande in commandes) {
      final resultat = await _executerCommande(
        commande,
        texteOriginal: texte,
        conversationRef: conversationRef,
        contexte: contexte,
      );

      contexte = resultat.contexte;
      reponses.add(resultat.message);
    }

    final reponseOra = reponses.where((e) => e.trim().isNotEmpty).join("\n");

    await conversationRef.collection('messages').add({
      'texte': reponseOra.isEmpty ? "Je n'ai pas bien compris." : reponseOra,
      'sender': 'ora',
      'date': Timestamp.now(),
    });

    await conversationRef.set({
      'dernierMessage': reponseOra,
      'dateMaj': Timestamp.now(),
      'titre': texte.length > 20 ? "${texte.substring(0, 20)}..." : texte,
    }, SetOptions(merge: true));
  }

  Future<_ResultatExecution> _executerCommande(
    Map<String, dynamic> resultat, {
    required String texteOriginal,
    required DocumentReference<Map<String, dynamic>> conversationRef,
    required ModeleContexte? contexte,
  }) async {
    final action = _valeur(resultat, "action", "CHAT").toUpperCase();

    if (action == "CREATE_NOTE") {
      final titre = _valeur(resultat, "titre", "Sans titre");
      final contenu = _valeur(resultat, "contenu", "");

      final nouvelId = await _serviceNote.ajouterNote(
        titre: titre,
        contenu: contenu,
        aimee: false,
      );

      final nouveauContexte = ModeleContexte(
        type: "note",
        id: nouvelId,
        titre: titre,
        contenu: contenu,
        source: "chat",
      );

      await _enregistrerContexte(conversationRef, nouveauContexte);
      return _ResultatExecution(
        "La note a été ajoutée avec succès.",
        nouveauContexte,
      );
    }

    if (action == "UPDATE_NOTE") {
      final titre = _valeur(resultat, "titre", "");
      final contenu = _valeur(resultat, "contenu", "");
      final nouveauTitre = _valeur(resultat, "nouveau_titre", "");

      if (contexte != null &&
          contexte.type == "note" &&
          contexte.id.isNotEmpty &&
          titre.isEmpty) {
        final titreFinal = nouveauTitre.isEmpty ? contexte.titre : nouveauTitre;
        final contenuFinal = contenu.isEmpty ? contexte.contenu : contenu;

        await _serviceNote.mettreAJourNote(
          idNote: contexte.id,
          titre: titreFinal,
          contenu: contenuFinal,
          aimee: false,
        );

        final nouveauContexte = ModeleContexte(
          type: "note",
          id: contexte.id,
          titre: titreFinal,
          contenu: contenuFinal,
          source: contexte.source,
        );
        await _enregistrerContexte(conversationRef, nouveauContexte);
        return _ResultatExecution(
          "La note actuelle a été modifiée avec succès.",
          nouveauContexte,
        );
      }

      final note = await _serviceNote.trouverNoteParTitre(titre);
      if (note == null)
        return _ResultatExecution(
          "Je n'ai pas trouvé la note à modifier.",
          contexte,
        );

      final titreFinal = nouveauTitre.isEmpty ? note.titre : nouveauTitre;
      final contenuFinal = contenu.isEmpty ? note.contenu : contenu;
      await _serviceNote.mettreAJourNote(
        idNote: note.id,
        titre: titreFinal,
        contenu: contenuFinal,
        aimee: note.liked,
      );

      final nouveauContexte = ModeleContexte(
        type: "note",
        id: note.id,
        titre: titreFinal,
        contenu: contenuFinal,
        source: "chat",
      );
      await _enregistrerContexte(conversationRef, nouveauContexte);
      return _ResultatExecution(
        "La note a été modifiée avec succès.",
        nouveauContexte,
      );
    }

    if (action == "DELETE_NOTE") {
      final titre = _valeur(resultat, "titre", "");

      if (contexte != null &&
          contexte.type == "note" &&
          contexte.id.isNotEmpty &&
          titre.isEmpty) {
        await _serviceNote.supprimerNote(contexte.id);
        await _enregistrerContexte(conversationRef, null);
        return _ResultatExecution(
          "La note actuelle a été supprimée avec succès.",
          null,
        );
      }

      final note = await _serviceNote.trouverNoteParTitre(titre);
      if (note == null)
        return _ResultatExecution(
          "Je n'ai pas trouvé la note à supprimer.",
          contexte,
        );

      await _serviceNote.supprimerNote(note.id);
      return _ResultatExecution(
        "La note a été supprimée avec succès.",
        contexte,
      );
    }

    if (action == "SEARCH_NOTE") {
      final titre = _valeur(resultat, "titre", "");
      final notes = await _serviceNote.rechercherNotesParTitre(titre);

      if (notes.isEmpty)
        return _ResultatExecution(
          "Je n'ai trouvé aucune note avec ce titre.",
          contexte,
        );

      if (notes.length == 1) {
        final note = notes.first;
        final nouveauContexte = ModeleContexte(
          type: "note",
          id: note.id,
          titre: note.titre,
          contenu: note.contenu,
          source: "chat",
        );
        await _enregistrerContexte(conversationRef, nouveauContexte);
        return _ResultatExecution(
          'J\'ai trouvé la note "${note.titre}" : ${note.contenu}',
          nouveauContexte,
        );
      }

      final titres = notes.map((n) => n.titre).join(", ");
      return _ResultatExecution(
        "J'ai trouvé plusieurs notes : $titres",
        contexte,
      );
    }

    if (action == "CREATE_TASK") {
      final titre = _valeur(resultat, "titre", "Nouvelle tâche");
      final heure = _valeur(resultat, "heure", "--:--");
      final categorie = _valeur(resultat, "categorie", "Autre");
      final priorite = _normaliserPriorite(
        _valeur(resultat, "priorite", "moyenne"),
      );
      final dateTexte = _valeur(resultat, "date", "");
      final dateTache = _dateDepuisTexte(dateTexte, DateTime.now());

      await _serviceTache.ajouterTache(
        titre: titre,
        heure: heure,
        date: dateTache,
        categorie: categorie,
        priorite: priorite,
      );

      final tache = await _serviceTache.trouverTacheParTitre(titre);
      final nouveauContexte = tache == null
          ? contexte
          : ModeleContexte(
              type: "tache",
              id: tache.id,
              titre: tache.titre,
              contenu:
                  "${tache.categorie} - ${tache.priorite} - ${tache.heure}",
              source: "chat",
            );

      await _enregistrerContexte(conversationRef, nouveauContexte);
      return _ResultatExecution(
        "La tâche a été ajoutée avec succès. Priorité : $priorite.",
        nouveauContexte,
      );
    }

    if (action == "UPDATE_TASK") {
      final titre = _valeur(resultat, "titre", "");
      final nouveauTitre = _valeur(resultat, "nouveau_titre", "");
      final heure = _valeur(resultat, "heure", "");
      final categorie = _valeur(resultat, "categorie", "");
      final prioriteTexte = _valeur(resultat, "priorite", "");
      final dateTexte = _valeur(resultat, "date", "");
      final contientTerminee = resultat.containsKey("terminee");
      final terminee = (resultat["terminee"] ?? false) == true;

      var tache = titre.isNotEmpty
          ? await _serviceTache.trouverTacheParTitre(titre)
          : null;

      if (tache == null &&
          contexte != null &&
          contexte.type == "tache" &&
          contexte.id.isNotEmpty) {
        final toutes = await _serviceTache.recupererToutesLesTaches();
        try {
          tache = toutes.firstWhere((e) => e.id == contexte.id);
        } catch (_) {
          tache = null;
        }
      }

      if (tache == null)
        return _ResultatExecution(
          "Je n'ai pas trouvé la tâche à modifier.",
          contexte,
        );

      final titreFinal = nouveauTitre.isEmpty ? tache.titre : nouveauTitre;
      final heureFinale = heure.isEmpty ? tache.heure : heure;
      final categorieFinale = categorie.isEmpty ? tache.categorie : categorie;
      final prioriteFinale = prioriteTexte.isEmpty
          ? tache.priorite
          : _normaliserPriorite(prioriteTexte);
      final dateFinale = _dateDepuisTexte(dateTexte, tache.date);
      final etatFinal = contientTerminee ? terminee : tache.terminee;

      await _serviceTache.mettreAJourTache(
        idTache: tache.id,
        titre: titreFinal,
        heure: heureFinale,
        date: dateFinale,
        categorie: categorieFinale,
        terminee: etatFinal,
        priorite: prioriteFinale,
      );

      final nouveauContexte = ModeleContexte(
        type: "tache",
        id: tache.id,
        titre: titreFinal,
        contenu: "$categorieFinale - $prioriteFinale - $heureFinale",
        source: "chat",
      );
      await _enregistrerContexte(conversationRef, nouveauContexte);

      if (contientTerminee && etatFinal) {
        return _ResultatExecution(
          "La tâche a été marquée comme terminée.",
          nouveauContexte,
        );
      }
      if (contientTerminee && !etatFinal) {
        return _ResultatExecution(
          "La tâche a été marquée comme non terminée.",
          nouveauContexte,
        );
      }
      return _ResultatExecution(
        "La tâche a été modifiée avec succès.",
        nouveauContexte,
      );
    }

    if (action == "DELETE_TASK") {
      final titre = _valeur(resultat, "titre", "");
      var tache = titre.isNotEmpty
          ? await _serviceTache.trouverTacheParTitre(titre)
          : null;

      if (tache == null &&
          contexte != null &&
          contexte.type == "tache" &&
          contexte.id.isNotEmpty) {
        final toutes = await _serviceTache.recupererToutesLesTaches();
        try {
          tache = toutes.firstWhere((e) => e.id == contexte.id);
        } catch (_) {
          tache = null;
        }
      }

      if (tache == null)
        return _ResultatExecution(
          "Je n'ai pas trouvé la tâche à supprimer.",
          contexte,
        );

      await _serviceTache.supprimerTache(tache.id);
      await _enregistrerContexte(conversationRef, null);
      return _ResultatExecution("La tâche a été supprimée avec succès.", null);
    }

    if (action == "SEARCH_TASK") {
      final titre = _valeur(resultat, "titre", "");
      final taches = await _serviceTache.rechercherTachesParTitre(titre);

      if (taches.isEmpty)
        return _ResultatExecution(
          "Je n'ai trouvé aucune tâche avec ce titre.",
          contexte,
        );

      if (taches.length == 1) {
        final tache = taches.first;
        final nouveauContexte = ModeleContexte(
          type: "tache",
          id: tache.id,
          titre: tache.titre,
          contenu: "${tache.categorie} - ${tache.priorite} - ${tache.heure}",
          source: "chat",
        );
        await _enregistrerContexte(conversationRef, nouveauContexte);
        return _ResultatExecution(
          'J\'ai trouvé la tâche "${tache.titre}" - ${tache.categorie}, priorité ${tache.priorite}, à ${tache.heure}.',
          nouveauContexte,
        );
      }

      final titres = taches.map((t) => t.titre).join(", ");
      return _ResultatExecution(
        "J'ai trouvé plusieurs tâches : $titres",
        contexte,
      );
    }

    if (action == "GET_TASKS_BY_DATE") {
      final dateTexte = _valeur(resultat, "date", "");
      final dateDemandee = _dateDepuisTexte(dateTexte, DateTime.now());
      final taches = await _serviceTache.recupererTachesParDateTriees(
        dateDemandee,
      );

      if (taches.isEmpty) {
        return _ResultatExecution(
          "Tu n’as aucune tâche pour le ${_formaterDate(dateDemandee)}.",
          contexte,
        );
      }

      final lignes = taches
          .map((t) {
            final etat = t.terminee ? "terminée" : "à faire";
            final heure = t.heure == "--:--" ? "sans heure" : t.heure;
            return "${_iconePriorite(t.priorite)} ${t.titre} - ${t.categorie} - $heure - $etat";
          })
          .join("\n");

      return _ResultatExecution(
        "Voici tes tâches du ${_formaterDate(dateDemandee)}, classées par priorité :\n$lignes",
        contexte,
      );
    }

    if (action == "CREATE_ALARME") {
      final dateTexte = _valeur(resultat, "date", "");
      final titre = _valeur(resultat, "titre", "Alarme");
      final heureTexte = _valeur(resultat, "heure", "--:--");
      final jours = _valeur(
        resultat,
        "jours",
        dateTexte.isEmpty ? "quotidien" : "unique",
      );

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
          date: dateTexte.isEmpty ? null : dateTexte,
        ),
      );

      return _ResultatExecution(
        "L’alarme a été ajoutée avec succès.",
        contexte,
      );
    }

    if (action == "UPDATE_ALARME") {
      final titre = _valeur(resultat, "titre", "");
      final nouveauTitre = _valeur(resultat, "nouveau_titre", "");
      final heureTexte = _valeur(resultat, "heure", "");
      final jours = _valeur(resultat, "jours", "");
      final dateTexte = _valeur(resultat, "date", "");

      final alarme = await _serviceAlarme.trouverAlarmeParTitre(titre);
      if (alarme == null)
        return _ResultatExecution(
          "Je n’ai pas trouvé l’alarme à modifier.",
          contexte,
        );

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
          date: dateTexte.isEmpty ? alarme.date : dateTexte,
        ),
      );

      return _ResultatExecution(
        "L’alarme a été modifiée avec succès.",
        contexte,
      );
    }

    if (action == "DELETE_ALARME") {
      final titre = _valeur(resultat, "titre", "");
      final alarme = await _serviceAlarme.trouverAlarmeParTitre(titre);

      if (alarme != null && alarme.id != null) {
        await _serviceAlarme.supprimerAlarme(alarme.id!);
        return _ResultatExecution(
          "L’alarme a été supprimée avec succès.",
          contexte,
        );
      }
      return _ResultatExecution(
        "Je n’ai pas trouvé l’alarme à supprimer.",
        contexte,
      );
    }

    if (action == "TOGGLE_ALARME") {
      final titre = _valeur(resultat, "titre", "");
      final active = (resultat["active"] ?? true) == true;
      final alarme = await _serviceAlarme.trouverAlarmeParTitre(titre);

      if (alarme != null && alarme.id != null) {
        await _serviceAlarme.basculerActivation(alarme.id!, active);
        return _ResultatExecution(
          active
              ? "L’alarme a été activée avec succès."
              : "L’alarme a été désactivée avec succès.",
          contexte,
        );
      }
      return _ResultatExecution("Je n’ai pas trouvé l’alarme.", contexte);
    }

    if (action == "RECOMMENDATION") {
      final taches = await _serviceTache.recupererToutesLesTaches();
      final nonTerminees = taches.where((t) => !t.terminee).toList();

      if (nonTerminees.isEmpty) {
        return _ResultatExecution(
          "Bravo, tu n’as pas de tâches en attente. Tu peux ajouter une nouvelle tâche ou réviser tes notes.",
          contexte,
        );
      }

      final triees = _serviceTache.trierParPriorite(nonTerminees);
      triees.sort((a, b) {
        final comparaisonDate = a.date.compareTo(b.date);
        if (comparaisonDate != 0) return comparaisonDate;
        return _serviceTache.trierParPriorite([a, b]).first.id == a.id ? -1 : 1;
      });
      final prochaine = triees.first;
      return _ResultatExecution(
        "Je te conseille de commencer par : ${prochaine.titre} (${prochaine.categorie}, priorité ${prochaine.priorite}) à ${prochaine.heure}.",
        contexte,
      );
    }

    final reponse = await _gemini.envoyerMessageChat(
      texteOriginal,
      contexte: contexte,
    );
    return _ResultatExecution(reponse, contexte);
  }
}

class _ResultatExecution {
  final String message;
  final ModeleContexte? contexte;

  _ResultatExecution(this.message, this.contexte);
}
