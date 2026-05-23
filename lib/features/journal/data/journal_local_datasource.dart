import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/journal_entry.dart';

class JournalLocalDataSource {
  Future<List<JournalEntry>> getEntries() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('journal_entries', orderBy: 'created_at DESC');
    return rows.map(JournalEntry.fromMap).toList();
  }

  Future<void> saveEntry(JournalEntry entry) async {
    final db = await AppDatabase.instance.database;
    await db.insert('journal_entries', entry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteEntry(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }
}
