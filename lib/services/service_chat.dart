import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ora/services/service_gemini.dart';
import 'service_note.dart';
import 'service_tache.dart';
import 'service_alarme.dart';
import 'service_meteo.dart';
import 'service_maps.dart';
import 'service_notification_locale.dart';
import 'package:ora/controlleurs/controleur_eau.dart';
import 'package:ora/controlleurs/controleur_sante.dart';
import 'package:ora/controlleurs/controleur_sport.dart';
import '../models/modele_contexte.dart';
import '../models/modele_alarme.dart';

class ServiceChat {
  final ServiceTache _serviceTache = ServiceTache();
  final ServiceGemini _gemini = ServiceGemini();
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ServiceNote _serviceNote = ServiceNote();
  final ServiceAlarme _serviceAlarme = ServiceAlarme();
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
      'CREATE_ALARME',
      'UPDATE_ALARME',
      'DELETE_ALARME',
      'TOGGLE_ALARME',
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
      'CREATE_ALARME',
      'UPDATE_ALARME',
      'DELETE_ALARME',
      'TOGGLE_ALARME',
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
    final historique = await _chargerHistoriqueMessages(conversationRef);
    final action = _valeur(resultat, "action", "CHAT").toUpperCase();
    if (action == "OPEN_MAP_ROUTE") {
      if (contexte == null || contexte.type != "trajet") {
        return _ResultatExecution(
          " Dis-moi d'abord ta destination (ex: je vais à Sousse)",
          contexte,
        );
      }
      return _ResultatExecution(
        "Clique pour voir le trajet vers ${contexte.id}",
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
      await _serviceNote.synchroniserVersFirebase();
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
          "J'ai compris le trajet vers $destination, mais je n'ai pas pu calculer la position ou la destination. Vérifie GPS et internet.",
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

      final messageNotification =
          "Météo à ${meteo.ville}: ${meteo.description}, ${meteo.temperature}°. Pars maintenant pour arriver à ${_formaterHeure(heureArrivee)}.";

      await ServiceNotificationLocale.instance.programmerNotificationTrajet(
        idTrajet:
            "${destination}_${heureArrivee.toIso8601String()}_${DateTime.now().millisecondsSinceEpoch}",
        destination: destination,
        dateSortie: heureSortie,
        message: messageNotification,
      );

      final texteReponse =
          "Trajet vers $destination préparé.\n"
          "📍 Distance estimée : $distanceKm km\n"
          "🕒 Temps trajet estimé : $tempsTrajet min\n"
          "🌦️ Météo à ${meteo.ville} : ${meteo.description}, ${meteo.temperature}°\n"
          "⏱️ Marge météo : $margeMeteo min\n"
          "🚶 Sors vers ${_formaterHeure(heureSortie)} pour arriver à ${_formaterHeure(heureArrivee)}.";
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
          userId: '',
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
          userId: alarme.userId,
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
        "💧 Hydratation mise à jour : ${maj.verres}/${maj.objectif} verres.",
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
        "⚖️ Poids mis à jour : ${maj.poids.toStringAsFixed(1)} kg.",
        contexte,
      );
    }

    if (action == "SET_MOOD") {
      final sante = await _controleurSante.chargerAujourdhui();
      final humeur = _valeur(resultat, "humeur", "Normal");

      final maj = await _controleurSante.modifierHumeur(sante, humeur);

      return _ResultatExecution(
        "😊 Humeur enregistrée : ${maj.humeur}.",
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
        "😴 Sommeil enregistré : ${maj.heuresSommeil} h.",
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
        "🏃 Sport mis à jour : ${maj.minutes}/${maj.objectifMinutes} min.",
        contexte,
      );
    }

    if (action == "SET_HEALTH_STATE") {
      final sport = await _controleurSport.chargerAujourdhui();
      final etat = _valeur(resultat, "etat_sante", "Bonne santé");

      final maj = await _controleurSport.modifierEtatSante(sport, etat);

      return _ResultatExecution(
        "🩺 État de santé mis à jour : ${maj.etatSante}.",
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
    conseil += "💧 Il te reste $verresRestants verre(s) d’eau à boire.\n";
  } else {
    conseil += "💧 Objectif hydratation atteint.\n";
  }

  if (sportRestant > 0) {
    conseil += "🏃 Il te reste $sportRestant min de sport pour atteindre ton objectif.\n";
  } else {
    conseil += "🏃 Objectif sport atteint.\n";
  }

  if (sante.heuresSommeil < 6) {
    conseil += "😴 Ton sommeil est faible, essaie de te reposer plus.\n";
  } else if (sante.heuresSommeil >= 7) {
    conseil += "😴 Sommeil satisfaisant aujourd’hui.\n";
  }

  if (sante.humeur.toLowerCase().contains("triste") ||
      sante.humeur.toLowerCase().contains("stress")) {
    conseil += "😊 Essaie de faire une petite pause ou une activité relaxante.\n";
  }

  return _ResultatExecution(
    "📊 Bilan du jour :\n"
    "💧 Hydratation : ${eau.verres}/${eau.objectif} verres\n"
    "🏃 Sport : ${sport.minutes}/${sport.objectifMinutes} min\n"
    "⚖️ Poids : ${sante.poids.toStringAsFixed(1)} kg\n"
    "😊 Humeur : ${sante.humeur}\n"
    "😴 Sommeil : ${sante.heuresSommeil} h\n"
    "🩺 État santé : ${sport.etatSante}\n\n"
    "✅ Conseil ORA :\n$conseil",
    contexte,
  );
}
    if (action == "RECOMMENDATION") {
      final maintenant = DateTime.now();
      final taches = await _serviceTache.recupererToutesLesTaches();
      final nonTerminees = taches.where((t) => !t.terminee).toList();

      if (nonTerminees.isEmpty) {
        return _ResultatExecution(
          "✅ Bravo, tu n’as aucune tâche en attente. Tu peux ajouter une petite tâche utile ou réviser une note importante.",
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
      final nombreHaute = nonTerminees
          .where((t) => t.priorite.toLowerCase().trim() == 'haute')
          .length;
      final heure = prochaine.heure == "--:--"
          ? "sans heure précise"
          : "à ${prochaine.heure}";
      final dateTexte = _formaterDate(prochaine.date);

      var conseil =
          "🎯 Je te conseille de commencer par : ${prochaine.titre}\n"
          "${_iconePriorite(prochaine.priorite)} Priorité : ${prochaine.priorite}\n"
          "📂 Catégorie : ${prochaine.categorie}\n"
          "📅 Date : $dateTexte, $heure";

      if (nombreHaute >= 2) {
        conseil +=
            "\n\n⚠️ Tu as $nombreHaute tâches de priorité haute. Commence par une seule, puis passe à la suivante.";
      } else if (aujourdhui.length >= 3) {
        conseil +=
            "\n\n⏳ Tu as plusieurs tâches aujourd’hui. Essaie de les faire par petites sessions.";
      } else {
        conseil += "\n\n✅ C’est le meilleur choix pour avancer sans stress.";
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
