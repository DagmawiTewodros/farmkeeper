import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/weather_snapshot.dart';

class WeatherLocalDataSource {
  Future<WeatherSnapshot?> getWeather() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('weather_cache', where: 'id = ?', whereArgs: [1], limit: 1);
    if (rows.isEmpty) return null;
    return WeatherSnapshot.fromMap(rows.first);
  }

  Future<void> saveWeather(WeatherSnapshot weather) async {
    final db = await AppDatabase.instance.database;
    await db.insert('weather_cache', weather.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
