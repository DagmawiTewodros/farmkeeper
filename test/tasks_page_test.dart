import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmkeeper/features/auth/presentation/screens/tasks_screen.dart';
import 'package:farmkeeper/features/tasks/data/tasks_repository.dart';
import 'package:farmkeeper/features/tasks/domain/task.dart';
import 'package:farmkeeper/features/tasks/presentation/providers/tasks_provider.dart';

class FakeTasksRepository implements TasksRepository {
  final List<Task> _tasks;
  FakeTasksRepository([List<Task>? tasks]) : _tasks = tasks ?? [];

  @override
  Future<void> addTask(Task task) async => _tasks.add(task);

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final matches = _tasks.where((task) => task.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<List<Task>> getTasks() async => List<Task>.from(_tasks);

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((element) => element.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }
}

void main() {
  testWidgets('DailyTasksPage shows task summary and list from repository', (tester) async {
    final repository = FakeTasksRepository([
      const Task(
        id: 'task_1',
        title: 'Water compost',
        subtitle: 'Keep humidity steady',
        priority: 'LOW',
        priorityColor: 'grey',
        timeOfDay: 'Afternoon',
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tasksRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: DailyTasksPage()),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Daily Tasks'), findsOneWidget);
    expect(find.text('Water compost'), findsOneWidget);
    expect(find.text('Saved locally'), findsOneWidget);
    expect(find.byIcon(Icons.assignment), findsOneWidget);
  });
}
