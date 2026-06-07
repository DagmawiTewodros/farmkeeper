const sqlite3 = require('sqlite3').verbose();
const path = require('path');

if (process.argv.length < 3) {
  console.error('Usage: node inspect_db.js <path-to-db>');
  process.exit(1);
}
const dbPath = path.resolve(process.argv[2]);
console.log('Inspecting DB:', dbPath);
const db = new sqlite3.Database(dbPath, sqlite3.OPEN_READONLY, (err) => {
  if (err) {
    console.error('Failed to open DB', err.message);
    process.exit(1);
  }
});

db.all("SELECT name, type FROM sqlite_master WHERE type IN ('table','view')", (err, rows) => {
  if (err) {
    console.error('Error querying sqlite_master:', err.message);
    process.exit(1);
  }
  console.log('Tables/Views:');
  rows.forEach(r => console.log(' -', r.name, r.type));

  if (rows.length === 0) {
    console.log('No tables found.');
    db.close();
    return;
  }

  const firstTable = rows[0].name;
  console.log('\nSample rows from', firstTable);
  db.all(`SELECT * FROM ${firstTable} LIMIT 5`, (e, sample) => {
    if (e) {
      console.error('Error reading sample rows:', e.message);
    } else {
      console.log(sample);
    }
    db.close();
  });
});
