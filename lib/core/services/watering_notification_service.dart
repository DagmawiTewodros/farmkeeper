import '../../../features/crops/domain/crop.dart';

class WateringNotification {
  final String id;
  final String cropName;
  final String message;
  final DateTime dueDate;
  final bool isRead;

  WateringNotification({
    required this.id,
    required this.cropName,
    required this.message,
    required this.dueDate,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'crop_name': cropName,
      'message': message,
      'due_date': dueDate.toIso8601String(),
      'is_read': isRead ? 1 : 0,
    };
  }

  factory WateringNotification.fromMap(Map<String, dynamic> map) {
    return WateringNotification(
      id: map['id'].toString(),
      cropName: map['crop_name']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      dueDate: DateTime.tryParse(map['due_date']?.toString() ?? '') ?? DateTime.now(),
      isRead: (map['is_read'] as int?) == 1,
    );
  }
}

class WateringNotificationService {
  static List<WateringNotification> generateNotifications(List<Crop> crops) {
    final notifications = <WateringNotification>[];
    final now = DateTime.now();

    for (final crop in crops) {
      final plantedDate = DateTime.tryParse(crop.plantedDate) ?? now;
      final daysSincePlanting = now.difference(plantedDate).inDays;
      
      if (daysSincePlanting >= crop.wateringIntervalDays) {
        final lastWateringCycle = (daysSincePlanting ~/ crop.wateringIntervalDays) * crop.wateringIntervalDays;
        final nextWatering = plantedDate.add(Duration(days: lastWateringCycle + crop.wateringIntervalDays));
        final daysUntilWatering = nextWatering.difference(now).inDays;

        if (daysUntilWatering <= 0) {
          notifications.add(WateringNotification(
            id: '${crop.id}_${now.millisecondsSinceEpoch}',
            cropName: crop.name,
            message: 'Watering due today',
            dueDate: now,
          ));
        } else if (daysUntilWatering <= 1) {
          notifications.add(WateringNotification(
            id: '${crop.id}_${now.millisecondsSinceEpoch}',
            cropName: crop.name,
            message: 'Watering due tomorrow',
            dueDate: now.add(const Duration(days: 1)),
          ));
        }
      }
    }

    return notifications;
  }

  static String getNextWateringDate(Crop crop) {
    final plantedDate = DateTime.tryParse(crop.plantedDate) ?? DateTime.now();
    final daysSincePlanting = DateTime.now().difference(plantedDate).inDays;
    final nextCycle = ((daysSincePlanting ~/ crop.wateringIntervalDays) + 1) * crop.wateringIntervalDays;
    final nextWatering = plantedDate.add(Duration(days: nextCycle));
    return '${nextWatering.month}/${nextWatering.day}';
  }
}
