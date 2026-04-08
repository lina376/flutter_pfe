import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../database/base_locale.dart';
import '../models/modele_tache.dart';

class ServiceTache {
  final BaseLocale _baseLocale = BaseLocale.instance;
  final FirebaseAuth _authentification = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      where: 'estSupprimee = ?',
      whereArgs: [0],
      orderBy: 'date ASC, heure ASC',
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
      tache.toLocalMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ModeleTache>> _recupererTachesNonSynchronisees() async {
    final db = await _baseLocale.database;

    final result = await db.query(
      'taches',
      where: 'estSynchronisee = ?',
      whereArgs: [0],
    );

    return result.map((e) => ModeleTache.fromMap(e)).toList();
  }

  Future<void> ajouterTache({
    required String titre,
    required String heure,
    required DateTime date,
  }) async {
    try {
      final dateSansHeure = DateTime(date.year, date.month, date.day);
      final id = _firestore.collection('tmp').doc().id;

      final tache = ModeleTache(
        id: id,
        titre: titre,
        heure: heure,
        date: dateSansHeure,
        terminee: false,
        estSynchronisee: false,
        estSupprimee: false,
      );

      await _insererOuMajLocal(tache);

      try {
        final ref = _tachesRef;
        if (ref != null) {
          await ref
              .doc(id)
              .set(tache.toCloudMap())
              .timeout(const Duration(seconds: 2));

          await _insererOuMajLocal(tache.copyWith(estSynchronisee: true));
        }
      } catch (_) {}

      await _rafraichirFluxTaches();
    } catch (e) {
      print('❌ Erreur ajout tâche: $e');
    }
  }

  Future<void> supprimerTache(String idTache) async {
    try {
      final db = await _baseLocale.database;

      await db.update(
        'taches',
        {'estSupprimee': 1, 'estSynchronisee': 0},
        where: 'id = ?',
        whereArgs: [idTache],
      );

      try {
        final ref = _tachesRef;
        if (ref != null) {
          await ref.doc(idTache).delete().timeout(const Duration(seconds: 2));
        }

        await db.delete('taches', where: 'id = ?', whereArgs: [idTache]);
      } catch (_) {}

      await _rafraichirFluxTaches();
    } catch (e) {
      print('❌ Erreur suppression tâche: $e');
    }
  }

  Future<void> changerEtatTache({
    required String idTache,
    required bool terminee,
  }) async {
    try {
      final db = await _baseLocale.database;

      final rows = await db.query(
        'taches',
        where: 'id = ?',
        whereArgs: [idTache],
        limit: 1,
      );

      if (rows.isEmpty) return;

      final ancienne = ModeleTache.fromMap(rows.first);
      final maj = ancienne.copyWith(terminee: terminee, estSynchronisee: false);

      await _insererOuMajLocal(maj);

      try {
        final ref = _tachesRef;
        if (ref != null) {
          await ref
              .doc(idTache)
              .set(maj.toCloudMap())
              .timeout(const Duration(seconds: 2));

          await _insererOuMajLocal(maj.copyWith(estSynchronisee: true));
        }
      } catch (_) {}

      await _rafraichirFluxTaches();
    } catch (e) {
      print('❌ Erreur modification état tâche: $e');
    }
  }

  Future<void> synchroniserDepuisFirebase() async {
    try {
      final ref = _tachesRef;
      if (ref == null) return;

      final snapshot = await ref.get();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final tache = ModeleTache(
          id: doc.id,
          titre: (data['titre'] ?? '').toString(),
          heure: (data['heure'] ?? '--:--').toString(),
          date: DateTime.parse(data['date']),
          terminee: (data['terminee'] ?? false) == true,
          estSynchronisee: true,
          estSupprimee: false,
        );

        await _insererOuMajLocal(tache);
      }

      await _rafraichirFluxTaches();
    } catch (_) {}
  }

  Future<void> synchroniserVersFirebase() async {
    try {
      final ref = _tachesRef;
      if (ref == null) return;

      final nonSync = await _recupererTachesNonSynchronisees();
      final db = await _baseLocale.database;

      for (final t in nonSync) {
        if (t.estSupprimee) {
          await ref.doc(t.id).delete();
          await db.delete('taches', where: 'id = ?', whereArgs: [t.id]);
        } else {
          await ref.doc(t.id).set(t.toCloudMap());
          await _insererOuMajLocal(t.copyWith(estSynchronisee: true));
        }
      }

      await _rafraichirFluxTaches();
    } catch (_) {}
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
