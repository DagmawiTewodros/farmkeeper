import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/user.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final db = await AppDatabase.instance.database;
    final sessions = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (sessions.isEmpty) return null;

    final userId = sessions.first['user_id'];
    final users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (users.isEmpty) return null;

    return User.fromJson(users.first);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final db = await AppDatabase.instance.database;
      final users = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
        limit: 1,
      );

      if (users.isEmpty) {
        throw Exception('Invalid email or password');
      }

      final user = User.fromJson(users.first);
      await db.insert('sessions', {
        'id': 1,
        'user_id': user.id,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final db = await AppDatabase.instance.database;
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        throw Exception('An account with this email already exists');
      }

      final token = 'offline-token-${DateTime.now().millisecondsSinceEpoch}';
      final id = await db.insert('users', {
        'name': name,
        'email': email,
        'password': password,
        'role': 'farmer',
        'token': token,
      });

      final user = User(id: id, name: name, email: email, token: token);
      await db.insert('sessions', {
        'id': 1,
        'user_id': id,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    final db = await AppDatabase.instance.database;
    await db.delete('sessions', where: 'id = ?', whereArgs: [1]);
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  () => AuthNotifier(),
);
