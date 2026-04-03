import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/modele_notification.dart';
import '../services/service_notification.dart';

class ControleurNotification {
  final ServiceNotification _service = ServiceNotification();

  Stream<List<ModeleNotification>> obtenirFluxNotifications() {
    return _service.obtenirFluxNotifications();
  }

  Future<void> marquerCommeLu(String id) async {
    await _service.marquerCommeLu(id);
  }

  Future<void> supprimerNotification(String id) async {
    await _service.supprimerNotification(id);
  }

  String formaterDate(dynamic timestamp) {
    if (timestamp is! Timestamp) return '';
    final date = timestamp.toDate();
    return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  String formaterDateDepuisDateTime(DateTime date) {
    return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
