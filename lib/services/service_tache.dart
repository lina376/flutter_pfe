import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../database/base_locale.dart';
import '../models/modele_tache.dart';
import 'service_notification_locale.dart';

class ServiceTache {
  final BaseLocale _baseLocale = BaseLocale.instance;
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => _authentification.currentUser?.uid;

  final StreamController<List<ModeleTache>> _tachesController =
      StreamController<List<ModeleTache>>.broadcast();

  CollectionReference<Map<String, dynamic>>? get _tachesRef {
    final utilisateur = _authentification.currentUser;
    if (utilisateur == null) return null;

    return _firestore
        .collection('users')
        .doc(utilisateur.uid)
        .collection('taches');
  }

  Stream<List<ModeleTache>> obtenirFluxTaches() {
    _rafraichirFluxTaches();
    return _tachesController.stream;
  }

  Stream<List<ModeleTache>> obtenirFluxTachesParDate(DateTime date) async* {
    yield await recupererTachesParDate(date);

    await for (final taches in _tachesController.stream) {
      yield taches.where((t) {
        return t.date.year == date.year &&
            t.date.month == date.month &&
            t.date.day == date.day;
      }).toList();
    }
  }

  Future<List<ModeleTache>> recupererToutesLesTaches() async {
    final db = await _baseLocale.database;

    final result = await db.query(
      'taches',
      where: 'userId = ? AND estSupprimee = ?',
      whereArgs: [_userId ?? '', 0],
      orderBy:
          "date ASC, CASE LOWER(priorite) WHEN 'haute' THEN 1 WHEN 'moyenne' THEN 2 ELSE 3 END ASC, heure ASC",
    );

    return result.map((e) => ModeleTache.fromMap(e)).toList();
  }

  Future<List<ModeleTache>> recupererTachesParDate(DateTime date) async {
    final toutesLesTaches = await recupererToutesLesTaches();

    return toutesLesTaches.where((t) {
      return t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day;
    }).toList();
  }

