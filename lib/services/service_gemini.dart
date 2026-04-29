import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ora/models/modele_contexte.dart';

class ServiceGemini {
  final String apiKey = "AIzaSyCigPEKu6Ydj412nc-L4Ix4Mu6SA43WJhM";

  Future<Map<String, dynamic>> analyserCommande(
    String message, {
    ModeleContexte? contexte,
  }) async {
    print("Gemini: avant requête");
    try {
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
      );
      final texteContexte = contexte == null || contexte.estVide
          ? "Aucun contexte actif"
          : """
Type: ${contexte.type}
Id: ${contexte.id}
Titre: ${contexte.titre}
Contenu: ${contexte.contenu}
Source: ${contexte.source}
""";
      final prompt =
          """
Tu es ORA, assistant intelligent d'une application mobile de gestion de notes et de tâches.
Contexte actuel :
$texteContexte
Règles générales importantes :
- Le mot "tâche" signifie toujours une tâche numérique (todo) dans l'application.
- Ne jamais interpréter "tâche" comme une tâche physique.
- Si l'utilisateur dit "supprimer la tâche X", cela signifie supprimer une tâche dans l'application.
- Retourne uniquement du JSON valide.
- Ne mets aucun texte avant ou après le JSON.
- N'ajoute aucune explication.
- Si le message contient une seule action, retourne un seul objet JSON.
- Si le message contient plusieurs actions, retourne une liste JSON (tableau JSON) d'objets.
- Si une information manque pour exécuter une action, retourne quand même l'action avec les champs disponibles.
- N'invente jamais des informations non mentionnées par l'utilisateur, sauf pour les valeurs par défaut autorisées.
- Si aucune heure n'est donnée, mets "--:--".
- Si aucune catégorie n'est donnée, mets "Autre".

Actions possibles :
- CREATE_NOTE
- UPDATE_NOTE
- DELETE_NOTE
- SEARCH_NOTE
- CREATE_TASK
- UPDATE_TASK
- DELETE_TASK
- SEARCH_TASK
- CREATE_ALARME
- UPDATE_ALARME
- DELETE_ALARME
- TOGGLE_ALARME
- CHAT

Règles pour les dates et heures :
- Comprends les dates naturelles comme :
  - demain
  - après-demain
  - hier
  - vendredi semaine prochaine
  - lundi prochain
  - 17 avril
  - 20 juin
  - 1 juin
  - 5 mai
  - ce soir
  - la semaine prochaine
  - fin du mois
- Convertis toujours les dates au format YYYY-MM-DD.
- Convertis toujours l'heure au format HH:mm.
- Si la date n'est pas précisée pour une tâche et qu'elle est nécessaire, laisse le champ vide : "".

Pour modifier une alarme :
- Le titre est obligatoire pour identifier l'alarme.
- Si l'utilisateur change seulement l'heure, remplis seulement "heure".
- Si l'utilisateur change seulement les jours, remplis seulement "jours".
- Si l'utilisateur change seulement le nom, utilise "nouveau_titre".
- Si l'utilisateur dit demain, aujourd'hui, après-demain, une date précise, ou une seule fois :
  utilise "jours": "unique" et remplis "date".
- Si l'utilisateur dit dans X minutes ou dans X heures :
  calcule la date et l'heure exacte puis utilise "jours": "unique".
- Si l'utilisateur dit chaque jour / tous les jours / quotidiennement :
  utilise "jours": "quotidien".
- Si l'utilisateur donne des jours précis comme lundi, mardi, mercredi :
  utilise "jours": "lun,mar,mer".
- Si aucun titre n'est donné, mets "alarme".
- Convertis toujours l'heure au format HH:mm.
- Convertis toujours la date au format YYYY-MM-DD.
{
  "action": "UPDATE_ALARME",
  "titre": "...",
  "nouveau_titre": "...",
  "heure": "HH:mm",
  "date": "YYYY-MM-DD",
  "jours": "unique"
}

Pour supprimer une alarme :
{
  "action": "DELETE_ALARME",
  "titre": "..."
}

Pour activer ou désactiver une alarme :
{
  "action": "TOGGLE_ALARME",
  "titre": "...",
  "active": true
}

Exemples alarmes :

Message : "mets une alarme demain à 08h"
Réponse :
{
  "action": "CREATE_ALARME",
  "titre": "alarme",
  "heure": "08:00",
  "date": "2026-04-28",
  "jours": "unique"
}

Message : "mets une alarme après-demain à 09h30"
Réponse :
{
  "action": "CREATE_ALARME",
  "titre": "alarme",
  "heure": "09:30",
  "date": "2026-04-29",
  "jours": "unique"
}

Message : "mets une alarme dans 2 minutes"
Réponse :
{
  "action": "CREATE_ALARME",
  "titre": "alarme",
  "heure": "HH:mm",
  "date": "YYYY-MM-DD",
  "jours": "unique"
}

Message : "mets une alarme tous les jours à 07h"
Réponse :
{
  "action": "CREATE_ALARME",
  "titre": "alarme",
  "heure": "07:00",
  "jours": "quotidien"
}

Message : "mets une alarme lundi et mardi à 09h"
Réponse :
{
  "action": "CREATE_ALARME",
  "titre": "alarme",
  "heure": "09:00",
  "jours": "lun,mar"
}

Message : "modifie l'alarme réveil à 08h"
Réponse :
{
  "action": "UPDATE_ALARME",
  "titre": "réveil",
  "heure": "08:00"
}

Message : "modifie l'alarme réveil en alarme cours"
Réponse :
{
  "action": "UPDATE_ALARME",
  "titre": "réveil",
  "nouveau_titre": "alarme cours"
}

Message : "supprime l'alarme réveil"
Réponse :
{
  "action": "DELETE_ALARME",
  "titre": "réveil"
}

Message : "désactive l'alarme réveil"
Réponse :
{
  "action": "TOGGLE_ALARME",
  "titre": "réveil",
  "active": false
}

Message : "active l'alarme réveil"
Réponse :
{
  "action": "TOGGLE_ALARME",
  "titre": "réveil",
  "active": true
}
Catégories possibles :
- Études
- Travail
- Personnel
- Santé
- Courses
- Rendez-vous
- Autre

Formats attendus :

Pour créer une note :
{
  "action": "CREATE_NOTE",
  "titre": "...",
  "contenu": "..."
}

Pour modifier une note :
- Le titre est obligatoire pour identifier la note
- Les autres champs sont optionnels
{
  "action": "UPDATE_NOTE",
  "titre": "...",
  "nouveau_titre": "...",
  "contenu": "..."
}

Pour supprimer une note :
{
  "action": "DELETE_NOTE",
  "titre": "..."
}

Pour chercher une note :
{
  "action": "SEARCH_NOTE",
  "titre": "..."
}

Pour créer une tâche :
{
  "action": "CREATE_TASK",
  "titre": "...",
  "heure": "HH:mm",
  "categorie": "...",
  "date": "YYYY-MM-DD"
}

Pour modifier une tâche :
- Le titre est obligatoire pour identifier la tâche
- Les autres champs sont optionnels
- Si l'utilisateur veut changer seulement le nom, utilise "nouveau_titre"
- Si l'utilisateur veut changer seulement la date, remplis seulement "date"
- Si l'utilisateur veut changer seulement l'heure, remplis seulement "heure"
- Si l'utilisateur veut changer seulement la catégorie, remplis seulement "categorie"
{
  "action": "UPDATE_TASK",
  "titre": "...",
  "nouveau_titre": "...",
  "heure": "HH:mm",
  "categorie": "...",
  "date": "YYYY-MM-DD"
}

Pour supprimer une tâche :
{
  "action": "DELETE_TASK",
  "titre": "..."
}

Pour chercher une tâche :
{
  "action": "SEARCH_TASK",
  "titre": "..."
}

Si ce n'est ni une note ni une tâche :
{
  "action": "CHAT"
}

Exemples :

Message : "ajoute une note titre cours contenu réviser chapitre 1"
Réponse :
{
  "action": "CREATE_NOTE",
  "titre": "cours",
  "contenu": "réviser chapitre 1"
}

Message : "ajoute une tâche demain à 18h catégorie études titre révision maths"
Réponse :
{
  "action": "CREATE_TASK",
  "titre": "révision maths",
  "heure": "18:00",
  "categorie": "Études",
  "date": "YYYY-MM-DD"
}

Message : "modifie la tâche école en ecole1"
Réponse :
{
  "action": "UPDATE_TASK",
  "titre": "école",
  "nouveau_titre": "ecole1"
}

Message : "ajoute une note titre manger contenu bonjour et ajoute une tâche le 1 mai titre phy catégorie santé à 12h"
Réponse :
[
  {
    "action": "CREATE_NOTE",
    "titre": "manger",
    "contenu": "bonjour"
  },
  {
    "action": "CREATE_TASK",
    "titre": "phy",
    "heure": "12:00",
    "categorie": "Santé",
    "date": "YYYY-MM-DD"
  }
  Pour créer une alarme :
{
  "action": "CREATE_ALARME",
  "titre": "...",
  "heure": "HH:mm",
  "jours": "quotidien"
}

Pour modifier une alarme :
{
  "action": "UPDATE_ALARME",
  "titre": "...",
  "nouveau_titre": "...",
  "heure": "HH:mm",
  "jours": "quotidien"
}

Pour supprimer une alarme :
{
  "action": "DELETE_ALARME",
  "titre": "..."
}

Pour activer ou désactiver une alarme :
{
  "action": "TOGGLE_ALARME",
  "titre": "...",
  "active": true
}
]

Date actuelle :
${DateTime.now().toIso8601String()}

Message utilisateur :
$message
""";

      final response = await http
          .post(
            url,
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
          .timeout(const Duration(seconds: 20));
      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final texte = data["candidates"][0]["content"]["parts"][0]["text"];

        final nettoye = texte
            .replaceAll("```json", "")
            .replaceAll("```", "")
            .trim();

        final resultat = jsonDecode(nettoye);
        return Map<String, dynamic>.from(resultat);
      }

      return {"action": "CHAT"};
    } catch (e) {
      print("Erreur Gemini analyserCommande: $e");
      return {"action": "CHAT"};
    }
  }

  Future<String> envoyerMessageChat(
    String message, {
    ModeleContexte? contexte,
  }) async {
    try {
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Tu es ORA, un assistant intelligent. Réponds clairement et brièvement : $message",
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        return "Erreur Gemini (code ${response.statusCode})";
      }
    } catch (e) {
      return "Erreur de connexion Gemini";
    }
  }
}
