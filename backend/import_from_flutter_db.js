const sqlite3 = require('sqlite3').verbose();
const path = require('path');

if (process.argv.length < 3) {
  console.error('Usage: node import_from_flutter_db.js <path-to-flutter-db>');
  process.exit(1);
}

const flutterDbPath = path.resolve(process.argv[2]);
const backendDbPath = path.resolve(__dirname, 'farmkeeper.db');

console.log('Flutter DB:', flutterDbPath);
console.log('Backend DB:', backendDbPath);

const openDb = (dbPath) => new sqlite3.Database(dbPath, sqlite3.OPEN_READWRITE, (err) => {
  if (err) {
    console.error('Failed to open DB', dbPath, err.message);
    process.exit(1);
  }
});

const srcDb = openDb(flutterDbPath);
const dstDb = openDb(backendDbPath);

const readTasks = () => new Promise((resolve, reject) => {
  srcDb.all('SELECT * FROM tasks', (err, rows) => {
    if (err) return reject(err);
    resolve(rows || []);
  });
});

const taskExists = (title, due_date) => new Promise((resolve, reject) => {
  dstDb.get('SELECT id FROM tasks WHERE title = ? AND (due_date = ? OR due_date IS ?)', [title, due_date, due_date], (err, row) => {
    if (err) return reject(err);
    resolve(!!row);
  });
});

const insertTask = (task) => new Promise((resolve, reject) => {
  // Map Flutter task fields to backend schema
  const title = task.title || '';
  const description = task.subtitle || '';
  // prefer deadline as due_date; fallback to time_of_day
  const due_date = task.deadline || task.time_of_day || null;
  const priority = task.priority || 'medium';
  const is_completed = (task.is_completed === 1 || task.is_completed === true) ? 1 : 0;

  const sql = `INSERT INTO tasks (title, description, due_date, priority, is_completed) VALUES (?, ?, ?, ?, ?)`;
  dstDb.run(sql, [title, description, due_date, priority, is_completed], function(err) {
    if (err) return reject(err);
    resolve(this.lastID);
  });
});

(async () => {
  try {
    const tasks = await readTasks();
    console.log(`Found ${tasks.length} task(s) in Flutter DB.`);
    let imported = 0;
    for (const t of tasks) {
      const title = t.title || '';
      const due_date = t.deadline || t.time_of_day || null;
      const exists = await taskExists(title, due_date);
      if (exists) {
        console.log(`Skipping existing task: "${title}" due ${due_date}`);
        continue;
      }
      const id = await insertTask(t);
      imported++;
      console.log(`Inserted task id ${id}: "${title}"`);
    }
    console.log(`Import complete. Imported ${imported} new task(s).`);
    srcDb.close();
    dstDb.close();
  } catch (err) {
    console.error('Error during import:', err.message || err);
    process.exit(1);
  }
})();
