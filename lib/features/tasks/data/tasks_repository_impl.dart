import '../domain/task.dart';
import 'tasks_remote_datasource.dart';
import 'tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksRemoteDataSource remoteDataSource;

  const TasksRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> addTask(Task task) {
    return remoteDataSource.createTask(task);
  }

  @override
  Future<List<Task>> getTasks() async {
    final tasks = await remoteDataSource.getAllTasks();
    return tasks;
  }

  @override
  Future<Task?> getTaskById(String id) {
    return remoteDataSource.getTaskById(id);
  }

  @override
  Future<void> updateTask(Task task) {
    return remoteDataSource.updateTask(task);
  }

  @override
  Future<void> deleteTask(String id) {
    return remoteDataSource.deleteTask(id);
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final task = await getTaskById(id);
    if (task == null) return;
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }
}
