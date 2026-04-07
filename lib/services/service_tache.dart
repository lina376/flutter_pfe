import 'dart:async';
import '../database/base_locale.dart';
import '../models/modele_tache.dart';

class ServiceTache {
  final BaseLocale _baseLocale = BaseLocale.instance;

  final StreamController<List<ModeleTache>> _tachesController =
      StreamController<List<ModeleTache>>.broadcast();

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

    final result = await db.query('taches', orderBy: 'date ASC, heure ASC');

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

  Future<void> ajouterTache({
    required String titre,
    required String heure,
    required DateTime date,
  }) async {
    try {
      final db = await _baseLocale.database;

      final dateSansHeure = DateTime(date.year, date.month, date.day);

      final id = await db.insert('taches', {
        'titre': titre,
        'heure': heure,
        'date': dateSansHeure.toIso8601String(),
        'terminee': 0,
      });

      print('✅ Tâche ajoutée avec id: $id');

      await _rafraichirFluxTaches();
    } catch (e) {
      print('❌ Erreur ajout tâche: $e');
    }
  }

  Future<void> supprimerTache(String idTache) async {
    try {
      final db = await _baseLocale.database;

      await db.delete(
        'taches',
        where: 'id = ?',
        whereArgs: [int.parse(idTache)],
      );

      print('🗑️ Tâche supprimée: $idTache');

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

      await db.update(
        'taches',
        {'terminee': terminee ? 1 : 0},
        where: 'id = ?',
        whereArgs: [int.parse(idTache)],
      );

      print('🔄 Etat tâche modifié: $idTache');

      await _rafraichirFluxTaches();
    } catch (e) {
      print('❌ Erreur modification état tâche: $e');
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
