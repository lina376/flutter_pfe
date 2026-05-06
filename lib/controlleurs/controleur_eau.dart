import 'package:intl/intl.dart';
import 'package:ora/models/modele_eau.dart';
import 'package:ora/services/service_eau_local.dart';
import 'package:ora/services/service_eau_firebase.dart';

class ControleurEau {
  final ServiceEauLocal _local = ServiceEauLocal.instance;
  final ServiceEauFirebase _firebase = ServiceEauFirebase();

  String get dateAujourdhui {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  int calculerObjectifVerres({
    required int age,
    required double poids,
    required String activite,
  }) {
    double litres = poids * 0.035;

    if (age < 12) {
      litres = poids * 0.03;
    }

    if (activite == 'sportif') {
      litres += 0.5;
    }

    if (activite == 'faible') {
      litres -= 0.2;
    }

    litres = litres.clamp(1.0, 4.0);

    return (litres / 0.25).round();
  }

  Future<ModeleEau> chargerAujourdhui() async {
    final date = dateAujourdhui;
    final existant = await _local.obtenirParDate(date);

    if (existant != null) return existant;

    final nouveau = ModeleEau(
      id: date,
      date: date,
      verres: 0,
      objectif: calculerObjectifVerres(age: 22, poids: 70, activite: 'normale'),
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(nouveau);
    await synchroniser(nouveau);

    return nouveau;
  }

  Future<List<ModeleEau>> chargerSemaine() async {
    final maintenant = DateTime.now();

    final debutSemaine = maintenant.subtract(
      Duration(days: maintenant.weekday - 1),
    );

    final finSemaine = debutSemaine.add(const Duration(days: 6));

    final debut = DateFormat('yyyy-MM-dd').format(debutSemaine);
    final fin = DateFormat('yyyy-MM-dd').format(finSemaine);

    return _local.obtenirEntreDates(debut, fin);
  }

  Future<ModeleEau> ajouterVerre(ModeleEau eau) async {
    final nouveauNombre = eau.verres < eau.objectif
        ? eau.verres + 1
        : eau.verres;

    final maj = eau.copyWith(
      verres: nouveauNombre,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);

    return maj;
  }

  Future<ModeleEau> retirerVerre(ModeleEau eau) async {
    final nouveauNombre = eau.verres > 0 ? eau.verres - 1 : 0;

    final maj = eau.copyWith(
      verres: nouveauNombre,
      updatedAt: DateTime.now(),
      synced: false,
    );

    await _local.sauvegarder(maj);
    await synchroniser(maj);

    return maj;
  }

  Future<void> synchroniser(ModeleEau eau) async {
    try {
      await _firebase.sauvegarder(eau);
      await _local.sauvegarder(eau.copyWith(synced: true));
    } catch (_) {
      await _local.sauvegarder(eau.copyWith(synced: false));
    }
  }

  Future<void> sauvegarderEtSynchroniser(ModeleEau eau) async {
    await _local.sauvegarder(eau);
    await synchroniser(eau);
  }

  Future<void> synchroniserTout() async {
    final nonSynces = await _local.obtenirNonSynchronises();

    for (final item in nonSynces) {
      await synchroniser(item);
    }
  }
}
