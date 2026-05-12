//init notif demande permission progremme lalarme annuler l allarme
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class ServiceNotificationLocale {
  static final ServiceNotificationLocale instance =
      ServiceNotificationLocale._init();

  ServiceNotificationLocale._init();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  String messageTacheParCategorie(String categorie, String titre) {
    switch (categorie.toLowerCase()) {
      case "sport":
        return "Prépare-toi pour ton activité sportive : $titre.";
      case "études":
        return "C’est bientôt le moment de réviser : $titre.";
      case "travail":
        return "Rappel travail : $titre commence bientôt.";
      case "santé":
        return "Rappel santé : n’oublie pas $titre.";
      case "rendez-vous":
        return "Tu as bientôt un rendez-vous : $titre.";
      case "courses":
        return "N’oublie pas tes courses : $titre.";
      default:
        return "Rappel : $titre commence bientôt.";
    }
  }

  Future<void> programmerNotificationTache({
    required String idTache,
    required String titre,
    required String categorie,
    required DateTime date,
    required String heure,
  }) async {
    if (heure == "--:--" || !heure.contains(":")) return;

    final parts = heure.split(":");
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);

    if (h == null || m == null) return;

    final dateTache = DateTime(date.year, date.month, date.day, h, m);

    // notification 10 minutes avant
    final dateNotification = dateTache.subtract(const Duration(minutes: 10));

    if (dateNotification.isBefore(DateTime.now())) return;

    final idNotification = idTache.hashCode.abs();

    const androidDetails = AndroidNotificationDetails(
      'ora_task_channel',
      'Rappels des tâches ORA',
      channelDescription: 'Notifications intelligentes des tâches ORA',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      idNotification,
      "Rappel tâche",
      messageTacheParCategorie(categorie, titre),
      tz.TZDateTime.from(dateNotification, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> annulerNotificationTache(String idTache) async {
    final idNotification = idTache.hashCode.abs();
    await _plugin.cancel(idNotification);
  }

  Future<void> initialiser() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> programmerAlarme({
    required int id,
    required String titre,
    required String body,
    required DateTime dateTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'ora_alarm_channel',
      'Alarmes ORA',
      channelDescription: 'Notifications des alarmes ORA',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
      enableVibration: true,
      fullScreenIntent: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      titre,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> annulerAlarme(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> programmerNotificationTrajet({
    required String idTrajet,
    required String destination,
    required DateTime dateSortie,
    required String message,
  }) async {
    if (dateSortie.isBefore(DateTime.now())) return;

    final idNotification = idTrajet.hashCode.abs();

    const androidDetails = AndroidNotificationDetails(
      'ora_trip_channel',
      'Rappels trajet ORA',
      channelDescription: 'Notifications météo et sortie pour les trajets ORA',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      idNotification,
      "ORA trajet vers $destination",
      message,
      tz.TZDateTime.from(dateSortie, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> annulerNotificationTrajet(String idTrajet) async {
    await _plugin.cancel(idTrajet.hashCode.abs());
  }
Future<void> afficherNotification({
  required int id,
  required String titre,
  required String corps,
}) async {
  await _plugin.show(
    id,
    titre,
    corps,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'ora_channel',
        'ORA Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}
Future<void> programmerRappelQuotidien({
  required int id,
  required String titre,
  required String corps,
  required int heure,
  required int minute,
}) async {
  final maintenant = tz.TZDateTime.now(tz.local);

  var dateProgramme = tz.TZDateTime(
    tz.local,
    maintenant.year,
    maintenant.month,
    maintenant.day,
    heure,
    minute,
  );

  if (dateProgramme.isBefore(maintenant)) {
    dateProgramme = dateProgramme.add(const Duration(days: 1));
  }

  await _plugin.zonedSchedule(
    id,
    titre,
    corps,
    dateProgramme,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'ora_rappels',
        'Rappels ORA',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,

  );
}
  Future<void> testerNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'ora_alarm_channel',
      'Alarmes ORA',
      channelDescription: 'Notifications des alarmes ORA',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(999, 'Test ORA', 'Notification immédiate', details);
  }
}
