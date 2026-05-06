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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE eau (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            verres INTEGER NOT NULL,
            objectif INTEGER NOT NULL,
            updatedAt TEXT NOT NULL,
            synced INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<ModeleEau?> obtenirParDate(String date) async {
    final db = await database;

    final result = await db.query(
      'eau',
      where: 'date = ?',
      whereArgs: [date],
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

  Future<List<ModeleEau>> obtenirEntreDates(String debut, String fin) async {
    final db = await database;

    final result = await db.query(
      'eau',
      where: 'date >= ? AND date <= ?',
      whereArgs: [debut, fin],
      orderBy: 'date ASC',
    );

    return result.map((e) => ModeleEau.fromMap(e)).toList();
  }

  Future<List<ModeleEau>> obtenirNonSynchronises() async {
    final db = await database;

    final result = await db.query('eau', where: 'synced = ?', whereArgs: [0]);

    return result.map((e) => ModeleEau.fromMap(e)).toList();
  }
}
