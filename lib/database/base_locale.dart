import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE taches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        description TEXT,
        date TEXT,
        heure TEXT,
        terminee INTEGER NOT NULL DEFAULT 0
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
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
