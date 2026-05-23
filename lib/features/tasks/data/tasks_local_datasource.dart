import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/task.dart';

class TasksLocalDataSource {
  static const String tableName = 'tasks';

  Future<List<Task>> getAllTasks() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(tableName, orderBy: 'time_of_day ASC');
    return rows.map(Task.fromMap).toList();
  }

  Future<Task?> getTaskById(String id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(tableName, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Task.fromMap(rows.first);
  }

  Future<void> insertTask(Task task) async {
    final db = await AppDatabase.instance.database;
    await db.insert(tableName, task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTask(Task task) async {
    final db = await AppDatabase.instance.database;
    await db.update(tableName, task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
