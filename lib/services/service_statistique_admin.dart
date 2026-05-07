import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ora/models/modele_statistique_admin.dart';

class ServiceStatistiqueAdmin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ModeleStatistiqueAdmin> chargerStatistiques(String periode) async {
    final utilisateursSnapshot = await _firestore.collection('users').get();
    final totalUtilisateurs = utilisateursSnapshot.docs
        .where((doc) => (doc.data()['role'] ?? 'user') != 'admin')
        .length;

    final plage = _plageDates(periode);

    final eauSnapshot = await _firestore.collectionGroup('eau').get();
    final sportSnapshot = await _firestore.collectionGroup('sport').get();
    final conversationSnapshot = await _firestore.collectionGroup('conversations').get();

    final utilisateursEau = <String>{};
    for (final doc in eauSnapshot.docs) {
      final data = doc.data();
      final date = (data['date'] ?? '').toString();
      final verres = _convertirInt(data['verres']);
      final objectif = _convertirInt(data['objectif'], defaut: 12);
      final uid = _extraireUid(doc.reference);

      if (uid.isNotEmpty && _dateDansPeriode(date, plage) && verres >= objectif) {
        utilisateursEau.add(uid);
      }
    }

    final utilisateursSport = <String>{};
    for (final doc in sportSnapshot.docs) {
      final data = doc.data();
      final date = (data['date'] ?? '').toString();
      final minutes = _convertirInt(data['minutes']);
      final uid = _extraireUid(doc.reference);

      if (uid.isNotEmpty && _dateDansPeriode(date, plage) && minutes > 0) {
        utilisateursSport.add(uid);
      }
    }

    final utilisateursChat = <String>{};
    for (final doc in conversationSnapshot.docs) {
      final data = doc.data();
      final uid = _extraireUid(doc.reference);
      final dateMaj = data['dateMaj'];

      if (uid.isEmpty) continue;

      if (dateMaj is Timestamp) {
        final date = DateFormat('yyyy-MM-dd').format(dateMaj.toDate());
        if (_dateDansPeriode(date, plage)) utilisateursChat.add(uid);
      } else {
        utilisateursChat.add(uid);
      }
    }

    return ModeleStatistiqueAdmin(
      totalUtilisateurs: totalUtilisateurs,
      utilisateursEauObjectif: utilisateursEau.length,
      utilisateursSport: utilisateursSport.length,
      utilisateursChat: utilisateursChat.length,
      periode: periode,
    );
  }

  ({DateTime debut, DateTime fin}) _plageDates(String periode) {
    final maintenant = DateTime.now();
    final aujourdhui = DateTime(maintenant.year, maintenant.month, maintenant.day);

    if (periode == 'semaine') {
      final debut = aujourdhui.subtract(Duration(days: aujourdhui.weekday - 1));
      return (debut: debut, fin: aujourdhui);
    }

    if (periode == 'mois') {
      return (debut: DateTime(aujourdhui.year, aujourdhui.month, 1), fin: aujourdhui);
    }

    return (debut: aujourdhui, fin: aujourdhui);
  }

  bool _dateDansPeriode(String dateTexte, ({DateTime debut, DateTime fin}) plage) {
    final date = DateTime.tryParse(dateTexte);
    if (date == null) return false;

    final jour = DateTime(date.year, date.month, date.day);
    return !jour.isBefore(plage.debut) && !jour.isAfter(plage.fin);
  }

  String _extraireUid(DocumentReference<Map<String, dynamic>> reference) {
    final parentUtilisateur = reference.parent.parent;
    if (parentUtilisateur == null) return '';
    return parentUtilisateur.id;
  }

  int _convertirInt(dynamic valeur, {int defaut = 0}) {
    if (valeur is int) return valeur;
    if (valeur is double) return valeur.round();
    return int.tryParse((valeur ?? '').toString()) ?? defaut;
  }
}
