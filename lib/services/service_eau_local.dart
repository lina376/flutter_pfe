import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ora/models/modele_eau.dart';

class ServiceEauLocal {
  static final ServiceEauLocal instance = ServiceEauLocal._init();
  static Database? _database;

  ServiceEauLocal._init();

  Future<Database> get database async {
    _database ??= await _initDB('ora_eau.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE eau (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            date TEXT NOT NULL,
            verres INTEGER NOT NULL,
            objectif INTEGER NOT NULL,
            updatedAt TEXT NOT NULL,
            synced INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          final colonnes = await db.rawQuery('PRAGMA table_info(eau)');
          final existe = colonnes.any((c) => c['name'] == 'userId');
          if (!existe) {
            await db.execute(
              "ALTER TABLE eau ADD COLUMN userId TEXT NOT NULL DEFAULT ''",
            );
          }
        }
      },
    );
  }

  Future<ModeleEau?> obtenirParDate(String userId, String date) async {
    final db = await database;

    final result = await db.query(
      'eau',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return ModeleEau.fromMap(result.first);
  }

  Future<void> sauvegarder(ModeleEau eau) async {
    final db = await database;

    await db.insert(
      'eau',
      eau.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> sauvegarderDepuisFirebase(ModeleEau eauFirebase) async {
    final local = await obtenirParDate(eauFirebase.userId, eauFirebase.date);

    // Ne jamais écraser une modification locale pas encore synchronisée.
    if (local != null && !local.synced) return;

    if (local == null || eauFirebase.updatedAt.isAfter(local.updatedAt)) {
      await sauvegarder(eauFirebase.copyWith(synced: true));
    }
  }

  Future<List<ModeleEau>> obtenirEntreDates({
    required String userId,
    required String debut,
    required String fin,
  }) async {
    final db = await database;

    final result = await db.query(
      'eau',
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, debut, fin],
      orderBy: 'date ASC',
    );

    return result.map((e) => ModeleEau.fromMap(e)).toList();
  }

  Future<List<ModeleEau>> obtenirNonSynchronises(String userId) async {
    final db = await database;

    final result = await db.query(
      'eau',
      where: 'userId = ? AND synced = ?',
      whereArgs: [userId, 0],
      orderBy: 'updatedAt ASC',
    );

    return result.map((e) => ModeleEau.fromMap(e)).toList();
  }
}
