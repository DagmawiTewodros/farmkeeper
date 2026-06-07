import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../domain/task.dart';

class TasksRemoteDataSource {
  static final String _baseApiUrl = kIsWeb
      ? 'http://localhost:3000/api/tasks'
      : 'http://10.0.2.2:3000/api/tasks';

  final http.Client client;

  TasksRemoteDataSource([http.Client? client]) : client = client ?? http.Client();

  Future<List<Task>> getAllTasks() async {
    final response = await client.get(Uri.parse(_baseApiUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch tasks');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.map((item) => Task.fromMap(item as Map<String, dynamic>)).toList();
  }

  Future<Task?> getTaskById(String id) async {
    final response = await client.get(Uri.parse('$_baseApiUrl/$id'));
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch task');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return Task.fromMap(body['data'] as Map<String, dynamic>);
  }

  Future<void> createTask(Task task) async {
    final response = await client.post(
      Uri.parse(_baseApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': task.title,
        'description': task.subtitle,
        'due_date': task.deadline?.toIso8601String(),
        'priority': task.priority,
        'is_completed': task.isCompleted ? 1 : 0,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create task');
    }
  }

  Future<void> updateTask(Task task) async {
    final response = await client.put(
      Uri.parse('$_baseApiUrl/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': task.title,
        'description': task.subtitle,
        'due_date': task.deadline?.toIso8601String(),
        'priority': task.priority,
        'is_completed': task.isCompleted ? 1 : 0,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await client.delete(Uri.parse('$_baseApiUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}
