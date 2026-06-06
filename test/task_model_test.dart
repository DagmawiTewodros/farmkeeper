import 'package:flutter_test/flutter_test.dart';
import 'package:farmkeeper/features/tasks/domain/task.dart';

void main() {
  test('Task toMap and fromMap roundtrip', () {
    final task = Task(
      id: 'task_42',
      title: 'Plant lettuce',
      subtitle: 'Fast-growing variety',
      priority: 'HIGH',
      priorityColor: 'red',
      timeOfDay: 'Morning',
      isCompleted: true,
      deadline: DateTime.parse('2026-07-01T12:00:00'),
    );

    final map = task.toMap();
    final restored = Task.fromMap(map);

    expect(restored.id, task.id);
    expect(restored.title, task.title);
    expect(restored.subtitle, task.subtitle);
    expect(restored.priority, task.priority);
    expect(restored.priorityColor, task.priorityColor);
    expect(restored.timeOfDay, task.timeOfDay);
    expect(restored.isCompleted, task.isCompleted);
    expect(restored.deadline, task.deadline);
  });

  test('copyWith updates completion and deadline', () {
    final original = Task(
      id: 'task_99',
      title: 'Inspect greenhouse',
      subtitle: 'Check humidity sensors',
      priority: 'MEDIUM',
      priorityColor: 'orange',
      timeOfDay: 'Afternoon',
    );

    final updated = original.copyWith(
      isCompleted: true,
      deadline: DateTime.parse('2026-08-10T08:00:00'),
    );

    expect(updated.isCompleted, isTrue);
    expect(updated.deadline, isNotNull);
    expect(updated.title, original.title);
    expect(updated.id, original.id);
  });
}
