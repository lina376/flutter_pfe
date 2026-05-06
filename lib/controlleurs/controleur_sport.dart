import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ora/controlleurs/controleur_eau.dart';
import 'package:ora/controlleurs/controleur_sante.dart';
import 'package:ora/models/modele_eau.dart';
import 'package:ora/models/modele_sante.dart';
import 'package:ora/models/modele_sport.dart';
import 'package:ora/services/service_sport_firebase.dart';
import 'package:ora/services/service_sport_local.dart';

class ControleurSport {
  final ServiceSportLocal _local = ServiceSportLocal.instance;
  final ServiceSportFirebase _firebase = ServiceSportFirebase();
  final FirebaseAuth _authentification = FirebaseAuth.instance;

  String get dateAujourdhui {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  String get _userId {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) {
      throw Exception('Utilisateur non connecté');
    }
    return utilisateur.uid;
  }

  bool _estFatigue(ModeleSante? sante) {
    if (sante == null) return false;
    return sante.heuresSommeil <= 5 ||
        sante.humeur == 'Fatigué' ||
        sante.humeur == 'Stressé';
  }

  bool _hydratationFaible(ModeleEau? eau) {
    if (eau == null || eau.objectif == 0) return false;
    return (eau.verres / eau.objectif) < 0.40;
  }

  bool _personneFragile(ModeleSante? sante, String etatSante) {
    return etatSante == 'Malade' || (sante != null && sante.age >= 50);
  }

  int calculerObjectifSport({
    required ModeleSante? sante,
    required ModeleEau? eau,
    required String objectifSport,
    required String etatSante,
  }) {
    int objectif = 30;
    final poids = sante?.poids ?? 65.0;
    final age = sante?.age ?? 20;

    if (objectifSport == 'Perte de poids') {
      objectif = poids >= 85 ? 35 : 45;
    } else if (objectifSport == 'Prise de poids') {
      objectif = 35;
    } else {
      objectif = 30;
    }

    if (sante?.activite == 'Sportif') objectif += 5;
    if (sante?.activite == 'Faible') objectif -= 5;

    if (_estFatigue(sante)) objectif -= 10;
    if (_hydratationFaible(eau)) objectif -= 5;
    if (_personneFragile(sante, etatSante)) objectif = age >= 50 ? 20 : 25;
    if (age < 18 && objectif > 35) objectif = 35;

    return objectif.clamp(15, 60).toInt();
  }

  String proposerTypeSeance({
    required ModeleSante? sante,
    required String objectifSport,
    required String etatSante,
  }) {
    if (_personneFragile(sante, etatSante)) return 'Marche douce';
    if (sante != null && sante.humeur == 'Stressé') return 'Yoga';
    if (_estFatigue(sante)) return 'Étirement';

    if (objectifSport == 'Perte de poids') return 'Cardio léger';
    if (objectifSport == 'Prise de poids') return 'Renforcement';

    if (sante?.activite == 'Sportif') return 'Cardio';
    return 'Marche active';
  }

  String proposerIntensite({
    required ModeleSante? sante,
    required ModeleEau? eau,
    required String objectifSport,
    required String etatSante,
  }) {
    if (_personneFragile(sante, etatSante)) return 'Légère';
    if (_estFatigue(sante)) return 'Douce';
    if (_hydratationFaible(eau)) return 'Modérée';
    if (objectifSport == 'Prise de poids') return 'Renforcement';
    if (objectifSport == 'Perte de poids') return 'Progressive';
    if (sante?.activite == 'Sportif' && (sante?.heuresSommeil ?? 0) >= 7) {
      return 'Intense';
    }
    return 'Modérée';
  }

