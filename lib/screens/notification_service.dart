import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _notificationsRef(
    String uid,
  ) {
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  static Future<void> addNotification({
    required String type,
    required String title,
    required String body,
    required String iconType,
    DateTime? scheduledFor,
    Map<String, dynamic>? data,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _notificationsRef(user.uid).add({
      'type': type,
      'title': title,
      'body': body,
      'iconType': iconType,
      'createdAt': Timestamp.now(),
      'scheduledFor': scheduledFor != null
          ? Timestamp.fromDate(scheduledFor)
          : Timestamp.now(),
      'isRead': false,
      'data': data ?? {},
    });
  }

  static Future<void> markAsRead(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _notificationsRef(
      user.uid,
    ).doc(notificationId).update({'isRead': true});
  }

  static Future<void> deleteNotification(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _notificationsRef(user.uid).doc(notificationId).delete();
  }

  static Future<void> sendWaterReminder({required int waterMl}) async {
    await addNotification(
      type: 'water',
      title: 'Hydratation',
      body: 'Vous n’avez pas beaucoup bu aujourd’hui. Pensez à boire de l’eau.',
      iconType: 'water',
      data: {'waterMl': waterMl},
    );
  }

  static Future<void> sendDoctorAppointmentReminder({
    required String doctorName,
    required DateTime appointmentDate,
  }) async {
    await addNotification(
      type: 'doctor',
      title: 'Rappel rendez-vous',
      body:
          'Vous avez un rendez-vous chez $doctorName à ${appointmentDate.hour.toString().padLeft(2, '0')}:${appointmentDate.minute.toString().padLeft(2, '0')}.',
      iconType: 'doctor',
      scheduledFor: appointmentDate,
      data: {
        'doctorName': doctorName,
        'appointmentTime': appointmentDate.toIso8601String(),
      },
    );
  }

  static Future<void> sendMedicineReminder({
    required String medicineName,
    required DateTime reminderTime,
  }) async {
    await addNotification(
      type: 'medicine',
      title: 'Rappel médicament',
      body: 'C’est le moment de prendre votre médicament : $medicineName.',
      iconType: 'medicine',
      scheduledFor: reminderTime,
      data: {'medicineName': medicineName},
    );
  }

  static Future<void> sendCustomHealthReminder({
    required String title,
    required String body,
    required String iconType,
    DateTime? scheduledFor,
    Map<String, dynamic>? data,
  }) async {
    await addNotification(
      type: 'custom',
      title: title,
      body: body,
      iconType: iconType,
      scheduledFor: scheduledFor,
      data: data,
    );
  }
}
