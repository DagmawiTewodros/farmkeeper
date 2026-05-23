import '../domain/task.dart';

abstract class TasksRepository {
  Future<void> addTask(Task task);
  Future<List<Task>> getTasks();
  Future<Task?> getTaskById(String id);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskCompletion(String id);
}
