import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ora/models/modele_sante.dart';
import 'package:ora/services/service_sante_local.dart';
import 'package:ora/services/service_sante_firebase.dart';
import 'package:ora/controlleurs/controleur_eau.dart';

class ControleurSante {
  final ServiceSanteLocal _local = ServiceSanteLocal.instance;
  final ServiceSanteFirebase _firebase = ServiceSanteFirebase();

  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    return user.uid;
  }

  String get dateAujourdhui {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<ModeleSante> chargerAujourdhui() async {
    final userId = _userId;
    final date = dateAujourdhui;

    final existant = await _local.obtenirParDate(userId: userId, date: date);

    if (existant != null) return existant;

    final nouveau = ModeleSante(
      id: '$userId-$date',
      userId: userId,
      date: date,
      age: 20,
      poids: 65.0,
      activite: 'Normale',
      heuresSommeil: 7.0,
      humeur: 'Heureux',
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(nouveau);
    await synchroniser(nouveau);

    return nouveau;
  }

  Future<List<ModeleSante>> chargerSemaine() async {
    final userId = _userId;
    final maintenant = DateTime.now();

    final debutSemaine = maintenant.subtract(
      Duration(days: maintenant.weekday - 1),
    );

    final finSemaine = debutSemaine.add(const Duration(days: 6));

    final debut = DateFormat('yyyy-MM-dd').format(debutSemaine);
    final fin = DateFormat('yyyy-MM-dd').format(finSemaine);

    return _local.obtenirEntreDates(userId: userId, debut: debut, fin: fin);
  }

  Future<ModeleSante> modifierSommeil(ModeleSante sante, double heures) async {
    final maj = sante.copyWith(
      heuresSommeil: heures,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);
    await ControleurEau().mettreAJourObjectifDepuisSante(maj);
    return maj;
  }

  Future<ModeleSante> modifierHumeur(ModeleSante sante, String humeur) async {
    final maj = sante.copyWith(
      humeur: humeur,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);
    return maj;
  }

  Future<ModeleSante> modifierPoids(ModeleSante sante, double poids) async {
    final maj = sante.copyWith(
      poids: poids,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);
    return maj;
  }

  Future<ModeleSante> modifierProfil({
    required ModeleSante sante,
    required int age,
    required double poids,
    required String activite,
  }) async {
    final maj = sante.copyWith(
      age: age,
      poids: poids,
      activite: activite,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);
    return maj;
  }

  Future<void> synchroniser(ModeleSante sante) async {
    try {
      await _firebase.sauvegarder(sante);
      await _local.sauvegarder(sante.copyWith(synced: true));
    } catch (_) {
      await _local.sauvegarder(sante.copyWith(synced: false));
    }
  }

  Future<List<ModeleSante>> chargerSemaineDepuis(DateTime dateReference) async {
    final userId = _userId;

    final debutSemaine = dateReference.subtract(
      Duration(days: dateReference.weekday - 1),
    );

    final finSemaine = debutSemaine.add(const Duration(days: 6));

    final debut = DateFormat('yyyy-MM-dd').format(debutSemaine);
    final fin = DateFormat('yyyy-MM-dd').format(finSemaine);

    return _local.obtenirEntreDates(userId: userId, debut: debut, fin: fin);
  }

  Future<ModeleSante?> obtenirDernierProfil() async {
    return await chargerAujourdhui();
  }

  Future<void> synchroniserTout() async {
    final userId = _userId;
    final nonSynchronises = await _local.obtenirNonSynchronises(userId);

    for (final item in nonSynchronises) {
      await synchroniser(item);
    }
  }
}
