import '../models/modele_tache.dart';
import '../services/service_tache.dart';
import 'package:ora/services/service_notification.dart';
class ControleurTache {
  final ServiceTache _serviceTache = ServiceTache();

  Stream<List<ModeleTache>> obtenirFluxTaches() {
    return _serviceTache.obtenirFluxTaches();
  }

  Stream<List<ModeleTache>> obtenirFluxTachesParDate(DateTime date) {
    return _serviceTache.obtenirFluxTachesParDate(date);
  }

 Future<void> ajouterTache({
  required String titre,
  required String heure,
  required DateTime date,
  required String categorie,
  String priorite = 'moyenne',
}) async {
  await _serviceTache.ajouterTache(
    titre: titre,
    heure: heure,
    date: date,
    categorie: categorie,
    priorite: priorite,
  );
if (heure == "--:--" || !heure.contains(":")) return;
  if (categorie.toLowerCase() == 'rendez-vous') {
    await ServiceNotification().creerNotification(
      title: 'Rendez-vous : $titre',
      body:
          'Rendez-vous : $titre. Consultez le trajet pour arriver à l’heure 📍',
      type: 'rendez_vous',
      iconType: 'trip',
      Duration rappelAvant;

if (priorite.toLowerCase() == 'haute') {
  rappelAvant = const Duration(minutes: 30);
} else if (priorite.toLowerCase() == 'moyenne') {
  rappelAvant = const Duration(minutes: 15);
} else {
  rappelAvant = const Duration(minutes: 5);
}
      scheduledFor: DateTime(
  date.year,
  date.month,
  date.day,
  int.parse(heure.split(':')[0]),
  int.parse(heure.split(':')[1]),
).subtract(rappelAvant),
      data: {
        'destination': titre,
        'date': date.toIso8601String(),
        'heure': heure,
      },
    );
  }
  if (categorie.toLowerCase() == 'étude' ||
    categorie.toLowerCase() == 'etude') {
  await ServiceNotification().creerNotification(
    title: 'Étude : $titre',
    body: 'Il est temps de commencer votre séance d’étude 📚',
    type: 'etude',
    iconType: 'study',
    Duration rappelAvant;

if (priorite.toLowerCase() == 'haute') {
  rappelAvant = const Duration(minutes: 30);
} else if (priorite.toLowerCase() == 'moyenne') {
  rappelAvant = const Duration(minutes: 15);
} else {
  rappelAvant = const Duration(minutes: 5);
}
    scheduledFor: DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(heure.split(':')[0]),
      int.parse(heure.split(':')[1]),
    ).subtract(rappelAvant),
    data: {
      'titre': titre,
      'date': date.toIso8601String(),
      'heure': heure,
    },
  );
}
if (categorie.toLowerCase() == 'courses') {
  await ServiceNotification().creerNotification(
    title: 'Courses : $titre',
    body: 'N’oublie pas tes courses 🛒',
    type: 'courses',
    iconType: 'shopping',
    Duration rappelAvant;

if (priorite.toLowerCase() == 'haute') {
  rappelAvant = const Duration(minutes: 30);
} else if (priorite.toLowerCase() == 'moyenne') {
  rappelAvant = const Duration(minutes: 15);
} else {
  rappelAvant = const Duration(minutes: 5);
}
    scheduledFor: DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(heure.split(':')[0]),
      int.parse(heure.split(':')[1]),
    ).subtract(rappelAvant),
    data: {
      'titre': titre,
      'date': date.toIso8601String(),
      'heure': heure,
    },
  );
}
if (categorie.toLowerCase() == 'travail') {
  await ServiceNotification().creerNotification(
    title: 'Travail : $titre',
    body: 'Votre tâche de travail aprés 20 min💼',
    type: 'travail',
    iconType: 'work',
    Duration rappelAvant;

if (priorite.toLowerCase() == 'haute') {
  rappelAvant = const Duration(minutes: 30);
} else if (priorite.toLowerCase() == 'moyenne') {
  rappelAvant = const Duration(minutes: 15);
} else {
  rappelAvant = const Duration(minutes: 5);
}
    scheduledFor: DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(heure.split(':')[0]),
      int.parse(heure.split(':')[1]),
    ).subtract(rappelAvant),
    data: {
      'titre': titre,
      'date': date.toIso8601String(),
      'heure': heure,
    },
  );
}

