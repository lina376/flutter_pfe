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
      version: 7,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE taches (
        id TEXT PRIMARY KEY,
        titre TEXT NOT NULL,
        description TEXT,
        date TEXT,
        heure TEXT,
        terminee INTEGER NOT NULL DEFAULT 0,
        estSynchronisee INTEGER NOT NULL DEFAULT 1,
        estSupprimee INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        titre TEXT,
        contenu TEXT,
        liked INTEGER,
        date TEXT,
        estSynchronisee INTEGER,
        estSupprimee INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE alarmes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        note TEXT,
        heure INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        jours TEXT NOT NULL,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
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
          terminee INTEGER NOT NULL DEFAULT 0,
          estSynchronisee INTEGER NOT NULL DEFAULT 1,
          estSupprimee INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }

    if (oldVersion < 7) {
      await db.execute('DROP TABLE IF EXISTS alarmes');

      await db.execute('''
        CREATE TABLE alarmes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titre TEXT NOT NULL,
          note TEXT,
          heure INTEGER NOT NULL,
          minute INTEGER NOT NULL,
          jours TEXT NOT NULL,
          active INTEGER NOT NULL DEFAULT 1
        )
      ''');
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
