import '../domain/task.dart';
import 'tasks_local_datasource.dart';
import 'tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksLocalDataSource localDataSource;

  const TasksRepositoryImpl(this.localDataSource);

  @override
  Future<void> addTask(Task task) {
    return localDataSource.insertTask(task);
  }

  @override
  Future<List<Task>> getTasks() async {
    final cachedTasks = await localDataSource.getAllTasks();
    if (cachedTasks.isNotEmpty) return cachedTasks;
    return [];
  }

  @override
  Future<Task?> getTaskById(String id) {
    return localDataSource.getTaskById(id);
  }

  @override
  Future<void> updateTask(Task task) {
    return localDataSource.updateTask(task);
  }

  @override
  Future<void> deleteTask(String id) {
    return localDataSource.deleteTask(id);
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final task = await getTaskById(id);
    if (task == null) return;
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }
}
