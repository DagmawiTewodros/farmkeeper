const sqlite3 = require('sqlite3').verbose();
const path = require('path');

let sqliteDb = null;

const convertPlaceholders = (sql) => sql.replace(/\$\d+/g, '?').replace(/RETURNING\s+id/gi, '');

const connectSqlite = () => {
  const dbPath = path.resolve(__dirname, 'farmkeeper.db');
  sqliteDb = new sqlite3.Database(dbPath, sqlite3.OPEN_READWRITE | sqlite3.OPEN_CREATE, (err) => {
    if (err) {
      console.error('SQLite open error:', err);
      throw err;
    }
    console.log(`SQLite database opened at ${dbPath}`);
  });
};

const query = (text, params = []) => {
  const sql = convertPlaceholders(text);

  return new Promise((resolve, reject) => {
    const normalized = sql.trim().toUpperCase();
    if (normalized.startsWith('SELECT') || normalized.startsWith('PRAGMA')) {
      sqliteDb.all(sql, params, (err, rows) => {
        if (err) return reject(err);
        resolve({ rows, rowCount: rows.length });
      });
      return;
    }

    sqliteDb.run(sql, params, function (err) {
      if (err) return reject(err);
      resolve({ lastID: this.lastID, changes: this.changes, rows: this.lastID ? [{ id: this.lastID }] : [] });
    });
  });
};

const createSqliteTables = async () => {
  await query(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      salt TEXT NOT NULL,
      token TEXT,
      role TEXT DEFAULT 'farmer',
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  `);

  await query(`
    CREATE TABLE IF NOT EXISTS crops (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      variety TEXT,
      planting_date TEXT NOT NULL,
      days_to_maturity INTEGER NOT NULL,
      estimated_harvest_date TEXT NOT NULL,
      field_name TEXT NOT NULL,
      quantity REAL NOT NULL,
      photo_url TEXT,
      watering_interval_days INTEGER,
      last_watered_date TEXT,
      actual_harvest_date TEXT,
      yield_amount REAL,
      yield_unit TEXT,
      quality_rating INTEGER,
      harvest_notes TEXT,
      is_harvested INTEGER DEFAULT 0,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  `);

  await query(`
    CREATE TABLE IF NOT EXISTS crop_journal (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      crop_id INTEGER NOT NULL,
      category TEXT NOT NULL,
      note_text TEXT,
      photo_url TEXT,
      weather_condition TEXT,
      pest_name TEXT,
      treatment_applied TEXT,
      fertilizer_name TEXT,
      fertilizer_quantity TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE
    )
  `);

  await query(`
    CREATE TABLE IF NOT EXISTS tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      due_date TEXT,
      priority TEXT DEFAULT 'medium',
      is_completed INTEGER DEFAULT 0,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  `);

  await query(`
    CREATE TABLE IF NOT EXISTS calendar_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      event_date TEXT NOT NULL,
      note TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  `);
};

const initializeDB = async () => {
  connectSqlite();
  await createSqliteTables();
  console.log('SQLite-only offline backend initialized.');
};

module.exports = { initializeDB, query };
