class CalendarEvent {
  final String id;
  final String title;
  final String eventDate;
  final String note;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.note,
  });

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'].toString(),
      title: map['title']?.toString() ?? '',
      eventDate: map['event_date']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'event_date': eventDate,
      'note': note,
    };
  }
}