  int calculerCalories({
    required int minutes,
    required String typeSeance,
    required double poids,
    required int age,
    required String intensite,
    required String etatSante,
  }) {
    double coefficient = 4.0;

    switch (typeSeance) {
      case 'Cardio':
        coefficient = 7.0;
        break;
      case 'Cardio léger':
        coefficient = 5.5;
        break;
      case 'Renforcement':
        coefficient = 6.0;
        break;
      case 'Marche active':
        coefficient = 4.5;
        break;
      case 'Marche douce':
        coefficient = 3.0;
        break;
      case 'Yoga':
        coefficient = 3.0;
        break;
      case 'Étirement':
        coefficient = 2.4;
        break;
      default:
        coefficient = 4.0;
    }

    if (intensite == 'Intense') coefficient += 0.8;
    if (intensite == 'Douce' || intensite == 'Légère') coefficient -= 0.5;
    if (age >= 50 || etatSante == 'Malade') coefficient *= 0.85;
    if (age < 18) coefficient *= 0.90;

    return ((minutes * coefficient * poids) / 70).round().clamp(0, 2000).toInt();
  }

  ModeleSport _mettreAJourSelonProfil({
    required ModeleSport sport,
    required ModeleSante? sante,
    required ModeleEau? eau,
  }) {
    final objectifMinutes = calculerObjectifSport(
      sante: sante,
      eau: eau,
      objectifSport: sport.objectifSport,
      etatSante: sport.etatSante,
    );

    final typeSeance = proposerTypeSeance(
      sante: sante,
      objectifSport: sport.objectifSport,
      etatSante: sport.etatSante,
    );

    final intensite = proposerIntensite(
      sante: sante,
      eau: eau,
      objectifSport: sport.objectifSport,
      etatSante: sport.etatSante,
    );

    final calories = calculerCalories(
      minutes: sport.minutes,
      typeSeance: typeSeance,
      poids: sante?.poids ?? 65.0,
      age: sante?.age ?? 20,
      intensite: intensite,
      etatSante: sport.etatSante,
    );

    return sport.copyWith(
      objectifMinutes: objectifMinutes,
      typeSeance: typeSeance,
      intensite: intensite,
      calories: calories,
      updatedAt: DateTime.now(),
      synced: false,
    );
  }

  Future<ModeleSport> chargerAujourdhui() async {
    final userId = _userId;
    final date = dateAujourdhui;
    final profilSante = await ControleurSante().obtenirDernierProfil();
    final profilEau = await ControleurEau().chargerAujourdhui();
    final existant = await _local.obtenirParDate(userId, date);

    if (existant != null) {
      final maj = _mettreAJourSelonProfil(
        sport: existant,
        sante: profilSante,
        eau: profilEau,
      );

      if (maj.objectifMinutes != existant.objectifMinutes ||
          maj.typeSeance != existant.typeSeance ||
          maj.intensite != existant.intensite ||
          maj.calories != existant.calories) {
        await _local.sauvegarder(maj);
        await synchroniser(maj);
        return maj;
      }

      return existant;
    }

    final base = ModeleSport(
      id: '$userId-$date',
      userId: userId,
      date: date,
      minutes: 0,
      objectifMinutes: 30,
      objectifSport: 'Rester en forme',
      etatSante: 'Bonne santé',
      typeSeance: 'Marche active',
      intensite: 'Modérée',
      calories: 0,
      updatedAt: DateTime.now(),
      synced: false,
    );

    final nouveau = _mettreAJourSelonProfil(
      sport: base,
      sante: profilSante,
      eau: profilEau,
    );

    await _local.sauvegarder(nouveau);
    await synchroniser(nouveau);
    return nouveau;
  }

  Future<List<ModeleSport>> chargerSemaineDepuis(DateTime dateReference) async {
    final debutSemaine = dateReference.subtract(
      Duration(days: dateReference.weekday - 1),
    );
    final finSemaine = debutSemaine.add(const Duration(days: 6));

    return _local.obtenirEntreDates(
      userId: _userId,
      debut: DateFormat('yyyy-MM-dd').format(debutSemaine),
      fin: DateFormat('yyyy-MM-dd').format(finSemaine),
    );
  }

