import 'package:easy_localization/easy_localization.dart';

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

    final partiesHeure = heure.split(':');
    if (partiesHeure.length != 2) return;

    final int? heureTache = int.tryParse(partiesHeure[0]);
    final int? minuteTache = int.tryParse(partiesHeure[1]);

    if (heureTache == null || minuteTache == null) return;

    final DateTime dateTache = DateTime(
      date.year,
      date.month,
      date.day,
      heureTache,
      minuteTache,
    );

    final Duration rappelAvant = _obtenirDureeRappel(priorite);
    final DateTime dateNotification = dateTache.subtract(rappelAvant);

    if (dateNotification.isBefore(DateTime.now())) return;

    final String categorieNormalisee = categorie.toLowerCase().trim();

    if (categorieNormalisee == 'rendez-vous') {
      await ServiceNotification().creerNotification(
        title: 'notif_rendez_vous_title'.tr(args: [titre]),
        body: 'notif_rendez_vous_body'.tr(args: [titre]),
        type: 'rendez_vous',
        iconType: 'trip',
        scheduledFor: dateNotification,
        data: {
          'destination': titre,
          'date': date.toIso8601String(),
          'heure': heure,
        },
      );
      return;
    }

    if (categorieNormalisee == 'étude' || categorieNormalisee == 'etude') {
      await ServiceNotification().creerNotification(
        title: 'notif_etude_title'.tr(args: [titre]),
        body: 'notif_etude_body'.tr(),
        type: 'etude',
        iconType: 'study',
        scheduledFor: dateNotification,
        data: {
          'titre': titre,
          'date': date.toIso8601String(),
          'heure': heure,
        },
      );
      return;
    }

    if (categorieNormalisee == 'courses') {
      await ServiceNotification().creerNotification(
        title: 'notif_courses_title'.tr(args: [titre]),
        body: 'notif_courses_body'.tr(),
        type: 'courses',
        iconType: 'shopping',
        scheduledFor: dateNotification,
        data: {
          'titre': titre,
          'date': date.toIso8601String(),
          'heure': heure,
        },
      );
      return;
    }

    if (categorieNormalisee == 'travail') {
      await ServiceNotification().creerNotification(
        title: 'notif_travail_title'.tr(args: [titre]),
        body: 'notif_travail_body'.tr(),
        type: 'travail',
        iconType: 'work',
        scheduledFor: dateNotification,
        data: {
          'titre': titre,
          'date': date.toIso8601String(),
          'heure': heure,
        },
      );
      return;
    }

    if (categorieNormalisee == 'personnelle') {
      await ServiceNotification().creerNotification(
        title: 'notif_personnel_title'.tr(args: [titre]),
        body: 'notif_personnel_body'.tr(),
        type: 'personnelle',
        iconType: 'personnel',
        scheduledFor: dateNotification,
        data: {
          'titre': titre,
          'date': date.toIso8601String(),
          'heure': heure,
        },
      );
      return;
    }

    if (categorieNormalisee == 'santé' || categorieNormalisee == 'sante') {
      await ServiceNotification().creerNotification(
        title: 'notif_sante_title'.tr(args: [titre]),
        body: 'notif_sante_body'.tr(),
        type: 'sante',
        iconType: 'health',
        scheduledFor: dateNotification,
        data: {
          'titre': titre,
          'date': date.toIso8601String(),
          'heure': heure,
        },
      );
      return;
    }

    await ServiceNotification().creerNotification(
      title: 'notif_rappel_title'.tr(args: [titre]),
      body: 'notif_rappel_body'.tr(),
      type: 'autre',
      iconType: 'task',
      scheduledFor: dateNotification,
      data: {
        'titre': titre,
        'date': date.toIso8601String(),
        'heure': heure,
      },
    );
  }

  Duration _obtenirDureeRappel(String priorite) {
    final String prioriteNormalisee = priorite.toLowerCase().trim();

    if (prioriteNormalisee == 'haute') {
      return const Duration(minutes: 30);
    }

    if (prioriteNormalisee == 'moyenne') {
      return const Duration(minutes: 15);
    }

    return const Duration(minutes: 5);
  }

  Future<void> supprimerTache(String idTache) {
    return _serviceTache.supprimerTache(idTache);
  }

  Future<void> changerEtatTache({
    required String idTache,
    required bool terminee,
  }) {
    return _serviceTache.changerEtatTache(
      idTache: idTache,
      terminee: terminee,
    );
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