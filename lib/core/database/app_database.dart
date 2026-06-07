import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'farmkeeper_offline.db');

    
    print('Opening local Flutter DB at: $path');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'farmer',
            token TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            user_id INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            subtitle TEXT NOT NULL,
            priority TEXT NOT NULL,
            priority_color TEXT NOT NULL,
            time_of_day TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            deadline TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE crops (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            variety TEXT NOT NULL,
            planted_date TEXT NOT NULL,
            status TEXT NOT NULL,
            watering_interval_days INTEGER NOT NULL DEFAULT 3,
            harvest_time TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE journal_entries (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            note TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE weather_cache (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            location TEXT NOT NULL,
            temperature TEXT NOT NULL,
            summary TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE calendar_events (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            event_date TEXT NOT NULL,
            note TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE crops ADD COLUMN watering_interval_days INTEGER NOT NULL DEFAULT 3',
          );
          await db.execute('ALTER TABLE crops ADD COLUMN harvest_time TEXT');
          await db.execute('ALTER TABLE tasks ADD COLUMN deadline TEXT');
        }
      },
    );
  }
}
