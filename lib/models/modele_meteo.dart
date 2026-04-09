class MeteoActuelle {
  final String ville;
  final int temperature;
  final String description;
  final int ressenti;
  final int humidite;
  final int vent;
  final int pression;
  final String conseil;

  MeteoActuelle({
    required this.ville,
    required this.temperature,
    required this.description,
    required this.ressenti,
    required this.humidite,
    required this.vent,
    required this.pression,
    required this.conseil,
  });
}

class PrevisionJour {
  final String jour;
  final int temperatureMax;
  final int temperatureMin;
  final String description;

  PrevisionJour({
    required this.jour,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.description,
  });
}
