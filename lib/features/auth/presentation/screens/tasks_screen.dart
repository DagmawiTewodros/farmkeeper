import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../tasks/domain/task.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';

class DailyTasksPage extends ConsumerWidget {
  const DailyTasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksProvider);

    return Container(
      color: const Color(0xFFF5F5EF),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Tasks',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => context.push('/notifications_screen'),
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Color(0xFF215A2A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Saved locally', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Expanded(
                child: tasksState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text(error.toString())),
                  data: (tasks) {
                    final remaining = tasks
                        .where((task) => !task.isCompleted)
                        .length;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                'REMAINING',
                                '$remaining',
                                Icons.pending_actions,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _summaryCard(
                                'TOTAL',
                                '${tasks.length}',
                                Icons.assignment,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: tasks.isEmpty
                              ? const Center(
                                  child: Text('No tasks yet. Tap Add Task.'),
                                )
                              : ListView.separated(
                                  itemCount: tasks.length,
                                  separatorBuilder: (_, index) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) =>
                                      _taskTile(context, ref, tasks[index]),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _addTask(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _taskTile(BuildContext context, WidgetRef ref, Task task) {
    return Card(
      child: ListTile(
        leading: Icon(
          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: const Color(0xFF2E7D32),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('${task.timeOfDay} - ${task.subtitle}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'toggle') {
              await ref
                  .read(tasksRepositoryProvider)
                  .toggleTaskCompletion(task.id);
              ref.invalidate(tasksProvider);
            } else if (value == 'delete') {
              await ref.read(tasksRepositoryProvider).deleteTask(task.id);
              ref.invalidate(tasksProvider);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'toggle',
              child: Text(
                task.isCompleted ? 'Mark incomplete' : 'Mark complete',
              ),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  Future<void> _addTask(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    DateTime? selectedDeadline;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task',
                hintText: 'Enter task description',
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Deadline'),
              subtitle: Text(
                selectedDeadline != null
                    ? '${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}'
                    : 'Select deadline',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  selectedDeadline = picked;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && selectedDeadline != null) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true &&
        titleController.text.isNotEmpty &&
        selectedDeadline != null) {
      final now = DateTime.now();
      await ref
          .read(tasksRepositoryProvider)
          .addTask(
            Task(
              id: now.microsecondsSinceEpoch.toString(),
              title: titleController.text,
              subtitle:
                  'Deadline: ${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}',
              priority: 'MEDIUM',
              priorityColor: 'orange',
              timeOfDay: 'Today',
              deadline: selectedDeadline,
            ),
          );
      ref.invalidate(tasksProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task saved with notification.')),
        );
      }
    }
  }
}
