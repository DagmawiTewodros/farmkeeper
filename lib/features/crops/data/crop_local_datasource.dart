import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/crop.dart';

class CropLocalDataSource {
  Future<List<Crop>> getCrops() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('crops', orderBy: 'planted_date DESC');
    return rows.map(Crop.fromMap).toList();
  }

  Future<void> saveCrop(Crop crop) async {
    final db = await AppDatabase.instance.database;
    await db.insert('crops', crop.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteCrop(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('crops', where: 'id = ?', whereArgs: [id]);
  }
}
