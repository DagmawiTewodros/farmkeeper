import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/tasks_local_datasource.dart';
import '../../data/tasks_repository.dart';
import '../../data/tasks_repository_impl.dart';
import '../../domain/task.dart';

final tasksLocalDataSourceProvider = Provider<TasksLocalDataSource>((ref) {
  return TasksLocalDataSource();
});

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepositoryImpl(ref.watch(tasksLocalDataSourceProvider));
});

final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.watch(tasksRepositoryProvider);
  final tasks = await repository.getTasks();
  if (tasks.isEmpty) {
    await _seedDefaultTasks(repository);
    return repository.getTasks();
  }
  return tasks;
});

Future<void> _seedDefaultTasks(TasksRepository repository) async {
  final defaultTasks = [
    const Task(
      id: 'task_1',
      title: 'Water Plot A-4',
      subtitle: 'Ensure drip saturation for tomatoes',
      priority: 'HIGH',
      priorityColor: 'red',
      timeOfDay: 'Morning',
    ),
    const Task(
      id: 'task_2',
      title: 'Check Soil pH',
      subtitle: 'Target 6.5 for berry patch',
      priority: 'MEDIUM',
      priorityColor: 'orange',
      timeOfDay: 'Morning',
    ),
    const Task(
      id: 'task_3',
      title: 'Clean Seed Trays',
      subtitle: 'Sanitize batch for winter kale',
      priority: 'LOW',
      priorityColor: 'grey',
      timeOfDay: 'Afternoon',
    ),
  ];

  for (final task in defaultTasks) {
    await repository.addTask(task);
  }
}
