import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/calendar_event.dart';

class CalendarLocalDataSource {
  Future<List<CalendarEvent>> getEvents() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('calendar_events', orderBy: 'event_date ASC');
    return rows.map(CalendarEvent.fromMap).toList();
  }

  Future<void> saveEvent(CalendarEvent event) async {
    final db = await AppDatabase.instance.database;
    await db.insert('calendar_events', event.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteEvent(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('calendar_events', where: 'id = ?', whereArgs: [id]);
  }
}
