import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenirFluxNotifications() {
    final ref = _refNotifications();
    if (ref == null) return const Stream.empty();

    return ref.orderBy('createdAt', descending: true).snapshots();
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
