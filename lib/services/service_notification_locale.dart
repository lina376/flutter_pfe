//init notif demande permission progremme lalarme annuler l allarme
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class ServiceNotificationLocale {
  static final ServiceNotificationLocale instance =
      ServiceNotificationLocale._init();

  ServiceNotificationLocale._init();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

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
      sound: RawResourceAndroidNotificationSound('alarm.mp3'),
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
