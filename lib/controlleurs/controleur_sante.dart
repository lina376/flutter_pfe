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

    // 1) D'abord on tente d'envoyer les données locales en attente.
    await synchroniserTout();

    // 2) Si une donnée locale existe, elle est prioritaire pour éviter la perte offline.
    final existantLocal = await _local.obtenirParDate(userId: userId, date: date);
    if (existantLocal != null) {
      if (existantLocal.synced) {
        await _recupererDepuisFirebaseSansEcraserLocal(userId: userId, date: date);
        final apresSync = await _local.obtenirParDate(userId: userId, date: date);
        return apresSync ?? existantLocal;
      }
      return existantLocal;
    }

    // 3) Si rien en local, on essaye Firebase. Si internet est coupé, on crée localement.
    try {
      final distant = await _firebase.obtenirParDate(userId: userId, date: date);
      if (distant != null) {
        final local = distant.copyWith(synced: true);
        await _local.sauvegarder(local);
        return local;
      }
    } catch (_) {}

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
    return chargerSemaineDepuis(DateTime.now());
  }

  Future<List<ModeleSante>> chargerSemaineDepuis(DateTime dateReference) async {
    final userId = _userId;

    final debutSemaine = dateReference.subtract(
      Duration(days: dateReference.weekday - 1),
    );

    final finSemaine = debutSemaine.add(const Duration(days: 6));

    final debut = DateFormat('yyyy-MM-dd').format(debutSemaine);
    final fin = DateFormat('yyyy-MM-dd').format(finSemaine);

    // Offline-first: on pousse les modifications locales, puis on récupère Firebase.
    await synchroniserTout();

    try {
      final donneesFirebase = await _firebase.obtenirEntreDates(
        userId: userId,
        debut: debut,
        fin: fin,
      );

      for (final item in donneesFirebase) {
        await _local.sauvegarderDepuisFirebase(item.copyWith(synced: true));
      }
    } catch (_) {
      // Pas d'internet: on garde les données SQLite sans bloquer l'interface.
    }

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

    try {
      await ControleurEau().mettreAJourObjectifDepuisSante(maj);
    } catch (_) {}

    return _local.obtenirParDate(userId: maj.userId, date: maj.date).then((v) => v ?? maj);
  }

  Future<ModeleSante> modifierHumeur(ModeleSante sante, String humeur) async {
    final maj = sante.copyWith(
      humeur: humeur,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);
    return _local.obtenirParDate(userId: maj.userId, date: maj.date).then((v) => v ?? maj);
  }

  Future<ModeleSante> modifierPoids(ModeleSante sante, double poids) async {
    final maj = sante.copyWith(
      poids: poids,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);
    return _local.obtenirParDate(userId: maj.userId, date: maj.date).then((v) => v ?? maj);
  }

  Future<ModeleSante> modifierProfil({
    required ModeleSante sante,
    required int age,
    required double poids,
    required String activite,
  }) async {
    final maj = sante.copyWith(
      age: age,
      poids: double.parse(poids.toStringAsFixed(1)),
      activite: activite,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);

    try {
      await ControleurEau().mettreAJourObjectifDepuisSante(maj);
    } catch (_) {}

    return _local.obtenirParDate(userId: maj.userId, date: maj.date).then((v) => v ?? maj);
  }

  Future<void> synchroniser(ModeleSante sante) async {
    try {
      await _firebase.sauvegarder(sante);
      await _local.sauvegarder(sante.copyWith(synced: true));
    } catch (_) {
      await _local.sauvegarder(sante.copyWith(synced: false));
    }
  }

  Future<void> synchroniserTout() async {
    final userId = _userId;
    final nonSynchronises = await _local.obtenirNonSynchronises(userId);

    for (final item in nonSynchronises) {
      await synchroniser(item);
    }
  }

  Future<void> _recupererDepuisFirebaseSansEcraserLocal({
    required String userId,
    required String date,
  }) async {
    try {
      final distant = await _firebase.obtenirParDate(userId: userId, date: date);
      if (distant != null) {
        await _local.sauvegarderDepuisFirebase(distant.copyWith(synced: true));
      }
    } catch (_) {}
  }

  Future<ModeleSante?> obtenirDernierProfil() async {
    return await chargerAujourdhui();
  }
}