if (categorie.toLowerCase() == 'personnelle') {
  await ServiceNotification().creerNotification(
    title: 'Personnel : $titre',
    body: 'Votre activité personnelle approche 😊',
    type: 'personnelle',
    iconType: 'personnel',
    Duration rappelAvant;

if (priorite.toLowerCase() == 'haute') {
  rappelAvant = const Duration(minutes: 30);
} else if (priorite.toLowerCase() == 'moyenne') {
  rappelAvant = const Duration(minutes: 15);
} else {
  rappelAvant = const Duration(minutes: 5);
}
    scheduledFor: DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(heure.split(':')[0]),
      int.parse(heure.split(':')[1]),
    ).subtract(rappelAvant),
    data: {
      'titre': titre,
      'date': date.toIso8601String(),
      'heure': heure,
    },
  );
}

if (categorie.toLowerCase() == 'santé' ||
    categorie.toLowerCase() == 'sante') {
  await ServiceNotification().creerNotification(
    title: 'Santé : $titre',
    body: 'Votre activité santé approche ❤️',
    type: 'sante',
    iconType: 'health',
    Duration rappelAvant;

if (priorite.toLowerCase() == 'haute') {
  rappelAvant = const Duration(minutes: 30);
} else if (priorite.toLowerCase() == 'moyenne') {
  rappelAvant = const Duration(minutes: 15);
} else {
  rappelAvant = const Duration(minutes: 5);
}
    scheduledFor: DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(heure.split(':')[0]),
      int.parse(heure.split(':')[1]),
    ).subtract(rappelAvant),
    data: {
      'titre': titre,
      'date': date.toIso8601String(),
      'heure': heure,
    },
  );
}

if (categorie.toLowerCase() == 'autre') {
  await ServiceNotification().creerNotification(
    title: 'Rappel : $titre',
    body: 'Votre tâche approche ⏰',
    type: 'autre',
    iconType: 'task',
    Duration rappelAvant;

if (priorite.toLowerCase() == 'haute') {
  rappelAvant = const Duration(minutes: 30);
} else if (priorite.toLowerCase() == 'moyenne') {
  rappelAvant = const Duration(minutes: 15);
} else {
  rappelAvant = const Duration(minutes: 5);
}
    scheduledFor: DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(heure.split(':')[0]),
      int.parse(heure.split(':')[1]),
    ).subtract(rappelAvant),
    data: {
      'titre': titre,
      'date': date.toIso8601String(),
      'heure': heure,
    },
  );
}

}
  Future<void> supprimerTache(String idTache) {
    return _serviceTache.supprimerTache(idTache);
  }

  Future<void> changerEtatTache({
    required String idTache,
    required bool terminee,
  }) {
    return _serviceTache.changerEtatTache(idTache: idTache, terminee: terminee);
  }

  Future<void> synchroniserTaches() async {
    await _serviceTache.synchroniserVersFirebase();
    await _serviceTache.synchroniserDepuisFirebase();
  }

  Future<List<ModeleTache>> recupererTachesParDateTriees(DateTime date) {
    return _serviceTache.recupererTachesParDateTriees(date);
  }

  List<ModeleTache> trierParPriorite(List<ModeleTache> taches) {
    return _serviceTache.trierParPriorite(taches);
  }

  List<ModeleTache> filtrerParDate(List<ModeleTache> taches, DateTime date) {
    return taches.where((tache) {
      return tache.date.year == date.year &&
          tache.date.month == date.month &&
          tache.date.day == date.day;
    }).toList();
  }

  void dispose() {
    _serviceTache.dispose();
  }
}
