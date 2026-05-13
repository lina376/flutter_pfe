import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ora/models/modele_eau.dart';
import 'package:ora/services/service_eau_local.dart';
import 'package:ora/services/service_eau_firebase.dart';
import 'package:ora/controlleurs/controleur_sante.dart';

class ControleurEau {
  final ServiceEauLocal _local = ServiceEauLocal.instance;
  final ServiceEauFirebase _firebase = ServiceEauFirebase();
  final FirebaseAuth _authentification = FirebaseAuth.instance;

  String get dateAujourdhui {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  String get _userId {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) {
      throw Exception('Utilisateur non connecté');
    }
    return utilisateur.uid;
  }

  String clePreference(String nom) => '${_userId}_$nom';

  int calculerObjectifVerres({
    required int age,
    required double poids,
    required String activite,
  }) {
    double litres = poids * 0.035;

    if (age < 12) {
      litres = poids * 0.03;
    }

    if (activite.toLowerCase() == 'sportif') {
      litres += 0.5;
    }

    if (activite.toLowerCase() == 'faible') {
      litres -= 0.2;
    }

    litres = litres.clamp(1.0, 4.0);

    return (litres / 0.25).round();
  }

  Future<int> obtenirObjectifHydratation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(clePreference('objectif_hydratation')) ??
        calculerObjectifVerres(age: 22, poids: 70, activite: 'normale');
  }

  Future<void> mettreAJourObjectifDepuisSante(profilSante) async {
    final eau = await chargerAujourdhui();

    final nouvelObjectif = calculerObjectifVerres(
      age: profilSante.age,
      poids: profilSante.poids,
      activite: profilSante.activite,
    );

    final maj = eau.copyWith(
      objectif: nouvelObjectif,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);
  }

  Future<List<ModeleEau>> chargerSemaineDepuis(DateTime dateReference) async {
    final userId = _userId;

    final debutSemaine = dateReference.subtract(
      Duration(days: dateReference.weekday - 1),
    );

    final finSemaine = debutSemaine.add(const Duration(days: 6));

    final debut = DateFormat('yyyy-MM-dd').format(debutSemaine);
    final fin = DateFormat('yyyy-MM-dd').format(finSemaine);

    // Offline-first: on pousse d'abord les changements locaux, puis on récupère Firebase.
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
      // Pas d'internet: on garde SQLite sans bloquer l'interface.
    }

    return _local.obtenirEntreDates(userId: userId, debut: debut, fin: fin);
  }

  Future<ModeleEau> chargerAujourdhui() async {
    final utilisateurId = _userId;
    final date = dateAujourdhui;

    // 1) Envoyer les données locales en attente si internet est revenu.
    await synchroniserTout();

    // 2) SQLite reste prioritaire si l'utilisateur a modifié offline.
    final existant = await _local.obtenirParDate(utilisateurId, date);
    if (existant != null) {
      if (existant.synced) {
        await _recupererDepuisFirebaseSansEcraserLocal(
          userId: utilisateurId,
          date: date,
        );
      }

      final apresSync = await _local.obtenirParDate(utilisateurId, date);
      final local = apresSync ?? existant;
      return _mettreAJourObjectifSiNecessaire(local);
    }

    // 3) Si rien en local, on essaye Firebase. Si internet est coupé, on crée localement.
    try {
      final distant = await _firebase.obtenirParDate(
        userId: utilisateurId,
        date: date,
      );
      if (distant != null) {
        final local = distant.copyWith(synced: true);
        await _local.sauvegarder(local);
        return _mettreAJourObjectifSiNecessaire(local);
      }
    } catch (_) {}

    final profilSante = await ControleurSante().obtenirDernierProfil();

    final objectif = calculerObjectifVerres(
      age: profilSante?.age ?? 20,
      poids: profilSante?.poids ?? 65.0,
      activite: profilSante?.activite ?? 'Normale',
    );

    final nouveau = ModeleEau(
      id: '$utilisateurId-$date',
      userId: utilisateurId,
      date: date,
      verres: 0,
      objectif: objectif,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(nouveau);
    await synchroniser(nouveau);

    return nouveau;
  }

  Future<List<ModeleEau>> chargerSemaine() async {
    return chargerSemaineDepuis(DateTime.now());
  }

  Future<ModeleEau> ajouterVerre(ModeleEau eau) async {
    final nouveauNombre = eau.verres < eau.objectif
        ? eau.verres + 1
        : eau.verres;

    final maj = eau.copyWith(
      userId: _userId,
      verres: nouveauNombre,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);

    return _local.obtenirParDate(maj.userId, maj.date).then((v) => v ?? maj);
  }

  Future<ModeleEau> retirerVerre(ModeleEau eau) async {
    final nouveauNombre = eau.verres > 0 ? eau.verres - 1 : 0;

    final maj = eau.copyWith(
      userId: _userId,
      verres: nouveauNombre,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);

    return _local.obtenirParDate(maj.userId, maj.date).then((v) => v ?? maj);
  }

  Future<void> synchroniser(ModeleEau eau) async {
    final donnees = eau.copyWith(userId: _userId);
    try {
      await _firebase.sauvegarder(donnees);
      await _local.sauvegarder(donnees.copyWith(synced: true));
    } catch (_) {
      await _local.sauvegarder(donnees.copyWith(synced: false));
    }
  }

  Future<void> sauvegarderEtSynchroniser(ModeleEau eau) async {
    final donnees = eau.copyWith(userId: _userId, synced: false);
    await _local.sauvegarder(donnees);
    await synchroniser(donnees);
  }

  Future<void> synchroniserTout() async {
    final nonSynces = await _local.obtenirNonSynchronises(_userId);

    for (final item in nonSynces) {
      await synchroniser(item);
    }
  }

  Future<void> modifierObjectifAujourdhui(int nouvelObjectif) async {
    final eau = await chargerAujourdhui();

    final maj = eau.copyWith(
      objectif: nouvelObjectif,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);
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

  Future<ModeleEau> _mettreAJourObjectifSiNecessaire(ModeleEau eau) async {
    final profilSante = await ControleurSante().obtenirDernierProfil();

    final objectifActuel = calculerObjectifVerres(
      age: profilSante?.age ?? 20,
      poids: profilSante?.poids ?? 65.0,
      activite: profilSante?.activite ?? 'Normale',
    );

    if (eau.objectif == objectifActuel) return eau;

    final maj = eau.copyWith(
      objectif: objectifActuel,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);

    return _local.obtenirParDate(maj.userId, maj.date).then((v) => v ?? maj);
  }
}