  Future<List<ModeleSport>> chargerSemaine() async {
    return chargerSemaineDepuis(DateTime.now());
  }

  Future<ModeleSport> modifierMinutes(ModeleSport sport, int minutes) async {
    final profilSante = await ControleurSante().obtenirDernierProfil();
    final minutesCorrigees = minutes.clamp(0, 240).toInt();

    final maj = sport.copyWith(
      userId: _userId,
      minutes: minutesCorrigees,
      calories: calculerCalories(
        minutes: minutesCorrigees,
        typeSeance: sport.typeSeance,
        poids: profilSante?.poids ?? 65.0,
        age: profilSante?.age ?? 20,
        intensite: sport.intensite,
        etatSante: sport.etatSante,
      ),
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);
    return maj;
  }

  Future<ModeleSport> modifierTypeSeance(
    ModeleSport sport,
    String typeSeance,
  ) async {
    final profilSante = await ControleurSante().obtenirDernierProfil();

    final maj = sport.copyWith(
      userId: _userId,
      typeSeance: typeSeance,
      calories: calculerCalories(
        minutes: sport.minutes,
        typeSeance: typeSeance,
        poids: profilSante?.poids ?? 65.0,
        age: profilSante?.age ?? 20,
        intensite: sport.intensite,
        etatSante: sport.etatSante,
      ),
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);
    return maj;
  }

  Future<ModeleSport> modifierObjectifSport(
    ModeleSport sport,
    String objectifSport,
  ) async {
    final profilSante = await ControleurSante().obtenirDernierProfil();
    final profilEau = await ControleurEau().chargerAujourdhui();

    final base = sport.copyWith(
      userId: _userId,
      objectifSport: objectifSport,
      updatedAt: DateTime.now(),
      synced: false,
    );

    final maj = _mettreAJourSelonProfil(
      sport: base,
      sante: profilSante,
      eau: profilEau,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);
    return maj;
  }

  Future<ModeleSport> modifierEtatSante(
    ModeleSport sport,
    String etatSante,
  ) async {
    final profilSante = await ControleurSante().obtenirDernierProfil();
    final profilEau = await ControleurEau().chargerAujourdhui();

    final base = sport.copyWith(
      userId: _userId,
      etatSante: etatSante,
      updatedAt: DateTime.now(),
      synced: false,
    );

    final maj = _mettreAJourSelonProfil(
      sport: base,
      sante: profilSante,
      eau: profilEau,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);
    return maj;
  }

  Future<void> sauvegarderEtSynchroniser(ModeleSport sport) async {
    final donnees = sport.copyWith(userId: _userId);
    await _local.sauvegarder(donnees);
    await synchroniser(donnees);
  }

  Future<void> synchroniser(ModeleSport sport) async {
    final donnees = sport.copyWith(userId: _userId);
    try {
      await _firebase.sauvegarder(donnees);
      await _local.sauvegarder(donnees.copyWith(synced: true));
    } catch (_) {
      await _local.sauvegarder(donnees.copyWith(synced: false));
    }
  }

  Future<void> synchroniserTout() async {
    final nonSynces = await _local.obtenirNonSynchronises(_userId);

    for (final item in nonSynces) {
      await synchroniser(item);
    }
  }

  Future<ModeleSante?> obtenirSanteLiee() async {
    return ControleurSante().obtenirDernierProfil();
  }

  Future<ModeleEau?> obtenirEauLiee() async {
    return ControleurEau().chargerAujourdhui();
  }

