import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/modele_notification.dart';

class ServiceNotification {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>? _refNotifications() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications');
  }

  Stream<List<ModeleNotification>> obtenirFluxNotifications() {
    final ref = _refNotifications();
    if (ref == null) return Stream.value([]);

    return ref
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ModeleNotification.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> marquerCommeLu(String id) async {
    final ref = _refNotifications();
    if (ref == null) return;

    await ref.doc(id).update({'isRead': true});
  }

  Future<void> supprimerNotification(String id) async {
    final ref = _refNotifications();
    if (ref == null) return;

    await ref.doc(id).delete();
  }

  Future<void> sendWaterReminder({required int waterMl}) async {
    final ref = _refNotifications();
    if (ref == null) return;

    await ref.add({
      'title': 'Rappel hydratation',
      'body': 'Il est temps de boire $waterMl ml d’eau.',
      'type': 'water',
      'iconType': 'water',
      'isRead': false,
      'createdAt': Timestamp.now(),
      'scheduledFor': Timestamp.now(),
      'data': {'waterMl': waterMl},
    });
  }

  Future<void> sendDoctorAppointmentReminder({
    required String doctorName,
    required DateTime appointmentDate,
  }) async {
    final ref = _refNotifications();
    if (ref == null) return;

    await ref.add({
      'title': 'Rendez-vous médical',
      'body': 'Vous avez un rendez-vous avec $doctorName.',
      'type': 'doctor',
      'iconType': 'doctor',
      'isRead': false,
      'createdAt': Timestamp.now(),
      'scheduledFor': Timestamp.fromDate(appointmentDate),
      'data': {'doctorName': doctorName},
    });
  }
Stream<int> compterNonLues() {
  final ref = _refNotifications();
  if (ref == null) return Stream.value(0);

  return ref
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((s) => s.docs.length);
}
Future<void> creerNotification({
  required String title,
  required String body,
  required String type,
  required String iconType,
  required DateTime scheduledFor,
  Map<String, dynamic> data = const {},
}) async {
  final ref = _refNotifications();
  if (ref == null) return;

  await ref.add({
    'title': title,
    'body': body,
    'type': type,
    'iconType': iconType,
    'isRead': false,
    'createdAt': Timestamp.now(),
    'scheduledFor': Timestamp.fromDate(scheduledFor),
    'data': data,
  });
}
Future<bool> notificationExisteAujourdHui({
  required String type,
}) async {
  final ref = _refNotifications();
  if (ref == null) return false;

  final aujourdHui = DateTime.now();

  final debut = DateTime(
    aujourdHui.year,
    aujourdHui.month,
    aujourdHui.day,
  );

  final fin = debut.add(const Duration(days: 1));

  final snapshot = await ref
      .where('type', isEqualTo: type)
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(debut))
      .where('createdAt', isLessThan: Timestamp.fromDate(fin))
      .get();

  return snapshot.docs.isNotEmpty;
}
  Future<void> sendMedicineReminder({
    required String medicineName,
    required DateTime reminderTime,
  }) async {
    final ref = _refNotifications();
    if (ref == null) return;

    await ref.add({
      'title': 'Rappel médicament',
      'body': 'N’oubliez pas de prendre $medicineName.',
      'type': 'medicine',
      'iconType': 'medicine',
      'isRead': false,
      'createdAt': Timestamp.now(),
      'scheduledFor': Timestamp.fromDate(reminderTime),
      'data': {'medicineName': medicineName},
    });
  }
}
