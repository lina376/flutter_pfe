import '../database/base_locale.dart';
import '../models/modele_alarme.dart';
import 'service_notification_locale.dart';

class ServiceAlarme {
  final BaseLocale _baseLocale = BaseLocale.instance;

  Future<List<ModeleAlarme>> recupererToutesLesAlarmes() async {
    final db = await _baseLocale.database;

    final result = await db.query('alarmes', orderBy: 'heure ASC, minute ASC');

    return result.map((e) => ModeleAlarme.fromMap(e)).toList();
  }

  Future<ModeleAlarme?> trouverAlarmeParTitre(String titreRecherche) async {
    final alarmes = await recupererToutesLesAlarmes();

    try {
      return alarmes.firstWhere(
        (alarme) =>
            alarme.titre.toLowerCase().trim() ==
            titreRecherche.toLowerCase().trim(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<int> ajouterAlarme(ModeleAlarme alarme) async {
    final db = await _baseLocale.database;

    final id = await db.insert('alarmes', alarme.toMap());

    try {
      await _programmerAlarmeNotification(id, alarme);
    } catch (e) {
      print("Erreur programmation notification alarme: $e");
    }

    return id;
  }

  Future<void> modifierAlarme(ModeleAlarme alarme) async {
    if (alarme.id == null) return;

    final db = await _baseLocale.database;

    await db.update(
      'alarmes',
      alarme.toMap(),
      where: 'id = ?',
      whereArgs: [alarme.id],
    );

    await _annulerToutesNotifications(alarme.id!);

    if (alarme.active) {
      await _programmerAlarmeNotification(alarme.id!, alarme);
    }
  }

  Future<void> supprimerAlarme(int id) async {
    final db = await _baseLocale.database;

    await db.delete('alarmes', where: 'id = ?', whereArgs: [id]);

    await _annulerToutesNotifications(id);
  }

  Future<void> basculerActivation(int id, bool active) async {
    final db = await _baseLocale.database;

    await db.update(
      'alarmes',
      {'active': active ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );

    await _annulerToutesNotifications(id);

    if (active) {
      final alarmes = await recupererToutesLesAlarmes();

      ModeleAlarme? alarme;
      try {
        alarme = alarmes.firstWhere((a) => a.id == id);
      } catch (_) {
        alarme = null;
      }

      if (alarme != null) {
        await _programmerAlarmeNotification(id, alarme.copyWith(active: true));
      }
    }
  }

  Future<void> _annulerToutesNotifications(int id) async {
    for (int i = 0; i < 7; i++) {
      await ServiceNotificationLocale.instance.annulerAlarme(id + i);
    }
  }

  Future<void> _programmerAlarmeNotification(
    int id,
    ModeleAlarme alarme,
  ) async {
    if (alarme.jours == "unique") {
      DateTime dateAlarme;

      try {
        final date = DateTime.parse(alarme.date!);

        dateAlarme = DateTime(
          date.year,
          date.month,
          date.day,
          alarme.heure,
          alarme.minute,
        );
      } catch (_) {
        final now = DateTime.now();

        dateAlarme = DateTime(
          now.year,
          now.month,
          now.day,
          alarme.heure,
          alarme.minute,
        );

        if (dateAlarme.isBefore(now)) {
          dateAlarme = dateAlarme.add(const Duration(days: 1));
        }
      }

      await ServiceNotificationLocale.instance.programmerAlarme(
        id: id,
        titre: alarme.titre,
        body: alarme.note == null || alarme.note!.trim().isEmpty
            ? "Alarme ORA"
            : alarme.note!,
        dateTime: dateAlarme,
      );

      return;
    }

    final joursList = alarme.jours == "quotidien"
        ? ["lun", "mar", "mer", "jeu", "ven", "sam", "dim"]
        : alarme.jours.split(",");

    final weekdayMap = {
      "lun": DateTime.monday,
      "mar": DateTime.tuesday,
      "mer": DateTime.wednesday,
      "jeu": DateTime.thursday,
      "ven": DateTime.friday,
      "sam": DateTime.saturday,
      "dim": DateTime.sunday,
    };

    for (int i = 0; i < joursList.length; i++) {
      final jour = joursList[i].trim();
      final targetWeekday = weekdayMap[jour] ?? DateTime.monday;
      final now = DateTime.now();

      DateTime dateAlarme = DateTime(
        now.year,
        now.month,
        now.day,
        alarme.heure,
        alarme.minute,
      );

      while (dateAlarme.weekday != targetWeekday || dateAlarme.isBefore(now)) {
        dateAlarme = dateAlarme.add(const Duration(days: 1));
      }

      await ServiceNotificationLocale.instance.programmerAlarme(
        id: id + i,
        titre: alarme.titre,
        body: alarme.note == null || alarme.note!.trim().isEmpty
            ? "Alarme ORA"
            : alarme.note!,
        dateTime: dateAlarme,
      );
    }
  }
}
