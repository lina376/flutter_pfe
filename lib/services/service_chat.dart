import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ora/services/service_gemini.dart';
import 'service_note.dart';
import 'service_tache.dart';
import 'service_meteo.dart';
import 'service_maps.dart';
import 'service_notification_locale.dart';
import 'package:ora/controlleurs/controleur_eau.dart';
import 'package:ora/controlleurs/controleur_sante.dart';
import 'package:ora/controlleurs/controleur_sport.dart';
import '../models/modele_contexte.dart';
class ServiceChat {
  final ServiceTache _serviceTache = ServiceTache();
  final ServiceGemini _gemini = ServiceGemini();
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ServiceNote _serviceNote = ServiceNote();
  final ServiceMeteo _serviceMeteo = ServiceMeteo();
  final ServiceMaps _serviceMaps = ServiceMaps();
  final ControleurEau _controleurEau = ControleurEau();
final ControleurSante _controleurSante = ControleurSante();
final ControleurSport _controleurSport = ControleurSport();

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

  String _formaterHeure(DateTime date) {
    String deux(int v) => v.toString().padLeft(2, '0');
    return '${deux(date.hour)}:${deux(date.minute)}';
  }

  DateTime _dateAvecHeure(DateTime date, String heureTexte) {
    final heure = _extraireHeure(heureTexte, 8);
    final minute = _extraireMinute(heureTexte, 0);
    return DateTime(date.year, date.month, date.day, heure, minute);
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

  Future<List<Map<String, dynamic>>> _chargerHistoriqueMessages(
    DocumentReference<Map<String, dynamic>> conversationRef,
  ) async {
    final snapshot = await conversationRef
        .collection('messages')
        .orderBy('date', descending: true)
        .limit(10)
        .get();

    return snapshot.docs.reversed.map((doc) {
      final data = doc.data();
      return {
        'sender': (data['sender'] ?? '').toString(),
        'texte': (data['texte'] ?? '').toString(),
      };
    }).toList();
  }

  bool _commandeValide(Map<String, dynamic> commande) {
    final action = _valeur(commande, 'action', 'CHAT').toUpperCase();

    final actionsAutorisees = {
      'CREATE_NOTE',
      'UPDATE_NOTE',
      'DELETE_NOTE',
      'SEARCH_NOTE',
      'CREATE_TASK',
      'UPDATE_TASK',
      'DELETE_TASK',
      'SEARCH_TASK',
      'GET_TASKS_BY_DATE',
      'CREATE_TRIP_REMINDER',
      'RECOMMENDATION',
      'OPEN_MAP_ROUTE',
      'ADD_WATER',
'REMOVE_WATER',
'SET_WATER',
'SET_WEIGHT',
'INCREASE_WEIGHT',
'DECREASE_WEIGHT',
'SET_MOOD',
'SET_SLEEP',
'ADD_SPORT',
'REMOVE_SPORT',
'SET_SPORT',
'SET_HEALTH_STATE',
'GET_DAILY_SUMMARY',
      'CHAT',
    };

    if (!actionsAutorisees.contains(action)) return false;

    final titreObligatoire = {
      'CREATE_NOTE',
      'UPDATE_NOTE',
      'DELETE_NOTE',
      'SEARCH_NOTE',
      'CREATE_TASK',
      'UPDATE_TASK',
      'DELETE_TASK',
      'SEARCH_TASK',
    };

    if (titreObligatoire.contains(action)) {
      final titre = _valeur(commande, 'titre', '');
      if (titre.isEmpty && action.startsWith('CREATE')) return false;
    }

    if (action == 'CREATE_TRIP_REMINDER') {
      return _valeur(commande, 'destination', '').isNotEmpty;
    }
  
    return true;
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
    final historique = await _chargerHistoriqueMessages(conversationRef);

    List<Map<String, dynamic>> commandes;
    try {
      commandes = await _gemini.analyserCommandes(
        texte,
        contexte: contexte,
        historique: historique,
      );
      commandes = commandes.where(_commandeValide).toList();
      if (commandes.isEmpty)
        commandes = [
          {"action": "CHAT"},
        ];
    } catch (e) {
      commandes = [
        {"action": "RECOMMENDATION"},
      ];
    }

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
      'texte': reponseOra.isEmpty ? 'chat_pas_compris'.tr() : reponseOra,
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
    final historique = await _chargerHistoriqueMessages(conversationRef);
    final action = _valeur(resultat, "action", "CHAT").toUpperCase();
    if (action == "OPEN_MAP_ROUTE") {
      if (contexte == null || contexte.type != "trajet") {
        return _ResultatExecution(
          'chat_destination_dabord'.tr(),
          contexte,
        );
      }
      return _ResultatExecution(
        'chat_voir_trajet'.tr(args: [contexte.id]),
        contexte,
      );
    }
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
        'message_note_ajoutee'.tr(),
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
          'message_note_actuelle_modifiee'.tr(),
          nouveauContexte,
        );
      }

