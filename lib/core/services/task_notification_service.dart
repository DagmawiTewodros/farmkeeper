import '../../../features/tasks/domain/task.dart';

class TaskNotification {
  final String taskTitle;
  final String message;
  final DateTime deadline;

  const TaskNotification({
    required this.taskTitle,
    required this.message,
    required this.deadline,
  });
}

class TaskNotificationService {
  static List<TaskNotification> generateNotifications(List<Task> tasks) {
    final notifications = <TaskNotification>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    for (final task in tasks) {
      if (task.deadline == null || task.isCompleted) continue;

      final deadlineDate = DateTime(
        task.deadline!.year,
        task.deadline!.month,
        task.deadline!.day,
      );

      if (deadlineDate == today) {
        notifications.add(
          TaskNotification(
            taskTitle: task.title,
            message: 'Task due today!',
            deadline: task.deadline!,
          ),
        );
      } else if (deadlineDate == tomorrow) {
        notifications.add(
          TaskNotification(
            taskTitle: task.title,
            message: 'Task due tomorrow',
            deadline: task.deadline!,
          ),
        );
      } else if (deadlineDate.isBefore(today)) {
        notifications.add(
          TaskNotification(
            taskTitle: task.title,
            message: 'Task overdue!',
            deadline: task.deadline!,
          ),
        );
      }
    }

    return notifications;
  }

  static String getDeadlineDisplay(DateTime? deadline) {
    if (deadline == null) return 'No deadline';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);
    final daysUntil = deadlineDate.difference(today).inDays;

    if (daysUntil == 0) return 'Due today';
    if (daysUntil == 1) return 'Due tomorrow';
    if (daysUntil < 0) return 'Overdue';
    return 'Due in $daysUntil days';
  }
}
