import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ora/models/modele_sport.dart';

class ServiceSportLocal {
  static final ServiceSportLocal instance = ServiceSportLocal._init();
  static Database? _database;

  ServiceSportLocal._init();

  Future<Database> get database async {
    _database ??= await _initDB('ora_sport.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 2,
      onCreate: _creerBase,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _ajouterColonneSiAbsente(
            db,
            'sport',
            'objectifSport',
            "TEXT NOT NULL DEFAULT 'Rester en forme'",
          );
          await _ajouterColonneSiAbsente(
            db,
            'sport',
            'etatSante',
            "TEXT NOT NULL DEFAULT 'Bonne santé'",
          );
        }
      },
    );
  }

  Future<void> _creerBase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sport (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        date TEXT NOT NULL,
        minutes INTEGER NOT NULL,
        objectifMinutes INTEGER NOT NULL,
        objectifSport TEXT NOT NULL,
        etatSante TEXT NOT NULL,
        typeSeance TEXT NOT NULL,
        intensite TEXT NOT NULL,
        calories INTEGER NOT NULL,
        updatedAt TEXT NOT NULL,
        synced INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _ajouterColonneSiAbsente(
    Database db,
    String table,
    String colonne,
    String type,
  ) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $colonne $type');
    } catch (_) {}
  }

  Future<ModeleSport?> obtenirParDate(String userId, String date) async {
    final db = await database;

    final result = await db.query(
      'sport',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return ModeleSport.fromMap(result.first);
  }

  Future<void> sauvegarder(ModeleSport sport) async {
    final db = await database;

    await db.insert(
      'sport',
      sport.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ModeleSport>> obtenirEntreDates({
    required String userId,
    required String debut,
    required String fin,
  }) async {
    final db = await database;

    final result = await db.query(
      'sport',
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, debut, fin],
      orderBy: 'date ASC',
    );

    return result.map((e) => ModeleSport.fromMap(e)).toList();
  }

  Future<List<ModeleSport>> obtenirNonSynchronises(String userId) async {
    final db = await database;

    final result = await db.query(
      'sport',
      where: 'userId = ? AND synced = ?',
      whereArgs: [userId, 0],
    );

    return result.map((e) => ModeleSport.fromMap(e)).toList();
  }
}