      final note = await _serviceNote.trouverNoteParTitre(titre);
      if (note == null)
        return _ResultatExecution(
          'message_note_introuvable_modification'.tr(),
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
        'message_note_modifiee'.tr(),
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
          'message_note_actuelle_supprimee'.tr(),
          null,
        );
      }

      final note = await _serviceNote.trouverNoteParTitre(titre);
      if (note == null)
        return _ResultatExecution(
          'message_note_introuvable_suppression'.tr(),
          contexte,
        );

      await _serviceNote.supprimerNote(note.id);
      await _serviceNote.synchroniserVersFirebase();
      return _ResultatExecution(
        'message_note_supprimee'.tr(),
        contexte,
      );
    }

    if (action == "SEARCH_NOTE") {
      final titre = _valeur(resultat, "titre", "");
      final notes = await _serviceNote.rechercherNotesParTitre(titre);

      if (notes.isEmpty)
        return _ResultatExecution(
          'message_aucune_note'.tr(),
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
          'message_note_trouvee' .tr(args: [note.titre, note.contenu]),
          nouveauContexte,
        );
      }

      final titres = notes.map((n) => n.titre).join(", ");
      return _ResultatExecution(
        'message_plusieurs_notes'.tr(args: [titres]),
        contexte,
      );
    }

    if (action == "CREATE_TASK") {
     String titre = _valeur(resultat, "titre", "Nouvelle tâche").trim();

if (titre.isEmpty ||
    RegExp(r'^r+$', caseSensitive: false).hasMatch(titre)) {
  titre = "Nouvelle tâche";
}
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
        'chat_tache_ajoutee'.tr(args: [priorite]),
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
          'message_tache_introuvable_modification'.tr(),
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
          'message_tache_terminee'.tr(),
          nouveauContexte,
        );
      }
      if (contientTerminee && !etatFinal) {
        return _ResultatExecution(
          'message_tache_non_terminee'.tr(),
          nouveauContexte,
        );
      }
      return _ResultatExecution(
        'message_tache_modifiee'.tr(),
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
          'message_tache_introuvable_suppression'.tr(),
          contexte,
        );

      await _serviceTache.supprimerTache(tache.id);
      await _enregistrerContexte(conversationRef, null);
      return _ResultatExecution('message_tache_supprimee'.tr(), null);
    }

    if (action == "SEARCH_TASK") {
      final titre = _valeur(resultat, "titre", "");
      final taches = await _serviceTache.rechercherTachesParTitre(titre);

      if (taches.isEmpty)
        return _ResultatExecution(
          'message_aucune_tache'.tr(),
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
         'message_tache_trouvee'.tr( args: [ tache.titre, tache.categorie, tache.priorite, tache.heure, ], ),
          nouveauContexte,
        );
      }

      final titres = taches.map((t) => t.titre).join(", ");
      return _ResultatExecution(
        'message_plusieurs_taches'.tr(args: [titres]),
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
          'message_aucune_tache_date'.tr(args: [_formaterDate(dateDemandee)]),
          contexte,
        );
      }

      final lignes = taches
          .map((t) {
            final etat = t.terminee
    ? 'etat_tache_terminee'.tr()
    : 'etat_tache_a_faire'.tr();

final heure = t.heure == "--:--"
    ? 'heure_sans_heure'.tr()
    : t.heure;
            return "${_iconePriorite(t.priorite)} ${t.titre} - ${t.categorie} - $heure - $etat";
          })
          .join("\n");

      return _ResultatExecution(
        'message_taches_date' .tr(args: [_formaterDate(dateDemandee), lignes]),
        contexte,
      );
    }

    if (action == "CREATE_TRIP_REMINDER") {
      final destination = _valeur(resultat, "destination", "Sousse");
      final dateTexte = _valeur(resultat, "date", "");
      final heureArriveeTexte = _valeur(resultat, "heure_arrivee", "--:--");
      final dateDemandee = _dateDepuisTexte(dateTexte, DateTime.now());
      final heureArrivee = _dateAvecHeure(dateDemandee, heureArriveeTexte);

      final positionActuelle = await _serviceMaps.obtenirPositionActuelle();
      final destinationMaps = await _serviceMaps.obtenirDestinationDepuisNom(
        destination,
      );
      final meteo = await _serviceMeteo.obtenirMeteoPourVille(destination);
      final margeMeteo = _serviceMeteo.margeTrajetSelonMeteo(meteo);

      if (positionActuelle == null || destinationMaps == null) {
        return _ResultatExecution(
          'message_trajet_compris'.tr(args: [destination]),
          contexte,
        );
      }

      final distanceMetres = _serviceMaps.calculerDistance(
        positionActuelle.latitude,
        positionActuelle.longitude,
        destinationMaps.latitude,
        destinationMaps.longitude,
      );
      final distanceKm = (distanceMetres / 1000).toStringAsFixed(1);
      final tempsTrajet = _serviceMaps.calculerTempsTrajet(distanceMetres);
      final heureSortie = heureArrivee.subtract(
        Duration(minutes: tempsTrajet + margeMeteo),
      );

      final messageNotification = 'message_notification_trajet'.tr( args: [ meteo.ville, meteo.description, meteo.temperature.toString(), _formaterHeure(heureArrivee), ], );
      await ServiceNotificationLocale.instance.programmerNotificationTrajet(
        idTrajet:
            "${destination}_${heureArrivee.toIso8601String()}_${DateTime.now().millisecondsSinceEpoch}",
        destination: destination,
        dateSortie: heureSortie,
        message: messageNotification,
      );

      final texteReponse = 'message_trajet_prepare'.tr( args: [ destination, distanceKm, tempsTrajet.toString(), meteo.ville, meteo.description, meteo.temperature.toString(), margeMeteo.toString(), _formaterHeure(heureSortie), _formaterHeure(heureArrivee), ], );
      final nouveauContexte = ModeleContexte(
        type: "trajet",
        id: destination,
        titre: "Trajet vers $destination",
        contenu:
            "destination=$destination;"
            "lat=${destinationMaps.latitude};"
            "lng=${destinationMaps.longitude};"
            "distance=$distanceKm;"
            "temps=$tempsTrajet;"
            "sortie=${_formaterHeure(heureSortie)};",
        source: "chat",
      );

      await _enregistrerContexte(conversationRef, nouveauContexte);

      return _ResultatExecution(texteReponse, nouveauContexte);
    }
    if (action == "ADD_WATER" ||
        action == "REMOVE_WATER" ||
        action == "SET_WATER") {
      final eau = await _controleurEau.chargerAujourdhui();

      final valeur = int.tryParse(
            "${resultat['quantite'] ?? resultat['verres'] ?? 1}",
          ) ??
          1;

      var maj = eau;

      if (action == "ADD_WATER") {
        for (int i = 0; i < valeur; i++) {
          maj = await _controleurEau.ajouterVerre(maj);
        }
        
      }

      if (action == "REMOVE_WATER") {
        for (int i = 0; i < valeur; i++) {
          maj = await _controleurEau.retirerVerre(maj);
        }
      }

      if (action == "SET_WATER") {
  maj = eau;

  while (maj.verres < valeur) {
    maj = await _controleurEau.ajouterVerre(maj);
  }

  while (maj.verres > valeur) {
    maj = await _controleurEau.retirerVerre(maj);
  }
}

      return _ResultatExecution(
        'message_hydratation' .tr(args: [maj.verres.toString(), maj.objectif.toString()]),
        contexte,
      );
    }

    if (action == "SET_WEIGHT" ||
        action == "INCREASE_WEIGHT" ||
        action == "DECREASE_WEIGHT") {
      final sante = await _controleurSante.chargerAujourdhui();

      final valeur = double.tryParse(
            "${resultat['poids'] ?? resultat['valeur'] ?? sante.poids}",
          ) ??
          sante.poids;

      double nouveauPoids = sante.poids;

      if (action == "SET_WEIGHT") nouveauPoids = valeur;
      if (action == "INCREASE_WEIGHT") nouveauPoids += valeur;
      if (action == "DECREASE_WEIGHT") nouveauPoids -= valeur;

      if (nouveauPoids < 20) nouveauPoids = 20;

      final maj = await _controleurSante.modifierPoids(sante, nouveauPoids);

      return _ResultatExecution(
        'message_poids' .tr(args: [maj.poids.toStringAsFixed(1)]),
        contexte,
      );
    }

    if (action == "SET_MOOD") {
      final sante = await _controleurSante.chargerAujourdhui();
      final humeur = _valeur(resultat, "humeur", "Normal");

      final maj = await _controleurSante.modifierHumeur(sante, humeur);

      return _ResultatExecution(
        'message_humeur'.tr(args: [maj.humeur]),
        contexte,
      );
    }

    if (action == "SET_SLEEP") {
      final sante = await _controleurSante.chargerAujourdhui();

      final heures = double.tryParse(
            "${resultat['heures'] ?? resultat['sommeil'] ?? sante.heuresSommeil}",
          ) ??
          sante.heuresSommeil;

      final maj = await _controleurSante.modifierSommeil(sante, heures);

      return _ResultatExecution(
        'message_sommeil' .tr(args: [maj.heuresSommeil.toString()]),
        contexte,
      );
    }

    if (action == "ADD_SPORT" ||
        action == "REMOVE_SPORT" ||
        action == "SET_SPORT") {
      final sport = await _controleurSport.chargerAujourdhui();

      final valeur = int.tryParse("${resultat['minutes'] ?? 0}") ?? 0;

      int nouveauTotal = sport.minutes;

      if (action == "ADD_SPORT") nouveauTotal += valeur;
      if (action == "REMOVE_SPORT") nouveauTotal -= valeur;
      if (action == "SET_SPORT") nouveauTotal = valeur;

      if (nouveauTotal < 0) nouveauTotal = 0;

      final maj = await _controleurSport.modifierMinutes(sport, nouveauTotal);

      return _ResultatExecution(
        'message_sport' .tr(args: [maj.minutes.toString(), maj.objectifMinutes.toString()]),
        contexte,
      );
    }

    if (action == "SET_HEALTH_STATE") {
      final sport = await _controleurSport.chargerAujourdhui();
      final etat = _valeur(resultat, "etat_sante", "Bonne santé");

      final maj = await _controleurSport.modifierEtatSante(sport, etat);

      return _ResultatExecution(
        'message_etat_sante'.tr(args: [maj.etatSante]),
        contexte,
      );
    }
    if (action == "GET_DAILY_SUMMARY") {
  final eau = await _controleurEau.chargerAujourdhui();
  final sante = await _controleurSante.chargerAujourdhui();
  final sport = await _controleurSport.chargerAujourdhui();

  final verresRestants = eau.objectif - eau.verres;
  final sportRestant = sport.objectifMinutes - sport.minutes;

  String conseil = "";

if (verresRestants > 0) {
  conseil += 'conseil_eau_reste'
      .tr(args: [verresRestants.toString()]);
} else {
  conseil += 'conseil_eau_atteint'.tr();
}

if (sportRestant > 0) {
  conseil += 'conseil_sport_reste'
      .tr(args: [sportRestant.toString()]);
} else {
  conseil += 'conseil_sport_atteint'.tr();
}

if (sante.heuresSommeil < 6) {
  conseil += 'conseil_sommeil_faible'.tr();
} else if (sante.heuresSommeil >= 7) {
  conseil += 'conseil_sommeil_bon'.tr();
}

if (sante.humeur.toLowerCase().contains("triste") ||
    sante.humeur.toLowerCase().contains("stress")) {
  conseil += 'conseil_humeur_pause'.tr();
}

return _ResultatExecution( 'message_bilan_complet'.tr( args: [ eau.verres.toString(), eau.objectif.toString(), sport.minutes.toString(), sport.objectifMinutes.toString(), sante.poids.toStringAsFixed(1), sante.humeur, sante.heuresSommeil.toString(), sport.etatSante, conseil, ], ), contexte, );
}
    if (action == "RECOMMENDATION") {
      final maintenant = DateTime.now();
      final taches = await _serviceTache.recupererToutesLesTaches();
      final nonTerminees = taches.where((t) => !t.terminee).toList();

      if (nonTerminees.isEmpty) {
        return _ResultatExecution(
          'message_aucune_tache_attente'.tr(),
          contexte,
        );
      }

      final aujourdhui = nonTerminees.where((t) {
        return t.date.year == maintenant.year &&
            t.date.month == maintenant.month &&
            t.date.day == maintenant.day;
      }).toList();

      final base = aujourdhui.isNotEmpty ? aujourdhui : nonTerminees;
      final triees = _serviceTache.trierParPriorite(base);
      triees.sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return _serviceTache.trierParPriorite([a, b]).first.id == a.id ? -1 : 1;
      });

      final prochaine = triees.first;
      final nombreHaute = aujourdhui
    .where((t) => t.priorite.toLowerCase().trim() == 'haute')
    .length;
      final heure = prochaine.heure == "--:--"
    ? 'heure_sans_precision'.tr()
    : 'heure_a'.tr(args: [prochaine.heure]);
      final dateTexte = _formaterDate(prochaine.date);

      var conseil =
    "${'message_conseil_commencer'.tr(args: [prochaine.titre])}\n"
    "${_iconePriorite(prochaine.priorite)} ${'message_priorite'.tr(args: ['', prochaine.priorite])}\n"
    "${'message_categorie'.tr(args: [prochaine.categorie])}\n"
    "${'message_date_heure'.tr(args: [dateTexte, heure])}";

      if (nombreHaute >= 2) {
        conseil +=
    "\n\n${'message_plusieurs_taches_haute'.tr(args: [nombreHaute.toString()])}";
      } else if (aujourdhui.length >= 3) {
        conseil +=
    "\n\n${'message_plusieurs_taches_aujourdhui'.tr()}";
      } else {
        conseil +=
    "\n\n${'message_meilleur_choix'.tr()}";
      }

      return _ResultatExecution(conseil, contexte);
    }

    final reponse = await _gemini.envoyerMessageChat(
      texteOriginal,
      contexte: contexte,
      historique: historique,
    );
    return _ResultatExecution(reponse, contexte);
  }
}

class _ResultatExecution {
  final String message;
  final ModeleContexte? contexte;

  _ResultatExecution(this.message, this.contexte);
}