  Future<void> _insererOuMajLocal(ModeleTache tache) async {
    final db = await _baseLocale.database;
    await db.insert(
      'taches',
      tache.copyWith(userId: _userId ?? '').toLocalMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ModeleTache?> _recupererTacheLocale(String idTache) async {
    final db = await _baseLocale.database;
    final rows = await db.query(
      'taches',
      where: 'userId = ? AND id = ?',
      whereArgs: [_userId ?? '', idTache],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return ModeleTache.fromMap(rows.first);
  }

  Future<List<ModeleTache>> _recupererTachesNonSynchronisees() async {
    final db = await _baseLocale.database;

    final result = await db.query(
      'taches',
      where: 'userId = ? AND estSynchronisee = ?',
      whereArgs: [_userId ?? '', 0],
    );

    return result.map((e) => ModeleTache.fromMap(e)).toList();
  }

  Future<void> _envoyerTacheVersFirebase(ModeleTache tache) async {
    final ref = _tachesRef;
    if (ref == null) return;

    await ref
        .doc(tache.id)
        .set(tache.copyWith(userId: _userId ?? '').toCloudMap())
        .timeout(const Duration(seconds: 5));

    await _insererOuMajLocal(tache.copyWith(estSynchronisee: true));
  }

  Future<void> ajouterTache({
    required String titre,
    required String heure,
    required DateTime date,
    required String categorie,
    String priorite = 'moyenne',
  }) async {
    try {
      final dateSansHeure = DateTime(date.year, date.month, date.day);
      final id = _firestore.collection('tmp').doc().id;

      final tache = ModeleTache(
        id: id,
        userId: _userId ?? '',
        titre: titre,
        heure: heure,
        date: dateSansHeure,
        categorie: categorie,
        priorite: priorite,
        terminee: false,
        estSynchronisee: false,
        estSupprimee: false,
      );

      await _insererOuMajLocal(tache);
      await _rafraichirFluxTaches();

      await ServiceNotificationLocale.instance.programmerNotificationTache(
        idTache: tache.id,
        titre: tache.titre,
        categorie: tache.categorie,
        date: tache.date,
        heure: tache.heure,
      );

      try {
        await _envoyerTacheVersFirebase(tache);
      } catch (e) {
        print('Sync ajout tâche en attente: $e');
      }

      await _rafraichirFluxTaches();
    } catch (e) {
      print('Erreur ajout tâche: $e');
    }
  }

  Future<void> supprimerTache(String idTache) async {
    try {
      await ServiceNotificationLocale.instance.annulerNotificationTache(idTache);
      final db = await _baseLocale.database;

      await db.update(
        'taches',
        {'estSupprimee': 1, 'estSynchronisee': 0},
        where: 'userId = ? AND id = ?',
        whereArgs: [_userId ?? '', idTache],
      );
      await _rafraichirFluxTaches();

      try {
        final ref = _tachesRef;
        if (ref != null) {
          await ref.doc(idTache).delete().timeout(const Duration(seconds: 5));
        }

        await db.delete(
          'taches',
          where: 'userId = ? AND id = ?',
          whereArgs: [_userId ?? '', idTache],
        );
      } catch (e) {
        print('Suppression tâche cloud en attente: $e');
      }

      await _rafraichirFluxTaches();
    } catch (e) {
      print('Erreur suppression tâche: $e');
    }
  }

  Future<void> changerEtatTache({
    required String idTache,
    required bool terminee,
  }) async {
    try {
      final ancienne = await _recupererTacheLocale(idTache);
      if (ancienne == null) return;

      final maj = ancienne.copyWith(
        terminee: terminee,
        estSynchronisee: false,
        estSupprimee: false,
      );

      await _insererOuMajLocal(maj);
      await _rafraichirFluxTaches();

      if (terminee) {
        await ServiceNotificationLocale.instance.annulerNotificationTache(idTache);
      } else {
        await ServiceNotificationLocale.instance.programmerNotificationTache(
          idTache: maj.id,
          titre: maj.titre,
          categorie: maj.categorie,
          date: maj.date,
          heure: maj.heure,
        );
      }

      try {
        await _envoyerTacheVersFirebase(maj);
      } catch (e) {
        print('Sync état tâche en attente: $e');
      }

      await _rafraichirFluxTaches();
    } catch (e) {
      print('Erreur modification état tâche: $e');
    }
  }

  int _rangPriorite(String priorite) {
    switch (priorite.toLowerCase().trim()) {
      case 'haute':
      case 'élevée':
      case 'elevee':
      case 'urgent':
        return 0;
      case 'moyenne':
      case 'normal':
        return 1;
      case 'basse':
      case 'faible':
        return 2;
      default:
        return 1;
    }
  }

  List<ModeleTache> trierParPriorite(List<ModeleTache> taches) {
    final copie = List<ModeleTache>.from(taches);
    copie.sort((a, b) {
      final priorite = _rangPriorite(a.priorite).compareTo(
        _rangPriorite(b.priorite),
      );
      if (priorite != 0) return priorite;
      if (a.heure == '--:--' && b.heure != '--:--') return 1;
      if (a.heure != '--:--' && b.heure == '--:--') return -1;
      return a.heure.compareTo(b.heure);
    });
    return copie;
  }

  Future<List<ModeleTache>> recupererTachesParDateTriees(DateTime date) async {
    final taches = await recupererTachesParDate(date);
    return trierParPriorite(taches);
  }

  Future<ModeleTache?> trouverTacheParTitre(String titreRecherche) async {
    final taches = await recupererToutesLesTaches();

    try {
      return taches.firstWhere(
        (tache) =>
            tache.titre.toLowerCase().trim() ==
            titreRecherche.toLowerCase().trim(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<ModeleTache>> rechercherTachesParTitre(
    String titreRecherche,
  ) async {
    final taches = await recupererToutesLesTaches();

    return taches.where((tache) {
      return tache.titre.toLowerCase().contains(
        titreRecherche.toLowerCase().trim(),
      );
    }).toList();
  }

  Future<void> mettreAJourTache({
    required String idTache,
    required String titre,
    required String heure,
    required DateTime date,
    required String categorie,
    required bool terminee,
    String? priorite,
  }) async {
    try {
      final ancienne = await _recupererTacheLocale(idTache);
      final dateSansHeure = DateTime(date.year, date.month, date.day);

      final tache = ModeleTache(
        id: idTache,
        userId: _userId ?? '',
        titre: titre,
        heure: heure,
        date: dateSansHeure,
        categorie: categorie,
        priorite: priorite ?? ancienne?.priorite ?? 'moyenne',
        terminee: terminee,
        estSynchronisee: false,
        estSupprimee: false,
      );

      await _insererOuMajLocal(tache);
      await _rafraichirFluxTaches();

      await ServiceNotificationLocale.instance.annulerNotificationTache(idTache);
      if (!terminee) {
        await ServiceNotificationLocale.instance.programmerNotificationTache(
          idTache: tache.id,
          titre: tache.titre,
          categorie: tache.categorie,
          date: tache.date,
          heure: tache.heure,
        );
      }

      try {
        await _envoyerTacheVersFirebase(tache);
      } catch (e) {
        print('Sync mise à jour tâche en attente: $e');
      }

      await _rafraichirFluxTaches();
    } catch (e) {
      print('Erreur mise à jour tâche: $e');
    }
  }

  Future<void> synchroniserDepuisFirebase() async {
    try {
      final ref = _tachesRef;
      if (ref == null) return;

      final snapshot = await ref.get().timeout(const Duration(seconds: 8));

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final locale = await _recupererTacheLocale(doc.id);

          // Important: ne pas écraser une modification locale pas encore synchronisée.
          if (locale != null && !locale.estSynchronisee) continue;

          final dateTexte = (data['date'] ?? '').toString();
          if (dateTexte.isEmpty) continue;

          final tache = ModeleTache(
            id: doc.id,
            userId: _userId ?? '',
            titre: (data['titre'] ?? '').toString(),
            heure: (data['heure'] ?? '--:--').toString(),
            date: DateTime.parse(dateTexte),
            categorie: (data['categorie'] ?? 'Autre').toString(),
            priorite: (data['priorite'] ?? 'moyenne').toString(),
            terminee: (data['terminee'] ?? false) == true,
            estSynchronisee: true,
            estSupprimee: false,
          );

          await _insererOuMajLocal(tache);
        } catch (e) {
          print('Erreur lecture tâche cloud ${doc.id}: $e');
        }
      }

      await _rafraichirFluxTaches();
    } catch (e) {
      print('Erreur synchronisation depuis Firebase: $e');
    }
  }

  Future<void> synchroniserVersFirebase() async {
    try {
      final ref = _tachesRef;
      if (ref == null) return;

      final nonSync = await _recupererTachesNonSynchronisees();
      final db = await _baseLocale.database;

      for (final t in nonSync) {
        try {
          if (t.estSupprimee) {
            await ref.doc(t.id).delete().timeout(const Duration(seconds: 5));
            await db.delete(
              'taches',
              where: 'userId = ? AND id = ?',
              whereArgs: [_userId ?? '', t.id],
            );
          } else {
            await ref
                .doc(t.id)
                .set(t.copyWith(userId: _userId ?? '').toCloudMap())
                .timeout(const Duration(seconds: 5));
            await _insererOuMajLocal(t.copyWith(estSynchronisee: true));
          }
        } catch (e) {
          print('Tâche ${t.id} gardée en attente de synchronisation: $e');
        }
      }

      await _rafraichirFluxTaches();
    } catch (e) {
      print('Erreur synchronisation vers Firebase: $e');
    }
  }

  Future<void> _rafraichirFluxTaches() async {
    final taches = await recupererToutesLesTaches();
    if (!_tachesController.isClosed) {
      _tachesController.add(taches);
    }
  }

  void dispose() {
    _tachesController.close();
  }
}
