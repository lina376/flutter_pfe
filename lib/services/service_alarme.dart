import '../database/base_locale.dart';
import '../models/modele_alarme.dart';

class ServiceAlarme {
  final BaseLocale _baseLocale = BaseLocale.instance;

  Future<List<ModeleAlarme>> recupererToutesLesAlarmes() async {
    final db = await _baseLocale.database;

    final result = await db.query('alarmes', orderBy: 'heure ASC, minute ASC');

    return result.map((e) => ModeleAlarme.fromMap(e)).toList();
  }

  Future<void> ajouterAlarme(ModeleAlarme alarme) async {
    final db = await _baseLocale.database;

    await db.insert('alarmes', alarme.toMap());
  }

  Future<void> supprimerAlarme(int id) async {
    final db = await _baseLocale.database;

    await db.delete('alarmes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> basculerActivation(int id, bool active) async {
    final db = await _baseLocale.database;

    await db.update(
      'alarmes',
      {'active': active ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
