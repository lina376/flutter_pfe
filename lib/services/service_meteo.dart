import '../models/modele_meteo.dart';

class ServiceMeteo {
  Future<MeteoActuelle> obtenirMeteoActuelle() async {
    await Future.delayed(const Duration(seconds: 1));

    return MeteoActuelle(
      ville: "Sousse",
      temperature: 24,
      description: "Ciel dégagé",
      ressenti: 26,
      humidite: 60,
      vent: 12,
      pression: 1015,
      conseil: "Temps agréable aujourd’hui ☀️",
    );
  }

  Future<List<PrevisionJour>> obtenirPrevisions() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      PrevisionJour(
        jour: "Lun",
        temperatureMax: 25,
        temperatureMin: 18,
        description: "Soleil",
      ),
      PrevisionJour(
        jour: "Mar",
        temperatureMax: 23,
        temperatureMin: 17,
        description: "Nuageux",
      ),
      PrevisionJour(
        jour: "Mer",
        temperatureMax: 21,
        temperatureMin: 16,
        description: "Pluie",
      ),
    ];
  }
}