  List<Map<String, dynamic>> exercicesRecommandes({
    required ModeleSport sport,
    required ModeleSante? sante,
    required ModeleEau? eau,
  }) {
    if (_personneFragile(sante, sport.etatSante) || _estFatigue(sante)) {
      return [
        {'titre': 'Marche douce', 'duree': '15-20 min'},
        {'titre': 'Étirement', 'duree': '10-15 min'},
        {'titre': 'Yoga', 'duree': '15-20 min'},
      ];
    }

    if (sport.objectifSport == 'Perte de poids') {
      return [
        {'titre': 'Cardio léger', 'duree': sante != null && sante.poids >= 85 ? '25-35 min' : '30-45 min'},
        {'titre': 'Marche active', 'duree': '30-45 min'},
        {'titre': 'Renforcement', 'duree': '15-25 min'},
      ];
    }

    if (sport.objectifSport == 'Prise de poids') {
      return [
        {'titre': 'Renforcement', 'duree': '30-40 min'},
        {'titre': 'Marche active', 'duree': '15-20 min'},
        {'titre': 'Étirement', 'duree': '10-15 min'},
      ];
    }

    return [
      {'titre': 'Marche active', 'duree': '20-30 min'},
      {'titre': 'Yoga', 'duree': '15-25 min'},
      {'titre': 'Cardio léger', 'duree': '20-30 min'},
    ];
  }

  String conseilSport({
    required ModeleSport sport,
    required ModeleSante? sante,
    required ModeleEau? eau,
  }) {
    final progressionEau = eau == null || eau.objectif == 0
        ? 0.0
        : eau.verres / eau.objectif;

    if (_personneFragile(sante, sport.etatSante)) {
      return 'ORA adapte le sport à votre état de santé 🌿\n'
          'Séance légère recommandée : ${sport.typeSeance}, ${sport.objectifMinutes} min maximum.\n'
          'Évitez l’effort intense et reposez-vous si vous vous sentez fatigué.';
    }

    if (sante != null && sante.age < 18) {
      return 'ORA propose un programme adapté à votre âge ✨\n'
          'Objectif : ${sport.objectifSport}. Séance conseillée : ${sport.typeSeance}.\n'
          'On évite les séances trop longues ou trop intenses.';
    }

    if (sante != null && sante.heuresSommeil <= 4) {
      return 'ORA détecte une fatigue importante 😴\n'
          'Aujourd’hui, privilégiez une activité douce.\n'
          'Objectif conseillé : ${sport.objectifMinutes} min, sans forcer.';
    }

    if (sante != null && sante.humeur == 'Stressé') {
      return 'Votre niveau de stress semble élevé 🌿\n'
          'ORA recommande yoga, respiration ou marche calme.\n'
          'Buvez régulièrement avant et après l’effort.';
    }

    if (progressionEau < 0.40 && sport.minutes > 0) {
      return 'ORA remarque que votre hydratation est faible 💧\n'
          'Avant de continuer le sport, essayez de boire un verre d’eau.\n'
          'La durée est réduite pour rester raisonnable : ${sport.objectifMinutes} min.';
    }

    if (sport.minutes >= sport.objectifMinutes) {
      return 'Excellent travail ✨\n'
          'Votre objectif sportif est atteint aujourd’hui.\n'
          'Pensez maintenant à la récupération et à l’hydratation.';
    }

    if (sport.objectifSport == 'Perte de poids') {
      return 'Objectif perte de poids 🔥\n'
          'ORA recommande ${sport.typeSeance} avec intensité ${sport.intensite.toLowerCase()}.\n'
          'Le programme tient compte de votre poids, sommeil et hydratation.';
    }

    if (sport.objectifSport == 'Prise de poids') {
      return 'Objectif prise de poids saine 💪\n'
          'ORA recommande surtout le renforcement musculaire.\n'
          'Associez la séance avec une alimentation régulière.';
    }

    return 'ORA propose une activité équilibrée aujourd’hui 💪\n'
        'Séance recommandée : ${sport.typeSeance}, intensité ${sport.intensite.toLowerCase()}.\n'
        'Avancement : ${sport.minutes}/${sport.objectifMinutes} min.';
  }
}
