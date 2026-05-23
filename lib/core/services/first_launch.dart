import '../database/app_database.dart';

class FirstLaunchService {
  static Future<bool> isFirstLaunch() async {
    final db = await AppDatabase.instance.database;
    final users = await db.query('users', limit: 1);
    return users.isEmpty;
  }

  static Future<bool> hasActiveSession() async {
    final db = await AppDatabase.instance.database;
    final sessions = await db.query('sessions', where: 'id = ?', whereArgs: [1], limit: 1);
    return sessions.isNotEmpty;
  }

  static Future<String> getInitialRoute() async {
    if (await isFirstLaunch()) return '/onboarding_screen';
    if (await hasActiveSession()) return '/home';
    return '/login_screen';
  }
}
