const { exec, execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const FLUTTER_PKG = 'com.example.farmkeeper';
const LOCAL_COPY = path.resolve(__dirname, '..', 'farmkeeper_offline.db');
const IMPORT_SCRIPT = path.resolve(__dirname, 'import_from_flutter_db.js');
const PULL_INTERVAL_MS = 2000;

let lastHash = null;

function sha1(filePath) {
  try {
    const data = fs.readFileSync(filePath);
    return crypto.createHash('sha1').update(data).digest('hex');
  } catch (e) {
    return null;
  }
}

function pullDb(cb) {
  // Try exec-out run-as first
  const cmd = `adb exec-out run-as ${FLUTTER_PKG} cat databases/farmkeeper_offline.db > "${LOCAL_COPY}"`;
  exec(cmd, { maxBuffer: 1024 * 1024 * 50 }, (err, stdout, stderr) => {
    if (err) {
      // fallback to copy-to-sdcard method
      console.error('exec-out failed, falling back to sdcard method:', err.message);
      const fallback = `adb shell "run-as ${FLUTTER_PKG} cp /data/data/${FLUTTER_PKG}/databases/farmkeeper_offline.db /sdcard/" && adb pull /sdcard/farmkeeper_offline.db "${LOCAL_COPY}" && adb shell "run-as ${FLUTTER_PKG} rm /sdcard/farmkeeper_offline.db"`;
      exec(fallback, { maxBuffer: 1024 * 1024 * 50 }, (e2) => {
        if (e2) return cb(e2);
        cb(null);
      });
      return;
    }
    cb(null);
  });
}

function runImporter() {
  try {
    console.log('Running importer...');
    const out = execSync(`node "${IMPORT_SCRIPT}" "${LOCAL_COPY}"`, { stdio: 'inherit' });
  } catch (e) {
    console.error('Importer failed:', e.message);
  }
}

console.log('Starting sync daemon: pulling emulator DB and importing changes to backend/farmkeeper.db');
console.log('Make sure emulator is running and app installed in debug mode.');

(async function loop() {
  while (true) {
    try {
      await new Promise((res) => pullDb((err) => res()));
      const h = sha1(LOCAL_COPY);
      if (h && h !== lastHash) {
        console.log(new Date().toISOString(), 'Detected DB change or new copy.');
        lastHash = h;
        runImporter();
      }
    } catch (e) {
      console.error('Error during sync:', e.message || e);
    }
    await new Promise((r) => setTimeout(r, PULL_INTERVAL_MS));
  }
})();
