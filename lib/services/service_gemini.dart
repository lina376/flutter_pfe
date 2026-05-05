import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ora/models/modele_contexte.dart';

class ServiceGemini {
  static const String apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyBTI2GeRbIFLrcjtX6lkwKAXaXyyecRLYA',
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
Tu es ORA, assistant intelligent d'une application Flutter de notes, tâches et alarmes.

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
CREATE_ALARME, UPDATE_ALARME, DELETE_ALARME, TOGGLE_ALARME,
CREATE_TRIP_REMINDER, RECOMMENDATION, OPEN_MAP_ROUTE, CHAT.

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

Important pour chercher les tâches :
- Si l'utilisateur dit "tâches d'aujourd'hui", "tasks today", "jibli les taches d'aujourd'hui", retourne GET_TASKS_BY_DATE avec la date actuelle.
- Si l'utilisateur dit "tâches de demain", retourne GET_TASKS_BY_DATE avec la date de demain.
- Si l'utilisateur demande de les classer, trier ou afficher par priorité, mets "tri":"priorite".

Important pour terminer une tâche :
- Si l'utilisateur dit "j'ai terminé", "terminer", "كمّلت", "kammalt", retourne UPDATE_TASK avec "terminee": true.
- Si l'utilisateur dit "pas terminée", retourne UPDATE_TASK avec "terminee": false.

Supprimer tâche :
{"action":"DELETE_TASK","titre":"..."}

Chercher tâche :
{"action":"SEARCH_TASK","titre":"..."}

Créer alarme :
{"action":"CREATE_ALARME","titre":"...","heure":"HH:mm","date":"YYYY-MM-DD","jours":"unique"}
ou
{"action":"CREATE_ALARME","titre":"...","heure":"HH:mm","jours":"quotidien"}

Modifier alarme :
{"action":"UPDATE_ALARME","titre":"...","nouveau_titre":"...","heure":"HH:mm","date":"YYYY-MM-DD","jours":"unique"}

Supprimer alarme :
{"action":"DELETE_ALARME","titre":"..."}

Activer/désactiver alarme :
{"action":"TOGGLE_ALARME","titre":"...","active":true}

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
