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
import 'package:easy_localization/easy_localization.dart';

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
      etatGeneral: 'coach_invite_etat'.tr(),
      scoreBienEtre: 65,
      conseilDuJour: 'coach_invite_conseil'.tr(),
      recommandationHydratation: 'coach_invite_hydratation'.tr(),
      recommandationSport: 'coach_invite_sport'.tr(),
      alerteSante: 'coach_invite_alerte'.tr(),
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
        ? 'coach_hydratation_faible'.tr()
        : tauxEau < 1
            ? 'coach_hydratation_proche'.tr()
            : 'coach_hydratation_atteint'.tr();

    final recommandationSport = minutesSport == 0
        ? 'coach_sport_debut'.tr()
        : minutesSport < objectifSport
            ? 'coach_sport_progression'.tr()
            : 'coach_sport_atteint'.tr();

    final alerteSante = heuresSommeil < 6
        ? 'coach_alerte_sommeil'.tr()
        : humeur.toLowerCase().contains('stress')
            ? 'coach_alerte_stress'.tr()
            : 'coach_alerte_aucune'.tr();

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
          ? 'coach_etat_tres_bon'.tr()
          : score >= 55
              ? 'coach_etat_moyen'.tr()
              : 'coach_etat_attention'.tr(),
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
      return 'coach_conseil_recuperation'.tr();
    }
    if (tauxEau < 0.5) {
      return 'coach_conseil_hydratation'.tr();
    }
    if (tauxSport < 0.4) {
      return 'coach_conseil_marche'.tr();
    }
    if (score >= 80) {
      return 'coach_conseil_excellent'.tr();
    }
    return 'coach_conseil_general'.tr();
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