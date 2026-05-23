import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../crops/presentation/providers/crop_provider.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';
import '../../../../core/services/watering_notification_service.dart';
import '../../../../core/services/task_notification_service.dart';

class FarmNotification {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconColor;

  const FarmNotification({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
  });
}

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final List<FarmNotification> _activeNotifications = [];
  final List<FarmNotification> _archivedNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadWateringNotifications();
  }

  void _loadWateringNotifications() {
    final cropsState = ref.read(cropsProvider);
    final tasksState = ref.read(tasksProvider);

    cropsState.when(
      loading: () {},
      error: (error, _) {},
      data: (crops) {
        final wateringNotifications =
            WateringNotificationService.generateNotifications(crops);

        tasksState.when(
          loading: () {},
          error: (error, _) {},
          data: (tasks) {
            final taskNotifications =
                TaskNotificationService.generateNotifications(tasks);

            setState(() {
              _activeNotifications.clear();

              for (final notification in wateringNotifications) {
                _activeNotifications.add(
                  FarmNotification(
                    title: 'Watering Due: ${notification.cropName}',
                    subtitle: notification.message,
                    time: 'Now',
                    icon: Icons.water_drop,
                    iconColor: Colors.blue,
                  ),
                );
              }

              for (final notification in taskNotifications) {
                _activeNotifications.add(
                  FarmNotification(
                    title: 'Task Due: ${notification.taskTitle}',
                    subtitle: notification.message,
                    time: 'Now',
                    icon: Icons.task_alt,
                    iconColor: Colors.orange,
                  ),
                );
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F1),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Notification history',
            onPressed: _showArchiveHistory,
            icon: const Icon(Icons.history, color: Color(0xFF2E7D32)),
          ),
          TextButton(
            onPressed: _activeNotifications.isEmpty
                ? null
                : _archiveAllNotifications,
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_activeNotifications.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 44,
                    color: Color(0xFF2E7D32),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'All caught up',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Read notifications were moved to history.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ..._activeNotifications.map(notificationCard),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WEEKLY SUMMARY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${32 + _archivedNotifications.length} Alerts Resolved',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your farm efficiency increased by 12% this week.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _archiveAllNotifications() {
    setState(() {
      _archivedNotifications.insertAll(0, _activeNotifications);
      _activeNotifications.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications moved to history.')),
    );
  }

  void _showArchiveHistory() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notification History'),
          content: SizedBox(
            width: double.maxFinite,
            child: _archivedNotifications.isEmpty
                ? const Text('No archived notifications yet.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _archivedNotifications.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final notification = _archivedNotifications[index];
                      return ListTile(
                        leading: Icon(
                          notification.icon,
                          color: notification.iconColor,
                        ),
                        title: Text(notification.title),
                        subtitle: Text(notification.time),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget notificationCard(FarmNotification notification) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: notification.iconColor.withValues(alpha: 0.2),
          child: Icon(notification.icon, color: notification.iconColor),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            notification.subtitle,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        trailing: Text(
          notification.time,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
