import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ora/models/modele_coach_ora.dart';
import 'package:ora/models/modele_eau.dart';
import 'package:ora/models/modele_sante.dart';
import 'package:ora/models/modele_sport.dart';
import 'package:ora/services/service_eau_local.dart';
import 'package:ora/services/service_sante_local.dart';
import 'package:ora/services/service_sport_local.dart';

class ServiceCoachOra {
  final ServiceEauLocal _serviceEau = ServiceEauLocal.instance;
  final ServiceSanteLocal _serviceSante = ServiceSanteLocal.instance;
  final ServiceSportLocal _serviceSport = ServiceSportLocal.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  String get dateAujourdhui => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<ModeleCoachOra> construireCoachAujourdhui() async {
    final uid = userId;
    if (uid == null) {
      return _coachInvite();
    }

    final date = dateAujourdhui;
    final eau = await _serviceEau.obtenirParDate(uid, date);
    final sante = await _serviceSante.obtenirParDate(userId: uid, date: date);
    final sport = await _serviceSport.obtenirParDate(uid, date);

    final coach = _construireDepuisDonnees(
      userId: uid,
      date: date,
      eau: eau,
      sante: sante,
      sport: sport,
    );

    await sauvegarderResumeFirebase(coach);
    return coach;
  }

  ModeleCoachOra _coachInvite() {
    return ModeleCoachOra(
      userId: 'invite',
      date: dateAujourdhui,
      eauBu: 0,
      objectifEau: 2,
      minutesSport: 0,
      objectifSport: 30,
      heuresSommeil: 7,
      humeur: 'Stable',
      etatGeneral: 'Connectez-vous pour personnaliser votre suivi.',
      scoreBienEtre: 65,
      conseilDuJour:
          'Commencez par remplir votre profil santé, puis suivez votre hydratation et votre activité sportive.',
      recommandationHydratation: 'Objectif conseillé : environ 2 L par jour.',
      recommandationSport: 'Activité douce conseillée : 20 à 30 minutes de marche.',
      alerteSante: 'Aucune alerte disponible sans profil connecté.',
      updatedAt: DateTime.now(),
    );
  }

  ModeleCoachOra _construireDepuisDonnees({
    required String userId,
    required String date,
    required ModeleEau? eau,
    required ModeleSante? sante,
    required ModeleSport? sport,
  }) {
    final objectifVerres = (eau?.objectif ?? 10).clamp(1, 30).toInt();
    final verresBus = (eau?.verres ?? 0).clamp(0, 30).toInt();
    final objectifEau = objectifVerres * 0.25;
    final eauBu = verresBus * 0.25;

    final heuresSommeil = sante?.heuresSommeil ?? 7.0;
    final humeur = sante?.humeur ?? 'Stable';
    final minutesSport = sport?.minutes ?? 0;
    final objectifSport = sport?.objectifMinutes ?? 30;

    final tauxEau = (verresBus / objectifVerres).clamp(0.0, 1.0);
    final tauxSport = objectifSport == 0
        ? 0.0
        : (minutesSport / objectifSport).clamp(0.0, 1.0);
    final tauxSommeil = (heuresSommeil / 8).clamp(0.0, 1.0);

    final score = ((tauxEau * 40) + (tauxSport * 30) + (tauxSommeil * 30))
        .round()
        .clamp(0, 100)
        .toInt();

    final recommandationHydratation = tauxEau < 0.5
        ? 'Votre hydratation est faible aujourd’hui. Essayez de boire un verre maintenant et de continuer progressivement.'
        : tauxEau < 1
            ? 'Vous êtes proche de votre objectif. Continuez à boire régulièrement.'
            : 'Objectif hydratation atteint. Gardez ce rythme.';

    final recommandationSport = minutesSport == 0
        ? 'Commencez par une activité simple : marche, étirement ou respiration pendant 10 minutes.'
        : minutesSport < objectifSport
            ? 'Bonne progression. Il vous reste quelques minutes pour atteindre votre objectif sportif.'
            : 'Objectif sport atteint. Pensez à la récupération et à l’étirement.';

    final alerteSante = heuresSommeil < 6
        ? 'Sommeil faible : évitez une séance intense et privilégiez une activité légère.'
        : humeur.toLowerCase().contains('stress')
            ? 'Votre humeur indique du stress. Prenez une pause respiration de 5 minutes.'
            : 'Aucune alerte importante pour aujourd’hui.';

    final conseil = _genererConseil(score, tauxEau, tauxSport, heuresSommeil);

    return ModeleCoachOra(
      userId: userId,
      date: date,
      eauBu: eauBu,
      objectifEau: objectifEau,
      minutesSport: minutesSport,
      objectifSport: objectifSport,
      heuresSommeil: heuresSommeil,
      humeur: humeur,
      etatGeneral: score >= 80
          ? 'Très bon équilibre'
          : score >= 55
              ? 'Équilibre moyen'
              : 'Besoin d’attention',
      scoreBienEtre: score,
      conseilDuJour: conseil,
      recommandationHydratation: recommandationHydratation,
      recommandationSport: recommandationSport,
      alerteSante: alerteSante,
      updatedAt: DateTime.now(),
    );
  }

  String _genererConseil(
    int score,
    double tauxEau,
    double tauxSport,
    double sommeil,
  ) {
    if (sommeil < 6) {
      return 'Votre priorité aujourd’hui est la récupération : hydratez-vous bien et évitez les efforts intenses.';
    }
    if (tauxEau < 0.5) {
      return 'ORA vous conseille de renforcer votre hydratation avant de penser à une séance sportive.';
    }
    if (tauxSport < 0.4) {
      return 'Une marche courte peut améliorer votre énergie sans pression.';
    }
    if (score >= 80) {
      return 'Excellent rythme. Gardez votre équilibre entre hydratation, sommeil et activité.';
    }
    return 'Avancez doucement : un verre d’eau, un mouvement léger et une bonne nuit peuvent améliorer votre journée.';
  }

  Future<void> sauvegarderResumeFirebase(ModeleCoachOra coach) async {
    try {
      if (coach.userId == 'invite') return;
      await _firestore
          .collection('users')
          .doc(coach.userId)
          .collection('coachOra')
          .doc(coach.date)
          .set(coach.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }
}
