class Task {
  final String id;
  final String title;
  final String subtitle;
  final String priority;
  final String priorityColor;
  final String timeOfDay;
  final bool isCompleted;
  final DateTime? deadline;

  const Task({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.priorityColor,
    required this.timeOfDay,
    this.isCompleted = false,
    this.deadline,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'].toString(),
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      priority: map['priority']?.toString() ?? 'LOW',
      priorityColor: map['priority_color']?.toString() ?? 'grey',
      timeOfDay: map['time_of_day']?.toString() ?? 'Morning',
      isCompleted: map['is_completed'] == 1,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'priority': priority,
      'priority_color': priorityColor,
      'time_of_day': timeOfDay,
      'is_completed': isCompleted ? 1 : 0,
      'deadline': deadline?.toIso8601String(),
    };
  }

  Task copyWith({bool? isCompleted, DateTime? deadline}) {
    return Task(
      id: id,
      title: title,
      subtitle: subtitle,
      priority: priority,
      priorityColor: priorityColor,
      timeOfDay: timeOfDay,
      isCompleted: isCompleted ?? this.isCompleted,
      deadline: deadline ?? this.deadline,
    );
  }
}
