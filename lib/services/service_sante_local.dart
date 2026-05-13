import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ora/models/modele_sante.dart';

class ServiceSanteLocal {
  static final ServiceSanteLocal instance = ServiceSanteLocal._init();
  static Database? _database;

  ServiceSanteLocal._init();

  Future<Database> get database async {
    _database ??= await _initDB('ora_sante.db');
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
          CREATE TABLE sante (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            date TEXT NOT NULL,
            age INTEGER NOT NULL,
            poids REAL NOT NULL,
            activite TEXT NOT NULL,
            heuresSommeil REAL NOT NULL,
            humeur TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            synced INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<ModeleSante?> obtenirParDate({
    required String userId,
    required String date,
  }) async {
    final db = await database;

    final result = await db.query(
      'sante',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return ModeleSante.fromMap(result.first);
  }

  Future<void> sauvegarder(ModeleSante sante) async {
    final db = await database;

    await db.insert(
      'sante',
      sante.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> sauvegarderDepuisFirebase(ModeleSante santeFirebase) async {
    final local = await obtenirParDate(
      userId: santeFirebase.userId,
      date: santeFirebase.date,
    );

    // Ne jamais écraser une modification locale pas encore synchronisée.
    if (local != null && !local.synced) return;

    if (local == null || santeFirebase.updatedAt.isAfter(local.updatedAt)) {
      await sauvegarder(santeFirebase.copyWith(synced: true));
    }
  }

  Future<List<ModeleSante>> obtenirEntreDates({
    required String userId,
    required String debut,
    required String fin,
  }) async {
    final db = await database;

    final result = await db.query(
      'sante',
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, debut, fin],
      orderBy: 'date ASC',
    );

    return result.map((e) => ModeleSante.fromMap(e)).toList();
  }

  Future<List<ModeleSante>> obtenirNonSynchronises(String userId) async {
    final db = await database;

    final result = await db.query(
      'sante',
      where: 'userId = ? AND synced = ?',
      whereArgs: [userId, 0],
      orderBy: 'updatedAt ASC',
    );

    return result.map((e) => ModeleSante.fromMap(e)).toList();
  }
}
