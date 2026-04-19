import 'dart:convert';
import 'package:http/http.dart' as http;

class ServiceGemini {
  final String apiKey = "AIzaSyCLA7X4XlmiiurOZ-UGZnWH6ev4Vrw19tI";

  Future<Map<String, dynamic>> analyserCommande(String message) async {
    print("Gemini: avant requête");
    try {
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
      );

      final prompt =
          """
Tu es ORA, assistant d'une application mobile de gestion de notes et de tâches.

Important :
- Le mot "tâche" signifie toujours une tâche numérique (todo) dans l'application.
- Ne jamais interpréter "tâche" comme une tâche physique.
- Si l'utilisateur dit "supprimer la tâche X", cela signifie supprimer une tâche dans l'application.
- Retourne uniquement un JSON valide.
- Ne mets aucun texte avant ou après le JSON.

Actions possibles :
- CREATE_NOTE
- UPDATE_NOTE
- DELETE_NOTE
- SEARCH_NOTE
- CREATE_TASK
- UPDATE_TASK
- DELETE_TASK
- SEARCH_TASK
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
- Si aucune heure n'est donnée, mets "--:--".
- Si aucune catégorie n'est donnée, mets "Autre".

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
{
  "action": "UPDATE_NOTE",
  "titre": "...",
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
{
  "action": "UPDATE_TASK",
  "titre": "...",
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

  Future<String> envoyerMessageChat(String message) async {
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
