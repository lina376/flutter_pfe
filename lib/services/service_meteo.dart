import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/modele_meteo.dart';

class ServiceMeteo {
  String _descriptionDepuisCode(int code) {
    if (code == 0) return 'Ciel dégagé';
    if ([1, 2, 3].contains(code)) return 'Partiellement nuageux';
    if ([45, 48].contains(code)) return 'Brouillard';
    if ([51, 53, 55, 56, 57].contains(code)) return 'Bruine';
    if ([61, 63, 65, 66, 67].contains(code)) return 'Pluie';
    if ([71, 73, 75, 77].contains(code)) return 'Neige';
    if ([80, 81, 82].contains(code)) return 'Averses';
    if ([95, 96, 99].contains(code)) return 'Orage';
    return 'Météo variable';
  }

  String _conseilDepuisMeteo({
    required String description,
    required int temperature,
    required int vent,
  }) {
    final d = description.toLowerCase();

    if (d.contains('orage')) {
      return 'Attention, risque d’orage. Évite de sortir sans nécessité et prends une marge de temps.';
    }
    if (d.contains('pluie') || d.contains('averse') || d.contains('bruine')) {
      return 'Il peut pleuvoir. Prends un parapluie et sors un peu plus tôt.';
    }
    if (d.contains('brouillard')) {
      return 'Visibilité faible. Fais attention sur la route et pars plus tôt.';
    }
    if (vent >= 35) {
      return 'Il y a du vent. Fais attention pendant le trajet.';
    }
    if (temperature >= 32) {
      return 'Il fait chaud. Bois de l’eau et évite l’effort prolongé.';
    }
    if (temperature <= 10) {
      return 'Il fait froid. Habille-toi bien avant de sortir.';
    }

    return 'Temps acceptable aujourd’hui.';
  }

  int margeTrajetSelonMeteo(MeteoActuelle meteo) {
    final d = meteo.description.toLowerCase();

    if (d.contains('orage')) return 30;
    if (d.contains('pluie') || d.contains('averse') || d.contains('bruine')) {
      return 20;
    }
    if (d.contains('brouillard')) return 20;
    if (meteo.vent >= 35) return 15;
    return 10;
  }

  Future<({double latitude, double longitude, String nom})?> _chercherVille(
    String ville,
  ) async {
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(ville)}&count=1&language=fr&format=json',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'];
    if (results is! List || results.isEmpty) return null;

    final premier = Map<String, dynamic>.from(results.first as Map);
    return (
      latitude: (premier['latitude'] as num).toDouble(),
      longitude: (premier['longitude'] as num).toDouble(),
      nom: (premier['name'] ?? ville).toString(),
    );
  }

  Future<MeteoActuelle> obtenirMeteoActuelle({String ville = 'Sousse'}) async {
    try {
      final position = await _chercherVille(ville);
      if (position == null) throw Exception('Ville introuvable');

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,surface_pressure&timezone=auto',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) throw Exception('Erreur météo');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final current = Map<String, dynamic>.from(data['current'] as Map);

      final temperature = ((current['temperature_2m'] ?? 0) as num).round();
      final ressenti = ((current['apparent_temperature'] ?? temperature) as num)
          .round();
      final humidite = ((current['relative_humidity_2m'] ?? 0) as num).round();
      final vent = ((current['wind_speed_10m'] ?? 0) as num).round();
      final pression = ((current['surface_pressure'] ?? 1015) as num).round();
      final code = ((current['weather_code'] ?? 0) as num).round();
      final description = _descriptionDepuisCode(code);

      return MeteoActuelle(
        ville: position.nom,
        temperature: temperature,
        description: description,
        ressenti: ressenti,
        humidite: humidite,
        vent: vent,
        pression: pression,
        conseil: _conseilDepuisMeteo(
          description: description,
          temperature: temperature,
          vent: vent,
        ),
      );
    } catch (_) {
      return MeteoActuelle(
        ville: ville,
        temperature: 24,
        description: 'Météo indisponible',
        ressenti: 24,
        humidite: 0,
        vent: 0,
        pression: 1015,
        conseil:
            'Je n’ai pas pu récupérer la météo réelle. Vérifie la connexion internet.',
      );
    }
  }

  Future<MeteoActuelle> obtenirMeteoPourVille(String ville) {
    return obtenirMeteoActuelle(ville: ville);
  }

  Future<List<PrevisionJour>> obtenirPrevisions({
    String ville = 'Sousse',
  }) async {
    try {
      final position = await _chercherVille(ville);
      if (position == null) throw Exception('Ville introuvable');

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=3',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) throw Exception('Erreur météo');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final daily = Map<String, dynamic>.from(data['daily'] as Map);
      final jours = (daily['time'] as List).cast<String>();
      final max = (daily['temperature_2m_max'] as List).cast<num>();
      final min = (daily['temperature_2m_min'] as List).cast<num>();
      final codes = (daily['weather_code'] as List).cast<num>();

      return List.generate(jours.length, (index) {
        final date = DateTime.parse(jours[index]);
        const noms = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
        return PrevisionJour(
          jour: noms[date.weekday - 1],
          temperatureMax: max[index].round(),
          temperatureMin: min[index].round(),
          description: _descriptionDepuisCode(codes[index].round()),
        );
      });
    } catch (_) {
      return [
        PrevisionJour(
          jour: 'Auj',
          temperatureMax: 24,
          temperatureMin: 18,
          description: 'Indisponible',
        ),
      ];
    }
  }
}
