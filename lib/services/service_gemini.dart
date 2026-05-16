import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ora/models/modele_contexte.dart';

class ServiceGemini {
  static const String apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyDdNJocTm6MgjnzLXeqzNq5vpqtje5JJbI',
  );

  Uri get _url => Uri.parse(
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
  );

  String _historiqueTexte(List<Map<String, dynamic>> historique) {
    if (historique.isEmpty) return "Aucun historique";
    return historique
        .map((m) => "${m['sender'] ?? 'user'}: ${m['texte'] ?? ''}")
        .join("\n");
  }

  String _contexteTexte(ModeleContexte? contexte) {
    if (contexte == null || contexte.estVide) return "Aucun contexte actif";
    return """
Type: ${contexte.type}
Id: ${contexte.id}
Titre: ${contexte.titre}
Contenu: ${contexte.contenu}
Source: ${contexte.source}
""";
  }

  String _extraireJson(String texte) {
    var nettoye = texte.replaceAll("```json", "").replaceAll("```", "").trim();

    final debutObjet = nettoye.indexOf('{');
    final debutListe = nettoye.indexOf('[');

    if (debutObjet == -1 && debutListe == -1) return nettoye;

    final commenceParListe =
        debutListe != -1 && (debutObjet == -1 || debutListe < debutObjet);

    if (commenceParListe) {
      final fin = nettoye.lastIndexOf(']');
      if (fin != -1) return nettoye.substring(debutListe, fin + 1);
    } else {
      final fin = nettoye.lastIndexOf('}');
      if (fin != -1) return nettoye.substring(debutObjet, fin + 1);
    }

    return nettoye;
  }

  List<Map<String, dynamic>> _normaliserResultat(dynamic resultat) {
    if (resultat is List) {
      return resultat
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (resultat is Map) {
      return [Map<String, dynamic>.from(resultat)];
    }

    return [
      {"action": "CHAT"},
    ];
  }

  Future<List<Map<String, dynamic>>> analyserCommandes(
    String message, {
    ModeleContexte? contexte,
    List<Map<String, dynamic>> historique = const [],
  }) async {
    if (apiKey.trim().isEmpty || apiKey == "REMPLACE_PAR_TA_CLE_GEMINI") {
      return [
        {"action": "CHAT"},
      ];
    }

    try {
      final prompt =
          """
Tu es ORA, assistant intelligent d'une application Flutter de notes, tâches.

Date actuelle exacte : ${DateTime.now().toIso8601String()}
Contexte actif :
${_contexteTexte(contexte)}

Historique des 5 derniers échanges :
${_historiqueTexte(historique)}

Ta mission : transformer le message utilisateur en JSON valide uniquement.
Ne réponds jamais avec une explication dans cette fonction.

Actions possibles :
CREATE_NOTE, UPDATE_NOTE, DELETE_NOTE, SEARCH_NOTE,
CREATE_TASK, UPDATE_TASK, DELETE_TASK, SEARCH_TASK, GET_TASKS_BY_DATE,
CREATE_TRIP_REMINDER, RECOMMENDATION, OPEN_MAP_ROUTE,ADD_WATER,REMOVE_WATER,SET_WATER,SET_WEIGHT,
INCREASE_WEIGHT,DECREASE_WEIGHT,SET_MOOD,SET_SLEEP,ADD_SPORT,
REMOVE_SPORT,SET_SPORT,SET_HEALTH_STATE,GET_DAILY_SUMMARY,CHAT.

Règles générales :
- Retourne seulement un objet JSON ou une liste JSON.
- Si le message contient plusieurs actions, retourne une liste d'objets.
- Si l'utilisateur dit "cette note", "modifie-la", "supprime-la", utilise le contexte actif si disponible.
- Si l'utilisateur dit "cette tâche", "termine-la", utilise le contexte actif si disponible.
- Le mot tâche signifie toujours todo numérique.
- Si aucune heure n'est donnée, mets "--:--".
- Si aucune catégorie n'est donnée pour une tâche, mets "Autre".
- Si aucune priorité n'est donnée pour une tâche, mets "moyenne".
- Priorités autorisées : haute, moyenne, basse.
- Convertis les dates naturelles en YYYY-MM-DD selon la date actuelle.
- Convertis les heures en HH:mm.
Si l'utilisateur dit:
- montre moi le trajet
- ouvre la carte
Réponds toujours dans la langue actuelle de l'application.
→ retourne:
{ "action": "OPEN_MAP_ROUTE" }
Formats :

Créer note :
{"action":"CREATE_NOTE","titre":"...","contenu":"..."}

Modifier note :
{"action":"UPDATE_NOTE","titre":"...","nouveau_titre":"...","contenu":"..."}

Supprimer note :
{"action":"DELETE_NOTE","titre":"..."}

Chercher note :
{"action":"SEARCH_NOTE","titre":"..."}

Créer tâche :
{"action":"CREATE_TASK","titre":"...","date":"YYYY-MM-DD","heure":"HH:mm","categorie":"Études","priorite":"moyenne"}

Modifier tâche :
{"action":"UPDATE_TASK","titre":"...","nouveau_titre":"...","date":"YYYY-MM-DD","heure":"HH:mm","categorie":"...","priorite":"haute","terminee":true}

Afficher les tâches d'une date :
{"action":"GET_TASKS_BY_DATE","date":"YYYY-MM-DD","tri":"priorite"}
Bilan journalier :
Si l'utilisateur demande son bilan, résumé, état du jour, "chnoua na9sni lyoum",
"a3tini bilan", "bilan lyoum", retourne :

{"action":"GET_DAILY_SUMMARY"}
Actions santé / sport / hydratation autorisées :

ADD_WATER : ajouter un ou plusieurs verres d’eau.
Exemple utilisateur : "j’ai bu un verre d’eau"
Réponse JSON :
{"action":"ADD_WATER","quantite":1}

REMOVE_WATER : retirer un ou plusieurs verres d’eau.
Exemple utilisateur : "retire un verre d’eau"
Réponse JSON :
{"action":"REMOVE_WATER","quantite":1}

SET_WATER : définir le nombre total de verres d’eau de la journée.
Exemple utilisateur : "mets mon eau à 4 verres"
Réponse JSON :
{"action":"SET_WATER","verres":4}

SET_WEIGHT : définir le poids actuel.
Exemple utilisateur : "mon poids est 70.5 kg"
Réponse JSON :
{"action":"SET_WEIGHT","poids":70.5}

INCREASE_WEIGHT : augmenter le poids actuel.
Exemple utilisateur : "augmente mon poids de 1 kg"
Réponse JSON :
{"action":"INCREASE_WEIGHT","valeur":1}

DECREASE_WEIGHT : diminuer le poids actuel.
Exemple utilisateur : "diminue mon poids de 0.5 kg"
Réponse JSON :
{"action":"DECREASE_WEIGHT","valeur":0.5}

SET_MOOD : enregistrer l’humeur du jour.
Exemple utilisateur : "je suis heureux aujourd’hui"
Réponse JSON :
{"action":"SET_MOOD","humeur":"Heureux"}

SET_SLEEP : enregistrer le nombre d’heures de sommeil.
Exemple utilisateur : "j’ai dormi 7 heures"
Réponse JSON :
{"action":"SET_SLEEP","heures":7}

ADD_SPORT : ajouter des minutes de sport.
Exemple utilisateur : "j’ai fait 30 minutes de sport"
Réponse JSON :
{"action":"ADD_SPORT","minutes":30}

REMOVE_SPORT : retirer des minutes de sport.
Exemple utilisateur : "retire 10 minutes de sport"
Réponse JSON :
{"action":"REMOVE_SPORT","minutes":10}

SET_SPORT : définir le total des minutes de sport de la journée.
Exemple utilisateur : "mets mon sport à 40 minutes"
Réponse JSON :
{"action":"SET_SPORT","minutes":40}

SET_HEALTH_STATE : modifier l’état de santé.
Exemple utilisateur : "je suis malade aujourd’hui"
Réponse JSON :
{"action":"SET_HEALTH_STATE","etat_sante":"Malade"}
Important pour chercher les tâches :
- Si l'utilisateur dit "tâches d'aujourd'hui", "tasks today", "jibli les taches d'aujourd'hui", retourne GET_TASKS_BY_DATE avec la date actuelle.
- Si l'utilisateur dit "tâches de demain", retourne GET_TASKS_BY_DATE avec la date de demain.
- Si l'utilisateur demande de les classer, trier ou afficher par priorité, mets "tri":"priorite".

Important pour terminer une tâche :
- Si l'utilisateur dit "j'ai terminé", "terminer", "كمّلت", "kammalt", retourne UPDATE_TASK avec "terminee": true.
- Si l'utilisateur dit "pas terminée", retourne UPDATE_TASK avec "terminee": false.
Si le message de l’utilisateur contient une demande de modification
comme ajouter, retirer, diminuer, augmenter, corriger, mettre à jour,
changer ou définir, tu dois retourner l’action JSON correspondante.

Ne réponds jamais avec du texte normal pour ces actions.
Retourne uniquement un JSON valide.
Supprimer tâche :
{"action":"DELETE_TASK","titre":"..."}

Chercher tâche :
{"action":"SEARCH_TASK","titre":"..."}
Créer rappel trajet météo :
{"action":"CREATE_TRIP_REMINDER","destination":"Sousse","date":"YYYY-MM-DD","heure_arrivee":"HH:mm"}

Règles trajet :
- Si l'utilisateur dit "je vais à", "je pars à", "machya l", "نمشي", "عندي مشية" avec une ville et une heure, retourne CREATE_TRIP_REMINDER.
- destination = ville ou lieu mentionné.
- heure_arrivee = heure où l'utilisateur veut arriver.
- Convertis demain, aujourd'hui, vendredi... en YYYY-MM-DD.

Recommandation :
{"action":"RECOMMENDATION"}

Discussion normale :
{"action":"CHAT"}
final langue = context.locale.languageCode;

String instructionLangue = '';

if (langue == 'ar') {
  instructionLangue =
      'أجب باللغة العربية الفصحى فقط دون استعمال اللهجة.';
} else if (langue == 'fr') {
  instructionLangue =
      'Réponds uniquement en français.';
} else {
  instructionLangue =
      'Reply only in English.';
}
Message utilisateur :
$message
""";

      final response = await http
          .post(
            _url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": prompt},
                  ],
                },
              ],
              "generationConfig": {
                "temperature": 0.1,
                "responseMimeType": "application/json",
              },
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        return [
          {"action": "CHAT"},
        ];
      }

      final data = jsonDecode(response.body);
      final texte =
          data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "{}";
      final resultat = jsonDecode(_extraireJson(texte.toString()));
      return _normaliserResultat(resultat);
    } catch (e) {
      print("Erreur Gemini analyserCommandes: $e");
      return [
        {"action": "CHAT"},
      ];
    }
  }

  Future<Map<String, dynamic>> analyserCommande(
    String message, {
    ModeleContexte? contexte,
    List<Map<String, dynamic>> historique = const [],
  }) async {
    final commandes = await analyserCommandes(
      message,
      contexte: contexte,
      historique: historique,
    );
    return commandes.isEmpty ? {"action": "CHAT"} : commandes.first;
  }

  String messageErreurOra() {
    final messages = [
      "Je n'ai pas bien compris cette demande.",
      "ORA n'arrive pas à traiter ça pour le moment.",
      "Cette action n'est pas encore supportée par ORA.",
      "Peux-tu reformuler ta demande autrement ?",
      "ORA n'est pas connectée à Internet pour le moment.",
    ];
    messages.shuffle();
    return messages.first;
  }

  Future<String> envoyerMessageChat(
    String message, {
    ModeleContexte? contexte,
    List<Map<String, dynamic>> historique = const [],
  }) async {
    if (apiKey.trim().isEmpty || apiKey == "REMPLACE_PAR_TA_CLE_GEMINI") {
      return "ORA n'est pas encore configurée correctement.";
    }

    try {
      final prompt =
          """
Tu es ORA, assistant intelligent d'une application mobile.
Réponds brièvement, clairement et en français simple/Tunisien si l'utilisateur écrit en Tunisien.
Contexte actif : ${_contexteTexte(contexte)}
Historique récent :
${_historiqueTexte(historique)}
Message : $message
""";

      final response = await http
          .post(
            _url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": prompt},
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ??
                "Je n'ai pas bien compris.")
            .toString()
            .trim();
      }

      return messageErreurOra();
    } catch (e) {
      return messageErreurOra();
    }
  }
}
