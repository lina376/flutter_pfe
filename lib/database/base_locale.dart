import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BaseLocale {
  static final BaseLocale instance = BaseLocale._init();
  static Database? _database;

  BaseLocale._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ora_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 13,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE taches (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL DEFAULT '',
        titre TEXT NOT NULL,
        description TEXT,
        date TEXT,
        heure TEXT,
        categorie TEXT NOT NULL DEFAULT 'Autre',
        priorite TEXT NOT NULL DEFAULT 'moyenne',
        terminee INTEGER NOT NULL DEFAULT 0,
        estSynchronisee INTEGER NOT NULL DEFAULT 1,
        estSupprimee INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL DEFAULT '',
        titre TEXT,
        contenu TEXT,
        liked INTEGER,
        date TEXT,
        estSynchronisee INTEGER,
        estSupprimee INTEGER
      )
    ''');
  }

  Future<void> _ajouterColonneSiAbsente(
    Database db,
    String table,
    String colonne,
    String definition,
  ) async {
    final colonnes = await db.rawQuery('PRAGMA table_info($table)');
    final existe = colonnes.any((c) => c['name'] == colonne);

    if (!existe) {
      await db.execute('ALTER TABLE $table ADD COLUMN $definition');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notes(
          id TEXT PRIMARY KEY,
          titre TEXT,
          contenu TEXT,
          liked INTEGER,
          date TEXT,
          estSynchronisee INTEGER,
          estSupprimee INTEGER
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS taches');

      await db.execute('''
        CREATE TABLE taches (
          id TEXT PRIMARY KEY,
          titre TEXT NOT NULL,
          description TEXT,
          date TEXT,
          heure TEXT,
          categorie TEXT NOT NULL DEFAULT 'Autre',
          priorite TEXT NOT NULL DEFAULT 'moyenne',
          terminee INTEGER NOT NULL DEFAULT 0,
          estSynchronisee INTEGER NOT NULL DEFAULT 1,
          estSupprimee INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }

    if (oldVersion < 8) {
      await _ajouterColonneSiAbsente(
        db,
        'taches',
        'categorie',
        "categorie TEXT NOT NULL DEFAULT 'Autre'",
      );
    }

    if (oldVersion < 10) {
      await _ajouterColonneSiAbsente(
        db,
        'taches',
        'priorite',
        "priorite TEXT NOT NULL DEFAULT 'moyenne'",
      );
    }

    if (oldVersion < 11) {
      await _ajouterColonneSiAbsente(
        db,
        'notes',
        'userId',
        "userId TEXT NOT NULL DEFAULT ''",
      );

      await _ajouterColonneSiAbsente(
        db,
        'taches',
        'userId',
        "userId TEXT NOT NULL DEFAULT ''",
      );
    }

    if (oldVersion < 13) {
      await db.execute('DROP TABLE IF EXISTS alarmes');
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}