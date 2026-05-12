import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ora/models/modele_eau.dart';
import 'package:ora/services/service_eau_local.dart';
import 'package:ora/services/service_eau_firebase.dart';
import 'package:ora/controlleurs/controleur_sante.dart';
import 'package:ora/services/service_notification.dart';
import 'package:ora/services/service_notification_locale.dart';
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

    if (activite == 'sportif') {
      litres += 0.5;
    }

    if (activite == 'faible') {
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

  Future<List<ModeleEau>> chargerSemaineDepuis(
  DateTime dateReference,
) async {
  final userId = _userId;

  final debutSemaine = dateReference.subtract(
    Duration(days: dateReference.weekday - 1),
  );

  final finSemaine = debutSemaine.add(const Duration(days: 6));

  final debut = DateFormat('yyyy-MM-dd').format(debutSemaine);
  final fin = DateFormat('yyyy-MM-dd').format(finSemaine);

  final donneesFirebase = await _firebase.obtenirEntreDates(
    userId: userId,
    debut: debut,
    fin: fin,
  );

  for (final item in donneesFirebase) {
    await _local.sauvegarder(item.copyWith(synced: true));
  }
try {
  final donneesFirebase = await _firebase
      .obtenirEntreDates(
        userId: userId,
        debut: debut,
        fin: fin,
      )
      .timeout(const Duration(seconds: 5));

  for (final item in donneesFirebase) {
    await _local.sauvegarder(item.copyWith(synced: true));
  }
} catch (e) {
  print("Erreur chargement eau semaine Firebase: $e");
}
  return _local.obtenirEntreDates(
    userId: userId,
    debut: debut,
    fin: fin,
  );
}

  Future<ModeleEau> chargerAujourdhui() async {
    final utilisateurId = _userId;
    final date = dateAujourdhui;
    final existant = await _local.obtenirParDate(utilisateurId, date);
    if (existant != null) {
      final profilSante = await ControleurSante().obtenirDernierProfil();

      final objectifActuel = calculerObjectifVerres(
        age: profilSante?.age ?? 20,
        poids: profilSante?.poids ?? 65.0,
        activite: profilSante?.activite ?? 'Normale',
      );

      if (existant.objectif != objectifActuel) {
        final maj = existant.copyWith(
          objectif: objectifActuel,
          updatedAt: DateTime.now(),
          synced: false,
        );

        await _local.sauvegarder(maj);
        await synchroniser(maj);

        return maj;
      }
if (existant.verres < existant.objectif) {
  await ServiceNotification().creerNotification(
    title: 'Rappel hydratation',
    body: 'Tu n’as pas encore atteint ton objectif. Bois un verre d’eau 💧',
    type: 'water',
    iconType: 'water',
    scheduledFor: DateTime.now(),
  );
}
      return existant;
    }
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
  final userId = _userId;
  final maintenant = DateTime.now();

  final debutSemaine = maintenant.subtract(
    Duration(days: maintenant.weekday - 1),
  );

  final finSemaine = debutSemaine.add(const Duration(days: 6));

  final debut = DateFormat('yyyy-MM-dd').format(debutSemaine);
  final fin = DateFormat('yyyy-MM-dd').format(finSemaine);

  try {
    final donneesFirebase = await _firebase
        .obtenirEntreDates(
          userId: userId,
          debut: debut,
          fin: fin,
        )
        .timeout(const Duration(seconds: 5));

    for (final item in donneesFirebase) {
      await _local.sauvegarder(item.copyWith(synced: true));
    }
  } catch (e) {
    print("Erreur chargement eau Firebase: $e");
  }

  return _local.obtenirEntreDates(
    userId: userId,
    debut: debut,
    fin: fin,
  );
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
    if (maj.verres < maj.objectif) {
  await ServiceNotification().creerNotification(
    title: 'Rappel hydratation',
    body:
        'Tu n’as pas encore atteint ton objectif. Bois un verre d’eau 💧',
    type: 'water',
    iconType: 'water',
    scheduledFor: DateTime.now(),
  );
}

await ServiceNotificationLocale.instance.afficherNotification(
  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  titre: 'Rappel hydratation',
  corps: 'Bois un verre d’eau 💧',
);
    return maj;
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

    return maj;
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
    final donnees = eau.copyWith(userId: _userId);
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
}
